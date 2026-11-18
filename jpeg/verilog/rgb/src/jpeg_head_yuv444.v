module jpeg_head_yuv444 (
    input          clk                 ,
    input          rst                 ,

    input [15:0]   cfg_img_h           ,
    input [15:0]   cfg_img_w           ,
    input [6:0]    cfg_quality         , 
    input          jpeg_start          ,

    output         quant_lum_ren       ,
    output [12:0]  quant_lum_raddr     ,
    input  [7:0]   quant_lum_rdata     ,
    output         quant_chrom_ren     ,
    output [12:0]  quant_chrom_raddr   ,
    input  [7:0]   quant_chrom_rdata   ,

    output [7:0]   jpeg_head_data      ,
    output         jpeg_head_data_valid,
    output         jpeg_head_data_last  
);
localparam HEAD_CNT = 9'd25 + 9'd64 + 9'd5 + 9'd64 + 9'd465 + 9'd1;
reg [9:0]  cnt  ;
reg [8:0]  addr0;
reg [12:0] addr1;
reg [2:0]  addr2;
reg [12:0] addr3;
reg [8:0]  addr4;
reg        ren0 ;
reg        ren1 ;
reg        ren2 ;
reg        ren3 ;
reg        ren4 ;
reg [7:0]  head0 [24:0];
reg [7:0]  head2 [4:0];
reg [7:0]  head4 [464:0];

reg [7:0] rdata0;
reg [7:0] rdata2;
reg [7:0] rdata4;

reg [1:0]  ren1_ff;
reg [1:0]  ren3_ff;

always @(posedge clk ) begin
    if(rst)begin
        cnt <= 10'd0;
    end
    else begin
        if(jpeg_start)begin
            cnt <= 10'd1;
        end
        else if((cnt > 10'd0) && (cnt <= HEAD_CNT))begin
            cnt <= cnt + 10'd1;
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
        if((cnt > 10'd0) && (cnt < 10'd26))begin
            ren0 <= 1'b1;
        end
        else begin
            ren0 <= 1'b0;
        end
    end
end

always @(posedge clk ) begin
    addr1 <= cnt - 10'd24 + ((cfg_quality - 7'd1) << 3'd6);
end

always @(posedge clk ) begin
    if(rst)begin
        ren1 <= 1'b0;
    end
    else begin
        if((cnt > 10'd23) && (cnt < 10'd88))begin
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
    addr2 <= cnt - 10'd89;
end

always @(posedge clk ) begin
    if(rst)begin
        ren2 <= 1'b0;
    end
    else begin
        if((cnt > 10'd89) && (cnt < 10'd95))begin
            ren2 <= 1'b1;
        end
        else begin
            ren2 <= 1'b0;
        end
    end
end

always @(posedge clk ) begin
    addr3 <= cnt - 10'd93 + ((cfg_quality - 7'd1) << 3'd6);
end

always @(posedge clk ) begin
    if(rst)begin
        ren3 <= 1'b0;
    end
    else begin
        if((cnt > 10'd92) && (cnt < 10'd157))begin
            ren3 <= 1'b1;
        end
        else begin
            ren3 <= 1'b0;
        end
    end
end

always @(posedge clk ) begin
    if(rst)begin
        ren3_ff <= 2'b00;
    end
    else begin
        ren3_ff[0] <= ren3      ;
        ren3_ff[1] <= ren3_ff[0];
    end
end

assign quant_chrom_ren   = ren3 ;
assign quant_chrom_raddr = addr3;

always @(posedge clk ) begin
    addr4 <= cnt - 10'd158;
end

