// Copyright 2006, 2007 Dennis van Weeren
//
// This file is part of Minimig
// 
// Modified by caro for 1ChipMSX in 2017
//
// Minimig is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.
//
// Minimig is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//PS2 mouse controller.
//This module decodes the standard 3 byte packet of an PS/2 compatible 2 or 3 button mouse.
//The module also automatically handles power-up initailzation of the mouse.

module ps2mouse(clk,reset,strob,mouse_en,mdata,ps2mdat,ps2mclk);

input   clk;        //bus clock
input   reset;      //reset
output  mouse_en;   //mouse enable
input   strob;      //strob
output  [5:0]mdata; //mdata
inout   ps2mdat;    //mouse PS/2 data
inout   ps2mclk;    //mouse PS/2 clk
//==========================================================
//local signals
reg  mouse_en;
reg  [3:0]nibl;
reg  [5:0]mdata;
reg  [7:0]mbutton;
reg  [7:0]ycount;
reg  [7:0]xcount;
reg  [7:0]coord_X;
reg  [7:0]coord_Y;

reg  mclkout=1; 	//mouse clk out
wire mdatout;	//mouse data out
reg  mdatb,mclkb,mclkc;	//input synchronization	

reg	[7:0]delta_Y;	//mouse delta y
reg	[7:0]delta_X;	//mouse delta x
reg	fdelta;		//flag receive packets
reg	[10:0]mreceive;	//mouse receive register
reg	[11:0]msend;	//mouse send register
reg	[15:0]mtimer;	//mouse timer
reg	[2:0]mstate;	//mouse current state
reg	[2:0]mnext;	//mouse next state
reg	[15:0]msxtimer;	//MSX mouse timer
reg	[3:0]msxstate;	//MSX mouse current state
reg	[3:0]msxnext;	//MSX mouse next state

wire mclkneg;	//negative edge of mouse clock strobe
reg	 mrreset;	//mouse receive reset
wire mrready;	//mouse receive ready;
reg	 msreset;	//mouse send reset
wire msready;	//mouse send ready;
reg	 mtreset;	//mouse timer reset
wire mtready;	//mouse timer ready
reg  msxtreset;	//MSX mouse timer reset
reg  mcreset;	//MSX mouse coord reset
wire msxtready;	//MSX mouse timer ready
wire mthalf;		//mouse timer somewhere halfway timeout
reg [1:0]mpacket;	//mouse packet byte valid number

//bidirectional open collector IO buffers
assign ps2mclk=(mclkout)?1'bz:1'b0;
assign ps2mdat=(mdatout)?1'bz:1'b0;

//input synchronization of external signals
always @(posedge clk)
begin
	mdatb <= ps2mdat;
	mclkb <= ps2mclk;
	mclkc <= mclkb;
end

//detect mouse clock negative edge
assign mclkneg=mclkc&(~mclkb);

//PS2 mouse input shifter
always @(posedge clk)
	if(mrreset)
		mreceive[10:0] <= 11'b11111111111;
	else if(mclkneg)
		mreceive[10:0] <= {mdatb,mreceive[10:1]};
assign mrready = ~mreceive[0];

