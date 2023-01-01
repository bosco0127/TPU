module Adder_32bit (
    input wire [31:0] A,
    input wire [31:0] B,
    input wire Cin,

    output wire [31:0] S,
    output wire Cout
);

    wire CarryOut;

    Adder_16bit ADD0 (
        .A (A[15:0]),
        .B (B[15:0]),
        .Cin (Cin),
        .S (S[15:0]),
        .Cout (CarryOut)
    );

    Adder_16bit ADD1 (
        .A (A[31:16]),
        .B (B[31:16]),
        .Cin (CarryOut),
        .S (S[31:16]),
        .Cout (Cout)
    );

endmodule