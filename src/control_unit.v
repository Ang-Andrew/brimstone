module control_unit#(
  parameter ALU_CNTRL_WIDTH_P = 3,
  parameter FUNCT_WIDTH_P = 6,
  parameter OP_WIDTH_P = 6
)(
  input wire [OP_WIDTH_P-1:0] i_opcode,
  input wire [FUNCT_WIDTH_P-1:0] i_function,
  output wire o_mem_wr_en,
  output wire o_branch,
  output wire [ALU_CNTRL_WIDTH_P-1:0] o_alu_cntrl,
  output wire o_alu_src_sel,
  output wire o_reg_wr_addr_sel,
  output wire o_reg_wr_en,
  output wire o_reg_wr_data_sel,
  output wire o_jump);

  //----------------------------------------------------------------------------
  // local parameter declarations
  //----------------------------------------------------------------------------
  
  localparam[1:0] ADD       = 2'b00;  // add
  localparam[1:0] SUB       = 2'b01;  // subtract
  localparam[1:0] LOOK      = 2'b10;  // look at funct field value
  localparam[1:0] INVALID   = 2'b11;  // invalid

  
  localparam[OP_WIDTH_P-1:0] RTYPE  = 6'b000000;
  localparam[OP_WIDTH_P-1:0] LW     = 6'b100011;
  localparam[OP_WIDTH_P-1:0] SW     = 6'b101011;
  localparam[OP_WIDTH_P-1:0] BEQ    = 6'b000100;
  localparam[OP_WIDTH_P-1:0] JUMP   = 6'b000010;

  localparam ALU_DECODE_WIDTH = FUNCT_WIDTH_P+2;

  //----------------------------------------------------------------------------
  // register and wire declarations
  //----------------------------------------------------------------------------

  reg [1:0] alu_op;

  // data memory control
  reg reg_wr_data_sel;
  reg mem_wr_en = 0;
  reg branch = 0;

  // alu control
  reg [ALU_CNTRL_WIDTH_P-1:0] alu_cntrl;
  reg alu_src_sel = 0;

  // register file control
  reg reg_wr_addr_sel;
  reg reg_wr_en = 0;
  
  // jump
  reg jump;

  // alu decoder input which is a
  // concatenation of fucntion and alu operation
  wire [ALU_DECODE_WIDTH-1:0] alu_decode_input;

  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // assignments
  //----------------------------------------------------------------------------

  // concatenate function and alu operation
  assign alu_decode_input = {alu_op,i_function};

  // output assignments
  assign o_reg_wr_data_sel  = reg_wr_data_sel;
  assign o_mem_wr_en        = mem_wr_en;
  assign o_branch           = branch;
  assign o_alu_cntrl        = alu_cntrl;
  assign o_alu_src_sel      = alu_src_sel;
  assign o_reg_wr_addr_sel  = reg_wr_addr_sel;
  assign o_reg_wr_en        = reg_wr_en;

  //----------------------------------------------------------------------------

  
  //----------------------------------------------------------------------------
  // Opcode decoder
  //----------------------------------------------------------------------------

  always @(i_opcode) begin
    case(i_opcode)
      RTYPE  : begin
        reg_wr_en         = 1'b1;
        reg_wr_addr_sel   = 1'b1;
        alu_src_sel       = 1'b0;
        branch            = 1'b0;
        mem_wr_en         = 1'b0;
        reg_wr_data_sel   = 1'b0;
        alu_op            = 2'b10;
        jump              = 1'b0;
      end
      LW : begin
        reg_wr_en         = 1'b1;
        reg_wr_addr_sel   = 1'b0;
        alu_src_sel       = 1'b1;
        branch            = 1'b0;
        mem_wr_en         = 1'b0;
        reg_wr_data_sel   = 1'b1;
        alu_op            = 2'b00;
        jump              = 1'b0;
      end
      SW : begin
        reg_wr_en         = 1'b1;
        reg_wr_addr_sel   = 1'b0;
        alu_src_sel       = 1'b1;
        branch            = 1'b0;
        mem_wr_en         = 1'b0;
        reg_wr_data_sel   = 1'b1;
        alu_op            = 2'b00;
        jump              = 1'b0;
      end
      BEQ : begin
        reg_wr_en         = 1'b0;
        reg_wr_addr_sel   = 1'b0;
        alu_src_sel       = 1'b0;
        branch            = 1'b1;
        mem_wr_en         = 1'b0;
        reg_wr_data_sel   = 1'b0;
        alu_op            = 2'b01;
        jump              = 1'b0;
      end
      JUMP : begin
        reg_wr_en         = 1'b0;
        reg_wr_addr_sel   = 1'b0;
        alu_src_sel       = 1'b0;
        branch            = 1'b0;
        mem_wr_en         = 1'b0;
        reg_wr_data_sel   = 1'b0;
        alu_op            = 2'b00;
        jump              = 1'b1;
      end
      default: begin
        reg_wr_en         = 1'b0;
        reg_wr_addr_sel   = 1'b0;
        alu_src_sel       = 1'b0;
        branch            = 1'b0;
        mem_wr_en         = 1'b0;
        reg_wr_data_sel   = 1'b0;
        alu_op            = 2'b11; // invalid alu op code
        jump              = 1'b1;
      end
    endcase
  end

  //----------------------------------------------------------------------------


  //----------------------------------------------------------------------------
  // ALU decoder
  //----------------------------------------------------------------------------
  
  always @(alu_decode_input) begin
    casez(alu_decode_input)
      8'b00?????? : alu_cntrl = 3'b010; // requires add operation
      8'b?1?????? : alu_cntrl = 3'b110; // requries sub operation
      8'b1?100000 : alu_cntrl = 3'b010; // add operation
      8'b1?100010 : alu_cntrl = 3'b110; // subtraction operation
      8'b1?100100 : alu_cntrl = 3'b000; // and operation
      8'b1?100101 : alu_cntrl = 3'b001; // or operation
      8'b1?101010 : alu_cntrl = 3'b111; // set less than (SLT) operation
      default     : alu_cntrl = 3'bxxx; // invalid
    endcase
  end

  //----------------------------------------------------------------------------

endmodule