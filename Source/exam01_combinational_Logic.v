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


module and2_gate(  /////////// module ����(���� ����); 
    input A,
    input B,
    output F
    );
    
    and(F, A, B);  /////// gate(���, �Է�); ------> �̰� ��ü�� ���
endmodule    //// primitive gate ����(������Ƽ�� ����Ʈ�� ����� 1��)


module half_adder(  ////// half addr�� ���, ��������
    input A,
    input B,
    output sum,
    output carry
 );
    xor(sum, A, B); ////// xor gate ����
    and(carry, A, B); ////// and gate ����
 endmodule  ///// ������ �𵨸��� ASIC������ �����������, FPGA������ ��ȿ����

/////////////////////////////////////////////////////////////////////////////////
module half_adder_dataflow(   ///// �������÷ο� �𵨸�
                              /////assign ���� Ȱ���Ͽ� �������� ����� ǥ��
    input A,
    input B,
    output sum,
    output carry
 );
    assign sum = A^B;  ///// xor
    assign carry = A&B; ///// and 
endmodule // ������ half addr�� �� ���� ���� ����� ��.
//////////////////////////////////////////////////////////////////////////////////

module half_adder_4bit(
    // load_data �� 1�� �����ִ� ����� �Ѵ�.
    // ���� �����̱� ������ 0 �Ǵ� 1���� ������ �� �ִ�.
    // 1�� �����ϴ� ī���͸� �� �ɷ� ������� �� ����.
    input inc,
    input [3:0] load_data, 
    output [3:0] sum
    );
    
    // half adder 3���� ������.
//    wire [3:0] carry_out;
//    half_adder_dataflow ha0(.A(inc), .B(load_data[0]), .sum(sum[0]), .carry(carry_out[0]));
//    half_adder_dataflow ha1(.A(carry_out[0]), .B(load_data[1]), .sum(sum[1]), .carry(carry_out[1]));
//    half_adder_dataflow ha2(.A(carry_out[1]), .B(load_data[2]), .sum(sum[2]), .carry(carry_out[2]));
//    half_adder_dataflow ha3(.A(carry_out[2]), .B(load_data[3]), .sum(sum[3]), .carry(carry_out[3]));
    
    // �� �ڵ带 for������ ������.
    wire [3:0] carry_out;
    half_adder_dataflow ha0(.A(inc), .B(load_data[0]), .sum(sum[0]), .carry(carry_out[0]));
    // for������ ������ �𵨸��� ��
    genvar i; // ��� ȸ�η� �� ���������. �ܼ��� for�������� �� ����
    generate
        for(i = 1 ; i < 4 ; i = i + 1) begin
            half_adder_dataflow ha(.A(carry_out[i-1]), .B(load_data[i]), .sum(sum[i]), .carry(carry_out[i]));
        end
    endgenerate
endmodule


module half_adder_N_bit #(parameter N = 8)(
    // load_data �� 1�� �����ִ� ����� �Ѵ�.
    // ���� �����̱� ������ 0 �Ǵ� 1���� ������ �� �ִ�.
    // 1�� �����ϴ� ī���͸� �� �ɷ� ������� �� ����.
    input inc,
    input [N-1:0] load_data, 
    output [N-1:0] sum
    );

    wire [N-1:0] carry_out;
    half_adder_dataflow ha0(.A(inc), .B(load_data[0]), .sum(sum[0]), .carry(carry_out[0]));
    // for������ ������ �𵨸��� ��
    genvar i; // ��� ȸ�η� �� ���������. �ܼ��� for�������� �� ����
    generate
        for(i = 1 ; i < N ; i = i + 1) begin
            half_adder_dataflow ha(.A(carry_out[i-1]), .B(load_data[i]), .sum(sum[i]), .carry(carry_out[i]));
        end
    endgenerate
endmodule




module half_adder_behaviaral(   ///// ������ �𵨸�(always �� ���)
    input A,
    input B,
    output reg sum, //// always ������ ������ ������ reg������ ����Ǿ�� �Ѵ�.
    output reg carry
 );
    always @(A, B) begin //// begin~end �� block�� ����� �ش�.
        case({A, B})
            2'b00: begin sum = 0; carry = 0; end ///// A=0, B=0 �̸�, sum=0, carry=0 �̴�.
            2'b01: begin sum = 1; carry = 0; end
            2'b10: begin sum = 1; carry = 0; end
            2'b11: begin sum = 0; carry = 1; end
        endcase
    end
endmodule


////// Full_adder �����


