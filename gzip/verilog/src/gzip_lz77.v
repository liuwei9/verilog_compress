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

reg s_ready_r;

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


    
endmodule