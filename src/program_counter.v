module program_counter#(
  parameter DATA_WIDTH_P = 32
)(
  input wire clk,
  input wire reset,
  input wire [DATA_WIDTH_P-1:0] i_count_next,
  output wire [DATA_WIDTH_P-1:0] o_count
);
  reg [DATA_WIDTH_P-1:0] next_count = {DATA_WIDTH_P{1'b0}};
  assign o_count = next_count;

  // counter process
  always @(posedge clk) begin
    if (reset) begin
      next_count <= {DATA_WIDTH_P{1'b0}};
    end else begin
      next_count <= i_count_next + 1;
    end;
  end

endmodule