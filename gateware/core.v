module core#(
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
  input wire [DATA_WIDTH_P-1:0] i_rd_data,

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
  
  wire reg_wr_data_sel;
  wire mem_wr_en;
  wire branch;
  wire alu_src_sel;
  wire reg_wr_addr_sel;
  wire reg_wr_data;
  wire reg_wr_addr;
  wire reg_wr_en;
  wire alu_i_b_sel;
  wire reg_rd_port_b;
  wire beq_pc_jump;
  wire zero_alu_result;

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
    .o_mem_wr_en(mem_wr_en),
    .o_branch(),
    .o_alu_cntrl(alu_control),
    .o_alu_src_sel(alu_src_sel),
    .o_reg_wr_addr_sel(reg_wr_addr_sel),
    .o_reg_wr_en(reg_wr_en),
    .o_reg_wr_data_sel(reg_wr_data_sel));

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

  // BEQ logic
  always @(sign_extend_imm,pc_next) begin
    beq_pc_jump = pc + 4 + (sign_extend_imm << 2);
  end;

  assign pc_next = zero_alu_result and branch ? beq_pc_jump : pc + 4;

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
    .o_rd_data_b(reg_rd_port_b));

  // sign extension for LW
  always @(pc) begin
    sign_extend_imm = {{16{pc[DATA_WIDTH_P-1]}},pc}
  end

  // write data select
  assign reg_wr_data = reg_wr_data_sel ? i_rd_data : alu_out;

  // write address select
  assign reg_wr_addr = reg_wr_addr_sel ? i_instr[15:11] : i_instr[20:16];

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

  // src b select
  assign alu_in_b = alu_src_sel ? reg_rd_port_b ; sign_extend_imm;

  // zero detect
  assign zero_alu_result = alu_out == DATA_WIDTH_P'b0 ? 1'b1 : 1'b0;
  //----------------------------------------------------------------------------

endmodule