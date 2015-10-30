module SevenHexDecoder(
	input [31:0] i_hex,
	output logic [6:0] o_seven_1,
	output logic [6:0] o_seven_2,
	output logic [6:0] o_seven_3,
	output logic [6:0] o_seven_4,
	output logic [6:0] o_seven_5,
	output logic [6:0] o_seven_6,
	output logic [6:0] o_seven_7,
	output logic [6:0] o_seven_8
);
	/* The layout of seven segment display, 1: dark
	 *    00
	 *   5  1
	 *    66
	 *   4  2
	 *    33
	 */
	parameter D0 = 7'b1000000;
	parameter D1 = 7'b1111001;
	parameter D2 = 7'b0100100;
	parameter D3 = 7'b0110000;
	parameter D4 = 7'b0011001;
	parameter D5 = 7'b0010010;
	parameter D6 = 7'b0000010;
	parameter D7 = 7'b1011000;
	parameter D8 = 7'b0000000;
	parameter D9 = 7'b0010000;
	parameter DX = 7'b1111111;
	logic [31:0] now1, now2, now3, now4, now5, now6, now7, now8;
	
	always_comb begin
		now1 = i_hex;
		case(now1 % 10)
			0: o_seven_1 = D0;
			1: o_seven_1 = D1;
			2: o_seven_1 = D2;
			3: o_seven_1 = D3;
			4: o_seven_1 = D4;
			5: o_seven_1 = D5;
			6: o_seven_1 = D6;
			7: o_seven_1 = D7;
			8: o_seven_1 = D8;
			9: o_seven_1 = D9;
			default: o_seven_1 = DX;
		endcase
		now2 = now1/10;
		case(now2 % 10)
			0: o_seven_2 = D0;
			1: o_seven_2 = D1;
			2: o_seven_2 = D2;
			3: o_seven_2 = D3;
			4: o_seven_2 = D4;
			5: o_seven_2 = D5;
			6: o_seven_2 = D6;
			7: o_seven_2 = D7;
			8: o_seven_2 = D8;
			9: o_seven_2 = D9;
			default: o_seven_2 = DX;
		endcase
		now3 = now2/10;
		case(now3 % 10)
			0: o_seven_3 = D0;
			1: o_seven_3 = D1;
			2: o_seven_3 = D2;
			3: o_seven_3 = D3;
			4: o_seven_3 = D4;
			5: o_seven_3 = D5;
			6: o_seven_3 = D6;
			7: o_seven_3 = D7;
			8: o_seven_3 = D8;
			9: o_seven_3 = D9;
			default: o_seven_3 = DX;
		endcase
		now4 = now3/10;
		case(now4 % 10)
			0: o_seven_4 = D0;
			1: o_seven_4 = D1;
			2: o_seven_4 = D2;
			3: o_seven_4 = D3;
			4: o_seven_4 = D4;
			5: o_seven_4 = D5;
			6: o_seven_4 = D6;
			7: o_seven_4 = D7;
			8: o_seven_4 = D8;
			9: o_seven_4 = D9;
			default: o_seven_4 = DX;
		endcase
		now5 = now4/10;
		case(now5 % 10)
			0: o_seven_5 = D0;
			1: o_seven_5 = D1;
			2: o_seven_5 = D2;
			3: o_seven_5 = D3;
			4: o_seven_5 = D4;
			5: o_seven_5 = D5;
			6: o_seven_5 = D6;
			7: o_seven_5 = D7;
			8: o_seven_5 = D8;
			9: o_seven_5 = D9;
			default: o_seven_5 = DX;
		endcase
		now6 = now5/10;
		case(now6 % 10)
			0: o_seven_6 = D0;
			1: o_seven_6 = D1;
			2: o_seven_6 = D2;
			3: o_seven_6 = D3;
			4: o_seven_6 = D4;
			5: o_seven_6 = D5;
			6: o_seven_6 = D6;
			7: o_seven_6 = D7;
			8: o_seven_6 = D8;
			9: o_seven_6 = D9;
			default: o_seven_6 = DX;
		endcase
		now7 = now6/10;
		case(now7 % 10)
			0: o_seven_7 = D0;
			1: o_seven_7 = D1;
			2: o_seven_7 = D2;
			3: o_seven_7 = D3;
			4: o_seven_7 = D4;
			5: o_seven_7 = D5;
			6: o_seven_7 = D6;
			7: o_seven_7 = D7;
			8: o_seven_7 = D8;
			9: o_seven_7 = D9;
			default: o_seven_7 = DX;
		endcase
		now8 = now7/10;
		case(now8 % 10)
			0: o_seven_8 = D0;
			1: o_seven_8 = D1;
			2: o_seven_8 = D2;
			3: o_seven_8 = D3;
			4: o_seven_8 = D4;
			5: o_seven_8 = D5;
			6: o_seven_8 = D6;
			7: o_seven_8 = D7;
			8: o_seven_8 = D8;
			9: o_seven_8 = D9;
			default: o_seven_8 = DX;
		endcase
	end
endmodule
