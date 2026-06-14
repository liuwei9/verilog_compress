module jpeg_ctrl (
    input          clk                 ,
    input          rst                 ,

    input          jpeg_start          ,

    input [7:0]    jpeg_head_data      ,
    input          jpeg_head_data_valid,
    input          jpeg_head_data_last ,

    input [4:0]    huffman_s_len       ,
    input [15:0]   huffman_s_code      ,
    input [3:0]    huffman_s_bits      ,
    input [11:0]   huffman_s_data      ,
    input          huffman_s_data_valid,
    input          huffman_s_data_last ,

    output [63:0]  m_data              ,
    output [ 7:0]  m_data_keep         ,
    output         m_data_valid        ,
    output         m_data_last         
);

genvar i;

localparam IDLE = 4'b0001;
localparam HEAD = 4'b0010;
localparam WAIT = 4'b0100;
localparam DATA = 4'b1000;

reg [3:0] curr_state;
reg [3:0] next_state;

reg [2:0]  head_cnt  ;
reg [63:0] head_data ;
reg        head_valid;
reg        head_last ;

reg [27:0]  huffman_data_temp;
reg [4:0]   huffman_data_temp_bits;
reg [63:0]  huffman_64;
reg [6:0]   huffman_64_bits;
reg [31:0]  huffman_32;
reg [5:0]   huffman_32_bits;
reg [15:0]  huffman_32_padding      [3:0];
reg [4:0]   huffman_32_padding_bits [3:0];
reg [63:0]  huffman_64_p;
reg [6:0]   huffman_64_p_bits;
reg [127:0] huffman_128;
reg [7:0]   huffman_128_bits;
reg [63:0]  huffman_data;

always @(posedge clk ) begin
    if(rst)begin
        curr_state <= IDLE;
    end
    else begin
        curr_state <= next_state;
    end
end

always @(*) begin
    case (curr_state)
        IDLE: begin
            if(jpeg_start)begin
                next_state = HEAD;
            end
            else begin
                next_state = IDLE;
            end
        end 
        HEAD: begin
            if(jpeg_head_data_last & jpeg_head_data_valid)begin
                next_state = WAIT;
            end
            else begin
                next_state = HEAD;
            end
        end
        WAIT: begin
            
        end
        DATA: begin
            
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

always @(posedge clk ) begin
    if(rst)begin
        head_cnt <= 3'd0;
    end
    else begin
        if(curr_state == IDLE)begin
            head_cnt <= 3'd0;
        end
        else if(jpeg_head_data_valid)begin
            head_cnt <= head_cnt + 3'd1;
        end
    end
end

always @(posedge clk ) begin
    head_data <= {head_data[55:0], jpeg_head_data};
end

always @(posedge clk ) begin
    if(rst)begin
        head_valid <= 1'b0;
        head_last  <= 1'b0;
    end
    else begin
        head_valid <= jpeg_head_data_valid & (&head_cnt);
        head_last  <= jpeg_head_data_last;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        huffman_data_temp_bits <=  5'd0;
        huffman_data_temp      <= 28'd0;
    end
    else if(huffman_s_data_valid)begin
        huffman_data_temp_bits <= huffman_s_len + huffman_s_bits;
        huffman_data_temp      <= (huffman_s_data << huffman_s_len) | huffman_s_code;
    end
    else begin
        huffman_data_temp_bits <=  5'd0;
        huffman_data_temp      <= 28'd0;
    end   
end

