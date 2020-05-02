module core#(
  parameter DATA_WIDTH_P = 32,
  parameter DATA_ADDR_WIDTH_P = 32,
  parameter ADDR_WIDTH_P = 5,
  parameter CNTRL_WIDTH_P = 3,
  parameter ALU_CNTRL_WIDTH_P = 3,
  parameter FUNCT_WIDTH_P = 6,
  parameter OP_WIDTH_P = 6
)(
  input wire clk,
  input wire reset,
  input wire [DATA_WIDTH_P-1:0] i_instr,

  output wire [DATA_WIDTH_P-1:0] o_pc,

  // data memory interface
  input wire [DATA_WIDTH_P-1:0] i_mem_rd_data,
  output wire o_mem_wr_en,
  output wire [DATA_ADDR_WIDTH_P-1:0] o_mem_addr,
  output wire [DATA_WIDTH_P-1:0] o_mem_wr_data);

  //----------------------------------------------------------------------------
  // register and wire instantiations
  //----------------------------------------------------------------------------

  wire [DATA_WIDTH_P-1:0] pc;
  wire [DATA_WIDTH_P-1:0] pc_add;
  reg [DATA_WIDTH_P-1:0] pc_next;
  reg [DATA_WIDTH_P-1:0] sign_extend_imm;

  wire [ALU_CNTRL_WIDTH_P-1:0] alu_control;
  wire [DATA_WIDTH_P-1:0] alu_in_a;
  wire [DATA_WIDTH_P-1:0] alu_in_b;
  wire [DATA_WIDTH_P-1:0] alu_out;

  reg [DATA_WIDTH_P-1:0] mem_wr_data;
  
  wire reg_wr_data_sel;
  wire mem_wr_en;
  wire branch;
  wire alu_src_sel;
  wire reg_wr_addr_sel;
  wire [DATA_WIDTH_P-1:0] reg_wr_data;
  wire [ADDR_WIDTH_P-1:0] reg_wr_addr;
  wire reg_wr_en;
  wire alu_i_b_sel;
  wire [DATA_WIDTH_P-1:0] reg_rd_port_b;
  wire beq_pc;
  wire j_type_jump;
  wire zero_alu_result;

  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // assignments
  //----------------------------------------------------------------------------
  assign o_pc = pc;

  // data memory interface assignments
  assign o_mem_wr_en  = mem_wr_en;
  assign o_mem_addr = alu_out;
  assign o_mem_wr_data = mem_wr_data;

  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // Control unit
  //----------------------------------------------------------------------------

  control_unit #(
    .ALU_CNTRL_WIDTH_P(ALU_CNTRL_WIDTH_P),
    .FUNCT_WIDTH_P(FUNCT_WIDTH_P),
    .OP_WIDTH_P(OP_WIDTH_P))
  cntrl_unit_i(
    .i_opcode(i_instr[DATA_WIDTH_P-1:26]),
    .i_function(i_instr[5:0]),
    .o_mem_wr_en(mem_wr_en),
    .o_branch(branch),
    .o_alu_cntrl(alu_control),
    .o_alu_src_sel(alu_src_sel),
    .o_reg_wr_addr_sel(reg_wr_addr_sel),
    .o_reg_wr_en(reg_wr_en),
    .o_reg_wr_data_sel(reg_wr_data_sel),
    .o_jump(j_type_jump));

  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // program counter
  //----------------------------------------------------------------------------

  program_counter #(
    .DATA_WIDTH_P(DATA_WIDTH_P))
  pc_i(
    .clk(clk),
    .reset(reset),
    .i_count_next(pc_next),
    .o_count(pc));

  assign pc_add = pc + 4;

  // BEQ logic
  assign beq_pc = pc_add + (sign_extend_imm << 2);

  // JUMP logic

  assign j_type_jump = {pc_add[DATA_WIDTH_P-1:26],i_instr[25:0] << 2};

  // next pc multiplexer
  always @(j_type_jump, zero_alu_result, pc_add,beq_pc, j_type_jump) begin
    case({j_type_jump,zero_alu_result})
      2'b00 : pc_next = pc_add;
      2'b01 : pc_next = beq_pc;
      2'b10 : pc_next = j_type_jump;
      default : pc_next = pc_add;
    endcase
  end

  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // register file
  //----------------------------------------------------------------------------

  register_file #(
    .DATA_WIDTH_P(DATA_WIDTH_P),
    .ADDR_WIDTH_P(ADDR_WIDTH_P))
  reg_i (
    .clk(clk),
    .reset(reset),
    .i_rd_addr_a(i_instr[25:21]),
    .i_rd_addr_b(i_instr[20:16]),
    .i_wr_addr(reg_wr_addr),
    .i_wr_data(reg_wr_data),
    .i_wr_enable(reg_wr_en),
    .o_rd_data_a(alu_in_a),
    .o_rd_data_b(reg_rd_port_b));

  // sign extension for LW
  always @(pc) begin
    sign_extend_imm = {{16{pc[DATA_WIDTH_P-1]}},pc};
  end

  // write data select
  assign reg_wr_data = reg_wr_data_sel ? i_mem_rd_data : alu_out;

  // write address select
  assign reg_wr_addr = reg_wr_addr_sel ? i_instr[15:11] : i_instr[20:16];

  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // ALU
  //----------------------------------------------------------------------------

  alu #(
    .DATA_WIDTH_P(DATA_WIDTH_P),
    .ADDR_WIDTH_P(ADDR_WIDTH_P),
    .CNTRL_WIDTH_P(ALU_CNTRL_WIDTH_P))
  alu_i(  
    .clk(clk),
    .reset(reset),
    .i_control(alu_control),
    .i_a(alu_in_a),
    .i_b(alu_in_b),
    .o_result(alu_out));

  // src b select
  assign alu_in_b = alu_src_sel ? reg_rd_port_b : sign_extend_imm;

  // zero detect
  assign zero_alu_result = alu_out == {DATA_ADDR_WIDTH_P[1'b0]} ? 1'b1 : 1'b0;
  //----------------------------------------------------------------------------

endmodule