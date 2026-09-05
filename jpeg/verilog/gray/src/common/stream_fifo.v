module stream_fifo #(
    parameter DP = 1024,
    parameter WD = 8
) (
    input                             clk    ,
    input                             rst    ,
    input        [WD - 1 : 0]         s_data ,
    input                             s_valid,
    output reg                        s_ready,

    output       [WD - 1 : 0]         m_data ,
    output                            m_valid,
    input                             m_ready 
);

localparam DEPTH = DP < 11 ? 16 : DP;

localparam ADDR_WIDTH = $clog2(DEPTH);

reg [WD - 1:0] mem [DEPTH - 1:0];
reg [ADDR_WIDTH - 1:0] cnt;
reg [ADDR_WIDTH - 1:0] raddr;
reg [ADDR_WIDTH - 1:0] waddr;
wire                   ren  ;

wire [WD - 1:0] rdata;

wire [WD - 1:0] pipe_s_data ;
wire            pipe_s_valid;
wire            pipe_s_ready;
wire            pipe_s_fire ;
wire [WD - 1:0] pipe_m_data ;
wire            pipe_m_valid;
wire            pipe_m_ready;

always @(posedge clk ) begin
    if(rst == 1'b1)begin
        s_ready <= 1'b0;
    end
    else begin
        if(cnt >= 4'd10)begin
            s_ready <= 1'b0;
        end
        else begin
            s_ready <= 1'b1;
        end
    end
end

always @(posedge clk ) begin
    if(rst == 1'b1)begin
        waddr <= {ADDR_WIDTH{1'b0}};
    end
    else begin
        if(s_valid == 1'b1)begin
            waddr <= waddr + 1'b1;
        end
    end
end

always @(posedge clk ) begin
    if(s_valid == 1'b1)begin
        mem[waddr] <= s_data; 
    end
end

always @(posedge clk ) begin
    if(rst == 1'b1)begin
        cnt <= {ADDR_WIDTH{1'b0}};
    end
    else begin
        if((s_valid == 1'b1) && (pipe_s_fire == 1'b0))begin
            cnt <= cnt + 1'b1;
        end
        else if((s_valid == 1'b0) && (pipe_s_fire == 1'b1))begin
            cnt <= cnt - 1'b1;
        end
    end
end

always @(posedge clk ) begin
    if(rst == 1'b1)begin
        raddr <= {ADDR_WIDTH{1'b0}};
    end
    else begin
        if(pipe_s_fire == 1'b1)begin
            raddr <= raddr + 1'b1;
        end
    end
end

reg [WD - 1:0] m_data_temp;

always @(posedge clk ) begin
    if(pipe_m_valid & pipe_m_ready)begin
        m_data_temp <= pipe_m_data;
    end
end

assign rdata = mem[raddr];

assign pipe_s_data  = rdata;
assign pipe_s_valid = ren;
assign ren = (cnt > 0);

assign m_data  = pipe_m_valid & pipe_m_ready ? pipe_m_data[WD - 1 : 0] : m_data_temp;
assign m_valid = pipe_m_valid;
assign pipe_m_ready = m_ready;
assign pipe_s_fire = (pipe_s_valid == 1'b1) && (pipe_s_ready == 1'b1);

stream_pipe #(
  .DATA_WIDTH 	(WD)	
) stream_pipe_inst (
  .dataIn_valid   (pipe_s_valid),
  .dataIn_ready   (pipe_s_ready),
  .dataIn_payload (pipe_s_data ),
  .dataOut_valid  (pipe_m_valid),
  .dataOut_ready  (pipe_m_ready),
  .dataOut_payload(pipe_m_data ),
  .clk            (clk    ),
  .reset          (rst    )         
);

endmodule