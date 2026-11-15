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

wire [63:0] in_buf_m_data      ;
wire        in_buf_m_data_valid;
wire        in_buf_m_data_last ;
wire [1:0]  in_buf_m_data_user ;

wire [10:0] dct_m_data      ;
wire        dct_m_data_valid;
wire        dct_m_data_last ;
wire [1:0]  dct_m_data_user ;

jpeg_in_buf_top #(
    .IMG_H (MAX_IMG_H),
    .IMG_W (MAX_IMG_W)
) jpeg_in_buf_top_inst (
    .clk              (clk              ),
    .rst              (rst              ),

    .cfg_img_h        (cfg_img_h        ),
    .cfg_img_w        (cfg_img_w        ),
    .jpeg_start       (jpeg_start       ),

    .s_data           (s_data           ),
    .s_data_valid     (s_data_valid     ),
    .s_data_last      (s_data_last      ),
    .s_data_ready     (s_data_ready     ),

    .m_data           (in_buf_m_data      ),
    .m_data_valid     (in_buf_m_data_valid),
    .m_data_last      (in_buf_m_data_last ),
    .m_data_user      (in_buf_m_data_user )
);

jpeg_dct jpeg_dct_inst(
    .clk          (clk          ),
    .rst          (rst          ),

    .s_data       (in_buf_m_data      ),
    .s_data_valid (in_buf_m_data_valid),
    .s_data_last  (in_buf_m_data_last ),
    .s_data_user  (in_buf_m_data_user ),

    .m_data       (dct_m_data         ),
    .m_data_valid (dct_m_data_valid   ),
    .m_data_last  (dct_m_data_last    ),
    .m_data_user  (dct_m_data_user    )
);


endmodule