// Combine 4 x o_mem to ofmap_mem
`include "RWRam.sv"

module ofmap_mem
(
   input  logic                                clock,
   input  logic [511:0]                        data,
   input  logic [9:0]                          rdaddress,
   input  logic [9:0]                          wraddress,
   input  logic                                wren,
   output logic [511:0]                        q
);

    logic [3:0][127:0]                          o_data;
    logic [3:0][127:0]                          o_q;

    always_comb begin
        o_data                                  = data;
        q                                       = o_q;
    end

    RWRam ofmap_mem0
    (
        .clock                                  (clock),            
        .data                                   (o_data[0]),            
        .rdaddress                              (rdaddress),                
        .wraddress                              (wraddress),                
        .wren                                   (wren),            
        .q                                      (o_q[0])        
    );

    RWRam ofmap_mem1
    (
        .clock                                  (clock),            
        .data                                   (o_data[1]),            
        .rdaddress                              (rdaddress),                
        .wraddress                              (wraddress),                
        .wren                                   (wren),            
        .q                                      (o_q[1])        
    );

    RWRam ofmap_mem2
    (
        .clock                                  (clock),            
        .data                                   (o_data[2]),            
        .rdaddress                              (rdaddress),                
        .wraddress                              (wraddress),                
        .wren                                   (wren),            
        .q                                      (o_q[2])        
    );

    RWRam ofmap_mem3
    (
        .clock                                  (clock),            
        .data                                   (o_data[3]),            
        .rdaddress                              (rdaddress),                
        .wraddress                              (wraddress),                
        .wren                                   (wren),            
        .q                                      (o_q[3])        
    );

endmodule