always @(posedge clk ) begin
    if(rst)begin
        ren4 <= 1'b0;
    end
    else begin
        if((cnt > 10'd158) && (cnt < HEAD_CNT))begin
            ren4 <= 1'b1;
        end
        else begin
            ren4 <= 1'b0;
        end
    end
end

assign jpeg_head_data       = ren0 ?       rdata0           : 
                              ren1_ff[1] ? quant_lum_rdata  : 
                              ren2 ?       rdata2           :
                              ren3_ff[1] ? quant_chrom_rdata:
                                           rdata4           ; 
assign jpeg_head_data_valid = ren0 | ren1_ff[1] | ren2 | ren3_ff[1] | ren4;
assign jpeg_head_data_last  = cnt == HEAD_CNT;

always @(posedge clk ) begin
    rdata0 <= head0[addr0];
    rdata2 <= head2[addr2];
    rdata4 <= head4[addr4];
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
    head2[1] <= 8'hDB;
    head2[2] <= 8'h00;
    head2[3] <= 8'h43;
    head2[4] <= 8'h01;
end

always @(posedge clk ) begin
    head4[0] <= 8'hFF;
    head4[1] <= 8'hC0;
    head4[2] <= 8'h00;
    head4[3] <= 8'h11;
    head4[4] <= 8'h08;
    if(jpeg_start)begin
        head4[5] <= cfg_img_h[15:8];
        head4[6] <= cfg_img_h[ 7:0];
        head4[7] <= cfg_img_w[15:8];
        head4[8] <= cfg_img_w[ 7:0];
    end
    head4[  9] <= 8'h03;
    head4[ 10] <= 8'h01;
    head4[ 11] <= 8'h11;
    head4[ 12] <= 8'h00;
    head4[ 13] <= 8'h02;
    head4[ 14] <= 8'h11;
    head4[ 15] <= 8'h01;
    head4[ 16] <= 8'h03;
    head4[ 17] <= 8'h11;
    head4[ 18] <= 8'h01;

    head4[ 19] <= 8'hFF;
    head4[ 20] <= 8'hC4;
    head4[ 21] <= 8'h00;
    head4[ 22] <= 8'h1F;
    head4[ 23] <= 8'h00;

    head4[ 24] <= 8'h00;
    head4[ 25] <= 8'h01;
    head4[ 26] <= 8'h05;
    head4[ 27] <= 8'h01;
    head4[ 28] <= 8'h01;
    head4[ 29] <= 8'h01;
    head4[ 30] <= 8'h01;
    head4[ 31] <= 8'h01;
    head4[ 32] <= 8'h01;
    head4[ 33] <= 8'h00;
    head4[ 34] <= 8'h00;
    head4[ 35] <= 8'h00;
    head4[ 36] <= 8'h00;
    head4[ 37] <= 8'h00;
    head4[ 38] <= 8'h00;
    head4[ 39] <= 8'h00;
    head4[ 40] <= 8'h00;
    head4[ 41] <= 8'h01;
    head4[ 42] <= 8'h02;
    head4[ 43] <= 8'h03;
    head4[ 44] <= 8'h04;
    head4[ 45] <= 8'h05;
    head4[ 46] <= 8'h06;
    head4[ 47] <= 8'h07;
    head4[ 48] <= 8'h08;
    head4[ 49] <= 8'h09;
    head4[ 50] <= 8'h0A;
    head4[ 51] <= 8'h0B;

    head4[ 52] <= 8'hff;
    head4[ 53] <= 8'hc4;
    head4[ 54] <= 8'h00;
    head4[ 55] <= 8'hb5;
    head4[ 56] <= 8'h10;
    head4[ 57] <= 8'h00;
    head4[ 58] <= 8'h02;
    head4[ 59] <= 8'h01;
    head4[ 60] <= 8'h03;
    head4[ 61] <= 8'h03;
    head4[ 62] <= 8'h02;
    head4[ 63] <= 8'h04;
    head4[ 64] <= 8'h03;
    head4[ 65] <= 8'h05;
    head4[ 66] <= 8'h05;
    head4[ 67] <= 8'h04;
    head4[ 68] <= 8'h04;
    head4[ 69] <= 8'h00;
    head4[ 70] <= 8'h00;
    head4[ 71] <= 8'h01;
    head4[ 72] <= 8'h7d;
    head4[ 73] <= 8'h01;
    head4[ 74] <= 8'h02;
    head4[ 75] <= 8'h03;
    head4[ 76] <= 8'h00;
    head4[ 77] <= 8'h04;
    head4[ 78] <= 8'h11;
    head4[ 79] <= 8'h05;
    head4[ 80] <= 8'h12;
    head4[ 81] <= 8'h21;
    head4[ 82] <= 8'h31;
    head4[ 83] <= 8'h41;
    head4[ 84] <= 8'h06;
    head4[ 85] <= 8'h13;
    head4[ 86] <= 8'h51;
    head4[ 87] <= 8'h61;
    head4[ 88] <= 8'h07;
    head4[ 89] <= 8'h22;
    head4[ 90] <= 8'h71;
    head4[ 91] <= 8'h14;
    head4[ 92] <= 8'h32;
    head4[ 93] <= 8'h81;
    head4[ 94] <= 8'h91;
    head4[ 95] <= 8'ha1;
    head4[ 96] <= 8'h08;
    head4[ 97] <= 8'h23;
    head4[ 98] <= 8'h42;
    head4[ 99] <= 8'hb1;
    head4[100] <= 8'hc1;
    head4[101] <= 8'h15;
    head4[102] <= 8'h52;
    head4[103] <= 8'hd1;
    head4[104] <= 8'hf0;
    head4[105] <= 8'h24;
    head4[106] <= 8'h33;
    head4[107] <= 8'h62;
    head4[108] <= 8'h72;
    head4[109] <= 8'h82;
    head4[110] <= 8'h09;
    head4[111] <= 8'h0a;
    head4[112] <= 8'h16;
    head4[113] <= 8'h17;
    head4[114] <= 8'h18;
    head4[115] <= 8'h19;
    head4[116] <= 8'h1a;
    head4[117] <= 8'h25;
    head4[118] <= 8'h26;
    head4[119] <= 8'h27;
    head4[120] <= 8'h28;
    head4[121] <= 8'h29;
    head4[122] <= 8'h2a;
    head4[123] <= 8'h34;
    head4[124] <= 8'h35;
    head4[125] <= 8'h36;
    head4[126] <= 8'h37;
    head4[127] <= 8'h38;
    head4[128] <= 8'h39;
    head4[129] <= 8'h3a;
    head4[130] <= 8'h43;
    head4[131] <= 8'h44;
    head4[132] <= 8'h45;
    head4[133] <= 8'h46;
    head4[134] <= 8'h47;
    head4[135] <= 8'h48;
    head4[136] <= 8'h49;
    head4[137] <= 8'h4a;
    head4[138] <= 8'h53;
    head4[139] <= 8'h54;
    head4[140] <= 8'h55;
    head4[141] <= 8'h56;
    head4[142] <= 8'h57;
    head4[143] <= 8'h58;
    head4[144] <= 8'h59;
    head4[145] <= 8'h5a;
    head4[146] <= 8'h63;
    head4[147] <= 8'h64;
    head4[148] <= 8'h65;
    head4[149] <= 8'h66;
    head4[150] <= 8'h67;
    head4[151] <= 8'h68;
    head4[152] <= 8'h69;
    head4[153] <= 8'h6a;
    head4[154] <= 8'h73;
    head4[155] <= 8'h74;
    head4[156] <= 8'h75;
    head4[157] <= 8'h76;
    head4[158] <= 8'h77;
    head4[159] <= 8'h78;
    head4[160] <= 8'h79;
    head4[161] <= 8'h7a;
    head4[162] <= 8'h83;
    head4[163] <= 8'h84;
    head4[164] <= 8'h85;
    head4[165] <= 8'h86;
    head4[166] <= 8'h87;
    head4[167] <= 8'h88;
    head4[168] <= 8'h89;
    head4[169] <= 8'h8a;
    head4[170] <= 8'h92;
    head4[171] <= 8'h93;
    head4[172] <= 8'h94;
    head4[173] <= 8'h95;
    head4[174] <= 8'h96;
    head4[175] <= 8'h97;
    head4[176] <= 8'h98;
    head4[177] <= 8'h99;
    head4[178] <= 8'h9a;
    head4[179] <= 8'ha2;
    head4[180] <= 8'ha3;
    head4[181] <= 8'ha4;
    head4[182] <= 8'ha5;
    head4[183] <= 8'ha6;
    head4[184] <= 8'ha7;
    head4[185] <= 8'ha8;
    head4[186] <= 8'ha9;
    head4[187] <= 8'haa;
    head4[188] <= 8'hb2;
    head4[189] <= 8'hb3;
    head4[190] <= 8'hb4;
    head4[191] <= 8'hb5;
    head4[192] <= 8'hb6;
    head4[193] <= 8'hb7;
    head4[194] <= 8'hb8;
    head4[195] <= 8'hb9;
    head4[196] <= 8'hba;
    head4[197] <= 8'hc2;
    head4[198] <= 8'hc3;
    head4[199] <= 8'hc4;
    head4[200] <= 8'hc5;
    head4[201] <= 8'hc6;
    head4[202] <= 8'hc7;
    head4[203] <= 8'hc8;
    head4[204] <= 8'hc9;
    head4[205] <= 8'hca;
    head4[206] <= 8'hd2;
    head4[207] <= 8'hd3;
    head4[208] <= 8'hd4;
    head4[209] <= 8'hd5;
    head4[210] <= 8'hd6;
    head4[211] <= 8'hd7;
    head4[212] <= 8'hd8;
    head4[213] <= 8'hd9;
    head4[214] <= 8'hda;
    head4[215] <= 8'he1;
    head4[216] <= 8'he2;
    head4[217] <= 8'he3;
    head4[218] <= 8'he4;
    head4[219] <= 8'he5;
    head4[220] <= 8'he6;
    head4[221] <= 8'he7;
    head4[222] <= 8'he8;
    head4[223] <= 8'he9;
    head4[224] <= 8'hea;
    head4[225] <= 8'hf1;
    head4[226] <= 8'hf2;
    head4[227] <= 8'hf3;
    head4[228] <= 8'hf4;
    head4[229] <= 8'hf5;
    head4[230] <= 8'hf6;
    head4[231] <= 8'hf7;
    head4[232] <= 8'hf8;
    head4[233] <= 8'hf9;
    head4[234] <= 8'hfa;
    head4[235] <= 8'hFF;
    head4[236] <= 8'hC4;
    head4[237] <= 8'h00;
    head4[238] <= 8'h1F;
    head4[239] <= 8'h01;
    head4[240] <= 8'h00;
    head4[241] <= 8'h03;
    head4[242] <= 8'h01;
    head4[243] <= 8'h01;
    head4[244] <= 8'h01;
    head4[245] <= 8'h01;
    head4[246] <= 8'h01;
    head4[247] <= 8'h01;
    head4[248] <= 8'h01;
    head4[249] <= 8'h01;
    head4[250] <= 8'h01;
    head4[251] <= 8'h00;
    head4[252] <= 8'h00;
    head4[253] <= 8'h00;
    head4[254] <= 8'h00;
    head4[255] <= 8'h00;
    head4[256] <= 8'h00;
    head4[257] <= 8'h01;
    head4[258] <= 8'h02;
    head4[259] <= 8'h03;
    head4[260] <= 8'h04;
    head4[261] <= 8'h05;
    head4[262] <= 8'h06;
    head4[263] <= 8'h07;
    head4[264] <= 8'h08;
    head4[265] <= 8'h09;
    head4[266] <= 8'h0A;
    head4[267] <= 8'h0B;

    head4[268] <= 8'hFF;
    head4[269] <= 8'hC4;
    head4[270] <= 8'h00;
    head4[271] <= 8'hB5;
    head4[272] <= 8'h11;
    head4[273] <= 8'h00;
    head4[274] <= 8'h02;
    head4[275] <= 8'h01;
    head4[276] <= 8'h02;
    head4[277] <= 8'h04;
    head4[278] <= 8'h04;
    head4[279] <= 8'h03;
    head4[280] <= 8'h04;
    head4[281] <= 8'h07;
    head4[282] <= 8'h05;
    head4[283] <= 8'h04;
    head4[284] <= 8'h04;
    head4[285] <= 8'h00;
    head4[286] <= 8'h01;
    head4[287] <= 8'h02;
    head4[288] <= 8'h77;
    head4[289] <= 8'h00;
    head4[290] <= 8'h01;
    head4[291] <= 8'h02;
    head4[292] <= 8'h03;
    head4[293] <= 8'h11;
    head4[294] <= 8'h04;
    head4[295] <= 8'h05;
    head4[296] <= 8'h21;
    head4[297] <= 8'h31;
    head4[298] <= 8'h06;
    head4[299] <= 8'h12;
    head4[300] <= 8'h41;
    head4[301] <= 8'h51;
    head4[302] <= 8'h07;
    head4[303] <= 8'h61;
    head4[304] <= 8'h71;
    head4[305] <= 8'h13;
    head4[306] <= 8'h22;
    head4[307] <= 8'h32;
    head4[308] <= 8'h81;
    head4[309] <= 8'h08;
    head4[310] <= 8'h14;
    head4[311] <= 8'h42;
    head4[312] <= 8'h91;
    head4[313] <= 8'hA1;
    head4[314] <= 8'hB1;
    head4[315] <= 8'hC1;
    head4[316] <= 8'h09;
    head4[317] <= 8'h23;
    head4[318] <= 8'h33;
    head4[319] <= 8'h52;
    head4[320] <= 8'hF0;
    head4[321] <= 8'h15;
    head4[322] <= 8'h62;
    head4[323] <= 8'h72;
    head4[324] <= 8'hD1;
    head4[325] <= 8'h0A;
    head4[326] <= 8'h16;
    head4[327] <= 8'h24;
    head4[328] <= 8'h34;
    head4[329] <= 8'hE1;
    head4[330] <= 8'h25;
    head4[331] <= 8'hF1;
    head4[332] <= 8'h17;
    head4[333] <= 8'h18;
    head4[334] <= 8'h19;
    head4[335] <= 8'h1A;
    head4[336] <= 8'h26;
    head4[337] <= 8'h27;
    head4[338] <= 8'h28;
    head4[339] <= 8'h29;
    head4[340] <= 8'h2A;
    head4[341] <= 8'h35;
    head4[342] <= 8'h36;
    head4[343] <= 8'h37;
    head4[344] <= 8'h38;
    head4[345] <= 8'h39;
    head4[346] <= 8'h3A;
    head4[347] <= 8'h43;
    head4[348] <= 8'h44;
    head4[349] <= 8'h45;
    head4[350] <= 8'h46;
    head4[351] <= 8'h47;
    head4[352] <= 8'h48;
    head4[353] <= 8'h49;
    head4[354] <= 8'h4A;
    head4[355] <= 8'h53;
    head4[356] <= 8'h54;
    head4[357] <= 8'h55;
    head4[358] <= 8'h56;
    head4[359] <= 8'h57;
    head4[360] <= 8'h58;
    head4[361] <= 8'h59;
    head4[362] <= 8'h5A;
    head4[363] <= 8'h63;
    head4[364] <= 8'h64;
    head4[365] <= 8'h65;
    head4[366] <= 8'h66;
    head4[367] <= 8'h67;
    head4[368] <= 8'h68;
    head4[369] <= 8'h69;
    head4[370] <= 8'h6A;
    head4[371] <= 8'h73;
    head4[372] <= 8'h74;
    head4[373] <= 8'h75;
    head4[374] <= 8'h76;
    head4[375] <= 8'h77;
    head4[376] <= 8'h78;
    head4[377] <= 8'h79;
    head4[378] <= 8'h7A;
    head4[379] <= 8'h82;
    head4[380] <= 8'h83;
    head4[381] <= 8'h84;
    head4[382] <= 8'h85;
    head4[383] <= 8'h86;
    head4[384] <= 8'h87;
    head4[385] <= 8'h88;
    head4[386] <= 8'h89;
    head4[387] <= 8'h8A;
    head4[388] <= 8'h92;
    head4[389] <= 8'h93;
    head4[390] <= 8'h94;
    head4[391] <= 8'h95;
    head4[392] <= 8'h96;
    head4[393] <= 8'h97;
    head4[394] <= 8'h98;
    head4[395] <= 8'h99;
    head4[396] <= 8'h9A;
    head4[397] <= 8'hA2;
    head4[398] <= 8'hA3;
    head4[399] <= 8'hA4;
    head4[400] <= 8'hA5;
    head4[401] <= 8'hA6;
    head4[402] <= 8'hA7;
    head4[403] <= 8'hA8;
    head4[404] <= 8'hA9;
    head4[405] <= 8'hAA;
    head4[406] <= 8'hB2;
    head4[407] <= 8'hB3;
    head4[408] <= 8'hB4;
    head4[409] <= 8'hB5;
    head4[410] <= 8'hB6;
    head4[411] <= 8'hB7;
    head4[412] <= 8'hB8;
    head4[413] <= 8'hB9;
    head4[414] <= 8'hBA;
    head4[415] <= 8'hC2;
    head4[416] <= 8'hC3;
    head4[417] <= 8'hC4;
    head4[418] <= 8'hC5;
    head4[419] <= 8'hC6;
    head4[420] <= 8'hC7;
    head4[421] <= 8'hC8;
    head4[422] <= 8'hC9;
    head4[423] <= 8'hCA;
    head4[424] <= 8'hD2;
    head4[425] <= 8'hD3;
    head4[426] <= 8'hD4;
    head4[427] <= 8'hD5;
    head4[428] <= 8'hD6;
    head4[429] <= 8'hD7;
    head4[430] <= 8'hD8;
    head4[431] <= 8'hD9;
    head4[432] <= 8'hDA;
    head4[433] <= 8'hE2;
    head4[434] <= 8'hE3;
    head4[435] <= 8'hE4;
    head4[436] <= 8'hE5;
    head4[437] <= 8'hE6;
    head4[438] <= 8'hE7;
    head4[439] <= 8'hE8;
    head4[440] <= 8'hE9;
    head4[441] <= 8'hEA;
    head4[442] <= 8'hF2;
    head4[443] <= 8'hF3;
    head4[444] <= 8'hF4;
    head4[445] <= 8'hF5;
    head4[446] <= 8'hF6;
    head4[447] <= 8'hF7;
    head4[448] <= 8'hF8;
    head4[449] <= 8'hF9;
    head4[450] <= 8'hFA;
    head4[451] <= 8'hff;
    head4[452] <= 8'hda;
    head4[453] <= 8'h00;
    head4[454] <= 8'h0c;
    head4[455] <= 8'h03;
    head4[456] <= 8'h01;
    head4[457] <= 8'h00;
    head4[458] <= 8'h02;
    head4[459] <= 8'h11;
    head4[460] <= 8'h03;
    head4[461] <= 8'h11;
    head4[462] <= 8'h00;
    head4[463] <= 8'h3f;
    head4[464] <= 8'h00;
end


    
endmodule