module full_adder_structure( //// half_addr �ΰ��� ����(������ �𵨸�)
        input A, B, cin, 
        output sum, carry 
    );  ///// ������ ���� fulladdr�� ������ ������.
    
    wire sum_0; /// sum_0��� wire ����
    wire carry_0;   //// wire sum_0, carry_o; �̷��� ���� �ȴ�.
    wire carry_1;
    
    half_adder ha0 ( /// ù ���� half_addr --- half_addr�� �ν��Ͻ��� ��, ha0 : �ν��Ͻ���
                     //// instance(�ν��Ͻ�) : ����� ������ ����Ʈ�� �����.
    .A(A), /// .A : half_adder�� A        (A) : ���� ����� ����� A
    .B(B),
    .sum(sum_0), /// half_adder�� sum���ٰ� sum_0�� �����Ѵ�.
    .carry(carry_0)
    ); 
    half_adder ha1 (.A(sum_0), .B(cin), .sum(sum), .carry(carry_1));
    
    or(carry, carry_0, carry_1);
endmodule


module full_adder(
        input A, B, cin, 
        output sum, carry 
    );
    
    assign sum = A^B^cin;  /// ���� �������� �����. ------------ ��
    assign carry = (cin&(A^B)) | (A & B); /// ���� �������� �����.----------��
     /// ^ : xor, | : or, & : and,
     /// Verilog�� ��� �踦 �ٲ㼭 ��� ����� ����.(���ÿ� ����Ǳ� ����)
     /// ��Ʈ �� �����ڸ� �Ἥ ������� ������, ������ �𵨸��̶� �� ���̰� ����.
    
    
endmodule


module full_4bit_s( 
    input [3:0] a, b, /// msb :�ֻ�����Ʈ, lsb :������ ��Ʈ, [msb:lsb] 
    input       cin,
    output [3:0] sum, //// 4bit¥�� bus�� ������ ��µȴ�.
    output       carry
);
    wire [2:0] carry_in; /// wire 3��
    
    full_adder fa0 ( /// ������ ���� full adder instance
    .A(a[0]),     //// a[0] :4bit¥�� a�� 0���� bit
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
    wire [4:0] temp; /// carry�� �ڸ��� [5], [3:0]�� sum
    
    assign temp = a + b + cin; /// ��Ʈ�����ڰ� �ƴ�, ��Ģ�����ڸ� ����Ͽ���. ---> ȸ�ΰ� �޶���.
                               /// FPGA ���� �ִ� �����⸦ �̿��Ͽ� ȸ�θ� �����Ѵ�.(�� �� �߻�ȭ ������ ����.)
    assign sum = temp[3:0];
    assign carry = temp[4];

endmodule

module fadd_sub_4bit_s( /// s : structure modeling
    input [3:0] a, b, /// msb :�ֻ�����Ʈ, lsb :������ ��Ʈ, [msb:lsb] 
    input       s,    /// : add s= 0; sub s = 1(s�� 1�� ������ �����, 0�̸� �����)
    output [3:0] sum, //// 4bit¥�� bus�� ������ ��µȴ�.
    output       carry
);
    wire [2:0] carry_in; /// wire 3��
    
    full_adder fa0 ( /// ������ ���� full adder instance
    .A(a[0]),     //// a[0] :4bit¥�� a�� 0���� bit
    .B(b[0]^s),
    .cin(s),
    .sum(sum[0]),
    .carry(carry_in[0])
    );
    full_adder fa1 (.A(a[1]), .B(b[1]^s), .cin(carry_in[0]), .sum(sum[1]), .carry(carry_in[1]));
    full_adder fa2 (.A(a[2]), .B(b[2]^s), .cin(carry_in[1]), .sum(sum[2]), .carry(carry_in[2]));
    full_adder fa3 (.A(a[3]), .B(b[3]^s), .cin(carry_in[2]), .sum(sum[3]), .carry(carry));
    
endmodule //// ,(�޸�) �ڿ��� �ݵ�� ����ȴ�. .(����) �ڿ��� ������� �׳� ���´�.


module fadd_sub_4bit_d( /// d : data flow modeling
    input [3:0] a, b,
    input       s,    
    output [3:0] sum, 
    output       carry
);
    wire [4:0] temp;
    
    assign temp = s ? a-b : a+b; /// s�� carry�� �ƴ϶� �����, ����� �� � ���� �� ���� �����ϴ� �뵵
                                  /// s = 0(����)�̸�, : ���� ���� s�� ����.
                                  /// s = 1(��)�̸�, : ���� ���� s�� ����.
    assign sum = temp[3:0];
    assign carry = s ? ~temp[4] : temp[4];
    
endmodule



module comparator_s(
    input A, B,
    output equal, greater, less
);
    assign equal = A ~^ B;
    assign greater = A & ~B;
    assign less = ~A & B; /// assign�� ������, �������ڸ� ���� ������ �𵨸��̶� �� ���̰� ����.
                           /// bit ���� ���� ȸ�θ� �ٽ� ¥��� �Ѵ�.
    
endmodule

module comparator #(parameter N=4)( /// # : compile ���þ�, �� ����� �ٸ� ������ �ν��Ͻ��� ��, N ���� �ٲ㼭 ����� �� �ִ�. default = 4(N=4�� �������־��� ����)
                     /// ���� �����ڸ� �Ἥ Data-flow modeling���� ����
                    /// �Է��� bit�� �ٲ��ָ�, ���� bit �� ������ �����ϴ�.
    input [N-1:0] A, B,
    output equal, greater, less
);
    assign equal = (A==B) ? 1'b1 : 1'b0; ///  
    assign greater = (A>B) ? 1'b1 : 1'b0; 
    assign less = (A<B) ? 1'b1 : 1'b0; 
    
