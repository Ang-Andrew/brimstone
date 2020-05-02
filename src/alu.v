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
  
  localparam[2:0] OP_ADD    = 3'b010;
  localparam[2:0] OP_SUB    = 3'b110;
  localparam[2:0] OP_AND    = 3'b000;
  localparam[2:0] OP_OR     = 3'b001;
  localparam[2:0] OP_SLT    = 3'b111;

  reg [DATA_WIDTH_P-1:0] result;

  // operation decoder
  always @(i_control) begin
    case(i_control)
      OP_ADD  : result = i_a + i_b; // add
      OP_SUB  : result = i_a - i_b; // sub
      OP_AND  : result = i_a & i_b; // AND
      OP_OR   : result = i_a | i_b; // OR
      OP_SLT  : result = i_a < i_b; // SLT
      default : result = {DATA_WIDTH_P{1'bx}};
    endcase
  end

  assign o_result = result;

endmodule