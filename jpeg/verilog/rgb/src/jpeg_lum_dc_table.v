module jpeg_lum_dc_table (
    input            clk     ,
    input            rst     ,
    
    input      [3:0] lum_dc_raddr,
    output reg [3:0] lum_dc_len  ,
    output reg [8:0] lum_dc_code  
);
    
always @(posedge clk ) begin
    case (lum_dc_raddr)
        4'd0: begin
            lum_dc_len  <= 4'd2;
            lum_dc_code <= 9'd0;
        end 
        4'd1: begin
            lum_dc_len  <= 4'd3;
            lum_dc_code <= 9'd2;
        end 
        4'd2: begin
            lum_dc_len  <= 4'd3;
            lum_dc_code <= 9'd3;
        end 
        4'd3: begin
            lum_dc_len  <= 4'd3;
            lum_dc_code <= 9'd4;
        end 
        4'd4: begin
            lum_dc_len  <= 4'd3;
            lum_dc_code <= 9'd5;
        end 
        4'd5: begin
            lum_dc_len  <= 4'd3;
            lum_dc_code <= 9'd6;
        end 
        4'd6: begin
            lum_dc_len  <= 4'd4;
            lum_dc_code <= 9'd14;
        end 
        4'd7: begin
            lum_dc_len  <= 4'd5;
            lum_dc_code <= 9'd30;
        end 
        4'd8: begin
            lum_dc_len  <= 4'd6;
            lum_dc_code <= 9'd62;
        end 
        4'd9: begin
            lum_dc_len  <= 4'd7;
            lum_dc_code <= 9'd126;
        end 
        4'd10: begin
            lum_dc_len  <= 4'd8;
            lum_dc_code <= 9'd254;
        end 
        4'd11: begin
            lum_dc_len  <= 4'd9;
            lum_dc_code <= 9'd510;
        end 
        default: begin
            lum_dc_len  <= 4'd0;
            lum_dc_code <= 9'd0;
        end
    endcase
end
endmodule