PROJ = top_md5
DEVICE = hx8k
SOURCES = $(PROJ).v ../../../hdl/md5_lib/async.v ../../../hdl/ice40_ip/pll_96mhz.v ../../../hdl/md5_lib/cmd_parser.v ../../../hdl/md5_lib/string_process_match.v ../../../hdl/md5_lib/md5core.v ../../../hdl/md5_lib/hash_op.v
PIN_DEF = $(PROJ).pcf

all: $(PROJ).rpt $(PROJ).bin

%.blif: $(SOURCES)
	yosys -p 'synth_ice40 -top $(PROJ) -blif $@' $^

%.asc: $(PIN_DEF) %.blif
	arachne-pnr -d $(subst hx,,$(subst lp,,$(DEVICE))) -o $@ -p $^

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $<

prog: $(PROJ).bin
	iceprog $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo iceprog $<

clean:
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).rpt $(PROJ).bin

.SECONDARY:
.PHONY: all prog clean
