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


// 4bit짜리 ACC만들어서 두 개 이어붙일것이다.
// 일종의 레지스터
module half_acc(
    input clk, reset_p,
    input load_msb, load_lsb, // 시프트하여 사용하기 위한 변수
    input rd_en, // Bus를 공통으로 쓰기 떄문에 Control Block으로부터 받는 Enable 신호
    input [1:0] s, // mode select
    input [3:0] data_in, // 데이터 입력받을 변수
    output [3:0] data2bus, // BUS의 신호를 받아서 데이터 출력을 내보내는 변수, 신호가 오지 않으면 임피던스 상태
    output [3:0] register_data // 언제든 바로바로 데이터 출력을 내보내는 변수
    );
    
    
    reg [3:0] d;
    always @(*) begin
        case(s)
            2'b00 : d = register_data; // 데이터 유지
            2'b01 : d = {load_msb, register_data[3:1]}; // 불러온 msb와 register_data의 상위 3bit를 결합한다 -> 우시프트(>>), 곱셈
            2'b10 : d = {register_data[2:0], load_lsb}; // 좌시프트(<<), 나눗셈 
            2'b11 : d = data_in; // ALU나 BUS로부터 전송받은 데이터
        endcase // 조합논리회로에서는 case를 전부 채우거나 default를 만들어줘야 한다. 그렇지 않으면 Latch가 만들어질 수도 있다
    end
    
    // Half ACC
    register_Nbit_p_alltime #(.N(4)) h_cc(.d(d), .clk(clk), .reset_p(reset_p), .wr_en(1'b1), .rd_en(rd_en), .register_data(register_data), .q(data2bus));
    // 상시 출력은 register_data, 조건 출력(Enable 신호)은 data2bus
    
endmodule


module acc(
    input clk, reset_p, acc_high_reset_p,
    input fill_value, // 안 쓰는 비트를 0으로 채우거나 1로 채움
    input rd_en, acc_in_select,
    input [1:0] acc_high_select, acc_low_select, // Half_ACC가 두 개이므로 구분해줘야 한다.
    input [3:0] bus_data, alu_data, // BUS와 ALU로부터 받는 데이터
    output [3:0] acc_high_data2bus, acc_high_register_data,
    output [3:0] acc_low_data2bus, acc_low_register_data     
    );
    
    // ACC는 Bus로부터도 데이터를 받고, ALU로부터도 데이터를 받으므로,
    // 어디서 받을 것인지 선택하는 기능이 필요하다.
    wire [3:0] acc_high_data;
    assign acc_high_data = acc_in_select ? bus_data : alu_data;
    
    half_acc acc_high(.clk(clk), .reset_p(reset_p | acc_high_reset_p), .load_msb(fill_value), .load_lsb(acc_low_register_data[3]), .rd_en(rd_en), .s(acc_high_select), // 좌시프트할 때는 하위 bit에 최상위 bit를 준다
                      .data_in(acc_high_data), // BUS나 ALU로부터 전송된 데이터를 acc_high로 받는다.
                      .data2bus(acc_high_data2bus), .register_data(acc_high_register_data));
    half_acc acc_low(.clk(clk), .reset_p(reset_p), .load_msb(acc_high_register_data[0]), .load_lsb(fill_value), .rd_en(rd_en), .s(acc_low_select),
                      .data_in(acc_high_register_data), .data2bus(acc_low_data2bus), .register_data(acc_low_register_data));
                      // BUS나 ALU로부터 Data를 load할 때는 4bit씩 load하는데,
                      // 이 때, acc_high만 load한 Data 4bit를 받고 acc_low는 안 받아(이전에 있던 값 유지)
                      // 다음 연산을 위해서 또는 acc_high에 다음 Data를 받기 위해서 현재 Data를 acc_low로 넘겨줄 필요가 있다.
                      // 그래서 acc_low의 data_in에 acc_high 4bit를 그냥 그대로 줘
    // acc_low는 acc_high를 불러와서 쓴다.
    // 불러온 뒤 불러온 상위 4bit는 리셋을 시켜줘야 해.
    // 근데 그냥 리셋을 쓰면 하위까지 다 지워짐.
    // 따라서 상위 4bit만 따로 리셋해주는 기능이 필요하다. -> acc_high에 acc_high_reset_p 추가
    
                          
    
endmodule
