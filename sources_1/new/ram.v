module ram #(parameter ADDR_SIZE = 10, parameter WORD_SIZE = 8)(
  input clk,

  input [ADDR_SIZE - 1 : 0] w_addr,
  input [WORD_SIZE - 1 : 0] w_data,
  input we,

  input  [ADDR_SIZE - 1 : 0] r_addr,
  output [WORD_SIZE - 1 : 0] r_data
);

// -----------------------------------------------------------------------------
reg [WORD_SIZE - 1 : 0] mem [0 : 2 ** ADDR_SIZE - 1];
reg [ADDR_SIZE - 1 : 0] r_addr_reg;

// -----------------------------------------------------------------------------
always @(posedge clk) begin
  r_addr_reg <= r_addr;
end
assign r_data = mem[r_addr_reg];

// -----------------------------------------------------------------------------
always @(posedge clk) begin
  if (we == 1'b1) begin
    mem[w_addr] <= w_data;
  end
end
endmodule