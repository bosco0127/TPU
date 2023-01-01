module FullAdder(A,B,Cin,S,Cout);

	input wire A;
	input wire B;
	input wire Cin;
	output wire S;
	output wire Cout;

	//TODO
	wire X;
	wire Y;
	wire Z;
	assign X = A ^ B; // X = A ^ B
	assign Y = X & Cin; // Y = (A ^ B)Cin
	assign Z = A & B; // Z = AB
	assign S = X ^ Cin; // S = A ^ B ^ Cin
	assign Cout = Y | Z; // Cout = (A ^ B)Cin + AB
	
endmodule
