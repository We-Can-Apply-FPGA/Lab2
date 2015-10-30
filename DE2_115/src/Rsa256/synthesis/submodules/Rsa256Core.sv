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

localparam S_IDLE        = 0;
localparam S_PREPROCESS  = 1;
localparam S_LOOP        = 2;
localparam S_NEED        = 3;
localparam S_NONEED      = 4;

logic[2:0] state_r, state_w;
logic[15:0] pow_cnt_r, pow_cnt_w, mul_cnt_r, mul_cnt_w, pre_cnt_r, pre_cnt_w;
logic[255:0] a_r, e_r, n_r, a_w, e_w, n_w;
logic[256:0] a256_r, a256_w;
logic[255:0] ans_r, ans_w;
logic[257:0] ans1_r, ans1_w;
logic[257:0] ans2_r, ans2_w;

assign o_a_pow_e = ans_r;
assign o_finished = (state_r == S_IDLE);

task Power;
	begin
		if (a256_r & (1 << mul_cnt_r)) begin
			if ((ans1_r + a256_r) & 1) ans1_w = (ans1_r + a256_r + n_r) >> 1;
			else ans1_w = (ans1_r + a256_r) >> 1;
		end
		else begin
			if (ans1_r & 1) ans1_w = (ans1_r + n_r) >> 1;
			else ans1_w = ans1_r >> 1;
		end
	end
endtask

task Mul;
	begin
		if (a256_r & (1 << mul_cnt_r)) begin
			if ((ans2_r + ans_r) & 1) ans2_w = (ans2_r + ans_r + n_r) >> 1;
			else ans2_w = (ans2_r + ans_r) >> 1;
		end
		else begin
			if (ans2_r & 1) ans2_w = (ans2_r + n_r) >> 1;
			else ans2_w = ans2_r >> 1;
		end
	end
endtask

always_comb begin

	state_w = state_r;
	pre_cnt_w = pre_cnt_r;
	pow_cnt_w = pow_cnt_r;
	mul_cnt_w = mul_cnt_r;
	a256_w = a256_r;
	ans_w = ans_r;

	ans1_w = ans1_r;
	ans2_w = ans2_r;

	a_w = a_r;
	e_w = e_r;
	n_w = n_r;

	case(state_r)
		S_IDLE:begin
			if (i_start) begin
				a_w = i_a;
				e_w = i_e;
				n_w = i_n;
				pre_cnt_w = 0;
				a256_w = i_a;
				ans_w = 1;
				state_w = S_PREPROCESS;
			end
		end

		S_PREPROCESS:begin
			if (pre_cnt_r == 256) begin
				pow_cnt_w = 0;
				state_w = S_LOOP;
			end
			else begin
				if ((a256_r << 1) >= n_r)
					a256_w = (a256_r << 1) - n_r;
				else
					a256_w = a256_r << 1;
				pre_cnt_w = pre_cnt_r + 1;
			end
		end

		S_LOOP:begin
			if (pow_cnt_r == 256)
				state_w = S_IDLE;
			else begin
				if (e_r & (1 << pow_cnt_r)) begin
					mul_cnt_w = 0;
					ans1_w = 0;
					ans2_w = 0;
					state_w = S_NEED;
				end
				else begin
					mul_cnt_w = 0;
					ans1_w = 0;
					state_w = S_NONEED;
				end
				pow_cnt_w = pow_cnt_r + 1;
			end
		end

		S_NEED:begin
			if (mul_cnt_r == 256) begin
				if (ans1_r >= n_r) a256_w = ans1_r - n_r;
				else a256_w = ans1_r;

				if (ans2_r >= n_r) ans_w = ans2_r - n_r;
				else ans_w = ans2_r;

				state_w = S_LOOP;
			end

			else begin
				Power();
				Mul();
				mul_cnt_w = mul_cnt_r + 1;
			end
		end

		S_NONEED:begin
			if (mul_cnt_r == 256) begin
				if (ans1_r >= n_r) a256_w = ans1_r - n_r;
				else a256_w = ans1_r;

				state_w = S_LOOP;
			end

			else begin
				Power();
				mul_cnt_w = mul_cnt_r + 1;
			end
		end
	endcase
end

always_ff @(posedge i_clk or posedge i_rst) begin
	if (i_rst) begin
		state_r <= S_IDLE;
		pre_cnt_r <= 0;
		pow_cnt_r <= 0;
		mul_cnt_r <= 0;

		a256_r <=0;
		ans_r <= 0;

		ans1_r <= 0;
		ans2_r <= 0;

		a_r <= 0;
		e_r <= 0;
		n_r <= 0;
	end
	else begin
		state_r <= state_w;
		pre_cnt_r <= pre_cnt_w;
		pow_cnt_r <= pow_cnt_w;
		mul_cnt_r <= mul_cnt_w;

		a256_r <= a256_w;
		ans_r <= ans_w;

		ans1_r <= ans1_w;
		ans2_r <= ans2_w;

		a_r <= a_w;
		e_r <= e_w;
		n_r <= n_w;
	end
end
endmodule
