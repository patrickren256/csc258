// posedge enable? doesnt require clock?
module DisplayCounter(Clock, enable, reset_n, q);
	input Clock;
	input enable;
	input reset_n;
	output [3:0] q;
	reg [3:0] count;

	always @(posedge Clock, negedge reset_n)
	begin
		if (reset_n == 1'b0)
			count[3:0] <= 4'b0000;
		else if (enable == 1'b1)
			begin
				if (count[3:0] == 4'b1111)
					count[3:0] <= 4'b0000;
				else
					count[3:0] <= count[3:0] + 4'b0001;
			end
	end
	assign q[3:0] = count[3:0];
endmodule

/*
module RateDivider(Clock, reset_n, enable, d);
	input [27:0] d;
	input reset_n;
	input Clock;
	output enable;
	reg [27:0] d_old;
	reg [27:0] count;

	always @(posedge Clock, negedge reset_n)
	begin
		if (reset_n == 1'b0)
			count[27:0] <= d[27:0];
		else if (count[27:0] == 28'd0)
			count[27:0] <= d[27:0];
		else if (d[27:0] != d_old[27:0])
			begin
				count[27:0] <= d[27:0];
				d_old[27:0] <= d[27:0];
			end
		else
			count[27:0] <= count[27:0] - 28'd1;
	end
	assign enable = (count[27:0] == 28'd0) ? 1'b1 : 1'b0;
endmodule
*/