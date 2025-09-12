module jpeg_quant_table (
    input       clk         ,
    input       rst         ,
    input       jpeg_start  ,
    input [6:0] jpeg_quality,

);

wire [7:0] lumMat [63:0];
assign lumMat[ 0] = 16 ;
assign lumMat[ 1] = 11 ;
assign lumMat[ 2] = 10 ;
assign lumMat[ 3] = 16 ;
assign lumMat[ 4] = 24 ;
assign lumMat[ 5] = 40 ;
assign lumMat[ 6] = 51 ;
assign lumMat[ 7] = 61 ;
assign lumMat[ 8] = 12 ;
assign lumMat[ 9] = 12 ;
assign lumMat[10] = 14 ;
assign lumMat[11] = 19 ;
assign lumMat[12] = 26 ;
assign lumMat[13] = 58 ;
assign lumMat[14] = 60 ;
assign lumMat[15] = 55 ;
assign lumMat[16] = 14 ;
assign lumMat[17] = 13 ;
assign lumMat[18] = 16 ;
assign lumMat[19] = 24 ;
assign lumMat[20] = 40 ;
assign lumMat[21] = 57 ;
assign lumMat[22] = 69 ;
assign lumMat[23] = 56 ;
assign lumMat[24] = 14 ;
assign lumMat[25] = 17 ;
assign lumMat[26] = 22 ;
assign lumMat[27] = 29 ;
assign lumMat[28] = 51 ;
assign lumMat[29] = 87 ;
assign lumMat[30] = 80 ;
assign lumMat[31] = 62 ;
assign lumMat[32] = 18 ;
assign lumMat[33] = 22 ;
assign lumMat[34] = 37 ;
assign lumMat[35] = 56 ;
assign lumMat[36] = 68 ;
assign lumMat[37] = 109;
assign lumMat[38] = 103;
assign lumMat[39] = 77 ;
assign lumMat[40] = 24 ;
assign lumMat[41] = 35 ;
assign lumMat[42] = 55 ;
assign lumMat[43] = 64 ;
assign lumMat[44] = 81 ;
assign lumMat[45] = 104;
assign lumMat[46] = 113;
assign lumMat[47] = 92 ;
assign lumMat[48] = 49 ;
assign lumMat[49] = 64 ;
assign lumMat[50] = 78 ;
assign lumMat[51] = 87 ;
assign lumMat[52] = 103;
assign lumMat[53] = 121;
assign lumMat[54] = 120;
assign lumMat[55] = 101;
assign lumMat[56] = 72 ;
assign lumMat[57] = 92 ;
assign lumMat[58] = 95 ;
assign lumMat[59] = 98 ;
assign lumMat[60] = 112;
assign lumMat[61] = 100;
assign lumMat[62] = 103;
assign lumMat[63] = 99 ;

reg [:] quantLumMatrix [63:0];
reg [5:0] ;

endmodule