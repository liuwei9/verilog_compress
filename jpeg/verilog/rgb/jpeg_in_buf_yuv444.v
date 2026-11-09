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
reg [4:0]  s_data_valid_ff;
reg [4:0]  s_data_last_ff ; 

reg  [23 : 0]       wdata;
reg  [7:0]          wen  ;
reg  [DP_W - 1 : 0] waddr;
reg                 ren  ;
reg  [DP_W - 1 : 0] raddr;
wire [23 : 0]       rdata [7:0];
reg  [2:0]          wcnt ;
reg  [DP_W - 1 : 0] wlen ;

reg [1:0] ren_ff;
reg [63:0] rdata_t [7:0];

reg [5:0] rd_cnt;
reg [5:0] rd_cnt_ff [1:0];
reg [1:0] r_time;
reg [1:0] r_time_ff;
reg       r_row_last;
reg [1:0] r_row_last_ff;

reg m_valid;
reg m_last ;
reg [7:0] m_valid_ff;
reg [7:0] m_last_ff ;

reg [63:0] m_data_r      ;
reg        m_data_valid_r;
reg        m_data_last_r ;
reg        m_data_user_r ;
reg        m_data_end_r  ;


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

always @(posedge clk ) begin
    if(rst)begin
        s_data_valid_ff <= 5'd0;
        s_data_last_ff  <= 5'd0;
    end
    else begin
        s_data_valid_ff <= {s_data_valid_ff[3:0], s_data_valid};
        s_data_last_ff  <= {s_data_last_ff [3:0], s_data_last };
    end
end

genvar i;
localparam DP   = IMG_W;
localparam DP_W = $clog2(DP);

localparam WRITE   = 2'b01;
localparam READ    = 2'b10;


reg [2:0] curr_state;
reg [2:0] next_state;

always @(posedge clk ) begin
    if(rst)begin
        curr_state <= WRITE;
    end
    else begin
        curr_state <= next_state;
    end
end

