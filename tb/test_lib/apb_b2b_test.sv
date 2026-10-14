class apb_b2b_test extends apb_base_test;

    function new(virtual apb_if apbif);
        super.new(apbif);
    endfunction


    task run();
		env.run();
		env.agt.gen.reset();

        for (int i = 0; i < MEM_SIZE; i++) begin
            env.agt.gen.write(4*i, $urandom);
            env.agt.gen.read(4*i);
        end

		wait(env.sb.total_reads == MEM_SIZE);
		$display("Back to Back Write and Read Test Complete");
		env.sb.report();
    endtask

endclass