endmodule

module decoder_2_4_b( /// �����ϴϱ� ������ �𵨸����� ����
    input [1:0] A,
    output reg [3:0] Y /// always���� data type�� reg
);
//    always @ (A) begin /// always @ (~) : ~�� ���ϸ� 1ȸ ����
//        case(A) //// case(~) : ~�� ������ ����� ���� �Ʒ��� �� �ִٸ�, ������µ� �ϳ��� �����ٸ� �� ���� ���� default�� ���
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


module decoder_2_4_d( /// data-flow modeling���� ���ڴ� ����
    input [1:0] A,
    output [3:0] Y /// assign���� data type�� wire
);
    assign Y=(A==2'b00) ? 4'b0001 : (A==2'b01) ? 4'b0010 : (A==2'b10) ? 4'b0100 : 4'b1000; 
                     /// Y ? ����1 : ����2; ----> ������ ���̸�, ����1�� �ް� �����̸� ����2�� �޴´�.
                     /// ��ó�� ���ǿ����ڸ� �ߺ����� ���(�������ǹ�)�ϸ� if-else���� dataflow�� ǥ���� �� �ִ�.
endmodule

module decoder_2_4_en_d( /// enable�� �ִ� 2-4 ���ڴ�
    input [1:0] A,
    input       en,  /// en = 0 : ��� ����� 0
    output [3:0] Y /// assign���� data type�� wire
);
    assign Y=(en==0) ? 4'b0000 : (A==2'b00) ? 4'b0001 : (A==2'b01) ? 4'b0010 : (A==2'b10) ? 4'b0100 : 4'b1000; 

endmodule

module decoder_2_4_en_b( /// enable�� �ִ� 2-4 ���ڴ�
    input [1:0] A,
    input       en,  /// en = 0 : ��� ����� 0
    output reg [3:0]  Y /// assign���� data type�� wire
);
        always @ (A) begin
         if(en) begin
            case(A) //// case(~) : ~�� ������ ����� ���� �Ʒ��� �� �ִٸ�, ������µ� �ϳ��� �����ٸ� �� ���� ���� default�� ���
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
    
//    always @(A0) begin  �̷� �����ε� �ڵ��� �����ϴ�.
//        if(!en) Y=0;
//            else if(A==2'b00) Y=4'b0001;
//            else if(A==2'b01) Y=4'b0010;
//            else if(A==2'b10) Y=4'b0100;
//            else Y=4'b1000;
//     end
endmodule


module decoder_3_8( /// 2_4 ���ڴ��� �� �� ��ġ��, 3_8 ���ڴ��� ���� �� �ִ�.
    input [2:0] D,
    output[7:0] Y
);
    decoder_2_4_en_d de1 ( .A(D[1:0]), .en(~D[2]), .Y(Y[3:0]));  /// �ν��Ͻ��� ��, ���� ����( = .A(D))�� ������ ������ ������� �ۼ����ָ� ��.
    decoder_2_4_en_d de2 ( .A(D[1:0]), .en(D[2]), .Y(Y[7:4]));
    
endmodule


// ������ �𵨸����� ����(3-8 ���ڴ� 2�� �̾�ٿ��� en�� �ִ� 4-16 ���ڴ������)
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

module decoder_7seg( ////7_seg�� ��Ʈ��ȯ��
    input [3:0] hex_value,
    output reg [7:0] seg_7
);    
    always @(hex_value) begin
        case(hex_value)
            4'b0000 : seg_7 = 8'b0000_0011;   //// a�� �ֻ��� ��Ʈ�� ����.
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
            4'b1111 : seg_7 = 8'b0111_0001; /// ��� ����� ���� �� ��ٸ�, default �� ���൵ �ȵ�.
        endcase //// 0~F���� ��� �ڵ�
    end /// end ���� ���ִ� ������ ������.
endmodule

