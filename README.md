# tinytrng

Experimentations for True Random Number Generator with TinyFPGA.

This picure is a meta stable output (yellow) of a RS flip flop with LUTs and the bit stream (light blue) generated with it.

![meta stable](https://github.com/kazkojima/tinytrng/blob/junkyard/images/metastable.jpg)

A trial of an adaptive adjustment of the delay lines for RS inputs. The yellow and light blue are 2-bit random bit stream.
 The pink signal shows the status of adjustment which high means no adjustment done.

(blue signal is simply added as a triger for scope.)

![trial](https://github.com/kazkojima/tinytrng/blob/junkyard/images/adaptive-delay.png)