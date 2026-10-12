`ifndef __ENC_DEC_DRIVER_SV__
`define __ENC_DEC_DRIVER_SV__

class enc_dec_driver extends uvm_driver #(enc_dec_seq_item);

  `uvm_component_utils(enc_dec_driver)

  virtual enc_dec_if dut_if;
  virtual enc_dec_ref_model_if ref_if;

  enc_dec_seq_item req;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual enc_dec_if) :: get(this, " ", "dut_if", dut_if))
      `uvm_fatal("", "Failed to get intf from config db");
    
    if (!uvm_config_db #(virtual enc_dec_ref_model_if) :: get(this, "", "ref_if", ref_if))
   `uvm_fatal("", "Failed to get ref_if from config db");
    
    req = new();
    req.print();
  endfunction

  virtual task run_phase(uvm_phase phase);
    // Wait for reset to deassert
    @(negedge dut_if.reset);
    fork
      forever begin
          seq_item_port.get_next_item(req);
          drive(req);
          seq_item_port.item_done();
      end
    join
  endtask

   task drive(enc_dec_seq_item item);
    @(posedge dut_if.clk);

    // Apply inputs to DUT
    dut_if.command     <= item.command;
    dut_if.data_in     <= item.data_in;
    dut_if.secret_key  <= item.secret_key;

    // Apply inputs to Reference Model
    ref_if.command     <= item.command;
    ref_if.data_in     <= item.data_in;
    ref_if.secret_key  <= item.secret_key;

    // Print input transaction info
    `uvm_info("DRIVER", $sformatf(
      "Driving Inputs => CMD: %0d, DataIn: 0x%0h, Key: 0x%0h",
      item.command, item.data_in, item.secret_key), UVM_MEDIUM)

    // Wait some time or condition for outputs to be valid (customize as needed)
    @(posedge dut_if.clk); // 1 cycle delay (adjust as needed)

    // Print DUT outputs
    `uvm_info("DRIVER", $sformatf(
      "DUT Output => DataOut: 0x%0h, Valid: %0b",
      dut_if.out_data, dut_if.valid), UVM_MEDIUM)

    // Print Reference Model outputs
    `uvm_info("DRIVER", $sformatf(
      "REF Output => DataOut: 0x%0h, Valid: %0b",
      ref_if.out_data, ref_if.valid), UVM_MEDIUM)
  endtask


endclass


`endif // __ENC_DEC_DRIVER_SV__
