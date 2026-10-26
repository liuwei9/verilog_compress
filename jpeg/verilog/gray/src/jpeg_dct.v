module jpeg_dct (
    input         clk         ,
    input         rst         ,

    input [63:0]  s_data      ,
    input         s_data_valid,
    input         s_data_last ,

    output [10:0] m_data      ,
    output        m_data_valid,
    output        m_data_last 
);
/*

C_float =
[ 0.3535533906,  0.3535533906,  0.3535533906,  0.3535533906,  0.3535533906,  0.3535533906,  0.3535533906,  0.3535533906 ]
[ 0.4903926402,  0.4157348062,  0.2777851165,  0.0975451610, -0.0975451610, -0.2777851165, -0.4157348062, -0.4903926402 ]
[ 0.4619397663,  0.1913417162, -0.1913417162, -0.4619397663, -0.4619397663, -0.1913417162,  0.1913417162,  0.4619397663 ]
[ 0.4157348062, -0.0975451610, -0.4903926402, -0.2777851165,  0.2777851165,  0.4903926402,  0.0975451610, -0.4157348062 ]
[ 0.3535533906, -0.3535533906, -0.3535533906,  0.3535533906,  0.3535533906, -0.3535533906, -0.3535533906,  0.3535533906 ]
[ 0.2777851165, -0.4903926402,  0.0975451610,  0.4157348062, -0.4157348062, -0.0975451610,  0.4903926402, -0.2777851165 ]
[ 0.1913417162, -0.4619397663,  0.4619397663, -0.1913417162, -0.1913417162,  0.4619397663, -0.4619397663,  0.1913417162 ]
[ 0.0975451610, -0.2777851165,  0.4157348062, -0.4903926402,  0.4903926402, -0.4157348062,  0.2777851165, -0.0975451610 ]

C_q12 =
[ 1448,  1448,  1448,  1448,  1448,  1448,  1448,  1448 ]
[ 2009,  1703,  1138,   400,  -400, -1138, -1703, -2009 ]
[ 1892,   784,  -784, -1892, -1892,  -784,   784,  1892 ]
[ 1703,  -400, -2009, -1138,  1138,  2009,   400, -1703 ]
[ 1448, -1448, -1448,  1448,  1448, -1448, -1448,  1448 ]
[ 1138, -2009,   400,  1703, -1703,  -400,  2009, -1138 ]
[  784, -1892,  1892,  -784,  -784,  1892, -1892,   784 ]
[  400, -1138,  1703, -2009,  2009, -1703,  1138,  -400 ]

*/
reg signed [12:0] cos_rom [7:0][7:0];//S0_12
reg [5:0] zigzag_rom [63:0];

