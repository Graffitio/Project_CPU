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
    
    reg [19:0] clk_div; // 1ms 분주기 생성
    always @(posedge clk) clk_div = clk_div + 1;
    
    wire clk_8msec;
    edge_detector_p(.clk(clk), .cp_in(clk_div[19]), .rst(reset_p), .n_edge(clk_8msec));
    // edge detector에서 나오는 펄스를 One cycle pulse라고 한다.
    
    parameter SCAN_0 = 5'b00001; // 0번 스캔
    parameter SCAN_1 = 5'b00010; // 1번 스캔
    parameter SCAN_2 = 5'b00100; // 2번 스캔
    parameter SCAN_3 = 5'b01000; // 3번 스캔
    parameter KEY_PROCESS = 5'b10000;
    
    ///////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////// FSM Begin ////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////
    reg [4:0] state, next_state;
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) state = SCAN_0;
        else if(clk_8msec) state = next_state; 
    end
    
    // (*) : 아무 입력이 들어올 때 마다 동작하라는 의미
    // (*) 이런 식으로 always문 쓰면, MUX만으로 구성되기 떄문에 조합회로가 된다.
    always @(*) begin 
        case(state)
            SCAN_0 : begin
                // 풀업 저항을 쓸 것이므로 항상 1이 입력되고 있는 상태.
                // 따라서 4'b1111이 아니면, 어디선가 키 입력이 들어 왔다는 뜻
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
                // clk는 매우 짧은 시간이라 바운싱이 무조건 있을 수 밖에 없다.
                // 8msec 이후니까 바운싱은 이미 제거된 상태일 것이다.
                // 따로 디바운싱 필요없음.
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
                // 스캔할 때는 key_valid = 0으로 줘서 스캔모드
                SCAN_0 : begin col = 4'b1110; key_valid = 0; end
                SCAN_1 : begin col = 4'b1101; key_valid = 0; end
                SCAN_2 : begin col = 4'b1011; key_valid = 0; end
                SCAN_3 : begin col = 4'b0111; key_valid = 0; end
                KEY_PROCESS : begin
                    key_valid = 1;
                    case({col, row}) // 좌표라고 생각하면 된다.
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
