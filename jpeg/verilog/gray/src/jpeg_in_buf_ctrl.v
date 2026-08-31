module jpeg_in_buf_ctrl #(
    parameter IMG_H = 1024,
    parameter IMG_W = 8   
) (
    input                           clk              ,
    input                           rst              ,

    input [$clog2(IMG_H) - 1 : 0]   cfg_img_h        ,
    input [$clog2(IMG_W) - 1 : 0]   cfg_img_w        ,
    input [31:0]                    cfg_img_addr     ,
    input                           jpeg_start       ,

    input [63:0]                    s_data           ,
    input [ 7:0]                    s_data_keep      ,
    input                           s_data_valid     ,
    input                           s_data_last      ,
    output                          s_data_ready     ,

    output [31:0]                   s_cmd_addr       ,
    output [31:0]                   s_cmd_len        ,
    output                          s_cmd_valid      ,
    input                           s_cmd_ready      ,

    output [63:0]                   m_data           ,
    output                          m_data_valid     ,
    output                          m_data_last      ,
    output                          m_frame_end      ,
    input                           m_data_req       ,

    output [63:0]                   ping_s_data      ,
    output [ 7:0]                   ping_s_data_keep ,
    output                          ping_s_data_valid,
    output                          ping_s_data_last ,
    input                           ping_s_data_ready,
    output                          ping_s_data_done ,

    output [63:0]                   pang_s_data      ,
    output [ 7:0]                   pang_s_data_keep ,
    output                          pang_s_data_valid,
    output                          pang_s_data_last ,
    input                           pang_s_data_ready,
    output                          pang_s_data_done ,

    input [63:0]                    ping_m_data      ,
    input                           ping_m_data_valid,
    input                           ping_m_data_last ,
    output                          ping_m_data_req  ,
    input                           ping_m_data_end  ,

    input [63:0]                    pang_m_data      ,
    input                           pang_m_data_valid,
    input                           pang_m_data_last ,
    output                          pang_m_data_req  ,
    input                           pang_m_data_end  
);

localparam IMG_H_W = $clog2(IMG_H);

localparam IDLE = 4'b0001;
localparam ADDR = 4'b0010;
localparam DATA = 4'b0100;
localparam WAIT = 4'b1000;

reg [3:0] curr_state;
reg [3:0] next_state;

reg [IMG_H_W - 1 : 0] row_cnt;
reg [IMG_H_W - 1 : 0] m_row_num;
reg [IMG_H_W - 1 : 0] m_row_cnt;
reg                   m_frame_end_r;

reg [31:0] s_cmd_addr_r ;
reg [31:0] s_cmd_len_r  ;
reg        s_cmd_valid_r;

reg s_data_done;
wire m_data_end;

reg w_ping_t;
reg w_ping_tt;
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

assign s_cmd_addr  = s_cmd_addr_r ;
assign s_cmd_len   = s_cmd_len_r  ;
assign s_cmd_valid = s_cmd_valid_r;

always @(posedge clk ) begin
    if(curr_state == IDLE)begin
        row_cnt <= {{IMG_H_W}{1'b0}};
    end
    else begin
        if((curr_state == DATA) && (next_state == WAIT))begin
            row_cnt <= row_cnt + 1'b1;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        s_data_done <= 1'b0;
    end
    else begin
        if((curr_state == WAIT) && (next_state == IDLE))begin
            s_data_done <= 1'b1;
        end
        else begin
            s_data_done <= 1'b0;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        w_ping_t <= 1'b0;
    end
    else begin
        if((curr_state == DATA) && (next_state == WAIT) && (&row_cnt[2:0]))begin
            w_ping_t <= !w_ping_t;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        w_ping_tt <= 1'b0;
        w_ping    <= 1'b0;
    end
    else begin
        w_ping_tt <= w_ping_t ;
        w_ping    <= w_ping_tt;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        r_ping <= 1'b0;
    end
    else begin
        if(m_data_end)begin
            r_ping <= !r_ping;
        end
    end
end

assign ping_s_data       = s_data     ;
assign ping_s_data_keep  = s_data_keep;
assign ping_s_data_valid = w_ping == 1'b0 ? s_data_valid : 1'b0;
assign ping_s_data_last  = w_ping == 1'b0 ? s_data_last  : 1'b0;
assign ping_s_data_done  = w_ping == 1'b0 ? s_data_done  : 1'b0;

assign pang_s_data       = s_data     ;
assign pang_s_data_keep  = s_data_keep;
assign pang_s_data_valid = w_ping == 1'b1 ? s_data_valid : 1'b0;
assign pang_s_data_last  = w_ping == 1'b1 ? s_data_last  : 1'b0;
assign pang_s_data_done  = w_ping == 1'b1 ? s_data_done  : 1'b0;

assign s_data_ready = w_ping == 1'b0 ? ping_s_data_ready : pang_s_data_ready;

assign m_data       = r_ping == 1'b0 ? ping_m_data       : pang_m_data      ;
assign m_data_valid = r_ping == 1'b0 ? ping_m_data_valid : pang_m_data_valid;
assign m_data_last  = r_ping == 1'b0 ? ping_m_data_last  : pang_m_data_last ;

assign ping_m_data_req = r_ping == 1'b0 ? m_data_req : 1'b0;
assign pang_m_data_req = r_ping == 1'b1 ? m_data_req : 1'b0;

assign m_data_end = ping_m_data_end | pang_m_data_end;

always @(posedge clk ) begin
    if(rst)begin
        m_row_num <= {{IMG_H_W}{1'b0}};
    end
    else begin
        m_row_num <= cfg_img_h[IMG_H_W - 1 : 3] + (|cfg_img_h[2:0]);
    end
end

always @(posedge clk ) begin
    if(rst)begin
        m_row_cnt <= {{IMG_H_W}{1'b0}};
    end
    else begin
        if(m_frame_end)begin
            m_row_cnt <= {{IMG_H_W}{1'b0}}
        end
        else if(m_data_valid & m_data_last)begin
            m_row_cnt <= m_row_cnt + {{{IMG_H_W - 1}{1'b0}}, 1'b1};
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        m_frame_end_r <= 1'b0;
    end
    else begin
        m_frame_end_r <= m_row_cnt == (m_row_num - {{{IMG_H_W - 1}{1'b0}}, 1'b1});
    end
end

assign m_frame_end = m_frame_end_r & m_data_valid & m_data_last;

endmodule