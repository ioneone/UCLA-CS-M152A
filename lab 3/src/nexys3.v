module nexys3 (/*AUTOARG*/
   // Outputs
   seg, an,
   // Inputs
   sw, btnS, btnR, clk
   );
   
   input  [1:0]  sw;               // sw[0]: adjust, sw[1]: select
   input         btnS;             // pause button
   input         btnR;             // reset button
   input         clk;              // 100MHz
	
	output [7:0]  seg;              // 7 segment display
   output [3:0]  an;               // Anode
   
   wire          rst;
   wire          arst_i;
	wire   [17:0] clk_dv_inc;
	
	wire          is_adjust;
	wire          is_select;
	
	wire          is_btnS_posedge;
	
	wire          is_max_time;      // 1 if stopwatch is 59:59
	
	reg           is_pause;
   reg    [7:0]  seg_reg;
   reg    [3:0]  an_reg;
	
   reg    [1:0]  arst_ff;
   reg    [16:0] clk_dv;
	//reg    [6:0]  clk_dv;
   reg           clk_en;
   reg           clk_en_d;
   reg    [2:0]  step_d;
	
	
	reg    [26:0] clk_1Hz_counter;
	reg           clk_1Hz;
	
	reg    [25:0] clk_2Hz_counter;
	reg           clk_2Hz;
	
	reg    [24:0] clk_4Hz_counter;
	reg           clk_4Hz;
	
	reg    [18:0] clk_200Hz_counter;
	reg           clk_200Hz;
	
	reg    [3:0]  digit0;
	reg    [3:0]  digit1;
	reg    [3:0]  digit2;
	reg    [3:0]  digit3;
	
	reg    [3:0]  digit0_display;
	reg    [3:0]  digit1_display;
	reg    [3:0]  digit2_display;
	reg    [3:0]  digit3_display;
	
	reg           show_black;
	
   reg    [1:0]  seg_counter;
	
   // ===========================================================================
   // Asynchronous Reset
   // ===========================================================================

   assign arst_i = btnR;
   assign rst = arst_ff[0];
   
   always @ (posedge clk or posedge arst_i)
		if (arst_i)
			arst_ff <= 2'b11;
      else
			arst_ff <= {1'b0, arst_ff[1]};
		 
   // ===========================================================================
   // timing signal for clock enable
   // ===========================================================================

   assign clk_dv_inc = clk_dv + 1;
   
   always @ (posedge clk)
		if (rst) begin
			clk_dv   <= 0;
         clk_en   <= 1'b0;
         clk_en_d <= 1'b0;
      end
      else begin
         clk_dv   <= clk_dv_inc[16:0];
         clk_en   <= clk_dv_inc[17];
         clk_en_d <= clk_en;
      end
   
   // ===========================================================================
   // Debouncing
   // ===========================================================================

	assign is_btnS_posedge = ~ step_d[0] & step_d[1];
	
   always @ (posedge clk)
      if (rst)
         step_d[2:0]  <= 0;
      else if (clk_en) // Down sampling
         step_d[2:0]  <= {btnS, step_d[2:1]};
			
	// ===========================================================================
	// pause state
	// ===========================================================================
	
   always @ (posedge clk)
      if (rst)
			is_pause <= 1'b0;
      else if (clk_en_d & is_btnS_posedge)
		   is_pause <= ~is_pause;
      else if (is_max_time)
            is_pause <= 1;
           
       
	// ===========================================================================
	// custom clk 1Hz, 2Hz, 3Hz, 200Hz
	// ===========================================================================
	always @ (posedge clk) begin
      if (rst) begin
			clk_1Hz_counter <= 0;
			clk_1Hz <= 0;
			clk_2Hz_counter <= 0;
			clk_2Hz <= 0;
			clk_4Hz_counter <= 0;
			clk_4Hz <= 0;
			clk_200Hz_counter <= 0;
			clk_200Hz <= 0;
      end
      else begin
         // 1Hz
			//if (clk_1Hz_counter == 'd100_000_000) begin
			if (clk_1Hz_counter == 'd100_000) begin
				 clk_1Hz_counter <= 'd0;
				 clk_1Hz <= 1;
			end
			else begin
				 clk_1Hz_counter <= clk_1Hz_counter + 1;
				 clk_1Hz <= 0;
			end
			
			// 2Hz
			//if (clk_2Hz_counter == 'd50_000_000) begin
			if (clk_2Hz_counter == 'd50_000) begin
				 clk_2Hz_counter <= 'd0;
				 clk_2Hz <= 1;
			end
			else begin
				 clk_2Hz_counter <= clk_2Hz_counter + 1;
				 clk_2Hz <= 0;
			end
			
			// 4Hz
			//if (clk_4Hz_counter == 'd25_000_000) begin
			if (clk_4Hz_counter == 'd25_000) begin
				 clk_4Hz_counter <= 'd0;
				 clk_4Hz <= 1;
			end
			else begin
				 clk_4Hz_counter <= clk_4Hz_counter + 1;
				 clk_4Hz <= 0;
			end
			
			// 200Hz
			//if (clk_200Hz_counter == 'd500_000) begin
			if (clk_200Hz_counter == 'd500) begin
				 clk_200Hz_counter <= 'd0;
				 clk_200Hz <= 1;
			end
			else begin
				 clk_200Hz_counter <= clk_200Hz_counter + 1;
				 clk_200Hz <= 0;
			end
			
      end
		
	end // end always
	
	// ===========================================================================
	// increment stopwatch
	// ===========================================================================
	assign is_adjust = sw[0];
	assign is_select = sw[1];
	assign is_max_time = (digit0 == 'd9) & (digit1 == 'd5) & (digit2 == 'd9) & (digit3 =='d5);
	
	always @ (posedge clk) begin
		if (rst) begin
         digit0 <= 0;
         digit1 <= 0;
         digit2 <= 0;
         digit3 <= 0;
      end
      else if (~is_pause) begin
			if (is_adjust) begin 
            if (clk_2Hz) begin
               if (is_select) begin // selecting seconds
                  if (digit0 == 'd9) begin
                     digit0 <= 1;
                     if (digit1 == 'd5)
								digit1 <= 0;
							else
								digit1 <= digit1 + 1;
                  end
                  else if (digit0 == 'd8) begin
                     digit0 <= 0;
							if (digit1 == 'd5)
								digit1 <= 0;
							else 
								digit1 <= digit1 + 1;
						end
                  else 
                     digit0 <= digit0 + 'd2;
                        
               end // end selecting seconds
					
               else begin // selecting minutes
                  if (digit2 == 'd9) begin
                     digit2 <= 1;
                     if (digit3 == 'd5) 
								digit3 <= 0;
							else 
								digit3 <= digit3 + 1;
						end
                  else if (digit2 == 'd8) begin
                     digit2 <= 0;
							if (digit3 == 'd5) 
								digit3 <= 0;
							else 
								digit3 <= digit3 + 1;
						end
						else 
                     digit2 <= digit2 + 'd2;
               end // end selecting minutes
				end // end clk_2Hz
			end // end is_adjust
			
			// not adjust
			else begin
				if (clk_1Hz) begin
					if (digit0 == 'd9) begin
						digit0 <= 0;
						if (digit1 == 'd5) begin
							digit1 <= 0;
							if (digit2 == 'd9) begin
								digit2 <= 0;
								if (digit3 == 'd5)
									digit3 <= 0;
								else 
									digit3 <= digit3 + 1;
							end
							else
								digit2 <= digit2 + 1;
						end
						else begin
							digit1 <= digit1 + 1;
						end
					end
					else
						digit0 <= digit0 + 1;
				end
				
			end // end not adjust
			
		end // end ~is_pause
		
	end // end always
	
	
	// ===========================================================================
	// load digits to display
	// ===========================================================================
	always @ (posedge clk) begin
		if (rst)
			show_black <= 0;
		else begin
			if (clk_4Hz)
				show_black <= ~show_black;
		
			if (~is_adjust) begin
				digit0_display <= digit0;
				digit1_display <= digit1;
				digit2_display <= digit2;
				digit3_display <= digit3;
			end
			else begin
				if (show_black) begin
					if (is_select) begin // adjust seconds
						digit0_display <= 'd10;
						digit1_display <= 'd10;
						digit2_display <= digit2;
						digit3_display <= digit3;
					end
					else begin // adjust minutes
						digit0_display <= digit0;
						digit1_display <= digit1;
						digit2_display <= 'd10;
						digit3_display <= 'd10;
					end
				end // end show_black
				else begin 
					digit0_display <= digit0;
					digit1_display <= digit1;
					digit2_display <= digit2;
					digit3_display <= digit3;
				end
				
			end // end adjust
		end	
   end //end always
	
	
	// ===========================================================================
	// segment display
   // 0: 10100000
   // 1: 11111001  
   // 2: 10100100
   // 3: 10110000
   // 4: 10011001
   // 5: 10010010
   // 6: 10000010
   // 7: 11111000
   // 8: 10000000
   // 9: 10010000
	// ===========================================================================
   assign seg = seg_reg;
   assign an = an_reg;
   
	always @ (posedge clk) begin
      if (rst) begin
         seg_counter <= 0;
         seg_reg <= 0;
         an_reg <= 0;
      end
		else if (clk_200Hz) begin
		
			if (seg_counter == 'd0) begin
            an_reg <= 'b1110;
            casex (digit0_display)
               'd0: seg_reg <= 'b11000000; //c0
               'd1: seg_reg <= 'b11111001; //f9
               'd2: seg_reg <= 'b10100100; //a4
               'd3: seg_reg <= 'b10110000;
               'd4: seg_reg <= 'b10011001;
               'd5: seg_reg <= 'b10010010;
               'd6: seg_reg <= 'b10000010;
					'd7: seg_reg <= 'b11111000;
					'd8: seg_reg <= 'b10000000; //80
					'd9: seg_reg <= 'b10010000;
					default: seg_reg <= 'b11111111;
            endcase
         end 
         else if (seg_counter == 'd1) begin
            an_reg <= 'b1101;
            casex (digit1_display)
               'd0: seg_reg <= 'b11000000;
               'd1: seg_reg <= 'b11111001;
               'd2: seg_reg <= 'b10100100;
               'd3: seg_reg <= 'b10110000;
               'd4: seg_reg <= 'b10011001;
               'd5: seg_reg <= 'b10010010;
               'd6: seg_reg <= 'b10000010;
               'd7: seg_reg <= 'b11111000;
               'd8: seg_reg <= 'b10000000;
               'd9: seg_reg <= 'b10010000;
               default: seg_reg <= 'b11111111;
            endcase
         end
         else if (seg_counter == 'd2) begin
            an_reg <= 'b1011;
            casex (digit2_display)
               'd0: seg_reg <= 'b11000000;
               'd1: seg_reg <= 'b11111001;
               'd2: seg_reg <= 'b10100100;
               'd3: seg_reg <= 'b10110000;
               'd4: seg_reg <= 'b10011001;
               'd5: seg_reg <= 'b10010010;
               'd6: seg_reg <= 'b10000010;
               'd7: seg_reg <= 'b11111000;
               'd8: seg_reg <= 'b10000000;
               'd9: seg_reg <= 'b10010000;
               default: seg_reg <= 'b11111111;
            endcase
         end
         else begin
            an_reg <= 'b0111;
            casex (digit3_display)
               'd0: seg_reg <= 'b11000000;
               'd1: seg_reg <= 'b11111001;
               'd2: seg_reg <= 'b10100100;
               'd3: seg_reg <= 'b10110000;
               'd4: seg_reg <= 'b10011001;
               'd5: seg_reg <= 'b10010010;
               'd6: seg_reg <= 'b10000010;
               'd7: seg_reg <= 'b11111000;
               'd8: seg_reg <= 'b10000000;
               'd9: seg_reg <= 'b10010000;
               default: seg_reg <= 'b11111111;
            endcase
         end
            seg_counter <= seg_counter + 1;
		end   
         
	end // end always
         
endmodule // nexys3