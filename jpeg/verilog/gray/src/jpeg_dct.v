module jpeg_dct (
    input         clk         ,
    input         rst         ,

    input [63:0]  s_data      ,
    input         s_data_valid,
    input         s_frame_end ,
    input         s_data_last ,

    output [25:0] m_data      ,
    output        m_frame_end ,
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

genvar i, j;

reg [7:0] pipe_0 [7:0];

reg [2:0] index_i;
reg [2:0] index_j;

reg s_data_valid_ff; 
reg s_data_last_ff ; 

reg [67:0] s_data_fire;  

reg [20:0] pipe_1 [7:0];
reg [21:0] pipe_2 [3:0];
reg [22:0] pipe_3 [1:0];
reg [23:0] pipe_4      ;
reg [15:0] pipe_5      ;

reg [15:0] dct_1d_mem [112:0];
reg dct_1d_cnt_valid;
reg [5:0] dct_1d_cnt;
reg [15:0] dct_1d [7:0];

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
        s_data_fire     <= 68'd0;
    end
    else begin
        s_data_valid_ff <= s_data_valid;
        s_data_last_ff  <= s_data_last ;
        
        s_data_fire[0]  <= s_data_valid_ff & s_data_last_ff;
       
        s_data_fire[67:1] <= s_data_fire[66:0];
    end
end

always @(posedge clk ) begin
    if(rst)begin
        index_i <= 3'd0;
    end
    else begin
        if(s_data_valid_ff[0])begin
            index_i <= index_i + 3'd1;
        end
    end
end

generate
    for (i = 0; i < 8; i = i + 1) begin : LOOP_PIPE1
        always @(posedge clk ) begin
            pipe_1[i] <= $signed(pipe_0[i]) * $signed(cos_rom[index_i][i]);
        end
    end
endgenerate

always @(posedge clk ) begin
    pipe_2[0] <= $signed(pipe_1[0]) + $signed(pipe_1[1]);
    pipe_2[1] <= $signed(pipe_1[2]) + $signed(pipe_1[3]);
    pipe_2[2] <= $signed(pipe_1[4]) + $signed(pipe_1[5]);
    pipe_2[3] <= $signed(pipe_1[6]) + $signed(pipe_1[7]);

    pipe_3[0] <= $signed(pipe_2[0]) + $signed(pipe_2[1]);
    pipe_3[1] <= $signed(pipe_2[2]) + $signed(pipe_2[3]);

    pipe_4    <= $signed(pipe_3[0]) + $signed(pipe_3[1]);
    pipe_5    <= pipe_4[23:8];
end

always @(posedge clk ) begin
    dct_1d_mem[0] <= pipe_5;
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
        if(s_data_fire[67])begin
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
    
endmodule