// check TO START EVERYTHING WITH KEY[1] (START BUTTON OR RESET IS FINE)
module morse(LEDR, KEY, SW, CLOCK_50);
	input [2:0] SW;
	input [1:0] KEY;
	input CLOCK_50;
	output [9:0] LEDR;

	wire enable_wire;
	wire [13:0] pattern_wire;

	ShiftLeft sl0(
		.display_out(LEDR[0]),
		.clk(enable_wire),
		.reset_n(KEY[0]),
		.loadValue(KEY[1]),
		.pat_in(pattern_wire));

	RateDivider r0(
		.clk(CLOCK_50),
		.reset_n(KEY[0]),
		.enable(enable_wire),
		.d(99999999));

	LUT l0(
		.in3(SW[2:0]),
		.reset_n(KEY[0]),
		.start(KEY[1]),
		.out14(pattern_wire));
endmodule

//rate divider module
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

// shifter modules
// clock dialed with enable.
module ShiftLeft(display_out, clk, reset_n, loadValue, pat_in);
	input enable, clk, reset_n, loadValue;
	input [13:0] pat_in;
	output reg display_out;

	reg pat_out;

	always @(posedge clk, negedge reset_n)
	begin
		if (reset_n == 1'b0)
			begin
				pat_out <= 14'b0;
				display_out <= pat_out[13];
			end
		else if (loadValue == 1'b0)
			begin
				pat_out <= pat_in;
				display_out <= pat_out[13];
			end
		else begin
			display_out <= pat_out[13];
			pat_out <= {[12:0]pat_out, 1'b0};
		end
	end
endmodule

// LUT module
module LUT(in3, reset_n, start, out14);
	input [2:0] in3;
	input reset_n, start;
	output reg [13:0] out14;
	reg [13:0] outholder;

	always @(*)
	begin
		case(in3)
			3'b000: outholder <= 14'b10101000000000;
			3'b001: outholder <= 14'b11100000000000;
			3'b010: outholder <= 14'b10101110000000;
			3'b011: outholder <= 14'b10101011100000;
			3'b100: outholder <= 14'b10111011100000;
			3'b101: outholder <= 14'b11101010111000;
			3'b110: outholder <= 14'b11101011101110;
			3'b111: outholder <= 14'b11101110101000;
			default: outholder <= 14'b00000000000000;
		endcase
	end
	end

	always @(posedge start or negedge reset_n) begin
		if (reset_n == 1'b0) begin
			// reset
			out14 <= 14'b00000000000000;
		end
		else if (start == 1'b1) begin
			out14 <= outholder;
		end
		else begin
			out14 <= 14'b0;
		end
	end
endmodule