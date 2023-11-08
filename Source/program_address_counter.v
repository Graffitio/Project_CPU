`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/13 15:43:15
// Design Name: 
// Module Name: program_address_counter
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


module program_address_counter(
    input clk, reset_p,
    input pc_inc, load_pc,
    input pc_rd_en, // pc���� BUS�� ��µ� ������ �� ������
    input [7:0] pc_in, // �̵��� �������� �ּ�
    output [7:0] pc_out
    );
    
    // upcounter�� adder�� DFF�� ���ļ� �����.(����ȸ�ο� ����ȸ���� ����)
    wire [7:0] sum, next_addr, cur_addr;
    half_adder_N_bit #(.N(8)) ha8bit(
.inc(pc_inc), .load_data(cur_addr), .sum(sum));
    
    // ���� �ּҷ� �� ��, �ƴϸ� �ƿ� �ٸ� �ּҷ� ������ �� ����
    assign next_addr = load_pc ? pc_in : sum;
    
    register_Nbit_p_alltime #(.N(8)) pc_reg(
        .d(next_addr), .clk(clk), .reset_p(reset_p), .wr_en(1'b1), .rd_en(pc_rd_en), .register_data(cur_addr), .q(pc_out));
endmodule