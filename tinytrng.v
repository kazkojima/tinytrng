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
   input s_in,
   input r_in,
   output q,
   output qb
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

   SB_LUT4 #(.LUT_INIT(16'b10101010_10101010))
   dla (
	.O(dla_out),
	.I0(dla_in),
	.I1(1'b0),
	.I2(1'b0),
	.I3(1'b0)
	);

   SB_LUT4 #(.LUT_INIT(16'b10101010_10101010))
   dlb (
	.O(dlb_out),
	.I0(dlb_in),
	.I1(1'b1),
	.I2(1'b1),
	.I3(1'b0)
	);
endmodule // metastable

module tinytrng #(parameter integer NUM_UNITS = 1,
		  parameter integer XCLK_DIV = 8)
   (
    input  clk,
    input  resetn,

    output random,
    output pulse,
    output tp
   );

   reg [2:0]  clk_cnt;
   reg [2:0]  xclk_cycle;
   reg 	      xclk;
   reg 	      ff1, ff2, ff3;
   wire       rsffq, rsffqb;

   assign random = rsffq;
   assign pulse = clk;
   assign tp = ff3;

   always @(posedge clk) begin
      if (!resetn)
	begin
	   clk_cnt <= 0;
	   xclk <= 0;
	   xclk_cycle <= 0;
	end // if (!resetn)
      else
	begin
	   clk_cnt <= clk_cnt + 1;
	   if (clk_cnt == XCLK_DIV - 1)
	     begin
		xclk_cycle <= xclk_cycle + 1;
		xclk <= 0;
	     end
	   else
	     begin
		xclk <= 1;
	     end
	end // else: !if(!resetn)
      ff1 <= xclk;
      ff2 <= xclk;
      ff3 <= rsffq;
   end // always @ (posedge clk)

   metastable
     rsff (
	   .s_in	(ff1	),
	   .r_in	(ff2	),
	   .q		(rsffq	),
	   .qb		(rsffqb	)
	   );

endmodule // tinytrng
