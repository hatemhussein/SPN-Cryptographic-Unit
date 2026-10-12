// File: noop_test.sv
`ifndef __NOOP_TEST_SV__
`define __NOOP_TEST_SV__

`include "enc_dec_main_test.sv"
`include "noop_seq.sv"

class noop_test extends enc_dec_main_test;

  `uvm_component_utils(noop_test)

  function new(string name = "noop_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_test_sequence();
    noop_seq seq;
    seq = noop_seq::type_id::create("seq");
    seq.start(test_env.agt.sqr); // You must start it on the agent's sequencer
  endtask

endclass

`endif
