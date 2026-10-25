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

    input [63:0]   s_data           ,
    input [ 7:0]   s_data_keep      ,
    input          s_data_valid     ,
    input          s_data_last      ,
    output         s_data_ready     ,

    output [63:0]  m_data           ,
    output [ 7:0]  m_data_keep      ,
    output         m_data_valid     ,
    output         m_data_last      
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

wire [11:0] quant_m_data       ;
wire [5:0]  quant_m_zero_cnt   ;
wire        quant_m_data_valid ;
wire        quant_m_data_last  ;

wire [7:0]  ac_raddr;
wire [4:0]  ac_len  ;
wire [15:0] ac_code ;

wire [3:0]  dc_raddr;
wire [3:0]  dc_len  ;
wire [8:0]  dc_code ;

wire [4:0]  huffman_m_len       ;
wire [15:0] huffman_m_code      ;
wire [3:0]  huffman_m_bits      ;
wire [11:0] huffman_m_data      ;
wire        huffman_m_data_valid;
wire        huffman_m_data_last ;

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
    .jpeg_start       (jpeg_start  ),

    .s_data           (s_data      ),
    .s_data_keep      (s_data_keep ),
    .s_data_valid     (s_data_valid),
    .s_data_last      (s_data_last ),
    .s_data_ready     (s_data_ready),

    .m_data           (in_buf_m_data      ),
    .m_data_valid     (in_buf_m_data_valid),
    .m_data_last      (in_buf_m_data_last ),
    .m_data_req       (in_buf_m_data_req  )
);

assign in_buf_m_data_req = 1'b1;

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

jpeg_quant jpeg_quant_inst(
    .clk              (clk                ),
    .rst              (rst                ),

    .cfg_quality      (cfg_quality        ), 
    .jpeg_start       (jpeg_start         ),

    .s_data           (dct_m_data         ),
    .s_data_valid     (dct_m_data_valid   ),
    .s_data_last      (dct_m_data_last    ),

    .div_lum_ren      (div_lum_ren        ),
    .div_lum_raddr    (div_lum_raddr      ),
    .div_lum_rdata    (div_lum_rdata      ),
    
    .m_data           (quant_m_data       ),
    .m_zero_cnt       (quant_m_zero_cnt   ),
    .m_data_valid     (quant_m_data_valid ),
    .m_data_last      (quant_m_data_last  )
);

jpeg_huffman jpeg_huffman_inst(
    .clk              (clk              ),
    .rst              (rst              ),

    .jpeg_start       (jpeg_start       ),

    .s_data           (quant_m_data      ),
    .s_zero_cnt       (quant_m_zero_cnt  ),
    .s_data_valid     (quant_m_data_valid),
    .s_data_last      (quant_m_data_last ),

    .dc_raddr         (dc_raddr         ),
    .ac_raddr         (ac_raddr         ),

    .ac_len           (ac_len           ),
    .ac_code          (ac_code          ),
    .dc_len           (dc_len           ),
    .dc_code          (dc_code          ),

    .m_len            (huffman_m_len       ),
    .m_code           (huffman_m_code      ),
    .m_bits           (huffman_m_bits      ),
    .m_data           (huffman_m_data      ),
    .m_data_valid     (huffman_m_data_valid),
    .m_data_last      (huffman_m_data_last ) 
);

jpeg_dc_table jpeg_dc_table_inst(
    .clk      (clk     ),
    .rst      (rst     ),
    
    .dc_raddr (dc_raddr),
    .dc_len   (dc_len  ),
    .dc_code  (dc_code ) 
);

jpeg_ac_table jpeg_ac_table_inst(
    .clk      (clk     ),
    .rst      (rst     ),

    .ac_raddr (ac_raddr),
    .ac_len   (ac_len  ),
    .ac_code  (ac_code ) 
);

jpeg_ctrl jpeg_ctrl_inst(
    .clk                  (clk                 ),
    .rst                  (rst                 ),

    .jpeg_start           (jpeg_start          ),

    .jpeg_head_data       (jpeg_head_data      ),
    .jpeg_head_data_valid (jpeg_head_data_valid),
    .jpeg_head_data_last  (jpeg_head_data_last ),

    .huffman_s_len        (huffman_m_len       ),
    .huffman_s_code       (huffman_m_code      ),
    .huffman_s_bits       (huffman_m_bits      ),
    .huffman_s_data       (huffman_m_data      ),
    .huffman_s_data_valid (huffman_m_data_valid),
    .huffman_s_data_last  (huffman_m_data_last ),

    .m_data               (m_data              ),
    .m_data_keep          (m_data_keep         ),
    .m_data_valid         (m_data_valid        ),
    .m_data_last          (m_data_last         )
);
    
endmodule