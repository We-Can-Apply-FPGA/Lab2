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

//Main Block State
localparam S_MAIN_IDLE  = 0;
localparam S_MAIN_BEGIN = 1;//to initialize core_state
localparam S_MAIN_CALC  = 2;
localparam S_MAIN_END = 3;

//Power Block State
localparam S_POW_IDLE        = 0;
localparam S_POW_START       = 1;
localparam S_POW_PREPROCESS  = 2;
localparam S_POW_LOOP_READY  = 3;
localparam S_POW_WAIT_NEEDIT = 4;
localparam S_POW_LOOP        = 5;
localparam S_POW_WAIT        = 6;
localparam S_POW_END         = 7;

//Mutiply Block State
localparam S_MUL_IDLE  = 0;
localparam S_MUL_START = 1;
localparam S_MUL_CALC  = 2;
localparam S_MUL_END   = 3;


logic[1:0] main_state_r,main_state_w;
logic[2:0] pow_state_r,pow_state_w;
logic[1:0] mul_state_r,mul_state_w;
logic[15:0] pow_cnt_r,pow_cnt_w,mul_cnt_r,mul_count_w,pre_cnt_r,pre_cnt_w;
logic[255:0] a256_r,a256_w;
logic[255:0] ans_r,ans_w;
logic[255:0] mul_ans_r,mul_ans_w;

//task InitCalc;
//endtask

//task Preprocess;
	//input [255] beforeshift;
	//if(pre_cnt_r == 0)begin
		//pow_state_w = S_POW_LOOP;
		//pre_cnt_w = 255;
		//return beforeshift;
	//end
	//else begin
		//pre_cnt_w = pre_cnt_r - 1;
	//end
//endtask

always_comb begin Main

	//Main Block
	case(main_state_r)
		S_MAIN_IDLE:begin
			if(i_start)	main_state_w = S_MAIN_START;
			else	main_state_w = S_MAIN_IDLE;
		end

		S_MAIN_START:begin
			pow_state_w = S_POW_START;
			main_state_w = S_MAIN_CALC;
		end

		S_MAIN_CALC:begin
			if(pow_state_r == S_POW_END)	main_state_w = S_MAIN_IDLE;
		end
	
	//Power-Mont Block
	case(pow_state_r)
		S_POW_START:begin
			pow_state_w = S_POW_PREPROCESS;
			pre_cnt_w = 255;
			a256_w = a;
		end

		S_POW_PREPROCESS:
			if(a256_r >= n)	a256_w = a256_r - n;
			else	a256_w = a256_r;
			if(pre_cnt_r == 0)begin
				pow_state_w = S_POW_LOOP_READY;
				pre_cnt_w = 255;
				pow_cnt_w = 255;
			else
				pre_cnt_w = pre_cnt_r - 1;
			end
		end

		S_POW_LOOP_READY:
			ans_w = 1;
			if (e & (1 << pow_cnt_r)) begin //need_it
				pow_state_w = S_POW_WAIT_NEEDIT;
				mul_state_w = S_MUL_START;
			end
			else begin
				pow_state_w = S_POW_LOOP;
				mul_state_w = S_MUL_IDLE;
			end
		end

		S_POW_WAIT_NEEDIT:
			if(mul_state_r == S_MUL_END)begin
				mul_state_r = S_MUL_IDLE;
				pow_state_r = S_POW_LOOP;
				ans_w = mul_ans_r;
			end
		end

		S_POW_LOOP:
			

		end

		S_POW_WAIT:

		end

		//S_MAIN_END:begin //reset
			
		//end
end Main

always_ff @(posedge i_clk or posedge i_rst) begin
	if (i_rst) begin
		main_state_r <= S_MAIN_IDLE;
		pow_state_r <= S_POW_IDLE;
		mul_state_r <= S_MUL_IDLE;

		pre_cnt_r <= 0;
		pow_cnt_r <= 0;
		mul_cnt_r <= 0;

		ans_r <= 0;
		mul_ans_r <= 0;

		a256_r <=0
	end
	else begin
		if (i_start) begin
		  a <= i_a;
		  e <= i_e;
		  n <= i_n;
		end
		main_state_r <= main_state_w;
		pow_state_r <= pow_state_w;
		mul_state_r <= mul_state_w;
		pre_cnt_r <= pre_cnt_w;
		pow_cnt_r <= pow_cnt_w;
		mul_cnt_r <= mul_cnt_w;
		ans_r <= ans_w;
		mul_ans_r <= mul_ans_w;
		a256_r <= a256_w;
	end
end
endmodule
