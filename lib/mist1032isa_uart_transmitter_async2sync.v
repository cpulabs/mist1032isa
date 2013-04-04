
`default_nettype none

module mist1032isa_uart_transmitter_async2sync #(
		parameter N = 1
	)(
		input iCLOCK,
		input inRESET,
		//Ena-Signal
		input [N-1:0] iSIGNAL,
		output [N-1:0] oSIGNAL
	);
	
	reg [N-1:0] b_buffer;
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_buffer <= {N{1'b0}};
		end
		else begin
			b_buffer <= iSIGNAL;
		end
	end
	
	assign oSIGNAL = iSIGNAL & ~b_buffer;
	
endmodule

`default_nettype wire 
