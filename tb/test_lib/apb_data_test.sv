class apb_data_test extends apb_base_test;

    function new(virtual apb_if apbif);
        super.new(apbif);
    endfunction


    task run();
        env.run();
        env.agt.gen.reset();

        for(int i = 0; i < MEM_SIZE; i++) begin 

            repeat(REPEAT_COUNT) begin
				env.agt.gen.write(4*i, $urandom);
                env.agt.gen.read(4*i);
			end
        end
    
        wait(env.sb.total_reads == MEM_SIZE*REPEAT_COUNT);
        $display("Data Integrity Test Complete");
        env.sb.report();

    endtask

endclass


