# Spectrum-Visualizer

Spectrum visualizer for Altera DE1 FPGA Board - Verilog.

This module uses a VGA-Controller, the audio CODEC, and FFT IP Cores in order to play music using headphones directly from the FPGA and display the frequency spectrum of the input music. The project is currently not functional as the FFT ip core has incompatibilities with the FPGA Board used, therefore the display(and calculations) portion of the project is not fully tested and optimised.

module Audio_Visualizer(  
//////////////////////// Clock Input ////////////////////////   
input CLOCK_50, // 50 MHz   
//////////////////////// Push Button ////////////////////////   
input [3:0] KEY, // Pushbutton[3:0]   
// KEY[0] increases volume; It must be  
//pushed once to allow data to be heard on  
//the speakers  
// KEY[1] changes the resolution  
// KEY[3] – reset for VGA Controller  
//////////////////////// DPDT Switch ////////////////////////  
input [9:0] SW, // Toggle Switch[9:0]  
// SW[1] changes the data displayed on the  
//red LEDs– if SW1 = 1 it shows troubleshooting  
//data, else displays FFT samples from the left  
//channel 
//////////////////////////// LED ////////////////////////////  
output [7:0] LEDG, // LED Green[7:0] – displays volume  
output [9:0] LEDR,  // LED Red[9:0] – displays data from FFT – if  
//SW1 = 1 it shows troubleshooting data, else  
//displays FFT samples from the left channel  
//////////////////////// I2C ////////////////////////////////  
inout I2C_SDAT, // I2C Data output I2C_SCLK,  
// I2C Clock  
//////////////////////// VGA ////////////////////////////  
output VGA_HS, // VGA H_SYNC  
output VGA_VS,  // VGA V_SYNC   
output [3:0] VGA_R,  // VGA Red[3:0]  
output [3:0] VGA_G,  // VGA Green[3:0]   
output [3:0] VGA_B,  // VGA Blue[3:0]  
//////////////////// Audio CODEC ////////////////////////////  
inout AUD_ADCLRCK, // Audio CODEC ADC LR Clock   
input AUD_ADCDAT,  // Audio CODEC ADC Data  
inout AUD_DACLRCK,  // Audio CODEC DAC LR Clock  
output AUD_DACDAT,  // Audio CODEC DAC Data  
inout AUD_BCLK, // Audio CODEC Bit-Stream Clock   
output AUD_XCK // Audio CODEC Chip Clock );
