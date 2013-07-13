
`default_nettype none

module sim_memory_model(
		input wire iCLOCK,
		input wire inRESET,
		//Req
		input wire iMEMORY_REQ,
		output wire oMEMORY_LOCK,
		input wire [1:0] iMEMORY_ORDER,				//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		input wire iMEMORY_RW,						//1:Write | 0:Read
		input wire [25:0] iMEMORY_ADDR,
		//This -> Data RAM
		input wire [31:0] iMEMORY_DATA,
		//Data RAM -> This
		output wire oMEMORY_VALID,
		input wire iMEMORY_LOCK,
		output wire [63:0] oMEMORY_DATA
	);
	
	parameter P_MEM_INIT_LOAD = 1;		//0=not load | 1=load

	wire system_busy = fifo_write_full;
	wire system_read_condition = iMEMORY_REQ && !iMEMORY_RW && !system_busy;
	wire system_write_condition = iMEMORY_REQ && iMEMORY_RW && !system_busy;
	
	
	function [3:0] func_byte_addressing_controllor;
		input [1:0] func_order;	//2
		input [1:0] func_address;	//0
		begin
			if(func_address == 2'h0)begin
				case(func_order)
					2'h0: func_byte_addressing_controllor = 4'b0001;
					2'h1: func_byte_addressing_controllor = 4'b0011;
					2'h2: func_byte_addressing_controllor = 4'b1111;
					default: func_byte_addressing_controllor = 4'b0000;
				endcase
			end
			else if(func_address == 2'h1)begin
				case(func_order)
					2'h0: func_byte_addressing_controllor = 4'b0010;
					2'h1: func_byte_addressing_controllor = 4'b0110;
					default: func_byte_addressing_controllor = 4'b0000;
				endcase
			end
			else if(func_address == 2'h2)begin			
				case(func_order)
					2'h0: func_byte_addressing_controllor = 4'b0100;
					2'h1: func_byte_addressing_controllor = 4'b1100;
					default: func_byte_addressing_controllor = 4'b0000;
				endcase
			end
			else begin
				func_byte_addressing_controllor = 4'b1000;
			end
		end
	endfunction
	
	
	function [63:0] func_data_mask;
		input func_word_select; //0
		input [3:0] func_byte_enable;	//1111
		input [31:0] func_new_data;
		input [63:0] func_current_data;
		reg [63:0] func_private_data;
		begin
			if(!func_word_select)begin
				func_private_data[7:0] = (func_byte_enable[0])? func_new_data[7:0] : func_current_data[7:0];
				func_private_data[15:8] = (func_byte_enable[1])? func_new_data[15:8] : func_current_data[15:8];
				func_private_data[23:16] = (func_byte_enable[2])? func_new_data[23:16] : func_current_data[23:16];
				func_private_data[31:24] = (func_byte_enable[3])? func_new_data[31:24] : func_current_data[31:24];
				func_private_data[63:32] = func_current_data[63:32];
			end
			else begin
				func_private_data[39:32] = (func_byte_enable[0])? func_new_data[7:0] : func_current_data[39:32];
				func_private_data[47:40] = (func_byte_enable[1])? func_new_data[15:8] : func_current_data[47:40];
				func_private_data[55:48] = (func_byte_enable[2])? func_new_data[23:16] : func_current_data[55:48];
				func_private_data[63:56] = (func_byte_enable[3])? func_new_data[31:24] : func_current_data[63:56];
				func_private_data[31:0] = func_current_data[31:0];
			end
			func_data_mask = func_private_data;
		end
	endfunction
	
	//Memory
	//reg [63:0] b_mem_data[0:16777216-1];
	//reg [63:0] b_mem_data[0:67108864-1];
	reg [63:0] b_mem_data[0:(134217728/8)-1];
	
	
	initial begin
		#0 begin
			if(P_MEM_INIT_LOAD)begin
				//$readmemh("lowlayer_slideshow.O1.hex", b_mem_data);
				$readmemh("uart.hex", b_mem_data);
				$display("Mem[0]->%x", b_mem_data[0]);
				$display("Mem[1]->%x", b_mem_data[1]);
				$display("Mem[2]->%x", b_mem_data[2]);
				$display("Mem[3]->%x", b_mem_data[3]);
			end
		end
	end
	
	wire [63:0] test_test_test = {
					func_data_mask(
						iMEMORY_ADDR[2],
						func_byte_addressing_controllor(
							iMEMORY_ORDER,
							iMEMORY_ADDR[1:0]
						), 
						iMEMORY_DATA, 
						b_mem_data[iMEMORY_ADDR[25:3]])
				};
	
	//Memory Write Block
	always@(posedge iCLOCK )begin
		if(system_write_condition)begin
			b_mem_data[iMEMORY_ADDR[25:3]] <= 
				{
					func_data_mask(
						iMEMORY_ADDR[2],
						func_byte_addressing_controllor(
							iMEMORY_ORDER,
							iMEMORY_ADDR[1:0]
						), 
						iMEMORY_DATA, 
						b_mem_data[iMEMORY_ADDR[25:3]])
				};
		end
	end
	

	wire fifo_write_full;
	wire fifo_read_empty;
	
	/*
	always@(posedge iCLOCK)begin
		if(!system_read_condition)begin
			$display("[Read]", b_mem_data[1]);
		end
	end
	*/

	mist1032isa_sync_fifo #(64, 8, 3) OUT_FIFO(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.oCOUNT(),
		.iWR_EN((system_read_condition) && !fifo_write_full),
		.iWR_DATA(b_mem_data[iMEMORY_ADDR[25:3]]),
		.oWR_FULL(fifo_write_full),
		.iRD_EN(!iMEMORY_LOCK  && !fifo_read_empty),
		.oRD_DATA(oMEMORY_DATA),
		.oRD_EMPTY(fifo_read_empty)
	);
	
	assign oMEMORY_VALID = !iMEMORY_LOCK  && !fifo_read_empty;
	
	assign oMEMORY_LOCK = fifo_write_full;
	
	
endmodule


	


`default_nettype wire

