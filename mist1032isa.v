/****************************************
	MIST1032SA Processor
	
	
	Make	:	2011/10/04
	Update	:	2013/01/19
****************************************/
`default_nettype none	
`include "global.h"


module mist1032isa(
		/****************************************
		System
		****************************************/
		input iCORE_CLOCK,
		input iBUS_CLOCK,
		input iDPS_CLOCK,
		input inRESET,
		/****************************************
		SCI
		****************************************/
		output oSCI_TXD,
		input iSCI_RXD,
		/****************************************
		Memory BUS
		****************************************/
		//Req
		output oMEMORY_REQ,
		input iMEMORY_LOCK,
		output [1:0] oMEMORY_ORDER,				//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		output oMEMORY_RW,						//1:Write | 0:Read
		output [31:0] oMEMORY_ADDR,
		//This -> Data RAM
		output [31:0] oMEMORY_DATA,
		//Data RAM -> This
		input iMEMORY_VALID,
		output oMEMORY_BUSY,
		input [63:0] iMEMORY_DATA,	
		/****************************************
		GCI BUS
		****************************************/
		//Request
		output oGCI_REQ,					//Input
		input iGCI_BUSY,
		output oGCI_RW,						//0=Read : 1=Write
		output [31:0] oGCI_ADDR,
		output [31:0] oGCI_DATA,
		//Return
		input iGCI_REQ,						//Output
		output oGCI_BUSY,
		input [31:0] iGCI_DATA,
		//Interrupt
		input iGCI_IRQ_REQ,
		input [5:0] iGCI_IRQ_NUM,
		output oGCI_IRQ_ACK,
		//Interrupt Controll
		output oIO_IRQ_CONFIG_TABLE_REQ,
		output [5:0] oIO_IRQ_CONFIG_TABLE_ENTRY,
		output oIO_IRQ_CONFIG_TABLE_FLAG_MASK,
		output oIO_IRQ_CONFIG_TABLE_FLAG_VALID,
		output [1:0] oIO_IRQ_CONFIG_TABLE_FLAG_LEVEL,
		output [31:0] oDEBUG_PC,
		output [31:0] oDEBUG0,
		/****************************************
		Debug
		****************************************/
		input iDEBUG_UART_RXD,
		output oDEBUG_UART_TXD
	);
			
			
	/****************************************
	Register and Wire
	****************************************/
	//Memory
	wire core2mem_inst_req;
	wire mem2core_inst_lock;
	wire [1:0] core2mem_inst_mmumod;
	wire [31:0] core2mem_inst_pdt;
	wire [31:0] core2mem_inst_addr;
	wire mem2core_inst_valid;
	wire core2mem_inst_lock;
	wire mem2core_inst_pagefault;
	wire mem2core_inst_queue_flush;
	wire [63:0] mem2core_inst_data;
	wire [27:0] mem2core_inst_mmu_flags;
	wire core2mem_data_req;
	wire mem2core_data_lock;
	wire [1:0] core2mem_data_order;	
	wire core2mem_data_rw;		//0=Read | 1=Write
	wire [13:0] core2mem_data_tid;
	wire [1:0] core2mem_data_mmumod;
	wire [31:0] core2mem_data_pdt;
	wire [31:0] core2mem_data_addr;
	wire [31:0] core2mem_data_data;
	wire mem2core_data_valid;
	wire mem2core_data_pagefault;
	wire core2mem_data_lock;
	wire [63:0] mem2core_data_data;
	wire [27:0] mem2core_data_flags;
	
	//IO
	wire io2cpu_sysinfo_iosr_valid;
	wire [31:0] io2cpu_sysinfo_iosr;
	wire cpu2io_req;
	wire io2cpu_busy;
	wire [1:0] cpu2io_order;
	wire cpu2io_rw;
	wire [31:0] cpu2io_addr;
	wire [31:0] cpu2io_data;
	wire io2cpu_valid;
	wire [31:0] io2cpu_data;
	wire io2cpu_interrupt_valid;
	wire cpu2io_interrupt_ack;
	wire [5:0] io2cpu_interrupt_num;
	//DPS
	wire pic2dps_req;
	wire dps2pic_busy;
	wire pic2dps_rw;	
	wire [31:0] pic2dps_addr;	
	wire [31:0] pic2dps_data;	
	wire dps2pic_req;
	wire [31:0] dps2pic_data;
	wire dps2pic_irq_valid;
	wire [5:0] dps2pic_irq_num;
	wire pic2dps_irq_ack;
	
			
	/********************************************************************************
	Processor Core
	********************************************************************************/
	wire core2io_irq_tables_req;
	wire [5:0] core2io_irq_tables_entry;
	wire core2io_irq_tables_flag_mask;
	wire core2io_irq_tables_flag_valid;
	wire [1:0] core2io_irq_tables_flag_level;
	
	
	assign oIO_IRQ_CONFIG_TABLE_REQ = core2io_irq_tables_req;
	assign oIO_IRQ_CONFIG_TABLE_ENTRY = core2io_irq_tables_entry;
	assign oIO_IRQ_CONFIG_TABLE_FLAG_MASK = core2io_irq_tables_flag_mask;
	assign oIO_IRQ_CONFIG_TABLE_FLAG_VALID = core2io_irq_tables_flag_valid;
	assign oIO_IRQ_CONFIG_TABLE_FLAG_LEVEL = core2io_irq_tables_flag_level;
	
	core #(32'h0) CORE(
		/****************************************
		System
		****************************************/
		/*
		.iIF_CLOCK(iBUS_CLOCK),
		.iCORE_CLOCK(iCORE_CLOCK),
		*/
		
		.iCLOCK(iCORE_CLOCK),
		.inRESET(inRESET),
				
		/****************************************
		GCI Controll
		****************************************/	
		//Interrupt Control
		.oIO_IRQ_CONFIG_TABLE_REQ(core2io_irq_tables_req),
		.oIO_IRQ_CONFIG_TABLE_ENTRY(core2io_irq_tables_entry),
		.oIO_IRQ_CONFIG_TABLE_FLAG_MASK(core2io_irq_tables_flag_mask),
		.oIO_IRQ_CONFIG_TABLE_FLAG_VALID(core2io_irq_tables_flag_valid),
		.oIO_IRQ_CONFIG_TABLE_FLAG_LEVEL(core2io_irq_tables_flag_level),
		/****************************************
		Instruction Memory
		****************************************/
		//Req
		.oINST_REQ(core2mem_inst_req),
		.iINST_LOCK(mem2core_inst_lock),
		.oINST_MMUMOD(core2mem_inst_mmumod),
		.oINST_PDT(core2mem_inst_pdt),
		.oINST_ADDR(core2mem_inst_addr),
		//Data RAM -> This
		.iINST_VALID(mem2core_inst_valid),
		.oINST_BUSY(core2mem_inst_lock),
		.iINST_PAGEFAULT(mem2core_inst_pagefault),
		.iINST_QUEUE_FLUSH(mem2core_inst_queue_flush),
		.iINST_DATA(mem2core_inst_data),
		.iINST_MMU_FLAGS(mem2core_inst_mmu_flags),
		/****************************************
		Data Memory
		****************************************/
		//Req
		.oDATA_REQ(core2mem_data_req),
		.iDATA_LOCK(mem2core_data_lock),
		.oDATA_ORDER(core2mem_data_order),	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.oDATA_RW(core2mem_data_rw),			//1=Write 0=Read
		.oDATA_TID(core2mem_data_tid),
		.oDATA_MMUMOD(core2mem_data_mmumod),
		.oDATA_PDT(core2mem_data_pdt),
		.oDATA_ADDR(core2mem_data_addr),
		//This -> Data RAM
		.oDATA_DATA(core2mem_data_data),
		//Data RAM -> This
		.iDATA_VALID(mem2core_data_valid),
		.iDATA_PAGEFAULT(mem2core_data_pagefault),
		.iDATA_DATA(mem2core_data_data),
		.iDATA_MMU_FLAGS(mem2core_data_flags),
		/****************************************
		IO
		****************************************/
		//Req
		.oIO_REQ(cpu2io_req),
		.iIO_BUSY(io2cpu_busy),
		.oIO_ORDER(cpu2io_order),		//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.oIO_RW(cpu2io_rw),			//0=Write 1=Read
		.oIO_ADDR(cpu2io_addr),
		//Write
		.oIO_DATA(cpu2io_data),
		//Rec
		.iIO_VALID(io2cpu_valid || b_io_write_ack),
		.iIO_DATA(io2cpu_data),
		/****************************************
		Interrupt
		****************************************/
		.iINTERRUPT_VALID(io2cpu_interrupt_valid),
		.oINTERRUPT_ACK(cpu2io_interrupt_ack),
		.iINTERRUPT_NUM(io2cpu_interrupt_num),
		/****************************************
		System Infomation
		****************************************/
		.iSYSINFO_IOSR_VALID(io2cpu_sysinfo_iosr_valid),
		.iSYSINFO_IOSR(io2cpu_sysinfo_iosr),
		.oDEBUG_PC(oDEBUG_PC),
		.oDEBUG0(oDEBUG0),
		/****************************************
		Debug
		****************************************/
		.iDEBUG_CMD_REQ(debuger2processor_cmd_req),
		.oDEBUG_CMD_BUSY(processor2debuger_cmd_busy),
		.iDEBUG_CMD_COMMAND(debuger2processor_cmd_command),
		.iDEBUG_CMD_TARGET(debuger2processor_cmd_target),
		.iDEBUG_CMD_DATA(debuger2processor_cmd_data),
		.oDEBUG_CMD_VALID(processor2debuger_cmd_valid),
		.oDEBUG_CMD_ERROR(processor2debuger_cmd_error),
		.oDEBUG_CMD_DATA(processor2debuger_cmd_data)
	);
	
	
	wire mmu_lock = iMEMORY_LOCK;
	
	wire debuger2processor_cmd_req;
	wire processor2debuger_cmd_busy;
	wire [3:0] debuger2processor_cmd_command;
	wire [11:0] debuger2processor_cmd_target;
	wire [31:0] debuger2processor_cmd_data;
	wire processor2debuger_cmd_valid;
	wire processor2debuger_cmd_error;
	wire [31:0] processor2debuger_cmd_data;
	
	
	processor_debugger DEBUGGER(
		//Clock 
		.iCLOCK(iCORE_CLOCK),
		.inRESET(inRESET),
		//To Core
		.oDEBUG_CMD_REQ(debuger2processor_cmd_req),
		.iDEBUG_CMD_BUSY(processor2debuger_cmd_busy),
		.oDEBUG_CMD_COMMAND(debuger2processor_cmd_command),
		.oDEBUG_CMD_TARGET(debuger2processor_cmd_target),
		.oDEBUG_CMD_DATA(debuger2processor_cmd_data),
		.iDEBUG_CMD_VALID(processor2debuger_cmd_valid),
		.iDEBUG_CMD_ERROR(processor2debuger_cmd_error),
		.iDEBUG_CMD_DATA(processor2debuger_cmd_data),
		//To Uart
		.iUART_RXD(iDEBUG_UART_RXD),
		.oUART_TXD(oDEBUG_UART_TXD)
	);
	
	
	/********************************************************************************
	Memory Interface
	********************************************************************************/
	//Arbiter to MMU
	wire m_arbiter2mmu_req;
	wire mmu2m_arbiter_lock;
	wire m_arbiter2mmu_data_store_ack;
	wire [1:0] m_arbiter2mmu_mmu_mode;
	wire [31:0] m_arbiter2mmu_pdt;
	wire [1:0] m_arbiter2mmu_order;
	wire m_arbiter2mmu_rw;
	wire [31:0] m_arbiter2mmu_addr;
	wire [31:0] m_arbiter2mmu_data;
	wire mmu2m_arbiter_req;
	wire m_arbiter2mmu_lock;
	wire mmu2m_arbiter_store_ack;
	wire mmu2m_arbiter_page_fault;
	wire mmu2m_arbiter_queue_flush;
	wire [63:0] mmu2m_arbiter_data;
	wire [27:0] mmu2m_arbiter_mmu_flags;

	//Memory Pipe Arbiter
	memory_pipe_arbiter MEM_ARBITER(
		.iCLOCK(iBUS_CLOCK),
		.inRESET(inRESET),
		//Data(Core -> Memory)
		.iDATA_REQ(core2mem_data_req),
		.oDATA_LOCK(mem2core_data_lock),
		.iDATA_ORDER(core2mem_data_order),
		.iDATA_RW(core2mem_data_rw),
		.iDATA_TID(core2mem_data_tid),
		.iDATA_MMUMOD(core2mem_data_mmumod),
		.iDATA_PDT(core2mem_data_pdt),
		.iDATA_ADDR(core2mem_data_addr),
		.iDATA_DATA(core2mem_data_data),
		//Data(Memory -> Core)
		.oDATA_REQ(mem2core_data_valid),
		.iDATA_BUSY(1'b0),
		.oDATA_PAGEFAULT(mem2core_data_pagefault),
		.oDATA_DATA(mem2core_data_data),
		.oDATA_MMU_FLAGS(mem2core_data_flags),
		//Inst(Core -> Memory)
		.iINST_REQ(core2mem_inst_req),
		.oINST_LOCK(mem2core_inst_lock),
		.iINST_MMUMOD(core2mem_inst_mmumod),
		.iINST_PDT(core2mem_inst_pdt),
		.iINST_ADDR(core2mem_inst_addr),
		//Inst(Memory -> Core)
		.oINST_REQ(mem2core_inst_valid),
		.iINST_BUSY(core2mem_inst_lock),
		.oINST_PAGEFAULT(mem2core_inst_pagefault),
		.oINST_QUEUE_FLUSH(mem2core_inst_queue_flush),
		.oINST_DATA(mem2core_inst_data),
		.oINST_MMU_FLAGS(mem2core_inst_mmu_flags),
		//Memory(OutPort)
		.oMEMORY_REQ(m_arbiter2mmu_req),
		.iMEMORY_LOCK(mmu2m_arbiter_lock),
		.oMEMORY_DATA_STORE_ACK(m_arbiter2mmu_data_store_ack),
		.oMEMORY_MMU_MODE(m_arbiter2mmu_mmu_mode),
		.oMEMORY_PDT(m_arbiter2mmu_pdt),
		.oMEMORY_ORDER(m_arbiter2mmu_order),
		.oMEMORY_RW(m_arbiter2mmu_rw),
		.oMEMORY_ADDR(m_arbiter2mmu_addr),
		.oMEMORY_DATA(m_arbiter2mmu_data),
		//Memory(InPort)
		.iMEMORY_VALID(mmu2m_arbiter_req),
		.oMEMORY_BUSY(m_arbiter2mmu_lock),
		.iMEMORY_STORE_ACK(mmu2m_arbiter_store_ack),
		.iMEMORY_PAGE_FAULT(mmu2m_arbiter_page_fault),
		.iMEMORY_QUEUE_FLUSH(mmu2m_arbiter_queue_flush),
		.iMEMORY_DATA(mmu2m_arbiter_data),
		.iMEMORY_MMU_FLAGS(mmu2m_arbiter_mmu_flags)
	);
	
	//MMU
	mmu_if MMU_IF(
		.iCLOCK(iBUS_CLOCK),
		.inRESET(inRESET),
		/*************************
		To Core
		*************************/
		//Core -> This
		.iCORE_REQ(m_arbiter2mmu_req),
		.oCORE_LOCK(mmu2m_arbiter_lock),
		.iCORE_DATA_STORE_ACK(m_arbiter2mmu_data_store_ack),
		.iCORE_MMU_MODE(m_arbiter2mmu_mmu_mode),		//0=NoConvertion 1=none 2=1LevelConvertion 3=2LevelConvertion
		.iCORE_PDT(m_arbiter2mmu_pdt),					//Page Table Register
		.iCORE_ORDER(m_arbiter2mmu_order),
		.iCORE_RW(m_arbiter2mmu_rw),
		.iCORE_ADDR(m_arbiter2mmu_addr),
		.iCORE_DATA(m_arbiter2mmu_data),
		//This -> Core
		.oCORE_REQ(mmu2m_arbiter_req),
		.iCORE_LOCK(m_arbiter2mmu_lock),
		.oCORE_STORE_ACK(mmu2m_arbiter_store_ack),
		.oCORE_PAGE_FAULT(mmu2m_arbiter_page_fault),
		.oCORE_QUEUE_FLUSH(mmu2m_arbiter_queue_flush),
		.oCORE_DATA(mmu2m_arbiter_data),
		.oCORE_MMU_FLAGS(mmu2m_arbiter_mmu_flags),
		/************************
		To Memory
		************************/
		//This -> Memory
		.oMEMORY_REQ(oMEMORY_REQ),
		.iMEMORY_LOCK(iMEMORY_LOCK),
		.oMEMORY_ORDER(oMEMORY_ORDER),
		.oMEMORY_RW(oMEMORY_RW),
		.oMEMORY_ADDR(oMEMORY_ADDR),
		.oMEMORY_DATA(oMEMORY_DATA),
		//Memory -> This
		.iMEMORY_REQ(iMEMORY_VALID),
		.oMEMORY_LOCK(oMEMORY_BUSY),
		.iMEMORY_DATA(iMEMORY_DATA)
	); 

	/********************************************************************************
	IO Interface
	********************************************************************************/		
	//Peripheral Interface Controller
	peripheral_interface_controller PIC(
		/****************************************
		System
		****************************************/
		.iCLOCK(iBUS_CLOCK),
		.inRESET(inRESET),
		/****************************************
		System Infomation
		****************************************/
		.oSYSINFO_IOSR_VALID(io2cpu_sysinfo_iosr_valid),
		.oSYSINFO_IOSR(io2cpu_sysinfo_iosr),			//IO Start Address
		/****************************************
		IO - CPU Connection
		****************************************/
		//Req
		.iIO_REQ(cpu2io_req),
		.oIO_BUSY(io2cpu_busy),
		.iIO_ORDER(cpu2io_order),				//if (!iIO_RW && iIO_ORDER!=2'h2) then Alignment Fault
		.iIO_RW(cpu2io_rw),					//0=Write 1=Read
		.iIO_ADDR(cpu2io_addr),
		.iIO_DATA(cpu2io_data),
		//Output
		.oIO_VALID(io2cpu_valid),
		.iIO_BUSY(1'b0),
		.oIO_DATA(io2cpu_data),
		//Interrupt
		.oIO_INTERRUPT_VALID(io2cpu_interrupt_valid),
		.iIO_INTERRUPT_ACK(cpu2io_interrupt_ack),
		.oIO_INTERRUPT_NUM(io2cpu_interrupt_num),
		/****************************************
		To DPS Connection (Not Use)
		****************************************/
		//Request
		.oDPS_REQ(pic2dps_req),				//Input
		.iDPS_BUSY(dps2pic_busy),
		.oDPS_RW(pic2dps_rw),				//0=Read : 1=Write
		.oDPS_ADDR(pic2dps_addr),
		.oDPS_DATA(pic2dps_data),
		//Return
		.iDPS_REQ(dps2pic_req),			
		.oDPS_BUSY(),
		.iDPS_DATA(dps2pic_data),
		//Interrupt
		.iDPS_IRQ_REQ(dps2pic_irq_valid),
		.iDPS_IRQ_NUM(dps2pic_irq_num),
		.oDPS_IRQ_ACK(pic2dps_irq_ack),	
		/****************************************
		To GCI Connection
		****************************************/						
		//Request
		.oGCI_REQ(oGCI_REQ),				
		.iGCI_BUSY(iGCI_BUSY),
		.oGCI_RW(oGCI_RW),				//0=Read : 1=Write
		.oGCI_ADDR(oGCI_ADDR),
		.oGCI_DATA(oGCI_DATA),
		//Return
		.iGCI_REQ(iGCI_REQ),				
		.oGCI_BUSY(oGCI_BUSY),
		.iGCI_DATA(iGCI_DATA),
		//Interrupt
		.iGCI_IRQ_REQ(iGCI_IRQ_REQ),
		.iGCI_IRQ_NUM(iGCI_IRQ_NUM),
		.oGCI_IRQ_ACK(oGCI_IRQ_ACK)
	);	
	
	
		
	/********************************************************************************
	DPS
	********************************************************************************/
	wire	[5:0]	core2dps_irq_tables_entry_tmp;
	assign			core2dps_irq_tables_entry_tmp		=	core2io_irq_tables_entry - 6'd46;
	
	default_peripheral_system DPS(
		.iCLOCK(iBUS_CLOCK),
		.iDPS_BASE_CLOCK(iDPS_CLOCK),			//49.5120MHz
		.inRESET(inRESET),
		/****************************************
		IO
		****************************************/
		//IRQ Tables	
		.iDPS_IRQ_CONFIG_TABLE_REQ(core2io_irq_tables_req && (core2io_irq_tables_entry == 6'd36 || core2io_irq_tables_entry == 6'd37)),
		.iDPS_IRQ_CONFIG_TABLE_ENTRY(core2dps_irq_tables_entry_tmp[0]),
		.iDPS_IRQ_CONFIG_TABLE_FLAG_MASK(core2io_irq_tables_flag_mask),
		.iDPS_IRQ_CONFIG_TABLE_FLAG_VALID(core2io_irq_tables_flag_valid),
		.iDPS_IRQ_CONFIG_TABLE_FLAG_LEVEL(core2io_irq_tables_flag_level),
		//Req
		.iDPS_REQ(pic2dps_req),
		.oDPS_BUSY(dps2pic_busy),
		.iDPS_RW(pic2dps_rw),					//1:Write
		.iDPS_ADDR(pic2dps_addr),
		.iDPS_DATA(pic2dps_data),
		//Output
		.oDPS_VALID(dps2pic_req),
		.oDPS_DATA(dps2pic_data),
		/****************************************
		Interrupt
		****************************************/
		.oDPS_IRQ_REQ(dps2pic_irq_valid),
		.oDPS_IRQ_NUM(dps2pic_irq_num),
		.iDPS_IRQ_ACK(pic2dps_irq_ack),
		/****************************************
		Device
		****************************************/
		.oSCI_TXD(oSCI_TXD),
		.iSCI_RXD(iSCI_RXD)
	);	
	

		
	/*********************************************************
	Write Ack(Data Pipe)
	*********************************************************/	
	//IO
	reg b_io_write_ack;
	always@(posedge iBUS_CLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_io_write_ack <= 1'b0;
		end
		else begin
			case(b_io_write_ack)
				1'b0:
					begin
						if(!io2cpu_busy && cpu2io_req && cpu2io_rw)begin
							b_io_write_ack <= 1'b1;
						end
					end
				1'b1:
					begin
						b_io_write_ack <= 1'b0;
					end
			endcase
		end
	end
	
	

	
endmodule


`default_nettype wire

