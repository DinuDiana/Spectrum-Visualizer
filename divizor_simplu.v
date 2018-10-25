module clock_divider #(parameter N = 2)(input clock, output out);

reg [31:0] numar=0;

always @ (posedge clock)

     numar <= numar + 1;

assign out = numar[N];

endmodule