module alu#(
  parameter DATA_WIDTH_P = 32,
  parameter ADDR_WIDTH_P = 5,
  parameter CNTRL_WIDTH_P = 3
)(
  input wire clk,
  input wire reset,
  input wire [CNTRL_WIDTH_P-1:0] i_control,
  input wire [DATA_WIDTH_P-1:0] i_a,
  input wire [DATA_WIDTH_P-1:0] i_b,
  output wire [DATA_WIDTH_P-1:0] o_result
);
  localparam[2:0]
    OP_ADD    : 3'b010,
    OP_SUB    : 3'b110,
    OP_AND    : 3'b000,
    OP_OR     : 3'b001,
    OP_SLT    : 3'b111

  // operation decoder
  always @(i_control) begin
    case(i_control)
      OP_ADD  : o_result = i_a + i_b; // add
      OP_SUB  : o_result = i_a - i_b; // sub
      OP_AND  : o_result = i_a & i_b; // AND
      OP_OR   : o_result = i_a | i_b; // OR
      OP_SLT  : o_result = i_a < i_b; // SLT
      default : o_result = {DATA_WIDTH_P{1'bx}}
    endcase
  end

endmodule