always @(posedge clk ) begin
    if(rst)begin
        huffman_64 <= 64'd0;
    end
    else if(huffman_64_bits >= 7'd32)begin
        huffman_64 <= (huffman_data_temp << (huffman_64_bits - 7'd32)) | (huffman_64 >> 7'd32);
    end
    else begin
        huffman_64 <= (huffman_data_temp << huffman_64_bits) | huffman_64;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        huffman_64_bits <= 7'd0;
    end
    else if(huffman_64_bits >= 7'd32)begin
        huffman_64_bits <= huffman_64_bits - 7'd32 + huffman_data_temp_bits;
    end
    else begin
        huffman_64_bits <= huffman_64_bits + huffman_data_temp_bits;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        huffman_32 <= 32'd0;
    end
    else begin
        huffman_32 <= huffman_64[31:0];
    end    
end

always @(posedge clk ) begin
    if(rst)begin
        huffman_32_bits <= 6'd0;
    end
    else begin
        if(huffman_64_bits >= 7'd32)begin
            huffman_32_bits <= 6'd32;
        end
        else begin
            huffman_32_bits <= 6'd0;
        end
    end
end

generate
    for (i = 0; i < 4; i = i+1) begin : LOOP_PADDING
        always @(posedge clk ) begin
            if(rst)begin
                huffman_32_padding[i] <= 16'd0;
            end
            else if(huffman_32[(i*8) +: 8] == 8'hFF)begin
                huffman_32_padding[i] <= {huffman_32[(i*8) +: 8], 8'd0};
            end
            else begin
                huffman_32_padding[i] <= {8'd0, huffman_32[(i*8) +: 8]};
            end
        end
    end
endgenerate

always @(posedge clk ) begin
    if(rst)begin
        huffman_32_padding_bits[0] <= 5'd0;
    end
    else if(huffman_32_bits >= 6'd8)begin
        if(huffman_32[7:0] == 8'hFF)begin
            huffman_32_padding_bits[0] <= 5'd16;
        end
        else begin
            huffman_32_padding_bits[0] <= 5'd8;
        end
    end
    else begin
        huffman_32_padding_bits[0] <= huffman_32_bits;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        huffman_32_padding_bits[1] <= 5'd0;
    end
    else if(huffman_32_bits > 6'd8)begin
        if(huffman_32[15:8] == 8'hFF)begin
            huffman_32_padding_bits[1] <= 5'd16;
        end
        else begin
            huffman_32_padding_bits[1] <= huffman_32_bits - 5'd8;
        end
    end
    else begin
        huffman_32_padding_bits[1] <= 5'd0;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        huffman_32_padding_bits[2] <= 5'd0;
    end
    else if(huffman_32_bits > 6'd16)begin
        if(huffman_32[23:16] == 8'hFF)begin
            huffman_32_padding_bits[2] <= 5'd16;
        end
        else begin
            huffman_32_padding_bits[2] <= huffman_32_bits - 5'd16;
        end
    end
    else begin
        huffman_32_padding_bits[2] <= 5'd0;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        huffman_32_padding_bits[3] <= 5'd0;
    end
    else if(huffman_32_bits > 6'd24)begin
        if(huffman_32[31:24] == 8'hFF)begin
            huffman_32_padding_bits[3] <= 5'd16;
        end
        else begin
            huffman_32_padding_bits[3] <= huffman_32_bits - 5'd24;
        end
    end
    else begin
        huffman_32_padding_bits[3] <= 5'd0;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        huffman_64_p <= 64'd0;
    end
    else begin
        huffman_64_p <= huffman_32_padding[0] | 
                   (huffman_32_padding[1] << huffman_32_padding_bits[0]) | 
                   (huffman_32_padding[2] << huffman_32_padding_bits[1]) |
                   (huffman_32_padding[3] << huffman_32_padding_bits[2]) ;
    end    
end

always @(posedge clk ) begin
    if(rst)begin
        huffman_64_p_bits <= 7'd0;
    end
    else begin
        huffman_64_p_bits <= huffman_32_padding_bits[0] + huffman_32_padding_bits[1] + huffman_32_padding_bits[2] + huffman_32_padding_bits[3];
    end   
end

always @(posedge clk ) begin
    if(rst)begin
        huffman_128 <= 128'd0;
    end
    else if(huffman_128_bits >= 8'd64)begin
        huffman_128 <= (huffman_64_p << (huffman_128_bits - 8'd64)) | (huffman_128 >> 8'd64);
    end
    else begin
        huffman_128 <= (huffman_64_p << huffman_128_bits) | huffman_128;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        huffman_128_bits <= 8'd0;
    end
    else if(huffman_128_bits >= 8'd64)begin
        huffman_128_bits <= huffman_128_bits + huffman_64_p_bits - 8'd64;
    end
    else begin
        huffman_128_bits <= huffman_128_bits + huffman_64_p_bits;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        huffman_data <= 64'd0;
    end
    else begin
        huffman_data <= huffman_128[63:0];
    end   
end


assign m_data       = head_valid ? head_data : 64'd0;
assign m_data_keep  = head_valid ? 8'b1111_1111 : 8'd0;
assign m_data_valid = head_valid ;
assign m_data_last  = head_valid ? head_last : 1'b0;
    
endmodule