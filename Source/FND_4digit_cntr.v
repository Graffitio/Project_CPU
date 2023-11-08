`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/30 09:20:35
// Design Name: 
// Module Name: FND_4digit_cntr
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


module FND_4digit_cntr( //// ring counter top module ���� ---- 16bit�� ���� �޾Ƽ� 1ms �������� �� �ڸ��� ���ش�.
    input clk, rst,
    input [15:0] value, //// 4�ڸ��ϱ� 16bit
    output [3:0] com,
    output [7:0] seg_7
);
    reg [16:0] clk_1ms;//// 8ns * 2^17 = 1,048,576ns = 1048�� = 1.048ms
    always @(posedge clk) clk_1ms = clk_1ms + 1 ;
    
    ring_count_fnd ring1(.clk(clk_1ms[16]), .com(com)); //// 1ms posedge���� �½���Ʈ
                                                                   //// 1ms ���� CT ����� LED�� �����Ѵ�.
                                                                   
    wire [7:0] seg_7_font;
    reg [3:0] hex_value;
    decoder_7seg ring_seg_7(.hex_value(hex_value), .seg_7(seg_7_font));
    assign seg_7 = ~seg_7_font;
    
    always @(negedge clk) begin //// ī������ posedge�� ������, ��ġ�� �ʰ� negedge
        case(com)
            4'b1110 : hex_value = value[15:12]; //// CT1�� �ش��ϴ� hex_value�� value[15:12]
            4'b1101 : hex_value = value[11:8];
            4'b1011 : hex_value = value[7:4];
            4'b0111 : hex_value = value[3:0];
        endcase  //// edge triggering�� default���� ���� ���� �����ص� FF�� ��������� �������.           
    end
endmodule