module Rsa256Core(
	input i_clk,
	input i_rst,
	input i_start,
	input [255:0] i_a,
	input [255:0] i_e,
	input [255:0] i_n,
	output [255:0] o_a_pow_e,
	output o_finished
);
// a ^ e mod n

//Power Block State
localparam S_POW_IDLE        = 0;
localparam S_POW_START       = 1;
localparam S_POW_PREPROCESS  = 2;
localparam S_POW_LOOP_READY  = 3;
localparam S_POW_WAIT_NEEDIT = 4;
localparam S_POW_WAIT        = 5;

//Mutiply Block State
localparam S_MUL_IDLE  = 0;
localparam S_MUL_START = 1;
localparam S_MUL_CALC  = 2;


logic[2:0] pow_state_r,pow_state_w;
logic[1:0] mul_state_r,mul_state_w;
logic[15:0] pow_cnt_r,pow_cnt_w,mul_cnt_r,mul_cnt_w,pre_cnt_r,pre_cnt_w;
logic[255:0] a_r,e_r,n_r, a_w, e_w, n_w;
logic[256:0] a256_r,a256_w;
logic[256:0] ans_r,ans_w;
logic[257:0] mul_ans_r,mul_ans_w;
logic[255:0] mul_a_r, mul_a_w;
logic[255:0] mul_b_r, mul_b_w;
logic[257:0] mul_tmp1;
//task InitCalc;
//endtask

assign o_a_pow_e = ans_r;
assign o_finished = (pow_state_r == S_POW_IDLE);
always_comb begin

	pow_state_w = pow_state_r;
	mul_state_w = mul_state_r;
	pre_cnt_w = pre_cnt_r;
	pow_cnt_w = pow_cnt_r;
	mul_cnt_w = mul_cnt_r;
	ans_w = ans_r;
	mul_ans_w = mul_ans_r;
	a256_w = a256_r;
	mul_a_w = mul_a_r;
	mul_b_w = mul_b_r;
	a_w = a_r;
	e_w = e_r;
	n_w = n_r;
	mul_tmp1 = 0;

	//Power-Mont Block
	case(pow_state_r)
		S_POW_START:begin
			pre_cnt_w = 0;
			a256_w = a_r;
			ans_w = 1;
			pow_state_w = S_POW_PREPROCESS;
		end

		S_POW_PREPROCESS:begin
			if (pre_cnt_r == 256) begin
				pow_cnt_w = 0;
				pow_state_w = S_POW_LOOP_READY;
			end
			else begin
				if ((a256_r << 1) >= n_r)
					a256_w = (a256_r << 1) - n_r;
				else
					a256_w = a256_r << 1;
				pre_cnt_w = pre_cnt_r + 1;
			end
		end

		S_POW_LOOP_READY:begin
			//$display("256%d", a256_r);
			//$display("ans%d", ans_r);
			if (pow_cnt_r == 256)
				pow_state_w = S_POW_IDLE;
			else begin
				if (e_r & (1 << pow_cnt_r)) begin //need_it
					mul_a_w = ans_r;
					mul_b_w = a256_r;
					pow_state_w = S_POW_WAIT_NEEDIT;
					mul_state_w = S_MUL_START;
				end
				else begin
					mul_a_w = a256_r;
					mul_b_w = a256_r;
					pow_state_w = S_POW_WAIT;
					mul_state_w = S_MUL_START;
				end
				pow_cnt_w = pow_cnt_r + 1;
			end
		end

		S_POW_WAIT_NEEDIT:begin
			if(mul_state_r == S_MUL_IDLE)begin
				ans_w = mul_ans_r;

				mul_a_w = a256_r;
				mul_b_w = a256_r;
				pow_state_w = S_POW_WAIT;
				mul_state_w = S_MUL_START;
			end
		end

		S_POW_WAIT:begin
			if(mul_state_r == S_MUL_IDLE)begin
				a256_w = mul_ans_r;
				pow_state_w = S_POW_LOOP_READY;
			end
		end

		S_POW_IDLE:begin
			if (i_start) begin
				a_w = i_a;
				e_w = i_e;
				n_w = i_n;
				pow_state_w = S_POW_START;
			end
		end
	endcase
	//Multiply-Mont Block
	case(mul_state_r)
		S_MUL_IDLE:begin
		end

		S_MUL_START:begin
			mul_cnt_w = 0;
			mul_ans_w = 0;
			mul_state_w = S_MUL_CALC;
		end

		S_MUL_CALC:begin
			if (mul_cnt_r == 256) begin
				if (mul_ans_r >= n_r) mul_ans_w = mul_ans_r - n_r;
				mul_state_w = S_MUL_IDLE;
			end

			else begin
				if (mul_b_r & (1 << mul_cnt_r)) mul_tmp1 = mul_ans_r + mul_a_r;//needit
				else mul_tmp1 = mul_ans_r;

				if (mul_tmp1[0]) mul_ans_w = (mul_tmp1 + n_r) >> 1;
				else mul_ans_w = (mul_tmp1 >> 1);

				mul_cnt_w = mul_cnt_r + 1;
			end
		end
	endcase
end

always_ff @(posedge i_clk or posedge i_rst) begin
	if (i_rst) begin
		pow_state_r <= S_POW_IDLE;
		mul_state_r <= S_MUL_IDLE;

		pre_cnt_r <= 0;
		pow_cnt_r <= 0;
		mul_cnt_r <= 0;

		ans_r <= 0;
		mul_ans_r <= 0;

		a256_r <=0;
		mul_a_r <= 0;
		mul_b_r <= 0;
		a_r <= 0;
		e_r <= 0;
		n_r <= 0;
	end
	else begin
		pow_state_r <= pow_state_w;
		mul_state_r <= mul_state_w;
		pre_cnt_r <= pre_cnt_w;
		pow_cnt_r <= pow_cnt_w;
		mul_cnt_r <= mul_cnt_w;
		ans_r <= ans_w;
		mul_ans_r <= mul_ans_w;
		a256_r <= a256_w;
		mul_a_r <= mul_a_w;
		mul_b_r <= mul_b_w;
		a_r <= a_w;
		e_r <= e_w;
		n_r <= n_w;
	end
end
endmodule
