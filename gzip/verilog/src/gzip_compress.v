module gzip_compress (
    input         clk    ,
    input         rst    ,
    input  [7:0]  s_data ,
    input         s_valid,
    input         s_last ,
    output        s_ready,

    output [31:0] m_data ,
    output        m_valid,
    output        m_last ,
    input         m_ready 
);

gzip_compress_in_buf gzip_compress_in_buf_inst(
    .clk        (clk     ),
    .rst        (rst     ),
    .s_data     (s_data  ),
    .s_valid    (s_valid ),
    .s_last     (s_last  ),
    .s_ready    (s_ready ),

    .m_data     (),
    .m_valid    (),
    .m_last     (),
    .m_ready    () 
);


    
endmodule