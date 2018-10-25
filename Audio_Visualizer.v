module Audio_Visualizer(
////////////////////////	Clock Input	 	////////////////////////
input				CLOCK_50,				//	50 MHz
////////////////////////	Push Button		////////////////////////
input		[3:0]	KEY,						//	Pushbutton[3:0]
////////////////////////	DPDT Switch		////////////////////////
input		[9:0]	SW,						//	Toggle Switch[9:0]
////////////////////////////	LED		////////////////////////////
output	[7:0]	LEDG,						//	LED Green[7:0]
output	[9:0]	LEDR,						//	LED Red[9:0]
////////////////////////	I2C		////////////////////////////////
inout				I2C_SDAT,				//	I2C Data
output			I2C_SCLK,				//	I2C Clock
////////////////////////	VGA			////////////////////////////
output			VGA_HS,					//	VGA H_SYNC
output			VGA_VS,					//	VGA V_SYNC
output	[3:0]	VGA_R,   				//	VGA Red[3:0]
output	[3:0]	VGA_G,	 				//	VGA Green[3:0]
output	[3:0]	VGA_B,   				//	VGA Blue[3:0]
////////////////////	Audio CODEC		////////////////////////////
inout				AUD_ADCLRCK,			//	Audio CODEC ADC LR Clock
input				AUD_ADCDAT,				//	Audio CODEC ADC Data
inout				AUD_DACLRCK,			//	Audio CODEC DAC LR Clock
output			AUD_DACDAT,				//	Audio CODEC DAC Data
inout				AUD_BCLK,				//	Audio CODEC Bit-Stream Clock
output			AUD_XCK					//	Audio CODEC Chip Clock
	);

wire [31:0] dout;
wire [7:0] R, G, B;

DE1_i2sound sound_inst(
////////////////////	Clock Input	 	////////////////////	 
CLOCK_50,						//	50 MHz
////////////////////	Push Button		////////////////////
KEY,								//	Pushbutton[3:0]
////////////////////////	LED		////////////////////////
LEDG,								//	LED Green[7:0]
////////////////////	I2C		////////////////////////////
I2C_SDAT,						//	I2C Data
I2C_SCLK,						//	I2C Clock
////////////////	Audio CODEC		////////////////////////
AUD_ADCLRCK,					//	Audio CODEC ADC LR Clock
AUD_ADCDAT,						//	Audio CODEC ADC Data
AUD_DACLRCK,					//	Audio CODEC DAC LR Clock
AUD_DACDAT,						//	Audio CODEC DAC Data
AUD_BCLK,						//	Audio CODEC Bit-Stream Clock
AUD_XCK							//	Audio CODEC Chip Clock
);

DSP digital_signal_processing_inst(
////////////////////	Clock Input	 	////////////////////	
.CLOCK_50(CLOCK_50),
////////////////	Audio CODEC		////////////////////////
.AUD_ADCLRCK(AUD_ADCLRCK),						//	Audio CODEC ADC LR Clock
.AUD_ADCDAT(AUD_ADCDAT),						//	Audio CODEC ADC Data
.AUD_BCLK(AUD_BCLK),								//	Audio CODEC Bit-Stream Clock
////////////////Fast Fourier Transform Data - Output ////////////
.source_eop_l(source_eop_l),
.source_sop_l(source_sop_l),
.source_eop_r(source_eop_r),
.source_sop_r(source_sop_r),
.source_error_r(source_error_r),
.source_error_l(source_error_l),
.dout(dout),
.sink_eop(sink_eop),
.sink_sop(sink_sop),
.source_real_l_div(source_real_l_div),
.data_ok(data_ok),
.source_imag_l_div(source_imag_l_div),
.source_real_l(source_real_l),
.source_real_r(source_real_r),
.source_imag_l(source_imag_l),
.source_imag_r(source_imag_r),
.source_real_r_div(source_real_r_div),
.source_imag_r_div(source_imag_r_div),
.source_valid_r(source_valid_r),
.source_valid_l(source_valid_l)
);	
		
VGA_2 VGA_contr(
.clk(CLOCK_50),	 				//clock from FPGA – 50MHz
.mode(mode),					//selects the resolution we want the image to be displayed on 
											//(800 X 600 or 640 X 480)
.rst(rst), 
.xpos(xpos), 						//horizontal position
.ypos(ypos),						//vertical position
.disp_active(disp_active),		//synchronization signal that indicates if the displayed pixel is in the 
											//active area of the display or in the back or front porch
.R(R), .G(G), .B(B),			//4 bit output for the red, green and blue pixel which dictates the color 
										//of the displayed object
.hsync(VGA_HS), 				//horizontal sync – it activates after the active and the front porch areas 
											//of pixels were displayed horizontally and stays active until it reaches 
											//the back porch area
.vsync(VGA_VS),				//vertical sync – it activates after the active and the front porch areas 
											//of pixels were displayed vertically and stays active until it reaches the 
											//back porch area
											//direct logic
//////////Fast Fourier Transform Data - Input ////////////									
.clk_fft_l(data_ok),
.clk_fft_r(data_ok),
.source_real_l(source_real_l),
.source_imag_l(source_imag_l),
.source_ready_l(1'b1),
.source_valid_l(source_valid_l),
.source_sop_l(source_sop_l),
.source_eop_l(source_eop_l),
.source_real_r(source_real_r),
.source_imag_r(source_imag_r),
.source_ready_r(1'b1),
.source_valid_r(source_valid_r),
.source_sop_r(source_sop_r),
.source_eop_r(source_eop_r),
.source_real_l_div(source_real_l_div),
.source_real_r_div(source_real_r_div),
.source_imag_l_div(source_imag_l_div),
.source_imag_r_div(source_imag_r_div)
);	
		
assign VGA_R = R[7:4];
assign VGA_G = G[7:4];
assign VGA_B = B[7:4];		
assign rst = KEY[3];
assign mode = KEY[1];

assign LEDR[0] = (SW[1] == 1) ? sink_sop : source_real_l_div[0];
assign LEDR[1] = (SW[1] == 1) ? sink_eop : source_real_l_div[1];
assign LEDR[2] = (SW[1] == 1) ? source_sop_r : source_real_l_div[2];	
assign LEDR[3] = (SW[1] == 1) ? source_eop_r : source_real_l_div[3];
assign LEDR[4] = (SW[1] == 1) ? source_sop_l : source_real_l_div[4];
assign LEDR[5] = (SW[1] == 1) ? source_eop_l : source_real_l_div[5];
assign LEDR[7:6] = (SW[1] == 1) ? source_error_r : source_real_l_div[7:6];
assign LEDR[9:8] = (SW[1] == 1) ? source_error_l : source_real_l_div[9:8];

wire [15:0] source_real_l_div;
wire [15:0] source_real_l;
		
endmodule