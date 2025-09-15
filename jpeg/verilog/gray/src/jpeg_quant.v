module jpeg_quant (
    input          clk              ,
    input          rst              ,

    input [6:0]    cfg_quality      , 
    input          jpeg_start       ,

    input [25:0]   s_data           ,
    input          s_data_valid     ,
    input          s_data_last      ,

    output         div_lum_ren      ,
    output [12:0]  div_lum_raddr    ,
    input  [17:0]  div_lum_rdata    ,
    
    output [19:0]  m_data           ,
    output         m_data_valid     ,
    output         m_data_last      
);

reg [12:0] div_lum_base_addr;
reg [12:0] div_raddr;

reg jpeg_start_ff;

reg [25:0] s_data_ff [3:0];
reg [17:0] div_lum_rdata_ff [1:0];
reg [43:0] mul_data;
reg [19:0] round_data;

reg [5:0] s_data_valid_ff;
reg [5:0] s_data_last_ff ;

always @(posedge clk ) begin
    if(rst)begin
        jpeg_start_ff <= 1'b0;
    end
    else begin
        jpeg_start_ff <= jpeg_start;
    end
end

always @(posedge clk ) begin
    if(jpeg_start)begin
        div_lum_base_addr <= (cfg_quality - 7'd1) << 3'd6;
    end
end

assign div_lum_ren = s_data_valid;

always @(posedge clk ) begin
    if(jpeg_start_ff | (s_data_valid & s_data_last))begin
        div_raddr <= div_lum_base_addr;
    end
    else begin
        if(s_data_valid)begin
            div_raddr <= div_raddr + 13'd1;
        end
    end
end

assign div_lum_raddr = div_raddr;

always @(posedge clk ) begin
    s_data_ff[0] <= s_data;
    s_data_ff[1] <= s_data_ff[0];
    s_data_ff[2] <= s_data_ff[1];
    s_data_ff[3] <= s_data_ff[2];
end

always @(posedge clk ) begin
    div_lum_rdata_ff[0] <= div_lum_rdata;
    div_lum_rdata_ff[1] <= div_lum_rdata_ff[0];
end

always @(posedge clk ) begin
    mul_data   <= $signed(div_lum_rdata_ff[1]) * $signed(s_data_ff[3]);
    round_data <= $signed(mul_data[43:24]) + $signed({19'd0, mul_data[23]});
end

always @(posedge clk ) begin
    if(rst)begin
        s_data_valid_ff <= 6'd0;
        s_data_last_ff  <= 6'd0;
    end
    else begin
        s_data_valid_ff <= {s_data_valid_ff[4:0], s_data_valid};
        s_data_last_ff  <= {s_data_last_ff [4:0], s_data_last };
    end
end

assign m_data = round_data;
assign m_data_valid = s_data_valid_ff[5];
assign m_data_last  = s_data_last_ff [5];
    
endmodule