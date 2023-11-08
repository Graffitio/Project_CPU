`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/16 16:03:48
// Design Name: 
// Module Name: tb_processor
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


module tb_processor();

    reg clk, reset_p;
    reg [3:0] key_value;
    reg key_valid;
    wire [7:0] outreg_data;
    wire [3:0] kout; // key로 입력된 값을 출력(프로세스가 키 값을 제대로 받는 지 확인하기 위한 것)
    
    processor DUT(clk, reset_p, key_value, key_valid, outreg_data, kout);
    
    // 초기화(입력만 초기화 해준다.)
    initial begin
        clk = 0;
        reset_p = 1;
        key_value = 0;
        key_valid = 0;
    end
    
    // clock
    always #4 clk = ~clk;
    
    // 3 + 2 = 5 를 시뮬레이션해보자.
    initial begin
        #8;
        reset_p = 0; #8; // 리셋 풀어주고
        
        key_value = 3; key_valid = 1; #10_000; // 키 입력은 오래 걸리니까 길게 주자.
        key_value = 0; key_valid = 0; #10_000; // 값 받았으면 ,리셋
        
        key_value = 10; key_valid = 1; #10_000; // 더하기를 a로 설정했으니, 10을 넣어준다.
        key_value = 0; key_valid = 0; #10_000; // 값 받았으면 ,리셋
        
        key_value = 2; key_valid = 1; #10_000; // 키 입력은 오래 걸리니까 길게 주자.
        key_value = 0; key_valid = 0; #10_000; // 값 받았으면 ,리셋        
        
        key_value = 4'b1111; key_valid = 1; #10_000; // 더하기를 a로 설정했으니, 10을 넣어준다.
        key_value = 0; key_valid = 0; #10_000; // 값 받았으면 ,리셋
        $stop;
    end
    
endmodule
