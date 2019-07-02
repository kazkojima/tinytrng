/*
 *  Cosmem - A simple example memory/controller chip for COSMAC
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

module hardware (
    input  clk_16mhz,

    // onboard USB interface
    output pin_pu,
    output pin_usbp,
    output pin_usbn,

    // RANDOM
    output pin_1,

    // PULSE
    output pin_2,

    // TP
    output pin_3,

    // BCLK
    output pin_4,

    // onboard LED
    output user_led,
);
    assign pin_pu = 1'b1;
    assign pin_usbp = 1'b0;
    assign pin_usbn = 1'b0;

    wire clk = clk_16mhz;

    // Power-on Reset
    reg [5:0] reset_cnt = 0;
    wire resetn = &reset_cnt;

    always @(posedge clk) begin
        reset_cnt <= reset_cnt + !resetn;
    end

    tinytrng #(
        .NUM_UNITS(1),		// use 1 unit by default
	.XCLK_DIV(16)		// use 16/16=1MHz xclk by default
    ) trng (
        .clk          (clk         ),
	.resetn       (resetn      ),

        .random       (pin_1       ),
        .pulse        (pin_2       ),
        .tp           (pin_3       ),
        .bclk         (pin_4       ),
    );
endmodule
