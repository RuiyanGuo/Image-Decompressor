//Group_6
//This file is for milestone1

`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

// It connects the UART, SRAM and VGA together.
// It gives access to the SRAM for UART and VGA
module milestone1 (
    input logic CLOCK_50_I,                   
    input logic resetn,                      
    input logic M1_start,
    input logic [15:0] SRAM_read_data,
    output logic [15:0] SRAM_write_data,
    output logic [17:0] SRAM_address,
    output logic SRAM_we_n,
	 output logic M1_done 

);
M1_state_type M1_state;
parameter 
			 
          RGB_Y = 18'd76284,
          R_V = 18'd104595,
          G_U = 18'd25624,
			 G_V = 18'd53281,
          B_U = 18'd132251,
			 U_5 = 8'd21,
			 V_5 = 8'd21,
          U_3 = 8'd52,
			 V_3 = 8'd52,
          U_1 = 8'd159,
			 V_1 = 8'd159,
			 UV_plus = 8'd128,
			 Y_start = 18'd0,
          U_start = 18'd38400,
          V_start = 18'd57600,
			 Y_RGB_minus = 8'd16,
			 U_RGB_minus = 8'd128,
			 V_RGB_minus = 8'd128,
          RGB_start = 18'd146944,	 
			 RGB_base_address = 18'd146944;
			 

logic [15:0] Y_value; 
logic [31:0] U_even_value; //U'even
logic [31:0] U_odd_value; //U'odd
logic [7:0] U_buff; //store U
logic [31:0] V_even_value; //V'even
logic [31:0] V_odd_value;//V'odd
logic [7:0] V_buff; //store V 
logic [7:0] U_plus5;
logic [7:0] U_plus3;
logic [7:0] U_plus1;
logic [7:0] U_minus1;
logic [7:0] U_minus3;
logic [7:0] U_minus5;
logic [7:0] V_plus5;
logic [7:0] V_plus3;
logic [7:0] V_plus1;
logic [7:0] V_minus1;
logic [7:0] V_minus3;
logic [7:0] V_minus5;
logic [17:0] counter_Y, counter_U, counter_V, counter_RGB; 
//logic [31:0] U_odd, U_even, Y_odd, Y_even, V_odd, Y_even;
logic [31:0] R_even, R_odd, G_even, G_odd, B_even, B_odd;//31
logic [31:0] op1, op2, op3, op4;



//logic [31:0] result1;
logic [31:0] mult1, mult2;//31
logic [1:0] state_pin;
logic [7:0] count_pos;
logic [7:0] count_row;
//logic [18:0] Line_counter;
always @(posedge CLOCK_50_I or negedge resetn) begin
    if (~resetn) begin
        M1_state <= S_M1_IDLE;
        M1_done <= 1'b0;

        counter_Y <= 18'd0;
        counter_U <= 18'd0;
		  counter_V <= 18'd0;
        counter_RGB <= 18'd0;

        Y_value <= 16'd0;
        U_even_value <= 32'd0;
		  U_odd_value <= 32'd0;
        
		  U_buff <= 8'd0;
        V_even_value <= 32'd0;
		  V_odd_value <=32'd0;
       
		  V_buff <= 8'd0;
		  
		  U_plus5 <= 8'd0;
        U_plus3 <= 8'd0;
        U_plus1 <= 8'd0;
        U_minus1 <= 8'd0;
        U_minus3 <= 8'd0;
        U_minus5 <= 8'd0;
        V_plus5 <= 8'd0;
        V_plus3 <= 8'd0;
        V_plus1 <= 8'd0;
        V_minus1 <= 8'd0;
        V_minus3 <= 8'd0;
        V_minus5 <= 8'd0;
		  
        R_odd <=32'd0;
        G_odd <= 32'd0;
        B_odd <= 32'd0;
		  R_even <= 32'd0;
        G_even <= 32'd0;
        B_even <= 32'd0;
		  
		  count_row <= 8'd0;
		  count_pos <= 8'd0;
		  state_pin <= 2'b0;
		  //Line_counter <= 18'd0;
		  
		  op1 <= 32'b0;
		  op2 <= 32'b0;
		  op3 <= 32'b0;
        op4 <= 32'b0;

        SRAM_address <= 18'd0;
        SRAM_write_data <= 16'd0;
        SRAM_we_n <= 1'b1;
		 
		 end else begin
        case (M1_state)

        S_M1_IDLE: begin
		      M1_done <= 1'b0;
            if(M1_start) begin
				    counter_Y <= 18'd0;
                counter_U <= 18'd0;
		          counter_V <= 18'd0;
                counter_RGB <= 18'd0;

			 	    Y_value <= 16'd0;
                U_even_value <= 32'd0;
		          U_odd_value <= 32'd0;
		          U_buff <= 8'd0;
                V_even_value <= 32'd0;
		          V_odd_value <= 32'd0;
		          V_buff <= 8'd0;
		   
		          U_plus5 <= 8'd0;
                U_plus3 <= 8'd0;
                U_plus1 <= 8'd0;
                U_minus1 <= 8'd0;
                U_minus3 <= 8'd0;
                U_minus5 <= 8'd0;
                V_plus5 <= 8'd0;
                V_plus3 <= 8'd0;
                V_plus1 <= 8'd0;
                V_minus1 <= 8'd0;
                V_minus3 <= 8'd0;
                V_minus5 <= 8'd0;
		  
                R_odd <= 32'd0;
                G_odd <= 32'd0;
                B_odd <= 32'd0;
		          R_even <= 32'd0;
                G_even <= 32'd0;
                B_even <= 32'd0;
		  
		  
		         state_pin <= 2'b0;
					count_pos <= 8'd2;
					count_row <= 8'd0;
		         //Line_counter <= 18'd0;
		  
		         op1 <= 32'b0;
		         op2 <= 32'b0;
		         op3 <= 32'b0;
               op4 <= 32'b0;
					
               SRAM_we_n <= 1'b1;
               SRAM_address <= 18'd0;
               SRAM_write_data <= 16'd0;

               M1_state <= S_LI_0;
            end
        end

///////////////////////////////////////////////////		  
////////////////Lead In////////////////////////////
///////////////////////////////////////////////////1		  
		  S_LI_0: begin
		      count_row <= count_row + 8'd1;
		      SRAM_we_n <= 1'b1;
		      SRAM_address <= Y_start + counter_Y;
				counter_Y <= counter_Y + 18'd1; //Y0Y1
				
            M1_state <= S_LI_1;
				end
				
///////////////////////////////////////////////////2		  
		  S_LI_1: begin
		      SRAM_address <= U_start + counter_U;
				counter_U <= counter_U + 18'd1; //U0U1
				
				M1_state <= S_LI_2;
				end
				
///////////////////////////////////////////////////3
		  S_LI_2: begin
				SRAM_address <= V_start + counter_V;
				counter_V <= counter_V + 18'd1; //V0V1
				
				M1_state <= S_LI_3;
				end
				
///////////////////////////////////////////////////4
        S_LI_3: begin
		      SRAM_address <= U_start + counter_U; //U2U3
				counter_U <= counter_U + 18'd1;
				
		      //Store Y0Y1 into Y register
				Y_value <= SRAM_read_data;
				
				M1_state <= S_LI_4;
			end
				
///////////////////////////////////////////////////5
        S_LI_4: begin
		      SRAM_address <= V_start + counter_V; //V2V3
				counter_V <= counter_V + 18'd1;
		      //Store U0 into U prime register
		      U_even_value <= SRAM_read_data[15:8]; //U'0
				//To get the value of U(j+1 j-1 j-3 j-5)/2
				U_minus5 <= SRAM_read_data[15:8]; //V[(j-5)/2] = U0
				U_minus3 <= SRAM_read_data[15:8]; //V[(j-3)/2] = U0
				U_minus1 <= SRAM_read_data[15:8]; //V[(j-1)/2] = U0
				U_plus1 <= SRAM_read_data[7:0]; //V[(j+1)/2] = U1
	
            M1_state <= S_LI_5;
        end
		  
//////////////////////////////////////////////////6
       S_LI_5: begin
		      V_even_value <= SRAM_read_data[15:8]; //V'0
				//To get the value of V(j+1 j-1 j-3 j-5)/2
				V_minus5 <= SRAM_read_data[15:8]; //V[(j-5)/2] = V0
				V_minus3 <= SRAM_read_data[15:8]; //V[(j-3)/2] = V0
				V_minus1 <= SRAM_read_data[15:8]; //V[(j-1)/2] = V0
				V_plus1 <= SRAM_read_data[7:0]; //V[(j+1)/2] = V1
		
            M1_state <= S_LI_6;
			end
			
//////////////////////////////////////////////////7
       S_LI_6: begin
		      U_plus3 <= SRAM_read_data[15:8]; //U[(j+3)/2] = U2
		      U_plus5 <= SRAM_read_data[7:0]; //U[(j+5)/2] = U3 
				
				op1 <= Y_value[15:8] - Y_RGB_minus;//Y0
				op2 <= RGB_Y; //E(Y)
				op3 <= Y_value[7:0] - Y_RGB_minus;//Y1
				op4 <= RGB_Y; //O(Y)
				
				M1_state <= S_LI_7;
			end
			
//////////////////////////////////////////////////8
       S_LI_7: begin
		      SRAM_address <= Y_start + counter_Y; //Y2Y3
				counter_Y <= counter_Y + 18'd1;
				V_plus3 <= SRAM_read_data[15:8]; //V[(j+3)/2] = V2
		      V_plus5 <= SRAM_read_data[7:0]; //V[(j+5)/2] = V3 
				
				R_even <= mult1;//calculate R0
				R_odd <= mult2;
				G_even <= mult1;//calculate G0
				G_odd <= mult2;
				B_even <= mult1;//calculate B0
				B_odd <= mult2;
				
				M1_state <= S_LI_8;
			end
			
//////////////////////////////////////////////////9
       S_LI_8: begin
				SRAM_address <= U_start + counter_U; //U4U5
				counter_U <= counter_U + 18'd1;
				
				op1 <= U_plus5 + U_minus5;
				op2 <= U_5;
				op3 <= V_plus5 + V_minus5;
				op4 <= V_5;
				
				
				M1_state <= S_LI_9;
			end
				
//////////////////////////////////////////////////10
       S_LI_9: begin
		     SRAM_address <= V_start + counter_V; //V4V5
			  counter_V <= counter_V + 18'd1;
		     U_odd_value <= mult1;//calaculate U'1
			  V_odd_value <= mult2;//calaculate V'1
			  
		     op1 <= U_plus3 + U_minus3;
			  op2 <= U_3;//*****************************************
			  op3 <= V_plus3 + V_minus3;
			  op4 <= V_3;//**********************************
				
			  M1_state <= S_LI_10;
			 end
			
//////////////////////////////////////////////////11
       S_LI_10: begin
		     Y_value <= SRAM_read_data; //store Y2Y3
		 
		     U_odd_value <= U_odd_value - mult1;//calaculate U'1**************************
			  V_odd_value <= V_odd_value - mult2;//calaculate V'1************************
			  
		     op1 <= U_plus1 + U_minus1;
			  op2 <= U_1;
			  op3 <= V_plus1 + V_minus1;
			  op4 <= V_1;	
				
			  M1_state <= S_LI_11;
		end
			 
//////////////////////////////////////////////////12
       S_LI_11: begin
		     U_odd_value <= (U_odd_value + mult1 + UV_plus) >>> 8;//calaculate U'1 done
			  V_odd_value <= (V_odd_value + mult2 + UV_plus) >>> 8;//calaculate V'1 done
			  
			  U_buff <= SRAM_read_data[7:0]; // store U5 for the next iteration
			  //To get the parameters to calculate U'3
			  U_minus5 <= U_minus3; //U[(j-5)/2] = U0
			  U_minus3 <= U_minus1; // U[(j-3)/2] = U0
			  U_minus1 <= U_plus1; // U[(j-1)/2] = U1
			  U_plus1 <= U_plus3; // U[(j+1)/2] = U2
			  U_plus3 <= U_plus5; // U[(j+3)/2] = U3
			  U_plus5 <= SRAM_read_data[15:8]; // U[(j+5)/2] = U4
				
			  M1_state <= S_LI_12;
	   end
		
/////////////////////////////////////////////////13
       S_LI_12: begin
		     V_buff <= SRAM_read_data[7:0]; // store V5 for the next iteration
			  //To get the parameters to calculate V'3
			  V_minus5 <= V_minus3; //V[(j-5)/2] = V0
			  V_minus3 <= V_minus1; // V[(j-3)/2] = V0
			  V_minus1 <= V_plus1; // V[(j-1)/2] = V1
			  V_plus1 <= V_plus3; // V[(j+1)/2] = V2
			  V_plus3 <= V_plus5; // V[(j+3)/2] = V3
			  V_plus5 <= SRAM_read_data[15:8]; // V[(j+5)/2] = V4
				
		     op1 <= U_even_value - U_RGB_minus;
			  op2 <= G_U;//************************************************
			  op3 <= U_odd_value - U_RGB_minus;
		     op4 <= G_U;//************************************************
			 
			  M1_state <= S_LI_13;
			end
			
//////////////////////////////////////////////////14
       S_LI_13: begin
		     G_even <= G_even - mult1;//calculate G***************************
			  G_odd <= G_odd - mult2;//*******************************************
				
			  op1 <= U_even_value - U_RGB_minus;
			  op2 <= B_U;
			  op3 <= U_odd_value - U_RGB_minus;
			  op4 <= B_U;	
				
			  M1_state <= S_LI_14;
			end
			
//////////////////////////////////////////////////15
       S_LI_14: begin
		     B_even <= B_even + mult1;//B calculation done
			  B_odd <= B_odd + mult2;
		      
			  op1 <= V_even_value - V_RGB_minus;
			  op2 <= R_V;
			  op3 <= V_odd_value - V_RGB_minus;
			  op4 <= R_V;		
				
			  M1_state <= S_LI_15;
			end
			
//////////////////////////////////////////////////16
       S_LI_15: begin
		     R_even <= R_even + mult1;//R calculation done
			  R_odd <= R_odd + mult2;
		     
			  op1 <= V_even_value - V_RGB_minus;
			  op2 <= G_V;//*****************************************************
			  op3 <= V_odd_value - V_RGB_minus;
			  op4 <= G_V;	//**************************************************
				
				
			  M1_state <= S_LI_16;
			end
			
//////////////////////////////////////////////////17
       S_LI_16: begin
		     G_even <= G_even - mult1;//G calculation done*********************
			  G_odd <= G_odd - mult2;//********************************
			  
			  U_even_value <= U_minus1; //U'2
			  V_even_value <= V_minus1; //V'2
			  
			  op1 <= U_plus5 + U_minus5;
			  op2 <= U_5;
			  op3 <= V_plus5 + V_minus5;
			  op4 <= V_5;
				
				
			  M1_state <= S_LI_17;
			end
			
/////////////////////////////////////////////////18
       S_LI_17: begin
		     SRAM_address <= RGB_start + counter_RGB;
		     counter_RGB <= counter_RGB + 18'd1;
	        SRAM_we_n <= 1'b0;//start writing	
				
		     SRAM_write_data[15:8] <= (R_even[31] == 1'b1)?8'b0:((|R_even[30:24])?8'd255:R_even[23:16]); //write R0
           SRAM_write_data[7:0] <= (G_even[31] == 1'b1)?8'b0:((|G_even[30:24])?8'd255:G_even[23:16]); //write G0
			  
			  U_odd_value <= mult1;//calaculate U'3
			  V_odd_value <= mult2;//calaculate V'3
			  
		     op1 <= U_plus3 + U_minus3;
			  op2 <= U_3;//*****************************
			  op3 <= V_plus3 + V_minus3;
			  op4 <= V_3;	//*****************************
			  
			  M1_state <= S_LI_18;
			end
			  
//////////////////////////////////////////////////19
       S_LI_18: begin
		     SRAM_address <= RGB_start + counter_RGB;
		     counter_RGB <= counter_RGB + 18'd1;
	        //SRAM_we_n <= 1'b0;//start writing	
				
		     SRAM_write_data[15:8] <= (B_even[31] == 1'b1)?8'b0:((|B_even[30:24])?8'd255:B_even[23:16]); //write B0
           SRAM_write_data[7:0] <= (R_odd[31] == 1'b1)?8'b0:((|R_odd[30:24])?8'd255:R_odd[23:16]); //write R1
			  
			  U_odd_value <= U_odd_value - mult1;//calaculate U'3*************************
			  V_odd_value <= V_odd_value - mult2;//calaculate V'3*****************************
			  
		     op1 <= U_plus1 + U_minus1;
			  op2 <= U_1;
			  op3 <= V_plus1 + V_minus1;
			  op4 <= V_1;
			  
			  M1_state <= S_LI_19;
			end

////////////////////////////////////////////////////20
       S_LI_19: begin
		     SRAM_address <= RGB_start + counter_RGB;
		     counter_RGB <= counter_RGB + 18'd1;
	        //SRAM_we_n <= 1'b0;//start writing	
				
		     SRAM_write_data[15:8] <= (G_odd[31] == 1'b1)?8'b0:((|G_odd[30:24])?8'd255:G_odd[23:16]); //write G1
           SRAM_write_data[7:0] <= (B_odd[31] == 1'b1)?8'b0:((|B_odd[30:24])?8'd255:B_odd[23:16]); //write B1
			  
			  U_odd_value <= (U_odd_value + mult1 + UV_plus) >>> 8;//calaculate U'3 done
			  V_odd_value <= (V_odd_value + mult2 + UV_plus) >>> 8;//calaculate V'3 done
			  
		     op1 <= Y_value[15:8] - Y_RGB_minus;
			  op2 <= RGB_Y; //E(Y)
			  op3 <= Y_value[7:0] - Y_RGB_minus;
			  op4 <= RGB_Y; //O(Y)
				
			  
			  M1_state <= S_LI_20;
			end
			
////////////////////////////////////////////////////21
       S_LI_20: begin
		     SRAM_we_n <= 1'b1;//stop writing
		     SRAM_address <= Y_start + counter_Y; //Y4Y5
			  counter_Y <= counter_Y + 18'd1;	
	
	         R_even <= mult1;//calculate R
				R_odd <= mult2;
				G_even <= mult1;//calculate G
				G_odd <= mult2;
				B_even <= mult1;//calculate B
				B_odd <= mult2;
				
				op1 <= U_even_value - U_RGB_minus;
				op2 <= G_U;//*********************************
				op3 <= U_odd_value - U_RGB_minus;
				op4 <= G_U;//******************************				
			  
			  M1_state <= S_LI_21;
			end
			
////////////////////////////////////////////////////22
       S_LI_21: begin
		     //don't read U/V here
	        //SRAM_we_n <= 1'b1;//stop writing	
	
	         G_even <= G_even - mult1;//calculate G**********************8
				G_odd <= G_odd - mult2;//********************************
				
				op1 <= U_even_value - U_RGB_minus;
				op2 <= B_U;
				op3 <= U_odd_value - U_RGB_minus;
				op4 <= B_U;	
			  
			  M1_state <= S_LI_22;
			end
			
////////////////////////////////////////////////////23
       S_LI_22: begin
	         B_even <= B_even + mult1;//B calculation done //B2
				B_odd <= B_odd + mult2; //B3
		      
				op1 <= V_even_value - V_RGB_minus;
				op2 <= R_V;
				op3 <= V_odd_value - V_RGB_minus;
				op4 <= R_V;	
			  
			  M1_state <= S_LI_23;
			end
			
////////////////////////////////////////////////////24
       S_LI_23: begin 
		      Y_value <= SRAM_read_data; //store Y4Y5
		
	         R_even <= R_even + mult1;//R calculation done //R2
				R_odd <= R_odd + mult2; //R3
		      
				op1 <= V_even_value - V_RGB_minus;
				op2 <= G_V;//***********************************************
				op3 <= V_odd_value - V_RGB_minus;
				op4 <= G_V;	//*************************************
				
				//U_buff <= SRAM_read_data[7:0]; // store U7 for the next iteration
				//To get the parameters to calculate U'9
				U_minus5 <= U_minus3; //U[(j-5)/2] = U0
				U_minus3 <= U_minus1; // U[(j-3)/2] = U1
				U_minus1 <= U_plus1; // U[(j-1)/2] = U2
				U_plus1 <= U_plus3; // U[(j+1)/2] = U3
				U_plus3 <= U_plus5; // U[(j+3)/2] = U4
				U_plus5 <= U_buff; // U[(j+5)/2] = U5
			  
			  M1_state <= S_LI_24;
			end

////////////////////////////////////////////////////
       S_LI_24: begin
	         G_even <= G_even - mult1;//G calculation done //G2*******************8
				G_odd <= G_odd - mult2; //G3****************************************
		      
				//No multiplication now	
				
				//V_buff <= SRAM_read_data[7:0]; // store V7 for the next iteration
				//To get the parameters to calculate V'9
				V_minus5 <= V_minus3; //V[(j-5)/2] = V0
				V_minus3 <= V_minus1; // V[(j-3)/2] = V1
				V_minus1 <= V_plus1; // V[(j-1)/2] = V2
				V_plus1 <= V_plus3; // V[(j+1)/2] = V3
				V_plus3 <= V_plus5; // V[(j+3)/2] = V4
				V_plus5 <= V_buff; // V[(j+5)/2] = V5
			  
			  M1_state <= S_CC_0;
			end
			
//////////////////////////////////////////////////
/////////////Common Case//////////////////////////
////////////////CC0///////////////////////////////
//Start: Address:6/7 computing:4/5 writing:2/3
//Start to calculate RGB
        S_CC_0: begin
		      count_pos <= count_pos + 8'd1;
		      SRAM_address <= RGB_start + counter_RGB;
		      counter_RGB <= counter_RGB + 18'd1;                                                                          //??????
	         SRAM_we_n <= 1'b0;//start writing	
				
				SRAM_write_data[15:8] <= (R_even[31] == 1'b1)?8'b0:((|R_even[30:24])?8'd255:R_even[23:16]); //write R2         //??????
            SRAM_write_data[7:0] <= (G_even[31] == 1'b1)?8'b0:((|G_even[30:24])?8'd255:G_even[23:16]); //write G2

				op1 <= U_plus5 + U_minus5;
				op2 <= U_5;
				op3 <= V_plus5 + V_minus5;
				op4 <= V_5;
				
				M1_state <= S_CC_1;
			end
			
////////CC1//////////////////////////////////////
        S_CC_1: begin
		      SRAM_address <= RGB_start + counter_RGB;
				counter_RGB <= counter_RGB + 18'd1;
	         
            SRAM_write_data[15:8] <= (B_even[31] == 1'b1)?8'b0:((|B_even[30:24])?8'd255:B_even[23:16]); //write B2
            SRAM_write_data[7:0] <= (R_odd[31] == 1'b1)?8'b0:((|R_odd[30:24])?8'd255:R_odd[23:16]); //write R3
				
				U_even_value <= U_minus1;//U2 in first iteration
				
				U_odd_value <= mult1;//calaculate U'5
				V_odd_value <= mult2;//calaculate V'5
		      
			   op1 <= U_plus3 + U_minus3;
				op2 <= U_3;
				op3 <= V_plus3 + V_minus3;
				op4 <= V_3;	
				
				M1_state <= S_CC_2;
			end
			
////////CC2//////////////////////////////////////
        S_CC_2: begin
		      SRAM_address <= RGB_start + counter_RGB;
				counter_RGB <= counter_RGB + 18'd1;
	        // SRAM_we_n <= 1'b0;	
		
            SRAM_write_data[15:8] <= (G_odd[31] == 1'b1)?8'b0:((|G_odd[30:24])?8'd255:G_odd[23:16]); //write G3
            SRAM_write_data[7:0] <= (B_odd[31] == 1'b1)?8'b0:((|B_odd[30:24])?8'd255:B_odd[23:16]); //write B3
		     
				
				V_even_value <= V_minus1;//V2 in first iteration
				
				U_odd_value <= U_odd_value - mult1;//calaculate U'5
				V_odd_value <= V_odd_value - mult2;//calaculate V'5
				
				op1 <= U_plus1 + U_minus1;
				op2 <= U_1;
				op3 <= V_plus1 + V_minus1;
				op4 <= V_1;	
				
				M1_state <= S_CC_3;
			end
			
////////CC4//////////////////////////////////////
//Start from the address 6/7	
        S_CC_3: begin
		      SRAM_we_n <= 1'b1;//stop writing
	         SRAM_address <= Y_start + counter_Y;
				counter_Y <= counter_Y + 18'd1;
		  
		      U_odd_value <= (U_odd_value + mult1 + UV_plus) >>> 8;//calaculate U'5 done
				V_odd_value <= (V_odd_value + mult2 + UV_plus) >>> 8;//calaculate V'5 done
				
				/*R_odd <= 63'd0;//initialize RGB buff to 0
            G_odd <= 63'd0;
            B_odd <= 63'd0;
		      R_even <= 63'd0;
            G_even <= 63'd0;
            B_even <= 63'd0;*/
				
				op1 <= Y_value[15:8] - Y_RGB_minus; //Y4 here   even
				op2 <= RGB_Y; //E(Y)
				op3 <= Y_value[7:0] - Y_RGB_minus; //Y5 here    odd
				op4 <= RGB_Y; //O(Y)
				
				M1_state <= S_CC_4;
			end

////////CC5//////////////////////////////////////	
        S_CC_4: begin
		      if(state_pin == 2'b0) begin 
				   SRAM_address <= U_start + counter_U;
				   counter_U <= counter_U + 18'd1;
				end
				
		      R_even <= mult1;//calculate R
				R_odd <= mult2;
				G_even <= mult1;//calculate G
				G_odd <= mult2;
				B_even <= mult1;//calculate B
				B_odd <= mult2;
				
				op1 <= U_even_value - U_RGB_minus;
				op2 <= G_U;
				op3 <= U_odd_value - U_RGB_minus;
				op4 <= G_U;	
				
				M1_state <= S_CC_5;
			end
			
////////CC6//////////////////////////////////////	
        S_CC_5: begin
		      if(state_pin == 2'b0) begin 
	            SRAM_address <= V_start + counter_V;
				   counter_V = counter_V + 18'd1;
				end
	
				G_even <= G_even - mult1;//calculate G
				G_odd <= G_odd - mult2;
				
				op1 <= U_even_value - U_RGB_minus;
				op2 <= B_U;
				op3 <= U_odd_value - U_RGB_minus;
				op4 <= B_U;	
				
				M1_state <= S_CC_6;
			end
			
////////CC7//////////////////////////////////////	
        S_CC_6: begin 	
		      Y_value <= SRAM_read_data;
				
				B_even <= B_even + mult1;//B calculation done
				B_odd <= B_odd + mult2;
		      
				op1 <= V_even_value - V_RGB_minus;
				op2 <= R_V;
				op3 <= V_odd_value - V_RGB_minus;
				op4 <= R_V;	
				if(state_pin == 2'b0) begin 
				   M1_state <= S_CC_7;
					end
				else begin
				   M1_state <= S_CC_7_withbuff;
			   end
			end
			
////////CC8/////////////////////////////////////	
        S_CC_7: begin 	
				R_even <= R_even + mult1;//R calculation done
				R_odd <= R_odd + mult2;
		      
				op1 <= V_even_value - V_RGB_minus;
				op2 <= G_V;
				op3 <= V_odd_value - V_RGB_minus;
				op4 <= G_V;	
				
				U_buff <= SRAM_read_data[7:0]; // store U7 for the next iteration
				//To get the parameters to calculate U'7
				U_minus5 <= U_minus3; //U[(j-5)/2] = U1
				U_minus3 <= U_minus1; // U[(j-3)/2] = U2
				U_minus1 <= U_plus1; // U[(j-1)/2] = U3
				U_plus1 <= U_plus3; // U[(j+1)/2] = U4
				U_plus3 <= U_plus5; // U[(j+3)/2] = U5
				U_plus5 <= SRAM_read_data[15:8]; // U[(j+5)/2] = U6
				
         //   U_plus5 <= SRAM_read_data[15:8]; // U[(j+5)/2] = U6
         //   U_plus3 <= U_plus5; // U[(j+3)/2] = U5
          //  U_plus1 <= U_plus3; // U[(j+1)/2] = U4
          //  U_minus1 <= U_plus1; // U[(j-1)/2] = U3
         //   U_minus3 <= U_minus1; // U[(j-3)/2] = U2
          //  U_minus5 <= U_minus3; //U[(j-5)/2] = U1
				
				M1_state <= S_CC_8;
			end
			
////////CC9/////////////////////////////////////	
        S_CC_8: begin 	
				G_even <= G_even - mult1;//G calculation done
				G_odd <= G_odd - mult2;
		      
				//No multiplication now	
				V_buff <= SRAM_read_data[7:0]; // store V7 for the next iteration
				//To get the parameters to calculate V'7
				V_minus5 <= V_minus3; //V[(j-5)/2] = V1
				V_minus3 <= V_minus1; // V[(j-3)/2] = V2
				V_minus1 <= V_plus1; // V[(j-1)/2] = V3
				V_plus1 <= V_plus3; // V[(j+1)/2] = V4
				V_plus3 <= V_plus5; // V[(j+3)/2] = V5
				V_plus5 <= SRAM_read_data[15:8]; // V[(j+5)/2] = V6
				
				
       //     V_plus5 <= SRAM_read_data[15:8]; // V[(j+5)/2] = V6
       //     V_plus3 <= V_plus5; // V[(j+3)/2] = V5
       //     V_plus1 <= V_plus3; // V[(j+1)/2] = V4
       //     V_minus1 <= V_plus1; // V[(j-1)/2] = V3
       //     V_minus3 <= V_minus1; // V[(j-3)/2] = V2
       //     V_minus5 <= V_minus3; //V[(j-5)/2] = V1
				
				state_pin <= 2'b1;
				M1_state <= S_CC_0;
			end
			
////////CC8 with buff/////////////////////////////////////	
        S_CC_7_withbuff: begin 	
				R_even <= R_even + mult1;//R calculation done
				R_odd <= R_odd + mult2;
		      
				op1 <= V_even_value - V_RGB_minus;
				op2 <= G_V;
				op3 <= V_odd_value - V_RGB_minus;
				op4 <= G_V;	
				
				//U_buff <= SRAM_read_data[7:0]; // store U7 for the next iteration
				//To get the parameters to calculate U'9
				U_minus5 <= U_minus3; //U[(j-5)/2] = U2
				U_minus3 <= U_minus1; // U[(j-3)/2] = U3
				U_minus1 <= U_plus1; // U[(j-1)/2] = U4
				U_plus1 <= U_plus3; // U[(j+1)/2] = U5
				U_plus3 <= U_plus5; // U[(j+3)/2] = U6
				U_plus5 <= U_buff; // U[(j+5)/2] = U7
					
     //       U_plus5 <= U_buff; // U[(j+5)/2] = U7
      //      U_plus3 <= U_plus5; // U[(j+3)/2] = U6
      //      U_plus1 <= U_plus3; // U[(j+1)/2] = U5
     //       U_minus1 <= U_plus1; // U[(j-1)/2] = U4
      //      U_minus3 <= U_minus1; // U[(j-3)/2] = U3
     //       U_minus5 <= U_minus3; //U[(j-5)/2] = U2
				  U_buff <= 8'b0;
				
				M1_state <= S_CC_8_withbuff;
			end
			
////////CC9 with buff/////////////////////////////////////	
        S_CC_8_withbuff: begin 	
				G_even <= G_even - mult1;//G calculation done
				G_odd <= G_odd - mult2;
		      
				//No multiplication now	
				
				//V_buff <= SRAM_read_data[7:0]; // store V7 for the next iteration
				//To get the parameters to calculate V'9
				V_minus5 <= V_minus3; //V[(j-5)/2] = V2
				V_minus3 <= V_minus1; // V[(j-3)/2] = V3
				V_minus1 <= V_plus1; // V[(j-1)/2] = V4
				V_plus1 <= V_plus3; // V[(j+1)/2] = V5
				V_plus3 <= V_plus5; // V[(j+3)/2] = V6
				V_plus5 <= V_buff; // V[(j+5)/2] = V7
								
        //    V_plus5 <= V_buff; // V[(j+5)/2] = V7
        //    V_plus3 <= V_plus5; // V[(j+3)/2] = V6
        //    V_plus1 <= V_plus3; // V[(j+1)/2] = V5
        //   V_minus1 <= V_plus1; // V[(j-1)/2] = V4
         //   V_minus3 <= V_minus1; // V[(j-3)/2] = V3
         //   V_minus5 <= V_minus3; //V[(j-5)/2] = V2
			//	V_buff <= 8'b0;
				state_pin <= 2'b0;
				
				if(count_pos == 8'd156) begin //counter_Y = 157, Y312Y313
				   M1_state <= S_LO_0;
				end
				else begin
				   M1_state <= S_CC_0;
				end
			end
////////////////////////////////////////////////////////////			
////////////////////Lead out////////////////////////////////
////////////////////////////////////////////////////////////	
//Start: Read 314/315; Compute 312/313; Write: 310/311
        S_LO_0: begin
		      SRAM_address <= RGB_start + counter_RGB; //R310G310
		      counter_RGB <= counter_RGB + 18'd1;
	         SRAM_we_n <= 1'b0;//start writing	
				
				SRAM_write_data[15:8] <= (R_even[31] == 1'b1)?8'b0:((|R_even[30:24])?8'd255:R_even[23:16]); //write R310
           SRAM_write_data[7:0] <= (G_even[31] == 1'b1)?8'b0:((|G_even[30:24])?8'd255:G_even[23:16]); //write G310
				

				op1 <= U_plus5 + U_minus5;//312/313
				op2 <= U_5;
				op3 <= V_plus5 + V_minus5;
				op4 <= V_5;
				
				M1_state <= S_LO_1;
			end
				
///////////////////////////////////////////////////
		  S_LO_1: begin
				SRAM_address <= RGB_start + counter_RGB; //B310R311
				counter_RGB <= counter_RGB + 18'd1;
	         
            SRAM_write_data[15:8] <= (B_even[31] == 1'b1)?8'b0:((|B_even[30:24])?8'd255:B_even[23:16]); //write B310
            SRAM_write_data[7:0] <= (R_odd[31] == 1'b1)?8'b0:((|R_odd[30:24])?8'd255:R_odd[23:16]); //write R311
				
				U_even_value <= U_minus1;//U156 in first iteration
				
				U_odd_value <= mult1;//calaculate U'313
				V_odd_value <= mult2;//calaculate V'313
		      
			   op1 <= U_plus3 + U_minus3;
				op2 <= U_3;
				op3 <= V_plus3 + V_minus3;
				op4 <= V_3;	
				
				M1_state <= S_LO_2;
				end
				
///////////////////////////////////////////////////
        S_LO_2: begin
		      SRAM_address <= RGB_start + counter_RGB;
				counter_RGB <= counter_RGB + 18'd1;
	        // SRAM_we_n <= 1'b0;	
		
            SRAM_write_data[15:8] <= (G_odd[31] == 1'b1)?8'b0:((|G_odd[30:24])?8'd255:G_odd[23:16]); //write G311
            SRAM_write_data[7:0] <= (B_odd[31] == 1'b1)?8'b0:((|B_odd[30:24])?8'd255:B_odd[23:16]); //write B311
				
				V_even_value <= V_minus1;//V156 in first iteration
				
				U_odd_value <= U_odd_value - mult1;//calaculate U'313
				V_odd_value <= V_odd_value - mult2;//calaculate V'313
				
				op1 <= U_plus1 + U_minus1;
				op2 <= U_1;
				op3 <= V_plus1 + V_minus1;
				op4 <= V_1;	
				
				M1_state <= S_LO_3;
			end
				
///////////////////////////////////////////////////
        S_LO_3: begin
		     SRAM_we_n <= 1'b1;//stop writing
		    SRAM_address <= Y_start + counter_Y;//Y314Y315
				counter_Y <= counter_Y + 18'd1; //158
		  
		      U_odd_value <= (U_odd_value + mult1 + UV_plus) >>> 8;//calaculate U'313 done
				V_odd_value <= (V_odd_value + mult2 + UV_plus) >>> 8;//calaculate V'313 done
				
				
				op1 <= Y_value[15:8] - Y_RGB_minus; //Y312Y313 here
				op2 <= RGB_Y; //E(Y)
				op3 <= Y_value[7:0] - Y_RGB_minus;
				op4 <= RGB_Y; //O(Y)
				
            M1_state <= S_LO_4;
        end
		  
//////////////////////////////////////////////////
       S_LO_4: begin
				//No U/V here
				
		      R_even <= mult1;//calculate R312
				R_odd <= mult2;//R313
				G_even <= mult1;//calculate G312
				G_odd <= mult2; //G313
				B_even <= mult1;//calculate B312
				B_odd <= mult2; //B313
				
				op1 <= U_even_value - U_RGB_minus;
				op2 <= G_U;
				op3 <= U_odd_value - U_RGB_minus;
				op4 <= G_U;	

            M1_state <= S_LO_5;
			end
			
//////////////////////////////////////////////////
       S_LO_5: begin
					
				G_even <= G_even - mult1;//calculate G
				G_odd <= G_odd - mult2;
				
				op1 <= U_even_value - U_RGB_minus;
				op2 <= B_U;
				op3 <= U_odd_value - U_RGB_minus;
				op4 <= B_U;	
				
				M1_state <= S_LO_6;
			end
			
//////////////////////////////////////////////////
       S_LO_6: begin
		      Y_value <= SRAM_read_data; //Y314Y315
				
				B_even <= B_even + mult1;//B calculation done //B312
				B_odd <= B_odd + mult2; //B313
		      
				op1 <= V_even_value - V_RGB_minus;
				op2 <= R_V;
				op3 <= V_odd_value - V_RGB_minus;
				op4 <= R_V;	
				
				M1_state <= S_LO_7;
			end
			
//////////////////////////////////////////////////
       S_LO_7: begin
				R_even <= R_even + mult1;//R calculation done //R312
				R_odd <= R_odd + mult2; //R313
		      
				op1 <= V_even_value - V_RGB_minus;
				op2 <= G_V;
				op3 <= V_odd_value - V_RGB_minus;
				op4 <= G_V;	
				
				//To get the parameters to calculate U'315
            // keep U[(j+5)/2] = U159
				U_minus5 <= U_minus3; //U[(j-5)/2] = U155
				U_minus3 <= U_minus1; // U[(j-3)/2] = U156
				U_minus1 <= U_plus1; // U[(j-1)/2] = U157
				U_plus1 <= U_plus3; // U[(j+1)/2] = U158
				U_plus3 <= U_plus5; // U[(j+3)/2] = U159
				
				M1_state <= S_LO_8;
			end
				
//////////////////////////////////////////////////
       S_LO_8: begin
		     G_even <= G_even - mult1;//G calculation done/////////////////////////////////////////////////////
			  G_odd <= G_odd - mult2;
		      
				//No multiplication now	
				
			  //To get the parameters to calculate V'315
           // V[(j+5)/2] = V159
			  V_minus5 <= V_minus3; //V[(j-5)/2] = V155
			  V_minus3 <= V_minus1; // V[(j-3)/2] = V156
			  V_minus1 <= V_plus1; // V[(j-1)/2] = V157
			  V_plus1 <= V_plus3; // V[(j+1)/2] = V158
			  V_plus3 <= V_plus5; // V[(j+3)/2] = V159
			
			  M1_state <= S_LO_9;
			 end
			
//////////////////////////////////////////////////
//Read: 316/317 Compute: 314/315 Write:312/313
       S_LO_9: begin
		    SRAM_address <= RGB_start + counter_RGB;
		    counter_RGB <= counter_RGB + 18'd1;
	       SRAM_we_n <= 1'b0;//start writing	
				
		    SRAM_write_data[15:8] <= (R_even[31] == 1'b1)?8'b0:((|R_even[30:24])?8'd255:R_even[23:16]); //write R312
           SRAM_write_data[7:0] <= (G_even[31] == 1'b1)?8'b0:((|G_even[30:24])?8'd255:G_even[23:16]); //write G312
				

		    op1 <= U_plus5 + U_minus5;
			 op2 <= U_5;
			 op3 <= V_plus5 + V_minus5;
			 op4 <= V_5;
				
			 M1_state <= S_LO_10;
		end
			 
//////////////////////////////////////////////////
       S_LO_10: begin
		     SRAM_address <= RGB_start + counter_RGB;
		     counter_RGB <= counter_RGB + 18'd1;
	         
           SRAM_write_data[15:8] <= (B_even[31] == 1'b1)?8'b0:((|B_even[30:24])?8'd255:B_even[23:16]); //write B312
           SRAM_write_data[7:0] <= (R_odd[31] == 1'b1)?8'b0:((|R_odd[30:24])?8'd255:R_odd[23:16]); //write R313
				
			  U_even_value <= U_minus1;//U314 in first iteration
				
			  U_odd_value <= mult1;//calaculate U'315
		     V_odd_value <= mult2;//calaculate V'315
		      
			  op1 <= U_plus3 + U_minus3;
			  op2 <= U_3;
			  op3 <= V_plus3 + V_minus3;
			  op4 <= V_3;	
				
			  M1_state <= S_LO_11;
	   end
		
/////////////////////////////////////////////////
       S_LO_11: begin
		     SRAM_address <= RGB_start + counter_RGB;
		  	  counter_RGB <= counter_RGB + 18'd1;
	        // SRAM_we_n <= 1'b0;	
		
           SRAM_write_data[15:8] <= (G_odd[31] == 1'b1)?8'b0:((|G_odd[30:24])?8'd255:G_odd[23:16]); //write G313
           SRAM_write_data[7:0] <= (B_odd[31] == 1'b1)?8'b0:((|B_odd[30:24])?8'd255:B_odd[23:16]); //write B313
		     
				
			  V_even_value <= V_minus1;//V314 in first iteration
				
			  U_odd_value <= U_odd_value - mult1;//calaculate U'315
			  V_odd_value <= V_odd_value - mult2;//calaculate V'315
				
			  op1 <= U_plus1 + U_minus1;
			  op2 <= U_1;
			  op3 <= V_plus1 + V_minus1;
			  op4 <= V_1;	
				
			  M1_state <= S_LO_12;
			end
			
//////////////////////////////////////////////////
       S_LO_12: begin
		     SRAM_we_n <= 1'b1;//stop writing
		     SRAM_address <= Y_start + counter_Y;//Y316317
			  counter_Y <= counter_Y + 18'd1;
		  
		     U_odd_value <= (U_odd_value + mult1 + UV_plus) >>> 8;//calaculate U'315 done
		     V_odd_value <= (V_odd_value + mult2 + UV_plus) >>> 8;//calaculate V'315 done
				
				
			  op1 <= Y_value[15:8] - Y_RGB_minus; //Y314Y315 here
			  op2 <= RGB_Y; //E(Y)
			  op3 <= Y_value[7:0] - Y_RGB_minus;
			  op4 <= RGB_Y; //O(Y)
				
			  M1_state <= S_LO_13;
			end
			
//////////////////////////////////////////////////
       S_LO_13: begin
		     //No U/V here
				
		     R_even <= mult1;//calculate R314
		     R_odd <= mult2;//R315
			  G_even <= mult1;//calculate G314
			  G_odd <= mult2; //G315
			  B_even <= mult1;//calculate B314
			  B_odd <= mult2; //B315
				
			  op1 <= U_even_value - U_RGB_minus;
			  op2 <= G_U;
			  op3 <= U_odd_value - U_RGB_minus;
			  op4 <= G_U;	

				
			  M1_state <= S_LO_14;
			end
			
//////////////////////////////////////////////////
       S_LO_14: begin
		    G_even <= G_even - mult1;//calculate G
		    G_odd <= G_odd - mult2;
				
			 op1 <= U_even_value - U_RGB_minus;
			 op2 <= B_U;
			 op3 <= U_odd_value - U_RGB_minus;
			 op4 <= B_U;	
				
				
			  M1_state <= S_LO_15;
			end
			
//////////////////////////////////////////////////
       S_LO_15: begin
           Y_value <= SRAM_read_data; //Y316Y317
				
			  B_even <= B_even + mult1;//B calculation done //B314
			  B_odd <= B_odd + mult2; //B315
		      
			  op1 <= V_even_value - V_RGB_minus;
			  op2 <= R_V;
			  op3 <= V_odd_value - V_RGB_minus;
			  op4 <= R_V;	
				
			  M1_state <= S_LO_16;
			end
			
/////////////////////////////////////////////////
       S_LO_16: begin
		     R_even <= R_even + mult1;//R calculation done //R314
			  R_odd <= R_odd + mult2; //R313
		      
			  op1 <= V_even_value - V_RGB_minus;
			  op2 <= G_V;
			  op3 <= V_odd_value - V_RGB_minus;
			  op4 <= G_V;	
				
			  //To get the parameters to calculate U'317
           // keep U[(j+5)/2] = U159
           // keep U[(j+3)/2] = U159
			  U_minus5 <= U_minus3; //U[(j-5)/2] = U156
			  U_minus3 <= U_minus1; // U[(j-3)/2] = U157
			   U_minus1 <= U_plus1; // U[(j-1)/2] = U158
			  U_plus1 <= U_plus3; // U[(j+1)/2] = U159
			  
			  M1_state <= S_LO_17;
			end
			  
//////////////////////////////////////////////////
       S_LO_17: begin
		     G_even <= G_even - mult1;//G calculation done//G314
			  G_odd <= G_odd - mult2;
		      
			  //No multiplication now	
				
			  //To get the parameters to calculate V'317
           // V[(j+5)/2] = V159
           // V[(j+3)/2] = V159
			  V_minus5 <= V_minus3; //V[(j-5)/2] = V156
			  V_minus3 <= V_minus1; // V[(j-3)/2] = V157
			  V_minus1 <= V_plus1; // V[(j-1)/2] = V158
			  V_plus1 <= V_plus3; // V[(j+1)/2] = V159
			  
			  M1_state <= S_LO_18;
			end

////////////////////////////////////////////////////
//Read: 318/319 Compute: 316/317 Write:314/315
       S_LO_18: begin
		    SRAM_address <= RGB_start + counter_RGB;
		    counter_RGB <= counter_RGB + 18'd1;
	       SRAM_we_n <= 1'b0;//start writing	
				
		    SRAM_write_data[15:8] <= (R_even[31] == 1'b1)?8'b0:((|R_even[30:24])?8'd255:R_even[23:16]); //write R314
           SRAM_write_data[7:0] <= (G_even[31] == 1'b1)?8'b0:((|G_even[30:24])?8'd255:G_even[23:16]); //write G314
				

		    op1 <= U_plus5 + U_minus5;
			 op2 <= U_5;
			 op3 <= V_plus5 + V_minus5;
			 op4 <= V_5;
				
			  
			  M1_state <= S_LO_19;
			end
			
////////////////////////////////////////////////////
       S_LO_19: begin
		     SRAM_address <= RGB_start + counter_RGB;
		     counter_RGB <= counter_RGB + 18'd1;
	         
           SRAM_write_data[15:8] <= (B_even[31] == 1'b1)?8'b0:((|B_even[30:24])?8'd255:B_even[23:16]); //write B314
           SRAM_write_data[7:0] <= (R_odd[31] == 1'b1)?8'b0:((|R_odd[30:24])?8'd255:R_odd[23:16]); //write R315
				
			  U_even_value <= U_minus1;//U316
				
			  U_odd_value <= mult1;//calaculate U'317
		     V_odd_value <= mult2;//calaculate V'317
		      
			  op1 <= U_plus3 + U_minus3;
			  op2 <= U_3;
			  op3 <= V_plus3 + V_minus3;
			  op4 <= V_3;			
			  
			  M1_state <= S_LO_20;
			end
			
////////////////////////////////////////////////////
       S_LO_20: begin
		     SRAM_address <= RGB_start + counter_RGB;
		  	  counter_RGB <= counter_RGB + 18'd1;
	        // SRAM_we_n <= 1'b0;	
		
           SRAM_write_data[15:8] <= (G_odd[31] == 1'b1)?8'b0:((|G_odd[30:24])?8'd255:G_odd[23:16]); //write G315
           SRAM_write_data[7:0] <= (B_odd[31] == 1'b1)?8'b0:((|B_odd[30:24])?8'd255:B_odd[23:16]); //write B315
		     
				
			  V_even_value <= V_minus1;//V316
			  
			  U_odd_value <= U_odd_value - mult1;//calaculate U'317
			  V_odd_value <= V_odd_value - mult2;//calaculate V'317
				
			  op1 <= U_plus1 + U_minus1;
			  op2 <= U_1;
			  op3 <= V_plus1 + V_minus1;
			  op4 <= V_1;	
			  
			  M1_state <= S_LO_21;
			end
			
////////////////////////////////////////////////////
       S_LO_21: begin
		     SRAM_we_n <= 1'b1;//stop writing
	        SRAM_address <= Y_start + counter_Y;//Y318319
			  counter_Y <= counter_Y + 18'd1;
		  
		     U_odd_value <= (U_odd_value + mult1 + UV_plus) >>> 8;//calaculate U'317 done
		     V_odd_value <= (V_odd_value + mult2 + UV_plus) >>> 8;//calaculate V'317 done
				
				
			  op1 <= Y_value[15:8] - Y_RGB_minus; //Y316Y317 here
			  op2 <= RGB_Y; //E(Y)
			  op3 <= Y_value[7:0] - Y_RGB_minus;
			  op4 <= RGB_Y; //O(Y)
				
			  
			  M1_state <= S_LO_22;
			end
			
////////////////////////////////////////////////////
       S_LO_22: begin
	        //No U/V here
				
		     R_even <= mult1;//calculate R316
		     R_odd <= mult2;//R317
			  G_even <= mult1;//calculate G316
			  G_odd <= mult2; //G317
			  B_even <= mult1;//calculate B316
			  B_odd <= mult2; //B317
				
			  op1 <= U_even_value - U_RGB_minus;
			  op2 <= G_U;
			  op3 <= U_odd_value - U_RGB_minus;
			  op4 <= G_U;	
			  
			  M1_state <= S_LO_23;
			end

////////////////////////////////////////////////////
       S_LO_23: begin
	        G_even <= G_even - mult1;//calculate G
		     G_odd <= G_odd - mult2;
				
			  op1 <= U_even_value - U_RGB_minus;
			  op2 <= B_U;
			  op3 <= U_odd_value - U_RGB_minus;
			  op4 <= B_U;	
				
			  
			  M1_state <= S_LO_24;
			end
			
//////////////////////////////////////////////////
       S_LO_24: begin
           Y_value <= SRAM_read_data; //Y318Y319
				
			  B_even <= B_even + mult1;//B calculation done //B316
			  B_odd <= B_odd + mult2; //B317
		      
			  op1 <= V_even_value - V_RGB_minus;
			  op2 <= R_V;
			  op3 <= V_odd_value - V_RGB_minus;
			  op4 <= R_V;	
				
			  M1_state <= S_LO_25;
			end
			
/////////////////////////////////////////////////
       S_LO_25: begin
		     R_even <= R_even + mult1;//R calculation done //R316
			  R_odd <= R_odd + mult2; //R317
		      
			  op1 <= V_even_value - V_RGB_minus;
			  op2 <= G_V;
			  op3 <= V_odd_value - V_RGB_minus;
			  op4 <= G_V;	
				
			  //To get the parameters to calculate U'319
           // keep U[(j+5)/2] = U159
           // keep U[(j+3)/2] = U159
           // U[(j+1)/2] = U159
			  U_minus5 <= U_minus3; //U[(j-5)/2] = U157
			  U_minus3 <= U_minus1; // U[(j-3)/2] = U158
			  U_minus1 <= U_plus1; // U[(j-1)/2] = U159
			  
			  M1_state <= S_LO_26;
			end

//////////////////////////////////////////////////
       S_LO_26: begin
		     G_even <= G_even - mult1;//G calculation done//G314
			  G_odd <= G_odd - mult2;
		      
			  //No multiplication now	
				
			  //To get the parameters to calculate V'319
           // V[(j+5)/2] = V159
           // V[(j+3)/2] = V159
           // V[(j+1)/2] = V159
			  V_minus5 <= V_minus3; //V[(j-5)/2] = V157
			  V_minus3 <= V_minus1; // V[(j-3)/2] = V158
			   V_minus1 <= V_plus1; // V[(j-1)/2] = V159
			  
			  M1_state <= S_LO_27;
			end			

/////////////////////////////////////////////////			
//Compute: 316/317 Write:314/315
       S_LO_27: begin
		    SRAM_address <= RGB_start + counter_RGB;
		    counter_RGB <= counter_RGB + 18'd1;
	       SRAM_we_n <= 1'b0;//start writing	
				
		   SRAM_write_data[15:8] <= (R_even[31] == 1'b1)?8'b0:((|R_even[30:24])?8'd255:R_even[23:16]); //write R316
           SRAM_write_data[7:0] <= (G_even[31] == 1'b1)?8'b0:((|G_even[30:24])?8'd255:G_even[23:16]); //write G316
				

		    op1 <= U_plus5 + U_minus5;
			 op2 <= U_5;
			 op3 <= V_plus5 + V_minus5;
			 op4 <= V_5;
				
			  
			  M1_state <= S_LO_28;
			end

////////////////////////////////////////////////////
       S_LO_28: begin
		     SRAM_address <= RGB_start + counter_RGB;
		     counter_RGB <= counter_RGB + 18'd1;
	         
           SRAM_write_data[15:8] <= (B_even[31] == 1'b1)?8'b0:((|B_even[30:24])?8'd255:B_even[23:16]); //write B316
           SRAM_write_data[7:0] <= (R_odd[31] == 1'b1)?8'b0:((|R_odd[30:24])?8'd255:R_odd[23:16]); //write R317
				
			  U_even_value <= U_minus1;//U318
				
			  U_odd_value <= mult1;//calaculate U'319
		     V_odd_value <= mult2;//calaculate V'319
		      
			  op1 <= U_plus3 + U_minus3;
			  op2 <= U_3;
			  op3 <= V_plus3 + V_minus3;
			  op4 <= V_3;			
			  
			  M1_state <= S_LO_29;
			end			

////////////////////////////////////////////////////
       S_LO_29: begin
		     SRAM_address <= RGB_start + counter_RGB;
		  	  counter_RGB <= counter_RGB + 18'd1;
	        // SRAM_we_n <= 1'b0;	
		
           SRAM_write_data[15:8] <= (G_odd[31] == 1'b1)?8'b0:((|G_odd[30:24])?8'd255:G_odd[23:16]); //write G317
           SRAM_write_data[7:0] <= (B_odd[31] == 1'b1)?8'b0:((|B_odd[30:24])?8'd255:B_odd[23:16]); //write B317
		     
				
			  V_even_value <= V_minus1;//V318
			  
			  U_odd_value <= U_odd_value - mult1;//calaculate U'319
			  V_odd_value <= V_odd_value - mult2;//calaculate V'319
				
			  op1 <= U_plus1 + U_minus1;
			  op2 <= U_1;
			  op3 <= V_plus1 + V_minus1;
			  op4 <= V_1;	
			  
			  M1_state <= S_LO_30;
			end

////////////////////////////////////////////////////
       S_LO_30: begin
		     //No Y here
			  
			  SRAM_we_n <= 1'b1;//stop writing
		  
		     U_odd_value <= (U_odd_value + mult1 + UV_plus) >>> 8;//calaculate U'319 done
		     V_odd_value <= (V_odd_value + mult2 + UV_plus) >>> 8;//calaculate V'319 done
				
				
			  op1 <= Y_value[15:8] - Y_RGB_minus; //Y318Y319 here
			  op2 <= RGB_Y; //E(Y)
			  op3 <= Y_value[7:0] - Y_RGB_minus;
			  op4 <= RGB_Y; //O(Y)
				
			  
			  M1_state <= S_LO_31;
			end

////////////////////////////////////////////////////
       S_LO_31: begin
	        //No U/V here
				
		     R_even <= mult1;//calculate R318
		     R_odd <= mult2;//R319
			  G_even <= mult1;//calculate G318
			  G_odd <= mult2; //G319
			  B_even <= mult1;//calculate B318
			  B_odd <= mult2; //B319
				
			  op1 <= U_even_value - U_RGB_minus;
			  op2 <= G_U;
			  op3 <= U_odd_value - U_RGB_minus;
			  op4 <= G_U;	
			  
			  M1_state <= S_LO_32;
			end			

////////////////////////////////////////////////////
       S_LO_32: begin
	        G_even <= G_even - mult1;//calculate G
		     G_odd <= G_odd - mult2;
				
			  op1 <= U_even_value - U_RGB_minus;
			  op2 <= B_U;
			  op3 <= U_odd_value - U_RGB_minus;
			  op4 <= B_U;	
				
			  
			  M1_state <= S_LO_33;
			end

//////////////////////////////////////////////////
       S_LO_33: begin
				
			  B_even <= B_even + mult1;//B calculation done //B318
			  B_odd <= B_odd + mult2; //B319
		      
			  op1 <= V_even_value - V_RGB_minus;
			  op2 <= R_V;
			  op3 <= V_odd_value - V_RGB_minus;
			  op4 <= R_V;	
				
			  M1_state <= S_LO_34;
			end

/////////////////////////////////////////////////
       S_LO_34: begin
		     R_even <= R_even + mult1;//R calculation done //R318
			  R_odd <= R_odd + mult2; //R319
		      
			  op1 <= V_even_value - V_RGB_minus;
			  op2 <= G_V;
			  op3 <= V_odd_value - V_RGB_minus;
			  op4 <= G_V;	
			  
			  M1_state <= S_LO_35;
			end			

//////////////////////////////////////////////////
       S_LO_35: begin
		     G_even <= G_even - mult1;//G calculation done//G314
			  G_odd <= G_odd - mult2;
		      
			  
			  M1_state <= S_LO_36;
			end	

//////////////////////////////////////////////////
//Write: 318/319
       S_LO_36: begin
		     SRAM_address <= RGB_start + counter_RGB;
		     counter_RGB <= counter_RGB + 18'd1;
	        SRAM_we_n <= 1'b0;//start writing	
				
		     SRAM_write_data[15:8] <= (R_even[31] == 1'b1)?8'b0:((|R_even[30:24])?8'd255:R_even[23:16]); //write R318
           SRAM_write_data[7:0] <= (G_even[31] == 1'b1)?8'b0:((|G_even[30:24])?8'd255:G_even[23:16]); //write G318
			
			  M1_state <= S_LO_37;
			end


////////////////////////////////////////////////////
       S_LO_37: begin
		     SRAM_address <= RGB_start + counter_RGB;
		     counter_RGB <= counter_RGB + 18'd1;
	         
           SRAM_write_data[15:8] <= (B_even[31] == 1'b1)?8'b0:((|B_even[30:24])?8'd255:B_even[23:16]); //write B318
           SRAM_write_data[7:0] <= (R_odd[31] == 1'b1)?8'b0:((|R_odd[30:24])?8'd255:R_odd[23:16]); //write R319
			  
			  M1_state <= S_LO_38;
			end			

////////////////////////////////////////////////////
       S_LO_38: begin
		     SRAM_address <= RGB_start + counter_RGB;
		  	  counter_RGB <= counter_RGB + 18'd1;
	        	
		
           SRAM_write_data[15:8] <= (G_odd[31] == 1'b1)?8'b0:((|G_odd[30:24])?8'd255:G_odd[23:16]); //write G319
           SRAM_write_data[7:0] <= (B_odd[31] == 1'b1)?8'b0:((|B_odd[30:24])?8'd255:B_odd[23:16]); //write B319
		     
			  if(count_row == 8'd240) begin
			     M1_state <= S_Done;
				 end
			  else begin
			     state_pin <= 2'b0;
				  count_pos <= 8'd2;
				  M1_state <= S_LI_0;
			end
		end	

////////////////////////////////////////////////////
//////////////Done!!!///////////////////////////////
       S_Done: begin
		 
	       M1_done <= 1'b1;
			 
		   end
			
			default: M1_state <= S_M1_IDLE;

         endcase
			
	 end
end
assign mult1 = op1 * op2;//op: 32 bits//mult: 64 bits//RGB_value: 64 bits//write: 8 bits //YUV: 8 bits
assign mult2 = op3 * op4;

	 		  		  
		  
endmodule



