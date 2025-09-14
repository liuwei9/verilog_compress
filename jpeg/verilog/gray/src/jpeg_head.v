module jpeg_head (
    input          clk                 ,
    input          rst                 ,

    input [15:0]   cfg_img_h           ,
    input [15:0]   cfg_img_w           ,
    input [6:0]    cfg_quality         , 
    input [31:0]   cfg_img_addr        ,
    input          jpeg_start          ,

    output         quant_lum_ren       ,
    output [12:0]  quant_lum_raddr     ,
    input  [7:0]   quant_lum_rdata     ,

    output [7:0]   jpeg_head_data      ,
    output         jpeg_head_data_valid,
    output         jpeg_head_data_last  
);
localparam HEAD_CNT = 9'd25 + 9'd64 + 9'd239 + 9'd1;
reg [8:0]  cnt  ;
reg [8:0]  addr0;
reg [12:0] addr1;
reg [8:0]  addr2;
reg        ren0 ;
reg        ren1 ;
reg        ren2 ;
reg [7:0]  head0 [24:0];
reg [7:0]  head2 [238:0];

reg [7:0] rdata0;
reg [7:0] rdata2;

reg [1:0]  ren1_ff;

always @(posedge clk ) begin
    if(rst)begin
        cnt <= 9'd0;
    end
    else begin
        if(jpeg_start)begin
            cnt <= 9'd1;
        end
        else if((cnt > 9'd0) && (cnt <= HEAD_CNT))begin
            cnt <= cnt + 9'd1;
        end
    end
end

always @(posedge clk ) begin
    addr0 <= cnt;
end

always @(posedge clk ) begin
    if(rst)begin
        ren0 <= 1'b0;
    end
    else begin
        if((cnt > 9'd0) && (cnt < 9'd26))begin
            ren0 <= 1'b1;
        end
        else begin
            ren0 <= 1'b0;
        end
    end
end

always @(posedge clk ) begin
    addr1 <= cnt - 9'd24 + ((cfg_quality - 7'd1) << 3'd6);
end

always @(posedge clk ) begin
    if(rst)begin
        ren1 <= 1'b0;
    end
    else begin
        if((cnt > 9'd23) && (cnt < 9'd88))begin
            ren1 <= 1'b1;
        end
        else begin
            ren1 <= 1'b0;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        ren1_ff <= 2'b00;
    end
    else begin
        ren1_ff[0] <= ren1      ;
        ren1_ff[1] <= ren1_ff[0];
    end
end

assign quant_lum_ren   = ren1 ;
assign quant_lum_raddr = addr1;

always @(posedge clk ) begin
    addr2 <= cnt - 9'd89;
end

always @(posedge clk ) begin
    if(rst)begin
        ren2 <= 1'b0;
    end
    else begin
        if((cnt > 9'd89) && (cnt < HEAD_CNT))begin
            ren2 <= 1'b1;
        end
        else begin
            ren2 <= 1'b0;
        end
    end
end

assign jpeg_head_data       = ren0 ?       rdata0          : 
                              ren1_ff[1] ? quant_lum_rdata : 
                                           rdata2          ; 
assign jpeg_head_data_valid = ren0 | ren1_ff[1] | ren2;
assign jpeg_head_data_last  = cnt == HEAD_CNT;

always @(posedge clk ) begin
    rdata0 <= head0[addr0];
    rdata2 <= head2[addr2];
end

always @(posedge clk ) begin
    head0[ 0] <= 8'hFF;
    head0[ 1] <= 8'hD8;
    head0[ 2] <= 8'hFF;
    head0[ 3] <= 8'hE0;
    head0[ 4] <= 8'h00;
    head0[ 5] <= 8'h10;
    head0[ 6] <= 8'h4A;
    head0[ 7] <= 8'h46;
    head0[ 8] <= 8'h49;
    head0[ 9] <= 8'h46;
    head0[10] <= 8'h00;
    head0[11] <= 8'h01;
    head0[12] <= 8'h00;
    head0[13] <= 8'h00;
    head0[14] <= 8'h00;
    head0[15] <= 8'h01;
    head0[16] <= 8'h00;
    head0[17] <= 8'h01;
    head0[18] <= 8'h00;
    head0[19] <= 8'h00;
    head0[20] <= 8'hFF;
    head0[21] <= 8'hDB;
    head0[22] <= 8'h00;
    head0[23] <= 8'h43;
    head0[24] <= 8'h00;
end

always @(posedge clk ) begin
    head2[0] <= 8'hFF;
    head2[1] <= 8'hC0;
    head2[2] <= 8'h00;
    head2[3] <= 8'h0B;
    head2[4] <= 8'h08;
    if(jpeg_start)begin
        head2[5] <= cfg_img_h[15:8];
        head2[6] <= cfg_img_h[ 7:0];
        head2[7] <= cfg_img_w[15:8];
        head2[8] <= cfg_img_w[ 7:0];
    end
    head2[  9] <= 8'h01;
    head2[ 10] <= 8'h01;
    head2[ 11] <= 8'h11;
    head2[ 12] <= 8'h00;
    head2[ 13] <= 8'hFF;
    head2[ 14] <= 8'hC4;
    head2[ 15] <= 8'h00;
    head2[ 16] <= 8'h1F;
    head2[ 17] <= 8'h00;
    head2[ 18] <= 8'h00;
    head2[ 19] <= 8'h01;
    head2[ 20] <= 8'h05;
    head2[ 21] <= 8'h01;
    head2[ 22] <= 8'h01;
    head2[ 23] <= 8'h01;
    head2[ 24] <= 8'h01;
    head2[ 25] <= 8'h01;
    head2[ 26] <= 8'h01;
    head2[ 27] <= 8'h00;
    head2[ 28] <= 8'h00;
    head2[ 29] <= 8'h00;
    head2[ 30] <= 8'h00;
    head2[ 31] <= 8'h00;
    head2[ 32] <= 8'h00;
    head2[ 33] <= 8'h00;
    head2[ 34] <= 8'h00;
    head2[ 35] <= 8'h01;
    head2[ 36] <= 8'h02;
    head2[ 37] <= 8'h03;
    head2[ 38] <= 8'h04;
    head2[ 39] <= 8'h05;
    head2[ 40] <= 8'h06;
    head2[ 41] <= 8'h07;
    head2[ 42] <= 8'h08;
    head2[ 43] <= 8'h09;
    head2[ 44] <= 8'h0A;
    head2[ 45] <= 8'h0B;
    head2[ 46] <= 8'hff;
    head2[ 47] <= 8'hc4;
    head2[ 48] <= 8'h00;
    head2[ 49] <= 8'hb5;
    head2[ 50] <= 8'h10;
    head2[ 51] <= 8'h00;
    head2[ 52] <= 8'h02;
    head2[ 53] <= 8'h01;
    head2[ 54] <= 8'h03;
    head2[ 55] <= 8'h03;
    head2[ 56] <= 8'h02;
    head2[ 57] <= 8'h04;
    head2[ 58] <= 8'h03;
    head2[ 59] <= 8'h05;
    head2[ 60] <= 8'h05;
    head2[ 61] <= 8'h04;
    head2[ 62] <= 8'h04;
    head2[ 63] <= 8'h00;
    head2[ 64] <= 8'h00;
    head2[ 65] <= 8'h01;
    head2[ 66] <= 8'h7d;
    head2[ 67] <= 8'h01;
    head2[ 68] <= 8'h02;
    head2[ 69] <= 8'h03;
    head2[ 70] <= 8'h00;
    head2[ 71] <= 8'h04;
    head2[ 72] <= 8'h11;
    head2[ 73] <= 8'h05;
    head2[ 74] <= 8'h12;
    head2[ 75] <= 8'h21;
    head2[ 76] <= 8'h31;
    head2[ 77] <= 8'h41;
    head2[ 78] <= 8'h06;
    head2[ 79] <= 8'h13;
    head2[ 80] <= 8'h51;
    head2[ 81] <= 8'h61;
    head2[ 82] <= 8'h07;
    head2[ 83] <= 8'h22;
    head2[ 84] <= 8'h71;
    head2[ 85] <= 8'h14;
    head2[ 86] <= 8'h32;
    head2[ 87] <= 8'h81;
    head2[ 88] <= 8'h91;
    head2[ 89] <= 8'ha1;
    head2[ 90] <= 8'h08;
    head2[ 91] <= 8'h23;
    head2[ 92] <= 8'h42;
    head2[ 93] <= 8'hb1;
    head2[ 94] <= 8'hc1;
    head2[ 95] <= 8'h15;
    head2[ 96] <= 8'h52;
    head2[ 97] <= 8'hd1;
    head2[ 98] <= 8'hf0;
    head2[ 99] <= 8'h24;
    head2[100] <= 8'h33;
    head2[101] <= 8'h62;
    head2[102] <= 8'h72;
    head2[103] <= 8'h82;
    head2[104] <= 8'h09;
    head2[105] <= 8'h0a;
    head2[106] <= 8'h16;
    head2[107] <= 8'h17;
    head2[108] <= 8'h18;
    head2[109] <= 8'h19;
    head2[110] <= 8'h1a;
    head2[111] <= 8'h25;
    head2[112] <= 8'h26;
    head2[113] <= 8'h27;
    head2[114] <= 8'h28;
    head2[115] <= 8'h29;
    head2[116] <= 8'h2a;
    head2[117] <= 8'h34;
    head2[118] <= 8'h35;
    head2[119] <= 8'h36;
    head2[120] <= 8'h37;
    head2[121] <= 8'h38;
    head2[122] <= 8'h39;
    head2[123] <= 8'h3a;
    head2[124] <= 8'h43;
    head2[125] <= 8'h44;
    head2[126] <= 8'h45;
    head2[127] <= 8'h46;
    head2[128] <= 8'h47;
    head2[129] <= 8'h48;
    head2[130] <= 8'h49;
    head2[131] <= 8'h4a;
    head2[132] <= 8'h53;
    head2[133] <= 8'h54;
    head2[134] <= 8'h55;
    head2[135] <= 8'h56;
    head2[136] <= 8'h57;
    head2[137] <= 8'h58;
    head2[138] <= 8'h59;
    head2[139] <= 8'h5a;
    head2[140] <= 8'h63;
    head2[141] <= 8'h64;
    head2[142] <= 8'h65;
    head2[143] <= 8'h66;
    head2[144] <= 8'h67;
    head2[145] <= 8'h68;
    head2[146] <= 8'h69;
    head2[147] <= 8'h6a;
    head2[148] <= 8'h73;
    head2[149] <= 8'h74;
    head2[150] <= 8'h75;
    head2[151] <= 8'h76;
    head2[152] <= 8'h77;
    head2[153] <= 8'h78;
    head2[154] <= 8'h79;
    head2[155] <= 8'h7a;
    head2[156] <= 8'h83;
    head2[157] <= 8'h84;
    head2[158] <= 8'h85;
    head2[159] <= 8'h86;
    head2[160] <= 8'h87;
    head2[161] <= 8'h88;
    head2[162] <= 8'h89;
    head2[163] <= 8'h8a;
    head2[164] <= 8'h92;
    head2[165] <= 8'h93;
    head2[166] <= 8'h94;
    head2[167] <= 8'h95;
    head2[168] <= 8'h96;
    head2[169] <= 8'h97;
    head2[170] <= 8'h98;
    head2[171] <= 8'h99;
    head2[172] <= 8'h9a;
    head2[173] <= 8'ha2;
    head2[174] <= 8'ha3;
    head2[175] <= 8'ha4;
    head2[176] <= 8'ha5;
    head2[177] <= 8'ha6;
    head2[178] <= 8'ha7;
    head2[179] <= 8'ha8;
    head2[180] <= 8'ha9;
    head2[181] <= 8'haa;
    head2[182] <= 8'hb2;
    head2[183] <= 8'hb3;
    head2[184] <= 8'hb4;
    head2[185] <= 8'hb5;
    head2[186] <= 8'hb6;
    head2[187] <= 8'hb7;
    head2[188] <= 8'hb8;
    head2[189] <= 8'hb9;
    head2[190] <= 8'hba;
    head2[191] <= 8'hc2;
    head2[192] <= 8'hc3;
    head2[193] <= 8'hc4;
    head2[194] <= 8'hc5;
    head2[195] <= 8'hc6;
    head2[196] <= 8'hc7;
    head2[197] <= 8'hc8;
    head2[198] <= 8'hc9;
    head2[199] <= 8'hca;
    head2[200] <= 8'hd2;
    head2[201] <= 8'hd3;
    head2[202] <= 8'hd4;
    head2[203] <= 8'hd5;
    head2[204] <= 8'hd6;
    head2[205] <= 8'hd7;
    head2[206] <= 8'hd8;
    head2[207] <= 8'hd9;
    head2[208] <= 8'hda;
    head2[209] <= 8'he1;
    head2[210] <= 8'he2;
    head2[211] <= 8'he3;
    head2[212] <= 8'he4;
    head2[213] <= 8'he5;
    head2[214] <= 8'he6;
    head2[215] <= 8'he7;
    head2[216] <= 8'he8;
    head2[217] <= 8'he9;
    head2[218] <= 8'hea;
    head2[219] <= 8'hf1;
    head2[220] <= 8'hf2;
    head2[221] <= 8'hf3;
    head2[222] <= 8'hf4;
    head2[223] <= 8'hf5;
    head2[224] <= 8'hf6;
    head2[225] <= 8'hf7;
    head2[226] <= 8'hf8;
    head2[227] <= 8'hf9;
    head2[228] <= 8'hfa;
    head2[229] <= 8'hff;
    head2[230] <= 8'hda;
    head2[231] <= 8'h00;
    head2[232] <= 8'h08;
    head2[233] <= 8'h01;
    head2[234] <= 8'h01;
    head2[235] <= 8'h00;
    head2[236] <= 8'h00;
    head2[237] <= 8'h3f;
    head2[238] <= 8'h00;
end


    
endmodule