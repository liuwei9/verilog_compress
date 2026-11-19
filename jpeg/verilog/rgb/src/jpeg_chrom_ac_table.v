module jpeg_chrom_ac_table (
    input         clk     ,
    input         rst     ,

    input  [7:0]  chrom_ac_raddr,
    output [4:0]  chrom_ac_len  ,
    output [15:0] chrom_ac_code  
);

always @(posedge clk ) begin
    case (chrom_ac_raddr)
        8'd0: begin
            chrom_ac_len  <=  5'd2;
            chrom_ac_code <= 16'd0;
        end
        8'd1: begin
            chrom_ac_len  <=  5'd2;
            chrom_ac_code <= 16'd1;
        end
        8'd2: begin
            chrom_ac_len  <=  5'd3;
            chrom_ac_code <= 16'd4;
        end
        8'd3: begin
            chrom_ac_len  <=  5'd4;
            chrom_ac_code <= 16'd10;
        end
        8'd4: begin
            chrom_ac_len  <=  5'd5;
            chrom_ac_code <= 16'd24;
        end
        8'd5: begin
            chrom_ac_len  <=  5'd5;
            chrom_ac_code <= 16'd25;
        end
        8'd6: begin
            chrom_ac_len  <=  5'd6;
            chrom_ac_code <= 16'd56;
        end
        8'd7: begin
            chrom_ac_len  <=  5'd7;
            chrom_ac_code <= 16'd120;
        end
        8'd8: begin
            chrom_ac_len  <=  5'd9;
            chrom_ac_code <= 16'd500;
        end
        8'd9: begin
            chrom_ac_len  <=  5'd10;
            chrom_ac_code <= 16'd1014;
        end
        8'd10: begin
            chrom_ac_len  <=  5'd12;
            chrom_ac_code <= 16'd4084;
        end
        8'd11: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd12: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd13: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd14: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd15: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd16: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd17: begin
            chrom_ac_len  <=  5'd4;
            chrom_ac_code <= 16'd11;
        end
        8'd18: begin
            chrom_ac_len  <=  5'd6;
            chrom_ac_code <= 16'd57;
        end
        8'd19: begin
            chrom_ac_len  <=  5'd8;
            chrom_ac_code <= 16'd246;
        end
        8'd20: begin
            chrom_ac_len  <=  5'd9;
            chrom_ac_code <= 16'd501;
        end
        8'd21: begin
            chrom_ac_len  <=  5'd11;
            chrom_ac_code <= 16'd2038;
        end
        8'd22: begin
            chrom_ac_len  <=  5'd12;
            chrom_ac_code <= 16'd4085;
        end
        8'd23: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65416;
        end
        8'd24: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65417;
        end
        8'd25: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65418;
        end
        8'd26: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65419;
        end
        8'd27: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd28: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd29: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd30: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd31: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd32: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd33: begin
            chrom_ac_len  <=  5'd5;
            chrom_ac_code <= 16'd26;
        end
        8'd34: begin
            chrom_ac_len  <=  5'd8;
            chrom_ac_code <= 16'd247;
        end
        8'd35: begin
            chrom_ac_len  <=  5'd10;
            chrom_ac_code <= 16'd1015;
        end
        8'd36: begin
            chrom_ac_len  <=  5'd12;
            chrom_ac_code <= 16'd4086;
        end
        8'd37: begin
            chrom_ac_len  <=  5'd15;
            chrom_ac_code <= 16'd32706;
        end
        8'd38: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65420;
        end
        8'd39: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65421;
        end
        8'd40: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65422;
        end
        8'd41: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65423;
        end
        8'd42: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65424;
        end
        8'd43: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd44: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd45: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd46: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd47: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd48: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd49: begin
            chrom_ac_len  <=  5'd5;
            chrom_ac_code <= 16'd27;
        end
        8'd50: begin
            chrom_ac_len  <=  5'd8;
            chrom_ac_code <= 16'd248;
        end
        8'd51: begin
            chrom_ac_len  <=  5'd10;
            chrom_ac_code <= 16'd1016;
        end
        8'd52: begin
            chrom_ac_len  <=  5'd12;
            chrom_ac_code <= 16'd4087;
        end
        8'd53: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65425;
        end
        8'd54: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65426;
        end
        8'd55: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65427;
        end
        8'd56: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65428;
        end
        8'd57: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65429;
        end
        8'd58: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65430;
        end
        8'd59: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd60: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd61: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd62: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd63: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd64: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd65: begin
            chrom_ac_len  <=  5'd6;
            chrom_ac_code <= 16'd58;
        end
        8'd66: begin
            chrom_ac_len  <=  5'd9;
            chrom_ac_code <= 16'd502;
        end
        8'd67: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65431;
        end
        8'd68: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65432;
        end
        8'd69: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65433;
        end
        8'd70: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65434;
        end
        8'd71: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65435;
        end
        8'd72: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65436;
        end
        8'd73: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65437;
        end
        8'd74: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65438;
        end
        8'd75: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd76: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd77: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd78: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd79: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd80: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd81: begin
            chrom_ac_len  <=  5'd6;
            chrom_ac_code <= 16'd59;
        end
        8'd82: begin
            chrom_ac_len  <=  5'd10;
            chrom_ac_code <= 16'd1017;
        end
        8'd83: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65439;
        end
        8'd84: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65440;
        end
        8'd85: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65441;
        end
        8'd86: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65442;
        end
        8'd87: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65443;
        end
        8'd88: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65444;
        end
        8'd89: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65445;
        end
        8'd90: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65446;
        end
        8'd91: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd92: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd93: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd94: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd95: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd96: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd97: begin
            chrom_ac_len  <=  5'd7;
            chrom_ac_code <= 16'd121;
        end
        8'd98: begin
            chrom_ac_len  <=  5'd11;
            chrom_ac_code <= 16'd2039;
        end
        8'd99: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65447;
        end
        8'd100: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65448;
        end
        8'd101: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65449;
        end
        8'd102: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65450;
        end
        8'd103: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65451;
        end
        8'd104: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65452;
        end
        8'd105: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65453;
        end
        8'd106: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65454;
        end
        8'd107: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd108: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd109: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd110: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd111: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd112: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd113: begin
            chrom_ac_len  <=  5'd7;
            chrom_ac_code <= 16'd122;
        end
        8'd114: begin
            chrom_ac_len  <=  5'd11;
            chrom_ac_code <= 16'd2040;
        end
        8'd115: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65455;
        end
        8'd116: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65456;
        end
        8'd117: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65457;
        end
        8'd118: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65458;
        end
        8'd119: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65459;
        end
        8'd120: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65460;
        end
        8'd121: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65461;
        end
        8'd122: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65462;
        end
        8'd123: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd124: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd125: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd126: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd127: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd128: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd129: begin
            chrom_ac_len  <=  5'd8;
            chrom_ac_code <= 16'd249;
        end
        8'd130: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65463;
        end
        8'd131: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65464;
        end
        8'd132: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65465;
        end
        8'd133: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65466;
        end
        8'd134: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65467;
        end
        8'd135: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65468;
        end
        8'd136: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65469;
        end
        8'd137: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65470;
        end
        8'd138: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65471;
        end
        8'd139: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd140: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd141: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd142: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd143: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd144: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd145: begin
            chrom_ac_len  <=  5'd9;
            chrom_ac_code <= 16'd503;
        end
        8'd146: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65472;
        end
        8'd147: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65473;
        end
        8'd148: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65474;
        end
        8'd149: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65475;
        end
        8'd150: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65476;
        end
        8'd151: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65477;
        end
        8'd152: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65478;
        end
        8'd153: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65479;
        end
        8'd154: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65480;
        end
        8'd155: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd156: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd157: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd158: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd159: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd160: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd161: begin
            chrom_ac_len  <=  5'd9;
            chrom_ac_code <= 16'd504;
        end
        8'd162: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65481;
        end
        8'd163: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65482;
        end
        8'd164: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65483;
        end
        8'd165: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65484;
        end
        8'd166: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65485;
        end
        8'd167: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65486;
        end
        8'd168: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65487;
        end
        8'd169: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65488;
        end
        8'd170: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65489;
        end
        8'd171: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd172: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd173: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd174: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd175: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd176: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd177: begin
            chrom_ac_len  <=  5'd9;
            chrom_ac_code <= 16'd505;
        end
        8'd178: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65490;
        end
        8'd179: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65491;
        end
        8'd180: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65492;
        end
        8'd181: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65493;
        end
        8'd182: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65494;
        end
        8'd183: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65495;
        end
        8'd184: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65496;
        end
        8'd185: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65497;
        end
        8'd186: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65498;
        end
        8'd187: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd188: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd189: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd190: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd191: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd192: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd193: begin
            chrom_ac_len  <=  5'd9;
            chrom_ac_code <= 16'd506;
        end
        8'd194: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65499;
        end
        8'd195: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65500;
        end
        8'd196: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65501;
        end
        8'd197: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65502;
        end
        8'd198: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65503;
        end
        8'd199: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65504;
        end
        8'd200: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65505;
        end
        8'd201: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65506;
        end
        8'd202: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65507;
        end
        8'd203: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd204: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd205: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd206: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd207: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd208: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd209: begin
            chrom_ac_len  <=  5'd11;
            chrom_ac_code <= 16'd2041;
        end
        8'd210: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65508;
        end
        8'd211: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65509;
        end
        8'd212: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65510;
        end
        8'd213: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65511;
        end
        8'd214: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65512;
        end
        8'd215: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65513;
        end
        8'd216: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65514;
        end
        8'd217: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65515;
        end
        8'd218: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65516;
        end
        8'd219: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd220: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd221: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd222: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd223: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd224: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd225: begin
            chrom_ac_len  <=  5'd14;
            chrom_ac_code <= 16'd16352;
        end
        8'd226: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65517;
        end
        8'd227: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65518;
        end
        8'd228: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65519;
        end
        8'd229: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65520;
        end
        8'd230: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65521;
        end
        8'd231: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65522;
        end
        8'd232: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65523;
        end
        8'd233: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65524;
        end
        8'd234: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65525;
        end
        8'd235: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd236: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd237: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd238: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd239: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
        8'd240: begin
            chrom_ac_len  <=  5'd10;
            chrom_ac_code <= 16'd1018;
        end
        8'd241: begin
            chrom_ac_len  <=  5'd15;
            chrom_ac_code <= 16'd32707;
        end
        8'd242: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65526;
        end
        8'd243: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65527;
        end
        8'd244: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65528;
        end
        8'd245: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65529;
        end
        8'd246: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65530;
        end
        8'd247: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65531;
        end
        8'd248: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65532;
        end
        8'd249: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65533;
        end
        8'd250: begin
            chrom_ac_len  <=  5'd16;
            chrom_ac_code <= 16'd65534;
        end
        default: begin
            chrom_ac_len  <=  5'd0;
            chrom_ac_code <= 16'd0;
        end
    endcase
end
endmodule