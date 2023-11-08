`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/23 12:31:03
// Design Name: 
// Module Name: exam02_sequential_logic
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

module SR_latch(
    input R, S,
    output Q, Qbar
    );
    
    nor(Q, R, Qbar);  //// ������ ���� �ν��Ͻ� ���� ��. ----> primitive gate�� �ν��Ͻ����� ������ �� �ִ�.
    nor(Qbar, S, Q);  //// �ùķ��̼��ϸ� ���� �� ��. ��?? �ùķ��̼��� �̻����� ���길 �ϱ� ������.
    
endmodule

module Gated_SR_latch( //// SR �ø��÷��̶�� �θ��µ�, ������ FF�� �ƴ�.
                        //// edge trigering�ϸ� FF, level trigering�ϸ� LATCH
    input R, S, en,
    output Q, Qbar
    );
    
    wire and1_out, and2_out;
   
    and(and1_out, R, en);
    and(and2_out, S, en);
    nor(Q, and1_out, Qbar);
    nor(Qbar, and2_out, Q);
    
endmodule

module Gated_D_latch( //// 
    input D, en,
    output Q, Qbar
    );
    
    wire and1_out, and2_out, Dbar;
    
    not(Dbar, D);
    and(and1_out, Dbar, en);
    and(and2_out, D, en);
    nor(Q, and1_out, Qbar);
    nor(Qbar, and2_out, Q);
    
endmodule


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////LATCH ��� ����////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////



module D_flip_flop_n(
    input d,
    input clk,rst,
    output reg q
);
    always @(negedge clk, posedge rst) begin /// edge trigering
        if(rst) q = 0; ///// FF�� ���� ����� �� �־�� �Ѵ�.
        else q = d; 
    end
    
//    always @(clk) begin /// high level���� �����ϴ� level-trigering ----> LATCH
//        if(clk) q = d;  /// FPGA ������ LATCH�� ������ �ʵ��� �����ؾ� �ϴ� ȸ��.
//        else q = q;     /// �߰� �������� ���ļ� ������ ������ pdt�� �����(Ÿ�̹� ������ �����.)
//    end                 /// ������ ��� �ݵ�ü�� ������ �ô뿡�� LATCH�� pdt�� ���� �� ��
                          /// FF�� edge���� �����ϱ� ������ Ÿ�̹� ������ ����.
endmodule

//  always @(clk) begin
//      in(clk) q = d;
//  end  //// vivado�� �� ������ ���� LATCH�� ����� ����
//       //// clk�� ��ȭ�� ����� �����ϴ� �ǵ�, if (clk) ������ clk�� 0�̸� q���� ������Ų�� ---> LATCH
         //// �׷��Ƿ� ���ճ�ȸ�θ� always�� �̿��ؼ� ������ ����. LATCH�� �����ȴ�.
         //// �׷��� ��� �ȴٸ�, if���� ���ٸ� �ݵ�� else������ְ�, case���ٸ� ����Ǽ��� �� ���ų� default�� �� ���ִ��� �ؾ� �ȴ�.
         //// ��ġ�����ϱ� �׳� ���� ��. 
         
module D_flip_flop_p(
    input d,
    input clk, rst,
    output reg q
);
    always @(posedge clk, posedge rst) begin /// edge trigering
        if(rst) q = 0;
        else q = d; 
    end
endmodule

module t_flip_flop_n( ///// ������ ������ ���� ���̴�. FPGA �ȿ��� DFF�� ����ִ�.(LUT���� �ڿ� DFF �ϳ��� �پ��ִ� ����)
    input clk,        ///// �ᱹ DFF�� �ٸ� FF�� ������ �Ѵ�.
    input rst, /// active high - rst, active low --- rstn
    output reg q
//    output reg q = 0 //----> �̷��� �����, �ùķ��̼��� ���� �ʱ�ȭ��.
);
//    wire d;
//    assign d = ~q;
    
//    always@(posedge clk) begin
//        q = d;

//    reg temp = 0; /// reg �ʱ�ȭ�� �ùķ��̼��� ���� ����.
//                 /// wire�� ������� ����. 0�� ������� ������ �����ع�����.
    always@(negedge clk, posedge rst) begin //// 
        if(rst) q = 0;
        else q = ~q; //// d = ~q �̴ϱ� �̷��� ���� ����
    end
endmodule

module t_flip_flop_p(
    input clk, rst,
    input t, /// t = cp_in���� ���� ��.
    output reg q
);

    always@(posedge clk, posedge rst) begin
        if(rst) q=0;
        else if (t) q = ~q;
              else q = q;  //// ��� FF(������ȸ��)������ ���� �Ƚ��൵ ��. ��¥�� ���� �����ϱ� ������.
                            //// ���ճ�ȸ�ο����� �� ����� �Ѵ�. �� ���ָ� LATCH�� �������.
    end
endmodule


module up_counter_async(
    input clk, rst,
    output [3:0] count
);
    t_flip_flop_n T0(.clk(clk), .rst(rst), .q(count[0]));
    t_flip_flop_n T1(.clk(count[0]), .rst(rst), .q(count[1]));
    t_flip_flop_n T2(.clk(count[1]), .rst(rst), .q(count[2]));
    t_flip_flop_n T3(.clk(count[2]), .rst(rst), .q(count[3]));

endmodule


module down_counter_async(
    input clk, rst,
    output [3:0] count
);
    t_flip_flop_p T0(.clk(clk), .rst(rst), .q(count[0])); //// ���� bit�� 0->1 �� �� ��, ���� bit ��� ===> posedge�� ��, ����� ���
    t_flip_flop_p T1(.clk(count[0]), .rst(rst), .q(count[1]));
    t_flip_flop_p T2(.clk(count[1]), .rst(rst), .q(count[2]));
    t_flip_flop_p T3(.clk(count[2]), .rst(rst), .q(count[3]));

endmodule


module up_counter_sync( //// ����� ��ī����
    input clk, rst,
    output reg [3:0] count
);
    always @(posedge clk, posedge rst) begin //// ������ �𵨸����� ���ָ� �˾Ƽ� �������.
        if(rst) count = 0; //// �ʱⰪ ������ �ʼ�, �� ���ָ� z ���
        else count = count + 1;
    end       

endmodule

module down_counter_sync( //// ����� �ٿ�ī����
    input clk, rst,
    output reg [3:0] count
);
    always @(posedge clk, posedge rst) begin //// ������ �𵨸����� ���ָ� �˾Ƽ� �������.
        if(rst) count = 0; //// �ʱⰪ ������ �ʼ�, �� ���ָ� z ���
        else count = count - 1;
    end       

endmodule

module up_down_counter_sync(
    input clk, rst,
    input up_down,   ///// up_down = 1�̸�, up_counter
    output reg [3:0] count
);
    always @ (posedge clk, posedge rst) begin
        if(rst) count = 0; //// �׻� ������ �켱�� �Ǿ�� �Ѵ�.
        else if (up_down) count = count + 1;
        else count = count - 1;
    end
endmodule


module up_counter_sync_BCD( //// ����� 10�� ��ī����(0~9)
    input clk, rst,
    output reg [3:0] count
);
    always @(posedge clk, posedge rst) begin
        if(rst) count = 0; 
        else begin
            if(count >= 9) count = 0; //// =�̶� �� ���� >=��� �� ���� : �ϵ����� 9�� �ǳʶ� ���� �ֱ� ������(������ ���ɼ��� ����)
            else count = count + 1;
        end
    end       
endmodule


module up_down_counter_sync_BCD( //// ����� 10�� ���ٿ�ī����(0~9)
    input clk, rst, up_down,
    output reg [3:0] count
);
    always @(posedge clk, posedge rst) begin
        if(rst) count = 0; 
        else begin
            if(up_down) begin
                if(count >= 9) count = 0; //// 0~9�����̹Ƿ� 9 �Ѿ�� �ٽ� 0���� ����
                else count = count + 1;
            end
            else begin
                if(count == 0) count = 9; //// 0~9�����̹Ƿ� 0�̵Ǹ� �ٽ� 9���� ����
                else count = count - 1;
            end
        end
    end       
endmodule


//=============================================================================================================//
////////////////////////////////////////////////counter Ȱ��/////////////////////////////////////////////////////
//=============================================================================================================//


module ring_count_fnd(  //// ���� �α��� ���
    input clk,
    output [3:0] com
);
    reg [3:0] temp; //// �ʱⰪ�� ������� �ϹǷ� temp ����
    
    always @ (posedge clk) begin /// FND�� common anode type
        if(temp != 4'b1110 && temp != 4'b1101 && temp != 4'b1011 && temp != 4'b0111) temp = 4'b1110; // 
                                 /// rst ������, count = 0�� �¾�, �� com���� 0000�� �Ǵ� ����?
                                 /// ���� common cathod type�� ��쿡�� rst ������ com = 4'b1111�� �Ǿ�� �ϴµ� �̰� ��� �ڵ�?
                                 /// �ʱⰪ�� 1110 
                                 /// 0���� �� ������ FND�� 4'b1110
        else if (temp == 4'b0111) temp = 4'b1110; //// 0111 �Ǹ� 1110�� ���ƿͶ�
              else temp = {temp[2:0], 1'b1}; /// ���տ����� �̿��Ͽ� �½���Ʈ
    end //// 1110 1101 1011 0111 �� �ݺ��ϴ� ��ī���� 
    
//    always @ (posedge clk) begin /// FND�� common cathode type�� ���.
//        if(rst) com = 4b'1111;
//        else if (com != 4'b0001 && com != 4'b0010 && com != 4'b0100 && com != 4'b1000) com = 4'b0001;
//            else if (com == 4'b1000) com = 4'b0001;
//                  else com = {com[2:0], 1'b0};
//    end
    
    assign com = temp; //// temp�� �ٽ� com�̶�� ��¿� ��������ش�.
endmodule


module up_down_counter_Nbit #(parameter N = 4)( //// Nbit ���ٿ� ī���� 
    input clk, rst, up_down,
    output reg [N-1:0] count
);

    always @(posedge clk, posedge rst) begin
        if(rst) count = 0; 
        else begin
            if(up_down)
                count = count + 1;
            else 
                count = count - 1;
        end
    end       
endmodule


module edge_detector_n( /// falling edge detector ./// 2bit¥�� ����Ʈ ��������(SI-PO)
    input clk, cp_in, rst, /// cp : clock pulse
    output p_edge, n_edge /// ���� ª�� �޽� �ϳ��� ������.
);
    reg cp_in_old, cp_in_cur;
    
    always @ (negedge clk, posedge rst) begin
        if(rst) begin
             cp_in_old = 0;
             cp_in_cur = 0;
        end
        else begin
            cp_in_old = cp_in_cur; /// <= : ���� ������(=�� ������ ���) non-blocking ���� ���� ������ ���� ���� ������ non-blocking
            cp_in_cur = cp_in;     /// ������ȸ�ο����� non-blocking�� ������ ���� ���� �����ϴ�.
                                    /// ���ճ�ȸ��(level triggering)������ ������ blocking
                                    /// ��� ���� �� ���϶��� �ƹ��ų� �ᵵ �������.
        end
    end
    
    assign p_edge = ~cp_in_old & cp_in_cur; //// cp_old�� ���� 0�̴ϱ� ����
    assign n_edge = cp_in_old & ~cp_in_cur; //// cp_cur�� ���� 0�� �Ǿ����Ƿ� ����������

endmodule

module edge_detector_p( /// falling edge detector ./// 2bit¥�� ����Ʈ ��������(SI-PO)
    input clk, cp_in, rst, /// cp : clock pulse
    output p_edge, n_edge /// ���� ª�� �޽� �ϳ��� ������.
);
    reg cp_in_old, cp_in_cur;
    
    always @ (posedge clk, posedge rst) begin
        if(rst) begin
             cp_in_old = 0;
             cp_in_cur = 0;
        end
        else begin
            cp_in_old = cp_in_cur; /// <= : ���� ������(=�� ������ ���) non-blocking ���� ���� ������ ���� ���� ������ non-blocking
            cp_in_cur = cp_in;     /// ������ȸ�ο����� non-blocking�� ������ ���� ���� �����ϴ�.
                                    /// ���ճ�ȸ��(level triggering)������ ������ blocking
                                    /// ��� ���� �� ���϶��� �ƹ��ų� �ᵵ �������.
        end
    end
    
    assign p_edge = ~cp_in_old & cp_in_cur; //// cp_old�� ���� 0�̴ϱ� ����
    assign n_edge = cp_in_old & ~cp_in_cur; //// cp_cur�� ���� 0�� �Ǿ����Ƿ� ����������

endmodule

//=============================================================================================================//
////////////////////////////////////////////////   Register   ///////////////////////////////////////////////////
//=============================================================================================================//


//module shift_register_SISO_s( /// SISO register ������ �𵨸�
//    input clk, rst, d,
//    output q
//);
////    wire w1, w2, w3;  // �̷��� wire �������൵ �ȴ�.
//    wire [2:0] w;
//    D_flip_flop_n SS1(.d(d), .clk(clk), .rst(rst), .q(w[2]));
//    D_flip_flop_n SS2(.d(w[2]), .clk(clk), .rst(rst), .q(w[1]));
//    D_flip_flop_n SS3(.d(w[1]), .clk(clk), .rst(rst), .q(w[0]));
//    D_flip_flop_n SS4(.d(w[0]), .clk(clk), .rst(rst), .q(q));

//endmodule /// ������ �𵨸��� �� �� �ž�.

module shift_register_SISO_b_n( /// SISO register ������ �𵨸�
    input clk, rst, d,
    output reg q
);    
    reg [3:0] siso;    
//    always@(negedge clk, posedge rst) begin /// �̷��� ����� �� �ȴ�~
////        if(rst) siso = 0;
////        else begin
////            siso[3] = d;                        /// blocking���� ����� �ȵ�
////            siso[2] = siso[3];                  /// 4bit�� �� 1�� �Ǿ������.
////            siso[1] = siso[2];
////            siso[0] = siso[1];
////            q = siso[0];
////        end
////    end    
     always@(negedge clk, posedge rst) begin 
        if(rst) siso = 0;
        else begin
            siso[3] <= d;
            siso[2] <= siso[3];
            siso[1] <= siso[2];
            siso[0] <= siso[1];
            q = siso[0];
        end
    end    
endmodule


module shift_register_PISO( /// ���� �Է� - ���� ���
    input clk, rst, w_piso, /// �Է��� w(write), ����� r(read)�� ����.
    input [3:0] d,
    output q
);
    reg [3:0] data;
    
    always @ (posedge clk, posedge rst) begin
        if(rst) data = 0;
        else if(w_piso) data = {1'b0, data[3:1]}; //// Ŭ������ ���ķ� �Էµ� ���� �� bit�� ��µȴ�.
             else data = d;
    end
    
    assign q = data[0];

endmodule


module shift_register_SIPO_s( /// ���� �Է�-���� ��� 
    input clk, rst, d, r_en,
    output [3:0] q
);
    wire [3:0] shift_register;
    D_flip_flop_n SP1(.d(d), .clk(clk), .rst(rst), .q(shift_register[3]));
    D_flip_flop_n SP2(.d(shift_register[3]), .clk(clk), .rst(rst), .q(shift_register[2]));
    D_flip_flop_n SP3(.d(shift_register[2]), .clk(clk), .rst(rst), .q(shift_register[1]));
    D_flip_flop_n SP4(.d(shift_register[1]), .clk(clk), .rst(rst), .q(shift_register[0]));
    
    bufif0 (q[0], shift_register[0], ~r_en); /// bufif : 3-state buffer
    bufif0 (q[1], shift_register[1], ~r_en); /// r_en = 0�϶�, q[] = shift_register[]
    bufif0 (q[2], shift_register[2], ~r_en); /// bufif0 (���, �Է�, �����ȣ)
    bufif0 (q[3], shift_register[3], ~r_en);

endmodule


module shift_register_SIPO_h(
    input d, clk, rst, r_en,
    output [3:0] q
);
    reg [3:0] register;
    always@(negedge clk or posedge rst) begin
        if(rst) register <= 0;
        else register <= {d,register[3:1]}; //// �ϳ��� �а� �ֻ�����Ʈ���� �޴� ����Ʈ ��������
    end
    assign q = (r_en) ? register : 4'bzzzz; //// r_en = 1, register ���, �ƴϸ� z
endmodule




module shift_register_PIPO #(parameter N=8)(//// �����Է� - ������� reg ---> �̰� �׳� �������Ͷ�� �θ���.
     input [N-1:0] d,
     input clk, rst, w_en, r_en,
     output q
);
    reg [N-1:0] register;
    always@(posedge clk, posedge rst) begin
        if(rst) register = 0;
        else if(w_en) register = d; /// 4bit¥�� 4bit�� ����(PI)
            else register = register; 
    end
    
    assign q = r_en ? register : 'bz;
     /// 4bit¥�� 4bit�� �����.(PO)
     /// 'bz : �� bit�� �Ǵ� z�� �� ä������ ������.

endmodule




module shift_register( /// ���� ����Ʈ ��������
    input clk, rst, shift, load, sin, /// sin : serial input
    input [7:0] data_in, /// data_in : parallel input
    output reg [7:0] data_out
);
    
    always@(posedge clk, posedge rst) begin
        if(rst) data_out = 0;
        else if(shift) data_out = {sin, data_out[7:1]}; /// �����Է¹޾Ƽ� ����Ʈ�ϰ� ���
             else if(load) data_out = data_in; /// 
                  else data_out = data_out;
     end
endmodule


module sram_8bit_1024( /// 1kbyte static �޸�(reg �̾� ���� ���� static memory��� �Ѵ�.)
                       /// address(select bit)�� 10bit(2^10�̴ϱ�)
    input clk, w_en, r_en, /// �޸𸮴� �������� �����Ƿ� rst ����.
    input [9:0] addr,
    inout [7:0] data/// inout : ��ǲ�� �ǰ� �ƿ�ǲ�� �ǰ� ����
);

    reg [7:0] mem [0:1023]; //// 0~1023������ array
    always @(posedge clk)
        if(w_en) mem[addr] <= data; /// else�̸� �׳� ����
                                    /// 0�� �޸𸮿� �����ϴ� ���� mem[0],
                                    /// ���⼭ []�� bit�� �ƴ�, �迭�� �ǹ��Ѵ�.

    assign data = r_en ? mem[addr] : 8'bz; /// w_en / r_en ��ҿ��� 0���� �����ϰ� �ִٰ� �ʿ��� ���� 1 �༭ ��.
    
endmodule


module register_Nbit_p #(parameter N = 8)(
        input [N-1:0] d,
        input clk, reset_p, wr_en, rd_en,
        output [N-1:0] q
    );

    reg [N-1:0] register_temp;
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)register_temp = 0;
        else if(wr_en) register_temp = d;
    end

    assign q = rd_en ? register_temp : 'bz;
    
endmodule

module register_Nbit_p_alltime #(parameter N = 8)(
        input [N-1:0] d,
        input clk, reset_p, wr_en, rd_en,
        output [N-1:0] register_data, // ��� ���
        output [N-1:0] q
    );

    reg [N-1:0] register_temp;
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)register_temp = 0;
        else if(wr_en) register_temp = d;
    end

    assign q = rd_en ? register_temp : 'bz;
    assign register_data = register_temp; // enable ��ȣ�� ������� ������ ��µ�.
    
endmodule