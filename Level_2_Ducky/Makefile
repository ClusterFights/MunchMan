# Makefile to run verilog simulations
#
# Targets:
#    "make compile"             compiles only
#    "make run"                 runs only
#    "make viewer"              starts waveform viewer
#    "make clean"               deletes temporary files and dirs


#----- Useful variables
NAME_TOP	:= top_loopback
VPI_DIR		:= ${HOME}/usr/lib/ivl

#----- Targets, iverilog
# Use this to compile without running simulation
compile:
	iverilog -tvvp -c $(NAME_TOP).vf -o $(NAME_TOP).vvp -v > $(NAME_TOP).log

# Run simulation
run:
	vvp -M $(VPI_DIR) $(NAME_TOP).vvp

# Start viewer
viewer:
	gtkwave $(NAME_TOP).vcd &

# iverilog help, command line
help:
	man iverilog

#----- Cleanup
# Delete temporary files
clean:
	rm -f $(NAME_TOP).log
	rm -f $(NAME_TOP).vvp
	rm -f $(NAME_TOP).vcd
