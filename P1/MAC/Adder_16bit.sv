module Adder_16bit (
    input logic [15:0] A,
    input logic [15:0] B,
    input logic Cin,

    output logic [15:0] S,
    output logic Cout
);

    logic CarryOut;

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