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
    input pc_rd_en, // pc값이 BUS로 출력될 것인지 말 것인지
    input [7:0] pc_in, // 이동할 데이터의 주소
    output [7:0] pc_out
    );
    
    // upcounter는 adder와 DFF를 합쳐서 만든다.(조합회로와 순차회로의 결합)
    wire [7:0] sum, next_addr, cur_addr;
    half_adder_N_bit #(.N(8)) ha8bit(
.inc(pc_inc), .load_data(cur_addr), .sum(sum));
    
    // 다음 주소로 갈 지, 아니면 아예 다른 주소로 점프할 지 결정
    assign next_addr = load_pc ? pc_in : sum;
    
    register_Nbit_p_alltime #(.N(8)) pc_reg(
        .d(next_addr), .clk(clk), .reset_p(reset_p), .wr_en(1'b1), .rd_en(pc_rd_en), .register_data(cur_addr), .q(pc_out));
endmodule