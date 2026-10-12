import apb_pkg::*;

class generator;
	mailbox gen_to_drv;
	transaction tr;

	function new(mailbox gen_to_drv);
		$display("Generator initialized at time %0d", $time);
		this.gen_to_drv = gen_to_drv;
	endfunction

	task reset();
		tr = new();
		tr.presetn = 0;
		gen_to_drv.put(tr);
	endtask

	task write(
		bit [ADDR_WIDTH-1:0] paddr,
		bit [DATA_WIDTH-1:0] pwdata
	);
		tr = new();
		tr.paddr = paddr;
		tr.pwdata = pwdata;
		tr.pwrite = 1;
		tr.presetn = 1;
		gen_to_drv.put(tr);
	endtask

	task read(
		bit [ADDR_WIDTH-1:0] paddr
	);
		tr = new();
		tr.paddr = paddr;
		tr.pwrite = 0;
		tr.presetn = 1;
		gen_to_drv.put(tr);

		//$display("Read Address=%d, pwrite=%d", tr.paddr, tr.pwrite);
	endtask

	task random;
		tr = new();
		if(tr.randomize()) begin 
			$display("Randomization Successful");
			if(tr.pwrite)
				write(tr.paddr, tr.pwdata);
			else
				read(tr.paddr);
		end
		else
			$display("Randomization failed");
	endtask
endclass
