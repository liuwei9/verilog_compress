module jpeg_in_buf_ctrl #(
    parameter IMG_H = 1024,
    parameter IMG_W = 8   
) (
    input                           clk              ,
    input                           rst              ,

    input [$clog2(IMG_H) - 1 : 0]   cfg_img_h        ,
    input [$clog2(IMG_W) - 1 : 0]   cfg_img_w        ,
    input                           jpeg_start       ,

    input [63:0]                    s_data           ,
    input [ 7:0]                    s_data_keep      ,
    input                           s_data_valid     ,
    input                           s_data_last      ,
    output                          s_data_ready     ,

    output [63:0]                   m_data           ,
    output                          m_data_valid     ,
    output                          m_data_last      ,
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
    input                           ping_m_data_user ,
    output                          ping_m_data_req  ,
    input                           ping_m_data_end  ,

    input [63:0]                    pang_m_data      ,
    input                           pang_m_data_valid,
    input                           pang_m_data_last ,
    input                           pang_m_data_user ,
    output                          pang_m_data_req  ,
    input                           pang_m_data_end  
);

localparam IMG_H_W = $clog2(IMG_H);

localparam IDLE = 3'b001;
localparam DATA = 3'b010;
localparam WAIT = 3'b100;

reg [2:0] curr_state;
reg [2:0] next_state;

reg [IMG_H_W - 1 : 0] row_cnt;

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
                next_state = DATA;
            end
            else begin
                next_state = IDLE;
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
                next_state = DATA;
            end
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

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

endmodule