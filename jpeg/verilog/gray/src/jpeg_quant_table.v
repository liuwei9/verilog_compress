module jpeg_quant_table #(
    parameter QUANT_LUM_PATH = ""  ,
    parameter DIV_LUM_PATH   = ""  
) (
    input         clk            ,
    input         jpeg_start     ,

    input         quant_lum_ren  ,
    input  [12:0] quant_lum_raddr,
    output [7:0]  quant_lum_rdata,

    input         div_lum_ren    ,
    input  [12:0] div_lum_raddr  ,
    output [17:0] div_lum_rdata  
    
);
reg [ 7:0] quantLumMatrixMem [6399:0];
reg [17:0] divLumMatrixMem   [6399:0];

initial begin
    $readmemh(QUANT_LUM_PATH, quantLumMatrixMem);
    $readmemh(DIV_LUM_PATH,   divLumMatrixMem  );
end

reg [7:0] quant_lum_rdata_t0;
reg [7:0] quant_lum_rdata_t1;

reg [17:0] div_lum_rdata_t0;
reg [17:0] div_lum_rdata_t1;
always @(posedge clk ) begin
    if(quant_lum_ren)begin
        quant_lum_rdata_t0 <= quantLumMatrixMem[quant_lum_raddr];
    end
end

always @(posedge clk ) begin
    quant_lum_rdata_t1 <= quant_lum_rdata_t0;
end

always @(posedge clk ) begin
    if(quant_lum_ren)begin
        div_lum_rdata_t0 <= divLumMatrixMem[div_lum_raddr];
    end
end

always @(posedge clk ) begin
    div_lum_rdata_t1 <= div_lum_rdata_t0;
end

endmodule