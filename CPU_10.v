//在实现分支跳转指令的基础上修改，实现了中断返回
module CPU_10(
    input clk, 
    input rst, 
    input EX_irq

    // output Shift_Out, W_Data, NZCV, PC, Write_PC, Write_IR, Write_Reg, L_A, L_B, L_C, L_F, ALU_OP, SHIFT_OP, 
    // S, st_cur, PC_s, F_s, INT_irq, INTA_irq
    );

    //to accept the signal of icc
    wire CPSR_7 = 0;
    reg INTA_irq;
    wire INT_irq;

    //to accept the signal of state register
    reg W_SPSR_s;
    reg [2:0] W_CPSR_s;
    reg Write_SPSR;
    reg Write_CPSR;
    wire [31:0] SPSR_New;
    wire [31:0] CPSR_New;
    wire [3:0] MASK;
    //wire [3:0] NZCV;
    reg [2:0] Change_M;
    //wire S;
    
    wire [31:0] SPSR_fiq;
    wire [31:0] SPSR_irq;
    wire [31:0] SPSR_abt;
    wire [31:0] SPSR_svc;
    wire [31:0] SPSR_und;
    wire [31:0] SPSR_mon;
    wire [31:0] SPSR_hyp;
    wire [31:0] CPSR;

    // to accept the signal of dual stack pointer
    reg SP_in;
    reg SP_out;
    wire [31:0] SP;
    wire [31:0] SP_tmp;
    wire [31:0] PSP;
    wire [31:0] MSP;
    //wire [4:0] M;

    //寄存器信号
    wire [31:0] R_Data_rn;
    wire [31:0] R_Data_rm;
    wire [31:0] R_Data_rs;
    wire [31:0] W_Data;
    wire [3:0] R_Addr_rn;
    wire [3:0] R_Addr_rm;
    wire [3:0] R_Addr_rs;
    wire [3:0] W_Addr_rd;
    wire [3:0] W_Addr;

    /* 暂存器 temporary register */
    reg [31:0] F;
    reg [31:0] A;
    reg [31:0] B;
    reg [31:0] C;
    
    //NZCV
    reg [3:0] NZCV;
    wire [3:0] NZCV_temp;//存储ALU输出的NZCV信号，根据S信号选择是否打入NZCV中
    
    //barrel_shift信号
    wire [31:0] Shift_Data;
    wire [7:0] Shift_Num;
    reg [2:0] SHIFT_OP;
    wire [31:0] Shift_Out;
    wire [31:0] Shift_Carry_Out;

    //ALU信号
    wire [31:0] ALU_A;
    wire [31:0] ALU_B;
    wire [31:0] ALU_Out;
    reg [3:0] ALU_OP;

   //控制信号
    reg Write_PC;
    reg Write_IR;
    reg Write_Reg;
    reg ALU_A_s;
    reg ALU_B_s;
    reg [1:0]PC_s;
    reg W_Addr_s;
    reg L_A;
    reg L_B;
    reg L_C;
    reg L_F;
    reg [1:0] rm_imm_s;
    reg [2:0] rs_imm_s;
    wire [3:0] OP_Code;
    reg Und_ins;//译码失败标识，译码失败时为1
    reg S;//NZCV打入控制信号

    //new added control signal
    reg F_s = 0;//if 0 ,alu_out -> F, if 1 pc -> F


    //指令相关信号
    wire [31:0] IR;//来自指令寄存器的内容
    wire IR_Flag;//取指令成功的标志，成功时取1
    wire [7:0] PC;

    //立即数
    wire [4:0]imm5;
    wire [11:0]imm12;
    wire [23:0]imm24;

    //下一个状态和当前状态寄存器
    reg [6:0] st_next ;
    reg [6:0] st_cur ;

    //定义状态
    parameter IDLE = 6'd63;
    parameter S0 = 6'd0;
    //parameter Wait = 4'd1;
    parameter S1 = 6'd1;
    parameter S2 = 6'd2;
    parameter S3 = 6'd3;
    /********新增加7~11这5个阶段********/
    parameter S7 = 6'd7;
    parameter S8 = 6'd8;
    parameter S9 = 6'd9;
    parameter S10 = 6'd10;
    parameter S11 = 6'd11;
    /********中断新增**************/
    parameter S26 = 6'd26;
    parameter S27 = 6'd27;
    parameter S28 = 6'd28;
    parameter S29 = 6'd29;
    parameter S30 = 6'd30;
    parameter S31 = 6'd31;

    parameter M = 5'b10000;//寄存器使能
    parameter R14 = 4'he;//R14寄存器地址
    //指令类型，根据指令的类型决定cpu的状态转化，目前有4种类型：
    //0表示：数据处理指令：S0->S1->S2->S3->S0
    //1表示：BX指令：S0->S1->S7
    //2表示：B指令：S0->S8->S9->S0
    //3表示：BL指令：S0->S10->S11->S9->S0
    reg [2:0] Instruction_Type = 4'd0;


    //指令译码
    assign OP_Code[3:0] = IR[24:21];
    assign R_Addr_rn = IR[19:16];
    assign W_Addr_rd = IR[15:12];
    assign R_Addr_rs = IR[11:8];
    //assign SHIFT_OP = IR[6:4];//SHIFT
    assign R_Addr_rm = IR[3:0];
    assign imm12 = IR[11:0];
    assign imm5 = IR[11:7];
    assign imm24 = IR[23:0];
    /*********新增指令译码（单数据访存）*********/
    assign W_Addr_rt = IR[15:12];


