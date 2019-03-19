module nexys3 (/*AUTOARG*/
   // Outputs
   RsTx, led,
   // Inputs
   RsRx, sw, btnS, btnSeparateS, btnR, clk
   );

`include "seq_definitions.v"
   
   // USB-UART
	// display outputs on the terminal
   input        RsRx;
   output       RsTx;

   // Misc.
   input  [7:0] sw;
   output [7:0] led;
   input        btnS;                 // single-step instruction
	input        btnSeparateS;         // a separate send button
   input        btnR;                 // arst
   
   // Logic
   input        clk;                  // 100MHz
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [seq_dp_width-1:0] seq_tx_data;         // From seq_ of seq.v
   wire                 seq_tx_valid;           // From seq_ of seq.v
   wire [7:0]           uart_rx_data;           // From uart_top_ of uart_top.v
   wire                 uart_rx_valid;          // From uart_top_ of uart_top.v
   wire                 uart_tx_busy;           // From uart_top_ of uart_top.v
   // End of automatics
   
   wire        rst;
   wire        arst_i;
   wire [17:0] clk_dv_inc;

   reg [1:0]   arst_ff;    // async reset flip flop
   reg [16:0]  clk_dv;     // clock divider
   reg         clk_en;     // clock enable
   reg         clk_en_d;   // clock enable delay
      
   reg [7:0]   inst_wd;          // store values of 8 switches
   reg         inst_vld;         // true if instruction is valid (button push is stable?)
   reg [2:0]   step_d;           // step delay; store prev state of btnS
	reg [2:0]   step_separate_d;  // step delay; store prev state of btnSeparateS

   reg [7:0]   inst_cnt; // counter for instructions
   
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
     if (rst)
       begin
          clk_dv   <= 0;
          clk_en   <= 1'b0;
          clk_en_d <= 1'b0;
       end
     else
       begin
          clk_dv   <= clk_dv_inc[16:0];
          clk_en   <= clk_dv_inc[17];
          clk_en_d <= clk_en;
       end
   
   // ===========================================================================
   // Instruction Stepping Control / Debouncing
   // ===========================================================================

   always @ (posedge clk)
     if (rst)
       begin
          inst_wd[7:0]         <= 0;
          step_d[2:0]          <= 0;
			 step_separate_d[2:0] <= 0;
       end
     else if (clk_en) // Down sampling
       begin
          inst_wd[7:0]         <= sw[7:0];
			 
			 // shift right step_d and put btnS 
			 // to the most significant bit
          step_d[2:0]          <= {btnS, step_d[2:1]};
			 
			 // shift right of step_separate_d and 
			 // put btnSeparateS to the most significant bit
			 step_separate_d[2:0] <= {btnSeparateS, step_separate_d[2:1]};  
       end
	   
	// Detecting posedge of btnS
   wire is_btnS_posedge;
   assign is_btnS_posedge = ~ step_d[0] & step_d[1];
	
	// Detecting posedge of btnSeparateS
	wire is_btnSeparateS_posedge;
	assign is_btnSeparateS_posedge = ~ step_separate_d[0] & step_separate_d[1];
	
   always @ (posedge clk)
     if (rst)
       inst_vld <= 1'b0;
     else if (clk_en_d)
	    // instruction is valid if btnS or btnSeparateS is pressed
       inst_vld <= is_btnS_posedge | is_btnSeparateS_posedge;
	  else
	    inst_vld <= 0;

   always @ (posedge clk)
     if (rst)
       inst_cnt <= 0;
     else if (inst_vld)
       inst_cnt <= inst_cnt + 1;

   assign led[7:0] = inst_cnt[7:0];
   
   // ===========================================================================
   // Sequencer
   // ===========================================================================

	// Instantiate seq module from seq.v
   seq seq_ (// Outputs
             .o_tx_data                 (seq_tx_data[seq_dp_width-1:0]),
             .o_tx_valid                (seq_tx_valid),
             // Inputs
             .i_tx_busy                 (uart_tx_busy),
             .i_inst                    (inst_wd[seq_in_width-1:0]), // same as inst_wd[7:0]
             .i_inst_valid              (inst_vld), 
				 .i_is_btnSeparateS_posedge (is_btnSeparateS_posedge),
             /*AUTOINST*/
             // Inputs
             .clk                       (clk),
             .rst                       (rst));
   
   // ===========================================================================
   // UART controller
   // ===========================================================================

	// instantiate uart_top module from uart_top.v
   uart_top uart_top_ (// Outputs
                       .o_tx            (RsTx),
                       .o_tx_busy       (uart_tx_busy),
                       .o_rx_data       (uart_rx_data[7:0]),
                       .o_rx_valid      (uart_rx_valid),
                       // Inputs
                       .i_rx                      (RsRx),
                       .i_tx_data                 (seq_tx_data[seq_dp_width-1:0]),
                       .i_tx_stb                  (seq_tx_valid),
							  .i_ra                      (inst_wd[5:4]),
                       /*AUTOINST*/
                       // Inputs
                       .clk             (clk),
                       .rst             (rst));
   
endmodule // nexys3
// Local Variables:
// verilog-library-flags:("-f ../input.vc")
// End:
