module Adder_8bit (
    input logic [7:0] A,
    input logic [7:0] B,
    input logic Cin,

    output logic [7:0] S,
    output logic Cout
);

    // Variable
    logic CarryOut [6:0];

    // logic Assignment
    FullAdder FullAdder0 (
        .A (A[0]),
        .B (B[0]),
        .Cin (Cin),
        .S (S[0]),
        .Cout (CarryOut[0])
    );

    FullAdder FullAdder1 (
        .A (A[1]),
        .B (B[1]),
        .Cin (CarryOut[0]),
        .S (S[1]),
        .Cout (CarryOut[1])
    );

    FullAdder FullAdder2 (
        .A (A[2]),
        .B (B[2]),
        .Cin (CarryOut[1]),
        .S (S[2]),
        .Cout (CarryOut[2])
    );

    FullAdder FullAdder3 (
        .A (A[3]),
        .B (B[3]),
        .Cin (CarryOut[2]),
        .S (S[3]),
        .Cout (CarryOut[3])
    );

    FullAdder FullAdder4 (
        .A (A[4]),
        .B (B[4]),
        .Cin (CarryOut[3]),
        .S (S[4]),
        .Cout (CarryOut[4])
    );

    FullAdder FullAdder5 (
        .A (A[5]),
        .B (B[5]),
        .Cin (CarryOut[4]),
        .S (S[5]),
        .Cout (CarryOut[5])
    );

    FullAdder FullAdder6 (
        .A (A[6]),
        .B (B[6]),
        .Cin (CarryOut[5]),
        .S (S[6]),
        .Cout (CarryOut[6])
    );

    FullAdder FullAdder7 (
        .A (A[7]),
        .B (B[7]),
        .Cin (CarryOut[6]),
        .S (S[7]),
        .Cout (Cout)
    );

endmodule