initial begin
    // Row 0
    cos_rom[0][0] = 13'd1448;
    cos_rom[0][1] = 13'd1448;
    cos_rom[0][2] = 13'd1448;
    cos_rom[0][3] = 13'd1448;
    cos_rom[0][4] = 13'd1448;
    cos_rom[0][5] = 13'd1448;
    cos_rom[0][6] = 13'd1448;
    cos_rom[0][7] = 13'd1448;

    // Row 1
    cos_rom[1][0] = 13'd2009;
    cos_rom[1][1] = 13'd1703;
    cos_rom[1][2] = 13'd1138;
    cos_rom[1][3] = 13'd400 ;
    cos_rom[1][4] = -13'd400 ;
    cos_rom[1][5] = -13'd1138;
    cos_rom[1][6] = -13'd1703;
    cos_rom[1][7] = -13'd2009;

    // Row 2
    cos_rom[2][0] = 13'd1892;
    cos_rom[2][1] = 13'd784 ;
    cos_rom[2][2] = -13'd784;
    cos_rom[2][3] = -13'd1892;
    cos_rom[2][4] = -13'd1892;
    cos_rom[2][5] = -13'd784;
    cos_rom[2][6] = 13'd784;
    cos_rom[2][7] = 13'd1892;

    // Row 3
    cos_rom[3][0] = 13'd1703;
    cos_rom[3][1] = -13'd400;
    cos_rom[3][2] = -13'd2009;
    cos_rom[3][3] = -13'd1138;
    cos_rom[3][4] = 13'd1138;
    cos_rom[3][5] = 13'd2009;
    cos_rom[3][6] = 13'd400;
    cos_rom[3][7] = -13'd1703;

    // Row 4
    cos_rom[4][0] = 13'd1448;
    cos_rom[4][1] = -13'd1448;
    cos_rom[4][2] = -13'd1448;
    cos_rom[4][3] = 13'd1448;
    cos_rom[4][4] = 13'd1448;
    cos_rom[4][5] = -13'd1448;
    cos_rom[4][6] = -13'd1448;
    cos_rom[4][7] = 13'd1448;

    // Row 5
    cos_rom[5][0] = 13'd1138;
    cos_rom[5][1] = -13'd2009;
    cos_rom[5][2] = 13'd400;
    cos_rom[5][3] = 13'd1703;
    cos_rom[5][4] = -13'd1703;
    cos_rom[5][5] = -13'd400;
    cos_rom[5][6] = 13'd2009;
    cos_rom[5][7] = -13'd1138;

    // Row 6
    cos_rom[6][0] = 13'd784;
    cos_rom[6][1] = -13'd1892;
    cos_rom[6][2] = 13'd1892;
    cos_rom[6][3] = -13'd784;
    cos_rom[6][4] = -13'd784;
    cos_rom[6][5] = 13'd1892;
    cos_rom[6][6] = -13'd1892;
    cos_rom[6][7] = 13'd784;

    // Row 7
    cos_rom[7][0] = 13'd400;
    cos_rom[7][1] = -13'd1138;
    cos_rom[7][2] = 13'd1703;
    cos_rom[7][3] = -13'd2009;
    cos_rom[7][4] = 13'd2009;
    cos_rom[7][5] = -13'd1703;
    cos_rom[7][6] = 13'd1138;
    cos_rom[7][7] = -13'd400;
end

initial begin
    zigzag_rom[ 0] <= 6'd0;
    zigzag_rom[ 1] <= 6'd2;
    zigzag_rom[ 2] <= 6'd3;
    zigzag_rom[ 3] <= 6'd9;
    zigzag_rom[ 4] <= 6'd10;
    zigzag_rom[ 5] <= 6'd20;
    zigzag_rom[ 6] <= 6'd21;
    zigzag_rom[ 7] <= 6'd35;
    zigzag_rom[ 8] <= 6'd1;
    zigzag_rom[ 9] <= 6'd4;
    zigzag_rom[10] <= 6'd8;
    zigzag_rom[11] <= 6'd11;
    zigzag_rom[12] <= 6'd19;
    zigzag_rom[13] <= 6'd22;
    zigzag_rom[14] <= 6'd34;
    zigzag_rom[15] <= 6'd36;
    zigzag_rom[16] <= 6'd5;
    zigzag_rom[17] <= 6'd7;
    zigzag_rom[18] <= 6'd12;
    zigzag_rom[19] <= 6'd18;
    zigzag_rom[20] <= 6'd23;
    zigzag_rom[21] <= 6'd33;
    zigzag_rom[22] <= 6'd37;
    zigzag_rom[23] <= 6'd48;
    zigzag_rom[24] <= 6'd6;
    zigzag_rom[25] <= 6'd13;
    zigzag_rom[26] <= 6'd17;
    zigzag_rom[27] <= 6'd24;
    zigzag_rom[28] <= 6'd32;
    zigzag_rom[29] <= 6'd38;
    zigzag_rom[30] <= 6'd47;
    zigzag_rom[31] <= 6'd49;
    zigzag_rom[32] <= 6'd14;
    zigzag_rom[33] <= 6'd16;
    zigzag_rom[34] <= 6'd25;
    zigzag_rom[35] <= 6'd31;
    zigzag_rom[36] <= 6'd39;
    zigzag_rom[37] <= 6'd46;
    zigzag_rom[38] <= 6'd50;
    zigzag_rom[39] <= 6'd57;
    zigzag_rom[40] <= 6'd15;
    zigzag_rom[41] <= 6'd26;
    zigzag_rom[42] <= 6'd30;
    zigzag_rom[43] <= 6'd40;
    zigzag_rom[44] <= 6'd45;
    zigzag_rom[45] <= 6'd51;
    zigzag_rom[46] <= 6'd56;
    zigzag_rom[47] <= 6'd58;
    zigzag_rom[48] <= 6'd27;
    zigzag_rom[49] <= 6'd29;
    zigzag_rom[50] <= 6'd41;
    zigzag_rom[51] <= 6'd44;
    zigzag_rom[52] <= 6'd52;
    zigzag_rom[53] <= 6'd55;
    zigzag_rom[54] <= 6'd59;
    zigzag_rom[55] <= 6'd62;
    zigzag_rom[56] <= 6'd28;
    zigzag_rom[57] <= 6'd42;
    zigzag_rom[58] <= 6'd43;
    zigzag_rom[59] <= 6'd53;
    zigzag_rom[60] <= 6'd54;
    zigzag_rom[61] <= 6'd60;
    zigzag_rom[62] <= 6'd61;
    zigzag_rom[63] <= 6'd63;
