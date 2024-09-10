module gzip_lz77 (
    input         clk    ,
    input         rst    ,
    input  [7:0]  s_data ,
    input         s_valid,
    input         s_last ,
    output        s_ready,

    output [7:0]  m_data ,
    output        m_valid,
    output        m_last ,
    input         m_req    
);

genvar i;

reg s_ready_r;

reg [ 7:0]  data  [20:0];
reg [20:0]  valid;
reg [20:0]  last ;

reg [15:0]  h_hash;
wire [`HASH_BITS - 1:0] hash_data;

wire                     hash_mem_reverse;
wire [`HASH_BITS-1:0]    hash_mem_waddr  ;
wire                     hash_mem_wen    ;
wire [`BLOCK_SIZE_W-1:0] hash_mem_wdata  ;

wire [`HASH_BITS-1:0]    hash_mem_raddr  ;
wire                     hash_mem_ren    ;
wire [`BLOCK_SIZE_W:0]   hash_mem_rdata  ;

reg [`BLOCK_SIZE_W-1:0]  w_ptr;

always @(posedge clk ) begin
    if(rst)begin
        s_ready_r <= 1'b0;
    end
    else begin
        if(m_req)begin
            s_ready_r <= 1'b1;
        end
        else begin
            if(s_ready_r & s_last & s_valid)begin
                s_ready_r <= 1'b0;
            end
        end
    end
end

assign s_ready = s_ready_r;

always @(posedge clk ) begin
    if(rst)begin
        data[0] <= 8'd0 ;
        valid   <= 21'd0;
        last    <= 21'd0;
    end
    else begin
        data[0] <= s_data;
        valid   <= {valid[19:0], s_valid & s_ready};
        last    <= {last[19:0], s_valid & s_ready & s_last};
    end
end

generate
    for (i = 0; i < 20; i = i+1) begin
        always @(posedge clk ) begin
            data[i+1] <= data[i];
        end
    end
endgenerate

always @(posedge clk ) begin
    if(rst)begin
        h_hash <= 16'd0;
    end
    else begin
        if((s_valid == 1'b1) && (valid[0] == 1'b0))begin
            h_hash <= 16'd0;
        end
        else begin
            if(valid[0] == 1'b1)begin
                h_hash <= ((h_hash << `H_SHIFT) ^ data[0]) & `HASH_MASK;
            end
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        w_ptr <= {`BLOCK_SIZE_W{1'b0}};
    end
    else begin
        if((s_valid == 1'b1) && (valid[0] == 1'b0))begin
            w_ptr <= {`BLOCK_SIZE_W{1'b0}};
        end
        else begin
            if(valid[3])begin
                w_ptr <= w_ptr + 1'b1;
            end
        end
    end
end

assign hash_data = h_hash[`HASH_BITS - 1:0];
assign hash_mem_reverse = (s_valid == 1'b1) && (valid[0] == 1'b0);
assign hash_mem_wen   = valid[3];
assign hash_mem_waddr = hash_data;
assign hash_mem_wdata = w_ptr;
assign hash_mem_ren   = valid[3] ;
assign hash_mem_raddr = hash_data;

gzip_hash_mem gzip_hash_mem_inst(
    .clk    (clk             ),
    .rst    (rst             ),

    .reverse(hash_mem_reverse),
    .waddr  (hash_mem_waddr  ),
    .wen    (hash_mem_wen    ),
    .wdata  (hash_mem_wdata  ),

    .raddr  (hash_mem_raddr  ),
    .ren    (hash_mem_ren    ),
    .rdata  (hash_mem_rdata  )
)
    
endmodule