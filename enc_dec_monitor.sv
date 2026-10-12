`ifndef __ENC_DEC_MONITOR_SV__
`define __ENC_DEC_MONITOR_SV__

class enc_dec_monitor extends uvm_monitor;
  `uvm_component_utils(enc_dec_monitor)

  virtual enc_dec_if dut_if;
  virtual enc_dec_ref_model_if ref_if;

  
  
  uvm_analysis_port #(enc_dec_seq_item) item_collected_port;//for the dut
  uvm_blocking_put_port#(enc_dec_seq_item) item_collected_port_ref;  // Port for reference model transactions


  // Placeholder to capture transaction information.
  enc_dec_seq_item trans_collected;
  enc_dec_seq_item trans_collected_ref;

  // File handle for output file
  integer file;
  integer ref_file;


  function new(string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = new();
    trans_collected_ref = new();
    item_collected_port = new("item_collected_port", this);
    item_collected_port_ref = new("item_collected_port_ref", this);
    
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual enc_dec_if)::get(this, "", "dut_if", dut_if))
      `uvm_fatal(" ", "Failed to get intf from config db");
    if (!uvm_config_db#(virtual enc_dec_ref_model_if)::get(this, "", "ref_if", ref_if))
      `uvm_fatal(" ", "Failed to get ref_if from config db");

    // Open file for writing
    file = $fopen("dut.txt", "w");
    if (file == 0) begin
      `uvm_fatal("FILE", "Failed to open file dut.txt");
    end
    
    ref_file = $fopen("ref.txt", "w");
    if (ref_file == 0) begin
      `uvm_fatal("FILE", "Failed to open file ref.txt");
    end
  endfunction

  virtual function void finalize_phase(uvm_phase phase);
    // Close file
    if (file != 0) begin
      $fclose(file);
    end
    if (ref_file != 0) begin
      $fclose(ref_file);
    end
  endfunction

      virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge dut_if.clk);
      wait(dut_if.command != 2'b00); // Wait until a command other than NOP is issued

      // Capture input signals
      trans_collected.command    = dut_if.command;
      trans_collected.data_in    = dut_if.data_in;
      trans_collected.secret_key = dut_if.secret_key;

      trans_collected_ref.command    = ref_if.command;
      trans_collected_ref.data_in    = ref_if.data_in;
      trans_collected_ref.secret_key = ref_if.secret_key;

      @(posedge dut_if.clk); // Wait one cycle for outputs

      // Capture outputs (out_data, valid)
      trans_collected.out_data = dut_if.out_data;
      trans_collected.valid    = dut_if.valid;

      trans_collected_ref.out_data = ref_if.out_data;
      trans_collected_ref.valid    = ref_if.valid;

      // Send items to analysis ports
      item_collected_port.write(trans_collected);
      item_collected_port_ref.put(trans_collected_ref);

      // Write to file
      $fwrite(file, "%0d,%0h,%0h,%0h\n",
              dut_if.command,
              dut_if.data_in,
              dut_if.out_data,
              dut_if.valid);

      $fwrite(ref_file, "%0d,%0h,%0h,%0h\n",
              ref_if.command,
              ref_if.data_in,
              ref_if.out_data,
              ref_if.valid);

      // Console display
      $display("======================================");
      $display("|            MONITOR LOG             |");
      $display("======================================");
      $display("| Command      : %0d", dut_if.command);
      $display("| Data In      : %0h", dut_if.data_in);
      $display("| Out Data     : %0h", dut_if.out_data);
      $display("| Valid (Code) : %02b", dut_if.valid);
      case (dut_if.valid)
        2'b00: $display("| Status       : No output");
        2'b01: $display("| Status       : Encryption OK");
        2'b10: $display("| Status       : Decryption OK");
        2'b11: $display("| Status       : Internal Error");
      endcase
      $display("======================================\n");

    end
  endtask


endclass


`endif // __ENC_DEC_MONITOR_SV__
