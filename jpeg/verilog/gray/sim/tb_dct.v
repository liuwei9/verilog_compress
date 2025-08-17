module tb_dct (
    
);

reg clk;
reg rst;

reg [7:0] cnt;

wire [63:0]  s_data      ;
wire         s_data_valid;
wire         s_data_last ;
wire [25:0]  m_data      ;
wire         m_data_valid;
wire         m_data_last ;

initial begin
    clk = 1'b0;
    forever begin
        clk = #2.5 !clk;
    end
end

initial begin
    rst = 1'b1;
    #100 
    rst = 1'b0;
end

always @(posedge clk ) begin
    if(rst)begin
        cnt <= 8'd0;
    end
    else begin
        if(cnt == 8'd9)begin
            cnt <= cnt;
        end
        else begin
            cnt <= cnt + 8'd1;
        end
    end
end

// assign s_data       = cnt >= 8'd1 && cnt <= 8'd8 ? {8{8'd255}} : 8'd0;
assign s_data       = cnt >= 8'd1 && cnt <= 8'd8 ? 8'd0 : {8{8'd255}};
assign s_data_valid = cnt >= 8'd1 && cnt <= 8'd8;
assign s_data_last  = cnt == 8'd8;

    
jpeg_dct jpeg_dct_inst(
    .clk          (clk         ),
    .rst          (rst         ),

    .s_data       (s_data      ),
    .s_data_valid (s_data_valid),
    .s_data_last  (s_data_last ),

    .m_data       (m_data      ),
    .m_data_valid (m_data_valid),
    .m_data_last  (m_data_last )
);
endmodule