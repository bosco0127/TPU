/////////////////////////////////////////////////////////////////////
//
// Title: tb_MemoryController.sv
//
/////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

module tb_MemoryController;

    // size parameter
    localparam MAC_ROW                              = 16;
    localparam MAC_COL                              = 16;
    localparam W_BITWIDTH                           = 8;
    localparam IFMAP_BITWIDTH                       = 16;
    localparam OFMAP_BITWIDTH                       = 32;
    localparam W_ADDR_BIT                           = 11;
    localparam IFMAP_ADDR_BIT                       = 9;
    localparam OFMAP_ADDR_BIT                       = 10;
    // configuration parameter
    localparam OFMAP_CHANNEL_NUM                    = 64;
    localparam IFMAP_CHANNEL_NUM                    = 32;
    localparam WEIGHT_WIDTH                         = 3;
    localparam WEIGHT_HEIGHT                        = 3;
    localparam IFMAP_WIDTH                          = 16;
    localparam IFMAP_HEIGHT                         = 16;
    localparam OFMAP_WIDTH                          = 14;
    localparam OFMAP_HEIGHT                         = 14;
    // number parameter
    localparam WEIGHT_DATA_NUM                      = (OFMAP_CHANNEL_NUM*IFMAP_CHANNEL_NUM*WEIGHT_WIDTH*WEIGHT_HEIGHT)/MAC_COL;
    localparam IFMAP_REF_DATA_NUM                   = (IFMAP_CHANNEL_NUM*WEIGHT_WIDTH*WEIGHT_HEIGHT*OFMAP_WIDTH*OFMAP_HEIGHT*(OFMAP_CHANNEL_NUM/MAC_COL)/MAC_ROW);
    localparam OFMAP_DATA_NUM                       = (OFMAP_CHANNEL_NUM*OFMAP_WIDTH*OFMAP_HEIGHT)/MAC_COL;

    int                                             weight_error;
    int                                             ifmap_error;
    int                                             ofmap_error;


    const time CLK_PERIOD                           = 10ns;
    const time CLK_HALF_PERIOD                      = CLK_PERIOD / 2;
    const int  RESET_WAIT_CYCLES                    = 10;

    logic                                           clk;
    logic                                           rstn;

    logic                                           start;

    logic                                           ofmap_ready;

    logic                                           w_prefetch;
    logic [W_ADDR_BIT-1:0]                          w_addr;
    logic                                           w_read_en;

    logic                                           ifmap_start;
    logic [IFMAP_ADDR_BIT-1:0]                      ifmap_addr;
    logic                                           ifmap_read_en;

    logic                                           mac_done;

    logic [OFMAP_ADDR_BIT-1:0]                      ofmap_addr;
    logic                                           ofmap_write_en;
    logic                                           ofmap_write_done;

    logic                                           w_valid;
    logic [W_BITWIDTH*MAC_COL-1:0]                  w_data;
    logic [W_BITWIDTH*MAC_COL-1:0]                  w_data_ref_init[WEIGHT_DATA_NUM-1:0];
    logic [W_BITWIDTH*MAC_COL-1:0]                  w_data_ref;
    logic [$clog2(WEIGHT_DATA_NUM)-1:0]             w_data_ref_cnt;

    logic                                           ifmap_valid;
    logic [IFMAP_BITWIDTH*MAC_ROW-1:0]              ifmap_data;
    logic [IFMAP_BITWIDTH*MAC_ROW-1:0]              ifmap_data_ref_init[IFMAP_REF_DATA_NUM-1:0];
    logic [IFMAP_BITWIDTH*MAC_ROW-1:0]              ifmap_data_ref;
    logic [$clog2(IFMAP_REF_DATA_NUM)-1:0]          ifmap_data_ref_cnt;

    logic [OFMAP_BITWIDTH*MAC_COL-1:0]              ofmap_data_init[OFMAP_DATA_NUM-1:0];
    logic [OFMAP_BITWIDTH*MAC_COL-1:0]              ofmap_data;
    logic [OFMAP_BITWIDTH*MAC_COL-1:0]              ofmap_data_ref_init[OFMAP_DATA_NUM-1:0];
    logic [OFMAP_BITWIDTH*MAC_COL-1:0]              ofmap_data_ref;
    logic [$clog2(OFMAP_DATA_NUM)-1:0]              ofmap_data_ref_cnt;

    initial begin
        clk                                         = 1'b0;
        fork
            forever #CLK_HALF_PERIOD clk            = ~clk;
        join
    end

    initial begin
        rstn                                        = 1'b0;
        start                                       = 1'b0;
        ofmap_ready                                 = 1'b0;
        repeat(RESET_WAIT_CYCLES) @(posedge clk);
        rstn                                        = 1'b1;
        repeat(2) @(posedge clk);
        start                                       = 1'b1;
        @(posedge clk);
        start                                       = 1'b0;
        wait(mac_done);
        @(posedge clk);
        ofmap_ready                                 = 1'b1;
        repeat((OFMAP_CHANNEL_NUM*OFMAP_WIDTH*OFMAP_HEIGHT)/MAC_COL)@(posedge clk);
        ofmap_ready                                 = 1'b0;
        @(posedge clk);

        if ((weight_error + ifmap_error + ofmap_error) == 0) begin
            $display("Sucessfully finish!!");
            $display("total error: 0");
        end
        else begin
            $display("Simulation failed...");
            $display("weight error: %d", weight_error);
            $display("ifmap error: %d", ifmap_error);
            $display("ofmap error: %d", ofmap_error);
        end

        $stop;
    end

