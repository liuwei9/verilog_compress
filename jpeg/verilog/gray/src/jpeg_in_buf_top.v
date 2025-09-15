module jpeg_in_buf_top #(
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
    input                           s_cmd_ready      ,

    output [63:0]                   m_data           ,
    output                          m_data_valid     ,
    output                          m_data_last      ,
    input                           m_data_req       
);

wire [63:0]                   ping_s_data      ;
wire [ 7:0]                   ping_s_data_keep ;
wire                          ping_s_data_valid;
wire                          ping_s_data_last ;
wire                          ping_s_data_ready;
wire                          ping_s_data_done ;
 
wire [63:0]                   pang_s_data      ;
wire [ 7:0]                   pang_s_data_keep ;
wire                          pang_s_data_valid;
wire                          pang_s_data_last ;
wire                          pang_s_data_ready;
wire                          pang_s_data_done ;
 
wire [63:0]                   ping_m_data      ;
wire                          ping_m_data_valid;
wire                          ping_m_data_last ;
wire                          ping_m_data_req  ;
wire                          ping_m_data_end  ;

wire [63:0]                   pang_m_data      ;
wire                          pang_m_data_valid;
wire                          pang_m_data_last ;
wire                          pang_m_data_req  ;
wire                          pang_m_data_end  ;

jpeg_in_buf_ctrl #(
    .IMG_H (IMG_H),
    .IMG_W (IMG_W)
) jpeg_in_buf_ctrl_inst (
    .clk               (clk              ),
    .rst               (rst              ),

    .cfg_img_h         (cfg_img_h        ),
    .cfg_img_w         (cfg_img_w        ),
    .cfg_img_addr      (cfg_img_addr     ),
    .jpeg_start        (jpeg_start       ),

    .s_data            (s_data           ),
    .s_data_keep       (s_data_keep      ),
    .s_data_valid      (s_data_valid     ),
    .s_data_last       (s_data_last      ),
    .s_data_ready      (s_data_ready     ),

    .s_cmd_addr        (s_cmd_addr       ),
    .s_cmd_len         (s_cmd_len        ),
    .s_cmd_valid       (s_cmd_valid      ),
    .s_cmd_ready       (s_cmd_ready      ),

    .m_data            (m_data           ),
    .m_data_valid      (m_data_valid     ),
    .m_data_last       (m_data_last      ),
    .m_data_req        (m_data_req       ),

    .ping_s_data       (ping_s_data      ),
    .ping_s_data_keep  (ping_s_data_keep ),
    .ping_s_data_valid (ping_s_data_valid),
    .ping_s_data_last  (ping_s_data_last ),
    .ping_s_data_ready (ping_s_data_ready),
    .ping_s_data_done  (ping_s_data_done ),

    .pang_s_data       (pang_s_data      ),
    .pang_s_data_keep  (pang_s_data_keep ),
    .pang_s_data_valid (pang_s_data_valid),
    .pang_s_data_last  (pang_s_data_last ),
    .pang_s_data_ready (pang_s_data_ready),
    .pang_s_data_done  (pang_s_data_done ),

    .ping_m_data       (ping_m_data      ),
    .ping_m_data_valid (ping_m_data_valid),
    .ping_m_data_last  (ping_m_data_last ),
    .ping_m_data_req   (ping_m_data_req  ),
    .ping_m_data_end   (ping_m_data_end  ),

    .pang_m_data       (pang_m_data      ),
    .pang_m_data_valid (pang_m_data_valid),
    .pang_m_data_last  (pang_m_data_last ),
    .pang_m_data_req   (pang_m_data_req  ),
    .pang_m_data_end   (pang_m_data_end  )
);

jpeg_in_buf #(
    .IMG_H (IMG_H),
    .IMG_W (IMG_W)
) jpeg_in_buf_ping (
    .clk          (clk              ),
    .rst          (rst              ),

    .s_data       (ping_s_data      ),
    .s_data_keep  (ping_s_data_keep ),
    .s_data_valid (ping_s_data_valid),
    .s_data_last  (ping_s_data_last ),
    .s_data_ready (ping_s_data_ready),
    .s_data_done  (ping_s_data_done ),

    .m_data       (ping_m_data      ),
    .m_data_valid (ping_m_data_valid),
    .m_data_last  (ping_m_data_last ),
    .m_data_req   (ping_m_data_req  ),
    .m_data_end   (ping_m_data_end  )
);

jpeg_in_buf #(
    .IMG_H (IMG_H),
    .IMG_W (IMG_W)
) jpeg_in_buf_pang (
    .clk          (clk              ),
    .rst          (rst              ),

    .s_data       (pang_s_data      ),
    .s_data_keep  (pang_s_data_keep ),
    .s_data_valid (pang_s_data_valid),
    .s_data_last  (pang_s_data_last ),
    .s_data_ready (pang_s_data_ready),
    .s_data_done  (pang_s_data_done ),

    .m_data       (pang_m_data      ),
    .m_data_valid (pang_m_data_valid),
    .m_data_last  (pang_m_data_last ),
    .m_data_req   (pang_m_data_req  ),
    .m_data_end   (pang_m_data_end  )
);

    
endmodule