`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:22:37 01/17/2019 
// Design Name: 
// Module Name:    fpcvt 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module FPCVT(D, S, E, F);
/*
	D: input data in two's complement representation
	S: sign bit of floating point representaion
	E: exponent of floating point represenation
	F: significand of floating point represenation
*/
input      [12:0] D;
output reg        S;
output reg [2:0]  E;
output reg [4:0]  F;

wire        [11:0] unsignedD;

wire       [2:0]  exponent;
wire       [4:0]  significand;
wire              roundingBit;
	
    
assign exponent =
	 (unsignedD[11]) ? 7 :
	 (unsignedD[10]) ? 6 :
	 (unsignedD[9])  ? 5 :
	 (unsignedD[8])  ? 4 :
	 (unsignedD[7])  ? 3 :
	 (unsignedD[6])  ? 2 :
	 (unsignedD[5])  ? 1 : 0;
	 
assign significand =
    (unsignedD[11]) ? unsignedD[11:7] :
	 (unsignedD[10]) ? unsignedD[10:6] :
	 (unsignedD[9])  ? unsignedD[9:5]  :
	 (unsignedD[8])  ? unsignedD[8:4]  :
	 (unsignedD[7])  ? unsignedD[7:3]  :
	 (unsignedD[6])  ? unsignedD[6:2]  :
 	 (unsignedD[5])  ? unsignedD[5:1]  :
	 (unsignedD[4])  ? unsignedD[4:0]  :
	 (unsignedD[3])  ? unsignedD[3:0]  :
	 (unsignedD[2])  ? unsignedD[2:0]  :
	 (unsignedD[1])  ? unsignedD[1:0]  :
	 (unsignedD[0])  ? unsignedD[0]    : 0;
	 
assign roundingBit = 
    (unsignedD[11]) ? unsignedD[6] :
	 (unsignedD[10]) ? unsignedD[5] :
	 (unsignedD[9])  ? unsignedD[4] :
	 (unsignedD[8])  ? unsignedD[3] :
	 (unsignedD[7])  ? unsignedD[2] :
	 (unsignedD[6])  ? unsignedD[1] :
 	 (unsignedD[5])  ? unsignedD[0] : 0;
     
assign unsignedD = S ? ~D[11:0] + 'b1 : D[11:0];
     
     /*
reg [3:0] i;
reg [3:0] counter;
reg flag;

*/

always @* begin
	 
	 // sign bit is the most significant bit of input
	 S = D[12];
	 
	 // assign unsigedD and negate it if necessary
	 
  
    // 12.173ns
    
	 if (roundingBit) begin
	     if (significand == 'b11111) begin
		      if (exponent == 'b111) begin
				    E = exponent;
				    F = significand;
		      end
				else begin
				    F = 'b10000;
					 E = exponent + 'b1;
				end
		  end
		  else begin
		      E = exponent;
		      F = significand + 'b1;
		  end
	 end
	 else begin
	     if (significand == 'b00000 && exponent == 'b000 && S == 1) begin
		      E = 'b111;
		      F = 'b11111;
		  end
		  else begin
		      E = exponent;
		      F = significand;
		  end
	     
	 end
     

	 
	 
	  
    // search index of first non-zero leading bit
	 // 15.068ns
     /*
	 if (unsignedD[11]) begin
		  F = unsignedD[11:7];
		  if (F != 'b11111)
		      F = F + unsignedD[6];
		  E = 7;
	 end
    else if (unsignedD[10]) begin
		  F = unsignedD[10:6];
		  if (F != 'b11111) begin
		      F = F + unsignedD[5];
              E = 6;
          end
          else begin
              F = 'b10000;
              E = 7;
		  end
	 end
	 else if (unsignedD[9]) begin
		  F = unsignedD[9:5];
		  if (F != 'b11111) begin
		      F = F + unsignedD[4];
                E = 5;
           end
           else begin
                F = 'b10000;
                E = 6;
            end
	 end
	 else if (unsignedD[8]) begin
		  F = unsignedD[8:4];
		  if (F != 'b11111) begin
		      F = F + unsignedD[3];
              E = 4;
           end
          else begin
            F = 'b10000;
            E = 5;
           end
	 end
	 else if (unsignedD[7]) begin
		  F = unsignedD[7:3];
		  if (F != 'b11111) begin
		      F = F + unsignedD[2];
              E = 3;
           end
           else begin
            F = 'b10000;
            E = 4;
           end
	 end
	 else if (unsignedD[6]) begin
		  F = unsignedD[6:2];
		  if (F != 'b11111) begin
		      F = F + unsignedD[1];
              E = 2;
          end
          else begin
           F = 'b10000;
           E = 3;
          end
	 end
	 else if (unsignedD[5]) begin
		  F = unsignedD[5:1];
		  if (F != 'b11111) begin
            F = F + unsignedD[0];
            E = 1;
          end
          else begin
            F = 'b10000;
            E = 2;
          end
	 end
	 else if (unsignedD[4]) begin
		  F = unsignedD[4:0];
		  E = 0;
	 end
	 else if (unsignedD[3]) begin
		  F = unsignedD[3:0];
		  E = 0;
	 end
	 else if (unsignedD[2]) begin
		  F = unsignedD[2:0];
		  E = 0;
	 end
	 else if (unsignedD[1]) begin
		  F = unsignedD[1:0];
		  E = 0;
	 end
	 else if (unsignedD[0]) begin
		  F = unsignedD[0];
		  E = 0;
	 end
	 else begin
	     // input is 0 or -4096
		  if (S == 0) begin // input is 0
		      F = 0;
		      E = 0;
		  end
		  else begin // input is -4096
		      F = 'b11111;
				E = 'b111;
		  end
	 end
     */
     
     // 12.720ns
     /*
     counter = 0;
     flag = 0;
     for(i=0; i < 7; i=i+1)
     
        if(unsignedD[11] == 1)
            flag = 1;
            
        else
        begin
            if (flag == 0) begin
                unsignedD = unsignedD << 1;
                counter = counter +1;
            end
        end
        
      
            
      F = unsignedD[11:7] + unsignedD[6];
      E = (7 - counter < 0) ? 0 : 7 - counter;
        */
        
      
	 
end
endmodule
