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
    reg [1:0] acc_high_select, acc_low_select; // acc�� mode�� ����
    reg op_add, op_sub, op_mul, op_div, op_and;
    reg [3:0] bus_data, bus_reg_data;
    wire sign_flag, zero_flag;
    wire [7:0] acc_data; // �������� ������ ��� / ��� BUS�θ� ����.(���� 4bit, ���� 4bit)
    
    block_alu_acc DUT(
        clk, reset_p, acc_high_reset_p,
        rd_en, acc_in_select,
        acc_high_select, acc_low_select, // acc�� mode�� ����
        op_add, op_sub, op_mul, op_div, op_and,
        bus_data, bus_reg_data,
        sign_flag, zero_flag,
        acc_data // �������� ������ ��� / ��� BUS�θ� ����.(���� 4bit, ���� 4bit)
        );
        
    initial begin
        clk = 0;
        reset_p = 1;
        rd_en = 1;
        acc_high_reset_p = 0;
        acc_in_select = 0;
        bus_data = 4'b0111; bus_reg_data = 4'b0010; // 2�� 7�� ������.
        acc_high_select = 0; acc_low_select = 0;
        op_add = 0; op_sub = 0; op_mul = 0; op_div = 0; op_and = 0;
    end
    
    always #4 clk = ~clk;
    
    
//    // ����(mul)
//    initial begin
//        #8;
//        reset_p = 0; #8;
        
//        // BUS�� data�� high�� �ְ� low���� �ε��� ��, high Ŭ����
//        acc_in_select = 1; // BREG �� �ε�
//        acc_high_select = 2'b11; #8; // high�� �ε�.
//        acc_in_select = 0; acc_high_select = 2'b00; // �� �޾�����, ���ְ�
//        acc_low_select = 2'b11; #8; // high ���� low�� �����ְ�
//        acc_low_select = 2'b00; // �� �޾����� ���ش�.
//        acc_high_reset_p = 1; #8; // ���� 4bit�� �����ϰ� �� Ŭ�� ����
//        acc_high_reset_p = 0;
        
//        // ���� ����(������ ���ϱ� + �����Ʈ�� ����)
//        op_mul = 1; #8; // ���ϱ�
//        // op_mul = 1�̸�, acc_high_select_mul_div�� 2'b11�� ����.
//        // ALU���� ���� ����� ACC�� ���޵ȴ�.
//        op_mul = 0; acc_low_select = 2'b01; acc_high_select = 2'b01; #8; // �����Ʈ
        
//        op_mul = 1; acc_low_select = 2'b00; #8; // ���ϱ� / �� �и��� �� �Ǵϱ�, ������ ���� ���
//        op_mul = 0; acc_low_select = 2'b01; acc_high_select = 2'b01; #8; // �����Ʈ
        
//        op_mul = 1; acc_low_select = 2'b00; #8; // ���ϱ� / �� �и��� �� �Ǵϱ�, ������ ���� ���
//        op_mul = 0; acc_low_select = 2'b01; acc_high_select = 2'b01; #8; // �����Ʈ
        
//        op_mul = 1; acc_low_select = 2'b00; #8; // ���ϱ� / �� �и��� �� �Ǵϱ�, ������ ���� ���
//        op_mul = 0; acc_low_select = 2'b01; acc_high_select = 2'b01; #8; // �����Ʈ
        
//        acc_low_select = 2'b00; acc_high_select = 2'b00; #8; // �� 0�༭ ������ ����
//        $stop;
//    end

    // ������(�A)
    initial begin
        #8;
        reset_p = 0; #8;
        
        // BUS�� data�� high�� �ְ� low���� �ε��� ��, high Ŭ����
        acc_in_select = 1; // BREG �� �ε�
        acc_high_select = 2'b11; #8; // high�� �ε�.
        acc_in_select = 0; acc_high_select = 2'b00; // �� �޾�����, ���ְ�
        acc_low_select = 2'b11; #8; // high ���� low�� �����ְ�
        acc_low_select = 2'b00; // �� �޾����� ���ش�.
        acc_high_reset_p = 1; #8; // ���� 4bit�� �����ϰ� �� Ŭ�� ����
        acc_high_reset_p = 0;
        // ������� ACC : 0000 0111, BREG : 0010
        
        // ������ ����
        // �½���Ʈ + ������ ����
        // ����� acc_high_data - bus_reg_data �� ���� ������ ������ �� �Ұ����� �� ���ο� ���� �����Ѵ�.
        // �� ����� ������ ���´ٴ� ���� ���Ⱑ �Ұ����ϴٴ� �ǹ�.
        acc_low_select = 2'b10; acc_high_select = 2'b10; #8;// �½���Ʈ ���� �ϰ�
        // ������� ACC : 0000 1110, BREG : 0010
        acc_low_select = 2'b00; // �� �޾����� ���ְ�
        op_div = 1; #8; // 0000 - 0010 �ϸ�, �E���� �Ұ����ϹǷ� cout = 0�̰�, ������ ����
        // �E �� ������, carry_flag = cout = 1 / �E �� ������, carry�� �߻��ϰ�, cout = 0
        // ������� ACC : 0000 1110, BREG : 0010
        
        op_div = 0; // ����Ʈ�ϱ����� op_div ���ְ�
        acc_low_select = 2'b10; acc_high_select = 2'b10; #8;// �½���Ʈ ���� �ϰ�
        // ������� ACC : 0001 1100, BREG : 0010
        acc_low_select = 2'b00; // �� �޾����� ���ְ�
        op_div = 1; #8; // 0001 - 0010 �ϸ�, �E���� �Ұ����ϹǷ� cout = 0�̰�, ������ ����
        // ������� ACC : 0001 1100, BREG : 0010
        
        op_div = 0; // ����Ʈ�ϱ����� op_div ���ְ�
        acc_low_select = 2'b10; acc_high_select = 2'b10; #8;// �½���Ʈ ���� �ϰ�
        // ������� ACC : 0011 1000, BREG : 0010
        acc_low_select = 2'b00; // �� �޾����� ���ְ�
        op_div = 1; #8; // 0011 - 0010 �ϸ�, �E���� �����ϹǷ� cout = 1�̹Ƿ� ���� �� ���� �ε�
        // ������� ACC : 0001 1000, BREG : 0010
        
        op_div = 0; // ����Ʈ�ϱ����� op_div ���ְ�
        acc_low_select = 2'b10; acc_high_select = 2'b10; #8;// �½���Ʈ ���� �ϰ�
        // ������� ACC : 0011 0001, BREG : 0010
        acc_low_select = 2'b00; // �� �޾����� ���ְ�
        op_div = 1; #8; // 0011 - 0010 �ϸ�, �E���� �����ϹǷ� cout = 1�̹Ƿ� ���� �� ���� �ε�
        // ������� ACC : 0001 0001, BREG : 0010
        
        op_div = 0; // ����Ʈ�ϱ����� op_div ���ְ�
        acc_low_select = 2'b10; acc_high_select = 2'b00; #8; // acc_low�� �½���Ʈ �� �� ���ش�.
        // ������� ACC : 0001 0011, BREG : 0010
        acc_low_select = 2'b00; #8;
        $stop;
    end
endmodule