/************************************************************
    Data Read
************************************************************/
    initial begin
        $display("Loading text file.");
        $readmemh("C:\\EE495\\TPU\\P2\\data\\weight_ref.hex", w_data_ref_init);
        $readmemh("C:\\EE495\\TPU\\P2\\data\\ifmap_ref.hex", ifmap_data_ref_init);
        $readmemh("C:\\EE495\\TPU\\P2\\data\\ofmap.hex", ofmap_data_init);
        $readmemh("C:\\EE495\\TPU\\P2\\data\\ofmap_ref.hex", ofmap_data_ref_init);
    end

/************************************************************
    Error count
************************************************************/
    always @(posedge clk) begin
        if (~rstn) begin
            w_valid                                     <= '0;
            w_data_ref_cnt                              <= '0;
        end
        else begin
            w_valid                                     <= w_read_en;
            if (w_valid) begin
                w_data_ref_cnt                          <= w_data_ref_cnt + 'd1;
            end
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            ifmap_valid                                 <= '0;
            ifmap_data_ref_cnt                          <= '0;
        end
        else begin
            ifmap_valid                                 <= ifmap_read_en;
            if (ifmap_valid) begin
                ifmap_data_ref_cnt                      <= ifmap_data_ref_cnt + 'd1;
            end
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            ofmap_data_ref_cnt                          <= '0;
        end
        else begin
            if (ofmap_write_en) begin
                ofmap_data_ref_cnt                      <= ofmap_data_ref_cnt + 'd1;
            end
        end
    end

    assign ofmap_data                                   = ofmap_data_init[ofmap_addr];

    assign w_data_ref                                   = w_data_ref_init[w_data_ref_cnt];
    assign ifmap_data_ref                               = ifmap_data_ref_init[ifmap_data_ref_cnt];
    assign ofmap_data_ref                               = ofmap_data_ref_init[ofmap_data_ref_cnt];

    always @(posedge clk) begin
        if (w_valid) begin
            if (w_data_ref != w_data) begin
                weight_error++;
            end
        end
    end

    always @(posedge clk) begin
        if (ifmap_valid) begin
            if (ifmap_data_ref != ifmap_data) begin
                ifmap_error++;
            end
        end
    end


    always @(posedge clk) begin
        if (ofmap_write_en) begin
            if (ofmap_data_ref != ofmap_data) begin
                ofmap_error++;
            end
        end
    end

