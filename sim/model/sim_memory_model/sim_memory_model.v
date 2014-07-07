/****************************************************
SIM Memory Model
	with byte & half_word access controller

Version : 1.0.0

1.0.0 : 2014/07/05 Basic Mode


Memory Model
	Little Endian
	Ex :
		data = 0x01234567

		-Load
		load_word[0] = 0x01234567
		load_hf_word[0] = 0x0123
		load_byte[0] = 0x01

		-Store
		store_word[0], 0x89abcdef = 0x89abcdef
		store_hf_word[0], 0x89ab = 0x89ab4567
		store_byte[0], 0x89 = 0x89234567
****************************************************/

`default_nettype none

module sim_memory_model(
		input wire iCLOCK,
		input wire inRESET,
		//Req
		input wire iMEMORY_REQ,
		output wire oMEMORY_LOCK,
		input wire [1:0] iMEMORY_ORDER,				//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		input wire [3:0] iMEMORY_MASK,
		input wire iMEMORY_RW,						//1:Write | 0:Read
		input wire [25:0] iMEMORY_ADDR,
		//This -> Data RAM
		input wire [31:0] iMEMORY_DATA,
		//Data RAM -> This
		output wire oMEMORY_VALID,
		input wire iMEMORY_LOCK,
		output wire [63:0] oMEMORY_DATA
	);

	parameter P_MEM_INIT_LOAD = 1;		//0:not load | 1:load | 2:addr=data(Double Word Order) | 3:addr=data(Word Order) | 5:addr=data(Byte Order) | 7:Addr(Word)=Data(Word)
	parameter P_MEM_INIT_LOAD_FIEL = "binary_file.bin";
	parameter P_MEM_SIZE = 134217728/8;
	parameter P_DISP_WRITE = 0;			//0:No Display | 1:Display | 2:Display with endian convert
	parameter P_DISP_READ = 0;			//0:No Display | 1:Display | 2:Display with endian convert

	wire fifo_write_full;
	wire fifo_read_empty;
	wire [63:0] fifo_read_data;

	reg [63:0] b_mem_data[0:P_MEM_SIZE-1];

	integer i;

	wire system_busy = fifo_write_full;
	wire system_read_condition = iMEMORY_REQ && !iMEMORY_RW && !system_busy && !fifo_write_full;
	wire system_write_condition = iMEMORY_REQ && iMEMORY_RW && !system_busy;


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

	//Memory Write Block
	wire [63:0] write_data = func_data_mask(
		iMEMORY_ADDR[2],
		iMEMORY_MASK,
		iMEMORY_DATA,
		b_mem_data[iMEMORY_ADDR[25:3]]
	);

	always@(posedge iCLOCK)begin
		if(system_write_condition)begin
			b_mem_data[iMEMORY_ADDR[25:3]] <= write_data;
		end
	end


	//Memory
	initial begin
		#0 begin
			if(P_MEM_INIT_LOAD == 1)begin
				//Load File
				$readmemh(P_MEM_INIT_LOAD_FIEL, b_mem_data);
				//Endian Convert
				$display("[INF][sim_memory_model.v]Please wait. Endian converting for test file.");
				for(i = 0; i < P_MEM_SIZE; i = i + 1)begin
					b_mem_data[i] = func_endian_convert(b_mem_data[i]);		//[]
				end
				$display("[INF][sim_memory_model.v]Mem[0]->%x", b_mem_data[0]);
			end
			//Double Word Order
			else if(P_MEM_INIT_LOAD == 2)begin
				for(i = 0; i < P_MEM_SIZE; i = i + 1)begin
					b_mem_data[i] = func_endian_convert(i);
				end
			end
			//Word Order
			else if(P_MEM_INIT_LOAD == 3)begin
				for(i = 0; i < P_MEM_SIZE; i = i + 1)begin
					b_mem_data[i] = func_endian_convert({func_32bit(i*2+1), func_32bit(i*2)});
				end
			end
			//Byte Order
			else if(P_MEM_INIT_LOAD == 5)begin
				for(i = 0; i < P_MEM_SIZE; i = i + 1)begin
					b_mem_data[i] = func_endian_convert(
						{
							func_8bit(i*8+7),
							func_8bit(i*8+6),
							func_8bit(i*8+5),
							func_8bit(i*8+4),
							func_8bit(i*8+3),
							func_8bit(i*8+2),
							func_8bit(i*8+1),
							func_8bit(i*8)
						}
					);
				end
			end
			//Word Order(Addr=Data)
			else if(P_MEM_INIT_LOAD == 7)begin
				for(i = 0; i < P_MEM_SIZE; i = i + 1)begin
					b_mem_data[i] = func_endian_convert({func_32bit({i*2+1, 2'h0}), func_32bit({i*2, 2'h0})});
				end
			end
			//Half Word Order(Addr=Data)
			//Byte Order(Addr=Data)
			//Double Word Order(Addr=Data*2)
			//Word Order(Addr=Data*2)
			else if(P_MEM_INIT_LOAD == 11)begin
				for(i = 0; i < P_MEM_SIZE; i = i + 1)begin
					b_mem_data[i] = func_endian_convert({func_32bit({i*4+2, 2'h0}), func_32bit({i*4, 2'h0})});
				end
			end
		end
	end


	//Read Write Display
	always@(posedge iCLOCK)begin
		//Write
		if(system_write_condition && P_DISP_WRITE == 1)begin
			$display("[INFO][sim_memory_model.v] : Write Memory[%x(Byte)] = %x", iMEMORY_ADDR[25:0], write_data);
		end
		else if(system_write_condition && P_DISP_WRITE == 2)begin
			$display("[INFO][sim_memory_model.v][EC-Display] : Write Memory[%x(Byte)] = %x", iMEMORY_ADDR[25:0], func_endian_convert(write_data));
		end
		//Read
		if(system_read_condition && P_DISP_READ == 1)begin
			$display("[INFO][sim_memory_model.v] : Read Memory[%x(Byte)] = %x", iMEMORY_ADDR[25:0], b_mem_data[iMEMORY_ADDR[25:3]]);
		end
		else if(system_read_condition && P_DISP_READ == 2)begin
			$display("[INFO][sim_memory_model.v][EC-Display] : Read Memory[%x(Byte)] = %x", iMEMORY_ADDR[25:0], func_endian_convert(b_mem_data[iMEMORY_ADDR[25:3]]));
		end
	end

	function [63:0] func_endian_convert;
		input [63:0] func_data;
		reg [31:0] func_tmp;
		begin
			func_tmp = func_data[63:32];
			func_endian_convert = {
				func_tmp[7:0], func_tmp[15:8], func_tmp[23:16], func_tmp[31:24],
				func_data[7:0], func_data[15:8], func_data[23:16], func_data[31:24]
			};
		end
	endfunction

	function [31:0] func_32bit;
		input [31:0] func_data;
		begin
			func_32bit = func_data;
		end
	endfunction

	function [7:0] func_8bit;
		input [7:0] func_data;
		begin
			func_8bit = func_data;
		end
	endfunction

	mist1032isa_sync_fifo #(64, 8, 3) OUT_FIFO(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.oCOUNT(),
		.iWR_EN(system_read_condition),
		.iWR_DATA(b_mem_data[iMEMORY_ADDR[25:3]]),
		.oWR_FULL(fifo_write_full),
		.iRD_EN(!iMEMORY_LOCK  && !fifo_read_empty),
		.oRD_DATA(fifo_read_data),
		.oRD_EMPTY(fifo_read_empty)
	);

	assign oMEMORY_VALID = !iMEMORY_LOCK  && !fifo_read_empty;
	assign oMEMORY_DATA = fifo_read_data;
	assign oMEMORY_LOCK = fifo_write_full;

endmodule


`default_nettype wire



