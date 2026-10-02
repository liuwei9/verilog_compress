module tb_read_data #(
    parameter IMG_PATH = ""    ,
    parameter IMG_H    = 1024  ,
    parameter IMG_W    = 1024
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

reg [2:0]  cnt;
reg [63:0] data_r      ;
reg        data_valid_r;
reg        data_last_r ;
wire [7:0] m_data      ;
wire       m_data_valid;
wire       m_data_last ;

always @(posedge clk ) begin
    if(rst)begin
        cnt <= 3'd0;
    end
    else begin
        if(cmd_valid & cmd_ready)begin
            cnt <= 3'd0;
        end
        else begin
            if(m_data_valid & data_ready)begin
                cnt <= cnt + 3'd1;
            end
        end
    end
end

always @(posedge clk ) begin
    if(m_data_valid)begin
        data_r <= {m_data, data_r[63:8]};
    end
end

always @(posedge clk ) begin
    if(rst)begin
        data_valid_r <= 1'b0;
        data_last_r  <= 1'b0;
    end
    else begin
        data_valid_r <= m_data_valid && (&cnt | m_data_last);
        data_last_r  <= m_data_last;
    end
end

assign data       = data_r      ;
assign data_valid = data_valid_r;
assign data_last  = data_last_r ;

read_bmp #(
    .IMG_PATH     (IMG_PATH ),
    .IMG_N        (8        ), //8->gray, 24->rgb
    .IMG_H        (IMG_H    ),
    .IMG_W        (IMG_W    )
) read_bmp_inst (
    .clk          (clk      ),
    .rst          (rst      ),
    .m_data_req   (cmd_valid & cmd_ready),
    .m_data       (m_data      ),//{r,g,b} or gray
    .m_data_valid (m_data_valid),
    .m_data_last  (m_data_last ),
    .m_data_ready (data_ready  )
);
    
endmodule