//PS2 mouse send shifter
always @(posedge clk)
	if(reset || msreset)
	 begin
	    mouse_en <= 0;
		msend[11:0] <= 12'b110111101000; //send 0xf4 - mouse acktiv
	 end
	else if(!msready && mclkneg)
	 begin
		mouse_en <= 1;
		msend[11:0] <= {1'b0,msend[11:1]};
	 end
assign msready = (msend[11:0]==12'b000000000001)?1:0;
assign mdatout = (msreset)?1:msend[0];

//PS2 mouse timer
always @(posedge clk)
	if(mtreset)
		mtimer[15:0]<=16'h0000;
	else
		mtimer[15:0]<=mtimer[15:0]+1;
assign mtready=(mtimer[15:0]==16'hffff)?1:0;
assign mthalf=mtimer[11];

//MSX mouse timer
always @(posedge clk)
	if(msxtreset)
		msxtimer[15:0]<=16'h8000;
	else
		msxtimer[15:0] <= msxtimer[15:0]+1;
assign msxtready = (msxtimer[15:0]==16'hffff)?1:0;

//PS2 mouse packet decoding and handling
always @(posedge clk)
begin
	if(reset)
	  begin
		mbutton[7:0] <= 8'hf7;
		delta_X[7:0] <= 8'h00;	
		delta_Y[7:0] <= 8'h00;
	  end
	else if(mpacket==1)       //buttons
		mbutton[7:0] <= ~mreceive[8:1];
	else if(mpacket==2)       //delta X movement
	    delta_X[7:0] <= mreceive[8:1];
	else if(mpacket==3)       //delta Y movement
	  begin
	    delta_Y[7:0] <= mreceive[8:1];
	    fdelta <= 1;
	  end
	else if (mpacket==0)
	    fdelta <= 0;
end

//PS2 mouse packet decoding and handling for MSX
always @(posedge clk)
begin
	if(reset || mcreset)       //reset
	begin
		xcount[7:0]  <= 8'h00;	
		ycount[7:0]  <= 8'h00;
	end
//;--------------------------------------------------
//;     7     |      6    |     5     |     4       |
//;--------------------------------------------------
//; Y overflow| X overflow| Y sign bit| X sign bit  |
//;--------------------------------------------------
//;     3     |      2    |     1     |     0       |
//;--------------------------------------------------
//; Always 1  |Middle Btn | Right Btn |  Left Btn   |
//;--------------------------------------------------
    else if (fdelta)		// new packets receive
	  begin
	    if (delta_X == 8'h00)                  // deltaX = 0
	        xcount[7:0]  <= 8'h00; 
	    else
	        xcount[7:0]  <= -{~mbutton[4], delta_X[7:1]};
	    if (delta_Y == 8'h00)                  // deltaY = 0
	        ycount[7:0]  <= 8'h00; 
	    else
	        ycount[7:0]  <=  {~mbutton[5], delta_Y[7:1]};
	 end
end

always @(posedge clk)
	if(reset)       //reset
	    mdata <= 6'b000000;
	else
        mdata <= {mbutton[1:0],nibl};

//--------------------------------------------------------------
//--------------------------------------------------------------
//PS2 mouse state machine
always @(posedge clk)
	if(reset || mtready)    //master reset OR timeout
		mstate <= 0;
	else 
		mstate <= mnext;
always @(mstate or mthalf or msready or mrready or mreceive)
begin
	case(mstate)
		0:                  //initialize mouse phase 0, start timer
			begin
				mclkout=1;	//clk_ps2 = Z
				mrreset=1;
				mtreset=1;  // mouse timer reset
				msreset=1;
				mpacket=0;
				mnext=1;
			end

		1:                   //initialize mouse phase 1, hold clk low and reset send logic
			begin
				mclkout=0;	 //clk_ps2 = 0
				mrreset=0;
				mtreset=0;   // mouse timer start
				msreset=1;
				mpacket=0;
				if(mthalf)   //clk was low long enough, go to next state
					mnext=2;
				else
					mnext=1;
			end

		2:                   //initialize mouse phase 2, send 'enable data reporting' command to mouse
			begin
				mclkout=1;	 //clk_ps2 = Z
				mrreset=1;
				mtreset=0;
				msreset=0;   // begin send
				mpacket=0;
				if(msready)  //command set, go get 'ack' byte
				  begin
					mnext=6;
				  end
				else
					mnext=2;
			end

		3://get first packet byte
			begin
				mclkout=1;	 //mclk_ps2 = Z
				mtreset=1;   //reset mouse timer
				msreset=0;
				if(mrready)  //we got our first packet byte
				begin
					mpacket=1;
					mrreset=1;
					mnext=4;
				end
				else         //we are still waiting
				begin
					mpacket=0;
					mrreset=0;
					mnext=3;
				end
			end

		4:                   //get second packet byte
			begin
				mclkout=1;
				mtreset=0;
				msreset=0;
				if(mrready)   //we got our second packet byte
				begin
					mpacket=2;
					mrreset=1;
					mnext=5;
				end
				else          //we are still waiting
				begin
					mpacket=0;
					mrreset=0;
					mnext=4;
				end
			end

		5:               //get third packet byte (or get 'ACK' byte..)
			begin
				mclkout=1;
				mtreset=0;
				msreset=0;
				if(mrready)   //we got our third packet byte
				begin
					mpacket=3;
					mrreset=1;
					mnext=3;
				end
				else            //we are still waiting
				begin
					mpacket=0;
					mrreset=0;
					mnext=5;
				end
			end 
		6:               //get 'ACK' (0xFA) byte..
			begin
				mclkout=1;
				mtreset=0;
				msreset=0;
				mpacket=0;
				if(mrready)   //we got byte
				begin
					mrreset=1;
					mnext=3;
				end
				else            //we are still waiting
				begin
					mrreset=0;
					mnext=6;
				end
			end 
	endcase
end
//--------------------------------------------------------------
//--------------------------------------------------------------
//MSX mouse state machine
always @(posedge clk)
	if(reset || msxtready)         //master reset OR MSX timeout
		   msxstate <= 0;
	else 
		   msxstate <= msxnext;
always @(msxstate or strob)
begin
	case(msxstate)

		0:                         //initialize MSX mouse phase 0
			begin
				msxtreset <= 1;     // MSX timer reset
				mcreset   <= 0;
                nibl      = 4'h0;
				if (strob)
				    begin
						coord_X  = xcount[7:0];
						coord_Y  = ycount[7:0];
						msxnext  = 1;
				    end
				else
						msxnext = 0;
			end

		1:
			begin
				msxtreset <=0;       // start MSX timer
				mcreset   <=1;	     // reset xcount,ycount
				nibl = coord_X[7:4];
				if (~strob)
					msxnext = 2;
				else
					msxnext = 1;
			end

		2:
			begin
				msxtreset <=0;
				mcreset   <=0;
				nibl = coord_X[3:0];
				if (strob)
					msxnext = 3;
				else
					msxnext = 2;
			end

		3:
			begin
				msxtreset <=0;
				mcreset   <=0;
				nibl = coord_Y[7:4];
				if (~strob)
					msxnext = 4;
				else
					msxnext = 3;
			end

		4:
			begin
				msxtreset <=0;
				mcreset   <=0;
                nibl = coord_Y[3:0];
				if (strob)
					msxnext = 5;
				else
					msxnext = 4;
			end

		5:
			begin
				msxtreset <=0;
				mcreset   <=0;
                nibl = 4'h0;
				if (~strob)
					msxnext = 6;
				else
					msxnext = 5;
			end

		6:
			begin
				msxtreset <=0;
				mcreset   <=0;
                nibl = 4'h0;
				if (strob)
					msxnext = 7;
				else
					msxnext = 6;
			end

		7:
			begin
				msxtreset <=0;
				mcreset   <=0;
                nibl = 4'h0;
				if (~strob)
					msxnext = 8;
				else
					msxnext = 7;
			end

		8:
			begin
				msxtreset <=0;
				mcreset   <=0;
				nibl = 4'h0;
			   msxnext = 8;   // wait MSX timer overflow 3 msec
			end
	endcase
end
////////////////////////////////////////////////////////////////
endmodule
