`ifndef __ENC_DEC_SEQ_SV__
`define __ENC_DEC_SEQ_SV__

`include "enc_dec_seq_item.sv"

class enc_dec_seq extends uvm_sequence #(enc_dec_seq_item);

  `uvm_object_utils(enc_dec_seq)

  // Constructor
  function new(string name = "enc_dec_seq");
    super.new(name);
  endfunction

  // Sequence body
  virtual task body();
    enc_dec_seq_item tx;
    logic [15:0] captured_cipher;
    logic [31:0] key;

    // Run a fixed test first
    uvm_report_info("enc_dec_seq", "Starting fixed ENC->DEC test", UVM_MEDIUM);
    
    key = 32'hDEADBEEF;

    // Step 1: Encryption
    tx = enc_dec_seq_item::type_id::create("tx_encrypt", null);
    start_item(tx);
    tx.command     = enc_dec_seq_item::ENC;
    tx.data_in     = 16'hABCD;
    tx.secret_key  = key;
    finish_item(tx);
    tx.display();
    captured_cipher = tx.out_data;

    // Step 2: Decryption using encrypted output
    tx = enc_dec_seq_item::type_id::create("tx_decrypt", null);
    start_item(tx);
    tx.command     = enc_dec_seq_item::DEC;
    tx.data_in     = captured_cipher;
    tx.secret_key  = key;
    finish_item(tx);
    tx.display();

    // Step 3: Invalid Command
    tx = enc_dec_seq_item::type_id::create("tx_invalid", null);
    start_item(tx);
    tx.command     = enc_dec_seq_item::UNDEFINED;
    tx.data_in     = 16'h0000;
    tx.secret_key  = key;
    finish_item(tx);
    tx.display();

    // Now add 5 randomized tests
    repeat (5) begin
      #10;

      // Random encryption
      tx = enc_dec_seq_item::type_id::create("tx_rand_enc", null);
      start_item(tx);
      assert(tx.randomize() with {
        command == enc_dec_seq_item::ENC;
      });
      finish_item(tx);
      tx.display();
      captured_cipher = tx.out_data;
      key = tx.secret_key;

      // Random decryption
      tx = enc_dec_seq_item::type_id::create("tx_rand_dec", null);
      start_item(tx);
      tx.command     = enc_dec_seq_item::DEC;
      tx.data_in     = captured_cipher;
      tx.secret_key  = key;
      finish_item(tx);
      tx.display();
    end
  endtask

endclass

`endif
