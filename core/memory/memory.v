
`default_nettype none

module memory(
					input					iCLOCK,
					input					inRESET,
					input					iPREVIOUS_VALID,
					input	[31:0]			iPREVIOUS_DATA,
					input	[4:0]			iPREVIOUS_DESTINATION,
					input					iPREVIOUS_DESTINATION_SYSREG,
					input					iPREVIOUS_WRITEBACK,
					input					iPREVIOUS_MEM_VALID,
					input	[31:0]			iPREVIOUS_MEM_ADDR,
					input	[31:0]			iPREVIOUS_MEM_DATA,
					input					iPREVIOUS_MEM_RW,
					input	[1:0]			iPREVIOUS_MEM_ORDER,
					output					oPREVIOUS_LOCK,
					//Data Port
					output					oDATAIO_REQ,
					input					iDATAIO_BUSY,
					output	[1:0]			oDATAIO_ORDER,	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
					output					oDATAIO_RW,		//0=Read 1=Write
					output	[13:0]			oDATAIO_TID,
					output	[1:0]			oDATAIO_MMUMOD,
					output	[31:0]			oDATAIO_PDT,
					output	[31:0]			oDATAIO_ADDR,
					output	[31:0]			oDATAIO_DATA,
					input					iDATAIO_REQ,
					input	[31:0]			iDATAIO_DATA,
					//Next
					output					oNEXT_VALID,
					output	[31:0]			oNEXT_DATA,
					output	[4:0]			oNEXT_DESTINATION,
					output					oNEXT_DESTINATION_SYSREG,
					output					oNEXT_WRITEBACK
	);
		
	wire	lock_condition		=		iDATAIO_BUSY;// || iNEXT_LOCK;
	assign	oPREVIOUS_LOCK		=		lock_condition;
		
	assign		oDATAIO_REQ			=		b_dataio_reg;
	assign		oDATAIO_ORDER		=		b_dataio_order;
	assign		oDATAIO_RW			=		b_dataio_rw;
	assign		oDATAIO_ADDR		=		b_dataio_addr;
	assign		oDATAIO_DATA		=		b_dataio_data;
	
	reg				b_dataio_state;
	reg				b_dataio_reg;
	reg		[1:0]	b_dataio_order;
	reg				b_dataio_rw;
	reg		[31:0]	b_dataio_addr;
	reg		[31:0]	b_dataio_data;

	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_dataio_state		<=		1'b0;
			b_dataio_reg		<=		1'b0;
			b_dataio_order		<=		2'h0;
			b_dataio_rw			<=		1'b0;
			b_dataio_addr		<=		32'h0;
			b_dataio_data		<=		32'h0;
		end
		else if(iFREE_REFRESH)begin
			b_dataio_state		<=		1'b0;
			b_dataio_reg		<=		1'b0;
			b_dataio_order		<=		2'h0;
			b_dataio_rw			<=		1'b0;
			b_dataio_addr		<=		32'h0;
			b_dataio_data		<=		32'h0;
		end
		else begin
			//DATAIO
			case(b_dataio_state)
				1'b0:
					begin
						if(iPREVIOUS_MEM_VALID && !lock_condition)begin
							b_dataio_state		<=		1'b1;
							b_dataio_reg		<=		iPREVIOUS_MEM_VALID;
							b_dataio_order		<=		iPREVIOUS_MEM_ORDER;
							b_dataio_rw			<=		iPREVIOUS_MEM_RW;
							b_dataio_addr		<=		iPREVIOUS_MEM_ADDR;
							b_dataio_data		<=		iPREVIOUS_MEM_DATA;
						end
					end
				1'b1:
					begin
						b_dataio_reg		<=		1'b0;
						if(iDATAIO_REQ)begin
							b_dataio_state		<=		1'b0;
						end
					end
			endcase
		end
	end
	
	
	reg				b_next_state;
	reg				b_next_valid;
	reg		[31:0]	b_next_data;
	reg		[4:0]	b_next_destination;
	reg				b_next_destination_sysreg;
	reg				b_next_writeback;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_next_state				<=		1'b0;
			b_next_valid				<=		1'b0;
			b_next_data					<=		{32{1'b0}};
			b_next_destination			<=		5'h0;
			b_next_destination_sysreg	<=		1'b0;
			b_next_writeback			<=		1'b0;
		end
		else if(iFREE_REFRESH)begin
			b_next_state				<=		1'b0;
			b_next_valid				<=		1'b0;
			b_next_data					<=		{32{1'b0}};
			b_next_destination			<=		5'h0;
			b_next_destination_sysreg	<=		1'b0;
			b_next_writeback			<=		1'b0;
		end
		else begin
			//NEXT
			case(b_next_state)
				1'b0:
					begin					
						if(!lock_condition)begin
							if(iPREVIOUS_MEM_VALID)begin
								b_next_state				<=		1'b1;
								b_next_valid				<=		1'b0;
								b_next_data					<=		{32{1'b0}};
								b_next_destination			<=		iPREVIOUS_DESTINATION;
								b_next_destination_sysreg	<=		iPREVIOUS_DESTINATION_SYSREG;
								b_next_writeback			<=		iPREVIOUS_WRITEBACK;
							end
							else if(iPREVIOUS_VALID)begin
								b_next_state				<=		1'b0;
								b_next_valid				<=		iPREVIOUS_VALID;
								b_next_data					<=		iPREVIOUS_DATA;
								b_next_destination			<=		iPREVIOUS_DESTINATION;
								b_next_destination_sysreg	<=		iPREVIOUS_DESTINATION_SYSREG;
								b_next_writeback			<=		iPREVIOUS_WRITEBACK;
							end
							else begin
								b_next_valid				<=		1'b0;
							end
						end
					end
				1'b1:
					begin
						if(iDATAIO_REQ)begin
							b_next_state				<=		1'b0;
							b_next_valid				<=		iDATAIO_REQ;
							b_next_data					<=		iDATAIO_DATA;
							b_next_destination			<=		b_next_destination;
							b_next_destination_sysreg	<=		b_next_destination_sysreg;
							b_next_writeback			<=		b_next_writeback;
						end
					end
			endcase
		end
	end
	
	
	assign		oNEXT_VALID					=		b_next_valid;
	assign		oNEXT_DATA					=		b_next_data;
	assign		oNEXT_DESTINATION			=		b_next_destination;
	assign		oNEXT_DESTINATION_SYSREG	=		b_next_destination_sysreg;
	assign		oNEXT_WRITEBACK				=		b_next_writeback;
		
		
endmodule


`default_nettype wire

