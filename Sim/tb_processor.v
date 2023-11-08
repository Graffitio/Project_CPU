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
    wire [3:0] kout; // key�� �Էµ� ���� ���(���μ����� Ű ���� ����� �޴� �� Ȯ���ϱ� ���� ��)
    
    processor DUT(clk, reset_p, key_value, key_valid, outreg_data, kout);
    
    // �ʱ�ȭ(�Է¸� �ʱ�ȭ ���ش�.)
    initial begin
        clk = 0;
        reset_p = 1;
        key_value = 0;
        key_valid = 0;
    end
    
    // clock
    always #4 clk = ~clk;
    
    // 3 + 2 = 5 �� �ùķ��̼��غ���.
    initial begin
        #8;
        reset_p = 0; #8; // ���� Ǯ���ְ�
        
        key_value = 3; key_valid = 1; #10_000; // Ű �Է��� ���� �ɸ��ϱ� ��� ����.
        key_value = 0; key_valid = 0; #10_000; // �� �޾����� ,����
        
        key_value = 10; key_valid = 1; #10_000; // ���ϱ⸦ a�� ����������, 10�� �־��ش�.
        key_value = 0; key_valid = 0; #10_000; // �� �޾����� ,����
        
        key_value = 2; key_valid = 1; #10_000; // Ű �Է��� ���� �ɸ��ϱ� ��� ����.
        key_value = 0; key_valid = 0; #10_000; // �� �޾����� ,����        
        
        key_value = 4'b1111; key_valid = 1; #10_000; // ���ϱ⸦ a�� ����������, 10�� �־��ش�.
        key_value = 0; key_valid = 0; #10_000; // �� �޾����� ,����
        $stop;
    end
    
endmodule
