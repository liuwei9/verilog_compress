module jpeg_huffman (
    input          clk              ,
    input          rst              ,

    input          jpeg_start       ,

    input  [11:0]  s_data           ,
    input  [5:0]   s_zero_cnt       ,
    input          s_data_valid     ,
    input          s_frame_end      ,
    input          s_data_last      ,

    output [3:0]   dc_raddr         ,
    output [7:0]   ac_raddr         ,

    input  [4:0]   ac_len           ,
    input  [15:0]  ac_code          ,
    input  [3:0]   dc_len           ,
    input  [8:0]   dc_code          ,

    output [4:0]   m_len            ,
    output [15:0]  m_code           ,
    output [3:0]   m_bits           ,
    output [11:0]  m_data           ,
    output         m_data_valid     ,
    output         m_frame_end      ,
    output         m_data_last       
);

wire [18:0] fifo_s_data ;
wire        fifo_s_valid;
wire        fifo_s_ready;
wire [18:0] fifo_m_data ;
wire        fifo_m_valid;
wire        fifo_m_ready;

wire [11:0] t_data      ;
wire [5:0]  t_zero_cnt  ;
wire        t_data_last ;

reg         calc_state;

reg [11:0] prev;
reg first_flag;
reg [6:0] first_flag_ff;
reg [6:0] t_valid_ff;
reg [6:0] t_last_ff ;
reg       last_flag;
reg       last_data;

reg [11:0] pipe_1;
reg [11:0] pipe_2_0;
reg [11:0] pipe_2_1;
reg [11:0] pipe_2_1_ff [2:0];

reg [3:0]  n_bits;//bits - 1
reg [3:0]  s_dc_raddr;
reg [7:0]  s_ac_raddr;
reg [5:0]  zero_cnt ;
reg [5:0]  zero_cnt_ff [1:0];
reg        zero_valid;
reg [3:0]  zero_valid_ff;
reg [3:0]  n_bits_ff [1:0];
reg [1:0]  zero_state; //00->zero<16, 01->zero>=16, 10->last&zero>0&data==0, 
reg [1:0]  zero_state_ff [3:0];
reg        zero_16;

reg m_frame_end_flag;
reg m_frame_end_r   ;

assign fifo_m_ready = !calc_state;
assign fifo_s_data  = {s_data, s_zero_cnt, s_data_last};
assign fifo_s_valid = s_data_valid;
assign t_data_last  = fifo_m_data[0] & fifo_m_valid;
assign t_zero_cnt   = fifo_m_data[6:1];
assign t_data       = fifo_m_data[18:7];

