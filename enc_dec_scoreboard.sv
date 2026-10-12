`ifndef __ENC_DEC_SCOREBOARD_SV__
`define __ENC_DEC_SCOREBOARD_SV__

class enc_dec_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(enc_dec_scoreboard)

  // Analysis ports to connect to monitor and reference model
  uvm_analysis_imp#(enc_dec_seq_item, enc_dec_scoreboard) dut_item_collected_imp;
  uvm_blocking_put_imp#(enc_dec_seq_item, enc_dec_scoreboard) ref_item_collected_imp;
  
  
  enc_dec_seq_item dut_trans = new();
  enc_dec_seq_item ref_trans = new();


  function new(string name, uvm_component parent);
    super.new(name, parent);
    dut_item_collected_imp = new("dut_item_collected_imp", this);
    ref_item_collected_imp = new("ref_item_collected_imp", this);
  endfunction
  
  // Override the write function to process received transactions
  virtual function void write(enc_dec_seq_item data);
    dut_trans = data;
  endfunction
  
  virtual function void put(enc_dec_seq_item data);
    ref_trans = data;
    
  endfunction

  //just build a run_phase that just prints the contents of ref_trans and dut_trans
  // Task to print contents of dut_trans and ref_trans
 virtual task run_phase(uvm_phase phase);
  enc_dec_seq_item last_dut_trans;
  enc_dec_seq_item last_ref_trans;
  
  // Initialize last transactions to null or default values
  last_dut_trans = null;
  last_ref_trans = null;

  forever begin
    // Check if both DUT and reference model transactions are not null
    if (dut_trans != null && ref_trans != null) begin
      // Compare DUT and reference model transactions
      if (!dut_trans.compare(ref_trans)) begin
        // Print DUT transaction
        `uvm_info("scoreboard", $sformatf("DUT Transaction: Command = %0d, Data = %0h, secret_key = %0d, out_data = %0d,  valid = %0d", 
                                          dut_trans.command, dut_trans.data_in, dut_trans.secret_key,
                                          dut_trans.out_data, dut_trans.valid), UVM_MEDIUM)
        // Print reference model transaction
        `uvm_info("scoreboard", $sformatf("Reference Model Transaction: Command = %0d, Data = %0h, secret_key = %0d, out_data = %0d, valid = %0d", 
                                          ref_trans.command, ref_trans.data_in, ref_trans.secret_key,
                                          ref_trans.out_data, ref_trans.valid), UVM_MEDIUM)
        
        // Update last transactions
        last_dut_trans = dut_trans;
        last_ref_trans = ref_trans;
      end
      else
        begin
          `uvm_info("enc_dec_scoreboard", "Transactions Match: Pass", UVM_MEDIUM)
        end
    end

    // Optionally add delay to control simulation speed
    #10; // Adjust delay as per simulation requirements
  end
endtask


endclass


`endif // __ENC_DEC_SCOREBOARD_SV__
