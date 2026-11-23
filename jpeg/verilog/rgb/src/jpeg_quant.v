module jpeg_quant (
    input          clk              ,
    input          rst              ,

    input [6:0]    cfg_quality      , 
    input          jpeg_start       ,

    input [10:0]   s_data           ,
    input          s_data_valid     ,
    input          s_data_last      ,
    input [1:0]    s_data_user      ,

    output         div_lum_ren      ,
    output [12:0]  div_lum_raddr    ,
    input  [17:0]  div_lum_rdata    ,
    output         div_chrom_ren    ,
    output [12:0]  div_chrom_raddr  ,
    input  [17:0]  div_chrom_rdata  ,
    
    output [11:0]  m_data           ,
    output [6:0]   m_zero_cnt       ,
    output         m_data_valid     ,
    output         m_data_last      ,
    output [1:0]   m_data_user       
);

reg [12:0] div_lum_base_addr;
reg [12:0] div_raddr;

reg jpeg_start_ff;

reg [10:0] s_data_ff [3:0];
reg [17:0] div_lum_rdata_ff [1:0];
reg [28:0] mul_data;
reg [11:0] round_data;

reg [6:0] s_data_valid_ff;
reg [6:0] s_data_last_ff ;

reg [5:0]  zero_cnt;
reg [5:0]  zero_cnt_ff;
reg [6:0]  zero_cnt_ff_add1;
reg [11:0] round_data_ff;
reg        valid;
reg        valid_zero_last;
reg first_flag;

reg [1:0] s_data_user_ff [6:0];
genvar i;

always @(posedge clk ) begin
    s_data_user_ff[0] <= s_data_user;   
end

generate
    for (i = 0; i < 6; i = i+1) begin : LOOP_DELAY_USER
        always @(posedge clk ) begin
            s_data_user_ff[i+1] <= s_data_user_ff[i];
        end
    end
endgenerate

assign m_data_user = s_data_user_ff[6];


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

assign div_lum_ren   = s_data_valid;
assign div_chrom_ren = s_data_valid;

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

assign div_lum_raddr   = div_raddr;
assign div_chrom_raddr = div_raddr;

always @(posedge clk ) begin
    s_data_ff[0] <= s_data;
    s_data_ff[1] <= s_data_ff[0];
    s_data_ff[2] <= s_data_ff[1];
    s_data_ff[3] <= s_data_ff[2];
end

always @(posedge clk ) begin
    if(s_data_user_ff[1] == 2'b00)begin
        div_lum_rdata_ff[0] <= div_lum_rdata;
    end
    else begin
        div_lum_rdata_ff[0] <= div_chrom_rdata;
    end   
    div_lum_rdata_ff[1] <= div_lum_rdata_ff[0];
end
// reg [19:0] test_mem [2764800 - 1:0];
// reg [31:0]  addr;
// initial begin
//     $readmemh("E:/isp/MATLAB_Jpeg_encoder_master/quant_data.txt", test_mem);
// end

// always @(posedge clk ) begin
//     if(rst)begin
//         addr <= 32'd0;
//     end
//     else begin
//         if(s_data_valid_ff[4])begin
//             addr <= addr + 1;
//         end
//     end
// end

always @(posedge clk ) begin
    mul_data   <= $signed(div_lum_rdata_ff[1]) * $signed(s_data_ff[3]);
    round_data <= $signed(mul_data[27:16]) + $signed({11'd0, mul_data[15]});
    // round_data <= test_mem[addr];
end

always @(posedge clk ) begin
    if(rst)begin
        s_data_valid_ff <= 7'd0;
        s_data_last_ff  <= 7'd0;
    end
    else begin
        s_data_valid_ff <= {s_data_valid_ff[5:0], s_data_valid};
        s_data_last_ff  <= {s_data_last_ff [5:0], s_data_last };
    end
end

always @(posedge clk ) begin
    if(rst)begin
        zero_cnt <= 6'd0;
    end
    else begin
        if(s_data_valid_ff[5])begin
            if(first_flag)begin
                zero_cnt <= 6'd0;
            end
            else begin
                if(round_data == 12'd0)begin
                    zero_cnt <= zero_cnt + 6'd1; 
                end
                else begin
                    zero_cnt <= 6'd0;
                end
            end
        end
        else begin
            zero_cnt <= 6'd0;
        end
    end
end 

always @(posedge clk ) begin
    zero_cnt_ff_add1 <= zero_cnt + 6'd1;
    zero_cnt_ff      <= zero_cnt;
end

always @(posedge clk ) begin
    round_data_ff <= round_data[11:0];
end

always @(posedge clk ) begin
    if(rst)begin
        first_flag <= 1'b1;
    end
    else begin
        if(s_data_last_ff[5])begin
            first_flag <= 1'b1;
        end
        else if(s_data_valid_ff[5])begin
            first_flag <= 1'b0;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        valid <= 1'b0;
        valid_zero_last <= 1'b0;
    end
    else begin
        valid <= s_data_valid_ff[5] && ((round_data != 12'd0) || s_data_last_ff[5] || first_flag); 
        valid_zero_last <= s_data_valid_ff[5] & (round_data[11:0] != 12'd0) & (!first_flag);
    end
end

assign m_data       = round_data_ff     ;
assign m_zero_cnt   = valid_zero_last ? zero_cnt_ff : zero_cnt          ;
assign m_data_valid = valid             ;
assign m_data_last  = s_data_last_ff [6];
    
endmodule