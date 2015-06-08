


`default_nettype none

module pipeline_control_idt_read(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//System Register
		input wire [31:0] iSYSREG_IDTR,
		//Request
		input wire iRD_START,
		output wire oRD_FINISH,
		//Load Store
		output wire oLDST_USE,
		output wire oLDST_REQ,
		input wire iLDST_BUSY,
		output wire [1:0] oLDST_ORDER,	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		output wire oLDST_RW,		//0=Read 1=Write
		output wire [13:0] oLDST_ASID,
		output wire [1:0] oLDST_MMUMOD,
		output wire [31:0] oLDST_PDT,
		output wire [31:0] oLDST_ADDR,
		output wire [31:0] oLDST_DATA,
		input wire iLDST_REQ,
		input wire [31:0] iLDST_DATA,
		//IRQ_CONFIG_TABLE
		output wire oIRQ_CONF_TABLE_REQ,
		output wire [5:0] oIRQ_CONF_TABLE_ENTRY,
		output wire oIRQ_CONF_TABLE_FLAG_MASK,
		output wire oIRQ_CONF_TABLE_FLAG_VALID,
		output wire [1:0] oIRQ_CONF_TABLE_FLAG_LEVEL,
		//Interrupt Configlation Table
		output wire oICT_REQ,
		output wire [5:0] oICT_ENTRY,
		output wire oICT_CONF_MASK,
		output wire oICT_CONF_VALID,
		output wire [1:0] oICT_CONF_LEVEL
	);


	localparam L_PARAM_IDTREAD_STT_IDLE = 1'b0;
	localparam L_PARAM_IDTREAD_STT_LOAD = 1'b1;


	reg b_idt_read_state;
	reg [6:0] b_idt_read_counter;
	reg [6:0] b_idt_get_counter;
	reg b_idt_readend;
	reg b_idt_idt_data_valid;
	reg [31:0] b_idt_idt_data;


	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_idt_read_state <= L_PARAM_IDTREAD_STT_IDLE;
			b_idt_read_counter <= 7'h0;
			b_idt_get_counter <= 7'h0;
			b_idt_readend <= 1'b0;
			b_idt_idt_data_valid <= 1'b0;
			b_idt_idt_data <= {32{1'b0}};
		end
		else if(iRESET_SYNC)begin
			b_idt_read_state <= L_PARAM_IDTREAD_STT_IDLE;
			b_idt_read_counter <= 7'h0;
			b_idt_get_counter <= 7'h0;
			b_idt_readend <= 1'b0;
			b_idt_idt_data_valid <= 1'b0;
			b_idt_idt_data <= {32{1'b0}};
		end
		else begin
			case(b_idt_read_state)
				L_PARAM_IDTREAD_STT_IDLE:
					begin
						if(iRD_START)begin
							b_idt_read_state <= L_PARAM_IDTREAD_STT_LOAD;
							b_idt_read_counter <= 7'h0;
							b_idt_get_counter <= 7'h0;
						end
						b_idt_readend <= 1'b0;
						b_idt_idt_data_valid <= 1'b0;
						b_idt_idt_data <= {32{1'b0}};
					end
				L_PARAM_IDTREAD_STT_LOAD:
					begin
						if(b_idt_read_counter < 7'd64 + 7'h1)begin
							//Request Check
							if(!iLDST_BUSY)begin
								b_idt_read_counter <= b_idt_read_counter + 7'h1;
							end
						end
						//Get Check
						if(b_idt_get_counter < 7'd64 + 7'h1)begin
							if(iLDST_REQ)begin
								b_idt_get_counter <= b_idt_get_counter + 7'h1;
								b_idt_idt_data_valid <= iLDST_REQ;
								b_idt_idt_data <= iLDST_DATA;
							end
						end
						else begin
							b_idt_readend <= 1'b1;
							b_idt_read_state <= L_PARAM_IDTREAD_STT_IDLE;
						end
					end
			endcase
		end
	end


	wire idt_read_condition = (b_idt_read_state == L_PARAM_IDTREAD_STT_LOAD) && (b_idt_read_counter < (7'd64 + 7'h1)) && !iLDST_BUSY;


	assign oRD_FINISH = b_idt_readend;

	assign oIRQ_CONF_TABLE_REQ = b_idt_idt_data_valid;
	assign oIRQ_CONF_TABLE_ENTRY = b_idt_get_counter[5:0] - 6'h1;
	assign oIRQ_CONF_TABLE_FLAG_MASK = b_idt_idt_data[1];
	assign oIRQ_CONF_TABLE_FLAG_VALID	= b_idt_idt_data[0];
	assign oIRQ_CONF_TABLE_FLAG_LEVEL	= b_idt_idt_data[17:16];


	assign oICT_REQ = b_idt_idt_data_valid;
	assign oICT_ENTRY = b_idt_get_counter[5:0] - 6'h1;
	assign oICT_CONF_MASK = b_idt_idt_data[1];
	assign oICT_CONF_VALID = b_idt_idt_data[0];
	assign oICT_CONF_LEVEL = b_idt_idt_data[17:16];



	assign oLDST_USE = b_idt_read_state == L_PARAM_IDTREAD_STT_LOAD;
	assign oLDST_REQ = idt_read_condition;
	assign oLDST_ORDER = 2'h2;	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
	assign oLDST_RW = 1'b0;		//0=Read 1=Write
	assign oLDST_ASID = 14'h0;
	assign oLDST_MMUMOD = 2'h0;
	assign oLDST_PDT = 32'h0;
	assign oLDST_ADDR = iSYSREG_IDTR + {b_idt_read_counter, 3'h0};
	assign oLDST_DATA = 32'h0;

endmodule




`default_nettype wire 