`ifndef __RANDOM_SEQ_SV__
`define __RANDOM_SEQ_SV__

`include "enc_dec_seq_item.sv"

class random_seq extends uvm_sequence #(enc_dec_seq_item);
  `uvm_object_utils(random_seq)

  function new(string name = "random_seq");
    super.new(name);
  endfunction

  virtual task body();
    enc_dec_seq_item tx;

    // Use a regular for-loop instead of foreach
    for (int i = 0; i < 10; i++) begin
      tx = enc_dec_seq_item::type_id::create($sformatf("tx_%0d", i));

      start_item(tx);
      assert(tx.randomize());
      finish_item(tx);

      tx.display();
      #10;
    end
  endtask
endclass

`endif
