`ifndef __ENC_DEC_REF_MODEL_IF_SV__
`define __ENC_DEC_REF_MODEL_IF_SV__

interface enc_dec_ref_model_if(input logic clk, input logic reset);
  logic [1:0] command;
  logic [15:0] data_in;
  logic [31:0] secret_key;
  logic [15:0] out_data;
  logic [1:0] valid;
endinterface
`endif