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
reg  [6:0]    cfg_quality  = 10   ;
wire [31:0]   cfg_img_addr = 32'd0;
reg           jpeg_start   ;
reg  [63:0]   s_data         ;
reg  [ 7:0]   s_data_keep    ;
reg           s_data_valid   ;
reg           s_data_last    ;
reg           s_data_ready   ;
wire  [31:0]  s_cmd_addr     ;
wire  [31:0]  s_cmd_len      ;
wire          s_cmd_valid    ;
reg           s_cmd_ready    ;
reg   [63:0]  m_data         ;
reg   [ 7:0]  m_data_keep    ;
reg           m_data_valid   ;
reg           m_data_last    ;

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

string jpeg_path_pre = "E:/python_image_sim/pythonProject/jpeg/img/dut_gray_jpeg";
string jpeg_path;
initial begin
    load_img("E:/python_image_sim/pythonProject/jpeg/img/dut_gray_img.bmp");
    jpeg_start   = 1'b0 ;
    cfg_quality  = 10   ;
    jpeg_path = $sformatf("%s_%0d.jpeg", jpeg_path_pre, cfg_quality);
    #700
    jpeg_start   = 1'b1 ;
    #10
    jpeg_start   = 1'b0 ;
    fork
        read_bmp_gray();
        save_jpeg(jpeg_path);
    join 
    jpeg_start   = 1'b0 ;
    cfg_quality  = 20   ;
    jpeg_path = $sformatf("%s_%0d.jpeg", jpeg_path_pre, cfg_quality);
    #700
    jpeg_start   = 1'b1 ;
    #10
    jpeg_start   = 1'b0 ;
    fork
        read_bmp_gray();
        save_jpeg(jpeg_path);
    join  
    jpeg_start   = 1'b0 ;
    cfg_quality  = 50   ;
    jpeg_path = $sformatf("%s_%0d.jpeg", jpeg_path_pre, cfg_quality);
    #700
    jpeg_start   = 1'b1 ;
    #10
    jpeg_start   = 1'b0 ;
    fork
        read_bmp_gray();
        save_jpeg(jpeg_path);
    join   
    jpeg_start   = 1'b0 ;
    cfg_quality  = 80   ;
    jpeg_path = $sformatf("%s_%0d.jpeg", jpeg_path_pre, cfg_quality);
    #700
    jpeg_start   = 1'b1 ;
    #10
    jpeg_start   = 1'b0 ;
    fork
        read_bmp_gray();
        save_jpeg(jpeg_path);
    join  
    jpeg_start   = 1'b0 ;
    cfg_quality  = 100  ;
    jpeg_path = $sformatf("%s_%0d.jpeg", jpeg_path_pre, cfg_quality);
    #700
    jpeg_start   = 1'b1 ;
    #10
    jpeg_start   = 1'b0 ;
    fork
        read_bmp_gray();
        save_jpeg(jpeg_path);
    join            
    $finish;
end

initial begin
    
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

integer fp;
reg [7:0] mem [MAX_IMG_H * MAX_IMG_W * 4 - 1:0];
reg [7:0] file_header [53:0];
integer head_len;
integer file_len;
integer row_cnt = 0;
reg [31:0] row_num;
reg [31:0] col_num;
integer col_cnt = 0;
reg [31:0] row_size;
integer pix_index = 0;

task automatic load_img;
    input string img_path;  
    fp = $fopen(img_path, "rb");
    if(fp == 0)begin
        $display("Filed to open %s", img_path);
        $finish;
    end
    repeat(20) @(posedge clk);
    head_len = $fread(file_header, fp);
    file_len = $fread(mem, fp);
    $display("file len %d", file_len);
    repeat(20) @(posedge clk);
    $fclose(fp);
    repeat(20) @(posedge clk);
    row_num <= {file_header[25], file_header[24], file_header[23], file_header[22]};
    col_num <= {file_header[21], file_header[20], file_header[19], file_header[18]};
    @(posedge clk);
    row_size <= (col_num + 2'd3) / 3'd4 * 3'd4;
    col_cnt  <= 0;
    row_cnt  <= 0;
    @(posedge clk);

endtask
integer cnt;
task automatic read_bmp_gray;
    
    s_data_valid <= 1'b0;   
    s_data_last  <= 1'b0;
    s_cmd_ready  <= 1'b1;
    s_data_keep  <= 8'hff;
    cnt <= 0;
    @(posedge clk);
    
    for (row_cnt = 0; row_cnt < row_num; row_cnt++) begin
        s_data_valid <= 1'b0;
        s_data_last  <= 1'b0;
        pix_index = file_len - row_size * (row_cnt + 32'd1);
        wait(s_cmd_valid & s_cmd_ready);
        @(posedge clk);
        for (col_cnt = 0; col_cnt < col_num; col_cnt++) begin 
            s_data_valid <= (cnt == 7) || (col_cnt == col_num - 1);
            if(col_cnt == col_num - 1)
                s_data_last <= 1'b1;
            pix_index <= pix_index + 1;
            s_data <= {mem[pix_index], s_data[63:8]};
            if(cnt == 7)begin
                cnt <= 0;
            end          
            else begin
                cnt <= cnt + 1;
            end 
            do @(posedge clk); while (!s_data_ready);
        end
    end
    s_data_valid = 1'b0;   
    s_data_last  = 1'b0;

endtask

function automatic void write_8_bytes(integer fp, logic [63:0] data);
    for (int i = 0; i < 8; i++)
        $fwrite(fp, "%c", data[i*8 +: 8]);
endfunction

task automatic save_jpeg;
    input string img_path;
    integer fp;
    fp = $fopen(img_path,"wb");
    if(fp == 0)begin
        $display("error : cannot open %s", img_path);
        $stop;
    end
    while (m_data_last !== 1'b1) begin
        if(m_data_valid)begin
            write_8_bytes(fp, m_data);
        end
        @(posedge clk );
    end
    if(m_data_valid)begin
        write_8_bytes(fp, m_data);
    end
    @(posedge clk );
    $fclose(fp);
endtask

endmodule