always @(posedge clk ) begin
    if(rst)begin
        calc_state <= 1'b0;
    end
    else begin
        if((fifo_m_ready & fifo_m_valid) && (((t_zero_cnt == 6'd16) && (t_data != 12'd0)) || ((!t_data_last) & (t_zero_cnt > 6'd16))))begin
            calc_state <= 1'b1;
        end
        else if(zero_cnt == 5'd0)begin
            calc_state <= 1'b0;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        first_flag <= 1'b1;
    end
    else begin
        if(fifo_m_valid & fifo_m_ready)begin
            if(t_data_last)begin
                first_flag <= 1'b1;
            end
            else begin
                first_flag <= 1'b0;
            end
        end
    end
end


always @(posedge clk ) begin
    if(jpeg_start)begin
        prev <= 12'd0;
    end
    else begin
        if(fifo_m_valid & fifo_m_ready & first_flag)begin
            prev <= t_data;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        first_flag_ff   <= 7'd0;
        t_valid_ff <= 7'd0;
        t_last_ff  <= 7'd0;
    end
    else begin
        first_flag_ff <= {first_flag_ff[5:0], first_flag};
        t_valid_ff    <= {t_valid_ff[5:0], fifo_m_valid & fifo_m_ready};
        t_last_ff     <= {t_last_ff[5:0], last_data};
    end
end

always @(posedge clk ) begin
    if(fifo_m_valid & fifo_m_ready)begin
        if(t_data_last & (t_data == 12'd0))begin
            zero_cnt <= 16'd0;
        end
        else begin
            zero_cnt <= t_zero_cnt;
        end       
    end
    else if(zero_cnt >= 6'd16)begin
        zero_cnt <= zero_cnt - 6'd16;
    end
    else if(zero_cnt > 6'd0)begin
        zero_cnt <= 6'd0;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        last_flag <= 1'b0;
    end
    else begin
        if(fifo_m_valid & fifo_m_ready & t_data_last & (t_data != 12'd0) & (t_zero_cnt >= 6'd16))begin
            last_flag <= 1'b1;
        end
        else if(last_data)begin
            last_flag <= 1'b0;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        last_data <= 1'b0;
    end
    else begin
        if(fifo_m_valid & fifo_m_ready)begin
            if(t_data_last & ((t_data == 12'd0) || (t_zero_cnt < 6'd16)))begin
                last_data <= 1'b1;
            end
        end
        else if(last_flag & (zero_cnt < 6'd32))begin
            last_data <= 1'b1;
        end
        else begin
            last_data <= 1'b0;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        zero_16 <= 1'b0;
    end
    else begin
        if(fifo_m_valid & fifo_m_ready & (t_data != 12'd0) & (t_zero_cnt == 6'd16))begin
            zero_16 <= 1'b1;
        end
        else begin
            zero_16 <= 1'b0;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        zero_valid <= 1'b0;
    end
    else begin
        zero_valid <= (fifo_m_valid & fifo_m_ready & (!first_flag)) | (zero_cnt > 6'd16) | zero_16;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        zero_valid_ff <= 3'd0;
    end
    else begin
        zero_valid_ff <= {zero_valid_ff[2:0], zero_valid};
    end
end

always @(posedge clk ) begin
    zero_cnt_ff[0] <= zero_cnt;
    zero_cnt_ff[1] <= zero_cnt_ff[0];
end

always @(posedge clk ) begin
    if(fifo_m_valid & fifo_m_ready)begin
        if(t_data_last && (t_data == 12'd0))begin
            zero_state <= 2'b10;
        end
        else if(t_zero_cnt >= 6'd16)begin
            zero_state <= 2'b01;
        end
        else begin
            zero_state <= 2'b00;
        end
    end
    else if(zero_cnt >= 6'd32)begin
        zero_state <= 2'b01;
    end
    else begin
        zero_state <= 2'b00;
    end
end

always @(posedge clk ) begin
    zero_state_ff[0] <= zero_state;
    zero_state_ff[1] <= zero_state_ff[0];
    zero_state_ff[2] <= zero_state_ff[1];
    zero_state_ff[3] <= zero_state_ff[2];
end

always @(posedge clk ) begin
    if(fifo_m_valid & fifo_m_ready)begin
        if(first_flag)begin
            pipe_1 <= $signed(t_data) - $signed(prev);
        end
        else begin
            pipe_1 <= t_data;
        end 
    end
end

always @(posedge clk ) begin
    if(pipe_1[11])begin
        pipe_2_0[10:0] <= (~pipe_1[10:0]) + 11'd1;
        pipe_2_0[11]   <= 1'b0;
        pipe_2_1 <= $signed(pipe_1) - $signed(12'd1);
    end
    else begin
        pipe_2_0 <= pipe_1;
        pipe_2_1 <= pipe_1;
    end
end

always @(posedge clk ) begin
    pipe_2_1_ff[0] <= pipe_2_1      ;
    pipe_2_1_ff[1] <= pipe_2_1_ff[0];
    pipe_2_1_ff[2] <= pipe_2_1_ff[1] & ({12{1'b1}} >> (4'd12 - n_bits_ff[0]));
end

always @(posedge clk ) begin
    case (1'b1)
        pipe_2_0[10]: begin
            n_bits <= 4'd11;
        end 
        pipe_2_0[9]: begin
            n_bits <= 4'd10;
        end 
        pipe_2_0[8]: begin
            n_bits <= 4'd9;
        end 
        pipe_2_0[7]: begin
            n_bits <= 4'd8;
        end 
        pipe_2_0[6]: begin
            n_bits <= 4'd7;
        end 
        pipe_2_0[5]: begin
            n_bits <= 4'd6;
        end 
        pipe_2_0[4]: begin
            n_bits <= 4'd5;
        end 
        pipe_2_0[3]: begin
            n_bits <= 4'd4;
        end 
        pipe_2_0[2]: begin
            n_bits <= 4'd3;
        end 
        pipe_2_0[1]: begin
            n_bits <= 4'd2;
        end 
        pipe_2_0[0]: begin
            n_bits <= 4'd1;
        end 
        default: begin
            n_bits <= 4'd0;
        end
    endcase
end

always @(posedge clk ) begin
    if(t_valid_ff[2] & first_flag_ff[2])begin
        s_dc_raddr <= n_bits;
    end
end

always @(posedge clk ) begin
    case (zero_state_ff[1])
        2'b00: begin
            s_ac_raddr <= {zero_cnt_ff[1], n_bits};
        end 
        2'b01: begin
            s_ac_raddr <= 8'hF0;
        end
        2'b10: begin
            s_ac_raddr <= 8'h00;
        end
        default: begin
            s_ac_raddr <= 8'h00;
        end
    endcase
end

always @(posedge clk ) begin
    n_bits_ff[0] <= n_bits;
    n_bits_ff[1] <= n_bits_ff[0];
end

always @(posedge clk ) begin
    if(rst)begin
        m_frame_end_flag <= 1'b0;
    end
    else begin
        if(s_frame_end)begin
            m_frame_end_flag <= 1'b1;
        end
        else if(m_frame_end)begin
            m_frame_end_flag <= 1'b0;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        m_frame_end_r <= 1'b0;
    end
    else begin
        if(m_frame_end_flag & t_last_ff[2])begin
            m_frame_end_r <= 1'b1;
        end
        else begin
            m_frame_end_r <= 1'b0;
        end
    end
end

assign m_len  = first_flag_ff[4] ? {1'b0, dc_len }: ac_len ;
assign m_code = first_flag_ff[4] ? {4'b0, dc_code}: ac_code;
assign m_bits = zero_state_ff[3] == 2'b00 ? n_bits_ff[1]   :  4'd0;
assign m_data = zero_state_ff[3] == 2'b00 ? pipe_2_1_ff[2] : 12'd0;
assign m_data_valid = (t_valid_ff[4] & first_flag_ff[4]) | zero_valid_ff[3];
assign m_frame_end  = m_frame_end_r;
assign m_data_last  = t_last_ff[3];

assign dc_raddr = s_dc_raddr;
assign ac_raddr = s_ac_raddr;

stream_fifo #(
    .DP         (128),
    .WD         (19 )
) stream_fifo_inst (
    .clk        (clk         ),
    .rst        (rst         ),
    .s_data     (fifo_s_data ),
    .s_valid    (fifo_s_valid),
    .s_ready    (fifo_s_ready),

    .m_data     (fifo_m_data ),
    .m_valid    (fifo_m_valid),
    .m_ready    (fifo_m_ready) 
);


endmodule