end

genvar i, j;

reg [7:0] pipe_0 [7:0];

reg [2:0] index_i;
reg [2:0] index_j;

reg s_data_valid_ff; 
reg s_data_last_ff ; 

reg [68:0] s_data_fire;  

reg [20:0] dct_1d_pipe_1 [7:0];
reg [21:0] dct_1d_pipe_2 [3:0];
reg [22:0] dct_1d_pipe_3 [1:0];
reg [23:0] dct_1d_pipe_4      ;
reg [12:0] dct_1d_pipe_5      ;

reg [11:0] dct_1d_mem [112:0];
reg dct_1d_cnt_valid;
reg [5:0] dct_1d_cnt;
reg [11:0] dct_1d [7:0];
reg dct_1d_valid;
reg [4:0] dct_1d_valid_ff;

reg [24:0] dct_2d_pipe_1 [7:0];
reg [25:0] dct_2d_pipe_2 [3:0];
reg [26:0] dct_2d_pipe_3 [1:0];
reg [27:0] dct_2d_pipe_4;
reg [10:0] dct_2d_pipe_5;

reg [10:0] dct_2d_mem_ping [63:0];
reg [10:0] dct_2d_mem_pang [63:0];
reg w_ping;
reg r_ping;

reg [5:0] w_addr;
reg [5:0] r_addr;

reg [10:0] m_data_r      ;
reg        m_frame_end_r ;
reg        m_data_valid_r;
reg        m_data_last_r ;

