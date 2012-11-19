
`timescale 1ns/1ns
`default_nettype none
`define CYCLE 20
`define DPS_CYCLE 19



module test_dps;
	reg iCLOCK;
	reg iDPS_BASE_CLOCK;			//49.5120MHz
	reg inRESET;
	/****************************************
	IO
	****************************************/	
	//IRQ Tables	
	reg iDPS_IRQ_CONFIG_TABLE_REQ;
	reg [5:0] iDPS_IRQ_CONFIG_TABLE_ENTRY;			//UTIM64_IRT | LSFLAGS_IRT 
	reg iDPS_IRQ_CONFIG_TABLE_FLAG_MASK;
	reg iDPS_IRQ_CONFIG_TABLE_FLAG_VALID;
	reg [1:0] iDPS_IRQ_CONFIG_TABLE_FLAG_LEVEL;
	//Req
	reg iDPS_REQ;
	wire oDPS_BUSY;
	reg iDPS_RW;			//1:Write
	reg [31:0] iDPS_ADDR;
	//
	reg [31:0] iDPS_DATA;
	//Output
	wire oDPS_VALID;
	wire [31:0] oDPS_DATA;
	/****************************************
	Interrupt
	****************************************/
	wire oDPS_IRQ_REQ;
	wire [5:0] oDPS_IRQ_NUM;
	reg iDPS_IRQ_ACK;
	/****************************************
	Device
	****************************************/
	wire oSCI_TXD;
	reg iSCI_RXD;
	
	//Clock
	always#(`CYCLE/2)begin
		iCLOCK = !iCLOCK;
	end
	always#(`DPS_CYCLE/2)begin
		iDPS_BASE_CLOCK = !iDPS_BASE_CLOCK;
	end
	
	
	task dps_conf_table_write;
		input [5:0] entry; 
		input valid;
		input mask;
		input [1:0] level;
		begin	
			#(0)begin
				iDPS_IRQ_CONFIG_TABLE_REQ = 1;
				iDPS_IRQ_CONFIG_TABLE_ENTRY = entry;
				iDPS_IRQ_CONFIG_TABLE_FLAG_VALID = valid;
				iDPS_IRQ_CONFIG_TABLE_FLAG_MASK = mask;
				iDPS_IRQ_CONFIG_TABLE_FLAG_LEVEL = level;
			end
			#(`CYCLE)begin
				iDPS_IRQ_CONFIG_TABLE_REQ = 0;
				iDPS_IRQ_CONFIG_TABLE_ENTRY = entry;
				iDPS_IRQ_CONFIG_TABLE_FLAG_VALID = valid;
				iDPS_IRQ_CONFIG_TABLE_FLAG_MASK = mask;
				iDPS_IRQ_CONFIG_TABLE_FLAG_LEVEL = level;
			end
		end
	endtask
	
	task dps_request_write;
		input rw;
		input [31:0] addr;
		input [31:0] data;
		begin
			#(0)begin				
				iDPS_REQ = 1'b1;
				iDPS_RW = rw;
				iDPS_ADDR = addr;
				iDPS_DATA = data;
			end
			#(`CYCLE)begin
				iDPS_REQ = 1'b0;
			end
		end
	endtask
	
	initial begin
		#0 begin
			iCLOCK = 0;
			iDPS_BASE_CLOCK = 0;
			inRESET = 0;
			iDPS_IRQ_CONFIG_TABLE_REQ = 0;
			iDPS_IRQ_CONFIG_TABLE_ENTRY = 0;
			iDPS_IRQ_CONFIG_TABLE_FLAG_MASK = 0;
			iDPS_IRQ_CONFIG_TABLE_FLAG_VALID = 0;
			iDPS_IRQ_CONFIG_TABLE_FLAG_LEVEL = 0;
			iDPS_REQ = 0;
			iDPS_RW = 1'b0;
			iDPS_ADDR = 32'h0;
			iDPS_DATA = 32'b0;
			iDPS_IRQ_ACK = 0;
			iSCI_RXD = 1'b1;
		end
		#1 begin
			inRESET = 1;
		end
	end
	
	integer i;
	initial begin
		//Interrupt Config Table Set
		#(`CYCLE * 100)begin
			for(i = 0; i < 64; i = i + 1)begin
				if(i == 6'd36 || i == 6'd37)begin
					dps_conf_table_write(i, 1'b1, 1'b1, 2'h0);
				end
				else begin
					dps_conf_table_write(i, 1'b0, 1'b0, 2'h0);
				end
			end
		end
		//Timer Set
		#(`CYCLE * 100)begin
			//UTIM32A Main Counter Start
			#(`CYCLE)
			dps_request_write(1, 31'h00000000, 32'h00000001);		//Main Counter Start
			//UTIM32B Main Counter Start
			#(`CYCLE)
			dps_request_write(1, 31'h00000040, 32'h00000001);		//Main Counter Start
			
			//UTIM32A_CC0R_High Write
			#(`CYCLE)
			dps_request_write(1, 31'h00000008, 32'h00000000);		
			//UTIM32A_CC0R_Low Write
			#(`CYCLE)
			dps_request_write(1, 31'h0000000C, 32'h00000FFF);		
			
			
			//UTIM32A_CC0R Start Counter:Enable, Interrupt:On, BitMode:64bit, CountMode:Periodic 
			#(`CYCLE)
			dps_request_write(1, 31'h0000002C, 32'h0000000F);		
		end
	end
	
	
	
	
	
	default_peripheral_system TARGET(
		.iCLOCK(iCLOCK),
		.iDPS_BASE_CLOCK(iDPS_BASE_CLOCK),			//49.5120MHz
		.inRESET(inRESET),
		/****************************************
		IO
		****************************************/	
		//IRQ Tables	
		.iDPS_IRQ_CONFIG_TABLE_REQ(iDPS_IRQ_CONFIG_TABLE_REQ),
		.iDPS_IRQ_CONFIG_TABLE_ENTRY(iDPS_IRQ_CONFIG_TABLE_ENTRY),			//UTIM64_IRT | LSFLAGS_IRT 
		.iDPS_IRQ_CONFIG_TABLE_FLAG_MASK(iDPS_IRQ_CONFIG_TABLE_FLAG_MASK),
		.iDPS_IRQ_CONFIG_TABLE_FLAG_VALID(iDPS_IRQ_CONFIG_TABLE_FLAG_VALID),
		.iDPS_IRQ_CONFIG_TABLE_FLAG_LEVEL(iDPS_IRQ_CONFIG_TABLE_FLAG_LEVEL),
		//Req
		.iDPS_REQ(iDPS_REQ),
		.oDPS_BUSY(oDPS_BUSY),
		.iDPS_RW(iDPS_RW),			//1:Write
		.iDPS_ADDR(iDPS_ADDR),
		//
		.iDPS_DATA(iDPS_DATA),
		//Output
		.oDPS_VALID(oDPS_VALID),
		.oDPS_DATA(oDPS_DATA),
		/****************************************
		Interrupt
		****************************************/
		.oDPS_IRQ_REQ(oDPS_IRQ_REQ),
		.oDPS_IRQ_NUM(oDPS_IRQ_NUM),
		.iDPS_IRQ_ACK(iDPS_IRQ_ACK),
		/****************************************
		Device
		****************************************/
		.oSCI_TXD(oSCI_TXD),
		.iSCI_RXD(iSCI_RXD)
	);
	
	
	
endmodule



`default_nettype wire

