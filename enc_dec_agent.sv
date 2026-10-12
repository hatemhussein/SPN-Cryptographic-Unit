`ifndef __ENC_DEC_AGENT_SV__
`define __ENC_DEC_AGENT_SV__

`include "enc_dec_sequencer.sv"
`include "enc_dec_driver.sv"
`include "enc_dec_monitor.sv"
`include "enc_dec_scoreboard.sv"

class enc_dec_agent extends uvm_agent;
  `uvm_component_utils(enc_dec_agent)
  
  enc_dec_driver drv;
  enc_dec_monitor mon;
  enc_dec_sequencer sqr;
  enc_dec_scoreboard sb; // Adding the scoreboard
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = enc_dec_driver::type_id::create("drv", this);
    mon = enc_dec_monitor::type_id::create("mon", this);
    sqr = enc_dec_sequencer::type_id::create("sqr", this);
    sb = enc_dec_scoreboard::type_id::create("sb", this); // Creating the scoreboard

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
    mon.item_collected_port.connect(sb.dut_item_collected_imp); // Connecting monitor to scoreboard
    mon.item_collected_port_ref.connect(sb.ref_item_collected_imp);
  endfunction
endclass


`endif // __ENC_DEC_AGENT_SV__
