`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/16 10:09:56
// Design Name: 
// Module Name: processor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module processor(
    input clk, reset_p,
    input [3:0] key_value,
    input key_valid,
    output [7:0] outreg_data,
    output [3:0] kout // key로 입력된 값을 출력(프로세스가 키 값을 제대로 받는 지 확인하기 위한 것)
    );
    
    // MAR 
    // -> PC로 BUS로 주소값을 내보내고, BUS로부터 주소값을 받는 메모리 주소 레지스터
    wire [7:0] int_bus_data, mar_data; // internal bus data
    wire mar_inen; // BUS로부터 데이터를 받는 것을 허용
    register_Nbit_p_alltime #(.N(8)) mar(
       .d(int_bus_data), .clk(clk), .reset_p(reset_p), .wr_en(mar_inen), .rd_en(1'b1), .register_data(mar_data));
    // MAR은 상시 출력만 내보내므로, 조건부 출력부는 지워도 됨.
    
    // MDR
    wire [7:0] rom_data;
    wire mdr_oen; // BUS로의 데이터 출력 enable
    register_Nbit_p_alltime #(.N(8)) mdr(
       .d(rom_data), .clk(clk), .reset_p(reset_p), .wr_en(mdr_inen), .rd_en(mdr_oen), .q(int_bus_data));
    // 얘는 버스로 데이터를 출력하는 레지스터이므로, 조건부 출력 사용
    
    // IR
    // 입력된 명령어를 저장하기 위한 레지스터
    wire [7:0] ir_data;
    wire ir_inen;
    register_Nbit_p_alltime #(.N(8)) ir(
        .d(int_bus_data), .clk(clk), .reset_p(reset_p), .wr_en(ir_inen), .rd_en(1'b1), .register_data(ir_data));
    
    // PC
    wire pc_inc, load_pc, pc_oen;
    program_address_counter pc(
        .clk(clk), .reset_p(reset_p), .pc_inc(pc_inc), .load_pc(load_pc), .pc_rd_en(pc_oen), .pc_in(int_bus_data), .pc_out(int_bus_data));
    
    // BREG
    wire breg_inen;
    wire [3:0] bus_reg_data;
    register_Nbit_p_alltime #(.N(8)) breg(
        .d(int_bus_data[7:4]), .clk(clk), .reset_p(reset_p), .wr_en(breg_inen), .rd_en(1'b1), .register_data(bus_reg_data));
    
    // TMPREG
    wire tmpreg_inen, tmpreg_oen;
    register_Nbit_p_alltime #(.N(8)) tmpreg(
        .d(int_bus_data[7:4]), .clk(clk), .reset_p(reset_p), .wr_en(tmpreg_inen), .rd_en(tmpreg_oen), .q(int_bus_data[7:4]));
    
    // CREG
    wire creg_inen, creg_oen;
    register_Nbit_p_alltime #(.N(8)) creg(
        .d(int_bus_data[7:4]), .clk(clk), .reset_p(reset_p), .wr_en(creg_inen), .rd_en(creg_oen), .q(int_bus_data[7:4]));
    
    // DREG
    wire dreg_inen, dreg_oen;
    register_Nbit_p_alltime #(.N(8)) dreg(
        .d(int_bus_data[7:4]), .clk(clk), .reset_p(reset_p), .wr_en(dreg_inen), .rd_en(dreg_oen), .q(int_bus_data[7:4]));    
    
    // RREG
    wire rreg_inen, rreg_oen;
    register_Nbit_p_alltime #(.N(8)) rreg
        (.d(int_bus_data[7:4]), .clk(clk), .reset_p(reset_p), .wr_en(rreg_inen), .rd_en(rreg_oen), .q(int_bus_data[7:4]));
       
    // ALU & ACC
    wire acc_oen, acc_high_reset_p, acc_in_select;
    wire [1:0] acc_high_select, acc_low_select;
    wire op_add, op_sub, op_mul, op_div, op_and;
    wire sign_flag, zero_flag;   
    block_alu_acc alu_acc(
         .clk(clk), .reset_p(reset_p), .acc_high_reset_p(acc_high_reset_p), .rd_en(acc_oen), .acc_in_select(acc_in_select),
         .acc_high_select(acc_high_select), .acc_low_select(acc_low_select), // acc의 mode를 선택
         .op_add(op_add), .op_sub(op_sub), .op_mul(op_mul), .op_div(op_div), .op_and(op_and),
         .bus_data(int_bus_data[7:4]), .bus_reg_data(bus_reg_data),
         .sign_flag(sign_flag), .zero_flag(zero_flag),
         .acc_data(int_bus_data) // 최종적인 연산의 결과 / 얘는 BUS로만 간다.(상위 4bit, 하위 4bit)
         );
    
    // key 입력받을 레지스터
    wire inreg_oen;
    register_Nbit_p_alltime #(.N(4)) inreg(
        .d(key_value), .clk(clk), .reset_p(reset_p), .wr_en(1'b1), .rd_en(inreg_oen), .q(int_bus_data[7:4]));
    
    // 키 값이 입력되었는지 체크하는 레지스터
    wire keych_reg_oen;
    register_Nbit_p_alltime #(.N(4)) keych_reg( // key change
        .d({4{key_valid}}), .clk(clk), .reset_p(reset_p), .wr_en(1'b1), .rd_en(keych_reg_oen), .q(int_bus_data[7:4]));
        // {4{key_valid}} = {key_valid, key_valid, key_valid, key_valid}
    
    // 키 값이 제대로 CPU로 입력되었는지, FND 확인하기 위한 레지스터
    wire keyout_reg_inen;
    register_Nbit_p_alltime #(.N(4)) keyout_reg( // key change
        .d(int_bus_data[7:4]), .clk(clk), .reset_p(reset_p), .wr_en(keyout_reg_inen), .rd_en(1'b1), .register_data(kout));              
    
    // 최종 출력을 위한 레지스터
    wire outreg_inen;
    register_Nbit_p_alltime #(.N(8)) outreg(
        .d(int_bus_data), .clk(clk), .reset_p(reset_p), .wr_en(outreg_inen), .rd_en(1'b1), .register_data(outreg_data));
        
    // ROM
    wire rom_en;
    dist_mem_gen_0 rom(.a(mar_data), .qspo_ce(rom_en), .spo(rom_data));
    // MAR로부터 주소를 입력받고, 그 주소에 해당되는 명령어를 MDR로 보낸다.
    
    // Control_block
//    control_block c_block( // 변수명 그대로 썼으므로, 따로 지정해주지 않아도 된다.
//        clk, reset_p, ir_data, zero_flag, sign_flag,
//        mar_inen, mdr_inen, mdr_oen, ir_inen, pc_inc, load_pc, pc_oen,
//        breg_inen, tmpreg_inen, tmpreg_oen, creg_inen, creg_oen,
//        dreg_inen, dreg_oen, rreg_inen, rreg_oen,
//        acc_high_reset_p, acc_oen, acc_in_select,
//        op_add, op_sub, op_mul, op_div, op_and,
//        inreg_oen, keych_reg_oen, keyout_reg_inen, outreg_inen, rom_en,
//        acc_high_select, acc_low_select
//        );
        
    control_block c_block( // 변수명 그대로 썼으므로, 따로 지정해주지 않아도 된다.
        .clk(clk), .reset_p(reset_p), .ir_data(ir_data), .zero_flag(zero_flag), .sign_flag(sign_flag),
        .mar_inen(mar_inen), .mdr_inen(mdr_inen), .mdr_oen(mdr_oen), .ir_inen(ir_inen), .pc_inc(pc_inc), .load_pc(load_pc), .pc_oen(pc_oen),
        .breg_inen(breg_inen), .tmpreg_inen(tmpreg_inen), .tmpreg_oen(tmpreg_oen), .creg_inen(creg_inen), .creg_oen(creg_oen),
        .dreg_inen(dreg_inen), .dreg_oen(dreg_oen), .rreg_inen(rreg_inen), .rreg_oen(rreg_oen),
        .acc_high_reset_p(acc_high_reset_p), .acc_oen(acc_oen), .acc_in_select(acc_in_select),
        .op_add(op_add), .op_sub(op_sub), .op_mul(op_mul), .op_div(op_div), .op_and(op_and),
        .inreg_oen(inreg_oen), .keych_reg_oen(keych_reg_oen), .keyout_reg_inen(keyout_reg_inen), .outreg_inen(outreg_inen), .rom_en(rom_en),
        .acc_high_select(acc_high_select), .acc_low_select(acc_low_select)
        );        
            
endmodule


