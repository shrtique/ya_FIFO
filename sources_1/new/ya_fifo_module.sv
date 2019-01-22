`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

module ya_fifo_module # (
  parameter ADDR_SIZE = 10,
  parameter WORD_SIZE = 8,
  parameter FWFT      = 0  //First Word Fall Through mode: 0 - Off, 1 - On
)(
  
  input  logic                 i_clk,
  input  logic                 i_reset,

  input  logic                 i_we,
  output logic                 o_is_not_full,            
  input  logic [WORD_SIZE-1:0] i_data,
  
  input  logic                 i_re,
  output logic                 o_is_not_empty,
  output logic [WORD_SIZE-1:0] o_data

);
//////////////////////////////////////////////////////////////////////////////////
//CONST
localparam FIFO_DEPTH = 2 ** ADDR_SIZE;

//SIGNALS
logic empty;
logic full;

logic we_for_ram;
logic re_for_ram;

logic [ADDR_SIZE-1:0] w_pointer, w_pointer_reg; //address for writing
logic [ADDR_SIZE-1:0] r_pointer, r_pointer_reg; //address for reading
logic [ADDR_SIZE:0]   data_in_fifo_cntr;        //counter variable, shows amount of stored data

logic [WORD_SIZE-1:0] r_data;                   //data from RAM 

//
//
//////////////////////////////////////////////////////////////////////////////////
//PROCESSES

//WE and RE logic for RAM
assign we_for_ram = ( i_we ) && ( ~full );
assign re_for_ram = ( i_re ) && ( ~empty );
//
//

//notFULL and notEMPTY logic
assign o_is_not_full  = ~full;
assign o_is_not_empty = ~empty;
//
//

//FULL AND EMPTY LOGIC
always_ff @( posedge i_clk )
  begin
    if ( i_reset ) begin
      full  <= 1'b0;
      empty <= 1'b1;
    end else begin
      
      //writing operation
      if ( ( we_for_ram ) && ( ~re_for_ram ) ) begin    
        empty <= 1'b0;
        if ( data_in_fifo_cntr == FIFO_DEPTH - 1 ) begin
          full <= 1'b1;
        end  
      end
      
      //reading operation
      if ( ( ~we_for_ram ) && ( re_for_ram ) ) begin
        full <= 1'b0;
        if ( data_in_fifo_cntr == 1 ) begin
          empty <= 1'b1;
        end  
      end  

    end
  end
//
//

//STORED DATA COUNTER
always_ff @( posedge i_clk )
  begin
    if ( i_reset ) begin
      data_in_fifo_cntr <= '0;
    end else begin

      //writing operation
      if ( ( we_for_ram ) && ( ~re_for_ram ) ) begin
        data_in_fifo_cntr <= data_in_fifo_cntr + 1;
      end
      
      //reading operation
      if ( ( ~we_for_ram ) && ( re_for_ram ) ) begin
        data_in_fifo_cntr <= data_in_fifo_cntr - 1;
      end

      //if both -> data_in_fifo_cntr is not changed

    end 
  end
//
//

//WRITE and READ ADDRESS CALC
//We devided this process in two parts (comb and reg) explicitly to have..
//..direct signal from r_pointer logic, cause RAM module has it's own register for read address

always_ff @( posedge i_clk )
  begin
    if ( i_reset ) begin
      w_pointer_reg <= '0;
      r_pointer_reg <= '0;
    end else begin
      w_pointer_reg <= w_pointer;
      r_pointer_reg <= r_pointer;
    end 
  end
//
always_comb
begin
  w_pointer = w_pointer_reg;
  r_pointer = r_pointer_reg;

  if ( re_for_ram ) begin
    r_pointer = r_pointer_reg + 1;
  end 

  if ( we_for_ram ) begin
    w_pointer = w_pointer_reg + 1;
  end  
end 
//
// 

//OUTPUT DATA FROM FIFO
//use generate to choose between two FIFO modes:
//FIRST WORD FALL THROUGH or STANDART 
generate 
  if ( FWFT ) begin
   
    assign o_data = r_data; 
  
  end else begin 

    always_ff @( posedge i_clk )
      begin
        if ( i_reset ) begin
          o_data <= '0;
        end else begin
          if ( re_for_ram ) begin
            o_data <= r_data;
          end	
        end 
      end

  end
endgenerate       




//////////////////////////////////////////////////////////////////////////////////
//INST of RAM
ram # (
  .ADDR_SIZE ( ADDR_SIZE ), 
  .WORD_SIZE ( WORD_SIZE )
) fifo_ram_inst (

  .clk    ( i_clk         ),

  .w_addr ( w_pointer_reg ),
  .w_data ( i_data        ),
  .we     ( we_for_ram    ),

  .r_addr ( r_pointer     ), //use signal from comb logic, cuz it's registered in RAM module
  .r_data ( r_data        )
);


//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
endmodule
