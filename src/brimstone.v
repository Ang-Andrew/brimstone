module brimestone#(
  parameter DATA_WIDTH_P = 32,
  parameter DATA_ADDR_WIDTH_P = 32,
  parameter ADDR_WIDTH_P = 5,
  parameter CNTRL_WIDTH_P = 3,
  parameter ALU_CNTRL_WIDTH_P = 3,
  parameter FUNCT_WIDTH_P = 6,
  parameter OP_WIDTH_P = 6
)(
  input wire clk,
  input wire reset
);

  wire mem_wr_en;
  wire [DATA_ADDR_WIDTH_P-1:0] mem_addr;
  wire [DATA_WIDTH_P-1:0] mem_wr_data;
  wire [DATA_WIDTH_P-1:0] mem_rd_data;

  memory #(
    .DATA_WIDTH_P(DATA_WIDTH_P),
    .DATA_ADDR_WIDTH_P(DATA_WIDTH_P))
  data_memory(
  .clk(clk),
  .reset(reset),
  .i_mem_wr_en(mem_wr_en),
  .i_mem_addr(mem_addr),
  .i_mem_wr_data(mem_wr_data),
  .o_mem_rd_data(mem_rd_data));
  
  core #(
    .DATA_WIDTH_P(DATA_WIDTH_P),
    .DATA_ADDR_WIDTH_P(DATA_ADDR_WIDTH_P),
    .ADDR_WIDTH_P(ADDR_WIDTH_P),
    .CNTRL_WIDTH_P(CNTRL_WIDTH_P),
    .ALU_CNTRL_WIDTH_P(ALU_CNTRL_WIDTH_P),
    .FUNCT_WIDTH_P(FUNCT_WIDTH_P),
    .OP_WIDTH_P(OP_WIDTH_P))
  core_i(
    .clk(clk),
    .reset(reset),
    .i_instr(instr),

    // instruction memory interface
    .o_pc(pc),
    
    // data memory interface
    .i_mem_rd_data(mem_rd_data),
    .o_mem_wr_en(mem_wr_en),
    .o_mem_addr(mem_addr),
    .o_mem_wr_data(mem_wr_data)
  );

endmodule