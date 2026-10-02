module read_bmp #(
    parameter IMG_PATH = ""    ,
    parameter IMG_N    = 8     , //8->gray, 24->rgb
    parameter IMG_H    = 1024  ,
    parameter IMG_W    = 1024
) (
    input                clk         ,
    input                rst         ,
    input                m_data_req  ,
    output [IMG_N - 1:0] m_data      ,//{r,g,b} or gray
    output               m_data_valid,
    output               m_data_last ,
    input                m_data_ready
);

integer fp;

reg [IMG_N - 1:0] mem [IMG_H * IMG_W * 4 - 1:0];
reg [7:0] file_header [53:0];
integer head_len;
integer file_len;

reg read_success;

localparam IDLE     = 4'b0001;
localparam WAIT_REQ = 4'b0010;
localparam DATA     = 4'b0100;
localparam JUDGE    = 4'b1000;
reg [3:0] curr_state;
reg [3:0] next_state;

reg m_data_req_ff  ;
reg m_data_req_rise;
reg m_data_req_flag;

reg [31:0] row_cnt;
wire[31:0] row_num;
wire[31:0] col_num;
reg [31:0] col_cnt;
wire[31:0] row_size;
reg [31:0] pix_index;

assign row_num = {file_header[25], file_header[24], file_header[23], file_header[22]};
assign col_num = {file_header[21], file_header[20], file_header[19], file_header[18]};

initial begin
    read_success <= 1'b0;
    fp = $fopen(IMG_PATH, "rb");
    if(fp == 0)begin
        $display("Filed to open %s", IMG_PATH);
        $finish;
    end
    repeat(20) @(posedge clk);
    head_len = $fread(file_header, fp);
    file_len = $fread(mem, fp);
    $display("file len %d", file_len);
    repeat(20) @(posedge clk);
    $fclose(fp);
    read_success <= 1'b1;
    repeat(20) @(posedge clk);
end


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
            if(read_success)begin
                next_state = WAIT_REQ;
            end
            else begin
                next_state = IDLE;
            end
        end 
        WAIT_REQ: begin
            if(m_data_req_rise | m_data_req_flag)begin
                next_state = DATA;
            end
            else begin
                next_state = WAIT_REQ;
            end
        end
        DATA: begin
            if(m_data_valid & m_data_last)begin
                next_state = JUDGE;
            end
            else begin
                next_state = DATA;
            end
        end
        JUDGE: begin
            if(row_cnt == row_num)begin
                next_state = IDLE;
            end
            else begin
                next_state = WAIT_REQ;
            end
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

always @(posedge clk ) begin
    if(rst)begin
        m_data_req_ff   <= 1'b0;
        m_data_req_rise <= 1'b0;
        m_data_req_flag <= 1'b0;
    end
    else begin
        m_data_req_ff   <= m_data_req;
        m_data_req_rise <= m_data_req & (!m_data_req_rise);
        m_data_req_flag <= (m_data_req_flag | m_data_req_rise) && (curr_state != DATA);
    end
end

assign m_data_valid = curr_state == DATA;
assign m_data_last  = m_data_valid && (col_cnt == (col_num - 32'd1));

always @(posedge clk ) begin
    if(rst)begin
        row_cnt <= 32'd0;
    end
    else begin
        if(curr_state == IDLE)begin
            row_cnt <= 32'd0;
        end
        else begin
            if(m_data_last & m_data_ready & m_data_valid)begin
                row_cnt <= row_cnt + 32'd1;
            end
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        col_cnt <= 32'd0;
    end
    else begin
        if(m_data_valid & m_data_ready)begin
            if(m_data_last)begin
                col_cnt <= 32'd0;
            end
            else begin
                col_cnt <= col_cnt + 32'd1;
            end           
        end
    end
end

generate
    if(IMG_N == 24)begin : RGB
        assign row_size = (col_num * 2'd3 + 2'd3) / 3'd4 * 3'd4;
        assign m_data   = {mem[pix_index + 2], m_data[pix_index + 1], m_data[pix_index]}; //{r g b}
        always @(posedge clk ) begin
            if(curr_state == DATA)begin
                if(m_data_valid & m_data_ready)begin
                    pix_index <= pix_index + 32'd3;
                end 
            end
            else begin
                pix_index <= file_len - row_size * (row_cnt + 32'd1);
            end
        end
    end
    else begin
        assign row_size = (col_num + 2'd3) / 3'd4 * 3'd4;
        assign m_data   = mem[pix_index];
        always @(posedge clk ) begin
            if(curr_state == DATA)begin
                if(m_data_valid & m_data_ready)begin
                    pix_index <= pix_index + 32'd1;
                end               
            end
            else begin
                pix_index <= file_len - row_size * (row_cnt + 32'd1);
            end
        end
    end
endgenerate


    
endmodule