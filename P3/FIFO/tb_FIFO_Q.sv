`timescale 1ns / 1ps

module TB_FIFO_Q #(
    parameter DATA_WIDTH                = 32,
    parameter FIFO_DEPTH                = 16,
    parameter TEST_NUM                  = 10
);
    logic                         clk;
    logic                         rstn;
    logic                         enable_in;         // Input enable signal
    logic  [DATA_WIDTH-1:0]       data_in;          // Input data
    logic                         enable_out;         // Input enable signal
    logic  [DATA_WIDTH-1:0]       data_out;          // Output data

    FIFO_Q #(
        .DATA_WIDTH (DATA_WIDTH),
        .FIFO_DEPTH (FIFO_DEPTH)
    ) FIFO (
        .clk (clk),
        .rstn (rstn),
        .enable_in (enable_in), 
        .data_in (data_in),   
        .enable_out (enable_out),
        .data_out (data_out)  
    );

    /**************TEST DATA GENERATION**************/
    logic [DATA_WIDTH-1:0] TEST_DATA [TEST_NUM-1:0];
    int idx;
    int num_in = 0;
    int num_out = 0;
    int correct = 0;

    initial begin
        for (idx = 0; idx < TEST_NUM; idx++) begin
            TEST_DATA[idx] = idx;
        end
    end

    /**************CLOCK & RESET Negative GENERATION**************/
    logic clock_q = 1'b0;
    logic reset_n_q = 1'b0;

    initial begin
        enable_in <= 1'b0;
        data_in <= 'd0;
        #5 clock_q <= 1'b1;
        #101 reset_n_q <= 1'b1;
        /***TEST START***/
        repeat (TEST_NUM) begin
            @(posedge clk);
            enable_in <= 1'b1;
            data_in <= TEST_DATA[num_in];
            @(posedge clk);
            enable_in <= 1'b0;
            data_in <= TEST_DATA[num_in++];
        end
        @(posedge clk);
        #(FIFO_DEPTH*10)
        if (correct == TEST_NUM) begin
            $display("SUCCESS!");
        end else begin
            $display("Errors: %d",TEST_NUM-correct);
        end
        /***TEST END***/
        $finish();
    end

    always @(clock_q)
        #5 clock_q <= ~clock_q;

    assign clk = clock_q;
    assign rstn = reset_n_q;
    /**************CLOCK & RESET Negative GENERATION**************/

    /**************EVALUATION**************/
    always @(posedge enable_out) begin
        if (data_out == TEST_DATA[num_out]) begin
            correct++;
        end else begin
            $display("Error @ %1d",num_out);
        end
        num_out++;
    end
endmodule