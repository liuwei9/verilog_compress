module jpeg_in_buf #(
    parameter IMG_H = 1024,
    parameter IMG_W = 8   
) (
    input                           clk         ,
    input                           rst         ,

    input [63:0]                    s_data      ,
    input [ 7:0]                    s_data_keep ,
    input                           s_data_valid,
    input                           s_data_last ,
    output                          s_data_ready,
    input                           s_data_done ,

    output [63:0]                   m_data      ,
    output                          m_data_valid,
    output                          m_data_last ,
    input                           m_data_req  ,
    output                          m_data_end  
);

genvar i;

localparam DP = (IMG_W + 7) / 8;

localparam DP_W = $clog2(DP);

localparam WRITE   = 3'b001;
localparam WAIT    = 3'b010;
localparam READ    = 3'b100;


reg [2:0] curr_state;
reg [2:0] next_state;

reg [1:0] s_data_valid_ff;
reg [1:0] s_data_last_ff ;

reg  [63 : 0]       wdata;
reg  [7:0]          wen  ;
reg  [DP_W - 1 : 0] waddr;
wire [7:0]          ren  ;
reg  [DP_W - 1 : 0] raddr [7:0];
wire [63 : 0]       rdata [7:0];
reg  [2:0]          wcnt ;
reg  [DP_W - 1 : 0] wlen ;

reg  [6:0] rd_cnt;

reg [63:0] s_m_data      ;
reg        s_m_data_valid;
reg        s_m_data_last ;
reg        s_m_data_end  ;

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
            if((s_data_valid_ff[0] & s_data_last_ff[0] & (wcnt == 3'd0)) | s_data_done)begin
                next_state = WAIT;
            end
            else begin
                next_state = WRITE;
            end
        end
        WAIT: begin
            if(m_data_req)begin
                next_state = READ;
            end
            else begin
                next_state = WAIT;
            end
        end
        READ: begin
            if(m_data_end)begin
                next_state = WRITE;
            end
            else begin
                next_state = READ ;
            end
        end
        default: begin
            next_state = WRITE;
        end
    endcase
end

assign s_data_ready = (curr_state == WRITE);

always @(posedge clk ) begin
    if(rst)begin
        s_data_valid_ff <= 2'b0;
        s_data_last_ff  <= 2'b0;
    end
    else begin
        s_data_valid_ff <= {s_data_valid_ff[0:0], s_data_valid};
        s_data_last_ff  <= {s_data_last_ff [0:0], s_data_last };
    end
end

always @(posedge clk ) begin
    if(rst)begin
        wcnt <= 3'd0;
    end
    else begin
        if(s_data_valid & s_data_last)begin
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
        wen[0] <= (s_data_valid & s_data_ready) & (wcnt == 3'd0);
        wen[1] <= (s_data_valid & s_data_ready) & (wcnt == 3'd1);
        wen[2] <= (s_data_valid & s_data_ready) & (wcnt == 3'd2);
        wen[3] <= (s_data_valid & s_data_ready) & (wcnt == 3'd3);
        wen[4] <= (s_data_valid & s_data_ready) & (wcnt == 3'd4);
        wen[5] <= (s_data_valid & s_data_ready) & (wcnt == 3'd5);
        wen[6] <= (s_data_valid & s_data_ready) & (wcnt == 3'd6);
        wen[7] <= (s_data_valid & s_data_ready) & (wcnt == 3'd7);
    end
end

always @(posedge clk ) begin
    if(rst)begin
        waddr <= {{DP_W}{1'b0}};
    end
    else begin
        if(|wen)begin
            waddr <= waddr + 1'b1;
        end
        else if(s_data_valid_ff[1] & s_data_last_ff[1])begin
            waddr <= {{DP_W}{1'b0}};
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        wlen <= {{DP_W}{1'b0}};
    end
    else if(s_data_valid_ff[1] & s_data_last_ff[1])begin
        wlen <= waddr;
    end
end

always @(posedge clk ) begin
    wdata <= s_data;
end


always @(posedge clk ) begin
    if(rst)begin
        rd_cnt <= 7'd0;
    end
    else begin
        if(curr_state == WRITE)begin
            rd_cnt <= 7'd0;
        end
        else if(curr_state == READ)begin
            if(rd_cnt == 7'd65)begin
                rd_cnt <= 7'd0;
            end
            else begin
                rd_cnt <= rd_cnt + 7'd1;
            end 
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        s_m_data_end <= 1'b0;
    end
    else begin
        s_m_data_end <= (raddr[0] == wlen) && (rd_cnt == 7'd65);
    end
end

assign ren[0] = rd_cnt == 6'd1;
assign ren[1] = rd_cnt == 6'd2;
assign ren[2] = rd_cnt == 6'd3;
assign ren[3] = rd_cnt == 6'd4;
assign ren[4] = rd_cnt == 6'd5;
assign ren[5] = rd_cnt == 6'd6;
assign ren[6] = rd_cnt == 6'd7;
assign ren[7] = rd_cnt == 6'd8;

generate
    for (i = 0; i < 8; i = i+1) begin : LOOP_RADDR
        always @(posedge clk ) begin
            if(rst)begin
                raddr[i] <= {{DP_W}{1'b0}};
            end
            else begin
                if(curr_state == WRITE)begin
                    raddr[i] <= {{DP_W}{1'b0}};
                end
                else if(ren[i])begin
                    raddr[i] <= raddr[i] + 1'b1;
                end
            end
        end
    end
endgenerate

always @(posedge clk ) begin
    s_m_data <= rd_cnt == 6'd3  ? rdata[0] :
                rd_cnt == 6'd4  ? rdata[1] :
                rd_cnt == 6'd5  ? rdata[2] :
                rd_cnt == 6'd6  ? rdata[3] :
                rd_cnt == 6'd7  ? rdata[4] :
                rd_cnt == 6'd8  ? rdata[5] :
                rd_cnt == 6'd9  ? rdata[6] :
                rd_cnt == 6'd10 ? rdata[7] : 64'd0;
    s_m_data_last  <= rd_cnt == 6'd10;
    s_m_data_valid <= (rd_cnt >= 6'd3) && (rd_cnt <= 6'd10);
end

assign m_data       = s_m_data      ;
assign m_data_valid = s_m_data_valid;
assign m_data_last  = s_m_data_last ;
assign m_data_end   = s_m_data_end  ;

generate
    for (i = 0; i < 8; i = i+1) begin : LOOP_MEM
        spram #(
            .DP (DP),
            .DW (64) 
        ) spram_inst (
            .clk   (clk     ),
            .wdata (wdata   ),
            .wen   (wen[i]  ),
            .waddr (waddr   ),
            .ren   (ren[i]  ),
            .raddr (raddr[i]),
            .rdata (rdata[i])
        );
    end
endgenerate
    
endmodule