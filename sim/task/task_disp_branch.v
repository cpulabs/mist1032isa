

task task_disp_branch;
	begin
		if(TARGET.CORE.CORE_PIPELINE.EXECUTE.oJUMP_VALID)begin
			$display("[INFO]Time : %d, Core(EX) Branch : %x(PCR) -> %x(PCR)", $time, TARGET.CORE.CORE_PIPELINE.EXECUTE.b_pc, TARGET.CORE.CORE_PIPELINE.EXECUTE.oBRANCH_ADDR);
		end
	end
endtask