/**********读取寄存器数据****************/
    //assign R_Addr_rm = 4'b0001;
    //assign R_Addr_rs = 4'b0000;
/******************************************/


    //多路选择器
    assign ALU_A = ALU_A_s? {24'h000000,PC} : A;
    assign ALU_B = ALU_B_s? {6'b000000,imm24,2'b00} : Shift_Out;
    assign Shift_Data = rm_imm_s? {24'h000000,imm12[7:0]} : B;
    assign Shift_Num = rs_imm_s[1]? {3'b000,imm12[11:8],1'b0} : rs_imm_s[0]? C[7:0] : {3'b000,imm5};
    assign W_Addr = W_Addr_s? R14 : W_Addr_rd;
    assign W_Data = F;

    reg [2:0]testflag;

    //下跳沿IR读入指令后，判断指令的类型
    always @(*) begin
            if(IR[27:4] == 24'b000100101111111111110001)//0001 0010 1111 1111 1111 0001
            begin
                Instruction_Type <= 4'd1;//BX指令
                testflag <= 1;
            end
            else if(IR[27:24] == 4'b1010)
            begin
                Instruction_Type <= 4'd2;//B指令，bcc的24到27也是这个1010
            end
            else if (IR[27:24] == 4'b1011) 
            begin
                Instruction_Type <= 4'd3;//BL指令
            end
            else if(IR == 32'he1bef000)//识别唯一的MOVS指令，想不到其他方法和DP0区分e1bef000put before the IR[27:25] == 3'b000(next), or it will be 0(Instructin_type)
            begin
                Instruction_Type <= 4'd4;//MOVS中断返回指令，注意和普通的DP0格式区分
            end
            else if (IR[27:25] == 3'b000)
            begin
                Instruction_Type <= 4'd0;//数据处理指令
            end
            else if(IR[27:25] == 3'b001)
            begin
                Instruction_Type <= 4'd0;//数据处理指令
            end
            
            else
            begin
                Instruction_Type <= 4'd7;
            end
    end

    //状态转换
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            //状态初始化
            st_cur <= IDLE;
        end
        else begin
            st_cur <= st_next;
        end
    end

    //次态函数
    always @(*) begin
        case(st_cur)
            IDLE:begin
                st_next = S0;
            end
            S0:begin
                //st_next = Wait;
                if(IR_Flag && Und_ins == 1'b0) begin//cond条件成立
                    case (Instruction_Type)
                        
                        4'd0: begin
                            st_next = S1;//数据处理指令
                        end
                        4'd1: begin
                            st_next = S1;//BX指令
                        end
                        4'd2: begin
                            st_next = S8;//B指令
                        end
                        4'd3: begin
                            st_next = S10;//BL指令
                        end 
                        4'd4: begin
                            st_next = S1;//MOVS
                        end
                    endcase
                end
                else begin
                    st_next = S0;
                end        
            end
            /*Wait: begin
                if(IR_Flag && Und_ins == 1'b0) begin//cond条件成立
                    case (Instruction_Type)
                        
                        4'd0: begin
                            st_next = S1;//数据处理指令
                        end
                        4'd1: begin
                            st_next = S1;//BX指令
                        end
                        4'd2: begin
                            st_next = S8;//B指令
                        end
                        4'd3: begin
                            st_next = S10;//BL指令
                        end 
                    endcase
                end
                else begin
                    st_next = S0;
                end
            end*/
            S1:begin
                if(!Und_ins)//译码成功
                    case (Instruction_Type)
                        4'd1: st_next = S7;//BX指令
                        4'd4: st_next = S28;//MOVS instruct (interrupt return)
                        default: st_next = S2;
                    endcase
                else
                    st_next = S0;
            end
            S2:begin
                st_next = S3;
            end
            S3:begin
                st_next = S29;
            end
            S7: begin
                st_next = IDLE;
            end 
            S8: begin
                st_next = S9;
            end 
            S9: begin
                st_next = S29;
            end 
            S10: begin
                st_next = S11;
            end 
            S11: begin
                st_next = S9;
            end 
            S29: begin
                if(INT_irq == 1'b1 && CPSR_7 == 1'b0) //interrupt occur
                    st_next = S30;
                else
                    st_next = S0;
            end//I forget this "end" and get an error,but it reports at line 322 and line 600,it costs lots of my time to find it, SHIT VIVADO!!! 
            S30: begin
                st_next = S31;
            end
            S31: begin
                st_next = S27;
            end
            S27: begin
                st_next = S0;
            end
            S28: begin
                st_next = S26;
            end
            S26: begin
                st_next = S27;
            end
        endcase
    end

    //输出函数
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            //所有控制信号初始化
            NZCV <= 0;
            Write_PC <= 0;
            Write_IR <= 0;
            Write_Reg <= 0;
            L_A <= 0;
            L_C <= 0;
            L_B <= 0;
            L_F <= 0;
            ALU_A_s <= 0;
            ALU_B_s <= 0;
            PC_s <= 0;
            W_Addr_s <= 0;
            rm_imm_s <= 0;
            rs_imm_s <= 0;
            SHIFT_OP <= 0;
            ALU_OP <= 0;
        end
        else begin
            //修改Write_IR
            //只在S0状态下Write_IR。其他状态为0。
            case(st_next)
            /*S0,S7,S9: begin
                Write_IR <= 1;  //原代码
            end*/
            S0: begin
                Write_IR <= 1;
            end
            default:begin
                Write_IR <= 0;
            end
            endcase
    
            //修改Write_PC
            //在S0,S7,S9状态下Write_PC = 1,。其他状态为0。
            case(st_next)
            S0,S7,S9: begin
                Write_PC <= 1;
            end
            default:begin
                Write_PC <= 0;
            end
            endcase

            //修改Write_Reg
            //只在S3状态下Write_Reg = 1,。其他状态为0。
            case(st_next)
            S3,S11: begin
                Write_Reg <= 1;
            end
            default:begin
                Write_Reg <= 0;
            end
            endcase

            //修改L_A,L_B,L_C,L_F,寄存器控制信号
            case(st_next)
            S1: begin
                L_A <= 1'b1;
            end
            S2,S8,S10,S11: begin
                L_F <= 1'b1;
            end
            default:begin
                L_A <= 1'b0;
                L_B <= 1'b0;
                L_C <= 1'b0;
                L_F <= 1'b0;
            end
            endcase


            //修改ALU_A_s,ALU_B_s;ALU输入控制信号
            case(st_next)
                S8,S11: begin//PC+imm24→F
                    ALU_A_s <= 1'b1;
                    ALU_B_s <= 1'b1;
                end
                S10: begin//PC→F
                    ALU_A_s <= 1'b1;
                    ALU_B_s <= 1'b0;
                end
                default:begin//A+B→F
                    ALU_A_s <= 1'b0;
                    ALU_B_s <= 1'b0;
                end
            endcase

            //修改PC_s;PC控制信号
            case(st_next)
                S0: begin//取指令时不修改PC_s
                    PC_s <= 0;
                end
                S7: begin//B→PC
                    PC_s <= 2'b01;
                end
                S9: begin//F→PC
                    PC_s <= 2'b10;
                end
                default:begin//PC+4→PC
                    PC_s <= 2'b00;
                end
            endcase

            //修改W_Addr_s;W_Addr控制信号
            case(st_next)
                S11: begin//F->Reg[14]
                    W_Addr_s <= 1'b1;
                end
                default:begin
                    W_Addr_s <= 1'b0;
                end
            endcase

            //函数处理
            case(st_next)
            S0: begin
                //reset S27' signal
                SP_in <= 0;
                //reset S29's signal
                F_s <= 0;
                L_F <= 0;


                Und_ins <= 0;
            end
            S1: begin//s1时译码并读取寄存器内容
                if(Instruction_Type == 4'd1)begin
                    L_B <= 1;//B→PC
                end
                if(IR[27:25] == 3'b000 && IR[4] == 0 && IR[15:12] != 4'b1111) begin //Dp0格式
                    rm_imm_s <= 1'b0;
                    rs_imm_s <= 2'b00;
                    L_B <= 1;
                    L_C <= 0;
                end
                else if(IR[27:25] == 3'b000 && IR[7] == 0 && IR[4] == 1 && IR[15:12] != 4'b1111) begin //Dp1格式
                    rm_imm_s <= 1'b0;
                    rs_imm_s <= 2'b01;
                    L_B <= 1;
                    L_C <= 1;
                end
                else if(IR[27:25] == 3'b001 && IR[15:12] != 4'b1111)begin //Dp2格式
                    rm_imm_s <= 1'b1;
                    rs_imm_s <= 2'b10;
                    L_B <= 0;
                    L_C <= 0;
                end
                else begin
                    //Und_ins <= 1;
                end
            end
            S2: begin//s2时对译码内容进行运处理，输入到组合运算器中
                case(OP_Code)//通过OPCODE获取ALU_OP
                    4'b0000: ALU_OP <= 4'b0000;
                    4'b0001: ALU_OP <= 4'b0001;
                    4'b0010: ALU_OP <= 4'b0010;
                    4'b0011: ALU_OP <= 4'b0011;
                    4'b0100: ALU_OP <= 4'b0100;
                    4'b0101: ALU_OP <= 4'b0101;
                    4'b0110: ALU_OP <= 4'b0110;
                    4'b0111: ALU_OP <= 4'b0111;
                    4'b1000: ALU_OP <= 4'b0000;
                    4'b1001: ALU_OP <= 4'b0001;
                    4'b1010: ALU_OP <= 4'b0010;
                    4'b1011: ALU_OP <= 4'b0100;
                    4'b1100: ALU_OP <= 4'b1100;
                    4'b1101: ALU_OP <= 4'b1101;
                    4'b1110: ALU_OP <= 4'b1110;
                    4'b1111: ALU_OP <= 4'b1111;
                endcase
                S <= IR[20];
                case (rs_imm_s)//获取Shift相关信号
                    2'b00:begin
                        SHIFT_OP <= IR[6:4];
                    end 
                    2'b01:begin
                        SHIFT_OP <= IR[6:4];
                    end
                    2'b10:begin
                        SHIFT_OP <= 3'b111;
                    end
                endcase
            end

            S3:begin//s3将F结果打入W_Data,修改NZCV
                if(S) begin
                    NZCV <= NZCV_temp;
                end
            end

            S7: begin//B→PC
                    
                    //已将PC_s和Write_PC信号修改
            end

            S8: begin//PC+Offset→PC
                ALU_OP <= 4'b0100;
                S <= 1'b0;
            end

            S9: begin//F→PC
               //已将PC_s和Write_PC信号修改
            end

            S10: begin//PC→F
                ALU_OP <= 4'b1000;
                S <= 1'b0;
            end
            S11: begin//F->Reg[14],PC+Offset→PC
                ALU_OP <= 4'b0100;
                S <= 0;
            end
            S29: begin
                F_s <= 1'b1;
                L_F <= 1'b1;   
            end
            S30: begin
                //reset the control signal from S29
                F_s <= 1'b0;
                L_F <= 1'b0;
                //f -> lr_irq
                W_Addr_s <= 1'b1;//to be lazy, I write F into "LR" under user mode in the universla register pile
                Write_Reg <= 1'b1;
                //cpsr -> spsr_irq
                Change_M <= 3'd2;
                W_SPSR_s <= 1'b1;
            end
            S31: begin
                //reset the previous state's signal
                W_Addr_s <= 1'b0;
                Write_Reg <= 1'b0;
                Change_M <= 3'd0;
                //92h -> cpsr
                W_CPSR_s <= 3'd2;

                //INTA_irq = 1; have been done in interrupt_control_circuit module
                //irq interrupt vector->pc
                PC_s <= 2'b11;
                Write_PC <= 1'b1;
                //sp->msp/psp
                SP_out <= 1'b1;

                INTA_irq <= 1'b1;
            end
            S27: begin
                //reset the S31's signal
                W_CPSR_s <= 3'd0;
                PC_s <= 2'b00;  
                SP_out <= 1'b0;
                INTA_irq <= 1'b0;
                Write_PC <= 1'b0;
                //reset the S26's signal
                Write_PC <= 1'b0;
                PC_s <= 1'b0;
                Write_CPSR <= 1'b0;
                SP_out <= 1'b0;
                //msp->sp_irq
                SP_in <= 1'b1; 
            end 
            S28: begin
                //a->f
                ALU_OP <= 4'b1000;
                L_F <= 1'b1;

            end
            S26: begin
                //reset the previous state
                L_F <= 1'b0;
                //f->pc
                Write_PC <= 1'b1;
                PC_s <= 2'b10;
                //spsr->cpsr
                Write_CPSR <= 1'b1;
                W_CPSR_s <= 1'b0;
                //sp->msp/psp
                SP_out <= 1'b1;
                
            end
            endcase
        end
    end

    always @(negedge clk) begin
        if(L_A == 1'b1) A <= R_Data_rn;
        if(L_B == 1'b1) B <= R_Data_rm;
        if(L_C == 1'b1) C <= R_Data_rs;
        if(L_F == 1'b1) begin
            if(F_s == 1'b1) begin
                F <= PC; 
            end
            else begin
                F <= ALU_Out;
            end
        end
    end

    IF IF (
        .clk(clk),
        .rst(rst),
        .NZCV(NZCV),
        .Write_IR(Write_IR),
        .Write_PC(Write_PC),
        .B(B),
        .F(F),
        .PC_s(PC_s),

        .IR(IR),
        .IR_Flag(IR_Flag),
        .PC_OUT(PC)
    );

    ALU ALU(.A(ALU_A),
            .B(ALU_B),
            .ALU_OP(ALU_OP),
            .Shift_Carry_Out(Shift_Carry_Out),
            .CF(NZCV[1]),
            .VF(NZCV[0]),
            .F(ALU_Out),
            .NZCV(NZCV_temp)
    );

    barrel_shift bs(.Shift_Data(Shift_Data),
                    .Shift_Num(Shift_Num),
                    .SHIFT_OP(SHIFT_OP),
                    .Carry_flag(NZCV[1]),
                    .Shift_Out(Shift_Out),
                    .Shift_Carry_Out(Shift_Carry_Out)
    );

    REG REG (//universal register file
        .clk(clk),
        .rst(rst),
        .R_Addr_A(R_Addr_rn),
        .R_Addr_B(R_Addr_rm),
        .R_Addr_C(R_Addr_rs),
        .M(5'b10000),
        .W_Addr(W_Addr),
        .W_Data(W_Data),
        .Write_Reg(Write_Reg),
        .R_Data_A(R_Data_rn),
        .R_Data_B(R_Data_rm),
        .R_Data_C(R_Data_rs)
    );

    interrupt_control_circuit module1(
        .clk(clk),
        .rst(rst),
        .CPSR_7(CPSR_7),
        .EX_irq(EX_irq),
        .INTA_irq(INTA_irq),

        .INT_irq(INT_irq)
        
        //.PC_s(PC_s)
    );

    state_register_file module2(
        .clk(clk), 
        .W_SPSR_s(W_SPSR_s),
        .W_CPSR_s(W_CPSR_s),
        .Write_SPSR(Write_SPSR),
        .Write_CPSR(Write_CPSR),
        .SPSR_New(SPSR_New),
        .CPSR_New(CPSR_New),
        .MASK(MASK),
        .NZCV(NZCV),
        .Change_M(Change_M),
        .S(S),

        .SPSR_fiq(SPSR_fiq),
        .SPSR_irq(SPSR_irq),
        .SPSR_abt(SPSR_abt),
        .SPSR_svc(SPSR_svc),
        .SPSR_und(SPSR_und),
        .SPSR_mon(SPSR_mon),
        .SPSR_hyp(SPSR_hyp),
        .CPSR(CPSR)
    );

    dual_stack module3(
        .clk(ckl),
        .SP_in(SP_in),
        .SP_out(SP_out),
        .M(M),
        .SP(SP),

        .SP_tmp(SP_tmp),
        .PSP(PSP),
        .MSP(MSP)
    );
endmodule