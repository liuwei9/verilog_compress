module jpeg_dc_table (
    input            clk     ,
    input            rst     ,
    
    input      [3:0] dc_raddr,
    output reg [3:0] dc_len  ,
    output reg [8:0] dc_code  
);
    
always @(posedge clk ) begin
    case (dc_raddr)
        4'd0: begin
            dc_len  <= 4'd2;
            dc_code <= 9'd0;
        end 
        4'd1: begin
            dc_len  <= 4'd3;
            dc_code <= 9'd2;
        end 
        4'd2: begin
            dc_len  <= 4'd3;
            dc_code <= 9'd3;
        end 
        4'd3: begin
            dc_len  <= 4'd3;
            dc_code <= 9'd4;
        end 
        4'd4: begin
            dc_len  <= 4'd3;
            dc_code <= 9'd5;
        end 
        4'd5: begin
            dc_len  <= 4'd3;
            dc_code <= 9'd6;
        end 
        4'd6: begin
            dc_len  <= 4'd4;
            dc_code <= 9'd14;
        end 
        4'd7: begin
            dc_len  <= 4'd5;
            dc_code <= 9'd30;
        end 
        4'd8: begin
            dc_len  <= 4'd6;
            dc_code <= 9'd62;
        end 
        4'd9: begin
            dc_len  <= 4'd7;
            dc_code <= 9'd126;
        end 
        4'd10: begin
            dc_len  <= 4'd8;
            dc_code <= 9'd254;
        end 
        4'd11: begin
            dc_len  <= 4'd9;
            dc_code <= 9'd510;
        end 
        default: begin
            dc_len  <= 4'd0;
            dc_code <= 9'd0;
        end
    endcase
end
endmodule