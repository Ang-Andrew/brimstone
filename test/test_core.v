module test_core#(
)();
  // local parameters
  localparam DATA_WIDTH_P = 32;
  localparam DATA_ADDR_WIDTH_P = 32;
  localparam ADDR_WIDTH_P = 5;
  localparam CNTRL_WIDTH_P = 3;
  localparam ALU_CNTRL_WIDTH_P = 3;
  localparam FUNCT_WIDTH_P = 6;
  localparam OP_WIDTH_P = 6;

  // duration for each bit -> 25 MHz -> 40ns
  reg clk;
  localparam period = 40;
  localparam half_period = period/2;

  reg reset = 1'b0;

  reg [DATA_WIDTH_P-1:0] pc;
  reg [DATA_WIDTH_P-1:0] instr;
  reg [DATA_WIDTH_P-1:0] mem_rd_data;
  reg mem_wr_en;
  reg [DATA_ADDR_WIDTH_P-1:0] mem_wr_addr;
  reg [DATA_WIDTH_P-1:0] mem_wr_data;
  
  // clock generator
  always 
  begin
    clk = 1'b0; 
    #half_period;
    clk = 1'b1;
    #half_period;
  end

  core #(
    .DATA_WIDTH_P(DATA_WIDTH_P),
    .DATA_ADDR_WIDTH_P(DATA_ADDR_WIDTH_P),
    .ADDR_WIDTH_P(ADDR_WIDTH_P),
    .CNTRL_WIDTH_P(CNTRL_WIDTH_P),
    .ALU_CNTRL_WIDTH_P(ALU_CNTRL_WIDTH_P),
    .FUNCT_WIDTH_P(FUNCT_WIDTH_P),
    .OP_WIDTH_P(OP_WIDTH_P))
  UUT(
    .clk(clk),
    .reset(reset),
    .i_instr(instr),

    // instruction memory interface
    .o_pc(pc),
    
    // data memory interface
    .i_mem_rd_data(mem_rd_data),
    .o_mem_wr_en(mem_wr_en),
    .o_mem_wr_addr(mem_wr_addr),
    .o_mem_wr_data(mem_wr_data)
  );
  
  initial begin
    #period
    //--------------------------------------------------------------------------
    // test core
    //--------------------------------------------------------------------------
    $display ("TEST: core");
     
     @(posedge clk);


    //--------------------------------------------------------------------------

    #period
    $display("done");
    $stop;   // end of simulation
  end

endmodule
