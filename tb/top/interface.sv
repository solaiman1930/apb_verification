interface apb_if(input pclk);
	import apb_pkg::*;

	logic [ADDR_WIDTH-1:0] paddr;
	logic [DATA_WIDTH-1:0] pwdata;
	logic pselx;
	logic penable;
	logic pwrite;
	logic presetn;
	
	logic [DATA_WIDTH-1:0] prdata;
	logic pready;
	logic pslverr;

/*
	clocking driver_cb @(negedge pclk);
		default input #1 output #1;
		input prdata, pready, pslverr;
		output paddr, pwdata, pselx, penable, pwrite;
	endclocking

	clocking monitor_cb @(negedge pclk);
		default input #1 output #1;
		input paddr, pwdata, pselx, penable, pwrite, prdata, pready, pslverr;
	endclocking

	modport DRIVER (clocking driver_cb, input pclk, input presetn);
	modport MONITOR (clocking monitor_cb, input pclk, input presetn);
*/
endinterface
