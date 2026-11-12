module uart_rx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 115200
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        rx,
    output reg  [11:0] load_addr,
    output reg  [31:0] load_data
);

    // -------------------------------------------------
    // 16x oversampling baud generator
    // -------------------------------------------------
    localparam integer OVERSAMPLE = 16;
    localparam integer BAUD_DIV =
        (CLK_FREQ + (BAUD*OVERSAMPLE)/2) / (BAUD*OVERSAMPLE);

    reg [$clog2(BAUD_DIV)-1:0] baud_cnt;
    reg os_tick;

    always @(posedge clk or negedge rst_n) begin        
        if (!rst_n) begin
            baud_cnt <= 0;
            os_tick  <= 0;
        end else if (baud_cnt == BAUD_DIV-1) begin
            baud_cnt <= 0;
            os_tick  <= 1;
        end else begin
            baud_cnt <= baud_cnt + 1;
            os_tick  <= 0;
        end
    end

    // -------------------------------------------------
    // RX synchronizer (MANDATORY on FPGA)
    // -------------------------------------------------
    reg rx_ff2;
    always @(posedge clk) begin
        rx_ff2 <= rx;
        // rx_ff2 <= rx_ff1;
    end
    wire rx_sync = rx_ff2;

    // -------------------------------------------------
    // UART receiver FSM
    // -------------------------------------------------
    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;

    reg [3:0] os_cnt;
    reg [2:0] bit_cnt;
    reg [7:0] shift;

    reg       rx_valid;
    reg [7:0] rx_data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            os_cnt   <= 0;
            bit_cnt  <= 0;
            shift    <= 0;
            rx_valid <= 0;
            rx_data  <= 0;
        end else begin
            rx_valid <= 0;

            if (os_tick) begin
                case (state)
                    IDLE: begin
                        if (rx_sync == 0) begin
                            os_cnt <= OVERSAMPLE/2; // center of start bit
                            state  <= START;
                        end
                    end

                    START: begin
                        if (os_cnt == 0) begin
                            if (rx_sync == 0) begin
                                os_cnt  <= OVERSAMPLE-1;
                                bit_cnt <= 0;
                                state   <= DATA;
                            end else
                                state <= IDLE;
                        end else
                            os_cnt <= os_cnt - 1;
                    end

                    DATA: begin
                        if (os_cnt == 0) begin
                            shift <= {rx_sync, shift[7:1]}; // LSB first
                            os_cnt <= OVERSAMPLE-1;
                            if (bit_cnt == 3'd7)
                                state <= STOP;
                            else
                                bit_cnt <= bit_cnt + 1;
                        end else
                            os_cnt <= os_cnt - 1;
                    end

                    STOP: begin
                        if (os_cnt == 0) begin
                            if (rx_sync == 1) begin
                                rx_data  <= shift;
                                rx_valid <= 1;
                            end
                            state <= IDLE;
                        end else
                            os_cnt <= os_cnt - 1;
                    end
                endcase
            end
        end
    end

    // -------------------------------------------------
    // 6-byte instruction assembly (unchanged behavior)
    // -------------------------------------------------
    reg [47:0] data_48;
    reg [2:0]  byte_cnt;
    reg        instr_valid;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_48     <= 0;
            byte_cnt    <= 0;
            instr_valid <= 0;
        end else begin
            instr_valid <= 0;

            if (rx_valid) begin
                data_48 <= {data_48[39:0], rx_data};
                if (byte_cnt == 3'd5) begin
                    instr_valid <= 1;
                    byte_cnt    <= 0;
                end else
                    byte_cnt <= byte_cnt + 1;
            end
        end
    end

    // -------------------------------------------------
    // Output registers
    // -------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            load_addr <= 0;
            load_data <= 0;
        end else if (instr_valid) begin
            load_addr <= data_48[47:36];
            load_data <= data_48[31:0];
        end
    end

endmodule
