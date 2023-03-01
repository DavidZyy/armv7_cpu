TEST = CPU_test

run:
	iverilog ./CPU_test.v -y . -o CPU_test
	vvp -n CPU_test -vcd

wave:
	gtkwave CPU_test.vcd 

clean:
	rm CPU_test CPU_test.vcd