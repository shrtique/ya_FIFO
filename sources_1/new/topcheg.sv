`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.01.2019 13:13:31
// Design Name: 
// Module Name: topcheg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module topcheg #(
  parameter ADDR_SIZE = 10,
  parameter WORD_SIZE = 8
)(
  input  logic                 i_clk,
  input  logic                 i_reset,

  input  logic                 i_we,
  output logic                 o_is_not_full_standart,
  output logic                 o_is_not_full_fwft,
  output logic                 o_is_not_full_simpler,             
  input  logic [WORD_SIZE-1:0] i_data,
  
  input  logic                 i_re,
  output logic                 o_is_not_empty_standart,
  output logic                 o_is_not_empty_fwft,
  output logic                 o_is_not_empty_simpler,
  output logic [WORD_SIZE-1:0] o_data_standart,
  output logic [WORD_SIZE-1:0] o_data_fwft,
  output logic [WORD_SIZE-1:0] o_data_simpler
);


ya_fifo_module # (
  .ADDR_SIZE ( ADDR_SIZE ),
  .WORD_SIZE ( WORD_SIZE ),
  .FWFT      ( 0      )   
) fifo_standart (
  
  .i_clk          ( i_clk ),
  .i_reset        ( i_reset ),

  .i_we           ( i_we ),
  .o_is_not_full  ( o_is_not_full_standart ),            
  .i_data         ( i_data ),
  
  .i_re           ( i_re ),
  .o_is_not_empty ( o_is_not_empty_standart ),
  .o_data         ( o_data_standart )

);

ya_fifo_module # (
  .ADDR_SIZE ( ADDR_SIZE ),
  .WORD_SIZE ( WORD_SIZE ),
  .FWFT      ( 1      )   
) fifo_fwft (
  
  .i_clk          ( i_clk ),
  .i_reset        ( i_reset ),

  .i_we           ( i_we ),
  .o_is_not_full  ( o_is_not_full_fwft ),            
  .i_data         ( i_data ),
  
  .i_re           ( i_re ),
  .o_is_not_empty ( o_is_not_empty_fwft ),
  .o_data         ( o_data_fwft )

);


ya_fifo_simpler # (
  .ADDR_SIZE ( ADDR_SIZE ),
  .WORD_SIZE ( WORD_SIZE ),
  .FWFT      ( 0      )   
) fifo_simpler (
  
  .i_clk          ( i_clk ),
  .i_reset        ( i_reset ),

  .i_we           ( i_we ),
  .o_is_not_full  ( o_is_not_full_simpler ),            
  .i_data         ( i_data ),
  
  .i_re           ( i_re ),
  .o_is_not_empty ( o_is_not_empty_simpler ),
  .o_data         ( o_data_simpler )

);

endmodule


