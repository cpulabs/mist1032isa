`timescale 1ns/1ps
`define IF_CYCLE 20
`define TIMER_CYCLE 17


module dps_utim64_sim;
	reg iIF_CLOCK;
	reg iTIMER_CLOCK;
	//Reset
	reg inRESET;
	//CPU Interface
	reg iREQ_VALID;
	wire oREQ_BUSY;		//Ignore
	reg iREQ_RW;
	reg [4:0] iREQ_ADDR;
	reg [31:0] iREQ_DATA;
	wire oREQ_VALID;
	wire  [31:0] oREQ_DATA;
	//IRQ
	wire oIRQ_VALID;
	reg iIRQ_ACK;

	
	
	dps_utim64 TARGET(
		.iCLOCK(iIF_CLOCK),
		.iTIMER_CLOCK(iTIMER_CLOCK),
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
		.iIRQ_ACK(iIRQ_ACK)
	);
	
	always#(`IF_CYCLE/2)begin
		iIF_CLOCK = !iIF_CLOCK;
	end
	
	always#(`TIMER_CYCLE/2)begin
		iTIMER_CLOCK = !iTIMER_CLOCK;
	end
	
	initial begin
		#0
			begin
				iIF_CLOCK = 1'b0;
				iTIMER_CLOCK = 1'b0;
				inRESET = 1'b0;
				iREQ_VALID = 1'b0;
				iREQ_RW = 1'b0;
				iREQ_ADDR = 5'h0;
				iREQ_DATA = 32'h0;
				iIRQ_ACK = 1'b0;
			end
		#1
			begin
				inRESET = 1'b1;
			end
		#`IF_CYCLE
			begin
				task_cc0r_cmd(30);
				task_cc0cfgr_cmd(9);	//32bit Mode | Enable
				task_mcfgr_cmd(1);
			end
		#10000000
		begin
			$finish;
		end
	end

	
	//Main Counter Config Write
	task task_mcfgr_cmd;
		input [31:0] task_config;
		begin
			#`IF_CYCLE
				begin
					iREQ_VALID = 1'b1;
					iREQ_RW = 1'b1;
					iREQ_ADDR = 5'h0;
					iREQ_DATA = task_config;
				end
			#`IF_CYCLE
				begin
					iREQ_VALID = 1'b0;
					iREQ_RW = 1'b0;
					iREQ_ADDR = 5'h0;
					iREQ_DATA = 32'h0;
				end
		end
	endtask
	
	
	//Compare Counter 0 Config Write - 32bit
	task task_cc0cfgr_cmd;
		input [31:0] task_config;
		begin
			#`IF_CYCLE
				begin
					iREQ_VALID = 1'b1;
					iREQ_RW = 1'b1;
					iREQ_ADDR = 5'hb;
					iREQ_DATA = task_config;
				end
			#`IF_CYCLE
				begin
					iREQ_VALID = 1'b0;
					iREQ_RW = 1'b0;
					iREQ_ADDR = 5'h0;
					iREQ_DATA = 32'h0;
				end
		end
	endtask
	
	//Compare Counter 0 Write - 32bit
	task task_cc0r_cmd;
		input [31:0] task_data;
		begin
			#`IF_CYCLE
				begin
					iREQ_VALID = 1'b1;
					iREQ_RW = 1'b1;
					iREQ_ADDR = 5'h4;
					iREQ_DATA = task_data;
				end
			#`IF_CYCLE
				begin
					iREQ_VALID = 1'b0;
					iREQ_RW = 1'b0;
					iREQ_ADDR = 5'h0;
					iREQ_DATA = 32'h0;
				end
		end
	endtask
	
	
	
endmodule


