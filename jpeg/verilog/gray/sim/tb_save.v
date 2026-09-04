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
initial begin
    repeat(5) @(posedge clk);
    fp = $fopen(FILE_PATH,"w");
    if(fp == 0)begin
        $display("error : cannot open %s", FILE_PATH);
    $stop;
    end
    wait(m_data_last);
    repeat(5) @(posedge clk);
    $fclose(fp);
end

always @(posedge clk ) begin
    if(m_data_valid)begin
        $fwrite(fp, "%d\n", m_data[7:0]);
        $fwrite(fp, "%d\n", m_data[15:8]);
        $fwrite(fp, "%d\n", m_data[23:16]);
        $fwrite(fp, "%d\n", m_data[31:24]);
        $fwrite(fp, "%d\n", m_data[39:32]);
        $fwrite(fp, "%d\n", m_data[47:40]);
        $fwrite(fp, "%d\n", m_data[55:48]);
        $fwrite(fp, "%d\n", m_data[63:56]);
    end
end
    
endmodule