import apb_pkg::*;

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
	
	property reset_idle;
		@(posedge pclk)
		!presetn |-> (!pselx && !penable);
	endproperty

	assert property (reset_idle)
		else $error("APB master is not idle during reset");


	property setup_to_access;
		@(posedge pclk)
		disable iff (!presetn)
		(pselx && !penable) |=> (pselx && penable);
	endproperty

	assert property (setup_to_access)
		else $error("Setup was not followed by access");


	property stable_during_wait;
		@(posedge pclk)
		disable iff (!presetn)
		(pselx && penable && !pready)
		|=> (pselx && penable &&
			 $stable(paddr) &&
			 $stable(pwrite) &&
			 (!$past(pwrite) || $stable(pwdata)));
	endproperty

	assert property (stable_during_wait)
		else $error("APB signals changed during a wait state");


	property access_completion;
		@(posedge pclk)
		disable iff (!presetn)
		(pselx && penable && pready)
		|=> (!pselx || !penable);
	endproperty

	assert property (access_completion)
		else $error("Access phase did not terminate");


	property error_response_valid;
		@(posedge pclk)
		disable iff (!presetn)
		pslverr |-> (pselx && penable && pready);
	endproperty

	assert property (error_response_valid)
		else $error("PSLVERR asserted outside a completed access");


	property valid_read_data;
		@(posedge pclk)
		disable iff (!presetn)
		(pselx && penable && pready && !pwrite)
		|-> !$isunknown(prdata);
	endproperty

	assert property (valid_read_data)
		else $error("PRDATA contains X or Z during a completed read");


	property out_of_range_error;
		@(posedge pclk)
		disable iff (!presetn)
		(pselx && penable && pready && (paddr > 4*MEM_SIZE - 4))
		|-> pslverr;
	endproperty

	assert property (out_of_range_error)
		else $error("Out-of-range access did not return an error");


	property valid_address_no_error;
		@(posedge pclk)
		disable iff (!presetn)
		(pselx && penable && pready && (paddr <= 4*MEM_SIZE - 4))
		|-> !pslverr;
	endproperty

	assert property (valid_address_no_error)
		else $error("Valid access returned PSLVERR");


endinterface
