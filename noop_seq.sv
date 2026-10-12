// File: noop_seq.sv
`ifndef __NOOP_SEQ_SV__
`define __NOOP_SEQ_SV__

class noop_seq extends uvm_sequence #(enc_dec_seq_item);

  `uvm_object_utils(noop_seq)

  function new(string name = "noop_seq");
    super.new(name);
  endfunction

  virtual task body();
    enc_dec_seq_item tx;

    repeat (5) begin
      tx = enc_dec_seq_item::type_id::create("tx_noop");
      start_item(tx);
      tx.command    = enc_dec_seq_item::NOP;
      tx.data_in    = 16'h0000;
      tx.secret_key = 32'h00000000;
      finish_item(tx);
      tx.display();
    end
  endtask

endclass

`endif
