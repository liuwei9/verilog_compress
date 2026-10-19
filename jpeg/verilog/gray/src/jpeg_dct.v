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

reg [5:0] s_data_valid_ff; 
reg [5:0] s_data_last_ff ; 

reg [20:0] pipe_1 [7:0];
reg [21:0] pipe_2 [3:0];
reg [22:0] pipe_3 [1:0];
reg [23:0] pipe_4      ;
reg [15:0] pipe_5      ;

reg [15:0] dct_1d_mem [127:0];

generate
    for (i = 0; i < 8; i = i + 1) begin : LOOP_MINUS_128
        always @(posedge clk ) begin
            pipe_0[i] <= $signed({1'b0, s_data[i*8 +: 8]}) - $signed({1'b0, 8'd128});
        end
    end
endgenerate

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
    for (i = 0; i < 127; i = i+1) begin : LOOP_DCT_1D
        always @(posedge clk ) begin
            dct_1d_mem[i+1] <= dct_1d_mem[i];
        end
    end
endgenerate
    
endmodule