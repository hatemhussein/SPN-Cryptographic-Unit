`ifndef __ENC_DEC_ENV_SV__
`define __ENC_DEC_ENV_SV__

// `include "sequence.sv"
//we add any specific sequence include here
// `include "no_op_seq.sv"
`include "enc_dec_seq.sv"
`include "enc_dec_agent.sv"

class enc_dec_env extends uvm_env;
  `uvm_component_utils(enc_dec_env)
  enc_dec_agent agt;
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = enc_dec_agent::type_id::create("agt", this);
  endfunction
  
endclass


`endif // __ENC_DEC_ENV_SV__
