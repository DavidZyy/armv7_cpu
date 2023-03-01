/* test bench */
`timescale 1ns / 1ps
module CPU_test ();
    
    reg clk = 0;
    reg rst;
    reg EX_irq = 0;
    
//     wire [31:0] A;
//     wire [31:0] B;
//     wire [31:0] C;
//     wire [31:0] F;
//     wire [3:0] NZCV;
//     wire [7:0] PC;
//     wire Write_PC;
//     wire Write_IR;
//     wire Write_Reg;
//     wire L_A;
//     wire L_B;
//     wire L_C;
//     wire L_F;
//     //wire [1:0] rm_imm_s;
//     //wire [2:0] rs_imm_s;
//     wire [3:0] ALU_OP;
//     wire [2:0] SHIFT_OP;
//     wire S;
//     wire [31:0] IR;
// 
//     wire [6:0] st_cur;
//     wire [1:0] PC_s;
//     wire F_s;
//     wire INT_irq;
//     wire INTA_irq;

    initial begin
    $dumpfile("CPU_test.vcd");        //生成的vcd文件名称
    $dumpvars(0, CPU_test);    //tb模块名称
    end

    always @(*) begin
        #5
        clk <= ~clk;
    end
    initial begin
        rst <= 1;
        #9;
        rst <= 0;
        #400;
        EX_irq <= 1;
        #100000;
        $finish;
    end
    

CPU #(
	.IDLE 		( 6'd63    		),
	.S0   		( 6'd0     		),
	.S1   		( 6'd1     		),
	.S2   		( 6'd2     		),
	.S3   		( 6'd3     		),
	.S7   		( 6'd7     		),
	.S8   		( 6'd8     		),
	.S9   		( 6'd9     		),
	.S10  		( 6'd10    		),
	.S11  		( 6'd11    		),
	.S26  		( 6'd26    		),
	.S27  		( 6'd27    		),
	.S28  		( 6'd28    		),
	.S29  		( 6'd29    		),
	.S30  		( 6'd30    		),
	.S31  		( 6'd31    		),
	.M    		( 5'b10000 		),
	.R14  		( 4'he     		))
u_CPU(
	//ports
	.clk    		( clk    		),
	.rst    		( rst    		),
	.EX_irq 		( EX_irq 		)
);

endmodule