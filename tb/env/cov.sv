import apb_pkg::*;

class apb_coverage;

    int unsigned total_samples = 0;

    covergroup apb_cg with function sample(
        input logic [ADDR_WIDTH-1:0] paddr,
        input bit pwrite,
        input logic [DATA_WIDTH-1:0] pwdata,
        input bit pslverr
    );

        cp_operation: coverpoint pwrite {
            bins read_operation = {0};
            bins write_operation = {1};
        }

        cp_address: coverpoint paddr {
            bins valid_address[12] = {[0:4*MEM_SIZE-4]};
            bins invalid_address[12] = {[4*MEM_SIZE-4:$]};
        }

        cp_data: coverpoint pwdata {
            bins data_bins[12] = {[0:$]};
        }

        cp_data_pattern: coverpoint pwdata {
            bins all_zeros = {'0};
            bins all_ones = {'1};
            bins alternating_10 = {'hAAAAAAAA};
            bins alternating_01 = {'h55555555};
        }

        cp_error: coverpoint pslverr {
            bins no_error = {0};
            bins error = {1};
        }
    endgroup

    function new();
        apb_cg = new();
    endfunction


    function void sample(
        input logic [ADDR_WIDTH-1:0] paddr,
        input bit pwrite,
        input logic [DATA_WIDTH-1:0] pwdata,
        input bit pslverr
    );

        if ($isunknown({paddr, pwrite, pwdata, pslverr}))
            return;

        apb_cg.sample(paddr, pwrite, pwdata, pslverr);

        total_samples++;

    endfunction

    function void report();

        int fd;
        real coverage_percentage;

        coverage_percentage = apb_cg.get_coverage();

        fd = $fopen("apb_functional_coverage.txt", "w");

        if (fd == 0) begin
            $error("Cannot open functional coverage report!");
            return;
        end

        $fdisplay(fd, "==========================================");
        $fdisplay(fd, "       APB FUNCTIONAL COVERAGE REPORT");
        $fdisplay(fd, "==========================================");

        $fdisplay(fd, "DATA_WIDTH       : %0d", DATA_WIDTH);
        $fdisplay(fd, "ADDR_WIDTH       : %0d", ADDR_WIDTH);
        $fdisplay(fd, "MEM_SIZE         : %0d", MEM_SIZE);
        $fdisplay(fd, "Total samples    : %0d", total_samples);

        $fdisplay(fd, "------------------------------------------");
        $fdisplay(fd, "Functional coverage: %0.2f%%",
                  coverage_percentage);

        $fdisplay(fd, "==========================================");

        $fclose(fd);

        $display("Functional coverage report generated.");
        $display("Overall functional coverage: %0.2f%%",
                 coverage_percentage);

    endfunction

endclass
