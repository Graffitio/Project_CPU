`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/13 09:26:57
// Design Name: 
// Module Name: tb_acc
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


module tb_acc();
    reg clk, reset_p, acc_high_reset_p;
    reg fill_value; // �� ���� ��Ʈ�� 0���� ä��ų� 1�� ä��
    reg rd_en, acc_in_select;
    reg [1:0] acc_high_select, acc_low_select; // Half_ACC�� �� ���̹Ƿ� ��������� �Ѵ�.
    reg [3:0] bus_data, alu_data; // BUS�� ALU�κ��� �޴� ������
    wire [3:0] acc_high_data2bus, acc_high_register_data;
    wire [3:0] acc_low_data2bus, acc_low_register_data;     
    
    acc DUT(clk, reset_p, acc_high_reset_p, fill_value, rd_en, acc_in_select, acc_high_select, acc_low_select, bus_data, alu_data,
            acc_high_data2bus, acc_high_register_data, acc_low_data2bus, acc_low_register_data);
    
    // ���� �ʱ�ȭ
    initial begin
        clk = 0;
        reset_p = 1;
        acc_high_reset_p = 0;
        fill_value = 0;
        rd_en = 1;
        acc_in_select = 0;
        acc_high_select = 0; // 0�ָ� ���� �� ����
        acc_low_select = 0; // 0�ָ� ���� �� ����
        bus_data = 4'b0101; // 5
        alu_data = 4'b0010; // 2
    end
    
    always #4 clk = ~clk;
    
    initial begin
        #8
        reset_p = 0; #8; // �ʱ�ȭ ��
        
        acc_high_select = 2'b11; #8; // data load
        acc_high_select = 2'b00; #8; // data ����
        
        acc_in_select = 1; acc_high_select = 2'b11; #8;
        acc_high_select = 2'b00; #8;
        
        acc_low_select = 2'b11; #8;
        acc_low_select = 2'b00; #8;
        
        acc_high_select = 2'b01; acc_low_select = 2'b01; #8; // �����Ʈ
        acc_high_select = 2'b00; acc_low_select = 2'b00; #8;
        
        acc_high_select = 2'b10; acc_low_select = 2'b10; #8; // �½���Ʈ
        acc_high_select = 2'b00; acc_low_select = 2'b00; #8;       

        acc_high_select = 2'b10; acc_low_select = 2'b10; #8; // �½���Ʈ
        acc_high_select = 2'b00; acc_low_select = 2'b00; #8;
        
        acc_high_reset_p = 1; #8; // ���� 4bit�� ����           
        
        $stop;
    end
    

endmodule
