class agent;
	driver drv;
	monitor mon;
	generator gen;

	mailbox gen_to_drv;
	virtual apb_if apbif;

	function new(virtual apb_if apbif, mailbox mon_to_sb, apb_coverage cov);
		$display("Agent initialized at time %0d", $time);
		gen_to_drv = new();

		gen = new(gen_to_drv);
		drv = new(apbif, gen_to_drv);
		mon = new(apbif, mon_to_sb, cov);
	endfunction
	
	task run;
		fork
			$display("agent started");
			mon.run();
			drv.run();
		join_none
	endtask
endclass
