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

logic [256:0] ans_r, ans_w, tmp;
logic [7:0] now_r, now_w;
logic started_r, started_w, comparing_r, comparing_w;

always_comb begin
	started_w = started_r;
	ans_w = ans_r;
	now_w = now_r;
	comparing_w = comparing_r;
	tmp = 0;
	if (i_start && !started_r) begin
		started_w = 1;
		ans_w = 0;
		now_w = 255;
		comparing_w = 0;
	end else if (started_r) begin
		if (comparing_r) begin
			if (ans_r < i_n)
				ans_w = ans_r;
			else
				ans_w = ans_r - i_n;
		end else begin
			tmp = ans_r + i_a;
			if (i_e & (1 << now_r)) begin
				if (tmp & 1)
					ans_w = (tmp + i_n) >> 1;
				else
					ans_w = tmp >> 1;
			end else begin
				ans_w = ans_w >> 1;
			end
			if (now_r == 0) begin
				started_w = 0;
			end else
				now_w = now_r - 1;
		end
		comparing_w = !comparing_r;
	end
	o_finished = (now_r == 0);
	o_a_pow_e = ans_r[255:0];
end

always_ff @(posedge i_clk or posedge i_rst) begin : statement_label
	if (i_rst) begin
		started_r <= 0;
		ans_r <= 0;
		now_r <= 255;
		comparing_r <= 0;
	end else begin
		started_r <= started_w;
		ans_r <= ans_w;
		now_r <= now_w;
		comparing_r <= comparing_w;
	end
	
end : statement_label
endmodule
