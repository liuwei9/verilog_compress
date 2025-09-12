module jpeg_top #(
    parameter IMG_H = 1024,
    parameter IMG_W = 8 
) (
    input                           clk              ,
    input                           rst              ,

    input [$clog2(IMG_H) - 1 : 0]   cfg_img_h        ,
    input [$clog2(IMG_W) - 1 : 0]   cfg_img_w        ,
    input [31:0]                    cfg_img_addr     ,
    input                           jpeg_start       ,

    input [63:0]                    s_data           ,
    input [ 7:0]                    s_data_keep      ,
    input                           s_data_valid     ,
    input                           s_data_last      ,
    output                          s_data_ready     ,

    output [31:0]                   s_cmd_addr       ,
    output [31:0]                   s_cmd_len        ,
    output                          s_cmd_valid      ,
    input                           s_cmd_ready      
);

wire [63:0] in_buf_m_data      ;
wire        in_buf_m_data_valid;
wire        in_buf_m_data_last ;
wire        in_buf_m_data_req  ;

wire [25:0] dct_m_data         ;
wire        dct_m_data_valid   ;
wire        dct_m_data_last    ;

jpeg_in_buf_top #(
    .IMG_H (IMG_H),
    .IMG_W (IMG_W)
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
    .m_data_last      (dct_m_data_last ),
);
    
endmodule