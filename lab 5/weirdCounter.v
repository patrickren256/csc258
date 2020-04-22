module weirdCounter(SW, CLOCK_50, HEX0);	
	input [9:0] SW;	    	//sw[9] == reset, sw[1] sw[0] determine speed
	input CLOCK_50;			//
	output [6:0] HEX0;    	//display in hex
	wire enable;          	//enable
	reg count;     			//count passed into ratedivider.
	wire [3:0] holder;		//hexadecimal holder out of displaycounter, to be converted into hex display.

	always @(*)
	begin
		case (SW[1:0])
			2'b00: count = 0;
			2'b01: count = 49999999;
			2'b10: count = 99999999;
			2'b11: count = 199999999;
			default: count = 99999999999;
		endcase
	end

	RateDivider r0(
		.Clock(CLOCK_50), 
		.reset_n(SW[2]), 
		.enable(enable), 
		.d(count)
	);
	DisplayCounter d0(
		.Clock(CLOCK_50), 
		.enable(enable), 
		.reset_n(SW[2]), 
		.q(holder[3:0])
	);
	hexDecoder h0(
		.in4(holder[3:0]), 
		.out7(HEX0[6:0])
	);
endmodule



module DisplayCounter(clk, reset_n, enable, q);
	input clk, reset_n, enable;
	output [3:0] q;
	reg [3:0] count;
	// always @(posedge enable) ?????????????
	always @(posedge clk or negedge reset_n) begin
		if (reset_n) begin
			// reset
			count <= 4'b0000;
		end
		else if (count == 4'b1111) begin
			count <= 4'b0000;
		end
		else begin
			count <= count + 4'b0001;
		end
	end

	assign q = count;

endmodule

module RateDivider(clk, reset_n, enable, d);
	input clk, reset_n, d;
	output enable;
	reg counter;

	always @(posedge clk or negedge reset_n) 
	begin
		if (reset_n == 1'b0)
			counter <= d;
		else if (counter == 1'b0)
			counter <= d;
		else
			counter <= counter - 1;
	end

	assign enable = (counter == 0) ? 1 : 0;
endmodule

module hexdecoder(in4, out7);
	input [3:0] in4;
	output reg [6:0] out7;
	always @(*)
		begin
			case( in4[3:0] )
				4'b0000: out7[6:0] = 7'b1000000;
				4'b0001: out7[6:0] = 7'b1111001;
				4'b0010: out7[6:0] = 7'b0100100;
				4'b0011: out7[6:0] = 7'b0110000;
				4'b0100: out7[6:0] = 7'b0011001;
				4'b0101: out7[6:0] = 7'b0010010;
				4'b0110: out7[6:0] = 7'b0000010;
				4'b0111: out7[6:0] = 7'b1111000;
				4'b1000: out7[6:0] = 7'b0000000;
				4'b1001: out7[6:0] = 7'b0010000;
				4'b1010: out7[6:0] = 7'b0001000;
				4'b1011: out7[6:0] = 7'b0000011;
				4'b1100: out7[6:0] = 7'b1000110;
				4'b1101: out7[6:0] = 7'b0100001;
				4'b1110: out7[6:0] = 7'b0000110;
				4'b1111: out7[6:0] = 7'b0001110;
				default: out7[6:0] = 7'b1000000;
		end
	end
endmodule