/************************************************************
    User Logic
************************************************************/
    MemoryController
    #(
        // logic parameter
        .MAC_ROW                                        (MAC_ROW          ),
        .MAC_COL                                        (MAC_COL          ),
        .W_BITWIDTH                                     (W_BITWIDTH       ),
        .IFMAP_BITWIDTH                                 (IFMAP_BITWIDTH   ),
        .OFMAP_BITWIDTH                                 (OFMAP_BITWIDTH   ),
        .W_ADDR_BIT                                     (W_ADDR_BIT       ),
        .IFMAP_ADDR_BIT                                 (IFMAP_ADDR_BIT   ),
        .OFMAP_ADDR_BIT                                 (OFMAP_ADDR_BIT   ),
        // operation parameter
        .OFMAP_CHANNEL_NUM                              (OFMAP_CHANNEL_NUM),
        .IFMAP_CHANNEL_NUM                              (IFMAP_CHANNEL_NUM),
        .WEIGHT_WIDTH                                   (WEIGHT_WIDTH     ),
        .WEIGHT_HEIGHT                                  (WEIGHT_HEIGHT    ),
        .IFMAP_WIDTH                                    (IFMAP_WIDTH      ),
        .IFMAP_HEIGHT                                   (IFMAP_HEIGHT     ),
        .OFMAP_WIDTH                                    (OFMAP_WIDTH      ),
        .OFMAP_HEIGHT                                   (OFMAP_HEIGHT     )
    )
    DUT
    (
        .clk                                            (clk),
        .rstn                                           (rstn),
        .start_in                                       (start),
        .ofmap_ready_in                                 (ofmap_ready),
        .w_prefetch_out                                 (w_prefetch),
        .w_addr_out                                     (w_addr),
        .w_read_en_out                                  (w_read_en),
        .ifmap_start_out                                (ifmap_start),
        .ifmap_addr_out                                 (ifmap_addr),
        .ifmap_read_en_out                              (ifmap_read_en),
        .mac_done_out                                   (mac_done),
        .ofmap_addr_out                                 (ofmap_addr),
        .ofmap_write_en_out                             (ofmap_write_en),
        .ofmap_write_done_out                           (ofmap_write_done)
    );

/************************************************************
    Memory
************************************************************/
    SinglePortRam
    #(
        .RAM_WIDTH                                      (W_BITWIDTH*MAC_COL),
        .RAM_ADDR_BITS                                  (W_ADDR_BIT),
        .INIT_FILE_NAME                                 ("C:\\EE495\\TPU\\P2\\data\\weight.hex")
    )
    weightRamInst
    (
        .clk                                            (clk),
        .we_in                                          (1'b0),         //only read
        .addr_in                                        (w_addr),
        .wdata_in                                       ({(W_BITWIDTH*MAC_COL){1'b0}}),
        .rdata_out                                      (w_data)
    );

    SinglePortRam
    #(
        .RAM_WIDTH                                      (IFMAP_BITWIDTH*MAC_ROW),
        .RAM_ADDR_BITS                                  (IFMAP_ADDR_BIT),
        .INIT_FILE_NAME                                 ("C:\\EE495\\TPU\\P2\\data\\ifmap.hex")
    )
    IfmapRamInst
    (
        .clk                                            (clk),
        .we_in                                          (1'b0),         //only read
        .addr_in                                        (ifmap_addr),
        .wdata_in                                       ({(IFMAP_BITWIDTH*MAC_ROW){1'b0}}),
        .rdata_out                                      (ifmap_data)
    );

    SinglePortRam
    #(
        .RAM_WIDTH                                      (OFMAP_BITWIDTH*MAC_COL),
        .RAM_ADDR_BITS                                  (OFMAP_ADDR_BIT)
    )
    OfmapRamInst
    (
        .clk                                            (clk),
        .we_in                                          (ofmap_write_en),
        .addr_in                                        (ofmap_addr),
        .wdata_in                                       (ofmap_data),
        .rdata_out                                      (/*unused*/)    // no read
    );
    
endmodule
