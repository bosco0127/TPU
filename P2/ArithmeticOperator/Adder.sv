module Adder
#(
    parameter OPERAND_BIT = 10
)
(
    input  logic [OPERAND_BIT-1:0] A,
    input  logic [OPERAND_BIT-1:0] B,
    input  logic                   Cin,

    output logic [OPERAND_BIT-1:0] S,
    output logic                   Cout
);

    // Wire
    logic [OPERAND_BIT-1:0] CarryOut;

    // Generate Value
    genvar idx;

    // Wire Assignment
    assign Cout = CarryOut[OPERAND_BIT-1];

    generate
        for (idx = 0; idx < OPERAND_BIT; idx = idx + 1) begin : FullAdder_Chain_gen
            if (idx) begin
                FullAdder FA(
                    .A (A[idx]),
                    .B (B[idx]),
                    .Cin (CarryOut[idx-1]),
                    .S (S[idx]),
                    .Cout (CarryOut[idx])
                );
            end else begin
                FullAdder FA0(
                    .A (A[idx]),
                    .B (B[idx]),
                    .Cin (Cin),
                    .S (S[idx]),
                    .Cout (CarryOut[idx])
                );
            end
        end
    endgenerate

endmodule