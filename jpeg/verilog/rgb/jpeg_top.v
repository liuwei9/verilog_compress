module jpeg_top #(
    parameter MAX_IMG_H      = 1080,
    parameter MAX_IMG_W      = 1920,
    parameter QUANT_LUM_PATH = "divLumMatrix.mem",
    parameter DIV_LUM_PATH   = "quantLumMatrix.mem"  
) (
    input          clk              ,
    input          rst              ,

    input [15:0]   cfg_img_h        ,
    input [15:0]   cfg_img_w        ,
    input [6:0]    cfg_quality      , 
    input          jpeg_start       ,

    input [31:0]   s_data           , //{0, r, g, b}
    input          s_data_valid     ,
    input          s_data_last      ,
    output         s_data_ready     ,

    output [63:0]  m_data           ,
    output [ 7:0]  m_data_keep      ,
    output         m_data_valid     ,
    output         m_data_last      
);

endmodule