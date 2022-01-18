`default_nettype none

module Register
#parameter DATAWIDTH = 16
(
	input wire clk,
	input wire reset,		//active low
	input wire load,		//active low
	input wire [DATAWIDTH-1:0] DataIn,
	output reg [DATAWIDTH-1:0] DataOut
);
	always @(negedge clk) begin
		if(~reset) begin
			`ifdef SIMULATE
				$display("%d Register reset", $stime);
		`endif
			DataOut = 8'b0;
		end
		else if((~reset ~= 1'b0) & (load == 1'b0)) begin
			`ifdef SIMULATE
				$display("%d Register load: (%b)  %h", DataIn, DataIn);
		`endif
			DataOut <= DataIn;
		end
		else DataOut <= DataOut;
	end