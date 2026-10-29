 module jpeg_in_buf_yuv444 #(
    parameter IMG_H = 1024,
    parameter IMG_W = 8   
) (
    input                           clk         ,
    input                           rst         ,

    input [31:0]                    s_data      ,
    input                           s_data_valid,
    input                           s_data_last ,
    output                          s_data_ready,
    input                           s_data_done ,

    output [63:0]                   m_data      ,
    output                          m_data_valid,
    output                          m_data_last ,
    output                          m_data_user ,
    input                           m_data_req  ,
    output                          m_data_end  
);

endmodule