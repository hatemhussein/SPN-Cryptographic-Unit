`ifndef __ENC_DEC_MAIN_TEST_SV__
`define __ENC_DEC_MAIN_TEST_SV__

`include "uvm_macros.svh"
`include "enc_dec_env.sv"

class enc_dec_main_test extends uvm_test;

  `uvm_component_utils(enc_dec_main_test)

  enc_dec_env test_env;

  function new(string name = "enc_dec_main_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    test_env = enc_dec_env::type_id::create("test_env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    uvm_report_info("enc_dec_main_test", "Starting base test run phase", UVM_MEDIUM);
    phase.raise_objection(this);

    // Placeholder for derived class specific sequences
    run_test_sequence();

    phase.drop_objection(this);
    uvm_report_info("enc_dec_main_test", "Completed base test run phase", UVM_MEDIUM);
  endtask

  virtual task run_test_sequence();
    // To be overridden by derived classes
  endtask

endclass


`endif // __ENC_DEC_MAIN_TEST_SV__
