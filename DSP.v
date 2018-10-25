module DSP (
		input CLOCK_50,
		/////////////////DATA FROM CODEC/////////////
		inout AUD_ADCLRCK,					//	Audio CODEC ADC LR Clock
		input AUD_ADCDAT,						//	Audio CODEC ADC Data
		input AUD_BCLK,						//	Audio CODEC Bit-Stream Clock
		////////OUTPUT FOR CHECK////////////
		output source_eop_l,
		output source_sop_l,
		output source_eop_r,
		output source_sop_r,
		output [1:0] source_error_r,
		output [1:0] source_error_l,
		output [31:0] dout,
		output sink_eop,
		output sink_sop,
		output [15:0] source_real_l_div,
		output data_ok,
		output [15:0] source_imag_l_div,
		output [15:0] source_real_l,
		output [15:0] source_real_r,
		output [15:0] source_imag_l,
		output [15:0] source_imag_r,
		output [15:0] source_real_r_div,
		output [15:0] source_imag_r_div,
		output source_valid_r, source_valid_l
		);
		

fft fft_right(
	.clk(data_ok),
	.reset_n(reset_n),
	.inverse(0),
	.sink_valid(sink_valid),
	.sink_sop(sink_sop),
	.sink_eop(sink_eop),
	.sink_real(dout[31:16]),
	.sink_imag(16'h0000),
	.sink_error(2'b00),
	.source_ready(1'b1),
	.sink_ready(sink_ready_r),
	.source_error(source_error_r),
	.source_sop(source_sop_r),
	.source_eop(source_eop_r),
	.source_valid(source_valid_r),
	.source_exp(source_exp_r),
	.source_real(source_real_r),
	.source_imag(source_imag_r)
	);

fft_divider fft_div_right(
			.clock_50(CLOCK_50),
			.clock_fft(data_ok),
			.data_in_real(source_real_r),
			.data_out_real(source_real_r_div),
			.data_in_imag(source_imag_r),
			.data_out_imag(source_imag_r_div)
			);	
	
fft fft_left(
	.clk(data_ok),
	.reset_n(reset_n),
	.inverse(0),
	.sink_valid(sink_valid),
	.sink_sop(sink_sop),
	.sink_eop(sink_eop),
	.sink_real(dout[15:0]),
	.sink_imag(16'h0000),
	.sink_error(2'b00),
	.source_ready(1'b1),
	.sink_ready(sink_ready_l),
	.source_error(source_error_l),
	.source_sop(source_sop_l),
	.source_eop(source_eop_l),
	.source_valid(source_valid_l),
	.source_exp(source_exp_l),
	.source_real(source_real_l),
	.source_imag(source_imag_l)
	);

fft_divider fft_div_left(
			.clock_50(CLOCK_50),
			.clock_fft(data_ok),
			.data_in_real(source_real_l),
			.data_out_real(source_real_l_div),
			.data_in_imag(source_imag_l),
			.data_out_imag(source_imag_l_div)
			);		

SIPO register_dac(.clock(clock_1_5kHz),
						.din(AUD_ADCDAT), 
						.ADCLRC(AUD_ADCLRCK), 
						.BCLK(AUD_BCLK),
						.reset(reset), 
						.dout(dout),
						.data_ok(data_ok),
						.sink_valid(sink_valid),
						.sink_eop(sink_eop),
						.sink_sop(sink_sop),
						.reset_n(reset_n),
						.clock_fft_int(clock_fft_int),
						.clock_fft(clock_fft)
						);
						
					
endmodule