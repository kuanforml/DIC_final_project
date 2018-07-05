module SevenHexDecoder(
	input 		 [5:0] i_deg,
	input 		 [2:0] i_mode,
	output 		 [6:0] o_seven_deg0,
	output logic [6:0] o_seven_deg1,
	output logic [6:0] o_seven_deg2,
	output logic [6:0] o_seven_deg3,
	output logic [6:0] o_seven_mode0,
	output 	 	 [6:0] o_seven_mode1,

	input			 [6:0] i_counter,
	output logic [6:0] o_seven_bug0,
	output logic [6:0] o_seven_bug1
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

	parameter DP = 7'b0001100;
	parameter DD = 7'b0011100;

	assign o_seven_deg0 = DD;
	assign o_seven_mode1 = DP;

	logic [3:0] one, ten, hund;
	logic [3:0] one_count, ten_count;
	integer deg;

	assign deg  = ({6'd0, i_deg}*45) >> 3;
	assign one  = deg       % 10;
	assign ten  = (deg/10)  % 10;
	assign hund = (deg/100) % 10;

	assign one_count = i_counter      % 10;
	assign ten_count = (i_counter/10) % 10;

	always_comb begin
		case(one)
			4'h0: o_seven_deg1 = D0;
			4'h1: o_seven_deg1 = D1;
			4'h2: o_seven_deg1 = D2;
			4'h3: o_seven_deg1 = D3;
			4'h4: o_seven_deg1 = D4;
			4'h5: o_seven_deg1 = D5;
			4'h6: o_seven_deg1 = D6;
			4'h7: o_seven_deg1 = D7;
			4'h8: o_seven_deg1 = D8;
			4'h9: o_seven_deg1 = D9;
         default: o_seven_deg1 = '1;
		endcase
		case(ten)
			4'h0: o_seven_deg2 = D0;
			4'h1: o_seven_deg2 = D1;
			4'h2: o_seven_deg2 = D2;
			4'h3: o_seven_deg2 = D3;
			4'h4: o_seven_deg2 = D4;
			4'h5: o_seven_deg2 = D5;
			4'h6: o_seven_deg2 = D6;
			4'h7: o_seven_deg2 = D7;
			4'h8: o_seven_deg2 = D8;
			4'h9: o_seven_deg2 = D9;
         default: o_seven_deg2 = '1;
		endcase
		case(hund)
			4'h0: o_seven_deg3 = 7'b1111111;
			4'h1: o_seven_deg3 = D1;
			4'h2: o_seven_deg3 = D2;
			4'h3: o_seven_deg3 = D3;
			4'h4: o_seven_deg3 = D4;
			4'h5: o_seven_deg3 = D5;
			4'h6: o_seven_deg3 = D6;
			4'h7: o_seven_deg3 = D7;
			4'h8: o_seven_deg3 = D8;
			4'h9: o_seven_deg3 = D9;
         default: o_seven_deg3 = '1;
		endcase
		case(i_mode)
			3'h0: o_seven_mode0 = D0;
			3'h1: o_seven_mode0 = D1;
			3'h2: o_seven_mode0 = D2;
			3'h3: o_seven_mode0 = D3;
			3'h4: o_seven_mode0 = D4;
			3'h5: o_seven_mode0 = D5;
			3'h6: o_seven_mode0 = D6;
			3'h7: o_seven_mode0 = D7;
		endcase
		case(one_count)
			4'h0: o_seven_bug0 = D0;
			4'h1: o_seven_bug0 = D1;
			4'h2: o_seven_bug0 = D2;
			4'h3: o_seven_bug0 = D3;
			4'h4: o_seven_bug0 = D4;
			4'h5: o_seven_bug0 = D5;
			4'h6: o_seven_bug0 = D6;
			4'h7: o_seven_bug0 = D7;
			4'h8: o_seven_bug0 = D8;
			4'h9: o_seven_bug0 = D9;
         default: o_seven_bug0 = '1;
		endcase
		case(ten_count)
			4'h0: o_seven_bug1 = 7'b1111111;
			4'h1: o_seven_bug1 = D1;
			4'h2: o_seven_bug1 = D2;
			4'h3: o_seven_bug1 = D3;
			4'h4: o_seven_bug1 = D4;
			4'h5: o_seven_bug1 = D5;
			4'h6: o_seven_bug1 = D6;
			4'h7: o_seven_bug1 = D7;
			4'h8: o_seven_bug1 = D8;
			4'h9: o_seven_bug1 = D9;
         default: o_seven_bug1 = '1;
		endcase
	end
endmodule
