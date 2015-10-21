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

logic [255:0] o_a_pow_e_r, o_a_pow_e_w;
logic [7:0] now_r, now_w;
logic o_finished_r, o_finished_w, started_r, started_w;

always_comb begin
	if (i_start && stated_w == 0) begin
		started_w = 1;
		o_a_pow_e_w = 1;
	end
	if (started_r == 1) begin
		if (i_e & (1<< now_r)) begin
			o_a_pow_e_w = 
		end
		now_w = now_r+1;
	end
end

always_ff @(posedge i_lk or posedge i_rst) begin : statement_label
	if (i_rst) begin
		o_a_pow_e_r <= 0;
		o_finished_r <= 1;
		now_r <= 0;
	end else begin
		o_a_pow_e_r <= o_a_pow_e_w;
		o_finished_r <= o_finished_w;
		now_r <= now_w;
	end
	
end : statement_label
endmodule
