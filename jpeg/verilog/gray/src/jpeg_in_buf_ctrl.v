module jpeg_in_buf #(
    parameter IMG_H = 1024,
    parameter IMG_W = 8   
) (
    input                           clk         ,
    input                           rst         ,

    input [$clog2(IMG_H) - 1 : 0]   cfg_img_h   ,
    input [$clog2(IMG_W) - 1 : 0]   cfg_img_w   ,
    input [31:0]                    cfg_img_addr,
    input                           jpeg_start  ,

    input [63:0]                    s_data      ,
    input [ 7:0]                    s_data_keep ,
    input                           s_data_valid,
    input                           s_data_last ,
    output                          s_data_ready,
    input                           s_data_done ,

    output [31:0]                   s_cmd_addr  ,
    output [31:0]                   s_cmd_len   ,
    output                          s_cmd_valid ,
    input                           s_cmd_ready ,

    output [63:0]                   m_data      ,
    output                          m_data_valid,
    output                          m_data_last ,
    input                           m_data_req  ,
    output                          m_data_end  
);

localparam IMG_H_W = $clog2(IMG_H);

localparam IDLE = 4'b0001;
localparam ADDR = 4'b0010;
localparam DATA = 4'b0100;
localparam WAIT = 4'b1000;

reg [3:0] curr_state;
reg [3:0] next_state;

reg [IMG_H_W - 1 : 0] row_cnt;

reg [31:0] s_cmd_addr_r ;
reg [31:0] s_cmd_len_r  ;
reg        s_cmd_valid_r;

reg s_data_done_r;

reg w_ping_t;
reg w_ping;
reg r_ping;

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
                next_state = ADDR;
            end
            else begin
                next_state = IDLE;
            end
        end
        ADDR: begin
            if(s_cmd_ready & s_cmd_valid)begin
                next_state = DATA;
            end
            else begin
                next_state = ADDR;
            end
        end
        DATA: begin
            if(s_data_valid & s_data_last & s_data_ready)begin
                next_state = WAIT;
            end
            else begin
                next_state = DATA;
            end
        end
        WAIT: begin
            if(row_cnt == cfg_img_h)begin
                next_state = IDLE;
            end
            else begin
                next_state = ADDR;
            end
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

always @(posedge clk ) begin
    if(rst)begin
        s_cmd_valid_r <= 1'b0;
    end
    else begin
        if((curr_state != ADDR) && (next_state == ADDR))begin
            s_cmd_valid_r <= 1'b1;
        end
        else begin
            if(s_cmd_valid_r & s_cmd_ready)begin
                s_cmd_valid_r <= 1'b0;
            end
        end
    end
end

always @(posedge clk ) begin
    s_cmd_len_r <= cfg_img_w;
end

always @(posedge clk ) begin
    if(curr_state == IDLE)begin
        s_cmd_addr_r <= cfg_img_addr;
    end
    else if(s_cmd_valid & s_cmd_ready)begin
        s_cmd_addr_r <= s_cmd_addr_r + cfg_img_w;
    end
end

always @(posedge clk ) begin
    if(curr_state == IDLE)begin
        row_cnt <= {{IMG_H_W}1'b0};
    end
    else begin
        if((curr_state == DATA) && (next_state == WAIT))begin
            row_cnt <= row_cnt + 1'b1;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        s_data_done_r <= 1'b0;
    end
    else begin
        if((curr_state == WAIT) && (next_state == IDLE))begin
            s_data_done_r <= 1'b1;
        end
        else begin
            s_data_done_r <= 1'b0;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        w_ping_t <= 1'b0;
    end
    else begin
        if((curr_state == WAIT) && (next_state != WAIT))begin
            w_ping_t <= !w_ping_t;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        w_ping <= 1'b0;
    end
    else begin
        w_ping_t <= w_ping;
    end
end



endmodule