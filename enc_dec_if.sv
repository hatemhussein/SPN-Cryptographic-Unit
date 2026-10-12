`ifndef __ENC_DEC_IF_SV__
`define __ENC_DEC_IF_SV__

interface enc_dec_if(input logic clk, input logic reset);
  // Clock and reset signals
  logic clk;
  logic reset;

  // Input signals
  logic [1:0]  command;
  logic [15:0] data_in;
  logic [31:0] secret_key;

  // Output signals
  logic [15:0] out_data;
  logic [1:0] valid;

  // Define clocking block for clock and reset
  clocking cb @(posedge clk, posedge reset);
    input reset;
  endclocking


endinterface
`endif