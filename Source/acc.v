`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/06 23:10:25
// Design Name: 
// Module Name: acc
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


// 4bit¥�� ACC���� �� �� �̾���ϰ��̴�.
// ������ ��������
module half_acc(
    input clk, reset_p,
    input load_msb, load_lsb, // ����Ʈ�Ͽ� ����ϱ� ���� ����
    input rd_en, // Bus�� �������� ���� ������ Control Block���κ��� �޴� Enable ��ȣ
    input [1:0] s, // mode select
    input [3:0] data_in, // ������ �Է¹��� ����
    output [3:0] data2bus, // BUS�� ��ȣ�� �޾Ƽ� ������ ����� �������� ����, ��ȣ�� ���� ������ ���Ǵ��� ����
    output [3:0] register_data // ������ �ٷιٷ� ������ ����� �������� ����
    );
    
    
    reg [3:0] d;
    always @(*) begin
        case(s)
            2'b00 : d = register_data; // ������ ����
            2'b01 : d = {load_msb, register_data[3:1]}; // �ҷ��� msb�� register_data�� ���� 3bit�� �����Ѵ� -> �����Ʈ(>>), ����
            2'b10 : d = {register_data[2:0], load_lsb}; // �½���Ʈ(<<), ������ 
            2'b11 : d = data_in; // ALU�� BUS�κ��� ���۹��� ������
        endcase // ���ճ�ȸ�ο����� case�� ���� ä��ų� default�� �������� �Ѵ�. �׷��� ������ Latch�� ������� ���� �ִ�
    end
    
    // Half ACC
    register_Nbit_p_alltime #(.N(4)) h_cc(.d(d), .clk(clk), .reset_p(reset_p), .wr_en(1'b1), .rd_en(rd_en), .register_data(register_data), .q(data2bus));
    // ��� ����� register_data, ���� ���(Enable ��ȣ)�� data2bus
    
endmodule


module acc(
    input clk, reset_p, acc_high_reset_p,
    input fill_value, // �� ���� ��Ʈ�� 0���� ä��ų� 1�� ä��
    input rd_en, acc_in_select,
    input [1:0] acc_high_select, acc_low_select, // Half_ACC�� �� ���̹Ƿ� ��������� �Ѵ�.
    input [3:0] bus_data, alu_data, // BUS�� ALU�κ��� �޴� ������
    output [3:0] acc_high_data2bus, acc_high_register_data,
    output [3:0] acc_low_data2bus, acc_low_register_data     
    );
    
    // ACC�� Bus�κ��͵� �����͸� �ް�, ALU�κ��͵� �����͸� �����Ƿ�,
    // ��� ���� ������ �����ϴ� ����� �ʿ��ϴ�.
    wire [3:0] acc_high_data;
    assign acc_high_data = acc_in_select ? bus_data : alu_data;
    
    half_acc acc_high(.clk(clk), .reset_p(reset_p | acc_high_reset_p), .load_msb(fill_value), .load_lsb(acc_low_register_data[3]), .rd_en(rd_en), .s(acc_high_select), // �½���Ʈ�� ���� ���� bit�� �ֻ��� bit�� �ش�
                      .data_in(acc_high_data), // BUS�� ALU�κ��� ���۵� �����͸� acc_high�� �޴´�.
                      .data2bus(acc_high_data2bus), .register_data(acc_high_register_data));
    half_acc acc_low(.clk(clk), .reset_p(reset_p), .load_msb(acc_high_register_data[0]), .load_lsb(fill_value), .rd_en(rd_en), .s(acc_low_select),
                      .data_in(acc_high_register_data), .data2bus(acc_low_data2bus), .register_data(acc_low_register_data));
                      // BUS�� ALU�κ��� Data�� load�� ���� 4bit�� load�ϴµ�,
                      // �� ��, acc_high�� load�� Data 4bit�� �ް� acc_low�� �� �޾�(������ �ִ� �� ����)
                      // ���� ������ ���ؼ� �Ǵ� acc_high�� ���� Data�� �ޱ� ���ؼ� ���� Data�� acc_low�� �Ѱ��� �ʿ䰡 �ִ�.
                      // �׷��� acc_low�� data_in�� acc_high 4bit�� �׳� �״�� ��
    // acc_low�� acc_high�� �ҷ��ͼ� ����.
    // �ҷ��� �� �ҷ��� ���� 4bit�� ������ ������� ��.
    // �ٵ� �׳� ������ ���� �������� �� ������.
    // ���� ���� 4bit�� ���� �������ִ� ����� �ʿ��ϴ�. -> acc_high�� acc_high_reset_p �߰�
    
                          
    
endmodule
