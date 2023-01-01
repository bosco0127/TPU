module Adder_16bit (
    input wire [15:0] A,
    input wire [15:0] B,
    input wire Cin,

    output wire [15:0] S,
    output wire Cout
);

    wire CarryOut;

    Adder_8bit ADD0 (
        .A (A[7:0]),
        .B (B[7:0]),
        .Cin (Cin),
        .S (S[7:0]),
        .Cout (CarryOut)
    );

    Adder_8bit ADD1 (
        .A (A[15:8]),
        .B (B[15:8]),
        .Cin (CarryOut),
        .S (S[15:8]),
        .Cout (Cout)
    );

endmodule