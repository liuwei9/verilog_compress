module tb_top (
    
);
reg clk;
reg rst;

parameter MAX_IMG_H      = 720 ;
parameter MAX_IMG_W      = 1280;
parameter QUANT_LUM_PATH = "E:/jpeg/jpeg_gray_ku5p/user/src/jpeg/common/quantLumMatrix.mem";
parameter DIV_LUM_PATH   = "E:/jpeg/jpeg_gray_ku5p/user/src/jpeg/common/divLumMatrix.mem"  ;

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
    .s_cmd_ready      (s_cmd_ready      )
);

endmodule