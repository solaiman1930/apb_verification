class monitor;
	virtual apb_if apbif;
	mailbox mon_to_sb;
	transaction tr;
	apb_coverage cov;

	function new(virtual apb_if apbif, mailbox mon_to_sb, apb_coverage cov);
		$display("Monitor initialized at time %0d", $time);
		this.mon_to_sb = mon_to_sb;
		this.apbif = apbif;
		this.cov = cov;
	endfunction

	task run;
		forever begin
			wait(apbif.presetn);
			//$display("pselx=%d, penable=%d, pready=%d", apbif.pselx, apbif.penable, apbif.pready);
//
//			$display("Monitor Started at time %0d", $time);

			do begin
				@(posedge apbif.pclk);
			end
			while(!(apbif.pselx && apbif.penable && apbif.pready));

			tr = new();
				
			tr.paddr = apbif.paddr;
			tr.pwrite = apbif.pwrite;
			tr.pwdata = apbif.pwdata;
			tr.pselx = apbif.pselx;
			tr.prdata = apbif.prdata;
			tr.pslverr = apbif.pslverr;
			tr.penable = apbif.penable;
			tr.pready = apbif.pready;

			cov.sample(tr.paddr, tr.pwrite, tr.pwdata, tr.pslverr);
			
			//$display("In monitor paddr = %d, pwrite = %d", tr.paddr, tr.pwrite);
//			$display("paddr=%d, pwrite=%d, pwdata=%d, pselx=%d, prdata=%d, pslverr=%d, penable=%d, pready=%d time=%0d", tr.paddr, tr.pwrite, tr.pwdata, tr.pselx, tr.prdata, tr.pslverr, tr.penable, tr.pready, $time);
			mon_to_sb.put(tr);

		end
	endtask
endclass
			
