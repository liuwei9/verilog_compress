module jpeg_chrom_dc_table (
    input             clk           ,
    input             rst           ,
    
    input      [3:0]  chrom_dc_raddr,
    output reg [3:0]  chrom_dc_len  ,
    output reg [10:0] chrom_dc_code  
);
    
always @(posedge clk ) begin
    case (chrom_dc_raddr)
        4'd0: begin
            chrom_dc_len  <= 4'd2;
            chrom_dc_code <= 11'd0;
        end 
        4'd1: begin
            chrom_dc_len  <= 4'd2;
            chrom_dc_code <= 11'd1;
        end 
        4'd2: begin
            chrom_dc_len  <= 4'd2;
            chrom_dc_code <= 11'd2;
        end 
        4'd3: begin
            chrom_dc_len  <= 4'd3;
            chrom_dc_code <= 11'd6;
        end 
        4'd4: begin
            chrom_dc_len  <= 4'd4;
            chrom_dc_code <= 11'd14;
        end 
        4'd5: begin
            chrom_dc_len  <= 4'd5;
            chrom_dc_code <= 11'd30;
        end 
        4'd6: begin
            chrom_dc_len  <= 4'd6;
            chrom_dc_code <= 11'd62;
        end 
        4'd7: begin
            chrom_dc_len  <= 4'd7;
            chrom_dc_code <= 11'd126;
        end 
        4'd8: begin
            chrom_dc_len  <= 4'd8;
            chrom_dc_code <= 11'd254;
        end 
        4'd9: begin
            chrom_dc_len  <= 4'd9;
            chrom_dc_code <= 11'd510;
        end 
        4'd10: begin
            chrom_dc_len  <= 4'd10;
            chrom_dc_code <= 11'd1022;
        end 
        4'd11: begin
            chrom_dc_len  <= 4'd11;
            chrom_dc_code <= 11'd2046;
        end 
        default: begin
            chrom_dc_len  <= 4'd0;
            chrom_dc_code <= 11'd0;
        end
    endcase
end
endmodule