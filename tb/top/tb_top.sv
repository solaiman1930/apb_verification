module tb_top;
	import apb_pkg::*;
	import apb_test_pkg::*;
	
	bit pclk;

	initial begin
		pclk = 0;
		forever #5 pclk = ~pclk;
	end

	apb_if apbif(pclk);
	
	apb_v3_sram #(
		.ADDR_BUS_WIDTH(ADDR_WIDTH),
		.DATA_BUS_WIDTH(DATA_WIDTH),
		.MEMSIZE(MEM_SIZE)
	) dut(
		.PCLK(apbif.pclk),
		.PRESETn(apbif.presetn),
		.PADDR(apbif.paddr),
		.PSEL(apbif.pselx),
		.PENABLE(apbif.penable),
		.PWRITE(apbif.pwrite),
		.PWDATA(apbif.pwdata),
		.PRDATA(apbif.prdata),
		.PREADY(apbif.pready),
		.PSLVERR(apbif.pslverr)
	);

	initial begin
		string test_name;
		
		if_init();

		if(!$value$plusargs("TEST=%s", test_name))
			test_name = "reset_test";

		case(test_name)
			"apb_reset_test": begin
								  apb_reset_test test;
								  test = new(apbif);
								  test.run();
							  end
			"apb_seq_test": begin
							    apb_seq_test test;
								test = new(apbif);
								test.run();
							end
			"apb_b2b_test": begin
								apb_b2b_test test;
								test = new(apbif);
								test.run();
							end
			"apb_ones_test": begin
							 	 apb_ones_test test;
								 test = new(apbif);
								 test.run();
							 end
			"apb_zeros_test": begin
								  apb_zeros_test test;
								  test = new(apbif);
								  test.run();
							  end
			"apb_onezero_test": begin
								    apb_onezero_test test;
								    test = new(apbif);
								    test.run();
							    end
			"apb_zeroone_test": begin
									apb_zeroone_test test;
									test = new(apbif);
									test.run();
								end
			"apb_repeat_read_test": begin
										apb_repeat_read_test test;
										test = new(apbif);
										test.run();
									end
			"apb_repeat_write_test": begin
										 apb_repeat_write_test test;
										 test = new(apbif);
										 test.run();
									 end
			"apb_data_test": begin
								 apb_data_test test;
								 test = new(apbif);
								 test.run();
							 end
			"apb_err_test": begin
								apb_err_test test;
								test = new(apbif);
								test.run();
							end
			default:
				$display("UNKNOWN TEST NAME");
			endcase
		
		$finish;
	end

	initial begin
		$dumpfile("dump.vcd");
		$dumpvars(0, tb_top);
	end


	task if_init();
		apbif.presetn = 1;
		apbif.pselx = 0;	
 		apbif.penable = 0;
 		apbif.pwrite = 0;		
 		apbif.paddr = 0;
 		apbif.pwdata = 0;
	endtask
endmodule
