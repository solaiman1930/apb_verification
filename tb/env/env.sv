`include "scb.sv"
import agent_pkg::*;

class environment;
	agent agt;
	scoreboard sb;

	mailbox mon_to_sb;
	function new(virtual apb_if apbif);
		$display("Environment initialized at time %0d", $time);
		mon_to_sb = new();
		agt = new(apbif, mon_to_sb);
		sb = new(mon_to_sb);
	endfunction

	task run;
		fork
			$display("environment started");
			agt.run();
			sb.run();
		join_none
	endtask
endclass
