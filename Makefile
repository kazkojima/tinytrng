
upload: hardware.bin
	tinyprog -p hardware.bin

hardware.json: hardware.v tinytrng.v
	yosys -ql hardware.log -p 'synth_ice40 -top hardware -json hardware.json' $^

hardware.asc: hardware.pcf hardware.json
	nextpnr-ice40 --lp8k --package cm81 --json hardware.json --pcf hardware.pcf --asc hardware.asc --force

hardware.bin: hardware.asc
	icetime -d hx8k -mtr hardware.rpt hardware.asc
	icepack hardware.asc hardware.bin

clean:
	rm -f hardware.json hardware.log hardware.asc hardware.rpt hardware.bin




