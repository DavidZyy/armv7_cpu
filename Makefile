run:
	iverilog ./CPU_test.v -y . -o CPU_test
	vvp -n CPU_test -vcd

wave:
	gtkwave CPU_test.vcd 