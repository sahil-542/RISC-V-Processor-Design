module comparator(
    input  [31:0] a,
    input  [31:0] b,
    output        a_eq_b,
    output        a_gt_b,
    output        a_lt_b
);

wire [31:0] eq;
wire [31:0] gt;
wire [31:0] lt;
wire [32:0] prefix_eq;

genvar i;

/* Bit-wise equality using XNOR */
generate
    for (i = 0; i < 32; i = i + 1) begin : EQ_BITS
        xnor (eq[i], a[i], b[i]);
    end
endgenerate

/* Overall equality */
and (a_eq_b,
     eq[0], eq[1], eq[2], eq[3], eq[4], eq[5], eq[6], eq[7],
     eq[8], eq[9], eq[10], eq[11], eq[12], eq[13], eq[14], eq[15],
     eq[16], eq[17], eq[18], eq[19], eq[20], eq[21], eq[22], eq[23],
     eq[24], eq[25], eq[26], eq[27], eq[28], eq[29], eq[30], eq[31]);

/* Prefix equality chain (MSB first) */
assign prefix_eq[32] = 1'b1;

generate
    for (i = 31; i >= 0; i = i - 1) begin : PREFIX_EQ
        and (prefix_eq[i], prefix_eq[i+1], eq[i]);
    end
endgenerate

/* Greater-than and less-than bit logic */
generate
    for (i = 0; i < 32; i = i + 1) begin : COMP_BITS
        and (gt[i], prefix_eq[i+1], a[i], ~b[i]);
        and (lt[i], prefix_eq[i+1], ~a[i], b[i]);
    end
endgenerate

/* Final GT and LT outputs */
or (a_gt_b,
    gt[0], gt[1], gt[2], gt[3], gt[4], gt[5], gt[6], gt[7],
    gt[8], gt[9], gt[10], gt[11], gt[12], gt[13], gt[14], gt[15],
    gt[16], gt[17], gt[18], gt[19], gt[20], gt[21], gt[22], gt[23],
    gt[24], gt[25], gt[26], gt[27], gt[28], gt[29], gt[30], gt[31]);

or (a_lt_b,
    lt[0], lt[1], lt[2], lt[3], lt[4], lt[5], lt[6], lt[7],
    lt[8], lt[9], lt[10], lt[11], lt[12], lt[13], lt[14], lt[15],
    lt[16], lt[17], lt[18], lt[19], lt[20], lt[21], lt[22], lt[23],
    lt[24], lt[25], lt[26], lt[27], lt[28], lt[29], lt[30], lt[31]);

endmodule
