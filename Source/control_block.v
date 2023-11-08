`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/16 11:25:13
// Design Name: 
// Module Name: control_block
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


module control_block(
    input clk, reset_p,
    input [7:0] ir_data,
    input zero_flag, sign_flag,
    output mar_inen, mdr_inen, mdr_oen, ir_inen, pc_inc, load_pc, pc_oen,
           breg_inen, tmpreg_inen, tmpreg_oen, creg_inen, creg_oen,
           dreg_inen, dreg_oen, rreg_inen, rreg_oen,
           acc_high_reset_p, acc_oen, acc_in_select,
           op_add, op_sub, op_mul, op_div, op_and,
           inreg_oen, keych_reg_oen, keyout_reg_inen, outreg_inen, rom_en,
    output [1:0] acc_high_select, acc_low_select
    );
    
    wire [11:0] t;
    ring_counter_clk12_n ring_12(.clk(clk), .reset_p(reset_p), .t(t));
    
    wire nop, outb, outs, add_s, sub_s, and_s, div_s,
          mul_s, shl, clr_s, psah, shr, load, jz, jmp, jge,
          mov_ah_cr, mov_ah_dr, mov_tmp_ah, mov_tmp_br,
          mov_tmp_cr, mov_tmp_dr, mov_tmp_rr, mov_cr_ah, mov_cr_br,
          mov_dr_ah, mov_dr_tmp, mov_dr_br, mov_rr_ah,
          mov_key_ah, mov_inr_tmp, mov_inr_rr;
//    instr_decoder decode(
//          ir_data, nop, outb, outs, add_s, sub_s, and_s, div_s,
//          mul_s, shl, clr_s, psah, shr, load, jz, jmp, jge,
//          mov_ah_cr, mov_ah_dr, mov_tmp_ah, mov_tmp_br,
//          mov_tmp_cr, mov_tmp_dr, mov_tmp_rr, mov_cr_ah, mov_cr_br,
//          mov_dr_ah, mov_dr_tmp, mov_dr_br, mov_rr_ah,
//          mov_key_ah, mov_inr_tmp, mov_inr_rr
//          );
          
//    control_signal c_signal(
//          t, nop, outb, outs, add_s, sub_s, and_s, div_s,
//          mul_s, shl, clr_s, psah, shr, load, jz, jmp, jge,
//          mov_ah_cr, mov_ah_dr, mov_tmp_ah, mov_tmp_br,
//          mov_tmp_cr, mov_tmp_dr, mov_tmp_rr, mov_cr_ah, mov_cr_br,
//          mov_dr_ah, mov_dr_tmp, mov_dr_br, mov_rr_ah,
//          mov_key_ah, mov_inr_tmp, mov_inr_rr, zero_flag, sign_flag,
//          mar_inen, mdr_inen, mdr_oen, ir_inen, pc_inc, load_pc, pc_oen,
//          breg_inen, tmpreg_inen, tmpreg_oen, creg_inen, creg_oen,
//          dreg_inen, dreg_oen, rreg_inen, rreg_oen,
//          acc_high_reset_p, acc_oen, acc_in_select,
//          op_add, op_sub, op_mul, op_div, op_and,
//          inreg_oen, keych_reg_oen, keyout_reg_inen, outreg_inen, rom_en,
//          acc_high_select, acc_low_select
//          );  
          
    instr_decoder decode(
          .ir_data(ir_data), .nop(nop), .outb(outb), .outs(outs), .add_s(add_s), .sub_s(sub_s), .and_s(and_s), .div_s(div_s),
          .mul_s(mul_s), .shl(shl), .clr_s(clr_s), .psah(psah), .shr(shr), .load(load), .jz(jz), .jmp(jmp), .jge(jge),
          .mov_ah_cr(mov_ah_cr), .mov_ah_dr(mov_ah_dr), .mov_tmp_ah(mov_tmp_ah), .mov_tmp_br(mov_tmp_br),
          .mov_tmp_cr(mov_tmp_cr), .mov_tmp_dr(mov_tmp_dr), .mov_tmp_rr(mov_tmp_rr), .mov_cr_ah(mov_cr_ah), .mov_cr_br(mov_cr_br),
          .mov_dr_ah(mov_dr_ah), .mov_dr_tmp(mov_dr_tmp), .mov_dr_br(mov_dr_br), .mov_rr_ah(mov_rr_ah),
          .mov_key_ah(mov_key_ah), .mov_inr_tmp(mov_inr_tmp), .mov_inr_rr(mov_inr_rr)
          );
          
    control_signal c_signal(
          .t(t), .nop(nop), .outb(outb), .outs(outs), .add_s(add_s), .sub_s(sub_s), .and_s(and_s), .div_s(div_s),
          .mul_s(mul_s), .shl(shl), .clr_s(clr_s), .psah(psah), .shr(shr), .load(load), .jz(jz), .jmp(jmp), .jge(jge),
          .mov_ah_cr(mov_ah_cr), .mov_ah_dr(mov_ah_dr), .mov_tmp_ah(mov_tmp_ah), .mov_tmp_br(mov_tmp_br),
          .mov_tmp_cr(mov_tmp_cr), .mov_tmp_dr(mov_tmp_dr), .mov_tmp_rr(mov_tmp_rr), .mov_cr_ah(mov_cr_ah), .mov_cr_br(mov_cr_br),
          .mov_dr_ah(mov_dr_ah), .mov_dr_tmp(mov_dr_tmp), .mov_dr_br(mov_dr_br), .mov_rr_ah(mov_rr_ah),
          .mov_key_ah(mov_key_ah), .mov_inr_tmp(mov_inr_tmp), .mov_inr_rr(mov_inr_rr), .zero_flag(zero_flag), .sign_flag(sign_flag),
          .mar_inen(mar_inen), .mdr_inen(mdr_inen), .mdr_oen(mdr_oen), .ir_inen(ir_inen), .pc_inc(pc_inc), .load_pc(load_pc), .pc_oen(pc_oen),
          .breg_inen(breg_inen), .tmpreg_inen(tmpreg_inen), .tmpreg_oen(tmpreg_oen), .creg_inen(creg_inen), .creg_oen(creg_oen),
          .dreg_inen(dreg_inen), .dreg_oen(dreg_oen), .rreg_inen(rreg_inen), .rreg_oen(rreg_oen),
          .acc_high_reset_p(acc_high_reset_p), .acc_oen(acc_oen), .acc_in_select(acc_in_select),
          .op_add(op_add), .op_sub(op_sub), .op_mul(op_mul), .op_div(op_div), .op_and(op_and),
          .inreg_oen(inreg_oen), .keych_reg_oen(keych_reg_oen), .keyout_reg_inen(keyout_reg_inen), .outreg_inen(outreg_inen), .rom_en(rom_en),
          .acc_high_select(acc_high_select), .acc_low_select(acc_low_select)
          );        

endmodule


module ring_counter_clk12_n(
input clk, reset_p,
    output [11:0] t
    );

    reg [11:0] temp;
    // 12 clk마다 명령 하나씩 처리하면 된다.
    always @(negedge clk or posedge reset_p) begin
        if(reset_p) temp = 12'b0000_0000_0000;
        else if(temp == 12'b0000_0000_0000) temp = temp + 1;
        else if(temp == 12'b1000_0000_0000) temp = 12'b0000_0000_0001;
        else temp = {temp[10:0], 1'b0}; // 좌시프트
    end
    
    assign t = temp;
    
endmodule


// 32가지 명령을 해석할 수 있는 명령어 디코더
module instr_decoder(
    input [7:0] ir_data,
    output reg nop, outb, outs, add_s, sub_s, and_s, div_s,
               mul_s, shl, clr_s, psah, shr, load, jz, jmp, jge,
               mov_ah_cr, mov_ah_dr, mov_tmp_ah, mov_tmp_br,
               mov_tmp_cr, mov_tmp_dr, mov_tmp_rr, mov_cr_ah, mov_cr_br,
               mov_dr_ah, mov_dr_tmp, mov_dr_br, mov_rr_ah,
               mov_key_ah, mov_inr_tmp, mov_inr_rr   
    );
    
    always @(ir_data) begin
        {nop, outb, outs, add_s, sub_s, and_s, div_s,
         mul_s, shl, clr_s, psah, shr, load, jz, jmp, jge,
         mov_ah_cr, mov_ah_dr, mov_tmp_ah, mov_tmp_br,
         mov_tmp_cr, mov_tmp_dr, mov_tmp_rr, mov_cr_ah, mov_cr_br,
         mov_dr_ah, mov_dr_tmp, mov_dr_br, mov_rr_ah,
         mov_key_ah, mov_inr_tmp, mov_inr_rr} = 0; // 모든 명령어 묶어서 0으로 초기화
      
         case(ir_data) // ROM에 저장되는 형태는 Hexa code로 저장
            // 다 0으로 초기화해줬으므로, 하나만 1 주면 된다.
            8'h00 : nop = 1;
            8'h0B : outb = 1;
            8'h07 : outs = 1;
            8'h50 : add_s = 1;
            8'h52 : sub_s = 1;
            8'h54 : and_s = 1;
            8'h55 : div_s = 1;
            8'h51 : mul_s = 1;
            8'h15 : shl = 1;
            8'h10 : clr_s = 1;
            8'h14 : psah = 1;
            8'h16 : shr = 1;
            8'hD6 : load = 1;
            8'hD0 : jz = 1;
            8'hD4 : jmp = 1;
            8'hD2 : jge = 1;
            8'h83 : mov_ah_cr = 1;
            8'h84 : mov_ah_dr = 1;
            8'h88 : mov_tmp_ah = 1;
            8'h8A : mov_tmp_br = 1;
            8'h8B : mov_tmp_cr = 1;
            8'h8C : mov_tmp_dr = 1;
            8'h8D : mov_tmp_rr = 1;
            8'h98 : mov_cr_ah = 1;
            8'h9A : mov_cr_br = 1;
            8'hA0 : mov_dr_ah = 1;
            8'hA1 : mov_dr_tmp = 1;
            8'hA2 : mov_dr_br = 1;
            8'hA8 : mov_rr_ah = 1;
            8'hB0 : mov_key_ah = 1;
            8'hB9 : mov_inr_tmp = 1;
            8'hBD : mov_inr_rr = 1;
         endcase 
    end
    
endmodule


module control_signal(
    input [11:0] t, // 링카운터의 출력을 입력 t로 받음
    input nop, outb, outs, add_s, sub_s, and_s, div_s,
          mul_s, shl, clr_s, psah, shr, load, jz, jmp, jge,
          mov_ah_cr, mov_ah_dr, mov_tmp_ah, mov_tmp_br,
          mov_tmp_cr, mov_tmp_dr, mov_tmp_rr, mov_cr_ah, mov_cr_br,
          mov_dr_ah, mov_dr_tmp, mov_dr_br, mov_rr_ah,
          mov_key_ah, mov_inr_tmp, mov_inr_rr, zero_flag, sign_flag,
    output mar_inen, mdr_inen, mdr_oen, ir_inen, pc_inc, load_pc, pc_oen,
           breg_inen, tmpreg_inen, tmpreg_oen, creg_inen, creg_oen,
           dreg_inen, dreg_oen, rreg_inen, rreg_oen,
           acc_high_reset_p, acc_oen, acc_in_select,
           op_add, op_sub, op_mul, op_div, op_and,
           inreg_oen, keych_reg_oen, keyout_reg_inen, outreg_inen, rom_en,
    output [1:0] acc_high_select, acc_low_select
    );
    
    assign pc_oen = t[0] | (t[3] & (load | jz | jmp | jge));
    assign mar_inen = t[0] | (( load | jz | jmp | jge ) & t[3]);
    assign pc_inc = t[1]|((load|jz|jmp|jge)&t[4]);
    assign mdr_oen = t[2]|((load|(zero_flag&jz)|(~sign_flag&jge)|jmp)&t[5]);
    assign ir_inen = t[2];
    assign tmpreg_inen = (t[3]&(mov_dr_tmp|mov_inr_tmp))|(t[5]&load);
    assign tmpreg_oen = t[3]&(outb|mov_tmp_ah|mov_tmp_br|mov_tmp_cr | mov_tmp_dr|mov_tmp_rr);
    assign creg_inen = t[3]&(mov_ah_cr|mov_tmp_cr);
    assign creg_oen = t[3]&(mov_cr_ah|mov_cr_br);
    assign dreg_inen = t[3]&(mov_ah_dr|mov_tmp_dr);
    assign dreg_oen = t[3]&(mov_dr_ah|mov_dr_br|mov_dr_tmp);
    assign rreg_inen = t[3]&(mov_tmp_rr|mov_inr_rr);
    assign rreg_oen = t[3]&mov_rr_ah;
    assign breg_inen = t[3]&(mov_tmp_br|mov_cr_br|mov_dr_br);
    assign load_pc = t[5]&((zero_flag&jz)|(~sign_flag&jge)|jmp);
    assign acc_oen = t[3]&(outs|mov_ah_cr|mov_ah_dr);
    assign acc_in_select = t[3]&(mov_tmp_ah|mov_cr_ah|mov_rr_ah|mov_key_ah|mov_dr_ah);
    assign acc_high_reset_p = t[3]&clr_s;
    assign acc_high_select[1] = (t[3]&(add_s|sub_s|and_s|div_s|mul_s|shl|mov_tmp_ah|mov_cr_ah|
        mov_rr_ah|mov_key_ah|mov_dr_ah))|(mul_s&(t[5]|t[7]|t[9]))|
        (div_s&(t[4]|t[5]|t[6]|t[7]|t[8]|t[9]|t[10]));
    assign acc_high_select[0] = (t[3]&(add_s|sub_s|and_s|mul_s|shr|mov_tmp_ah|mov_cr_ah|mov_rr_ah|
        mov_key_ah|mov_dr_ah))|(t[4]&(add_s|div_s|mul_s))|
        (mul_s&(t[5]|t[6]|t[7]|t[8]|t[9]|t[10]))| (div_s&(t[6]|t[8]|t[10]));
    assign acc_low_select[1] = (t[3]&(div_s|psah|shl))|(div_s&(t[5]|t[7]|t[9]|t[11]));
    assign acc_low_select[0] = (t[3]&(psah|shr))|(t[4]&(add_s|mul_s))|(mul_s&(t[6]|t[8]|t[10]));
    assign op_add = t[3]&add_s;
    assign op_sub = t[3]&sub_s;
    assign op_and = t[3]&and_s;
    assign op_div = div_s&(t[4]|t[6]|t[8]|t[10]);
    assign op_mul = mul_s&(t[3]|t[5]|t[7]|t[9]);
    assign rom_en = ~(t[1]|((load|jz|jmp|jge)&t[4]));
    assign mdr_inen = t[1]|((load|jz|jmp|jge)&t[4]);
    assign inreg_oen = t[3]&(mov_inr_tmp|mov_inr_rr);
    assign keych_reg_oen = t[3]&mov_key_ah;
    assign outreg_inen = t[3]&outs;
    assign keyout_reg_inen = t[3]&outb;

endmodule