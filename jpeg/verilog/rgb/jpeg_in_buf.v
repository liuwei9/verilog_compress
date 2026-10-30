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

/*
Y =0.299R+0.587G+0.114B
Cb=−0.168736R−0.331264G+0.5B+128
Cr=0.5R−0.418688G−0.081312B+128

Y =19595R+38470G+7471B
Cb=-11058R-21710G+32768B+8388608
Cr=32768R-27439G-5329B+8388608
*/

reg [23:0] pipe0_1 [6:0];
reg [9:0]  pipe0_2 [1:0];
reg [24:0] pipe1_1 [2:0];
reg [9:0]  pipe1_2 [2:0];
reg [23:0] pipe1_3;
reg [25:0] pipe2   [2:0];
reg [7:0]  pipe3   [2:0];

always @(posedge clk ) begin
    pipe0_1[0] <= 16'd19595 * s_data[23:16]; //19595R
    pipe0_1[1] <= 16'd38470 * s_data[15: 8]; //38470G
    pipe0_1[2] <= 16'd7471  * s_data[ 7: 0]; //7471B
    pipe0_1[3] <= 16'd11058 * s_data[23:16]; //11058R
    pipe0_1[4] <= 16'd21710 * s_data[15: 8]; //21710G
    pipe0_1[5] <= 16'd27439 * s_data[15: 8]; //27439G
    pipe0_1[6] <= 16'd5329  * s_data[ 7: 0]; //5329B
    pipe0_2[0] <= {1'b0, s_data[23:16]} + {8'd128, 1'b0}; //32768R + 8388608
    pipe0_2[1] <= {1'b0, s_data[ 7: 0]} + {8'd128, 1'b0}; //32768B + 8388608
end

always @(posedge clk ) begin
    pipe1_1[0] <= pipe0_1[0] + pipe0_1[1];//19595R+38470G
    pipe1_1[1] <= pipe0_1[3] + pipe0_1[4];//11058R+21710G
    pipe1_1[2] <= pipe0_1[5] + pipe0_1[6];//27439G+5329B
    pipe1_2[0] <= pipe0_2[0];//32768R + 8388608
    pipe1_2[1] <= pipe0_2[1];//32768B + 8388608
    pipe1_3    <= pipe0_1[2];//7471B
end

always @(posedge clk ) begin
    pipe2[0] <= pipe1_1[0] + pipe1_3;//Y =19595R+38470G+7471B
    pipe2[1] <= $signed({1'b0, pipe0_2[1], 15'd0}) - $signed({1'b0, pipe1_1[1]});//Cb=-11058R-21710G+32768B+8388608
    pipe2[2] <= $signed({1'b0, pipe0_2[0], 15'd0}) - $signed({1'b0, pipe1_1[2]});//Cr=32768R-27439G-5329B+8388608
end

always @(posedge clk ) begin
    if(pipe2[0][25:16] >= 10'd255)begin
        pipe3[0] <= 8'd255;
    end
    else begin
        pipe3[0] <= pipe2[0][23:16] + pipe2[0][15];
    end
end

always @(posedge clk ) begin
    if(pipe2[1][25])begin
        pipe3[1] <= 8'd0;
    end
    else if(pipe2[1][24:16] >= 9'd255)begin
        pipe3[1] <= 8'd255;
    end
    else begin
        pipe3[1] <= pipe2[1][23:16] + pipe2[1][15];
    end
end

always @(posedge clk ) begin
    if(pipe2[2][25])begin
        pipe3[2] <= 8'd0;
    end
    else if(pipe2[2][24:16] >= 9'd255)begin
        pipe3[2] <= 8'd255;
    end
    else begin
        pipe3[2] <= pipe2[2][23:16] + pipe2[2][15];
    end
end

endmodule