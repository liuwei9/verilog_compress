module jpeg_huffman (
    input          clk              ,
    input          rst              ,

    input          jpeg_start       ,

    input  [11:0]  s_data           ,
    input  [5:0]   s_zero_cnt       ,
    input          s_data_valid     ,
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

reg [11:0] pipe_1;
reg [11:0] pipe_2_0;
reg [11:0] pipe_2_1;
reg [11:0] pipe_2_1_ff [2:0];

reg [3:0]  n_bits;//bits - 1
reg [3:0]  s_dc_raddr;
reg [3:0]  s_ac_raddr;
reg [5:0]  zero_cnt ;
reg        zero_valid;
reg        zero_valid_ff;
reg [3:0]  n_bits_ff [1:0];

assign fifo_m_ready = !calc_state;
assign fifo_s_data  = {s_data, s_zero_cnt, s_data_last};
assign fifo_s_valid = s_data_valid;
assign t_data_last  = fifo_m_data[0];
assign t_zero_cnt   = fifo_m_data[6:1];
assign t_data       = fifo_m_data[18:7];

always @(posedge clk ) begin
    if(rst)begin
        calc_state <= 1'b0;
    end
    else begin
        if(fifo_m_ready & fifo_m_valid & (!t_data_last) & (t_zero_cnt > 6'd16))begin
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
        t_last_ff     <= {t_last_ff[5:0], t_data_last};
    end
end

always @(posedge clk ) begin
    if(fifo_m_valid & fifo_m_ready)begin
        zero_cnt <= t_zero_cnt;
    end
    else if(zero_cnt >= 5'd16)begin
        zero_cnt <= zero_cnt - 5'd16;
    end
    else if(zero_cnt > 5'd0)begin
        zero_cnt <= 5'd0;
    end
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
        pipe_2_0 <= (~pipe_1[10:0]) + 12'd1;
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
    pipe_2_1_ff[2] <= pipe_2_1_ff[1];
end

always @(posedge clk ) begin
    case (1'b1)
        pipe_2_0[10]: begin
            n_bits <= 4'd10;
        end 
        pipe_2_0[9]: begin
            n_bits <= 4'd9;
        end 
        pipe_2_0[8]: begin
            n_bits <= 4'd8;
        end 
        pipe_2_0[7]: begin
            n_bits <= 4'd7;
        end 
        pipe_2_0[6]: begin
            n_bits <= 4'd6;
        end 
        pipe_2_0[5]: begin
            n_bits <= 4'd5;
        end 
        pipe_2_0[4]: begin
            n_bits <= 4'd4;
        end 
        pipe_2_0[3]: begin
            n_bits <= 4'd3;
        end 
        pipe_2_0[2]: begin
            n_bits <= 4'd2;
        end 
        pipe_2_0[1]: begin
            n_bits <= 4'd1;
        end 
        pipe_2_0[0]: begin
            n_bits <= 4'd0;
        end 
        default: begin
            n_bits <= 4'd0;
        end
    endcase
end

always @(posedge clk ) begin
    if(s_data_valid_ff[2] & first_flag_ff[2])begin
        s_dc_raddr <= n_bits;
    end
end



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