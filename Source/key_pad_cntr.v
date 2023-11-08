`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/06 10:07:51
// Design Name: 
// Module Name: key_pad_cntr
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


module key_pad_cntr(
    input clk, reset_p,
    input [3:0] row,
    output reg [3:0] col,
    output reg [3:0] key_value,
    output reg key_valid
    );
    
    reg [19:0] clk_div; // 1ms ���ֱ� ����
    always @(posedge clk) clk_div = clk_div + 1;
    
    wire clk_8msec;
    edge_detector_p(.clk(clk), .cp_in(clk_div[19]), .rst(reset_p), .n_edge(clk_8msec));
    // edge detector���� ������ �޽��� One cycle pulse��� �Ѵ�.
    
    parameter SCAN_0 = 5'b00001; // 0�� ��ĵ
    parameter SCAN_1 = 5'b00010; // 1�� ��ĵ
    parameter SCAN_2 = 5'b00100; // 2�� ��ĵ
    parameter SCAN_3 = 5'b01000; // 3�� ��ĵ
    parameter KEY_PROCESS = 5'b10000;
    
    ///////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////// FSM Begin ////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////
    reg [4:0] state, next_state;
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) state = SCAN_0;
        else if(clk_8msec) state = next_state; 
    end
    
    // (*) : �ƹ� �Է��� ���� �� ���� �����϶�� �ǹ�
    // (*) �̷� ������ always�� ����, MUX������ �����Ǳ� ������ ����ȸ�ΰ� �ȴ�.
    always @(*) begin 
        case(state)
            SCAN_0 : begin
                // Ǯ�� ������ �� ���̹Ƿ� �׻� 1�� �Էµǰ� �ִ� ����.
                // ���� 4'b1111�� �ƴϸ�, ��𼱰� Ű �Է��� ��� �Դٴ� ��
                if(row != 4'b1111) next_state = KEY_PROCESS;
                else next_state = SCAN_1;
            end
            SCAN_1 : begin
                if(row != 4'b1111) next_state = KEY_PROCESS;
                else next_state = SCAN_2;            
            end
            SCAN_2 : begin
                if(row != 4'b1111) next_state = KEY_PROCESS;
                else next_state = SCAN_3;            
            end
            SCAN_3 : begin
                if(row != 4'b1111) next_state = KEY_PROCESS;
                else next_state = SCAN_0;            
            end
            KEY_PROCESS : begin
                // clk�� �ſ� ª�� �ð��̶� �ٿ���� ������ ���� �� �ۿ� ����.
                // 8msec ���Ĵϱ� �ٿ���� �̹� ���ŵ� ������ ���̴�.
                // ���� ��ٿ�� �ʿ����.
                if(row != 4'b1111) next_state = KEY_PROCESS;
                else next_state = SCAN_0;                
            end                                    
        endcase
    end
    ///////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////// FSM End //////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            key_value = 0;
            key_valid = 0;
            col = 4'b0001;
        end
        else begin
            case(state)
                // ��ĵ�� ���� key_valid = 0���� �༭ ��ĵ���
                SCAN_0 : begin col = 4'b1110; key_valid = 0; end
                SCAN_1 : begin col = 4'b1101; key_valid = 0; end
                SCAN_2 : begin col = 4'b1011; key_valid = 0; end
                SCAN_3 : begin col = 4'b0111; key_valid = 0; end
                KEY_PROCESS : begin
                    key_valid = 1;
                    case({col, row}) // ��ǥ��� �����ϸ� �ȴ�.
                        8'b1110_1110 : key_value = 4'hD;
                        8'b1110_1101 : key_value = 4'hE;
                        8'b1110_1011 : key_value = 4'hB;
                        8'b1110_0111 : key_value = 4'hA;
                        
                        8'b1101_1110 : key_value = 4'hF;
                        8'b1101_1101 : key_value = 4'h3;
                        8'b1101_1011 : key_value = 4'h6;
                        8'b1101_0111 : key_value = 4'h9;
                        
                        8'b1011_1110 : key_value = 4'h0;
                        8'b1011_1101 : key_value = 4'h2;
                        8'b1011_1011 : key_value = 4'h5;
                        8'b1011_0111 : key_value = 4'h8;
                        
                        8'b0111_1110 : key_value = 4'hC;
                        8'b0111_1101 : key_value = 4'h1;
                        8'b0111_1011 : key_value = 4'h4;
                        8'b0111_0111 : key_value = 4'h7;                                                
                    endcase              
                end                                                                
            endcase
        end
    end
    
endmodule