always @(*) begin
    case (curr_state)
        WRITE: begin
            if((s_data_valid_ff[4] & s_data_last_ff[4] & (wcnt == 3'd0)) | s_data_done)begin
                next_state = READ;
            end
            else begin
                next_state =WRITE;
            end
        end 
        READ: begin
            
        end
        default: begin
            next_state = WRITE;
        end
    endcase
end

assign s_data_ready = (curr_state == WRITE);

always @(posedge clk ) begin
    if(rst)begin
        wcnt <= 3'd0;
    end
    else begin
        if(s_data_valid_ff[3] & s_data_last_ff[3])begin
            wcnt <= wcnt + 1'b1;
        end
        else if(curr_state == READ)begin
            wcnt <= 3'd0;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        wen <= 8'b0;
    end
    else begin
        wen[0] <= (s_data_valid_ff[3] & s_data_last_ff[3]) & (wcnt == 3'd0);
        wen[1] <= (s_data_valid_ff[3] & s_data_last_ff[3]) & (wcnt == 3'd1);
        wen[2] <= (s_data_valid_ff[3] & s_data_last_ff[3]) & (wcnt == 3'd2);
        wen[3] <= (s_data_valid_ff[3] & s_data_last_ff[3]) & (wcnt == 3'd3);
        wen[4] <= (s_data_valid_ff[3] & s_data_last_ff[3]) & (wcnt == 3'd4);
        wen[5] <= (s_data_valid_ff[3] & s_data_last_ff[3]) & (wcnt == 3'd5);
        wen[6] <= (s_data_valid_ff[3] & s_data_last_ff[3]) & (wcnt == 3'd6);
        wen[7] <= (s_data_valid_ff[3] & s_data_last_ff[3]) & (wcnt == 3'd7);
    end
end

always @(posedge clk ) begin
    if(rst)begin
        waddr <= {{DP_W}{1'b0}};
    end
    else begin
        if(|wen)begin           
            if(s_data_valid_ff[4] & s_data_last_ff[4])begin
                waddr <= {{DP_W}{1'b0}};
            end
            else begin
                waddr <= waddr + 1'b1;
            end
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        wlen <= {{DP_W}{1'b0}};
    end
    else if(s_data_valid_ff[4] & s_data_last_ff[4])begin
        wlen <= waddr;
    end
end

always @(posedge clk ) begin
    wdata <= {pipe3[3], pipe3[2], pipe3[1]}; //{Cr, Cb, Y}
end

always @(posedge clk ) begin
    if(rst)begin
        rd_cnt <= 6'd0;
    end
    else begin
        if(curr_state == WRITE)begin
            rd_cnt <= 6'd0;
        end
        else if(curr_state == READ)begin
            rd_cnt <= rd_cnt + 6'd1;
        end
    end
end

always @(posedge clk ) begin
    rd_cnt_ff[0] <= rd_cnt;
    rd_cnt_ff[1] <= rd_cnt_ff[0];
end

always @(posedge clk ) begin
    if(rst)begin
        ren <= 1'b0;
    end
    else begin
        if((rd_cnt >= 6'd0) && (rd_cnt <= 6'd7) && (curr_state == READ) && (r_time != 2'b11))begin
            ren <= 1'b1;
        end
        else begin
            ren <= 1'b0;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        raddr <= {{DP_W}{1'b0}};
    end
    else begin
        if(ren)begin
            raddr <= raddr + 1'b1;
        end
        else if((raddr == wlen) && (&rd_cnt))begin
            raddr <= {{DP_W}{1'b0}};
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        r_time <= 2'd0;
    end
    else begin
        if(curr_state == WRITE)begin
            r_time <= 2'd0;
        end
        else begin
            if((raddr == wlen) && (&rd_cnt))begin
                r_time <= r_time + 2'd1;
            end
        end
    end
end

always @(posedge clk ) begin
    r_time_ff <= r_time;
end

always @(posedge clk ) begin
    if(rst)begin
        r_row_last <= 1'd0;
    end
    else begin
        if((raddr == wlen) && (&rd_cnt))begin
            r_row_last <= 1'd1;
        end
        else begin
            r_row_last <= 1'd0;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        ren_ff <= 2'b0;
        r_row_last_ff <= 2'd0;
    end
    else begin
        ren_ff <= {ren_ff[0:0], ren};
        r_row_last_ff <= {r_row_last_ff[0:0], r_row_last};
    end
end

generate
    for (i = 0; i < 8; i = i+1) begin : LOOP_RD
        always @(posedge clk ) begin
            if(ren_ff[1])begin
                case (r_time_ff)
                    2'b00: begin
                        rdata_t[i] <= {rdata[i][7:0], rdata_t[63:8]};
                    end
                    2'b01: begin
                        rdata_t[i] <= {rdata[i][15:8], rdata_t[63:8]};
                    end
                    2'b10: begin
                        rdata_t[i] <= {rdata[i][23:16], rdata_t[63:8]};
                    end
                    default: begin
                        rdata_t[i] <= {rdata[i][7:0], rdata_t[63:8]};
                    end
                endcase
            end
        end
    end
endgenerate

always @(posedge clk ) begin
    if(rst)begin
        m_valid <= 1'b0;
    end
    else begin
        if(ren)begin
            m_valid <= 1'b1;
        end
        else if((raddr == wlen) && (&rd_cnt) && (r_time == 2'b10))begin
            m_valid <= 1'b0;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        m_last <= 1'b0;
    end
    else begin
        if(&rd_cnt)begin
            m_last <= 1'b1;
        end
        else begin
            m_last <= 1'b0;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        m_valid_ff <= 8'd0;
        m_last_ff  <= 8'd0;
    end
    else begin
        m_valid_ff <= {m_valid_ff[6:0], m_valid};
        m_last_ff  <= {m_last_ff[6:0],  m_last };
    end
end

always @(posedge clk ) begin
    case (rd_cnt_ff[2])
        6'd7:begin
            m_data_r <= rdata_t[0];
        end 
        6'd15:begin
            m_data_r <= rdata_t[1];
        end
        6'd23:begin
            m_data_r <= rdata_t[2];
        end
        6'd31:begin
            m_data_r <= rdata_t[3];
        end
        6'd39:begin
            m_data_r <= rdata_t[4];
        end
        6'47:begin
            m_data_r <= rdata_t[5];
        end
        6'd55:begin
            m_data_r <= rdata_t[6];
        end
        default: begin
            m_data_r <= m_data_r;
        end
    endcase
end

always @(posedge clk ) begin
    if(rst)begin
        m_data_valid_r <= 1'b0;
        m_data_last_r  <= 1'b0;
    end
    else begin
        m_data_valid_r <= m_valid_ff[7];
        m_data_last_r  <= m_last_ff [7];
    end
end

assign m_data       = m_data_r      ;
assign m_data_valid = m_data_valid_r;
assign m_data_last  = m_data_last_r ;

generate
    for (i = 0; i < 8; i = i+1) begin : LOOP_MEM
        spram #(
            .DP (DP),
            .DW (24) 
        ) spram_inst (
            .clk   (clk     ),
            .wdata (wdata   ),
            .wen   (wen[i]  ),
            .waddr (waddr   ),
            .ren   (ren     ),
            .raddr (raddr   ),
            .rdata (rdata[i])
        );
    end
endgenerate


endmodule