module fnd_test_top(  /// ������ ����°� �������ִ� ����� top module
    input clk,
    output [7:0] seg_7,
    output [3:0] com    ///4bit ¥���� com ���ڰ� 4�� �ִ�.
);
    assign com = 4'b1000;  //// 7_seg���� ������ ��µǴ� ��ġ�� com(ct1~ct4)
    
    reg [25:0] clk_div;    
    always @(posedge clk) //// posedge : rising edge
        clk_div = clk_div +1; //// block(begin-end) �ȿ� ������ �ϳ��ۿ� ���ٸ�, block ���� �����ϴ�.
    
    reg [3:0] count;
    always @(negedge clk_div[25]) begin //// �� 0.5�ʸ��� count�� �����Ѵ�.(������ �ֱ� : 8ns) �� 8ns x 2^26 = 0.56 sec
                                        //// 2�������� ���� bit�� �ֱ�� ���� bit �ֱ��� 2��
        count = count+1; 
    end
    
//    wire [7:0] seg_7_font;
//    decoder_7seg seg7( .hex_value(count), .seg_7(seg_7_font));
//    assign seg_7 = ~seg_7_font;     /// ���࿡ font�� �ݴ�� ��µ� ��쿡 �� ���� ����ؼ� seg_7�� ���������ָ� �ȴ�.
    
    decoder_7seg seg7( .hex_value(count), .seg_7(seg_7));  /// ���ڴ��� seg_7�� ž����� seg_7�� ����
endmodule


module encoder_4_2(
    input [3:0] d,
    output [1:0] b
);
    assign b = (d == 4'b0001) ? 2'b00 : (d == 4'b0010) ? 2'b01 : (d == 4'b0100) ? 2'b10 : 2'b11;
    //// d == 4'b1111 �̶��, 2'b11 �� ��µȴ�. �ٵ� �Ű澲�� ����
    //// ���ڴ��� �Է��� 0001, 0010, 0100, 1000 �̷��� 4���� �̿��� ��ȣ�� ����! �� ���� �Ͽ� ���������.
    //// �ٵ� vivado�� �Է��� 4�� ���̶�� �� �� ä�� ȸ�� ��������.

endmodule


module mux_2_1_s(  /// 2_1 Mux�� ������ �𵨸�
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
    input [1:0] s, /// 4�� �߿� 1�� ���� �Ѵ�. -> s = 2��,  2^2
    output      f
);
    assign f = d[s];
endmodule

module mux_8_1_d(
    input [7:0] d,
    input [2:0] s, /// 8�� �߿� 1�� ���� �Ѵ�. -> s = 3��, 2^3
    output      f
);
    assign f = d[s];
endmodule


module demux_1_4( /// 1�Է¿� 4��� demux
    input d,
    input [1:0] s, /// 4bit�� ����� ���������� 2bit s
    output reg [3:0] f
);
    
    always @(d, s) begin /// �Է��� �� ���ٸ�, *�� ��ü �����ϴ� always @* begin
//        f[s] = d;   /// �� �͸� ���ָ� �� �ȴ�..
          f = 0;      /// �ʱ�ȭ ���� ����� ��.
                      /// ���� ��� f[3] = d �� ��µȴٰ� �����غ���, ���� �ʱ�ȭ�� ���־�� �ٸ� ���(f[2:0])������ �ʱ�ȭ��(0)�� ��µǰ� f[3]������ d�� ��µȴ�.
          f[s] = d;
          
//          assign f = (s==2'b00) ? {3'b000,d} : (s==2'b01) ? {2'b00, d, 1'b0} : (s==2'b10) ? {1'b0, d, 2'b00} : {d,3'b000};   ---- dataflow modeling
           /// �º��� �캯�� bit ���� ������� �Ѵ�. �����ϸ� z, ������ overflow
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


module bin_to_dec( //// 12bit binary�� �޾Ƽ� 16bit decimal�� ��ȯ
    input [11:0] bin, 
    output reg [15:0] bcd /// �ø����� �ϳ��� ���͵� 4�ڸ� �� �о�� �ؼ� vector : 16
);
    reg [3:0] i;
    
    always @(bin) begin //// FND ����� �� ���� ��԰� �� ����.
        bcd = 0;
        for (i=0 ; i<12 ; i=i+1) begin
            bcd = {bcd[14:0], bin[11-i]};  //// ����Ʈ ������ ���տ����ڷ� ǥ��(ȸ�ΰ� �� ����������.)
                                           //// �·� 1bit ����Ʈ�ϰ�, �� �ڸ����� bin[11-i]�� �־� �ش�.
            if ( i < 11 && bcd[3:0] > 4) bcd[3:0] = bcd[3:0] + 3;
            if ( i < 11 && bcd[7:4] > 4) bcd[7:4] = bcd[7:4] + 3;
            if ( i < 11 && bcd[11:8] > 4) bcd[11:8] = bcd[11:8] + 3;
            if ( i < 11 && bcd[15:12] > 4) bcd[15:12] = bcd[15:12] + 3;
        end
    end
endmodule

///// ������ combinational logic