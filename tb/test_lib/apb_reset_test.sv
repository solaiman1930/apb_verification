class apb_reset_test extends apb_base_test;

    function new(virtual apb_if apbif);
        super.new(apbif);
    endfunction


    task run();
		env.run();	
        env.agt.gen.reset();
        $display("Reset deasserted successfully.");

		for(int i = 0; i < MEM_SIZE; i++) begin
			env.agt.gen.read(4*i);
		end
		
		wait(env.sb.total_reads == 	MEM_SIZE);
		$display("Reset Test Complete");
		env.sb.report();
    endtask

endclass
