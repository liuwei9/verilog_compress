module gzip_hash_mem (
    input                     clk    ,
    input                     rst    ,

    input                     reverse,
    input [`HASH_BITS-1:0]    waddr  ,
    input                     wen    ,
    input [`BLOCK_SIZE_W-1:0] wdata  ,

    input [`HASH_BITS-1:0]    raddr  ,
    input                     ren    ,
    input [`BLOCK_SIZE_W:0]   rdata  
);

localparam HASH_BITS_C = (1 << `HASH_BITS);

reg [`BLOCK_SIZE_W - 1:0] mem1 [((1 << `HASH_BITS) - 1) : 0];
reg [((1 << `HASH_BITS) - 1) : 0] mem2;

reg reverse_flag;

reg [`BLOCK_SIZE_W - 1:0] rdata1;
reg                       rdata2;

always @(posedge clk ) begin
    if(rst)begin
        reverse_flag <= 1'b1;
    end
    else begin
        if(reverse)begin
            reverse_flag <= !reverse_flag;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        mem2 <= {(HASH_BITS_C){1'b0}};
    end
    else begin
        if(reverse == 1'b1)begin
            if(reverse_flag == 1'b0)begin
                mem2 <= {(HASH_BITS_C){1'b0}};
            end
            else begin
                mem2 <= {(HASH_BITS_C){1'b1}};
            end
        end
        else begin
            if(wen)begin
                if(mem2[w_addr] != reverse_flag)begin
                    mem2[waddr] <= !mem2[w_addr];
                end  
            end
        end        
    end
end

always @(posedge clk ) begin
    if(wen)begin
        mem1[waddr] <= wdata;
    end
end

always @(posedge clk ) begin
    if(ren)begin
        rdata1 <= mem1[raddr];
    end
end

always @(posedge clk ) begin
    if(ren)begin
        rdata2 <= mem2[raddr:raddr];
    end
end

assign rdata {rdata2, rdata1};
    
endmodule