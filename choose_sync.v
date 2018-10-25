module choose_sync (input clock, 
							input reset,
							input mode,
							output reg [10:0] xpos, ypos,
							output reg vsync, hsync, disp_active);

wire [10:0] xpos_0, ypos_0, xpos_1, ypos_1;
wire vsync_0, hsync_0, disp_active_0, vsync_1, hsync_1, disp_active_1;

always @ (posedge clock)
	case (mode)
		0:	begin vsync <= vsync_0; 
					hsync <= hsync_0; 
					ypos <= ypos_0;
					xpos <= xpos_0;
					disp_active <= disp_active_0;
					//disp_active <= (disp_active_v_0 & disp_active_h_0); 
					end										//640*480 @ 60Hz timing
		1:	begin vsync <= vsync_1; 
					hsync <= hsync_1; 
					ypos <= ypos_1;
					xpos <= xpos_1;
					disp_active <= disp_active_1;
					//disp_active <= (disp_active_v_1 & disp_active_h_1); 
					end										//800*600 @ 72Hz timing
		default: begin vsync <= vsync_1; 
					hsync <= hsync_1; 
					ypos <= ypos_1;
					xpos <= xpos_1;
					disp_active <= disp_active_1;
					//disp_active <= (disp_active_v_1 & disp_active_h_1); 
					end										//800*600 @ 72Hz timing
	endcase

// hsync #(640, 656, 752, 800) h0(clock, xpos_0, hsync_0, disp_active_h_0, newline_0);  //640*480
//vsync #(480, 490, 492, 525) v0(newline_0, ypos_0, vsync_0, disp_active_v_0);
	
//hsync #(800, 856, 976, 1040) h1(clock, xpos_1, hsync_1, disp_active_h_1, newline_1);  //800*600
//vsync #(600, 637, 643, 666) v1(newline_1, ypos_1, vsync_1, disp_active_v_1);*/

syncro #(640, 656, 752, 800, 480, 490, 492, 525) syncro_640_480 (clock, xpos_0, hsync_0, ypos_0, vsync_0, disp_active_0);		//640*480
syncro syncro_800_600 (clock, xpos_1, hsync_1, ypos_1, vsync_1, disp_active_1);			//800*600

endmodule 