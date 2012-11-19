
`default_nettype none

module interrupt_lock___(
/*
		input				i1ST_BRANCH,
		input				i2D_BRANCH,
*/
		input				i1D_LOCK_CC,
		input				i2D_LOCK_CC,
		input				iEXECUTE_LOCK,
		input				iDISPATCH_LOCK,
		//Output
		output				oINT_LOCK
	);
	
	assign	oINT_LOCK	=	i1D_LOCK_CC || i2D_LOCK_CC;//!(!i2D_BRANCH || (i2D_BRANCH && i1ST_BRANCH)) || iEXECUTE_LOCK || iDISPATCH_LOCK;
	
endmodule



module interrupt_lock(
		input				i1ST_BRANCH,
		input				i2D_BRANCH,
		input				iEXECUTE_LOCK,
		input				iDISPATCH_LOCK,
		//Output
		output				oINT_LOCK
	);
	
	assign	oINT_LOCK	=	!(!i2D_BRANCH || (i2D_BRANCH && i1ST_BRANCH)) || iEXECUTE_LOCK || iDISPATCH_LOCK;
	
endmodule


`default_nettype wire
