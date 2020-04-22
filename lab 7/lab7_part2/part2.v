// Part 2 skeleton

module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,					//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;						// 	SW[9:7] choose color, SW[6:0] choose (x,y)
	input   [3:0]   KEY;					//	KEY[0] active low reset. KEY[3] load register with x value and y value (KEY[2]?) KEY[1] fills square (GO SIGNAL).

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	wire go;
	assign go = KEY[3];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire ld_x;
	wire ld_y;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	// datapath d0(...);
	datapathVGA d0(
		.resetn(resetn),
		.clock(CLOCK_50),
		.data_in(SW[6:0],)
		.ld_x(ld_x),
		.ld_y(ld_y),
		.x_out(x),
		.y_out(y))

    // Instansiate FSM control
    // control c0(...);
    controllerVGA c0(
    	.resetn(resetn),
    	.clock(CLOCK_50),
    	.go(go),
    	.ld_x(ld_x),
    	.ld_y(ld_y),
    	.write_en(writeEn));
    
endmodule

module datapathVGA(resetn, clock, data_in, ld_x, ld_y, x_out, y_out);
	input resetn, clock, ld_y, ld_x;
	input [6:0] data_in;
	output reg [7:0] x_out;
	output reg [6:0] y_out;

	reg [7:0] reg_x;
	reg [6:0] reg_y;

	// Output result registers
	always @(posedge clock) begin
		if (!resetn) begin
			x_out <= 7'd0;
			reg_x <= 7'd0;
			y_out <= 6'd0;
			reg_y <= 6'd0;
		end
		else begin
			x_out <= reg_x;
			y_out <= reg_y;
		end
	end

	always @(posedge clk) begin
		if (!resetn) begin
			reg_x <= 7'd0;
			reg_y <= 6'd0;
		end
		else begin
			if (ld_x)
				reg_x <= {1'b0, data_in};
			if (ld_y)
				reg_y <= data_in;
		end
	end

endmodule

module controllerVGA(resetn, clock, go, ld_x, ld_y, write_en);
	input resetn, clock, go;
	output reg ld_x, ld_y, write_en;

	reg [3:0] current_state, next_state;

	localparam  S_LOAD_X        = 4'd0,
                S_LOAD_X_WAIT   = 4'd1,
                S_LOAD_Y        = 4'd2,
                S_LOAD_Y_WAIT   = 4'd3,
                S_LOAD_EN        = 4'd4;

    always @(*) 
    begin: state_table
    		case(current_state)
    			S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X;
    			S_LOAD_X_WAIT: next_state = ? S_LOAD_X_WAIT : S_LOAD_Y;
    			S_LOAD_Y: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_Y_WAIT;
    			S_LOAD_Y_WAIT: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_EN
    			S_LOAD_EN: next_state = S_LOAD_X
    end // state_table


    //output logic aka all of our datapath control signals
    always @(*)
    begin enable_signals
    	// by default make all our signals 0
    	ld_x = 1'b0;
    	ld_y = 1'b0;
    	write_en = 1'b0;

    	case (current_state)
    		S_LOAD_X: begin
    			ld_x = 1'b1;
    		end
    		S_LOAD_Y: begin
    			ld_y = 1'b1;
    		end
    		S_LOAD_EN: begin
    			write_en = 1'b1;
    		end
    	endcase

    end // enable_signals

    // current_state registers
    always @(posedge clk) begin
    	if (!resetn) begin
    		current_state <= S_LOAD_X;
    	end
    	else
    		current_state <= next_state;
    	end
    end

endmodule















