module DE1_i2sound(
		////////////////////	Clock Input	 	////////////////////	 
		input CLOCK_50,						//	50 MHz
		////////////////////	Push Button		////////////////////
		input [3:0] KEY,							//	Pushbutton[3:0]
		////////////////////////	LED		////////////////////////
		output [7:0] LEDG,							//	LED Green[7:0]
		//output [9:0] LEDR,							//	LED Red[9:0]
		////////////////////	I2C		////////////////////////////
		inout I2C_SDAT,						//	I2C Data
		output I2C_SCLK,						//	I2C Clock
		////////////////////	VGA		////////////////////////////
		//output VGA_HS,							//	VGA H_SYNC
		//output VGA_VS,							//	VGA V_SYNC
		//output [3:0] VGA_R,   						//	VGA Red[3:0]
		//output [3:0] VGA_G,	 						//	VGA Green[3:0]
		//output [3:0] VGA_B,  							//	VGA Blue[3:0]
		////////////////	Audio CODEC		////////////////////////
		inout AUD_ADCLRCK,					//	Audio CODEC ADC LR Clock
		input AUD_ADCDAT,						//	Audio CODEC ADC Data
		inout AUD_DACLRCK,					//	Audio CODEC DAC LR Clock
		output AUD_DACDAT,						//	Audio CODEC DAC Data
		inout AUD_BCLK,						//	Audio CODEC Bit-Stream Clock
		output AUD_XCK						//	Audio CODEC Chip Clock
	);

//	Turn on all display
assign	LEDG		=	VOL;

//	All inout port turn to tri-state
assign	I2C_SDAT		=	1'bz;
assign	AUD_DACLRCK	=	AUD_ADCDAT;
assign	AUD_XCK		=	CLK_12_4;

wire	CLK_12_4;

clock_divider #(1) clock_divider_sample_audio(CLOCK_50, CLK_12_4);	//clock frequency of 12MHz
						
I2C_AV_Config 	I2CAVConfig	(	//	Host Side
						.iCLK(CLOCK_50),
						.iRST_N(KEY[0]),
						.iVOL(VOL),
						//	I2C Side
						.I2C_SCLK(I2C_SCLK),
						.I2C_SDAT(I2C_SDAT)	);

reg	[6:0]	VOL;		
				
always@(negedge KEY[0])
begin
	if(VOL<68)
	VOL		<=	98;
	else
	VOL		<=	VOL+3;
end

endmodule