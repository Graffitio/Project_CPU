`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/06 10:44:37
// Design Name: 
// Module Name: key_pad_test_top
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


module key_pad_test_top(
    input clk, reset_p,
    input [3:0] row,
    output [3:0] col,
    output [3:0] com,
    output [7:0] seg_7
    );
    
    wire [3:0] key_value;
    wire key_valid;
    key_pad_cntr key_pad(.clk(clk), .reset_p(reset_p), .row(row), .col(col), .key_value(key_value), .key_valid(key_valid));
    
    reg [15:0] value;
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            value = 0;
        end
        // 키패드 버튼 중 하나가 눌렸을 때, FND에 출력
        // 이거 안 하고 바로 넣어줘도 되기는 하는데, 확실하게 해주기 위해서 추가한다.
        else if(key_valid) begin
            value = key_value;
        end
    end
    
    FND_4digit_cntr(.clk(clk), .rst(reset_p), .value(value), .com(com), .seg_7(seg_7));
    
endmodule
