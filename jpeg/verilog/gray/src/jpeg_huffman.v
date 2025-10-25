module jpeg_huffman (
    input          clk              ,
    input          rst              ,

    input          jpeg_start       ,

    input  [11:0]  s_data           ,
    input  [5:0]   s_zero_cnt       ,
    input          s_data_valid     ,
    input          s_data_last      ,

    output [3:0]   dc_raddr         ,
    output [7:0]   ac_raddr         ,

    input  [4:0]   ac_len           ,
    input  [15:0]  ac_code          ,
    input  [3:0]   dc_len           ,
    input  [8:0]   dc_code          ,

    output [4:0]   m_len            ,
    output [15:0]  m_code           ,
    output [3:0]   m_bits           ,
    output [11:0]  m_data           ,
    output         m_data_valid     ,
    output         m_data_last       
);


endmodule


module jpeg_huffman_calc (
    input  [11:0]  s_data           ,
    input  [5:0]   s_zero_cnt       ,
    input          s_data_valid     ,
    input          s_data_last      ,

    output [3:0]   dc_raddr         ,
    output [7:0]   ac_raddr         ,

    input  [4:0]   ac_len           ,
    input  [15:0]  ac_code          ,
    input  [3:0]   dc_len           ,
    input  [8:0]   dc_code          ,

    output [11:0]  m_data           ,
    output         m_data_valid     ,
    output         m_data_last       
);

reg [11:0] data_mem [63:0];
reg [5:0]  zero_mem [63:0];

reg [5:0] waddr;
reg [5:0] raddr;
reg [5:0] rcnt;

always @(posedge clk ) begin
    if(s_data_valid)begin
        data_mem[waddr] <= s_data;
        zero_mem[waddr] <= s_zero_cnt;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        waddr <= 6'd0;
    end
    else begin
        if(s_data_valid)begin
            waddr <= waddr + 6'd1;
        end
        else if(m_data_valid & m_data_last)begin
            waddr <= 6'd0;
        end
    end
end

always @(posedge clk ) begin
    
end


    
endmodule