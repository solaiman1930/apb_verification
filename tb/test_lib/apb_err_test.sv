class apb_err_test extends apb_base_test;
	int unsigned addr;

    function new(virtual apb_if apbif);
        super.new(apbif);
    endfunction


    task run();
        env.run();
        env.agt.gen.reset();

		repeat(REPEAT_COUNT) begin
			addr = $urandom;
			env.agt.gen.write(addr, $urandom);
			env.agt.gen.read(addr);
		end
    
        wait(env.sb.total_reads == REPEAT_COUNT);
        $display("Error Test Complete");
        env.sb.report();

    endtask

endclass

