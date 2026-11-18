module jpeg_top #(
    parameter MAX_IMG_H      = 1080,
    parameter MAX_IMG_W      = 1920,
    parameter QUANT_LUM_PATH = "divLumMatrix.mem",
    parameter DIV_LUM_PATH   = "quantLumMatrix.mem" ,
    parameter QUANT_CHROM_PATH = "divChromMatrix.mem",
    parameter DIV_CHROM_PATH   = "quantChromMatrix.mem" 
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

wire [7:0]  jpeg_head_data      ;
wire        jpeg_head_data_valid;
wire        jpeg_head_data_last ;

wire [63:0] in_buf_m_data      ;
wire        in_buf_m_data_valid;
wire        in_buf_m_data_last ;
wire [1:0]  in_buf_m_data_user ;

wire [10:0] dct_m_data      ;
wire        dct_m_data_valid;
wire        dct_m_data_last ;
wire [1:0]  dct_m_data_user ;

wire        quant_lum_ren    ;
wire [12:0] quant_lum_raddr  ;
wire [7:0]  quant_lum_rdata  ;

wire        div_lum_ren      ;
wire [12:0] div_lum_raddr    ;
wire [17:0] div_lum_rdata    ;

wire        quant_chrom_ren  ;
wire [12:0] quant_chrom_raddr;
wire [7:0]  quant_chrom_rdata;

wire        div_chrom_ren    ;
wire [12:0] div_chrom_raddr  ;
wire [17:0] div_chrom_rdata  ;

wire [11:0] quant_m_data      ;
wire [6:0]  quant_m_zero_cnt  ;
wire        quant_m_data_valid;
wire        quant_m_data_last ;
wire [1:0]  quant_m_data_user ;

jpeg_head_yuv444 jpeg_head_yuv444_inst(
    .clk                  (clk                 ),
    .rst                  (rst                 ),

    .cfg_img_h            (cfg_img_h           ),
    .cfg_img_w            (cfg_img_w           ),
    .cfg_quality          (cfg_quality         ), 
    .jpeg_start           (jpeg_start          ),

    .quant_lum_ren        (quant_lum_ren       ),
    .quant_lum_raddr      (quant_lum_raddr     ),
    .quant_lum_rdata      (quant_lum_rdata     ),
    .quant_chrom_ren      (quant_chrom_ren     ),
    .quant_chrom_raddr    (quant_chrom_raddr   ),
    .quant_chrom_rdata    (quant_chrom_rdata   ),

    .jpeg_head_data       (jpeg_head_data      ),
    .jpeg_head_data_valid (jpeg_head_data_valid),
    .jpeg_head_data_last  (jpeg_head_data_last ) 
);

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

jpeg_quant_table #(
    .QUANT_LUM_PATH   (QUANT_LUM_PATH  ),
    .DIV_LUM_PATH     (DIV_LUM_PATH    ),
    .QUANT_CHROM_PATH (QUANT_CHROM_PATH),
    .DIV_CHROM_PATH   (DIV_CHROM_PATH  )
) jpeg_quant_table_inst (
    .clk                (clk                ),
    .jpeg_start         (jpeg_start         ),

    .quant_lum_ren      (quant_lum_ren      ),
    .quant_lum_raddr    (quant_lum_raddr    ),
    .quant_lum_rdata    (quant_lum_rdata    ),

    .div_lum_ren        (div_lum_ren        ),
    .div_lum_raddr      (div_lum_raddr      ),
    .div_lum_rdata      (div_lum_rdata      ),

    .quant_chrom_ren    (quant_chrom_ren    ),
    .quant_chrom_raddr  (quant_chrom_raddr  ),
    .quant_chrom_rdata  (quant_chrom_rdata  ),

    .div_chrom_ren      (div_chrom_ren      ),
    .div_chrom_raddr    (div_chrom_raddr    ),
    .div_chrom_rdata    (div_chrom_rdata    )
    
);

jpeg_quant jpeg_quant_inst(
    .clk              (clk              ),
    .rst              (rst              ),

    .cfg_quality      (cfg_quality      ), 
    .jpeg_start       (jpeg_start       ),

    .s_data           (dct_m_data       ),
    .s_data_valid     (dct_m_data_valid ),
    .s_data_last      (dct_m_data_last  ),
    .s_data_user      (dct_m_data_user  ),

    .div_lum_ren      (div_lum_ren      ),
    .div_lum_raddr    (div_lum_raddr    ),
    .div_lum_rdata    (div_lum_rdata    ),
    .div_chrom_ren    (div_chrom_ren    ),
    .div_chrom_raddr  (div_chrom_raddr  ),
    .div_chrom_rdata  (div_chrom_rdata  ),

    .m_data           (quant_m_data      ),
    .m_zero_cnt       (quant_m_zero_cnt  ),
    .m_data_valid     (quant_m_data_valid),
    .m_data_last      (quant_m_data_last ),
    .m_data_user      (quant_m_data_user ) 
);


endmodule