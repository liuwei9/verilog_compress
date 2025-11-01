module tb_read_data #(
    parameter FILE_PATH = "",
    parameter FILE_LEN  = 0  
) (
    input          clk          ,
    input          rst          ,
    input          start        ,

    input   [31:0] cmd_addr     ,
    input   [31:0] cmd_len      ,
    input          cmd_valid    ,
    output         cmd_ready    ,

    output [63:0]  data         ,
    output [7:0]   data_keep    ,
    output         data_valid   ,
    output         data_last    ,
    input          data_ready     
);

assign cmd_ready = 1'b1;
assign data_keep = 8'b1111_1111;

reg [31:0] addr;
reg [31:0] len;
reg [31:0] cnt;
reg valid;

reg [63:0] mem [FILE_LEN - 1:0];

initial begin
    $readmemh(FILE_PATH, mem);
end

always @(posedge clk ) begin
    if(cmd_valid & cmd_ready)begin
        len <= cmd_len / 8;
    end
end

always @(posedge clk ) begin
    if(rst)begin
        valid <= 1'b0;
    end
    else if(cmd_valid & cmd_ready)begin
        valid <= 1'b1;
    end
    else begin
        if(data_valid & data_ready & data_last)begin
            valid <= 1'b0;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        addr <= 32'd0;
    end
    else begin
        if(data_valid & data_ready)begin
            addr <= addr + 1'b1;
        end
    end
end

always @(posedge clk ) begin
    if(cmd_valid & cmd_ready)begin
        cnt <= 32'd0;
    end
    else begin
        if(data_valid & data_ready & data_last)begin
            cnt <= 32'd0;
        end
        else if(data_valid & data_ready)begin
            cnt <= cnt + 32'd1;
        end
    end
end


assign data_last = cnt == len - 1;
assign data = mem[addr];
assign data_valid = valid;
    
endmodule