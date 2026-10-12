class apb_zeros_test extends apb_base_test;

    function new(virtual apb_if apbif);
        super.new(apbif);
    endfunction


    task run();
        env.run();
        env.agt.gen.reset();

        for (int i = 0; i < MEM_SIZE; i++) begin
            env.agt.gen.write(i, 32'b0);
        end

        for (int i = 0; i < MEM_SIZE; i++) begin
            env.agt.gen.read(i);
        end
    
        wait(env.sb.total_reads == MEM_SIZE);
        $display("All Zero Test Complete");
        env.sb.report();

    endtask

endclass

