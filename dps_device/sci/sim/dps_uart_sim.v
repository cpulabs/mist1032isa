`timescale 1ns/1ps
`define IF_CYCLE 20
`define DPS_CYCLE 23


module dps_sci_sim;
	reg iIF_CLOCK;
	reg iDPS_CLOCK;
	//Reset
	reg inRESET;
	//CPU Interface
	reg iREQ_VALID;
	wire oREQ_BUSY;		//Ignore
	reg iREQ_RW;
	reg [1:0] iREQ_ADDR;
	reg [31:0] iREQ_DATA;
	wire oREQ_VALID;
	wire  [31:0] oREQ_DATA;
	//IRQ
	wire oIRQ_VALID;
	reg iIRQ_ACK;
	//UART
	wire oUART_TXD;
	reg iUART_RXD;
	
	
	dps_sci TARGET(
		.iIF_CLOCK(iIF_CLOCK),
		.iDPS_BASE_CLOCK(iDPS_CLOCK),
		//Reset
		.inRESET(inRESET),
		//CPU Interface
		.iREQ_VALID(iREQ_VALID),
		.oREQ_BUSY(oREQ_BUSY),		//Ignore
		.iREQ_RW(iREQ_RW),
		.iREQ_ADDR(iREQ_ADDR),
		.iREQ_DATA(iREQ_DATA),
		.oREQ_VALID(oREQ_VALID),
		.oREQ_DATA(oREQ_DATA),
		//IRQ
		.oIRQ_VALID(oIRQ_VALID),
		.iIRQ_ACK(iIRQ_ACK),
		//UART
		.oUART_TXD(oUART_TXD),
		.iUART_RXD(iUART_RXD)
	);
	
	
	always#(`IF_CYCLE/2)begin
		iIF_CLOCK = !iIF_CLOCK;
	end
	
	always#(`DPS_CYCLE/2)begin
		iDPS_CLOCK = !iDPS_CLOCK;
	end
	
	initial begin
		#0
			begin
				iIF_CLOCK = 1'b0;
				iDPS_CLOCK = 1'b0;
				inRESET = 1'b0;
				iREQ_VALID = 1'b0;
				iREQ_RW = 1'b0;
				iREQ_ADDR = 2'h0;
				iREQ_DATA = 32'h0;
				iIRQ_ACK = 1'b0;
				iUART_RXD = 1'b1;
			end
		#1
			begin
				inRESET = 1'b1;
			end
		#`IF_CYCLE
			begin
				task_config_cmd(1);		//Transmit Enable
				task_data_write_cmd(20);
			end
		#10000000
		begin
			$finish;
		end
	end
	
	task task_data_write_cmd;
		input [31:0] task_data;
		begin
			#`IF_CYCLE
				begin
					iREQ_VALID = 1'b1;
					iREQ_RW = 1'b1;
					iREQ_ADDR = 2'h0;
					iREQ_DATA = task_data;
				end
			#`IF_CYCLE
				begin
					iREQ_VALID = 1'b0;
					iREQ_RW = 1'b0;
					iREQ_ADDR = 2'h0;
					iREQ_DATA = 32'h0;
				end
		end
	endtask
	
	task task_config_cmd;
		input [31:0] task_config;
		begin
			#`IF_CYCLE
				begin
					iREQ_VALID = 1'b1;
					iREQ_RW = 1'b1;
					iREQ_ADDR = 2'h2;
					iREQ_DATA = task_config;
				end
			#`IF_CYCLE
				begin
					iREQ_VALID = 1'b0;
					iREQ_RW = 1'b0;
					iREQ_ADDR = 2'h0;
					iREQ_DATA = 32'h0;
				end
		end
	endtask
	
	
endmodule



