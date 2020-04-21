module top#(
  parameter DATA_WIDTH_P = 32,
  parameter ADDR_WIDTH_P = 5,
  parameter CNTRL_WIDTH_P = 3,
  parameter ALU_CNTRL_WIDTH_P = 3,
  parameter FUNCT_WIDTH_P = 6,
  parameter OP_WIDTH_P = 6
)(
  input wire clk,
  input wire reset,
  input wire [DATA_WIDTH_P-1:0] i_instr,

  output wire [DATA_WIDTH_P-1:0] o_pc

  // data memory interface
  output wire o_mem_wr_en;
  output wire o_mem_wr_addr;
  output wire o_mem_wr_data);

  //----------------------------------------------------------------------------
  // register and wire instantiations
  //----------------------------------------------------------------------------

  reg [DATA_WIDTH_P-1:0] pc;
  reg [DATA_WIDTH_P-1:0] pc_next;
  reg [DATA_WIDTH_P-1:0] sign_extend_imm;

  reg [ALU_CNTRL_WIDTH_P-1:0] alu_control;
  reg [DATA_WIDTH_P-1:0] alu_in_a;
  reg [DATA_WIDTH_P-1:0] alu_in_b;
  reg [DATA_WIDTH_P-1:0] alu_out;
  
  wire reg_data_sel;
  wire mem_wr_en;
  wire branch;
  wire alu_src_sel;
  wire reg_wr_addr_sel;
  wire reg_wr_en;

  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // assignments
  //----------------------------------------------------------------------------
  assign o_pc = pc;

  // data memory interface assignments
  assign o_mem_wr_en = mem_wr_en;
  assign o_mem_wr_addr = alu_out;
  assign o_mem_wr_data = mem_wr_data;

  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // Control unit
  //----------------------------------------------------------------------------

  control_unit cntrl_unit_i#(
    .ALU_CNTRL_WIDTH_P(ALU_CNTRL_WIDTH_P),
    .FUNCT_WIDTH_P(FUNCT_WIDTH_P),
    .OP_WIDTH_P(OP_WIDTH_P)
  )(
    .i_opcode(i_instr[DATA_WIDTH_P-1:26]),
    .i_function(i_instr[5:0]),
    .o_reg_data_sel(reg_data_sel),
    .o_mem_wr_en(mem_wr_en),
    .o_branch(),
    .o_alu_cntrl(alu_control),
    .o_alu_src_sel(alu_src_sel),
    .o_reg_wr_addr_sel(reg_wr_addr_sel),
    .o_reg_wr_en(reg_wr_en));

  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // program counter
  //----------------------------------------------------------------------------

  program_counter pc_i #(
    .DATA_WIDTH_P(DATA_WIDTH_P)
  )(
    .clk(clk),
    .reset(reset),
    .i_count_next(pc_next),
    .o_count(pc));

  // next program counter logic
  always @(pc) begin
    pc_next = pc+1;
  end

  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // register file
  //----------------------------------------------------------------------------

  register_fie reg_i #(
    .DATA_WIDTH_P(DATA_WIDTH_P),
    .ADDR_WIDTH_P(ADDR_WIDTH_P)
  )(
    .clk(clk),
    .reset(reset),
    .i_rd_addr_a(i_instr[25:21]),
    .i_rd_addr_b(i_instr[20:16]),
    .i_wr_addr(),
    .i_wr_data(),
    .i_wr_enable(reg_wr_en),
    .o_rd_data_a(alu_in_a),
    .o_rd_data_b());

  // sign extension for LW
  always @(pc) begin
    sign_extend_imm = {{16{pc[DATA_WIDTH_P-1]}},pc}
  end

  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // ALU
  //----------------------------------------------------------------------------

  alu alu_i #(
    .DATA_WIDTH_P(DATA_WIDTH_P),
    .ADDR_WIDTH_P(ADDR_WIDTH_P),
    .CNTRL_WIDTH_P(ALU_CNTRL_WIDTH_P)
  )(  
    .clk(clk),
    .reset(reset),
    .i_control(alu_control),
    .i_a(alu_in_a),
    .i_b(alu_in_b),
    .o_result(alu_out));

  //----------------------------------------------------------------------------

endmodule