class base_test;
	import apb_pkg::*;

	virtual apb_if apbif;
	environment env;
	function new(virtual apb_if apbif);
		this.apbif = apbif;
		env = new(apbif);
	endfunction
	
	task write_full(bit [DATA_WIDTH-1:0] pwdata);
		for(int i = 0; i < MEM_SIZE; i++)
			env.agt.gen.write(i, pwdata);
	endtask

	task read_full(bit [DATA_WIDTH-1:0] prdata);
		for(int i = 0; i < MEM_SIZE; i++)
			env.agt.gen.read(i, prdata);
	endtask

endclass

