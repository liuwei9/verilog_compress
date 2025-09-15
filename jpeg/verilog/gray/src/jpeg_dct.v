module jpeg_dct (
    input         clk         ,
    input         rst         ,

    input [63:0]  s_data      ,
    input         s_data_valid,
    input         s_data_last ,

    output [25:0] m_data      ,
    output        m_data_valid,
    output        m_data_last 
);

localparam MAGIC_0 = 10'b0010110101; //0.707106781
localparam MAGIC_1 = 10'b0001100010; //0.382683433
localparam MAGIC_2 = 10'b0010001011; //0.541196100
localparam MAGIC_3 = 10'b0101001110; //1.306562965


genvar i, j;

reg [9:0] pipe_0 [7:0];

reg [10:0] pipe_1 [7:0];
reg [10:0] pipe_1_0_ff [5:0];

reg [11:0] pipe_2 [6:0];

reg [11:0] pipe_2_0_ff   [2:0];
reg [11:0] pipe_2_1_ff   [2:0];
reg [11:0] pipe_2_0_b_ff [2:0];
reg [11:0] pipe_2_1_b_ff [2:0];
reg [11:0] pipe_2_2_ff   [3:0];
reg [11:0] pipe_2_2_b_ff [3:0];
reg [11:0] pipe_2_3_ff   [4:0];
reg [11:0] pipe_2_4_ff   [4:0];
reg [11:0] pipe_2_5_ff   [4:0];

reg [12:0] pipe_3_0;
reg [12:0] pipe_3_0_ff[1:0];
reg [9:0]  pipe_3_0_b_ff[1:0];

reg [12:0] pipe_3_1;
reg [12:0] pipe_3_1_ff[1:0];
reg [9:0]  pipe_3_1_b_ff[1:0];

reg [22:0] pipe_4_0;
reg [22:0] pipe_4_1;
reg [22:0] pipe_4_2;
reg [22:0] pipe_4_3;

reg [22:0] pipe_4_0_ff;

reg [23:0] pipe_5_0;
reg [23:0] pipe_5_1;
reg [23:0] pipe_5_2;

reg [23:0] pipe_6_0;
reg [23:0] pipe_6_1;
reg [23:0] pipe_6_2;
reg [23:0] pipe_6_3;
reg [13:0] pipe_6_4;
reg [13:0] pipe_6_5;
reg [23:0] pipe_6_6;
reg [23:0] pipe_6_7;

reg [23:0] pipe_7 [7:0];

reg [9:0] pipe_valid_0;
reg [9:0] pipe_last_0 ;

