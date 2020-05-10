module memory #(
  parameter DATA_WIDTH_P = 32,
  parameter DATA_ADDR_WIDTH_P = 32
)(
  input wire clk,
  input wire reset,
  input wire i_mem_wr_en,
  input wire [DATA_ADDR_WIDTH_P-1:0] i_mem_addr,
  input wire [DATA_WIDTH_P-1:0]      i_mem_wr_data,
  output wire [DATA_WIDTH_P-1:0]     o_mem_rd_data);

  reg [DATA_WIDTH_P-1:0] memory [DATA_ADDR_WIDTH_P-1:0];
  reg [DATA_WIDTH_P-1:0] rd_data;

  always @(posedge clk ) begin
    if (i_mem_wr_en) begin
      memory[i_mem_addr] <= i_mem_wr_data;
    end else begin
      rd_data <= memory[i_mem_addr];
    end;
  end

  assign o_mem_rd_data = rd_data;

endmodule