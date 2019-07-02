/*
 *  tinytrng - A simple example of True Random Number Generator.
 *
 *  Copyright (C) 2019  Kaz Kojima <kkojima@rr.iij4u.or.jp>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

module metastable
  (
   input  s_in,
   input  r_in,
   output q,
   output qb,
   input  [2:0] ds,
   input  [2:0] dr
   );

   wire       dla_out, dla_in;
   wire       dlb_out, dlb_in;
   assign dla_in = s_in;
   assign dlb_in = r_in;

   wire       lnay, lnaa, lnab;
   wire       lnby, lnba, lnab;
   assign q = lnay;
   assign qb = lnby;
   assign lnaa = qb;
   assign lnba = q;
   assign lnab = dla_out;
   assign lnbb = dlb_out;

   // Nands make a RS flip flop.

   SB_LUT4 #(.LUT_INIT(16'd7))
   lna (
	.O(lnay),
	.I0(lnaa),
	.I1(lnab),
	.I2(1'b0),
	.I3(1'b0)
	);
   
   SB_LUT4 #(.LUT_INIT(16'd7))
   lnb (
	.O(lnby),
	.I0(lnba),
	.I1(lnbb),
	.I2(1'b0),
	.I3(1'b0)
	);

   // Delay lines. Delays are adjusted by hand and are hard coded ATM.

   SB_LUT4 #(.LUT_INIT(16'b10101010_10101010))
   dla (
	.O(dla_out),
	.I0(dla_in),
	.I1(ds[0]),
	.I2(ds[1]),
	.I3(ds[2]),
	);

   SB_LUT4 #(.LUT_INIT(16'b10101010_10101010))
   dlb (
	.O(dlb_out),
	.I0(dlb_in),
	.I1(dr[0]),
	.I2(dr[1]),
	.I3(dr[2]),
	);
endmodule // metastable

module tinytrng #(parameter integer NUM_UNITS = 1,
		  parameter integer XCLK_DIV = 16,
		  localparam integer NUM_MEM = 16)
   (
    input  clk,
    input  resetn,

    output random,
    output pulse,
    output tp,
    output bclk,
   );

   reg [3:0]  clk_cnt;
   reg [3:0]  xclk_cycle;
   reg 	      xclk;
   reg 	      ff, ffb;
   reg [3:0]  p_cnt;
   reg [3:0]  latch;
   reg [8:0]  sum;
   reg [3:0]  mem_index;
   reg [3:0]  mem [0:NUM_MEM-1];
   reg 	      mem_fill;
   reg [3:0]  avarage;
   reg [2:0]  sdelay, rdelay;
   reg 	      mstable;
   wire       rsffq, rsffqb;

   assign random = latch[0];
   assign pulse = latch[1];
   assign tp = metastable;
   assign bclk = xclk;

   assign avarage = sum >> 4;

   always @(posedge clk) begin
      if (!resetn)
	begin
	   clk_cnt <= 0;
	   xclk <= 0;
	   xclk_cycle <= 0;
	   ff <= 1;
	   ffb <= 0;
	   p_cnt <= 0;
	   latch <= 0;
	   mem_index <= 0;
	   mem_fill <= 0;
	   sum <= 0;
	   sdelay <= 0;
	   rdelay <= 0;
	   mstable <= 0;
	end // if (!resetn)
      else
	begin
	   clk_cnt <= clk_cnt + 1;
	   if (clk_cnt == XCLK_DIV - 1)
	     begin
		xclk_cycle <= xclk_cycle + 1;
		xclk <= 0;
		latch <= p_cnt;
		sum <= (sum - (mem_fill ? mem[mem_index+1] : 0)) + p_cnt;
		if (mem_index == NUM_MEM - 1)
		  begin
		     mem_fill <= 1;
		  end
		mem_index <= mem_index + 1;
		if (mem_fill)
		  begin
		     if (avarage < 2)
		       begin
			  // ds up dr down
			  sdelay <= { sdelay[1:0], 1 };
			  rdelay <= { 0, rdelay[2:1] };
			  metastable <= 0;
		       end
		     else if (avarage > 13)
		       begin
			  // ds down dr up
			  sdelay <= { 0, sdelay[2:1] };
			  rdelay <= { rdelay[1:0], 1 };
			  metastable <= 0;
		       end
		     else
		       begin
			  metastable <= 1;
		       end
		  end
		p_cnt <= 0;
	     end
	   else
	     begin
		xclk <= 1;
	     end
	   ff <= rsffq;
	   ffb <= rsffqb;
	   if (ff)
	     begin
		p_cnt <= p_cnt + 1;
	     end
	end // else: !if(!resetn)
   end // always @ (posedge clk)

   metastable
     rsff (
	   .s_in	(xclk	),
	   .r_in	(xclk	),
	   .q		(rsffq	),
	   .qb		(rsffqb	),
	   .ds		(sdelay ),
	   .dr		(rdelay )
	   );

endmodule // tinytrng
