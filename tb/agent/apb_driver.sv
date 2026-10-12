import apb_pkg::*;

class driver;
	virtual apb_if apbif;
	mailbox gen_to_drv;
	transaction tr;

	function new(virtual apb_if apbif, mailbox gen_to_drv);
		$display("Driver initialized at time %0d", $time);
		this.gen_to_drv = gen_to_drv;
		this.apbif = apbif;
	endfunction

	task run;
		forever begin
		gen_to_drv.get(tr);
//		$display("In driver received Transaction. Paddr = %d, pwrite = %d, presetn = %d", tr.paddr, tr.pwrite, tr.presetn);
		if(!tr.presetn)
			reset();
		else if(tr.pwrite)
			write(tr);
		else
			read(tr);
		end
	endtask

	task reset();
		apbif.presetn = 0;
		repeat(RST_CYCLE)
			@(posedge apbif.pclk);
		apbif.presetn = 1;
	endtask

	task write(transaction tr);
		wait(apbif.presetn);
		@(posedge apbif.pclk);
		apbif.paddr <= tr.paddr;
		apbif.pwrite <= tr.pwrite;
		apbif.pwdata <= tr.pwdata;
		apbif.pselx <= 1;
		apbif.penable <= 0;

		@(posedge apbif.pclk);
		apbif.penable <= 1;

		while(!apbif.pready)
			@(posedge apbif.pclk);

		@(posedge apbif.pclk);
		apbif.pselx <= 0;
		apbif.penable <= 0;
	endtask

	task read(transaction tr);
		//$display("Read Entered");
		wait(apbif.presetn);
		//$display("After reset wait");
		@(posedge apbif.pclk);
		apbif.paddr <= tr.paddr;
		apbif.pwrite <= tr.pwrite;
		apbif.pselx <= 1;
		apbif.penable <= 0;
		@(negedge apbif.pclk);
		//$display("In driver paddr = %d, pwrite = %d, pselx = %d, penable = %d", apbif.paddr, apbif.pwrite, apbif.pselx, apbif.penable);
		@(posedge apbif.pclk);
		apbif.penable <= 1;

		while(!apbif.pready)
			@(posedge apbif.pclk);

		@(posedge apbif.pclk);
		apbif.pselx <= 0;
		apbif.penable <= 0;
	endtask

endclass

