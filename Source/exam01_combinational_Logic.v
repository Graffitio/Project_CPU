`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/19 14:24:13
// Design Name: 
// Module Name: and2_gate
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


module and2_gate(  /////////// module 모듈명(변수 선언); 
    input A,
    input B,
    output F
    );
    
    and(F, A, B);  /////// gate(출력, 입력); ------> 이것 자체가 모듈
endmodule    //// primitive gate 설계(프리미티브 게이트는 출력이 1개)


module half_adder(  ////// half addr의 모듈, 변수선언
    input A,
    input B,
    output sum,
    output carry
 );
    xor(sum, A, B); ////// xor gate 생성
    and(carry, A, B); ////// and gate 생성
 endmodule  ///// 구조적 모델링은 ASIC에서는 만들어지지만, FPGA에서는 비효율적

/////////////////////////////////////////////////////////////////////////////////
module half_adder_dataflow(   ///// 데이터플로우 모델링
                              /////assign 문을 활용하여 수식으로 출력을 표현
    input A,
    input B,
    output sum,
    output carry
 );
    assign sum = A^B;  ///// xor
    assign carry = A&B; ///// and 
endmodule // 앞으로 half addr는 이 것을 자주 사용할 것.
//////////////////////////////////////////////////////////////////////////////////

module half_adder_4bit(
    // load_data 에 1만 더해주는 기능을 한다.
    // 하프 에더이기 때문에 0 또는 1씩만 더해줄 수 있다.
    // 1씩 증가하는 카운터를 이 걸로 만들어줄 수 있음.
    input inc,
    input [3:0] load_data, 
    output [3:0] sum
    );
    
    // half adder 3개로 만들어보자.
//    wire [3:0] carry_out;
//    half_adder_dataflow ha0(.A(inc), .B(load_data[0]), .sum(sum[0]), .carry(carry_out[0]));
//    half_adder_dataflow ha1(.A(carry_out[0]), .B(load_data[1]), .sum(sum[1]), .carry(carry_out[1]));
//    half_adder_dataflow ha2(.A(carry_out[1]), .B(load_data[2]), .sum(sum[2]), .carry(carry_out[2]));
//    half_adder_dataflow ha3(.A(carry_out[2]), .B(load_data[3]), .sum(sum[3]), .carry(carry_out[3]));
    
    // 위 코드를 for문으로 만들어보자.
    wire [3:0] carry_out;
    half_adder_dataflow ha0(.A(inc), .B(load_data[0]), .sum(sum[0]), .carry(carry_out[0]));
    // for문으로 구조적 모델링할 떄
    genvar i; // 얘는 회로로 안 만들어진다. 단순히 for문에서만 쓸 변수
    generate
        for(i = 1 ; i < 4 ; i = i + 1) begin
            half_adder_dataflow ha(.A(carry_out[i-1]), .B(load_data[i]), .sum(sum[i]), .carry(carry_out[i]));
        end
    endgenerate
endmodule


module half_adder_N_bit #(parameter N = 8)(
    // load_data 에 1만 더해주는 기능을 한다.
    // 하프 에더이기 때문에 0 또는 1씩만 더해줄 수 있다.
    // 1씩 증가하는 카운터를 이 걸로 만들어줄 수 있음.
    input inc,
    input [N-1:0] load_data, 
    output [N-1:0] sum
    );

    wire [N-1:0] carry_out;
    half_adder_dataflow ha0(.A(inc), .B(load_data[0]), .sum(sum[0]), .carry(carry_out[0]));
    // for문으로 구조적 모델링할 떄
    genvar i; // 얘는 회로로 안 만들어진다. 단순히 for문에서만 쓸 변수
    generate
        for(i = 1 ; i < N ; i = i + 1) begin
            half_adder_dataflow ha(.A(carry_out[i-1]), .B(load_data[i]), .sum(sum[i]), .carry(carry_out[i]));
        end
    endgenerate
endmodule




module half_adder_behaviaral(   ///// 동작적 모델링(always 문 사용)
    input A,
    input B,
    output reg sum, //// always 문에서 왼쪽의 변수는 reg형으로 선언되어야 한다.
    output reg carry
 );
    always @(A, B) begin //// begin~end 로 block를 만들어 준다.
        case({A, B})
            2'b00: begin sum = 0; carry = 0; end ///// A=0, B=0 이면, sum=0, carry=0 이다.
            2'b01: begin sum = 1; carry = 0; end
            2'b10: begin sum = 1; carry = 0; end
            2'b11: begin sum = 0; carry = 1; end
        endcase
    end
endmodule


////// Full_adder 만들기


module full_adder_structure( //// half_addr 두개의 조합(구조적 모델링)
        input A, B, cin, 
        output sum, carry 
    );  ///// 앞으로 만들 fulladdr의 변수를 선언함.
    
    wire sum_0; /// sum_0라는 wire 선언
    wire carry_0;   //// wire sum_0, carry_o; 이렇게 만들어도 된다.
    wire carry_1;
    
    half_adder ha0 ( /// 첫 번쨰 half_addr --- half_addr을 인스턴스한 것, ha0 : 인스턴스명
                     //// instance(인스턴스) : 모듈을 가지고 게이트를 만든다.
    .A(A), /// .A : half_adder의 A        (A) : 지금 만드는 모듈의 A
    .B(B),
    .sum(sum_0), /// half_adder의 sum에다가 sum_0를 연결한다.
    .carry(carry_0)
    ); 
    half_adder ha1 (.A(sum_0), .B(cin), .sum(sum), .carry(carry_1));
    
    or(carry, carry_0, carry_1);
endmodule


module full_adder(
        input A, B, cin, 
        output sum, carry 
    );
    
    assign sum = A^B^cin;  /// 논리식 기준으로 만든다. ------------ ①
    assign carry = (cin&(A^B)) | (A & B); /// 논리식 기준으로 만든다.----------②
     /// ^ : xor, | : or, & : and,
     /// Verilog는 ①과 ②를 바꿔서 적어도 결과는 같다.(동시에 진행되기 때문)
     /// 비트 논리 연산자를 써서 만들었기 때문에, 구조적 모델링이랑 별 차이가 없다.
    
    
endmodule


module full_4bit_s( 
    input [3:0] a, b, /// msb :최상위비트, lsb :최하위 비트, [msb:lsb] 
    input       cin,
    output [3:0] sum, //// 4bit짜리 bus로 묶여서 출력된다.
    output       carry
);
    wire [2:0] carry_in; /// wire 3개
    
    full_adder fa0 ( /// 위에서 만든 full adder instance
    .A(a[0]),     //// a[0] :4bit짜리 a의 0번쨰 bit
    .B(b[0]),
    .cin(cin),
    .sum(sum[0]),
    .carry(carry_in[0])
    );
    full_adder fa1 (.A(a[1]), .B(b[1]), .cin(carry_in[0]), .sum(sum[1]), .carry(carry_in[1]));
    full_adder fa2 (.A(a[2]), .B(b[2]), .cin(carry_in[1]), .sum(sum[2]), .carry(carry_in[2]));
    full_adder fa3 (.A(a[3]), .B(b[3]), .cin(carry_in[2]), .sum(sum[3]), .carry(carry));
    
endmodule


module full_4bit( ///// dataflow modeling
    input [3:0] a, b,
    input       cin,
    output [3:0] sum,
    output       carry
);
    wire [4:0] temp; /// carry의 자리는 [5], [3:0]은 sum
    
    assign temp = a + b + cin; /// 비트연산자가 아닌, 사칙연산자를 사용하였다. ---> 회로가 달라짐.
                               /// FPGA 내에 있는 덧셈기를 이용하여 회로를 구성한다.(좀 더 추상화 레벨이 높다.)
    assign sum = temp[3:0];
    assign carry = temp[4];

endmodule

module fadd_sub_4bit_s( /// s : structure modeling
    input [3:0] a, b, /// msb :최상위비트, lsb :최하위 비트, [msb:lsb] 
    input       s,    /// : add s= 0; sub s = 1(s에 1을 넣으면 감산기, 0이면 가산기)
    output [3:0] sum, //// 4bit짜리 bus로 묶여서 출력된다.
    output       carry
);
    wire [2:0] carry_in; /// wire 3개
    
    full_adder fa0 ( /// 위에서 만든 full adder instance
    .A(a[0]),     //// a[0] :4bit짜리 a의 0번쨰 bit
    .B(b[0]^s),
    .cin(s),
    .sum(sum[0]),
    .carry(carry_in[0])
    );
    full_adder fa1 (.A(a[1]), .B(b[1]^s), .cin(carry_in[0]), .sum(sum[1]), .carry(carry_in[1]));
    full_adder fa2 (.A(a[2]), .B(b[2]^s), .cin(carry_in[1]), .sum(sum[2]), .carry(carry_in[2]));
    full_adder fa3 (.A(a[3]), .B(b[3]^s), .cin(carry_in[2]), .sum(sum[3]), .carry(carry));
    
endmodule //// ,(콤마) 뒤에는 반드시 띄어쓰기된다. .(온점) 뒤에는 띄어쓰기없이 그냥 나온다.


module fadd_sub_4bit_d( /// d : data flow modeling
    input [3:0] a, b,
    input       s,    
    output [3:0] sum, 
    output       carry
);
    wire [4:0] temp;
    
    assign temp = s ? a-b : a+b; /// s는 carry가 아니라 가산기, 감산기 중 어떤 것을 쓸 건지 설정하는 용도
                                  /// s = 0(거짓)이면, : 뒤의 값이 s로 들어간다.
                                  /// s = 1(참)이면, : 앞의 갚이 s로 들어간다.
    assign sum = temp[3:0];
    assign carry = s ? ~temp[4] : temp[4];
    
endmodule



module comparator_s(
    input A, B,
    output equal, greater, less
);
    assign equal = A ~^ B;
    assign greater = A & ~B;
    assign less = ~A & B; /// assign을 썼지만, 논리연산자를 쓰면 구조적 모델링이랑 별 차이가 없다.
                           /// bit 별로 각각 회로를 다시 짜줘야 한다.
    
endmodule

module comparator #(parameter N=4)( /// # : compile 지시어, 이 모듈을 다른 곳에서 인스턴스할 때, N 값을 바꿔서 사용할 수 있다. default = 4(N=4로 지정해주었기 때문)
                     /// 조건 연산자를 써서 Data-flow modeling으로 설계
                    /// 입력의 bit만 바꿔주면, 다중 bit 비교 연산이 가능하다.
    input [N-1:0] A, B,
    output equal, greater, less
);
    assign equal = (A==B) ? 1'b1 : 1'b0; ///  
    assign greater = (A>B) ? 1'b1 : 1'b0; 
    assign less = (A<B) ? 1'b1 : 1'b0; 
    
endmodule

module decoder_2_4_b( /// 복잡하니까 동작적 모델링으로 설계
    input [1:0] A,
    output reg [3:0] Y /// always문의 data type는 reg
);
//    always @ (A) begin /// always @ (~) : ~가 변하면 1회 실행
//        case(A) //// case(~) : ~의 변수의 경우의 수가 아래에 다 있다면, 상관없는데 하나라도 빠진다면 그 빠진 값은 default로 출력
//            2'b00: Y=4'b0001;
//            2'b01: Y=4'b0010;
//            2'b10: Y=4'b0100;
//            2'b11: Y=4'b1000;
//        endcase
//    end

    always @ (A) begin
        if(A==2'b00) Y=4'b0001;
        else if(A==2'b01) Y=4'b0010;
        else if(A==2'b10) Y=4'b0100;
        else Y=4'b1000;
    end
endmodule


module decoder_2_4_d( /// data-flow modeling으로 디코더 설계
    input [1:0] A,
    output [3:0] Y /// assign문의 data type는 wire
);
    assign Y=(A==2'b00) ? 4'b0001 : (A==2'b01) ? 4'b0010 : (A==2'b10) ? 4'b0100 : 4'b1000; 
                     /// Y ? 수식1 : 수식2; ----> 조건이 참이면, 수식1을 받고 거짓이면 수식2를 받는다.
                     /// 위처럼 조건연산자를 중복으로 사용(다중조건문)하면 if-else문을 dataflow로 표현할 수 있다.
endmodule

module decoder_2_4_en_d( /// enable이 있는 2-4 디코더
    input [1:0] A,
    input       en,  /// en = 0 : 모든 출력이 0
    output [3:0] Y /// assign문의 data type는 wire
);
    assign Y=(en==0) ? 4'b0000 : (A==2'b00) ? 4'b0001 : (A==2'b01) ? 4'b0010 : (A==2'b10) ? 4'b0100 : 4'b1000; 

endmodule

module decoder_2_4_en_b( /// enable이 있는 2-4 디코더
    input [1:0] A,
    input       en,  /// en = 0 : 모든 출력이 0
    output reg [3:0]  Y /// assign문의 data type는 wire
);
        always @ (A) begin
         if(en) begin
            case(A) //// case(~) : ~의 변수의 경우의 수가 아래에 다 있다면, 상관없는데 하나라도 빠진다면 그 빠진 값은 default로 출력
                2'b00: Y=4'b0001;
                2'b01: Y=4'b0010;
                2'b10: Y=4'b0100;
                2'b11: Y=4'b1000;
            endcase
         end
         else Y=0;
        end
endmodule

module decoder_2_4_en_b2( 
    input [1:0] A,
    input       en,
    output reg [3:0] Y 
);
    always @ (A) begin
        if(en) begin
            if(A==2'b00) Y=4'b0001;
            else if(A==2'b01) Y=4'b0010;
            else if(A==2'b10) Y=4'b0100;
            else Y=4'b1000;
        end
        else Y=0;
    end
    
//    always @(A0) begin  이런 식으로도 코딩이 가능하다.
//        if(!en) Y=0;
//            else if(A==2'b00) Y=4'b0001;
//            else if(A==2'b01) Y=4'b0010;
//            else if(A==2'b10) Y=4'b0100;
//            else Y=4'b1000;
//     end
endmodule


module decoder_3_8( /// 2_4 디코더를 두 개 합치면, 3_8 디코더를 만들 수 있다.
    input [2:0] D,
    output[7:0] Y
);
    decoder_2_4_en_d de1 ( .A(D[1:0]), .en(~D[2]), .Y(Y[3:0]));  /// 인스턴스할 때, 변수 지정( = .A(D))을 해주지 않으면 순서대로 작성해주면 됨.
    decoder_2_4_en_d de2 ( .A(D[1:0]), .en(D[2]), .Y(Y[7:4]));
    
endmodule


// 동작적 모델링으로 설계(3-8 디코더 2개 이어붙여서 en이 있는 4-16 디코더만들기)
//module decoder3x8(input wire [2:0] in, output reg [7:0] out);
//  always @(*)
//  begin
//    case (in)
//      3'b000: out = 8'b00000001;
//      3'b001: out = 8'b00000010;
//      3'b010: out = 8'b00000100;
//      3'b011: out = 8'b00001000;
//      3'b100: out = 8'b00010000;
//      3'b101: out = 8'b00100000;
//      3'b110: out = 8'b01000000;
//      3'b111: out = 8'b10000000;
//      default: out = 8'b00000000;
//    endcase
//  end
//endmodule
//    module decoder_en_3x8decoder(input en, input [3:0] A, output [15:0] Y);
//    wire [7:0] Y1, Y2;
//     assign Y = (en == 1'b1) ? {Y1, 8'b0} : {8'b0, Y2};
//      decoder3x8 deco1(.in(A), .out(Y1));
//      decoder3x8 deco2(.in(A), .out(Y2));
//      endmodule




//// 7-segment Decoder

module decoder_7seg( ////7_seg용 폰트변환기
    input [3:0] hex_value,
    output reg [7:0] seg_7
);    
    always @(hex_value) begin
        case(hex_value)
            4'b0000 : seg_7 = 8'b0000_0011;   //// a를 최상위 비트로 쓰자.
            4'b0001 : seg_7 = 8'b1001_1111;   
            4'b0010 : seg_7 = 8'b0010_0101;
            4'b0011 : seg_7 = 8'b0000_1101;
            4'b0100 : seg_7 = 8'b1001_1001;
            4'b0101 : seg_7 = 8'b0100_1001;
            4'b0110 : seg_7 = 8'b0100_0001;
            4'b0111 : seg_7 = 8'b0001_1111;
            4'b1000 : seg_7 = 8'b0000_0001;
            4'b1001 : seg_7 = 8'b0000_1001;   /// 0~9
            
            4'b1010 : seg_7 = 8'b0001_0001;   //// A~F
            4'b1011 : seg_7 = 8'b1100_0001;
            4'b1100 : seg_7 = 8'b0110_0011;
            4'b1101 : seg_7 = 8'b1000_0101;
            4'b1110 : seg_7 = 8'b0110_0001;
            4'b1111 : seg_7 = 8'b0111_0001; /// 모든 경우의 수를 다 썼다면, default 안 써줘도 된디.
        endcase //// 0~F까지 출력 코드
    end /// end 먼저 써주는 습관을 들이자.
endmodule

module fnd_test_top(  /// 보드의 입출력과 연결해주는 모듈을 top module
    input clk,
    output [7:0] seg_7,
    output [3:0] com    ///4bit 짜리라 com 단자가 4개 있다.
);
    assign com = 4'b1000;  //// 7_seg에서 실제로 출력되는 위치가 com(ct1~ct4)
    
    reg [25:0] clk_div;    
    always @(posedge clk) //// posedge : rising edge
        clk_div = clk_div +1; //// block(begin-end) 안에 문장이 하나밖에 없다면, block 생략 가능하다.
    
    reg [3:0] count;
    always @(negedge clk_div[25]) begin //// 약 0.5초마다 count가 증가한다.(보드의 주기 : 8ns) → 8ns x 2^26 = 0.56 sec
                                        //// 2진수에서 다음 bit의 주기는 이전 bit 주기의 2배
        count = count+1; 
    end
    
//    wire [7:0] seg_7_font;
//    decoder_7seg seg7( .hex_value(count), .seg_7(seg_7_font));
//    assign seg_7 = ~seg_7_font;     /// 만약에 font가 반대로 출력될 경우에 이 구문 사용해서 seg_7을 반전시켜주면 된다.
    
    decoder_7seg seg7( .hex_value(count), .seg_7(seg_7));  /// 디코더의 seg_7을 탑모듈의 seg_7에 연결
endmodule


module encoder_4_2(
    input [3:0] d,
    output [1:0] b
);
    assign b = (d == 4'b0001) ? 2'b00 : (d == 4'b0010) ? 2'b01 : (d == 4'b0100) ? 2'b10 : 2'b11;
    //// d == 4'b1111 이라면, 2'b11 이 출력된다. 근데 신경쓰지 마라
    //// 인코더는 입력이 0001, 0010, 0100, 1000 이렇게 4가지 이외의 신호가 없다! 는 전제 하에 만들어진다.
    //// 근데 vivado는 입력이 4개 뿐이라는 걸 모른 채로 회로 만들어버림.

endmodule


module mux_2_1_s(  /// 2_1 Mux의 구조적 모델링
    input [1:0] d,
    input       s,
    output      f    
);
    wire sbar, a0, a1;
    not(sbar, s);
    and(a0, d[0], sbar);
    and(a1, d[1], s);
    or(f, a0, a1);

endmodule


module mux_2_1_d( /// dataflow modeling
    input [1:0] d,
    input       s,
    output      f
);

    assign f = s ? d[1] :  d[0];

endmodule


module mux_4_1_d(
    input [3:0] d,
    input [1:0] s, /// 4개 중에 1개 골라야 한다. -> s = 2개,  2^2
    output      f
);
    assign f = d[s];
endmodule

module mux_8_1_d(
    input [7:0] d,
    input [2:0] s, /// 8개 중에 1개 골라야 한다. -> s = 3개, 2^3
    output      f
);
    assign f = d[s];
endmodule


module demux_1_4( /// 1입력에 4출력 demux
    input d,
    input [1:0] s, /// 4bit의 출력을 선정하위한 2bit s
    output reg [3:0] f
);
    
    always @(d, s) begin /// 입력이 다 들어갔다면, *로 대체 가능하다 always @* begin
//        f[s] = d;   /// 이 것만 써주면 안 된다..
          f = 0;      /// 초기화 먼저 해줘야 함.
                      /// 예를 들어 f[3] = d 가 출력된다고 가정해보자, 만약 초기화를 해주어야 다른 출력(f[2:0])에서는 초기화값(0)이 출력되고 f[3]에서만 d가 출력된다.
          f[s] = d;
          
//          assign f = (s==2'b00) ? {3'b000,d} : (s==2'b01) ? {2'b00, d, 1'b0} : (s==2'b10) ? {1'b0, d, 2'b00} : {d,3'b000};   ---- dataflow modeling
           /// 좌변과 우변의 bit 수를 맞춰줘야 한다. 부족하면 z, 많으면 overflow
    end
endmodule


module mux_test_top(
    input [7:0] d,
    input [2:0] s_mux,
    input [1:0] s_demux,
    output [3:0] f
);
    wire w;
    
    mux_8_1_d mux(.d(d), .s(s_mux), .f(w));
    demux_1_4 demux(.d(w), .s(s_demux), .f(f));
endmodule


module bin_to_dec( //// 12bit binary를 받아서 16bit decimal로 변환
    input [11:0] bin, 
    output reg [15:0] bcd /// 올림수가 하나만 나와도 4자리 다 읽어야 해서 vector : 16
);
    reg [3:0] i;
    
    always @(bin) begin //// FND 출력할 때 자주 써먹게 될 것임.
        bcd = 0;
        for (i=0 ; i<12 ; i=i+1) begin
            bcd = {bcd[14:0], bin[11-i]};  //// 쉬프트 연산을 결합연산자로 표현(회로가 더 간단해진다.)
                                           //// 좌로 1bit 쉬프트하고, 빈 자리에는 bin[11-i]를 넣어 준다.
            if ( i < 11 && bcd[3:0] > 4) bcd[3:0] = bcd[3:0] + 3;
            if ( i < 11 && bcd[7:4] > 4) bcd[7:4] = bcd[7:4] + 3;
            if ( i < 11 && bcd[11:8] > 4) bcd[11:8] = bcd[11:8] + 3;
            if ( i < 11 && bcd[15:12] > 4) bcd[15:12] = bcd[15:12] + 3;
        end
    end
endmodule

///// 여까지 combinational logic