generate
    for (i = 0; i < 8; i = i + 1) begin : LOOP_MINUS_128
        always @(posedge clk ) begin
            pipe_0[i] <= $signed({1'b0, s_data[i*8 +: 8]}) - $signed({1'b0, 8'd128});
        end
    end
endgenerate

always @(posedge clk ) begin
    if(rst)begin
        s_data_valid_ff <= 1'd0;
        s_data_last_ff  <= 1'd0;
        s_data_fire     <= 69'd0;
    end
    else begin
        s_data_valid_ff <= s_data_valid;
        s_data_last_ff  <= s_data_last ;
        
        s_data_fire[0]  <= s_data_valid_ff & s_data_last_ff;
       
        s_data_fire[68:1] <= s_data_fire[67:0];
    end
end

always @(posedge clk ) begin
    if(rst)begin
        index_i <= 3'd0;
    end
    else begin
        if(s_data_valid_ff)begin
            index_i <= index_i + 3'd1;
        end
    end
end

generate
    for (i = 0; i < 8; i = i + 1) begin : LOOP_PIPE1
        always @(posedge clk ) begin
            dct_1d_pipe_1[i] <= $signed(pipe_0[i]) * $signed(cos_rom[index_i][i]);
        end
    end
endgenerate

always @(posedge clk ) begin
    dct_1d_pipe_2[0] <= $signed(dct_1d_pipe_1[0]) + $signed(dct_1d_pipe_1[1]);
    dct_1d_pipe_2[1] <= $signed(dct_1d_pipe_1[2]) + $signed(dct_1d_pipe_1[3]);
    dct_1d_pipe_2[2] <= $signed(dct_1d_pipe_1[4]) + $signed(dct_1d_pipe_1[5]);
    dct_1d_pipe_2[3] <= $signed(dct_1d_pipe_1[6]) + $signed(dct_1d_pipe_1[7]);

    dct_1d_pipe_3[0] <= $signed(dct_1d_pipe_2[0]) + $signed(dct_1d_pipe_2[1]);
    dct_1d_pipe_3[1] <= $signed(dct_1d_pipe_2[2]) + $signed(dct_1d_pipe_2[3]);

    dct_1d_pipe_4    <= $signed(dct_1d_pipe_3[0]) + $signed(dct_1d_pipe_3[1]);  
end

always @(posedge clk ) begin
    dct_1d_pipe_5 <= $signed(dct_1d_pipe_4[23:12]) + $signed({11'd0, dct_1d_pipe_4[11]});
end

always @(posedge clk ) begin
    if($signed(dct_1d_pipe_5) > 13'sd2047)begin
        dct_1d_mem[0] <= 12'sd2047;
    end
    else if($signed(dct_1d_pipe_5) < -13'sd2048)begin
        dct_1d_mem[0] <= -12'sd2048;
    end
    else begin
        dct_1d_mem[0] <= dct_1d_pipe_5[11:0];
    end    
end

generate
    for (i = 0; i < 112; i = i+1) begin : LOOP_DCT_1D
        always @(posedge clk ) begin
            dct_1d_mem[i+1] <= dct_1d_mem[i];
        end
    end
endgenerate

always @(posedge clk ) begin
    if(rst)begin
        dct_1d_cnt_valid <= 1'b0;
    end
    else begin
        if(s_data_fire[4])begin
            dct_1d_cnt_valid <= 1'b1;
        end
        else if(&dct_1d_cnt)begin
            dct_1d_cnt_valid <= 1'b0;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        dct_1d_cnt <= 6'd0;
    end
    else begin
        if(dct_1d_cnt_valid)begin
            dct_1d_cnt <= dct_1d_cnt + 6'd1;
        end
        else begin
            dct_1d_cnt <= 6'd0;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        dct_1d_valid <= 1'b0;
    end
    else begin
        dct_1d_valid <= dct_1d_cnt_valid;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        dct_1d_valid_ff <= 5'd0;
    end
    else begin
        dct_1d_valid_ff <= {dct_1d_valid_ff[3:0], dct_1d_valid};
    end
end

always @(posedge clk ) begin
    if(dct_1d_cnt_valid)begin
        case (dct_1d_cnt)
            6'd0: begin
                dct_1d[0] <= dct_1d_mem[63];
                dct_1d[1] <= dct_1d_mem[55];
                dct_1d[2] <= dct_1d_mem[47];
                dct_1d[3] <= dct_1d_mem[39];
                dct_1d[4] <= dct_1d_mem[31];
                dct_1d[5] <= dct_1d_mem[23];
                dct_1d[6] <= dct_1d_mem[15];
                dct_1d[7] <= dct_1d_mem[ 7];
            end
            6'd8: begin
                dct_1d[0] <= dct_1d_mem[70];
                dct_1d[1] <= dct_1d_mem[62];
                dct_1d[2] <= dct_1d_mem[54];
                dct_1d[3] <= dct_1d_mem[46];
                dct_1d[4] <= dct_1d_mem[38];
                dct_1d[5] <= dct_1d_mem[30];
                dct_1d[6] <= dct_1d_mem[22];
                dct_1d[7] <= dct_1d_mem[14];
            end
            6'd16: begin
                dct_1d[0] <= dct_1d_mem[77];
                dct_1d[1] <= dct_1d_mem[69];
                dct_1d[2] <= dct_1d_mem[61];
                dct_1d[3] <= dct_1d_mem[53];
                dct_1d[4] <= dct_1d_mem[45];
                dct_1d[5] <= dct_1d_mem[37];
                dct_1d[6] <= dct_1d_mem[29];
                dct_1d[7] <= dct_1d_mem[21];
            end
            6'd24: begin
                dct_1d[0] <= dct_1d_mem[84];
                dct_1d[1] <= dct_1d_mem[76];
                dct_1d[2] <= dct_1d_mem[68];
                dct_1d[3] <= dct_1d_mem[60];
                dct_1d[4] <= dct_1d_mem[52];
                dct_1d[5] <= dct_1d_mem[44];
                dct_1d[6] <= dct_1d_mem[36];
                dct_1d[7] <= dct_1d_mem[28];
            end
            6'd32: begin
                dct_1d[0] <= dct_1d_mem[91];
                dct_1d[1] <= dct_1d_mem[83];
                dct_1d[2] <= dct_1d_mem[75];
                dct_1d[3] <= dct_1d_mem[67];
                dct_1d[4] <= dct_1d_mem[59];
                dct_1d[5] <= dct_1d_mem[51];
                dct_1d[6] <= dct_1d_mem[43];
                dct_1d[7] <= dct_1d_mem[35];
            end
            6'd40: begin
                dct_1d[0] <= dct_1d_mem[98];
                dct_1d[1] <= dct_1d_mem[90];
                dct_1d[2] <= dct_1d_mem[82];
                dct_1d[3] <= dct_1d_mem[74];
                dct_1d[4] <= dct_1d_mem[66];
                dct_1d[5] <= dct_1d_mem[58];
                dct_1d[6] <= dct_1d_mem[50];
                dct_1d[7] <= dct_1d_mem[42];
            end
            6'd48: begin
                dct_1d[0] <= dct_1d_mem[105];
                dct_1d[1] <= dct_1d_mem[97];
                dct_1d[2] <= dct_1d_mem[89];
                dct_1d[3] <= dct_1d_mem[81];
                dct_1d[4] <= dct_1d_mem[73];
                dct_1d[5] <= dct_1d_mem[65];
                dct_1d[6] <= dct_1d_mem[57];
                dct_1d[7] <= dct_1d_mem[49];
            end
            6'd56: begin
                dct_1d[0] <= dct_1d_mem[112];
                dct_1d[1] <= dct_1d_mem[104];
                dct_1d[2] <= dct_1d_mem[96];
                dct_1d[3] <= dct_1d_mem[88];
                dct_1d[4] <= dct_1d_mem[80];
                dct_1d[5] <= dct_1d_mem[72];
                dct_1d[6] <= dct_1d_mem[64];
                dct_1d[7] <= dct_1d_mem[56];
            end
            default: begin
                dct_1d[0] <= dct_1d[0];
                dct_1d[1] <= dct_1d[1];
                dct_1d[2] <= dct_1d[2];
                dct_1d[3] <= dct_1d[3];
                dct_1d[4] <= dct_1d[4];
                dct_1d[5] <= dct_1d[5];
                dct_1d[6] <= dct_1d[6];
                dct_1d[7] <= dct_1d[7];
            end 
        endcase
    end   
end

always @(posedge clk ) begin
    if(rst)begin
        index_j <= 3'd0;
    end
    else begin
        if(dct_1d_valid)begin
            index_j <= index_j + 3'd1;
        end
    end
end

generate
    for (i = 0; i < 8; i = i + 1) begin : LOOP_DCT_2D_PIPE0
        always @(posedge clk ) begin
            dct_2d_pipe_1[i] <= $signed(dct_1d[i]) * $signed(cos_rom[index_j][i]);
        end
    end
endgenerate

always @(posedge clk ) begin
    dct_2d_pipe_2[0] <= $signed(dct_2d_pipe_1[0]) + $signed(dct_2d_pipe_1[1]);
    dct_2d_pipe_2[1] <= $signed(dct_2d_pipe_1[2]) + $signed(dct_2d_pipe_1[3]);
    dct_2d_pipe_2[2] <= $signed(dct_2d_pipe_1[4]) + $signed(dct_2d_pipe_1[5]);
    dct_2d_pipe_2[3] <= $signed(dct_2d_pipe_1[6]) + $signed(dct_2d_pipe_1[7]);

    dct_2d_pipe_3[0] <= $signed(dct_2d_pipe_2[0]) + $signed(dct_2d_pipe_2[1]);
    dct_2d_pipe_3[1] <= $signed(dct_2d_pipe_2[2]) + $signed(dct_2d_pipe_2[3]);

    dct_2d_pipe_4    <= $signed(dct_2d_pipe_3[0]) + $signed(dct_2d_pipe_3[1]);  
end

always @(posedge clk ) begin
    if($signed(dct_2d_pipe_4[23:12]) >= 12'sd1023)begin
        dct_2d_pipe_5 <= 11'sd1023;
    end
    else if($signed(dct_2d_pipe_4[23:12]) <= -12'sd1024)begin
        dct_2d_pipe_5 <= -11'sd1024;
    end
    else begin
        dct_2d_pipe_5 <= dct_2d_pipe_4[22:12];
    end
end

always @(posedge clk ) begin
    if(rst)begin
        w_addr <= 6'd0;
    end
    else begin
        if(dct_1d_valid_ff[4])begin
            w_addr <= w_addr + 6'd1;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        w_ping <= 1'b0;
    end
    else begin
        if(dct_1d_valid_ff[4] & (&w_addr))begin
            w_ping <= !w_ping;
        end
    end
end

always @(posedge clk ) begin
    if(!w_ping)begin
        dct_2d_mem_ping[zigzag_rom[w_addr]] <= dct_2d_pipe_5;
    end    
end

always @(posedge clk ) begin
    if(w_ping)begin
        dct_2d_mem_pang[zigzag_rom[w_addr]] <= dct_2d_pipe_5;
    end    
end

always @(posedge clk ) begin
    if(rst)begin
        r_addr <= 6'd0;
    end
    else if(dct_1d_valid_ff[4] & (&w_addr))begin
        r_addr <= 6'd1;
    end
    else if(r_addr != 6'd0)begin
        r_addr <= r_addr + 6'd1;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        r_ping <= 1'b0;
    end
    else begin
        if(&r_addr)begin
            r_ping <= !r_ping;
        end
    end
end

always @(posedge clk ) begin
    if(r_ping)begin
        m_data_r <= dct_2d_mem_pang[r_addr];
    end
    else begin
        m_data_r <= dct_2d_mem_ping[r_addr];
    end
end

always @(posedge clk ) begin
    if(rst)begin
        m_data_valid_r <= 1'b0;
        m_data_last_r  <= 1'b0;
    end
    else begin
        m_data_valid_r <= (dct_1d_valid_ff[4] & (&w_addr)) || (|r_addr);
        m_data_last_r  <= &r_addr;
    end
end

assign m_data       = m_data_r      ;
assign m_frame_end  = m_frame_end_r ;
assign m_data_valid = m_data_valid_r;
assign m_data_last  = m_data_last_r ;
    
endmodule