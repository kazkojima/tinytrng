
upload: hardware.bin
	tinyprog -p hardware.bin

sim: hx8kdemo_tb.vvp
	vvp -N $<
	gtkwave testbench.vcd

hx8kdemo_tb.vvp: hx8kdemo_tb.v hardware.v tinytrng.v
	iverilog -s testbench -o $@ $^ /usr/local/share/yosys/ice40/cells_sim.v

hardware.json: hardware.v tinytrng.v
	yosys -ql hardware.log -p 'synth_ice40 -top hardware -json hardware.json' $^

hardware.asc: hardware.pcf hardware.json
	nextpnr-ice40 --lp8k --package cm81 --json hardware.json --pcf hardware.pcf --asc hardware.asc --force

hardware.bin: hardware.asc
	icetime -d hx8k -mtr hardware.rpt hardware.asc
	icepack hardware.asc hardware.bin

clean:
	rm -f hardware.json hardware.log hardware.asc hardware.rpt hardware.bin




