//-------------------------------------------------------------------------
//                                                                       --
//                                                                       --
//      For use with ECE 385 Lab 62                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab62 (

      ///////// Clocks /////////
      input     MAX10_CLK1_50, 

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);




logic Reset_h, vssig, blank, sync, VGA_Clk;


//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST, p1_hit, p2_hit;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [9:0] drawxsig, drawysig, p1xsig, p1ysig, p2xsig, p2ysig, ms1xsig, ms1ysig, ms2xsig, ms2ysig,  ballsizesig, ballsizesig2;
	logic [7:0] Red, Blue, Green;
	logic [7:0] keycode, keycode1, keycode2, keycode3, keycode4, keycode5;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);

	//Our A/D converter is only 12 bit
	assign VGA_R = Red[7:4];
	assign VGA_B = Blue[7:4];
	assign VGA_G = Green[7:4];
	
	logic [9:0] Dir_x, Dir_y;
	logic [9:0] fake_LED;
	logic [7:0] sprite_enum, sprite_enum2, marine_enum, scorep1, scorep2;
	
	logic [2:0] sprite2_animation;
	
	lab62_soc u0 (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, fake_LED}),
		.keycode_export(keycode),
		
		.sprite_enum_extern_export(sprite_enum),
		.sprite_enum2_extern_export(sprite_enum2),
		.marine_enum_export(marine_enum),
		.keycode1_export(keycode1),
		.keycode2_export(keycode2),
		.keycode3_export(keycode3),
		.keycode4_export(keycode4),
		.keycode5_export(keycode5),
		
		//player 1 location, x y
		.player1x_export(p1xsig),
		.player1y_export(p1ysig),
		.missile1_x_export(ms1xsig),
		.missile1_y_export(ms1ysig),
		
		//player 2 location, x y
		.player2x_export(p2xsig),
		.player2y_export(p2ysig),
		.missile2_x_export(ms2xsig),
		.missile2_y_export(ms2ysig),
		
		//collision bit
		.collisionp1_export(collision1),
		.collisionp2_export(collision2),
		//player 2 animation index
		.sprite2_animation_export(sprite2_animation),
		
		//score rom addr
		.scorep1_export(scorep1),
		.scorep2_export(scorep2),
		
		//hit detection bit
		.p1_hit_export(p1_hit),
		.p2_hit_export(p2_hit)
		
	 );

//instantiate a vga_controller, ball, and color_mapper here with the ports.
	vga_controller c1(		
					// input
					.Clk(MAX10_CLK1_50),       // 50 MHz clock
					.Reset(Reset_h),     // reset signal
					//output
					.hs(hssig),        // Horizontal sync pulse.  Active low
					.vs(vssig),        // Vertical sync pulse.  Active low
					.pixel_clk(VGA_Clk), // 25 MHz pixel clock output
					.blank(blank),     // Blanking interval indicator.  Active low.
					.sync(sync),      // Composite Sync signal.  Active low.  We don't use it in this lab,
												 //   but the video DAC on the DE2 board requires an input for it.
					.DrawX(drawxsig),     // horizontal coordinate
					.DrawY(drawysig) );   // vertical coordinate);
	assign ballsizessig = 4;
	color_mapper c2(	//input
						.p1x(p1xsig), //ballxsig
						.p1y(p1ysig), //ballysig
						.p2x(p2xsig),
						.p2y(p2ysig),
						.DrawX(drawxsig), 
						.DrawY(drawysig), 
						.ms1x(ms1xsig),
						.ms1y(ms1ysig),
						.ms2x(ms2xsig),
						.ms2y(ms2ysig),
						.Ball_size(ballsizesig),
						.clk(MAX10_CLK1_50),
						.blank(blank),
						.sprite_enum(sprite_enum[3:0]),
						.sprite_enum2(sprite_enum2[3:0]),
						.ui_anim_enum(marine_enum[3:0]),
						.sprite2_animation(sprite2_animation[2:0]),
						.scorep1(scorep1),
						.scorep2(scorep2),
						//output
						.Red(Red), 
						.Green(Green),	
						.Blue(Blue) );
	logic collision1, collision2;
	collision_detect cd(	.clk(MAX10_CLK1_50),
								.x_pos1(p1xsig),
								.y_pos1(p1ysig),
								.collision1(collision1),
								.x_pos2(p2xsig),
								.y_pos2(p2ysig),
								.collision2(collision2),
								);
	is_hit p1h (.p1x(p1xsig), .p1y(p1ysig), .p2x(ms2xsig), .p2y(ms2ysig), .hit(p1_hit));
	is_hit p2h (.p1x(p2xsig), .p1y(p2ysig), .p2x(ms1xsig), .p2y(ms1ysig), .hit(p2_hit));
	
	assign VGA_HS = hssig;
	assign VGA_VS = vssig;
endmodule