module RWRam
#(
    parameter BIT_WIDTH                     = 32,
    parameter RAM_WIDTH                     = 4,
    parameter RAM_ADDR_BITS                 = 10,
    parameter INIT_FILE_NAME                = ""
)
(
    input  logic                                clock,
    input  logic [BIT_WIDTH*RAM_WIDTH-1:0]      data,
    input  logic [RAM_ADDR_BITS-1:0]            rdaddress,
    input  logic [RAM_ADDR_BITS-1:0]            wraddress,
    input  logic                                wren,
    output logic [BIT_WIDTH*RAM_WIDTH-1:0]      q
);

    logic [BIT_WIDTH*RAM_WIDTH-1:0]             mem[(2**RAM_ADDR_BITS)-1:0];
    
    initial begin
        if (INIT_FILE_NAME != "") begin
            $readmemh(INIT_FILE_NAME, mem);
        end
    end

    // Asynchronous Read
    assign q = mem[rdaddress];

    // Synchronous Write
    always @(posedge clock) begin
        if(wren) begin
            mem[wraddress]                    <= data;
        end
    end

endmodule