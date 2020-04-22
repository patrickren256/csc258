module counter8bit(KEY, SW, HEX0, HEX1);
	input KEY;
	input [1:0] SW;
	// SW[0] RESET (CLEAR_B) ||||| SW[1] ENABLE
	output [6:0] HEX0
	output [6:0] HEX1;

	wire [6:0] t1;
	wire [7:0] q1;


	assign t1[0] = SW[0] && q1[0];
	assign t1[1] = t1[0] && q1[1];
	assign t1[2] = t1[1] && q1[2];
	assign t1[3] = t1[2] && q1[3];
	assign t1[4] = t1[3] && q1[4];
	assign t1[5] = t1[4] && q1[5];
	assign t1[6] = t1[5] && q1[6];

	mytff mt0(.clk(KEY), .clear_b(SW[0]), .t(SW[1]), .q(q1[0]));
	mytff mt1(.clk(KEY), .clear_b(SW[0]), .t(t1[0]), .q(q1[1]));
	mytff mt2(.clk(KEY), .clear_b(SW[0]), .t(t1[1]), .q(q1[2]));
	mytff mt3(.clk(KEY), .clear_b(SW[0]), .t(t1[2]), .q(q1[3]));
	mytff mt4(.clk(KEY), .clear_b(SW[0]), .t(t1[3]), .q(q1[4]));
	mytff mt5(.clk(KEY), .clear_b(SW[0]), .t(t1[4]), .q(q1[5]));
	mytff mt6(.clk(KEY), .clear_b(SW[0]), .t(t1[5]), .q(q1[6]));
	mytff mt7(.clk(KEY), .clear_b(SW[0]), .t(t1[6]), .q(q1[7]));

	hexdecoder h0(q1[3:0], HEX0);
	hexdecoder h1(q1[7:4], HEX1);

endmodule

module mytff(clk, clear_b, t, q);
	input clk, clear_b, t;
	output reg q;

	always @(posedge clk, posedge clear_b) begin
		if (clear_b == 1'b0) begin
			// reset
			q <= 1'b0;
		end
		else if (t == 1'b1) begin
			q <= !q;
		end
	end
endmodule 

module hexdecoder(in4, out7);
	input [3:0] in4;
	wire q, w, e, r;
	assign q = in4[3];
	assign w = in4[2];
	assign e = in4[1];
	assign r = in4[0];

	output [6:0] out7;

	assign out7[0] = !q && !w && !e && r || !q && w && !e && !r || q && w && !e && r || q && !w && e && r;
	assign out7[1] = !q && w && !e && r || q && w && !r || w && e && !r || q && w && e || q && e && r;
	assign out7[2] = !q && !w && e && !r || q && w && e || q && w && !r;
	assign out7[3] = !q && w && !e && !r || !w && !e && r || w && e && r || q && w && e && r;
	assign out7[4] = !w && !e && r || !q && w && !e || !q && r;
	assign out7[5] = !q && !w && r|| !q && e && r || !q && !w && e || q && w && !e && r;
	assign out7[6] = !q && !w && !e || !q && w && e && r || q && w && !e && !r;
endmodule