`timescale 1ns / 100ps

module TB_MAC #(
    parameter IFMAP_BITWIDTH = 16,
    parameter W_BITWIDTH     = 8,
    parameter OFMAP_BITWIDTH = 32,
    parameter NUM_TEST       = 16
);
    logic clk; // Clock signal
    logic rstn; // Reset Negative signal
    logic w_prefetch_in;
    logic w_enable_in;
    logic ifmap_start_in;
    logic ifmap_enable_in;
    logic MAC_valid_in;
    logic signed [W_BITWIDTH-1:0] w_data_in; // input weight data
    logic signed [IFMAP_BITWIDTH-1:0] ifmap_data_in; // input feature map data
    logic signed [OFMAP_BITWIDTH-1:0] MAC_data_in; // input previous MAC result
    logic ifmap_enable_out;
    logic MAC_valid_out;
    logic signed [W_BITWIDTH-1:0] w_data_out; // output weight data
    logic signed [IFMAP_BITWIDTH-1:0] ifmap_data_out; // output feature map data
    logic signed [OFMAP_BITWIDTH-1:0] MAC_data_out; // MAC result output

    integer i;
    integer cycle;
    integer idx;
    integer MAC_idx;

    MAC MAC1(
        .clk (clk),
        .rstn (rstn),
        .w_prefetch_in (w_prefetch_in),
        .w_enable_in (w_enable_in),
        .ifmap_start_in (ifmap_start_in),
        .ifmap_enable_in (ifmap_enable_in),
        .MAC_valid_in (MAC_valid_in),
        .w_data_in (w_data_in),
        .ifmap_data_in (ifmap_data_in),
        .MAC_data_in (MAC_data_in),
        .ifmap_enable_out (ifmap_enable_out),
        .MAC_valid_out (MAC_valid_out),
        .w_data_out (w_data_out),
        .ifmap_data_out (ifmap_data_out),
        .MAC_data_out (MAC_data_out)
    );

    /**************CLOCK & RESET Negative GENERATION**************/
    logic clock_q = 1'b0;
    logic reset_n_q = 1'b0;

    initial
        begin
        w_prefetch_in <= 1'b0;
        w_enable_in <= 1'b0;
        ifmap_start_in <= 1'b0;
        ifmap_enable_in <= 1'b0;
        #5 clock_q <= 1'b1;
        #101 reset_n_q <= 1'b1;
        /***WEGITH CONTROL TEST***/
        @(posedge clk);
        w_prefetch_in <= 1'b1;
        ifmap_start_in <= 1'b1;
        @(posedge clk);
        w_prefetch_in <= 1'b0;
        ifmap_start_in <= 1'b0;
        w_enable_in <= 1'b1;
        ifmap_enable_in <= 1'b1;
        #75
        @(posedge clk);
        w_enable_in <= 1'b0;
        ifmap_enable_in <= 1'b0;
        #18 reset_n_q <= 1'b0;
        #10 reset_n_q <= 1'b1;
        /***WEGITH CONTROL TEST***/
        end

    always @(clock_q)
        #5 clock_q <= ~clock_q;

    assign clk = clock_q;
    assign rstn = reset_n_q;
    /**************CLOCK & RESET Negative GENERATION**************/

    /**************TEST DATA GENERATION**************/
    logic signed [W_BITWIDTH-1:0] TEST_W_IN [NUM_TEST-1:0];
    logic signed [IFMAP_BITWIDTH-1:0] TEST_IFMAP_IN [NUM_TEST-1:0];
    logic signed [OFMAP_BITWIDTH-1:0] TEST_MAC_IN [NUM_TEST-1:0];
    logic signed [W_BITWIDTH-1:0] ANS_W_OUT [NUM_TEST-1:0];
    logic signed [IFMAP_BITWIDTH-1:0] ANS_IFMAP_OUT [NUM_TEST-1:0];
    logic signed [OFMAP_BITWIDTH-1:0] ANS_MAC_OUT [NUM_TEST-1:0];

    /**************INPUT WIRE ASSIGNMENT**************/
    assign w_data_in = TEST_W_IN[idx];
    assign ifmap_data_in = TEST_IFMAP_IN[idx];
    assign MAC_data_in = (cycle == -1) ? TEST_MAC_IN[0]:MAC_data_out;
    assign MAC_valid_in = ifmap_enable_out;
    /**************INPUT WIRE ASSIGNMENT**************/

    initial begin
        idx = 0;
        cycle = -1;
        TEST_W_IN[0] = 8'h80;   TEST_IFMAP_IN[0] = 1;   TEST_MAC_IN[0] = 0; TEST_MAC_IN[1] = 0;
        for (i = 0; i <= NUM_TEST; i = i + 1) begin
            if (i < NUM_TEST - 1) begin
                TEST_W_IN[i+1] = TEST_W_IN[i] + 23;
                TEST_IFMAP_IN[i+1] = TEST_IFMAP_IN[i]*(-2);
                if (i != 0) TEST_MAC_IN[i+1] = TEST_W_IN[i] * TEST_IFMAP_IN[i] + TEST_MAC_IN[i];
            end
            ANS_W_OUT[i] = TEST_W_IN[i-1];
            ANS_IFMAP_OUT[i] = TEST_IFMAP_IN[i-1];
            ANS_MAC_OUT[i] = TEST_W_IN[i-1]*TEST_IFMAP_IN[i-1]+TEST_MAC_IN[i-1];
        end
    end
    /**************TEST DATA GENERATION**************/

    /**************TEST**************/
    always @(*) begin
        if (cycle == -1) begin
            MAC_idx = 0;
        end else begin
            MAC_idx = cycle;
        end
    end

    always @(posedge clk ) begin           
        if (rstn != 0) begin
            idx = cycle + 1;            
        end
    end

    always @(posedge clk ) begin
        if (rstn == 0) begin
            #1
            if(w_data_out == 0 && ifmap_data_out == 0 && MAC_data_out == 0) begin
                $display("RESET TEST PASSED");
            end
            else begin
                $display("RESET TEST FAILED!");
                //$finish();
            end
        end else begin
            cycle = cycle + 1;
            if (cycle == NUM_TEST) begin
                $display("ALL TEST PASSED!");
                $finish();
            end
            #1
            if (cycle == 0) begin
                if(w_data_out == ANS_W_OUT[cycle] && ifmap_data_out == ANS_IFMAP_OUT[cycle] && MAC_data_out == 0) begin
                    $display("TEST %1d PASSED",cycle);
                end
                else begin
                    $display("TEST %1d FAILED!",cycle);
                    $display("ANS_W_OUT=%1d(%1d)\tANS_IFMAP_OUT=%1d(%1d)\tANS_MAC_OUT=%1d(%1d)",ANS_W_OUT[cycle],w_data_out,ANS_IFMAP_OUT[cycle],ifmap_data_out,0,MAC_data_out);
                    //$finish();
                end
            end else begin
                if(w_data_out == ANS_W_OUT[cycle] && ifmap_data_out == ANS_IFMAP_OUT[cycle] && MAC_data_out == ANS_MAC_OUT[cycle-1]) begin
                    $display("TEST %1d PASSED",cycle);
                end
                else begin
                    $display("TEST %1d FAILED!",cycle);
                    $display("ANS_W_OUT=%1d(%1d)\tANS_IFMAP_OUT=%1d(%1d)\tANS_MAC_OUT=%1d(%1d)",ANS_W_OUT[cycle],w_data_out,ANS_IFMAP_OUT[cycle],ifmap_data_out,ANS_MAC_OUT[cycle-1],MAC_data_out);
                    //$finish();
                end
            end
        end
    end
    /**************TEST**************/

endmodule