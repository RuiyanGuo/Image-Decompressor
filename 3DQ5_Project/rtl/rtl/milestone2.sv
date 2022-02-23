//Group_6
//This file is for milestone2

`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

// It connects the UART, SRAM and VGA together.
// It gives access to the SRAM for UART and VGA
module milestone2 (
    input logic CLOCK_50_I,
	 input logic resetn,
	 input logic [15:0]SRAM_read_data,
	 input logic M2_start,
	 
	 output logic SRAM_we_n,
    output logic M2_done,
	 output logic  [15:0] SRAM_write_data,
	 output logic [17:0] SRAM_address

);

M2_state_type M2_state;

parameter Y_prime_offset = 18'd76800,
          U_prime_offset = 18'd153600,
			 V_prime_offset = 18'd192000,
			 Y_offset = 18'd0,
			 U_offset = 18'd38400,
			 V_offset = 18'd57600;
          

logic [6:0] address_a1, address_b1, address_c1, address_a2, address_b2, address_c2, S_counter;
logic [31:0] write_data_a1;
logic [31:0] write_data_a2;
logic [31:0] write_data_b1;
logic [31:0] write_data_b2;
logic [31:0] write_data_c1;
logic [31:0] write_data_c2;
logic write_enable_a1;
logic write_enable_a2;
logic write_enable_b1;
logic write_enable_b2;
logic write_enable_c1;
logic write_enable_c2;
logic [31:0] read_data_a1;
logic [31:0] read_data_a2;
logic [31:0] read_data_b1;
logic [31:0] read_data_b2;
logic [31:0] read_data_c1;
logic [31:0] read_data_c2;

logic signed [31:0] op1, op2, op3, op4, op5, op6, op1_buff, op2_buff;
logic signed [31:0] T, S;
logic signed [31:0] T_buff[7:0];
logic signed [31:0] Y_odd, Y_even;
logic signed [15:0] C_trans_buff [7:0];

logic [3:0] row_index;
logic [3:0] col_index;

logic [8:0] col_block_counter, col_block_counter_w;
logic [8:0] row_block_counter, row_block_counter_w;
logic [7:0] Y_even_w,Y_odd_w;
logic [8:0] ram_counter;
logic [8:0] row_address, row_address_w, col_address, col_address_w;
logic [17:0] all_address, w_address;
logic write_s_prime_ready, write_S_end;
logic [7:0] counter_a, counter_b;
logic [15:0] S_prime_buff;
logic [17:0] S_offset,S_prime_offset;
logic signed [31:0] mult1, mult2, mult3;
logic Y_if;
logic U_if;
logic Y_prime_if;
logic U_prime_if;
logic UV_prime_if;
logic write_S_prime_ready;
logic T_odd_sign;
logic Y_odd_sign;
logic stop, sign_a;


assign col_address = col_index + 8*col_block_counter;
assign row_address = row_index + 8*row_block_counter;
assign col_address_w = col_index + 4*col_block_counter_w;
assign row_address_w = row_index + 8*row_block_counter_w;
assign all_address = Y_prime_if ? (320*row_address + col_address) : (160*row_address + col_address); // Reading 
assign w_address = Y_if ? (160*row_address_w + col_address_w) : (80*row_address_w + col_address_w); // Writing 
assign S_prime_offset = Y_prime_if ? Y_prime_offset : U_prime_offset;
assign S_offset = Y_if?Y_offset:U_offset;
assign Y_even_w = (Y_even[15]) ? 8'd0 : (|Y_even[14:8]) ? 8'd255 : Y_even[7:0];//Clipping
assign Y_odd_w = (Y_odd[15]) ? 8'd0 : (|Y_odd[14:8]) ? 8'd255 : Y_odd[7:0];

assign mult1 = op1 * op2;//3 multipliers
assign mult2 = op3 * op4;
assign mult3 = op5 * op6;


// instantiate RAM0 - S';S
RAM_inst0 RAM_inst0 (
	.address_a ( address_a1 ),
	.address_b ( address_a2 ),
	.clock ( CLOCK_50_I ),
	.data_a ( write_data_a1 ),
	.data_b ( write_data_a2 ),
	.wren_a ( write_enable_a1 ),
	.wren_b ( write_enable_a2 ),
	.q_a ( read_data_a1 ),
	.q_b ( read_data_a2 )
   );
// instantiate RAM1 - Ct; C
RAM_inst1 RAM_inst1 (
	.address_a ( address_b1 ),
	.address_b ( address_b2 ),
	.clock ( CLOCK_50_I ),
	.data_a ( write_data_b1 ),
	.data_b ( write_data_b2 ),
	.wren_a ( write_enable_b1 ),
	.wren_b ( write_enable_b2 ),
	.q_a ( read_data_b1 ),
	.q_b ( read_data_b2 )
	);
	
// instantiate RAM2 - T
RAM_inst2 RAM_inst2 (
	.address_a ( address_c1 ),
	.address_b ( address_c2 ),
	.clock ( CLOCK_50_I ),
	.data_a ( write_data_c1 ),
	.data_b ( write_data_c2 ),
	.wren_a ( write_enable_c1 ),
	.wren_b ( write_enable_c2 ),
	.q_a ( read_data_c1 ),
	.q_b ( read_data_c2 )
	);
	


always_ff @ (posedge CLOCK_50_I or negedge resetn) begin
	if (resetn == 1'b0) begin		
	   address_a1 <= 7'b0;//for S'
		address_a2 <= 7'b0;
		address_b1 <= 7'b0;
		address_b2 <= 7'b0;
		address_c1 <= 7'b0;
		address_c2 <= 7'b0;
		write_data_a1 <= 32'b0;
      write_data_a2 <= 32'b0;
      write_data_b1 <= 32'b0;
      write_data_b2 <= 32'b0;
      write_data_c1 <= 32'b0;
      write_data_c2 <= 32'b0;
		S <= 32'b0;
		T <= 32'b0;
		S_prime_buff <= 16'b0;
		SRAM_we_n <= 1'b1;
      write_enable_a1 <= 1'b0;
      write_enable_b1 <= 1'b0;
      write_enable_c1 <= 1'b0;
		write_enable_a2 <= 1'b0;
      write_enable_b2 <= 1'b0;
      write_enable_c2 <= 1'b0;
		row_index <= 4'b0;
      col_index <= 4'b0;
      col_block_counter <= 9'b0;
      row_block_counter <= 9'b0;
		col_block_counter_w <= 9'b0;
      row_block_counter_w <= 9'b0;
		write_S_prime_ready <= 1'b0;
		T_odd_sign <= 1'b0;
		Y_odd_sign <= 1'b0;
		ram_counter <= 9'b0;
		S_counter <= 7'b0;
		write_S_end <= 1'b0;
		Y_prime_if <= 1'b1;
		U_prime_if <= 1'b0;
		UV_prime_if <= 1'b0;
		Y_if <= 1'b1;
		U_if <= 1'b0;
		Y_odd <= 32'b0;
		Y_even <= 32'b0;
		stop <= 1'b0;
		counter_a <= 8'b0;
		counter_b <= 8'b0;
		op1 <= 16'b0;
		op2 <= 16'b0;
		op3 <= 16'b0;
		op4 <= 16'b0;
		op5 <= 16'b0;
		op6 <= 16'b0;
		sign_a <= 1'b1;
		end else begin
		case (M2_state)

///////////////////////////////////////////////////////////		
		S_M2_IDLE: begin
		   M2_done <= 1'b0;
			if(M2_start) begin
			address_a1 <= 7'b0;//for S'
			address_a2 <= 7'b0;
			address_b1 <= 7'b0;
			address_b2 <= 7'b0;
			address_c1 <= 7'b0;
			address_c2 <= 7'b0;
			write_data_a1 <= 32'b0;
			write_data_a2 <= 32'b0;
			write_data_b1 <= 32'b0;
			write_data_b2 <= 32'b0;
			write_data_c1 <= 32'b0;
			write_data_c2 <= 32'b0;
			S <= 32'b0;
			T <= 32'b0;
			S_prime_buff <= 16'b0;
			SRAM_we_n <= 1'b1;
			write_enable_a1 <= 1'b0;
			write_enable_b1 <= 1'b0;
			write_enable_c1 <= 1'b0;
			write_enable_a2 <= 1'b0;
			write_enable_b2 <= 1'b0;
			write_enable_c2 <= 1'b0;
			row_index <= 4'b0;
			col_index <= 4'b0;
			col_block_counter <= 9'b0;
			row_block_counter <= 9'b0;
			col_block_counter_w <= 9'b0;
			row_block_counter_w <= 9'b0;
			write_S_prime_ready <= 1'b0;//1: store prime to the buff 0: push both into RAM
			T_odd_sign <= 1'b0;
			Y_odd_sign <= 1'b0;
			ram_counter <= 9'b0;
			S_counter <= 7'b0;
			write_S_end <= 1'b0;
			Y_prime_if <= 1'b1;
			U_prime_if <= 1'b0;
			UV_prime_if <= 1'b0;
			Y_if <= 1'b1;
			U_if <= 1'b0;
			Y_odd <= 32'b0;
			Y_even <= 32'b0;
			stop <= 1'b0;
			counter_a <= 8'b0;
			counter_b <= 8'b0;
			sign_a <= 1'b1;
				M2_state <= LI_FS_0;
			end
	  end

///////////////////Lead In - FS' CT///////////////////////////////////
//////////////////////FS/////////////////////////////////////
      LI_FS_0: begin //Y0
		  SRAM_address <= S_prime_offset + all_address;//S'(0,0)
		  col_index <= col_index + 1;//col1
		  M2_state <= LI_FS_1;
		 end
			 
/////////////////////////////////////////////////////////////
      LI_FS_1: begin
		  SRAM_address <= S_prime_offset + all_address;//S'(0,1)
		  col_index <= col_index + 1;//col2
		  M2_state <= LI_FS_2;
		  end

/////////////////////CC//////////////////////////////////////
      LI_FS_2: begin
		  SRAM_address <= S_prime_offset + all_address;//S'(0,2)
		  col_index <= col_index + 1;//col3
		  M2_state <= LI_FS_3;
		  end
			  
/////////////////////////////////////////////////////////////
      LI_FS_3: begin
		  if(col_index == 4'd7) begin//1
			  if(row_index == 4'd7) begin//2
				 //Block ends
				 col_index <= 4'd0; //Both initialize to 0
				 row_index <= 4'd0;
				 write_enable_a1 <= 1'b0;
				 S_prime_buff <= SRAM_read_data; //store S'60 into the buff
				 SRAM_address <= S_prime_offset + all_address; //Read 63 S'
				 write_S_prime_ready <= 1'b1;
				 address_a1 <= address_a1 + 7'b1;
				 M2_state <= LI_FS_4; 
				 
			  end	
			  else begin//2
			  //change to the next row
				 row_index <= row_index + 4'b1;
				 col_index <= 4'b0;
				 if(~write_S_prime_ready) begin//3
					 write_enable_a1 <= 1'b0;
					 S_prime_buff <= SRAM_read_data; //store S'4, 11, 18, 25, 32, 39, 53
					 SRAM_address <= S_prime_offset + all_address;//address S'7, 14, 21, 28, 35, 42, 56
					 write_S_prime_ready <= 1'b1;
					 address_a1 <= address_a1 + 7'b1;
				 end else begin//3
					 write_data_a1 <= {S_prime_buff, SRAM_read_data};
					 SRAM_address <= S_prime_offset + all_address;
					 write_enable_a1 <= 1'b1;
					 write_S_prime_ready <= 1'b0;
				 end//3
			  end//2
		  //Col doesn't reach 7  
		  end else begin
			 if(~write_S_prime_ready) begin
				 SRAM_address <= S_prime_offset + all_address;
				 S_prime_buff <= SRAM_read_data; //store S' into the buff
				 col_index <= col_index + 4'b1; 
				 write_enable_a1 <= 1'b0;
				 write_S_prime_ready <= 1'b1;
				 address_a1 <= (sign_a)?7'b0:address_a1 + 7'b1;// for the first time fetch, col index is 1, address_a is 0
				 sign_a <= 1'b0;
				end else begin
				 write_data_a1 <= {S_prime_buff, SRAM_read_data};
				 SRAM_address <= S_prime_offset + all_address;
				 col_index <= col_index + 4'b1;
				 write_enable_a1 <= 1'b1;
				 write_S_prime_ready <= 1'b0;
				 
			 end
			 
			end
			end

///////////////////////////////////////////////////////////////
       LI_FS_4: begin //read S'61
			write_enable_a1 <= 1'b1;
			write_data_a1 <= {S_prime_buff, SRAM_read_data}; //Write the S' into ram
			M2_state <= LI_FS_5;
		end
		 
///////////////////////////////////////////////////////////////
       LI_FS_5: begin //S'62
			S_prime_buff <= SRAM_read_data; //store S' into the buff
			write_enable_a1 <= 1'b0;
			write_S_prime_ready <= 1'b0;
			address_a1 <= address_a1 + 7'b1;
			M2_state <= LI_FS_6;
			
		end
			
///////////////////////////////////////////////////////////////
       LI_FS_6: begin //S'63	
			write_enable_a1 <= 1'b1;
			write_data_a1 <= {S_prime_buff, SRAM_read_data};
			col_block_counter	<= col_block_counter + 9'b1;////1
			M2_state <= LI_CT_0;
			
			
		end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////			
///////////////////////////////////////////////////////////////
/////////////////////////////CT////////////////////////////////
		 LI_CT_0: begin
		   //Read S' and Ct for calculation
			address_a1 <= (ram_counter[8:6] << 2);
			address_a2 <= (ram_counter[8:6] << 2) + 7'b1;	//Start to get S'0 1 2 3
			address_b1 <= (ram_counter[5:3] << 2);
			address_b2 <= (ram_counter[5:3] << 2) + 7'b1; //get C (0,0) (1,0) (2,0) (3,0), C transpose (0,0) (0,1) (0,2) (0,3)
			write_enable_a1 <= 1'b0;
			
			M2_state <= LI_CT_1;
			
		end
//////////////////////////////////////////////////////////////////////////////		
		
///////////////////////////////////////////////////////////////
       LI_CT_1: begin
			
			address_a1 <= address_a1 + 7'b1;
			address_a2 <= address_a2 + 7'b1;	//Start to get S'4 5 6 7
			address_b1 <= address_b1 + 7'b1;
			address_b2 <= address_b2 + 7'b1; //get C(4,0) (5,0) (6,0) (7,0), C transpose (0,4) (0,5) (0,6) (0,7)
			
			M2_state <= LI_CT_2;
			
		end

//////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
		 LI_CT_2: begin
		   //Start calculation
			
			op1 <= $signed(read_data_a1 [31:16]);
			op2 <= $signed(read_data_b1 [31:16]); // S'(0:0) * C(0:0) C(0,0) = Ct(0,0)
			op3 <= $signed(read_data_a1 [15:0]);
			op4 <= $signed(read_data_b1 [15:0]); // S'(0:1) * C(1:0) C(1,0) = Ct(0,1)
			op5 <= $signed(read_data_a2 [31:16]);
			op6 <= $signed(read_data_b2 [31:16]); // S'(0:2) * C(2:0) C(2,0) = Ct(0,2)
			
			
			address_a1 <= address_a2 + 7'b1;
			address_b1 <= address_b2 + 7'b1;
		   
			
			M2_state <= LI_CT_3;
		end
		
//////////////////////////////////////////////////////////////////////////////		
			
////////////////////////////////////////////////////////////////
      LI_CT_3: begin //ram_counter [i,j,k]
		   
			T <= mult1 + mult2 + mult3;
			
			op1 <= $signed(read_data_a1 [15:0]);
			op2 <= $signed(read_data_b1 [15:0]);
			op3 <= $signed(read_data_a2 [31:16]);
			op4 <= $signed(read_data_b2 [31:16]); // S'(0:0) * C(0:0) C(0,0) = Ct(0,0)
			op5 <= $signed(read_data_a2 [15:0]);
			op6 <= $signed(read_data_b2 [15:0]); // S'(0:1) * C(1:0) C(1,0) = Ct(0,1)

		  
		   M2_state <= LI_CT_4; 
		 end
			 
///////////////////////////////////////////////////////////////
		LI_CT_4: begin
				
		  T <= T + mult1 + mult2 + mult3;
		  
		  op1 <= $signed(read_data_a1 [31:16]);
		  op2 <= $signed(read_data_b1 [31:16]); // S'(0:2) * C(2:0) C(2,0) = Ct(0,2)
		  op3 <= $signed(read_data_a1 [15:0]);
		  op4 <= $signed(read_data_b1 [15:0]); // store S'(0,3) C(3,0)
		 
		  M2_state <= LI_CT_5;
		 end	 
		 
///////////////////////////////////////////////////////////////
		LI_CT_5: begin
			 
		  T <= ((T + mult1 + mult2) >>> 8); //divided by 256
		  address_c1 <= (ram_counter[8:6] << 3) + ram_counter[5:3]; //get the address to store T
		  
		  M2_state <= LI_CT_6;
		 end	 
//////////////////////////////////////////////////////////////////
      LI_CT_6: begin
		  
			write_enable_c1 <= 1'b1;
			write_data_c1 <= T; // T0
			M2_state <= LI_CT_7;
			
			end

/////////////////////////////////////////////////////////////////////
      LI_CT_7: begin
		   
			//64 CC to store T totally
			if(counter_a < 8'd63) begin
				ram_counter <= ram_counter + 9'd8;
				
				M2_state <= LI_CT_0;
				counter_a <= counter_a + 8'b1;
			end
			else begin
				ram_counter <= 9'b0;
				sign_a <= 1'b1;// Initialize to 1 every time before go to CC_CS_FS, 1: address_a should start from 0
				M2_state <= CC_CS_FS_0;
				address_a1 <= 7'b0;
				write_enable_c1 <= 1'b0;
				write_enable_c2 <= 1'b0;
		 end
		 end
		 
///////////////////////CC//////////////////////////////////////
///////////////////////CS/FS'//////////////////////////////////
///////////////////////////////////////////////////////////////
//Use a1 to fetch S', a2 to store S
      CC_CS_FS_0: begin
		
		  address_b1 <= (ram_counter[8:6] << 2) + ram_counter[2:0]; //From C
		  address_b2 <= (ram_counter[8:6] << 2) + ram_counter[2:0] + 7'b1;
		  address_c1 <= (ram_counter[2:0] << 3) + ram_counter[5:3];//From T
		  address_c2 <= (ram_counter[2:0] << 3) + ram_counter[5:3] + 7'd8; 
		  write_enable_a1 <= 1'b0;
		  write_enable_a2 <= 1'b0;
		 
		  
		  ram_counter <= ram_counter + 9'd2;
		  
		  M2_state <= CC_CS_FS_1;
		end

///////////////////////////////////////////////////////////////////////////////
		CC_CS_FS_1: begin
		  address_b1 <= (ram_counter[8:6] << 2) + ram_counter[2:0]; //C_trans
		  address_b2 <= (ram_counter[8:6] << 2) + ram_counter[2:0] + 7'b1;
		  address_c1 <= (ram_counter[2:0] << 3) + ram_counter[5:3];//T
		  address_c2 <= ((1 + ram_counter[2:0]) << 3) + ram_counter[5:3]; 

		  ram_counter <= ram_counter + 9'd2;
		  
		  SRAM_address <= S_prime_offset + all_address;///////////////////////////////////Start locating
		  //col_index <= col_index + 1;//col1 2nd col_block
		  
		  M2_state <= CC_CS_FS_2;
		 
		 end

//////////////////////////////////////////////////////////////
      CC_CS_FS_2: begin
		   
			address_c1 <= (ram_counter[2:0] << 3) + ram_counter[5:3];//T
			address_c2 <= ((1 + ram_counter[2:0]) << 3) + ram_counter[5:3];
			
			C_trans_buff[0] <= $signed(read_data_b1 [31:16]);
			C_trans_buff[1] <= $signed(read_data_b1 [15:0]);
			C_trans_buff[2] <= $signed(read_data_b2 [31:16]);
			C_trans_buff[3] <= $signed(read_data_b2 [15:0]);
			T_buff[0] <= $signed(read_data_c1);
			T_buff[1] <= $signed(read_data_c2);
			
			
		   
		   ram_counter <= ram_counter + 9'd2;	
		  
			M2_state <= CC_CS_FS_3;
		 end

////////////////////////////////////////////////////////////////////////////
      CC_CS_FS_3: begin
			 
			address_c1 <= (ram_counter[2:0] << 3) + ram_counter[5:3];//T
			address_c2 <= ((1 + ram_counter[2:0]) << 3) + ram_counter[5:3]; 
			
			C_trans_buff[4] <= $signed(read_data_b1 [31:16]);
			C_trans_buff[5] <= $signed(read_data_b1 [15:0]);
			C_trans_buff[6] <= $signed(read_data_b2 [31:16]);
			C_trans_buff[7] <= $signed(read_data_b2 [15:0]);
			T_buff[2] <= $signed(read_data_c1);
			T_buff[3] <= $signed(read_data_c2);
		  
			ram_counter <= ram_counter + 9'd2;	
		   
			M2_state <= CC_CS_FS_4;
		end
			
/////////////////////////////////////////////////////////////////
		CC_CS_FS_4: begin//1
			
		  
			T_buff[4] <= $signed(read_data_c1);
			T_buff[5] <= $signed(read_data_c2);
		
			
			op1 = $signed(C_trans_buff[0]);
			op2 = $signed(T_buff[0]);
			op3 = $signed(C_trans_buff[1]);
			op4 = $signed(T_buff[1]);
			op5 = $signed(C_trans_buff[2]);
			op6 = $signed(T_buff[2]);
			
			if(col_index == 4'd7) begin//2
			  if(row_index == 4'd7) begin//3
				 //Block ends
				 col_index <= 4'b0; //Both initialize to 0
				 row_index <= 4'b0;
				 write_enable_a1 <= 1'b0;
				 S_prime_buff <= SRAM_read_data; //store S'60 into the buff
				 //SRAM_address <= S_prime_offset + all_address; //Read 63 S'
				 write_S_prime_ready <= 1'b1;
				 address_a1 <= address_a1 + 4'b1;
				 stop <= 1'b1;
				 
			  end else begin//3
			  //change to the next row
				 row_index <= row_index + 4'b1;
				 col_index <= 4'b0;
				 if(~write_S_prime_ready) begin//4
					 write_enable_a1 <= 1'b0;
					 S_prime_buff <= SRAM_read_data; 
					 write_S_prime_ready <= 1'b1;
					 address_a1 <= address_a1 + 4'b1;
				 end else begin//4
					 write_data_a1 <= {S_prime_buff, SRAM_read_data};
					 write_enable_a1 <= 1'b1;
					 write_S_prime_ready <= 1'b0;
				 end//4
				end//3
			 end else begin//2
			 if(~write_S_prime_ready) begin
				 S_prime_buff <= SRAM_read_data; //store S' into the buff
				 col_index <= col_index + 4'b1; 
				 write_enable_a1 <= 1'b0;
				 write_S_prime_ready <= 1'b1;
				 address_a1 <= (sign_a)?address_a1:address_a1 + 8'b1;
				 sign_a <= 1'b0;// for the first time fetch, col index is 1, address_a is 0
			 end else begin
				 write_data_a1 <= {S_prime_buff, SRAM_read_data};
				 col_index <= col_index + 4'b1;
				 write_enable_a1 <= 1'b1;
				 write_S_prime_ready <= 1'b0;
			 end
			 
			 end
   
			 
			M2_state <= CC_CS_FS_5;
		end
		

////////////////////////////////////////////////////////////////////
		CC_CS_FS_5: begin
		   
			
			T_buff[6] <= $signed(read_data_c1);
			T_buff[7] <= $signed(read_data_c2);
			
			S <= mult1 + mult2 + mult3;
			
			op1 = $signed(C_trans_buff[3]);
			op2 = $signed(T_buff[3]);
			op3 = $signed(C_trans_buff[4]);
			op4 = $signed(T_buff[4]);
			op5 = $signed(C_trans_buff[5]);
			op6 = $signed(T_buff[5]);
		  
		  
			M2_state <= CC_CS_FS_6;
		end
			
/////////////////////////////////////////////////////////////////////
      CC_CS_FS_6: begin
			
			S <= S + mult1 + mult2 + mult3;
			
			op1 = $signed(C_trans_buff[6]);
			op2 = $signed(T_buff[6]);
			op3 = $signed(C_trans_buff[7]);
			op4 = $signed(T_buff[7]);
			
			write_enable_a1 <= 1'b0;
			
			
			M2_state <= CC_CS_FS_7;
			
		end
			
////////////////////////////////////////////////////////////////////
      CC_CS_FS_7: begin
				
			S <= (S + mult1 + mult2) >>> 16;
			address_a2 <= 7'd64 + S_counter;
			
			M2_state <= CC_CS_FS_8;
				
		end

//////////////////////////////////////////////////////////////////////
		CC_CS_FS_8: begin
		
			write_enable_a2 <= 1'b1;
			write_data_a2 <= S;
			if(S_counter < 7'd63) begin
				S_counter <= S_counter + 7'b1;
			
				M2_state <= CC_CS_FS_0;
			end
			
			else begin
				/*write_enable_a2 <= 1'b1;
				write_enable_a1 <= 1'b0;
				write_data_a2 <= S;*/
				ram_counter <= 9'b0;
				S_counter <= 7'b0;
				stop <= 1'b0;
				write_S_prime_ready <= 1'b0;
				M2_state <= CC_WS_CT_buff;
				sign_a <= 1'b1;
			end
		end
	


			
////////////////////////////////////////////////////////////////////////
/////////////////CC_WS_CT///////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
		CC_WS_CT_buff: begin
		
		   write_enable_a1 <= 1'b0;
			write_enable_a2 <= 1'b0;
		   M2_state <= CC_WS_CT_0;
			
		  end
		  
/////////////////////////////////////////////////////////////////////////

		CC_WS_CT_0: begin
         SRAM_we_n <= 1'b1;		
			address_a1 <= (ram_counter[8:6] << 2);
			address_a2 <= (ram_counter[8:6] << 2) + 7'b1; //S'
			address_b1 <= (ram_counter[5:3] << 2);
			address_b2 <= (ram_counter[5:3] << 2) + 7'b1; //C
			write_enable_c1 <= 1'b0;
			
			M2_state <= CC_WS_CT_1;
			
		end
	
/////////////////////////////////////////////////////////////////////////
		CC_WS_CT_1: begin		
			
			address_a1 <= address_a1 + 7'b1;
			address_a2 <= address_a2 + 7'b1;	//Start to get S'4 5 6 7
			address_b1 <= address_b1 + 7'b1;
			address_b2 <= address_b2 + 7'b1; //get C(4,0) (5,0) (6,0) (7,0) from Ct in row
			 
			
			M2_state <= CC_WS_CT_2;
			
			end	
			
/////////////////////////////////////////////////////////////////////////////////

		CC_WS_CT_2: begin	
		
		   op1 <= $signed(read_data_a1 [31:16]);
			op2 <= $signed(read_data_b1 [31:16]); 
			op3 <= $signed(read_data_a1 [15:0]);
			op4 <= $signed(read_data_b1 [15:0]); 
			op5 <= $signed(read_data_a2 [31:16]);
			op6 <= $signed(read_data_b2 [31:16]); 
			
			address_a1 <= address_a2 + 7'b1;
			address_b1 <= address_b2 + 7'b1;
			
			
			
			
			M2_state <= CC_WS_CT_3;
			
		end	
			
/////////////////////////////////////////////////////////////////////////
		CC_WS_CT_3: begin		
		
		   T <= mult1 + mult2 + mult3;
			
			op1 <= $signed(read_data_a1 [15:0]);
			op2 <= $signed(read_data_b1 [15:0]);
			op3 <= $signed(read_data_a2 [31:16]);
			op4 <= $signed(read_data_b2 [31:16]); // S'(0:0) * C(0:0) C(0,0) = Ct(0,0)
			op5 <= $signed(read_data_a2 [15:0]);
			op6 <= $signed(read_data_b2 [15:0]); // S'(0:1) * C(1:0) C(1,0) = Ct(0,1)
			
			M2_state <= CC_WS_CT_4;
			end
			
///////////////////////////////////////////////////////////////////////////////////////////////
		CC_WS_CT_4: begin		
			T <= T + mult1 + mult2 + mult3;
			
			op1 <= $signed(read_data_a1 [31:16]);
			op2 <= $signed(read_data_b1 [31:16]); // S'(0:2) * C(2:0) C(2,0) = Ct(0,2)
			op3 <= $signed(read_data_a1 [15:0]);
			op4 <= $signed(read_data_b1 [15:0]); // store S'(0,3) C(3,0)
		  
		  //Writing is end	
		  if(write_S_end == 1'b1) begin
			  M2_state <= CC_WS_CT_5_a;
			  
		  end
		  //Writing keeps running
		  else begin
			M2_state <= CC_WS_CT_5;end
			 
			end
		
			
///////////////////////////////////////////////////////////////////////////
		CC_WS_CT_5: begin	
		
			T <= ((T + mult1 + mult2) >>> 8);
			address_c1 <= (ram_counter[8:6] << 3) + ram_counter[5:3];
	
			
				if(col_index == 4'd3) begin
				  if(row_index == 4'd7) begin
					 //Block ends
						col_index <= 4'b0; //Both initialize to 0
						row_index <= 4'b0; //store S'60 into the buff
						SRAM_address <= S_offset + w_address; //Read 63 S'
						address_a1 <= 7'd64 + counter_b[6:0];
					   address_a2 <= 7'd65 + counter_b[6:0];
						//SRAM_we_n <= 1'b0;	
					 end 
					else begin
				  //change to the next row
					 row_index <= row_index + 4'b1;
					 //SRAM_we_n <= 1'b0;	
					 col_index <= 4'b0;
					 SRAM_address <= S_offset + w_address;//address S'7, 14, 21, 28, 35, 42, 56
					 address_a1 <= 7'd64 + counter_b[6:0];
					 address_a2 <= 7'd65 + counter_b[6:0];
				  end
				end 
			  else begin
			       
					 SRAM_address <= S_offset + w_address;
					 //SRAM_we_n <= 1'b0;	
					 col_index <= col_index + 4'b1; 
					 write_enable_a1 <= 1'b0;
					 address_a1 <= 7'd64 + counter_b[6:0];
					 address_a2 <= 7'd65 + counter_b[6:0];// for the first time fetch, col index is 1, address_a is 0
					end
				 	
				M2_state <= CC_WS_CT_5_1;
		
			
		end
///////////////////////////////////////////////////////////////////////////////
		CC_WS_CT_5_1: begin
		  
		  M2_state <= CC_WS_CT_6;
		 end	

	

//////////////////////////////////////////////////////////////////////////////
		CC_WS_CT_6: begin		
				
			Y_even <= read_data_a1;
			Y_odd <= read_data_a2;
		
			M2_state <= CC_WS_CT_7;
			
		end
		
/////////////////////////////////////////////////////////////////////////////
	CC_WS_CT_5_a: begin	
	
			T <= ((T + mult1 + mult2) >>> 8);
			address_c1 <= (ram_counter[8:6] << 3) + ram_counter[5:3];
			M2_state <= CC_WS_CT_7;
			 end

		 
		
/////////////////////////////////////////////////////////////////////////////////
		CC_WS_CT_7: begin
		   
		   
			if(write_S_end == 1'b0) begin	
			  SRAM_we_n <= 1'b0;		
			  SRAM_write_data <= {Y_even_w, Y_odd_w};
			end
			write_enable_c1 <= 1'b1;
			write_data_c1 <= T; // T0
			
		   
			M2_state <= CC_WS_CT_8;	
			end

//////////////////////////////////////////////////////////////////////////////////
		CC_WS_CT_8: begin
		   
			SRAM_we_n <= 1'b1;
				//////////////////////////////////////////////////////////////////////////////////////	
		   write_enable_c1 <= 1'b0;
			write_enable_c2 <= 1'b0;
			if(counter_b <= 8'd126) begin
				if(counter_b >= 8'd62) begin
					write_S_end <= 1'b1;
				end
				ram_counter <= ram_counter + 9'd8;
				counter_b <= counter_b + 8'd2;
				M2_state <= CC_WS_CT_0;
			end
			else begin
			 
				ram_counter <= 9'b0;
				counter_b <= 0;
				M2_state <= CC_WS_CT_end;
				
			end
		end
			
			   

/////////////////////////////////////////////////////////////////////////////////
		CC_WS_CT_end: begin
		   write_S_end <= 1'b0;
		   SRAM_we_n <= 1'b1;
			address_a1 <= 7'b0;
			
			if(Y_if && col_block_counter_w >= 9'd39) begin//1
				if(row_block_counter_w >= 9'd29) begin//2 //if Y
					col_block_counter_w <= 9'b0;
				   row_block_counter_w <= 9'b0;
				   Y_if <= 1'b0;
				   U_if <= 1'b1;
			   end
			   else begin
				   col_block_counter_w <= 9'b0;
				   row_block_counter_w <= row_block_counter_w + 9'b1;
				end
			end 
			else if(U_if && col_block_counter_w >= 9'd19) begin//1
				if(row_block_counter_w >= 9'd59) begin//2 //if Y
					col_block_counter_w <= 9'b0;
				   row_block_counter_w <= 9'b0;
			   end
			   else begin
				   col_block_counter_w <= 9'b0;
				   row_block_counter_w <= row_block_counter_w + 9'b1;
				end
			end 
		
		
			else begin
			   col_block_counter_w <= col_block_counter_w + 9'b1;////////////////add col_block
				end
				

			//Reading from Y	
			if(Y_prime_if && col_block_counter >= 9'd39) begin//1
				if(row_block_counter == 9'd29) begin//2 //if Y
					col_block_counter <= 9'b0;
				   row_block_counter <= 9'b0;
				   Y_prime_if <= 1'b0;
				   UV_prime_if <= 1'b1;
				   M2_state <= CC_CS_FS_0;
			   end
			   
			   else begin
				   col_block_counter <= 9'b0;
				   row_block_counter <= row_block_counter + 9'b1;
				   M2_state <= CC_CS_FS_0;
				end 
				
		   end 
			
			//Reading from U/V
			else if (UV_prime_if && col_block_counter >= 9'd19) begin//1
				if(row_block_counter == 9'd59) begin//2 //if Y
					col_block_counter <= 9'b0;
				   row_block_counter <= 9'b0;
				  
				   M2_state <= LO_CS_0;;
			   end

					
			   else begin
				   col_block_counter <= 9'b0;
				   row_block_counter <= row_block_counter + 9'b1;
				   M2_state <= CC_CS_FS_0;
				end 
				end
			
			else begin
			   col_block_counter <= col_block_counter + 9'b1;////////////////add col_block
			   M2_state <= CC_CS_FS_0;
		   end
			end

/////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////LO//////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
		LO_CS_0: begin
			address_b1 <= (ram_counter[8:6] << 2) + ram_counter[2:0]; //T0T1
		   address_b2 <= (ram_counter[8:6] << 2) + ram_counter[2:0] + 7'b1;
		   address_c1 <= (ram_counter[2:0] << 3) + ram_counter[5:3];//From C
		   address_c2 <= ((1 + ram_counter[2:0]) << 3) + ram_counter[5:3]; 
	      
			ram_counter <= ram_counter + 9'd2;
			
			M2_state <= LO_CS_1;
		end
		
		 
///////////////////////////////////////////////////////////////////////////////////////////////
		LO_CS_1: begin
			address_b1 <= (ram_counter[8:6] << 2) + ram_counter[2:0]; //C_trans
			address_b2 <= (ram_counter[8:6] << 2) + ram_counter[2:0] + 7'b1;
		   address_c1 <= (ram_counter[2:0] << 3) + ram_counter[5:3];//T
		   address_c2 <= ((1 + ram_counter[2:0]) << 3) + ram_counter[5:3]; 
		  
			   
			ram_counter <= ram_counter + 9'd2;
			 
			  
         M2_state <= LO_CS_2;
			
		end
	
		
/////////////////////////////////////////////////////////////////////////////////////	
		LO_CS_2: begin
		
			C_trans_buff[0] <= $signed(read_data_b1 [31:16]);
		   C_trans_buff[1] <= $signed(read_data_b1 [15:0]);
		   C_trans_buff[2] <= $signed(read_data_b2 [31:16]);
			C_trans_buff[3] <= $signed(read_data_b2 [15:0]);
			T_buff[0] <= $signed(read_data_c1);
			T_buff[1] <= $signed(read_data_c2);
			
			address_c1 <= (ram_counter[2:0] << 3) + ram_counter[5:3];//T
			address_c2 <= ((1 + ram_counter[2:0]) << 3) + ram_counter[5:3]; 
			  
			  
		   ram_counter <= ram_counter + 9'd2;
			  
			 
			  
         M2_state <= LO_CS_3;	
		end
		

////////////////////////////////////////////////////////////////////////////////////
		LO_CS_3: begin
		
			C_trans_buff[4] <= $signed(read_data_b1 [31:16]);
			C_trans_buff[5] <= $signed(read_data_b1 [15:0]);
			C_trans_buff[6] <= $signed(read_data_b2 [31:16]);
		   C_trans_buff[7] <= $signed(read_data_b2 [15:0]);
			T_buff[2] <= $signed(read_data_c1);
		   T_buff[3] <= $signed(read_data_c2);
			
			address_c1 <= (ram_counter[2:0] << 3) + ram_counter[5:3];//T
			address_c2 <= ((1 + ram_counter[2:0]) << 3) + ram_counter[5:3]; 
			  
			
			  
			ram_counter <= ram_counter + 9'd2;
				
			
			M2_state <= LO_CS_4;	 
		end
	
	
////////////////////////////////////////////////////////////////////////////////////////
		LO_CS_4: begin
		
		   T_buff[4] <= $signed(read_data_c1);
			T_buff[5] <= $signed(read_data_c2);
			
			op1 = $signed(C_trans_buff[0]);
			op2 = $signed(T_buff[0]);
			op3 = $signed(C_trans_buff[1]);
			op4 = $signed(T_buff[1]);
			op5 = $signed(C_trans_buff[2]);
			op6 = $signed(T_buff[2]);
		     
			
			  
			M2_state <= LO_CS_5;
		end

////////////////////////////////////////////////////////////////////////////////////////
		LO_CS_5: begin
			
			T_buff[6] <= $signed(read_data_c1);
			T_buff[7] <= $signed(read_data_c2);
				
			S <= mult1 + mult2 + mult3;
				
			op1 = $signed(C_trans_buff[3]);
			op2 = $signed(T_buff[3]);
			op3 = $signed(C_trans_buff[4]);
			op4 = $signed(T_buff[4]);
			op5 = $signed(C_trans_buff[5]);
			op6 = $signed(T_buff[5]);
			  
			   	
			
				
			M2_state <= LO_CS_6;
				
		end	

////////////////////////////////////////////////////////////////////
      LO_CS_6: begin
		
		   S <= S + mult1 + mult2 + mult3;
				
			op1 = $signed(C_trans_buff[6]);
			op2 = $signed(T_buff[6]);
			op3 = $signed(C_trans_buff[7]);
			op4 = $signed(T_buff[7]);
				
			//write_enable_a1 <= 1'b0;
				
			address_a2 <= 7'd64 + S_counter;
	
			  
			M2_state <= LO_CS_7;
				
			end

//////////////////////////////////////////////////////////////////////
		 LO_CS_7: begin
		

			//write_enable_a1 <= 1'b0;
				
			S <= (S + mult1 + mult2) >>> 16;
			address_a2 <= 7'd64 + S_counter;
	
			  
			M2_state <= LO_CS_8;
				
			end
			
//////////////////////////////////////////////////////////////////////////
		LO_CS_8: begin
			write_enable_a2 <= 1'b1;
			write_data_a2 <= S;
				
			if(S_counter < 7'd63) begin
				S_counter <= S_counter + 7'b1;
				M2_state <= LO_CS_0;
				
			end
			else begin	
				S_counter <= 7'b0;
				M2_state <= LO_WS_0;
			end
	
		end	
			
////////////////////////////////////////////////////////////////////////
///////////////////////////////WS////////////////////////////////////////			
		LO_WS_0: begin
			
			write_enable_a2 <= 1'b0;
			SRAM_we_n <= 1'b1;	
			M2_state <= LO_WS_1;
	end


////////////////////////////////////////////////////////////////////////	
		LO_WS_1: begin		
			SRAM_we_n <= 1'b1;	
			
			if(col_index == 4'd3) begin
			  if(row_index == 4'd7) begin
				 //Block ends\
				 row_index <= 4'b0;
				 col_index <= 4'b0;
				 write_S_end <= 1'b1;
				 SRAM_address <= S_offset + w_address; //Read 63 S'
				 address_a1 <= 7'd64 + counter_b[6:0];
				 address_a2 <= 7'd65 + counter_b[6:0];
				 
				 
			  end else begin
			  //change to the next row
				 row_index <= row_index + 4'b1;
				 col_index <= 4'b0;
				 SRAM_address <= S_offset + w_address;//address S'7, 14, 21, 28, 35, 42, 56
				 address_a1 <= 7'd64 + counter_b[6:0];
				 address_a2 <= 7'd65 + counter_b[6:0];
			  end
			  
		  //Col doesn't reach 7  
		 end else begin
				 SRAM_address <= S_offset + w_address;
				 col_index <= col_index + 4'b1; 
				 write_enable_a1 <= 1'b0;
				 address_a1 <= 7'd64 + counter_b[6:0];
				 address_a2 <= 7'd65 + counter_b[6:0];
				end
		  M2_state <= LO_WS_1_1;
		end
////////////////////////////////////////////////////////////////////////////////////////////
		
		LO_WS_1_1: begin
		  M2_state <= LO_WS_2;
		 end
		 
///////////////////////////////////////////////////////////////////////////////////////////

		LO_WS_2: begin
			
			Y_even <= read_data_a1;
			Y_odd <= read_data_a2;
		 
			M2_state <= LO_WS_3;
		end	
			
///////////////////////////////////////////////////////////////////////////////
		LO_WS_3: begin
			SRAM_we_n <= 1'b0;
			SRAM_write_data <= {Y_even_w, Y_odd_w};
			
			if(counter_b == 8'd62) begin
				M2_state <= M2_Done;
				end
				
			else begin
			   counter_b <= counter_b + 8'd2;
				M2_state <= LO_WS_0;
				end
			end
			
//////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////		
		M2_Done: begin
			M2_done <= 1'b1;
			SRAM_we_n <= 1'b1;
			M2_state <= M2_Done_all;
		end
		
//////////////////////////////////////////////////////////////////////////////////////////////////////////
		M2_Done_all: begin
		   //M2_Done <= 1'b1;
			M2_state <= S_M2_IDLE;
			
		end
			
		default: M2_state <= S_M2_IDLE;









endcase
	end
end




endmodule