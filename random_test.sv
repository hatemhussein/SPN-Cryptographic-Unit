`ifndef __RANDOM_TEST_SV__
`define __RANDOM_TEST_SV__

`include "enc_dec_main_test.sv"
`include "random_seq.sv"

class random_test extends enc_dec_main_test;

  `uvm_component_utils(random_test)

  function new(string name = "random_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_test_sequence();
    random_seq seq;
    uvm_report_info("random_test", "Starting Random Sequence...", UVM_MEDIUM);

    seq = random_seq::type_id::create("seq");
    seq.start(this.test_env.agt.sqr);

    uvm_report_info("random_test", "Completed Random Sequence", UVM_MEDIUM);
  endtask
  
  virtual task run_phase(uvm_phase phase);
  super.run_phase(phase);
  run_test_sequence();  // Your sequence launcher
  endtask


endclass

`endif
