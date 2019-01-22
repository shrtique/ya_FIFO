`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.01.2019 18:17:51
// Design Name: 
// Module Name: ya_fifo_tb
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


module ya_fifo_tb(

    );




localparam ADDR_SIZE = 2;
localparam WORD_SIZE = 8;
localparam FWFT      = 1;



logic                 clk;
logic                 reset;

logic                 we, we_r;
logic [WORD_SIZE-1:0] i_data, i_data_r;

logic                 re, re_r;

logic is_not_full_standart;
logic is_not_full_fwft;
logic is_not_empty_standart;
logic is_not_empty_fwft;

logic output_data_standart;
logic output_data_fwft;


topcheg # (
  .ADDR_SIZE ( ADDR_SIZE ),
  .WORD_SIZE ( WORD_SIZE )
  //.FWFT      ( FWFT      )   
) UUT (
  
  .i_clk                   ( clk ),
  .i_reset                 ( reset ),

  .i_we                    ( we_r ),
  .o_is_not_full_standart  ( is_not_full_standart ),
  .o_is_not_full_fwft      ( is_not_full_fwft ),            
  .i_data                  ( i_data_r ),
  
  .i_re                    ( re_r ),
  .o_is_not_empty_standart ( is_not_empty_standart ),
  .o_is_not_empty_fwft     ( is_not_empty_fwft ),
  .o_data_standart         ( output_data_standart ),
  .o_data_fwft             ( output_data_fwft )

);

ram # (
  .ADDR_SIZE ( ADDR_SIZE ), 
  .WORD_SIZE ( WORD_SIZE )
) fifo_ram_UUT (

  .clk    ( clk ),

  .w_addr ( 0 ),
  .w_data ( i_data_r ),
  .we     ( we_r ),

  .r_addr ( 0 ),
  .r_data (  )
);



always
  begin
    clk = 1; #5; clk = 0; #5;
  end


initial
  begin

    reset              = 1'b1;
    we                 = 1'b0;
    re                 =  0;

    #17;
    reset              = 1'b0;

    #9;
    we = 1'b1;

    #70;
    we = 1'b0;
    #10;
    re = 1'b1;


    #50;
    re = 1'b0;

    #20;
    we = 1'b1;

    #20;
    re = 1'b1;

    #50;
    re = 1'b0;

    #50;
    re = 1'b1;

    #50;
    we = 1'b0;

    #50;
    reset              = 1'b1;
  end 



always_ff @( posedge clk )
  begin
    if ( reset ) begin
      we_r     <= 1'b0;
      i_data_r <= '0;
      re_r     <= 1'b0;
    end else begin
      we_r     <= we;
      i_data_r <= i_data_r + 1;
      re_r     <= re;      
    end 
  end




endmodule
