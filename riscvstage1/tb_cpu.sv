`timescale 1ns/1ps

module tb_cpu;

    // ------------------------------------
    // Parameters
    // ------------------------------------
    localparam CLK_FREQ = 100_000_000;
    localparam BAUD     = 115200;
    localparam BIT_TIME = 1_000_000_000 / BAUD; // ns

    // ------------------------------------
    // Signals
    // ------------------------------------
    reg clk;
    reg rst_n;
    reg rx;
    reg load_en;
    wire pc_op;

    // ------------------------------------
    // DUT
    // ------------------------------------
    top_cpu_uart dut (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .load_en(load_en),
        .pc_op(pc_op)
    );

    // ------------------------------------
    // Clock: 100 MHz
    // ------------------------------------
    always #5 clk = ~clk;

    // ------------------------------------
    // Instruction memory (simulation only)
    // ------------------------------------
    logic [47:0] insmem [0:125];
    integer i;

    initial begin
        $readmemh("inst_mem.mem", insmem);
    end

    // ------------------------------------
    // UART TX tasks (stimulus)
    // ------------------------------------
    task send_uart_byte(input [7:0] data);
        integer b;
        begin
            rx = 0;                // start bit
            #(BIT_TIME);

            for (b = 0; b < 8; b = b + 1) begin
                rx = data[b];      // LSB first
                #(BIT_TIME);
            end

            rx = 1;                // stop bit
            #(BIT_TIME);
        end
    endtask

    task send_uart_48(input [47:0] data);
        begin
            send_uart_byte(data[47:40]);
            send_uart_byte(data[39:32]);
            send_uart_byte(data[31:24]);
            send_uart_byte(data[23:16]);
            send_uart_byte(data[15:8]);
            send_uart_byte(data[7:0]);
        end
    endtask

    // ------------------------------------
    // Test sequence
    // ------------------------------------
    initial begin
        // init
        clk     = 0;
        rst_n   = 0;
        rx      = 1;   // UART idle
        load_en = 0;

        #100;
        rst_n = 1;

        #1000;

        // -----------------------------
        // LOAD PHASE
        // -----------------------------
        load_en = 1;   // enable instruction loading

        for (i = 0; i < 126; i = i + 1) begin
            send_uart_48(insmem[i]);
            #(6 * 10 * BIT_TIME); // guard time (6 bytes, 10 bits each)
        end

        load_en = 0;   // CPU starts executing

        // -----------------------------
        // RUN PHASE
        // -----------------------------
        #10_000_000;

        $finish;
    end

endmodule
