module FullAdder(A,B,Cin,S,Cout);

	input  logic A;
	input  logic B;
	input  logic Cin;
	output logic S;
	output logic Cout;

	//TODO
	logic X;
	logic Y;
	logic Z;
	assign X = A ^ B; // X = A ^ B
	assign Y = X & Cin; // Y = (A ^ B)Cin
	assign Z = A & B; // Z = AB
	assign S = X ^ Cin; // S = A ^ B ^ Cin
	assign Cout = Y | Z; // Cout = (A ^ B)Cin + AB
	
endmodule
