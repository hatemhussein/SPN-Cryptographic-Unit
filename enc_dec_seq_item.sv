`ifndef __ENC_DEC_SEQ_ITEM_SV__
`define __ENC_DEC_SEQ_ITEM_SV__

class enc_dec_seq_item extends uvm_sequence_item;

  // Define the inputs
  typedef enum logic [1:0] {
    NOP = 2'b00,
    ENC = 2'b01,
    DEC = 2'b10,
    UNDEFINED = 2'b11
  } command_e;

  rand command_e command;
  rand logic [15:0] data_in;
  rand logic [31:0] secret_key;

  // Output/result fields
  logic [15:0] out_data;
  logic [1:0] valid;
  
  // UVM automation macros
  `uvm_object_utils_begin(enc_dec_seq_item)
    `uvm_field_enum(command_e, command, UVM_ALL_ON)
    `uvm_field_int(data_in, UVM_ALL_ON)
    `uvm_field_int(secret_key, UVM_ALL_ON)
    `uvm_field_int(out_data, UVM_ALL_ON)
    `uvm_field_int(valid, UVM_ALL_ON)
  `uvm_object_utils_end

  // Constraints
  constraint valid_command { command inside {NOP, ENC, DEC, UNDEFINED}; }
  constraint data_in_range {data_in inside {[16'h0000 : 16'hFFFF]};}
  constraint secret_key_range { secret_key inside {[32'h00000000:32'hFFFFFFFF]}; }


  // Constructor
  function new(string name = "enc_dec_seq_item");
    super.new(name);
  endfunction

  // Display function for debug purposes
  virtual function void display();
    $display("command: %0d, data_in: %0h, secret_key: %0h, out_data: %0h, valid: %0h",
          command, data_in, secret_key, out_data, valid);

  endfunction
  
  function bit compare(enc_dec_seq_item other);
    // Compare each field of the enc_dec_seq_item
    if (this.command !== other.command) return 0;
    if (this.data_in !== other.data_in) return 0;
    if (this.secret_key !== other.secret_key) return 0;
    if (this.out_data !== other.out_data) return 0;
    if (this.valid !== other.valid) return 0;

    // If all fields match, return 1 (true)
    return 1;
  endfunction
endclass
`endif