generate
    for (i = 0; i < 8; i = i + 1) begin : LOOP_MINUS_128
        always @(posedge clk ) begin
            pipe_0[i] <= $signed({1'b0, s_data[i*8 +: 8]}) - $signed({1'b0, 8'd128});
        end
    end
endgenerate

always @(posedge clk ) begin
    pipe_1[0] <= $signed(pipe_0[0]) + $signed(pipe_0[7]); //tmp0 = output(i, 1) + output(i, 8);
    pipe_1[7] <= $signed(pipe_0[0]) - $signed(pipe_0[7]); //tmp7 = output(i, 1) - output(i, 8);
    pipe_1[1] <= $signed(pipe_0[1]) + $signed(pipe_0[6]); //tmp1 = output(i, 2) + output(i, 7);
    pipe_1[6] <= $signed(pipe_0[1]) - $signed(pipe_0[6]); //tmp6 = output(i, 2) - output(i, 7);
    pipe_1[2] <= $signed(pipe_0[2]) + $signed(pipe_0[5]); //tmp2 = output(i, 3) + output(i, 6);
    pipe_1[5] <= $signed(pipe_0[2]) - $signed(pipe_0[5]); //tmp5 = output(i, 3) - output(i, 6);
    pipe_1[3] <= $signed(pipe_0[3]) + $signed(pipe_0[4]); //tmp3 = output(i, 4) + output(i, 5);
    pipe_1[4] <= $signed(pipe_0[3]) - $signed(pipe_0[4]); //tmp4 = output(i, 4) - output(i, 5);
end

always @(posedge clk ) begin
    pipe_2[0] <= $signed(pipe_1[0]) + $signed(pipe_1[3]); //tmp10 = tmp0 + tmp3;
    pipe_2[3] <= $signed(pipe_1[0]) - $signed(pipe_1[3]); //tmp13 = tmp0 - tmp3;
    pipe_2[1] <= $signed(pipe_1[1]) + $signed(pipe_1[2]); //tmp11 = tmp1 + tmp2;
    pipe_2[2] <= $signed(pipe_1[1]) - $signed(pipe_1[2]); //tmp12 = tmp1 - tmp2;

    pipe_2[4] <= $signed(pipe_1[4]) + $signed(pipe_1[5]); //tmp10 = tmp4 + tmp5;
    pipe_2[5] <= $signed(pipe_1[5]) + $signed(pipe_1[6]); //tmp11 = tmp5 + tmp6;
    pipe_2[6] <= $signed(pipe_1[6]) + $signed(pipe_1[7]); //tmp12 = tmp6 + tmp7;
end

//z1 = (tmp12 + tmp13) * 0.707106781;
always @(posedge clk ) begin
    pipe_3_0 <= $signed(pipe_2[2]) + $signed(pipe_2[3]);
    pipe_3_0_ff[0] <= pipe_3_0;
    pipe_3_0_ff[1] <= pipe_3_0_ff[0];

    pipe_3_0_b_ff[0] <= MAGIC_0;
    pipe_3_0_b_ff[1] <= pipe_3_0_b_ff[0];

    pipe_4_0 <= $signed(pipe_3_0_ff[1]) * $signed(pipe_3_0_b_ff[1]);
end

//z5 = (tmp10 - tmp12) * 0.382683433;
always @(posedge clk ) begin
    pipe_3_1 <= $signed(pipe_2[4]) - $signed(pipe_2[6]);
    pipe_3_1_ff[0] <= pipe_3_1;
    pipe_3_1_ff[1] <= pipe_3_1_ff[0];

    pipe_3_1_b_ff[0] <= MAGIC_1;
    pipe_3_1_b_ff[1] <= pipe_3_1_b_ff[0];

    pipe_4_1 <= $signed(pipe_3_1_ff[1]) * $signed(pipe_3_1_b_ff[1]);
end

//z2 = 0.541196100 * tmp10 + z5;
//z4 = 1.306562965 * tmp12 + z5;
always @(posedge clk ) begin
    pipe_2_0_ff  [0] <= pipe_2[4]; 
    pipe_2_1_ff  [0] <= pipe_2[6]; 
    pipe_2_0_b_ff[0] <= MAGIC_2;
    pipe_2_1_b_ff[0] <= MAGIC_3;

    pipe_2_0_ff  [1] <= pipe_2_0_ff  [0]; 
    pipe_2_1_ff  [1] <= pipe_2_1_ff  [0]; 
    pipe_2_0_b_ff[1] <= pipe_2_0_b_ff[0];
    pipe_2_1_b_ff[1] <= pipe_2_1_b_ff[0];

    pipe_2_0_ff  [2] <= pipe_2_0_ff  [1]; 
    pipe_2_1_ff  [2] <= pipe_2_1_ff  [1]; 
    pipe_2_0_b_ff[2] <= pipe_2_0_b_ff[1];
    pipe_2_1_b_ff[2] <= pipe_2_1_b_ff[1];

    pipe_4_2 <= $signed(pipe_2_0_ff[2]) * $signed(pipe_2_0_b_ff[2]);
    pipe_4_3 <= $signed(pipe_2_1_ff[2]) * $signed(pipe_2_1_b_ff[2]);

    pipe_5_0 <= $signed(pipe_4_1) + $signed(pipe_4_2);
    pipe_5_1 <= $signed(pipe_4_1) + $signed(pipe_4_3);
end

//z3 = tmp11 * 0.707106781;
always @(posedge clk ) begin
    pipe_2_2_ff  [0] <= pipe_2[5];
    pipe_2_2_b_ff[0] <= MAGIC_0;

    pipe_2_2_ff  [1] <= pipe_2_2_ff  [0];
    pipe_2_2_b_ff[1] <= pipe_2_2_b_ff[0];

    pipe_2_2_ff  [2] <= pipe_2_2_ff  [1];
    pipe_2_2_b_ff[2] <= pipe_2_2_b_ff[1];

    pipe_2_2_ff  [3] <= pipe_2_2_ff  [2];
    pipe_2_2_b_ff[3] <= pipe_2_2_b_ff[2];

    pipe_5_2 <= $signed(pipe_2_2_ff[3]) * $signed(pipe_2_2_b_ff[3]);
end

//z11 = tmp7 + z3;
//z13 = tmp7 - z3;
always @(posedge clk ) begin
    pipe_1_0_ff[0] <= pipe_1[7];
    pipe_1_0_ff[1] <= pipe_1_0_ff[0];
    pipe_1_0_ff[2] <= pipe_1_0_ff[1];
    pipe_1_0_ff[3] <= pipe_1_0_ff[2];
    pipe_1_0_ff[4] <= pipe_1_0_ff[3];
    pipe_1_0_ff[5] <= pipe_1_0_ff[4];

    pipe_6_0 <= $signed({pipe_1_0_ff[5], 8'd0}) + $signed(pipe_5_2);
    pipe_6_1 <= $signed({pipe_1_0_ff[5], 8'd0}) - $signed(pipe_5_2);
end

always @(posedge clk ) begin
    pipe_6_2 <= pipe_5_0;
    pipe_6_3 <= pipe_5_1;
end

//output(i, 6) = z13 + z2;
//output(i, 4) = z13 - z2;
//output(i, 2) = z11 + z4;
//output(i, 8) = z11 - z4;
always @(posedge clk ) begin
    pipe_7[5] <= $signed(pipe_6_1) + $signed(pipe_6_2);
    pipe_7[3] <= $signed(pipe_6_1) - $signed(pipe_6_2);
    pipe_7[1] <= $signed(pipe_6_0) + $signed(pipe_6_3);
    pipe_7[7] <= $signed(pipe_6_0) - $signed(pipe_6_3);
end

//output(i, 1) = tmp10 + tmp11;
//output(i, 5) = tmp10 - tmp11;
always @(posedge clk ) begin
    pipe_2_3_ff[0] <= pipe_2[0];
    pipe_2_3_ff[1] <= pipe_2_3_ff[0];
    pipe_2_3_ff[2] <= pipe_2_3_ff[1];
    pipe_2_3_ff[3] <= pipe_2_3_ff[2];
    pipe_2_3_ff[4] <= pipe_2_3_ff[3];

    pipe_2_4_ff[0] <= pipe_2[1];
    pipe_2_4_ff[1] <= pipe_2_4_ff[0];
    pipe_2_4_ff[2] <= pipe_2_4_ff[1];
    pipe_2_4_ff[3] <= pipe_2_4_ff[2];
    pipe_2_4_ff[4] <= pipe_2_4_ff[3];

    pipe_6_4 <= $signed(pipe_2_3_ff[4]) + $signed(pipe_2_4_ff[4]);
    pipe_6_5 <= $signed(pipe_2_3_ff[4]) - $signed(pipe_2_4_ff[4]);

    pipe_7[0] <= $signed({pipe_6_4, 8'd0});
    pipe_7[4] <= $signed({pipe_6_5, 8'd0});
end

always @(posedge clk ) begin
    pipe_2_5_ff[0] <= pipe_2[3];
    pipe_2_5_ff[1] <= pipe_2_5_ff[0];
    pipe_2_5_ff[2] <= pipe_2_5_ff[1];
    pipe_2_5_ff[3] <= pipe_2_5_ff[2];
    pipe_2_5_ff[4] <= pipe_2_5_ff[3];

    pipe_4_0_ff <= pipe_4_0;
    pipe_6_6 <= $signed({pipe_2_5_ff[4], 8'd0}) + $signed(pipe_4_0_ff);
    pipe_6_7 <= $signed({pipe_2_5_ff[4], 8'd0}) - $signed(pipe_4_0_ff);

    pipe_7[2] <= pipe_6_6;
    pipe_7[6] <= pipe_6_7;
end

always @(posedge clk ) begin
    if(rst)begin
        pipe_valid_0 <= 10'd0;
        pipe_last_0  <= 10'd0;
    end
    else begin
        pipe_valid_0 <= {pipe_valid_0[8:0], s_data_valid};
        pipe_last_0  <= {pipe_last_0 [8:0], s_data_last };
    end
    
end

/*****************************************************************************/
reg [23:0] dct_1d_mem [7:0][15:0];
reg [23:0] dct_1d [7:0];
reg [2:0]  dct_1d_cnt;

reg  pipe_valid_1_t;
wire pipe_last_1_t ;

reg pipe_valid_1;
reg pipe_last_1 ;
always @(posedge clk ) begin
    if(rst)begin
        pipe_valid_1_t <= 1'b0;
    end
    else begin
        if(pipe_last_0[9] & pipe_valid_0[9])begin
            pipe_valid_1_t <= 1'b1;
        end
        else if(&dct_1d_cnt)begin
            pipe_valid_1_t <= 1'b0;
        end
    end
end

assign pipe_last_1_t = &dct_1d_cnt;

always @(posedge clk ) begin
    if(pipe_valid_1_t)begin
        dct_1d_cnt <= dct_1d_cnt + 3'd1;
    end
    else begin
        dct_1d_cnt <= 3'd0;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        pipe_valid_1 <= 1'b0;
        pipe_last_1  <= 1'b0;
    end
    else begin
        pipe_valid_1 <= pipe_valid_1_t;
        pipe_last_1  <= pipe_last_1_t ;
    end
end

generate
    for (i = 0; i < 8; i = i+1) begin : LOOP_DCT1D_P_I
        always @(posedge clk ) begin
            dct_1d_mem[i][0] <= pipe_7[i];
        end
    end
endgenerate

generate
    for (i = 0; i < 8; i = i+1) begin: LOOP_DCT1D_P1_I
        for (j = 1; j < 16; j = j+1) begin: LOOP_DCT1D_P1_J
            always @(posedge clk ) begin
                dct_1d_mem[i][j] <= dct_1d_mem[i][j - 1];
            end
        end
    end
endgenerate

generate
    for (i = 0; i < 8; i = i+1) begin: LOOP_DCT1D_P2_I
        always @(posedge clk ) begin
            case (dct_1d_cnt)
                3'd0: begin
                    dct_1d[i] <= dct_1d_mem[0][7 - i];
                end 
                3'd1: begin
                    dct_1d[i] <= dct_1d_mem[1][8 - i];
                end 
                3'd2: begin
                    dct_1d[i] <= dct_1d_mem[2][9 - i];
                end 
                3'd3: begin
                    dct_1d[i] <= dct_1d_mem[3][10 - i];
                end 
                3'd4: begin
                    dct_1d[i] <= dct_1d_mem[4][11 - i];
                end 
                3'd5: begin
                    dct_1d[i] <= dct_1d_mem[5][12 - i];
                end 
                3'd6: begin
                    dct_1d[i] <= dct_1d_mem[6][13 - i];
                end 
                3'd7: begin
                    dct_1d[i] <= dct_1d_mem[7][14 - i];
                end 
            endcase
        end
    end
endgenerate

/*****************************************************************************/
reg [23:0] pipe_10 [7:0];
reg [23:0] pipe_10_0_ff [6:0];

reg [23:0] pipe_20 [6:0];
reg [23:0] pipe_20_0_ff   [2:0];
reg [23:0] pipe_20_1_ff   [2:0];
reg [23:0] pipe_20_0_b_ff [2:0];
reg [23:0] pipe_20_1_b_ff [2:0];
reg [23:0] pipe_20_2_ff   [3:0];
reg [23:0] pipe_20_2_b_ff [3:0];
reg [23:0] pipe_20_3_ff   [5:0];
reg [23:0] pipe_20_4_ff   [5:0];
reg [23:0] pipe_20_5_ff   [5:0];

reg [23:0] pipe_30_0;
reg [23:0] pipe_30_0_ff[1:0];
reg [9:0]  pipe_30_0_b_ff[1:0];
reg [33:0] pipe_30_0_t;

reg [23:0] pipe_30_1;
reg [23:0] pipe_30_1_ff[1:0];
reg [9:0]  pipe_30_1_b_ff[1:0];
reg [33:0] pipe_30_1_t;

reg [33:0] pipe_30_2_t;
reg [33:0] pipe_30_3_t;
reg [33:0] pipe_30_4_t;

reg [25:0] pipe_40_0;
reg [25:0] pipe_40_1;
reg [25:0] pipe_40_2;
reg [25:0] pipe_40_3;

reg [25:0] pipe_40_0_ff;

reg [25:0] pipe_50_0;
reg [25:0] pipe_50_1;
reg [25:0] pipe_50_2;

reg [25:0] pipe_60_0;
reg [25:0] pipe_60_1;
reg [25:0] pipe_60_2;
reg [25:0] pipe_60_3;
reg [25:0] pipe_60_4;
reg [25:0] pipe_60_5;
reg [25:0] pipe_60_6;
reg [25:0] pipe_60_7;

reg [25:0] pipe_70 [7:0];
reg [9:0]  pipe_valid_2;
reg [9:0]  pipe_last_2 ;

always @(posedge clk ) begin
    pipe_10[0] <= $signed(dct_1d[0]) + $signed(dct_1d[7]); //tmp0 = output(1, i) + output(8, i);
    pipe_10[7] <= $signed(dct_1d[0]) - $signed(dct_1d[7]); //tmp7 = output(1, i) - output(8, i);
    pipe_10[1] <= $signed(dct_1d[1]) + $signed(dct_1d[6]); //tmp1 = output(2, i) + output(7, i);
    pipe_10[6] <= $signed(dct_1d[1]) - $signed(dct_1d[6]); //tmp6 = output(2, i) - output(7, i);
    pipe_10[2] <= $signed(dct_1d[2]) + $signed(dct_1d[5]); //tmp2 = output(3, i) + output(6, i);
    pipe_10[5] <= $signed(dct_1d[2]) - $signed(dct_1d[5]); //tmp5 = output(3, i) - output(6, i);
    pipe_10[3] <= $signed(dct_1d[3]) + $signed(dct_1d[4]); //tmp3 = output(4, i) + output(5, i);
    pipe_10[4] <= $signed(dct_1d[3]) - $signed(dct_1d[4]); //tmp4 = output(4, i) - output(5, i);
end

always @(posedge clk ) begin
    pipe_20[0] <= $signed(pipe_10[0]) + $signed(pipe_10[3]); //tmp10 = tmp0 + tmp3;
    pipe_20[3] <= $signed(pipe_10[0]) - $signed(pipe_10[3]); //tmp13 = tmp0 - tmp3;
    pipe_20[1] <= $signed(pipe_10[1]) + $signed(pipe_10[2]); //tmp11 = tmp1 + tmp2;
    pipe_20[2] <= $signed(pipe_10[1]) - $signed(pipe_10[2]); //tmp12 = tmp1 - tmp2;

    pipe_20[4] <= $signed(pipe_10[4]) + $signed(pipe_10[5]); //tmp10 = tmp4 + tmp5;
    pipe_20[5] <= $signed(pipe_10[5]) + $signed(pipe_10[6]); //tmp11 = tmp5 + tmp6;
    pipe_20[6] <= $signed(pipe_10[6]) + $signed(pipe_10[7]); //tmp12 = tmp6 + tmp7;
end

//z1 = (tmp12 + tmp13) * 0.707106781;
always @(posedge clk ) begin
    pipe_30_0 <= $signed(pipe_20[2]) + $signed(pipe_20[3]);
    pipe_30_0_ff[0] <= pipe_30_0;
    pipe_30_0_ff[1] <= pipe_30_0_ff[0];

    pipe_30_0_b_ff[0] <= MAGIC_0;
    pipe_30_0_b_ff[1] <= pipe_30_0_b_ff[0];

    pipe_30_0_t <= $signed(pipe_30_0_ff[1]) * $signed(pipe_30_0_b_ff[1]);
    pipe_40_0 <= $signed(pipe_30_0_t[33:8]) + $signed({1'b0, pipe_30_0_t[7]});
end

//z5 = (tmp10 - tmp12) * 0.382683433;
always @(posedge clk ) begin
    pipe_30_1 <= $signed(pipe_20[4]) - $signed(pipe_20[6]);
    pipe_30_1_ff[0] <= pipe_30_1;
    pipe_30_1_ff[1] <= pipe_30_1_ff[0];

    pipe_30_1_b_ff[0] <= MAGIC_1;
    pipe_30_1_b_ff[1] <= pipe_30_1_b_ff[0];

    pipe_30_1_t <= $signed(pipe_30_1_ff[1]) * $signed(pipe_30_1_b_ff[1]);
    pipe_40_1 <= $signed(pipe_30_1_t[33:8]) + $signed({1'b0, pipe_30_1_t[7]});
end

//z2 = 0.541196100 * tmp10 + z5;
//z4 = 1.306562965 * tmp12 + z5;
always @(posedge clk ) begin
    pipe_20_0_ff  [0] <= pipe_20[4]; 
    pipe_20_1_ff  [0] <= pipe_20[6]; 
    pipe_20_0_b_ff[0] <= MAGIC_2;
    pipe_20_1_b_ff[0] <= MAGIC_3;

    pipe_20_0_ff  [1] <= pipe_20_0_ff  [0]; 
    pipe_20_1_ff  [1] <= pipe_20_1_ff  [0]; 
    pipe_20_0_b_ff[1] <= pipe_20_0_b_ff[0];
    pipe_20_1_b_ff[1] <= pipe_20_1_b_ff[0];

    pipe_20_0_ff  [2] <= pipe_20_0_ff  [1]; 
    pipe_20_1_ff  [2] <= pipe_20_1_ff  [1]; 
    pipe_20_0_b_ff[2] <= pipe_20_0_b_ff[1];
    pipe_20_1_b_ff[2] <= pipe_20_1_b_ff[1];

    pipe_30_2_t <= $signed(pipe_20_0_ff[2]) * $signed(pipe_20_0_b_ff[2]);
    pipe_30_3_t <= $signed(pipe_20_1_ff[2]) * $signed(pipe_20_1_b_ff[2]);

    pipe_40_2 <= $signed(pipe_30_2_t[33:8]) + $signed({1'b0, pipe_30_2_t[7]});
    pipe_40_3 <= $signed(pipe_30_3_t[33:8]) + $signed({1'b0, pipe_30_3_t[7]});

    pipe_50_0 <= $signed(pipe_40_1) + $signed(pipe_40_2);
    pipe_50_1 <= $signed(pipe_40_1) + $signed(pipe_40_3);
end

//z3 = tmp11 * 0.707106781;
always @(posedge clk ) begin
    pipe_20_2_ff  [0] <= pipe_20[5];
    pipe_20_2_b_ff[0] <= MAGIC_0;

    pipe_20_2_ff  [1] <= pipe_20_2_ff  [0];
    pipe_20_2_b_ff[1] <= pipe_20_2_b_ff[0];

    pipe_20_2_ff  [2] <= pipe_20_2_ff  [1];
    pipe_20_2_b_ff[2] <= pipe_20_2_b_ff[1];

    pipe_20_2_ff  [3] <= pipe_20_2_ff  [2];
    pipe_20_2_b_ff[3] <= pipe_20_2_b_ff[2];

    pipe_30_4_t <= $signed(pipe_20_2_ff[3]) * $signed(pipe_20_2_b_ff[3]);
    pipe_50_2   <= $signed(pipe_30_4_t[33:8]) + $signed({1'b0, pipe_30_4_t[7]});
end

//z11 = tmp7 + z3;
//z13 = tmp7 - z3;
always @(posedge clk ) begin
    pipe_10_0_ff[0] <= pipe_10[7];
    pipe_10_0_ff[1] <= pipe_10_0_ff[0];
    pipe_10_0_ff[2] <= pipe_10_0_ff[1];
    pipe_10_0_ff[3] <= pipe_10_0_ff[2];
    pipe_10_0_ff[4] <= pipe_10_0_ff[3];
    pipe_10_0_ff[5] <= pipe_10_0_ff[4];
    pipe_10_0_ff[6] <= pipe_10_0_ff[5];

    pipe_60_0 <= $signed(pipe_10_0_ff[6]) + $signed(pipe_50_2);
    pipe_60_1 <= $signed(pipe_10_0_ff[6]) - $signed(pipe_50_2);
end

always @(posedge clk ) begin
    pipe_60_2 <= pipe_50_0;
    pipe_60_3 <= pipe_50_1;
end

//output(i, 6) = z13 + z2;
//output(i, 4) = z13 - z2;
//output(i, 2) = z11 + z4;
//output(i, 8) = z11 - z4;
always @(posedge clk ) begin
    pipe_70[5] <= $signed(pipe_60_1) + $signed(pipe_60_2);
    pipe_70[3] <= $signed(pipe_60_1) - $signed(pipe_60_2);
    pipe_70[1] <= $signed(pipe_60_0) + $signed(pipe_60_3);
    pipe_70[7] <= $signed(pipe_60_0) - $signed(pipe_60_3);
end

//output(i, 1) = tmp10 + tmp11;
//output(i, 5) = tmp10 - tmp11;
always @(posedge clk ) begin
    pipe_20_3_ff[0] <= pipe_20[0];
    pipe_20_3_ff[1] <= pipe_20_3_ff[0];
    pipe_20_3_ff[2] <= pipe_20_3_ff[1];
    pipe_20_3_ff[3] <= pipe_20_3_ff[2];
    pipe_20_3_ff[4] <= pipe_20_3_ff[3];
    pipe_20_3_ff[5] <= pipe_20_3_ff[4];

    pipe_20_4_ff[0] <= pipe_20[1];
    pipe_20_4_ff[1] <= pipe_20_4_ff[0];
    pipe_20_4_ff[2] <= pipe_20_4_ff[1];
    pipe_20_4_ff[3] <= pipe_20_4_ff[2];
    pipe_20_4_ff[4] <= pipe_20_4_ff[3];
    pipe_20_4_ff[5] <= pipe_20_4_ff[4];

    pipe_60_4 <= $signed(pipe_20_3_ff[5]) + $signed(pipe_20_4_ff[5]);
    pipe_60_5 <= $signed(pipe_20_3_ff[5]) - $signed(pipe_20_4_ff[5]);

    pipe_70[0] <= $signed(pipe_60_4);
    pipe_70[4] <= $signed(pipe_60_5);
end

always @(posedge clk ) begin
    pipe_20_5_ff[0] <= pipe_20[3];
    pipe_20_5_ff[1] <= pipe_20_5_ff[0];
    pipe_20_5_ff[2] <= pipe_20_5_ff[1];
    pipe_20_5_ff[3] <= pipe_20_5_ff[2];
    pipe_20_5_ff[4] <= pipe_20_5_ff[3];
    pipe_20_5_ff[5] <= pipe_20_5_ff[4];

    pipe_40_0_ff <= pipe_40_0;
    pipe_60_6 <= $signed(pipe_20_5_ff[5]) + $signed(pipe_40_0_ff);
    pipe_60_7 <= $signed(pipe_20_5_ff[5]) - $signed(pipe_40_0_ff);

    pipe_70[2] <= pipe_60_6;
    pipe_70[6] <= pipe_60_7;
end

always @(posedge clk ) begin
    if(rst)begin
        pipe_valid_2 <= 10'd0;
        pipe_last_2  <= 10'd0;
    end
    else begin
        pipe_valid_2 <= {pipe_valid_2[8:0], pipe_valid_1};
        pipe_last_2  <= {pipe_last_2 [8:0], pipe_last_1 };
    end
end

/*****************************************************************************/
reg [25:0] dout_mem [63:0];
reg [2:0]  waddr;
reg [5:0]  raddr;
reg [25:0] dout ;

reg  pipe_valid_3_t;
wire pipe_last_3_t ;

reg pipe_valid_3;
reg pipe_last_3 ;

always @(posedge clk ) begin
    if(pipe_valid_2[9])begin
        waddr <= waddr + 3'd1;
    end
    else begin
        waddr <= 3'd0;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        pipe_valid_3_t <= 1'b0;
    end
    else begin
        if(waddr == 3'd1)begin
            pipe_valid_3_t <= 1'b1;
        end
        else if(&raddr)begin
            pipe_valid_3_t <= 1'b0;
        end
    end
end

assign pipe_last_3_t = &raddr;

always @(posedge clk ) begin
    if(pipe_valid_3_t)begin
        raddr <= raddr + 6'd1;
    end
    else begin
        raddr <= 6'd0;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        pipe_valid_3 <= 1'b0;
        pipe_last_3  <= 1'b0;
    end
    else begin
        pipe_valid_3 <= pipe_valid_3_t;
        pipe_last_3  <= pipe_last_3_t ;
    end
end

always @(posedge clk ) begin
    if(pipe_valid_2[9])begin
        case (waddr)
            3'd0: begin
                dout_mem[0] <= pipe_70[0];
                dout_mem[1] <= pipe_70[1];
                dout_mem[2] <= pipe_70[2];
                dout_mem[3] <= pipe_70[3];
                dout_mem[4] <= pipe_70[4];
                dout_mem[5] <= pipe_70[5];
                dout_mem[6] <= pipe_70[6];
                dout_mem[7] <= pipe_70[7];
            end 
            3'd1: begin
                dout_mem[8] <= pipe_70[0];
                dout_mem[9] <= pipe_70[1];
                dout_mem[10] <= pipe_70[2];
                dout_mem[11] <= pipe_70[3];
                dout_mem[12] <= pipe_70[4];
                dout_mem[13] <= pipe_70[5];
                dout_mem[14] <= pipe_70[6];
                dout_mem[15] <= pipe_70[7];
            end 
            3'd2: begin
                dout_mem[16] <= pipe_70[0];
                dout_mem[17] <= pipe_70[1];
                dout_mem[18] <= pipe_70[2];
                dout_mem[19] <= pipe_70[3];
                dout_mem[20] <= pipe_70[4];
                dout_mem[21] <= pipe_70[5];
                dout_mem[22] <= pipe_70[6];
                dout_mem[23] <= pipe_70[7];
            end 
            3'd3: begin
                dout_mem[24] <= pipe_70[0];
                dout_mem[25] <= pipe_70[1];
                dout_mem[26] <= pipe_70[2];
                dout_mem[27] <= pipe_70[3];
                dout_mem[28] <= pipe_70[4];
                dout_mem[29] <= pipe_70[5];
                dout_mem[30] <= pipe_70[6];
                dout_mem[31] <= pipe_70[7];
            end 
            3'd4: begin
                dout_mem[32] <= pipe_70[0];
                dout_mem[33] <= pipe_70[1];
                dout_mem[34] <= pipe_70[2];
                dout_mem[35] <= pipe_70[3];
                dout_mem[36] <= pipe_70[4];
                dout_mem[37] <= pipe_70[5];
                dout_mem[38] <= pipe_70[6];
                dout_mem[39] <= pipe_70[7];
            end 
            3'd5: begin
                dout_mem[40] <= pipe_70[0];
                dout_mem[41] <= pipe_70[1];
                dout_mem[42] <= pipe_70[2];
                dout_mem[43] <= pipe_70[3];
                dout_mem[44] <= pipe_70[4];
                dout_mem[45] <= pipe_70[5];
                dout_mem[46] <= pipe_70[6];
                dout_mem[47] <= pipe_70[7];
            end 
            3'd6: begin
                dout_mem[48] <= pipe_70[0];
                dout_mem[49] <= pipe_70[1];
                dout_mem[50] <= pipe_70[2];
                dout_mem[51] <= pipe_70[3];
                dout_mem[52] <= pipe_70[4];
                dout_mem[53] <= pipe_70[5];
                dout_mem[54] <= pipe_70[6];
                dout_mem[55] <= pipe_70[7];
            end 
            3'd7: begin
                dout_mem[56] <= pipe_70[0];
                dout_mem[57] <= pipe_70[1];
                dout_mem[58] <= pipe_70[2];
                dout_mem[59] <= pipe_70[3];
                dout_mem[60] <= pipe_70[4];
                dout_mem[61] <= pipe_70[5];
                dout_mem[62] <= pipe_70[6];
                dout_mem[63] <= pipe_70[7];
            end  
        endcase
    end
end

always @(posedge clk ) begin
    dout <= dout_mem[raddr];
end

assign m_data       = dout        ;
assign m_data_valid = pipe_valid_3;
assign m_data_last  = pipe_last_3 ;
    
endmodule