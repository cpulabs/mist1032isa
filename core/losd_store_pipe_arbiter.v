`default_nettype none

module losd_store_pipe_arbiter(
		output							oLDST_REQ,
		input							iLDST_BUSY,	
		output	[1:0]					oLDST_ORDER,	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		output							oLDST_RW,		//0=Read 1=Write
		output	[13:0]					oLDST_TID,
		output	[1:0]					oLDST_MMUMOD,
		output	[31:0]					oLDST_PDT,	
		output	[31:0]					oLDST_ADDR,
		output	[31:0]					oLDST_DATA,
		input							iLDST_VALID,
		input	[31:0]					iLDST_DATA,
		//Selector
		input							iUSE_SEL,		//0:Execution | 1:Exception
		//Execution Module
		input							iEXE_REQ,
		output							oEXE_BUSY,
		input		[1:0]				iEXE_ORDER,	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		input							iEXE_RW,		//0=Read 1=Write
		input		[13:0]				iEXE_TID,
		input		[1:0]				iEXE_MMUMOD,
		input		[31:0]				iEXE_PDT,
		input		[31:0]				iEXE_ADDR,
		input		[31:0]				iEXE_DATA,
		output							oEXE_REQ,
		output		[31:0]				oEXE_DATA,
		//Exception Module
		input							iEXCEPT_REQ,
		output							oEXCEPT_BUSY,
		input		[1:0]				iEXCEPT_ORDER,	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		input							iEXCEPT_RW,		//0=Read 1=Write
		input		[13:0]				iEXCEPT_TID,
		input		[1:0]				iEXCEPT_MMUMOD,
		input		[31:0]				iEXCEPT_PDT,
		input		[31:0]				iEXCEPT_ADDR,
		input		[31:0]				iEXCEPT_DATA,
		output							oEXCEPT_REQ,
		output		[31:0]				oEXCEPT_DATA
	);

	
	
	//Output Port
	assign		oLDST_REQ		=	(iUSE_SEL)? iEXCEPT_REQ : iEXE_REQ;
	assign		oLDST_ORDER		=	(iUSE_SEL)? iEXCEPT_ORDER : iEXE_ORDER;
	assign		oLDST_RW		=	(iUSE_SEL)? iEXCEPT_RW : iEXE_RW;
	assign		oLDST_TID		=	(iUSE_SEL)? iEXCEPT_TID : iEXE_TID;		
	assign		oLDST_MMUMOD	=	(iUSE_SEL)? iEXCEPT_MMUMOD : iEXE_MMUMOD;		
	assign		oLDST_PDT		=	(iUSE_SEL)? iEXCEPT_PDT : iEXE_PDT;
	assign		oLDST_ADDR		=	(iUSE_SEL)? iEXCEPT_ADDR : iEXE_ADDR;
	assign		oLDST_DATA		=	(iUSE_SEL)? iEXCEPT_DATA : iEXE_DATA;
	
	//Exception Unit
	assign		oEXCEPT_BUSY	=		(iUSE_SEL)? iLDST_BUSY  : 1'b1;
	assign		oEXCEPT_REQ		=		(iUSE_SEL)? iLDST_VALID : 1'b0;
	assign		oEXCEPT_DATA	=		iLDST_DATA;
	
	//ALU-LoadStore Unit
	assign		oEXE_BUSY		=		(iUSE_SEL)? 1'b1 : iLDST_BUSY;
	assign		oEXE_REQ		=		(iUSE_SEL)? 1'b0 : iLDST_VALID;
	assign		oEXE_DATA		=		iLDST_DATA;
	
	
endmodule


`default_nettype wire
