module tb_top (
    
);
reg clk;
reg rst;

parameter MAX_IMG_H      = 720 ;
parameter MAX_IMG_W      = 1280;
parameter QUANT_LUM_PATH = "E:/jpeg/jpeg_gray_ku5p/user/src/jpeg/common/quantLumMatrix.mem";
parameter DIV_LUM_PATH   = "E:/jpeg/jpeg_gray_ku5p/user/src/jpeg/common/divLumMatrix.mem"  ;
parameter IMG_FILE_PATH  = "E:/python_image_sim/pythonProject/jpeg/img/dut_gray_img.txt";
parameter IMG_FILE_LEN   = 115200;
parameter DUT_FILE_PATH  = "E:/python_image_sim/pythonProject/jpeg/img/dut_gray_jpeg.jpeg";

wire [15:0]   cfg_img_h    = 720  ;
wire [15:0]   cfg_img_w    = 1280 ;
wire [6:0]    cfg_quality  = 10   ;
wire [31:0]   cfg_img_addr = 32'd0;
reg           jpeg_start   ;
wire [63:0]   s_data         ;
wire [ 7:0]   s_data_keep    ;
wire          s_data_valid   ;
wire          s_data_last    ;
wire          s_data_ready   ;
wire  [31:0]  s_cmd_addr     ;
wire  [31:0]  s_cmd_len      ;
wire          s_cmd_valid    ;
wire          s_cmd_ready    ;
wire  [63:0]  m_data         ;
wire  [ 7:0]  m_data_keep    ;
wire          m_data_valid   ;
wire          m_data_last    ;

initial begin
    clk = 1'b0;
    forever begin
        clk = #5 !clk;
    end
end

initial begin
    rst = 1'b1;
    #500
    rst = 1'b0;
end

initial begin
    jpeg_start = 1'b0;
    #700
    jpeg_start = 1'b1;
    #10
    jpeg_start = 1'b0;
end

jpeg_top #(
    .MAX_IMG_H       (MAX_IMG_H     ),
    .MAX_IMG_W       (MAX_IMG_W     ),
    .QUANT_LUM_PATH  (QUANT_LUM_PATH),
    .DIV_LUM_PATH    (DIV_LUM_PATH  )
) jpeg_top_inst (
    .clk              (clk              ),
    .rst              (rst              ),

    .cfg_img_h        (cfg_img_h        ),
    .cfg_img_w        (cfg_img_w        ),
    .cfg_quality      (cfg_quality      ), 
    .cfg_img_addr     (cfg_img_addr     ),
    .jpeg_start       (jpeg_start       ),

    .s_data           (s_data           ),
    .s_data_keep      (s_data_keep      ),
    .s_data_valid     (s_data_valid     ),
    .s_data_last      (s_data_last      ),
    .s_data_ready     (s_data_ready     ),

    .s_cmd_addr       (s_cmd_addr       ),
    .s_cmd_len        (s_cmd_len        ),
    .s_cmd_valid      (s_cmd_valid      ),
    .s_cmd_ready      (s_cmd_ready      ),

    .m_data           (m_data           ),
    .m_data_keep      (m_data_keep      ),
    .m_data_valid     (m_data_valid     ),
    .m_data_last      (m_data_last      )
);

tb_read_data #(
    .FILE_PATH (IMG_FILE_PATH),
    .FILE_LEN  (IMG_FILE_LEN ) 
) tb_read_data_inst (
    .clk          (clk              ),
    .rst          (rst              ),
    .start        (jpeg_start       ),

    .cmd_addr     (s_cmd_addr       ),
    .cmd_len      (s_cmd_len        ),
    .cmd_valid    (s_cmd_valid      ),
    .cmd_ready    (s_cmd_ready      ),

    .data         (s_data           ),
    .data_keep    (s_data_keep      ),
    .data_valid   (s_data_valid     ),
    .data_last    (s_data_last      ),
    .data_ready   (s_data_ready     )  
);

tb_save #(
    .FILE_PATH (DUT_FILE_PATH)
) tb_save_inst (
    .clk          (clk          ),
    .rst          (rst          ),
    .m_data       (m_data       ),
    .m_data_valid (m_data_valid ),
    .m_data_last  (m_data_last  )
);

endmodule