`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/13 11:51:46
// Design Name: 
// Module Name: tb_block_alu_acc
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


module tb_block_alu_acc();

    reg clk, reset_p, acc_high_reset_p;
    reg rd_en, acc_in_select;
    reg [1:0] acc_high_select, acc_low_select; // acc의 mode를 선택
    reg op_add, op_sub, op_mul, op_div, op_and;
    reg [3:0] bus_data, bus_reg_data;
    wire sign_flag, zero_flag;
    wire [7:0] acc_data; // 최종적인 연산의 결과 / 얘는 BUS로만 간다.(상위 4bit, 하위 4bit)
    
    block_alu_acc DUT(
        clk, reset_p, acc_high_reset_p,
        rd_en, acc_in_select,
        acc_high_select, acc_low_select, // acc의 mode를 선택
        op_add, op_sub, op_mul, op_div, op_and,
        bus_data, bus_reg_data,
        sign_flag, zero_flag,
        acc_data // 최종적인 연산의 결과 / 얘는 BUS로만 간다.(상위 4bit, 하위 4bit)
        );
        
    initial begin
        clk = 0;
        reset_p = 1;
        rd_en = 1;
        acc_high_reset_p = 0;
        acc_in_select = 0;
        bus_data = 4'b0111; bus_reg_data = 4'b0010; // 2에 7을 곱하자.
        acc_high_select = 0; acc_low_select = 0;
        op_add = 0; op_sub = 0; op_mul = 0; op_div = 0; op_and = 0;
    end
    
    always #4 clk = ~clk;
    
    
//    // 곱셈(mul)
//    initial begin
//        #8;
//        reset_p = 0; #8;
        
//        // BUS의 data를 high에 넣고 low에서 로드한 뒤, high 클리어
//        acc_in_select = 1; // BREG 값 로드
//        acc_high_select = 2'b11; #8; // high에 로드.
//        acc_in_select = 0; acc_high_select = 2'b00; // 값 받았으면, 꺼주고
//        acc_low_select = 2'b11; #8; // high 값을 low로 보내주고
//        acc_low_select = 2'b00; // 값 받았으면 꺼준다.
//        acc_high_reset_p = 1; #8; // 상위 4bit만 리셋하고 한 클락 보냄
//        acc_high_reset_p = 0;
        
//        // 곱셉 시작(곱셈은 더하기 + 우시프트의 연속)
//        op_mul = 1; #8; // 더하기
//        // op_mul = 1이면, acc_high_select_mul_div에 2'b11이 들어간다.
//        // ALU에서 더한 결과가 ACC로 전달된다.
//        op_mul = 0; acc_low_select = 2'b01; acc_high_select = 2'b01; #8; // 우시프트
        
//        op_mul = 1; acc_low_select = 2'b00; #8; // 더하기 / 또 밀리면 안 되니까, 데이터 유지 모드
//        op_mul = 0; acc_low_select = 2'b01; acc_high_select = 2'b01; #8; // 우시프트
        
//        op_mul = 1; acc_low_select = 2'b00; #8; // 더하기 / 또 밀리면 안 되니까, 데이터 유지 모드
//        op_mul = 0; acc_low_select = 2'b01; acc_high_select = 2'b01; #8; // 우시프트
        
//        op_mul = 1; acc_low_select = 2'b00; #8; // 더하기 / 또 밀리면 안 되니까, 데이터 유지 모드
//        op_mul = 0; acc_low_select = 2'b01; acc_high_select = 2'b01; #8; // 우시프트
        
//        acc_low_select = 2'b00; acc_high_select = 2'b00; #8; // 다 0줘서 데이터 유지
//        $stop;
//    end

    // 나눗셈(얖)
    initial begin
        #8;
        reset_p = 0; #8;
        
        // BUS의 data를 high에 넣고 low에서 로드한 뒤, high 클리어
        acc_in_select = 1; // BREG 값 로드
        acc_high_select = 2'b11; #8; // high에 로드.
        acc_in_select = 0; acc_high_select = 2'b00; // 값 받았으면, 꺼주고
        acc_low_select = 2'b11; #8; // high 값을 low로 보내주고
        acc_low_select = 2'b00; // 값 받았으면 꺼준다.
        acc_high_reset_p = 1; #8; // 상위 4bit만 리셋하고 한 클락 보냄
        acc_high_reset_p = 0;
        // 여기까지 ACC : 0000 0111, BREG : 0010
        
        // 나눗셈 시작
        // 좌시프트 + 뺴기의 연속
        // 빼기는 acc_high_data - bus_reg_data 이 것의 뺄셈이 가능한 지 불가능한 지 여부에 따라 결정한다.
        // 뺀 결과가 음수가 나온다는 것이 뺴기가 불가능하다는 의미.
        acc_low_select = 2'b10; acc_high_select = 2'b10; #8;// 좌시프트 먼저 하고
        // 여기까지 ACC : 0000 1110, BREG : 0010
        acc_low_select = 2'b00; // 값 받았으니 꺼주고
        op_div = 1; #8; // 0000 - 0010 하면, 뺼셈이 불가능하므로 cout = 0이고, 데이터 유지
        // 뺼 수 있으면, carry_flag = cout = 1 / 뺼 수 없으면, carry가 발생하고, cout = 0
        // 여기까지 ACC : 0000 1110, BREG : 0010
        
        op_div = 0; // 시프트하기전에 op_div 꺼주고
        acc_low_select = 2'b10; acc_high_select = 2'b10; #8;// 좌시프트 먼저 하고
        // 여기까지 ACC : 0001 1100, BREG : 0010
        acc_low_select = 2'b00; // 값 받았으니 꺼주고
        op_div = 1; #8; // 0001 - 0010 하면, 뺼셈이 불가능하므로 cout = 0이고, 데이터 유지
        // 여기까지 ACC : 0001 1100, BREG : 0010
        
        op_div = 0; // 시프트하기전에 op_div 꺼주고
        acc_low_select = 2'b10; acc_high_select = 2'b10; #8;// 좌시프트 먼저 하고
        // 여기까지 ACC : 0011 1000, BREG : 0010
        acc_low_select = 2'b00; // 값 받았으니 꺼주고
        op_div = 1; #8; // 0011 - 0010 하면, 뺼셈이 가능하므로 cout = 1이므로 빼고 그 값을 로드
        // 여기까지 ACC : 0001 1000, BREG : 0010
        
        op_div = 0; // 시프트하기전에 op_div 꺼주고
        acc_low_select = 2'b10; acc_high_select = 2'b10; #8;// 좌시프트 먼저 하고
        // 여기까지 ACC : 0011 0001, BREG : 0010
        acc_low_select = 2'b00; // 값 받았으니 꺼주고
        op_div = 1; #8; // 0011 - 0010 하면, 뺼셈이 가능하므로 cout = 1이므로 빼고 그 값을 로드
        // 여기까지 ACC : 0001 0001, BREG : 0010
        
        op_div = 0; // 시프트하기전에 op_div 꺼주고
        acc_low_select = 2'b10; acc_high_select = 2'b00; #8; // acc_low만 좌시프트 한 번 해준다.
        // 여기까지 ACC : 0001 0011, BREG : 0010
        acc_low_select = 2'b00; #8;
        $stop;
    end
endmodule
