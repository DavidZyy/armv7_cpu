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
    CPU_10 CPU_10(
            .clk(clk), 
            .rst(rst),
            .EX_irq(EX_irq)
            // .NZCV(NZCV),
            // .PC(PC),
            // .Write_PC(Write_PC),
            // .Write_IR(Write_IR),
            // .Write_Reg(Write_Reg),
            // .L_A(L_A),
            // .L_B(L_B),
            // .L_C(L_C),
            // .L_F(L_F),
            // //.rm_imm_s(rm_imm_s),
            // //.rs_imm_s(rs_imm_s),
            // .ALU_OP(ALU_OP),
            // .SHIFT_OP(SHIFT_OP),
            // .S(S),
            // .st_cur(st_cur),
            // .PC_s(PC_s),
            // .F_s(F_s),
            // .INT_irq(INT_irq),
            // .INTA_irq(INTA_irq)
    );
endmodule