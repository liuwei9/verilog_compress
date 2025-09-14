module jpeg_top #(
    parameter MAX_IMG_H      = 1024,
    parameter MAX_IMG_W      = 8   ,
    parameter QUANT_LUM_PATH = ""  ,
    parameter DIV_LUM_PATH   = ""  
) (
    input          clk              ,
    input          rst              ,

    input [15:0]   cfg_img_h        ,
    input [15:0]   cfg_img_w        ,
    input [6:0]    cfg_quality      , 
    input [31:0]   cfg_img_addr     ,
    input          jpeg_start       ,

    input [63:0]   s_data           ,
    input [ 7:0]   s_data_keep      ,
    input          s_data_valid     ,
    input          s_data_last      ,
    output         s_data_ready     ,

    output [31:0]  s_cmd_addr       ,
    output [31:0]  s_cmd_len        ,
    output         s_cmd_valid      ,
    input          s_cmd_ready      
);

wire         quant_lum_ren       ;
wire [12:0]  quant_lum_raddr     ;
wire [7:0]   quant_lum_rdata     ;

wire [7:0]   jpeg_head_data      ;
wire         jpeg_head_data_valid;
wire         jpeg_head_data_last ;

wire         div_lum_ren       ;
wire [12:0]  div_lum_raddr     ;
wire [17:0]  div_lum_rdata     ;

wire [63:0] in_buf_m_data      ;
wire        in_buf_m_data_valid;
wire        in_buf_m_data_last ;
wire        in_buf_m_data_req  ;

wire [25:0] dct_m_data         ;
wire        dct_m_data_valid   ;
wire        dct_m_data_last    ;

wire [63:0] ctrl_m_data        ;
wire [ 7:0] ctrl_m_data_keep   ;
wire        ctrl_m_data_valid  ;
wire        ctrl_m_data_last   ;

jpeg_head jpeg_head_inst(
    .clk                 (clk                 ),
    .rst                 (rst                 ),

    .cfg_img_h           (cfg_img_h           ),
    .cfg_img_w           (cfg_img_w           ),
    .cfg_quality         (cfg_quality         ), 
    .cfg_img_addr        (cfg_img_addr        ),
    .jpeg_start          (jpeg_start          ),

    .quant_lum_ren       (quant_lum_ren       ),
    .quant_lum_raddr     (quant_lum_raddr     ),
    .quant_lum_rdata     (quant_lum_rdata     ),

    .jpeg_head_data      (jpeg_head_data      ),
    .jpeg_head_data_valid(jpeg_head_data_valid),
    .jpeg_head_data_last (jpeg_head_data_last ) 
);

jpeg_quant_table #(
    .QUANT_LUM_PATH (QUANT_LUM_PATH ),
    .DIV_LUM_PATH   (DIV_LUM_PATH   )  
) jpeg_quant_table_inst (
    .clk            (clk            ),
    .jpeg_start     (jpeg_start     ),

    .quant_lum_ren  (quant_lum_ren  ),
    .quant_lum_raddr(quant_lum_raddr),
    .quant_lum_rdata(quant_lum_rdata),

    .div_lum_ren    (div_lum_ren    ),
    .div_lum_raddr  (div_lum_raddr  ),
    .div_lum_rdata  (div_lum_rdata  )
    
);

jpeg_in_buf_top #(
    .IMG_H (MAX_IMG_H),
    .IMG_W (MAX_IMG_W)
) jpeg_in_buf_top_inst (
    .clk              (clk         ),
    .rst              (rst         ),

    .cfg_img_h        (cfg_img_h   ),
    .cfg_img_w        (cfg_img_w   ),
    .cfg_img_addr     (cfg_img_addr),
    .jpeg_start       (jpeg_start  ),

    .s_data           (s_data      ),
    .s_data_keep      (s_data_keep ),
    .s_data_valid     (s_data_valid),
    .s_data_last      (s_data_last ),
    .s_data_ready     (s_data_ready),

    .s_cmd_addr       (s_cmd_addr  ),
    .s_cmd_len        (s_cmd_len   ),
    .s_cmd_valid      (s_cmd_valid ),
    .s_cmd_ready      (s_cmd_ready ),

    .m_data           (in_buf_m_data      ),
    .m_data_valid     (in_buf_m_data_valid),
    .m_data_last      (in_buf_m_data_last ),
    .m_data_req       (in_buf_m_data_req  )
);

jpeg_dct jpeg_dct_inst(
    .clk              (clk              ),
    .rst              (rst              ),

    .s_data           (in_buf_m_data      ),
    .s_data_valid     (in_buf_m_data_valid),
    .s_data_last      (in_buf_m_data_last ),

    .m_data           (dct_m_data      ),
    .m_data_valid     (dct_m_data_valid),
    .m_data_last      (dct_m_data_last )
);

jpeg_ctrl jpeg_ctrl_inst(
    .clk                  (clk                 ),
    .rst                  (rst                 ),

    .jpeg_start           (jpeg_start          ),

    .jpeg_head_data       (jpeg_head_data      ),
    .jpeg_head_data_valid (jpeg_head_data_valid),
    .jpeg_head_data_last  (jpeg_head_data_last ),

    .m_data               (ctrl_m_data         ),
    .m_data_keep          (ctrl_m_data_keep    ),
    .m_data_valid         (ctrl_m_data_valid   ),
    .m_data_last          (ctrl_m_data_last    )
);
    
endmodule