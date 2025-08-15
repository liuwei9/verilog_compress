module jpeg_dct (
    input        clk         ,
    input        rst         ,

    input [63:0] s_data      ,
    input        s_data_valid,
    input        s_data_last ,

    output [7:0] m_data      ,
    output       m_data_valid,
    output       m_data_last 
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
reg [8:0]  pipe_3_0_b_ff[1:0];

reg [12:0] pipe_3_1;
reg [12:0] pipe_3_1_ff[1:0];
reg [8:0]  pipe_3_1_b_ff[1:0];

reg [20:0] pipe_4_0;
reg [20:0] pipe_4_1;
reg [20:0] pipe_4_2;
reg [20:0] pipe_4_3;

reg [20:0] pipe_4_0_ff;

reg [21:0] pipe_5_0;
reg [21:0] pipe_5_1;
reg [21:0] pipe_5_2;

reg [21:0] pipe_6_0;
reg [21:0] pipe_6_1;
reg [21:0] pipe_6_2;
reg [21:0] pipe_6_3;
reg [12:0] pipe_6_4;
reg [12:0] pipe_6_5;
reg [21:0] pipe_6_6;
reg [21:0] pipe_6_7;

reg [21:0] pipe_7 [7:0];

generate
    for (i = 0; i < 8; i = i + 1) begin : LOOP_MINUS_128
        always @(posedge clk ) begin
            pipe_0[i] <= $signed({1'b0, s_data[i*8 +: 8]}) - $signed{1'b0, 8'd128};
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

    pipe_5_2 <= $signed(pipe_2_2_ff[3]) + $signed(pipe_2_2_b_ff[3]);
end

//z11 = tmp7 + z3;
//z13 = tmp7 - z3;
always @(posedge clk ) begin
    pipe_1_0_ff[0] <= pipe_1[7];
    pipe_1_0_ff[1] <= pipe_1_0_ff[0];
    pipe_1_0_ff[2] <= pipe_1_0_ff[1];
    pipe_1_0_ff[3] <= pipe_1_0_ff[2];
    pipe_1_0_ff[4] <= pipe_1_0_ff[3];
    pipe_1_0_ff[5] <= pipe_1_0_ff[6];

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

/*****************************************************************************/

    
endmodule