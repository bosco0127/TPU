module Counter (
    input logic clk,
    input logic rstn,

    input logic enable,
    input logic [31:0] MAX,

    output logic [31:0] Count,
    output logic isMAX,
    output logic isNext
);
    logic [31:0] Count_1;
    logic [31:0] Enable_out;
    logic [31:0] Reset_out;

    // Variable
    always_ff @(posedge clk ) begin : Counter
        Count <= Reset_out;
    end

    // Plus 1 Adder
    always_comb begin : One_Adder
        Count_1 = Count + 1;
    end

    // Enable Mux
    always_comb begin : Enable_MUX
        if (enable) begin
            Enable_out = Count_1;
        end else begin
            Enable_out = Count;
        end
    end

    // Reset Mux
    always_comb begin : Reset_MUX
        if (~(isMAX & enable) & rstn) begin
            Reset_out = Enable_out;
        end else begin
            Reset_out = 0;
        end
    end

    // Comparator
    always_comb begin : Comparator
        if (Count == MAX - 1) begin
            isMAX = 1'b1;
        end else begin
            isMAX = 1'b0;
        end
    end

    // isNext Register
    always_ff @(posedge clk ) begin : isMAX_Reg
        isNext <= isMAX;
    end

endmodule