`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

module ya_fifo_simpler #(
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


//SIGNALS
logic empty, empty_r;
logic full, full_r;

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
assign we_for_ram = ( i_we ) && ( ~full_r );
assign re_for_ram = ( i_re ) && ( ~empty_r );
//
//

//notFULL and notEMPTY logic
assign o_is_not_full  = ~full_r;
assign o_is_not_empty = ~empty_r;
//
//

//WRITE and READ ADDRESS CALC, FULL and EMPTY logic
//We devided this process in two parts (comb and reg) explicitly to have..
//..direct signal from r_pointer logic, cause RAM module has it's own register for read address

always_ff @( posedge i_clk )
  begin
    if ( i_reset ) begin
      w_pointer_reg <= '0;
      r_pointer_reg <= '0;

      full_r        <= '0;
      empty_r       <= '1;

    end else begin
      w_pointer_reg <= w_pointer;
      r_pointer_reg <= r_pointer;

      full_r        <= full;
      empty_r       <= empty;
    end 
  end
//
always_comb
begin
  w_pointer = w_pointer_reg;
  r_pointer = r_pointer_reg;

  full      = full_r;
  empty     = empty_r;

  if ( ( ~we_for_ram ) && ( re_for_ram ) ) begin          //read operation
    r_pointer = r_pointer_reg + 1;
    full      = 1'b0;

    if ( r_pointer == w_pointer_reg ) begin
      empty = 1'b1;
    end

  end else if ( ( we_for_ram ) && ( ~re_for_ram ) ) begin //write operation
    w_pointer = w_pointer_reg + 1;
    empty     = 1'b0;
    
    if ( w_pointer == r_pointer_reg ) begin
      full = 1'b1;
    end

  end else if ( ( we_for_ram ) && ( re_for_ram ) ) begin    //both
    r_pointer = r_pointer_reg + 1;
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
