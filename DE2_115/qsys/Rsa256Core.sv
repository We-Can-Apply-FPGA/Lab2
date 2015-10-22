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

logic [255:0] ans_r, ans_w, pow_r, pow_w;
logic [7:0] now_r, now_w;
logic started_r, started_w;

assign o_finished = !started_r;
assign o_a_pow_e = ans_r;

always_comb begin
	started_w = started_r;
	ans_w = ans_r;
	now_w = now_r;
	pow_w = pow_r;
	if (i_start && !started_r) begin
		started_w = 1;
		ans_w = 0;
		pow_w = i_a;
		now_w = 0;
	end else if (started_r) begin
		if (i_e & (1 << now_r))
			ans_w = (ans_r * pow_r) % i_n;
		pow_w = (pow_r * pow_r) % i_n;
		if (now_r == 0)
			started_w = 0;
		else
			now_w = now_r + 1;
	end
end

always_ff @(posedge i_clk or posedge i_rst) begin : statement_label
	if (i_rst) begin
		started_r <= 0;
		ans_r <= 0;
		pow_r <= 0;
		now_r <= 0;
	end else begin
		started_r <= started_w;
		ans_r <= ans_w;
		pow_r <= pow_w;
		now_r <= now_w;
	end
	
end : statement_label
endmodule
