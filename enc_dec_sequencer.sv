`ifndef __ENC_DEC_SEQUENCER_SV__
`define __ENC_DEC_SEQUENCER_SV__

class enc_dec_sequencer extends uvm_sequencer #(enc_dec_seq_item);// a basic sequencer

  `uvm_component_utils(enc_dec_sequencer)

  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass


`endif // __ENC_DEC_SEQUENCER_SV__
