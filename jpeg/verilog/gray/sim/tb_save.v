module tb_save #(
    parameter FILE_PATH = ""
) (
    input         clk         ,
    input         rst         ,
    input [63:0]  m_data      ,
    input         m_data_valid,
    input         m_data_last 
);

integer fp;
// integer fp_2;
initial begin
    repeat(5) @(posedge clk);
    fp = $fopen(FILE_PATH,"wb");
    // fp_2 = $fopen("E:/python_image_sim/pythonProject/jpeg/img/aaa.txt","w");
    if(fp == 0)begin
        $display("error : cannot open %s", FILE_PATH);
    $stop;
    end
    wait(m_data_last);
    repeat(5) @(posedge clk);
    $fclose(fp);
    // $fclose(fp_2);
    $finish;
end

always @(posedge clk ) begin
    if(m_data_valid)begin
        $fwrite(fp, "%c", m_data[7:0]);
        $fwrite(fp, "%c", m_data[15:8]);
        $fwrite(fp, "%c", m_data[23:16]);
        $fwrite(fp, "%c", m_data[31:24]);
        $fwrite(fp, "%c", m_data[39:32]);
        $fwrite(fp, "%c", m_data[47:40]);
        $fwrite(fp, "%c", m_data[55:48]);
        $fwrite(fp, "%c", m_data[63:56]);
    end
end

// always @(posedge clk ) begin
//     if(m_data_valid)begin
//         $fwrite(fp_2, "%h%h%h%h%h%h%h%h\n", m_data[7:0], m_data[15:8], m_data[23:16], m_data[31:24], m_data[39:32], m_data[47:40], m_data[55:48], m_data[63:56]);
//     end
// end

// reg [63:0] test_mem [9243 - 1:0];
// reg [31:0]  addr;
// initial begin
//     $readmemh("E:/isp/MATLAB_Jpeg_encoder_master/jpeg_gray/gray_image.txt", test_mem);
// end

// always @(posedge clk ) begin
//     if(rst)begin
//         addr <= 32'd0;
//     end
//     else begin
//         if(m_data_valid)begin
//             addr <= addr + 1;
//         end
//     end
// end


// always @(posedge clk ) begin
//     if(m_data_valid)begin
//         if(test_mem[addr] != m_data)begin
//             $stop;
//         end
//     end
// end
    
endmodule