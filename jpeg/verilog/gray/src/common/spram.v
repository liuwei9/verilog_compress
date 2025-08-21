module spram #(
    parameter DP = 1024,
    parameter DW = 8   ,
    parameter PIPE = 2  
) (
    input                             clk  ,
    input        [DW - 1 : 0]         wdata,
    input                             wen  ,
    input        [$clog2(DP) - 1 : 0] waddr,
    input                             ren  ,
    input        [$clog2(DP) - 1 : 0] raddr,
    output reg   [DW - 1 : 0]         rdata
);

reg [DW - 1:0] mem [DP - 1 : 0];
always @(posedge clk ) begin
    if(wen)begin
        mem[waddr] <= wdata;
    end
end

generate
    if(PIPE == 2)begin
        reg [DW - 1:0] rdata_temp;
        always @(posedge clk ) begin
            if(ren)begin
                rdata_temp <= mem[raddr];
            end
        end
        
        always @(posedge clk ) begin
            rdata <= rdata_temp;
        end
    end
    else begin
        always @(posedge clk ) begin
            if(ren)begin
                rdata <= mem[raddr];
            end
        end
    end
endgenerate

    
endmodule