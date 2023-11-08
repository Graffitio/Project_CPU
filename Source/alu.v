`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/06 14:07:38
// Design Name: 
// Module Name: alu
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


module alu(
    input clk, reset_p,
    input op_add, op_sub, op_mul, op_div, op_and, // ���꿡 ����� ��ɾ�
    input alu_lsb, // ������ ��Ʈ �Է� �ϳ� �־�� ��
    input [3:0] acc_high_data, // BUS�� ���� �Էµ� ù ���� Data 4bit�� ACC�� ���� -> ALU�� ���� 4bit�� ����
    input [3:0] bus_reg_data, // BUS�� ���� �Էµ� ���� Data 4bit�� BREG�� ���� -> ALU�� ���� 4bit�� ����
    output [3:0] alu_out, // ���� ���  -> ACC�� ����
    // �� ������ ���� flag
    output zero_flag, // ������ ����� 0�̸�, zero flag = 1
    output sign_flag, // ��� ���, ������ �߻��ϸ� sign_flag = 0, ��ȣ(����/���)�� ���� sign flag���� ��������. 
    output carry_flag, // carry�� �߻��ϸ�, carry flag = 1
    output cout // carry_out
    );
    // 8bit�� ALU�� ����ȴ�.
    // ACC�� ����Ǵ� ���� ���� 4bit -> ������ 4bit�θ� �̷������.
    // BREG�� ����Ǵ� ���� ���� 4bit
    // ���� ��� ���� 8bit¥�� CPU���, BUS�� 16bit�� �����Ǿ�� �Ѵ�.
    
    // �������
    // ����ȸ���̹Ƿ�, �Է��� ������ clk�� ������� ����� �ٷ� ��µȴ�.
    wire [3:0] sum;
    fadd_sub_4bit_d fadd_sub(.a(acc_high_data), .b(bus_reg_data),
                             .s(op_sub | op_div), // sub �Ǵ� div ��ɾ �߻����� ���� �ǹ��Ѵ�.
                             .sum(sum), .carry(cout)); // add : s = 0, sub : s = 1 (�������� ������ ����)
                             // ���� ���� ������ alu_out���� ������ �ȴ�.
    
    // AND ����
    assign alu_out = op_and ? (acc_high_data & bus_reg_data) : sum;
    
    // ���� �ӵ� : ���ϱ�� 2 clk, ������� 4 clk �̻�
    // �̷��� ���� alu�� �������, ������, ����Ʈ ����, �� ������� �����ϴ�.
    
    // Zero Flag
    wire zero_sum = ~(|sum); // sum�� ��� ��Ʈ�� 0�̵Ǹ�, zero_sum = 1
    register_Nbit_p #(.N(1)) zero_f(.d(zero_sum), .clk(clk), .reset_p(reset_p), .wr_en(op_sub), .rd_en(1'd1), .q(zero_flag));
    
    // Sign Flag
    // �A ����� ����ų� 0�̸�, cout = 1 -> sign_flag = 0
    // �A ����� ������ ������ cout = 0 -> sign_flag = 1
    register_Nbit_p #(.N(1)) sign_f(.d(~cout), .clk(clk), .reset_p(reset_p), .wr_en(op_sub), .rd_en(1'd1), .q(sign_flag));
//    register_Nbit_p #(.N(1)) sign_f(.d(!(cout) & op_sub), .clk(clk), .reset_p(reset_p), .wr_en(op_sub), .rd_en(1'b1), .q(sign_flag));
    
    // Carry Flag
    // ���ϱ�, ������, ���ϱ��� �� ���� �ϹǷ�
    // wr_en�� 1 �༭ ��� enable�ǰ� �ϰ� cout�� &�� ��������.
    register_Nbit_p #(.N(1)) carry_f(.d(cout & (op_add | op_div | (op_mul & alu_lsb))), .clk(clk), .reset_p(reset_p), .wr_en(1'b1), .rd_en(1'd1), .q(carry_flag)); //

endmodule


module block_alu_acc(
    input clk, reset_p, acc_high_reset_p,
    input rd_en, acc_in_select,
    input [1:0] acc_high_select, acc_low_select, // acc�� mode�� ����
    input op_add, op_sub, op_mul, op_div, op_and,
    input [3:0] bus_data, bus_reg_data,
    output sign_flag, zero_flag,
    output [7:0] acc_data // �������� ������ ��� / ��� BUS�θ� ����.(���� 4bit, ���� 4bit)
    );
    
    // ��� ���ο��� �ְ� ���� ��ȣ���� wire ó��
    wire [3:0] alu_data;
    wire [3:0] acc_high_data2bus, acc_low_data2bus;
    wire [3:0] acc_high_register_data, acc_low_register_data;
    wire carry_flag, cout;
    wire [1:0] acc_high_select_mul_div;
    
    // acc_low_register_data�� ��������Ʈ�� 0�̸� ���� �����͸� ����, 1�̸� ACC�� BREG�� ���� ���� �� ���� Load
    // ALU�� ���ճ�ȸ���̱� ������ clk�� ������ ���� �ʰ� �Էµ� ��� ���
    // ���� ���� �Է¹����� �ٷ� ������ �ǰ�, �� ���� acc_high_select �Ǵ� acc_low_select�� ���� ����/����Ʈ/�ε尡 �����ȴ�.
//    assign acc_high_select_mul_div[0] = op_mul ? acc_low_register_data[0] : acc_high_select[0]; 
//    assign acc_high_select_mul_div[1] = op_mul ? acc_low_register_data[0] : acc_high_select[1];
    assign acc_high_select_mul_div[0] = (op_mul | op_div) ? (op_mul & acc_low_register_data[0]) | (op_div & cout) : acc_high_select[0];
    assign acc_high_select_mul_div[1] = (op_mul | op_div) ? (op_mul & acc_low_register_data[0]) | (op_div & cout) : acc_high_select[1];
    // op_div = 1�̸鼭 cout�� 1�� �ȴٸ�, ���Ⱑ �����ϴٴ� ���̹Ƿ� acc_high_select_mul_div = 2'b11�� �Ǿ� �A ���� �ε��Ѵ�.
    
    acc U_acc(.clk(clk), .reset_p(reset_p), .acc_high_reset_p(acc_high_reset_p),
              .fill_value(carry_flag), .rd_en(rd_en), .acc_in_select(acc_in_select),
              .acc_high_select(acc_high_select_mul_div), .acc_low_select(acc_low_select),
              .bus_data(bus_data), .alu_data(alu_data),
              .acc_high_data2bus(acc_high_data2bus), .acc_high_register_data(acc_high_register_data),
              .acc_low_data2bus(acc_low_data2bus), .acc_low_register_data(acc_low_register_data)
              );
              
    assign acc_data = {acc_high_data2bus, acc_low_data2bus}; // BUS�� ��µǴ� acc_data(���Ǻ� ���)
    
    alu U_alu(.clk(clk), .reset_p(reset_p),
              .op_add(op_add), .op_sub(op_sub), .op_mul(op_mul), .op_div(op_div), .op_and(op_and), // ���꿡 ����� ��ɾ�
              .alu_lsb(acc_high_register_data[0]), // ������ ��Ʈ �Է� �ϳ� �־�� ��
              .acc_high_data(acc_high_register_data), // BUS�� ���� �Էµ� ù ���� Data 4bit�� ACC�� ���� -> ALU�� ���� 4bit�� ����
              .bus_reg_data(bus_reg_data), // BUS�� ���� �Էµ� ���� Data 4bit�� BREG�� ���� -> ALU�� ���� 4bit�� ����
              .alu_out(alu_data), // ���� ���  -> ACC�� ����
              .zero_flag(zero_flag), // ������ ����� 0�̸�, zero flag = 1
              .sign_flag(sign_flag), // ��� ���, ������ �߻��ϸ� sign_flag = 0, ��ȣ(����/���)�� ���� sign flag���� ��������. 
              .carry_flag(carry_flag), // carry�� �߻��ϸ�, carry flag = 1
              .cout(cout) // carry_out
              );
              
    // ���ϱ�� ������ ���� op_add �Ǵ� op_sub�� �ְ� high & low_select�� 2'b11�� �� �� ����ϸ� �ȴ�.
    // 
    // acc_data�� ������ ������Ʈ�� assign���� ������� ������ ���ϱ� ȿ���� ��Ÿ����.
endmodule


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////// Half ACC /////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//// 4bit¥�� ACC���� �� �� �̾���ϰ��̴�.
//module half_acc(
//    input clk, reset_p,
//    input load_msb, load_lsb, // ����Ʈ�Ͽ� ����� ���� ����
//    input rd_en, // Bus�� �������� ���� ������ Control Block���κ��� �޴� Enable ��ȣ
//    input [1:0] s,
//    input [3:0] data_in, // ������ �Է¹��� ����
//    output [3:0] data2bus, // BUS�� ��ȣ�� �޾Ƽ� ������ ����� �������� ����, ��ȣ�� ���� ������ ���Ǵ��� ����
//    output [3:0] register_data // ������ �ٷιٷ� ������ ����� �������� ����
//    );
    
    
//    reg [3:0] d;
//    always @(*) begin
//        case(s)
//            2'b00 : d = register_data;
//            2'b01 : d = {load_msb, register_data[3:1]}; // �ҷ��� msb�� register_data�� ���� 3bit�� �����Ѵ� -> �����Ʈ ����
//            2'b10 : d = {register_data[2:0], load_lsb}; // �½���Ʈ
//            2'b11 : d = data_in;
//        endcase // ���ճ�ȸ�ο����� case�� ���� ä��ų� default�� �������� �Ѵ�. �׷��� ������ Latch�� ������� ���� �ִ�
//    end
    
//    // Half ACC
//    register_Nbit_p_alltime #(.N(4)) h_cc(.d(d), .clk(clk), .reset_p(reset_p), .wr_en(1'b1), .rd_en(rd_en), .register_data(register_data), .q(data2bus));
//    // ��� ����� register_data, ���� ���(Enable ��ȣ)�� data2bus
    
//endmodule


//module acc(
//    input clk, reset_p, acc_high_reset_p,
//    input fill_value, // 0���� ä��ų� 1�� ä��
//    input rd_en, acc_in_select,
//    input [1:0] acc_high_select, acc_low_select, // Half_ACC�� �� ���̹Ƿ� ��������� �Ѵ�.
//    input [3:0] bus_data, alu_data,
//    output [3:0] acc_high_data2bus, acc_high_register_data,
//    output [3:0] acc_low_data2bus, acc_low_register_data     
//    );
    
//    // ACC�� Bus�κ��͵� �����͸� �ް�, ALU�κ��͵� �����͸� �����Ƿ�,
//    // ��� ���� ������ �����ϴ� ����� �ʿ��ϴ�.
//    wire [3:0] acc_high_data;
//    assign acc_high_data = acc_in_select ? bus_data : alu_data;
    
//    half_acc acc_high(.clk(clk), .reset_p(reset_p | acc_high_reset_p), .load_msb(fill_value), .load_lsb(acc_low_register_data[3]), .rd_en(rd_en), .s(acc_high_select), // �½���Ʈ�� ���� ���� bit�� �ֻ��� bit�� �ش�
//                      .data_in(acc_high_data), .data2bus(acc_high_data2bus), .register_data(acc_high_register_data));
//    half_acc acc_low(.clk(clk), .reset_p(reset_p), .load_msb(acc_high_register_data[0]), .load_lsb(fill_value), .rd_en(rd_en), .s(acc_low_select),
//                      .data_in(acc_high_register_data), .data2bus(acc_low_data2bus), .register_data(acc_low_register_data));
//                      // load�� ���� ���� 4bit�� �ް� ���� 4bit�� �� �޾�
//                      // �׷��� data_in�� ���� 4bit�� �׳� �״�� ��
//    // ���� ��Ʈ�� ���� 4bit�� �ҷ��ͼ� ����.
//    // �ҷ��� �� �ҷ��� ���� 4but�� ������ ������� ��.
//    // �ٵ� �׳� ������ ���� �������� �� ������.
//    // ���� ���� 4bit�� ���� �������ִ� ����� �ʿ��ϴ�. -> acc_high�� acc_high_reset_p �߰�                                     
    
//endmodule