

task task_disp_loadstore;
	begin
		if(TARGET.CORE.CORE_PIPELINE.EXECUTE.iDATAIO_REQ && !TARGET.CORE.CORE_PIPELINE.EXECUTE.oDATAIO_RW)begin
			$display("[INFO]Time : %d, Core(EX3) Load/Store[L], %x, %x, %x, %x", $time, TARGET.CORE.CORE_PIPELINE.EXECUTE.b_pc-32'h4, TARGET.CORE.CORE_PIPELINE.EXECUTE.b_r_spr, TARGET.CORE.CORE_PIPELINE.EXECUTE.oDATAIO_ADDR, TARGET.CORE.CORE_PIPELINE.EXECUTE.load_data);
		end
		if(TARGET.CORE.CORE_PIPELINE.EXECUTE.oDATAIO_REQ && TARGET.CORE.CORE_PIPELINE.EXECUTE.oDATAIO_RW)begin
			$display("[INFO]Time : %d, Core(EX3) Load/Store[S], %x, %x, %x, %x", $time, TARGET.CORE.CORE_PIPELINE.EXECUTE.b_pc-32'h4, TARGET.CORE.CORE_PIPELINE.EXECUTE.b_r_spr, TARGET.CORE.CORE_PIPELINE.EXECUTE.oDATAIO_ADDR, TARGET.CORE.CORE_PIPELINE.EXECUTE.for_assertion_store_real_data);
		end
	end
endtask