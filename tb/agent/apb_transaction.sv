class transaction;
	import apb_pkg::*;

	rand bit [ADDR_WIDTH-1:0] paddr;
	rand bit [DATA_WIDTH-1:0] pwdata;
	rand bit pwrite;
	bit penable;
	bit pselx;
	bit presetn;

	logic [DATA_WIDTH-1:0] prdata;
	logic pslverr;
	logic pready;
endclass
