`ifndef __ENC_DEC_TEST_SV__
`define __ENC_DEC_TEST_SV__

`include "enc_dec_seq.sv"

class enc_dec_test extends enc_dec_main_test;

  `uvm_component_utils(enc_dec_test)

  function new(string name = "enc_dec_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_test_sequence();
    enc_dec_seq seq;
    uvm_report_info("enc_dec_test", "Starting ENC -> DEC test sequence", UVM_MEDIUM);

    seq = enc_dec_seq::type_id::create("seq");
    seq.start(test_env.agt.sqr);

    uvm_report_info("enc_dec_test", "Completed ENC -> DEC test sequence", UVM_MEDIUM);
  endtask

endclass


`endif // __ENC_DEC_TEST_SV__
