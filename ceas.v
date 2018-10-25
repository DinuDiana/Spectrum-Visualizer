module ceas (input clock, input mode, output out);

wire clock_25;

assign out = (mode==1) ? clock : clock_25;

clock_divider #(0) div(clock, clock_25);

endmodule 