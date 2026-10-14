import apb_pkg::*;

class scoreboard;
    mailbox mon_to_sb;
    transaction tr;

    bit [DATA_WIDTH-1:0] memory [bit [ADDR_WIDTH-1:0]];

    int total_writes = 0;
    int total_reads = 0;
    int passed_reads = 0;
    int failed_reads = 0;
    int error_responses = 0;

    function new(mailbox mon_to_sb);
        this.mon_to_sb = mon_to_sb;

		for(int i = 0; i < MEM_SIZE; i++)
			memory[4*i] = 32'b0;

        $display("Scoreboard initialized at time %0t", $time);
    endfunction

    task run();

        forever begin
            mon_to_sb.get(tr);
			//$display("Transaction Received for Address %d", tr.paddr);
			if (tr.pwrite) begin
				if (tr.pslverr) begin
					error_responses++;
					$display("[SB][WRITE ERROR] Address=%h is out of range, Time=%0t", tr.paddr, $time);
				end
				else begin
					memory[tr.paddr] = tr.pwdata;
					total_writes++;
					$display("[SB][WRITE] Addr=%h, Data=%h, Time=%0t", tr.paddr, tr.pwdata, $time);
				end
			end

			else begin
				total_reads++;
				//$display("%d total reads", total_reads);
				if (tr.pslverr) begin
					error_responses++;
					$display("[SB][READ ERROR] Address=%h is out of range, Time=%0t", tr.paddr, $time);
				end

				else if (tr.prdata !== memory[tr.paddr]) begin
					failed_reads++;
					$display("[SB][FAIL] Addr=%h, Expected=%h, Actual=%h, Time=%0t", tr.paddr, memory[tr.paddr], tr.prdata, $time);

				end

				else begin
					passed_reads++;
					$display("[SB][PASS] Addr=%h, Expected=%h, Actual=%h, Time=%0t", tr.paddr, memory[tr.paddr], tr.prdata, $time);
				end
			end

        end
    endtask


    task report();

        $display("\n");
        $display("========================================");
        $display("       SCOREBOARD SUMMARY");
        $display("========================================");

        $display("Total writes : %0d", total_writes);
        $display("Total reads             : %0d", total_reads);
        $display("Passed reads             : %0d", passed_reads);
        $display("Failed reads             : %0d", failed_reads);
        $display("Error responses          : %0d", error_responses);

        $display("========================================");

        if (failed_reads == 0)
            $display("DATA CHECK: PASS");
        else
            $display("DATA CHECK: FAIL");

        $display("========================================\n");
    endtask

endclass
