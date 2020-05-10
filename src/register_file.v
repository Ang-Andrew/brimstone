module register_file#(
  parameter MEM_INIT_FILE = "register_file.mem",
  parameter DATA_WIDTH_P = 32,
  parameter ADDR_WIDTH_P = 5,
  parameter DEPTH_P = 32)
(
  //----------------------------------------------------------------------------
  // inputs
  //----------------------------------------------------------------------------
  input wire clk,
  input wire reset,
  input wire [ADDR_WIDTH_P-1:0] i_rd_addr_a,
  input wire [ADDR_WIDTH_P-1:0] i_rd_addr_b,
  input wire [ADDR_WIDTH_P-1:0] i_wr_addr,
  input wire [DATA_WIDTH_P-1:0] i_wr_data,
  input wire i_wr_enable,
  //----------------------------------------------------------------------------
  // outputs
  //----------------------------------------------------------------------------
  output wire [DATA_WIDTH_P-1:0] o_rd_data_a,
  output wire [DATA_WIDTH_P-1:0] o_rd_data_b
);

  //----------------------------------------------------------------------------
  // register and wire instantiations
  //----------------------------------------------------------------------------

  reg [DATA_WIDTH_P-1:0] rd_data_a;
  reg [DATA_WIDTH_P-1:0] rd_data_b;
  reg [DATA_WIDTH_P-1:0] memory [0:DEPTH_P-1];

  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // assignments
  //----------------------------------------------------------------------------

  assign o_rd_data_a = rd_data_a;
  assign o_rd_data_b = rd_data_b;

  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // intialise memory
  //----------------------------------------------------------------------------
  integer j;
  initial begin
    for(j=0;j<DEPTH_P;j=j+1) begin
      memory[j] <= {DATA_WIDTH_P{1'b0}};
    end;
  end
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // read process
  //----------------------------------------------------------------------------
  always @(*) begin
    rd_data_a <= memory[i_rd_addr_a];
    rd_data_b <= memory[i_rd_addr_b];
  end

  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // write process
  //----------------------------------------------------------------------------
  integer i;
  always @(posedge clk) begin
    if (reset) begin
      // reset everything
      for(i=0;i<DEPTH_P-1;i=i+1) begin
        memory[i] <= {DATA_WIDTH_P{1'b0}};
      end;
    end else if (i_wr_enable) begin
      memory[i_wr_addr] <= i_wr_data;
    end;
  end
  //----------------------------------------------------------------------------
endmodule

