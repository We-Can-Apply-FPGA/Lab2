module Rsa256Core(
	input i_clk,
	input i_rst,
	input i_start,
	input [255:0] i_a,
	input [255:0] i_e,
	input [255:0] i_n,
	output [255:0] o_a_pow_e,
	output o_finished,
	//output o_pow_state,
	//output o_mul_state,
);
// a ^ e mod n

//Main Block State
localparam S_MAIN_IDLE  = 0;
localparam S_MAIN_START = 1;//to initialize core_state
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
logic[15:0] pow_cnt_r,pow_cnt_w,mul_cnt_r,mul_cnt_w,pre_cnt_r,pre_cnt_w,post_cnt_r,post_cnt_w;
logic[255:0] a,e,n;
logic[255:0] a256_r,a256_w;
logic[255:0] ans_r,ans_w;
logic[255:0] mul_ans_r,mul_ans_w;
logic[255:0] mul_a,mul_b;
logic[255:0] mul_tmp1,mul_tmp2;
//task InitCalc;
//endtask

assign e = i_e;
assign n = i_n;
assign a = i_a;
assign o_finished = (main_state_r == S_MAIN_IDLE);
//assign o_pow_state= pow_state_r;
//assign o_mul_state = mul_state_r;

always_comb begin

	main_state_w = main_state_r;
	pow_state_w = pow_state_r;
	mul_state_w = mul_state_r;
	pre_cnt_w = pre_cnt_r;
	pow_cnt_w = pow_cnt_r;
	mul_cnt_w = mul_cnt_r;
	ans_w = ans_r;
	mul_ans_w = mul_ans_r;
	a256_w = a256_r;
	mul_a = 0;
	mul_b = 0;
	mul_tmp1=0;
	mul_tmp2=0;
	o_a_pow_e = 0;
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
			post_cnt_w = 255;
			if(pow_state_r == S_POW_IDLE)begin
				main_state_w = S_MAIN_END;
			end
		end
	
		S_MAIN_END:begin //reset
			
			main_state_w = S_MAIN_IDLE;
		end
	endcase

	//Power-Mont Block
	case(pow_state_r)
		S_POW_START:begin
			pre_cnt_w = 255;
			a256_w = a;
			pow_state_w = S_POW_PREPROCESS;
		end

		S_POW_PREPROCESS:begin
			ans_w = 1;
			//process overflow
			if(a256_r >= n)	a256_w = a256_r - n;
			else	a256_w = a256_r;

			if(pre_cnt_r == 0)begin
				pre_cnt_w = 255;//reset
				pow_cnt_w = 255;
				pow_state_w = S_POW_LOOP_READY;
			end
			else begin
				pre_cnt_w = pre_cnt_r - 1;
				pow_state_w = S_POW_PREPROCESS;
			end
		end

		S_POW_LOOP_READY:begin
			if(pow_cnt_r == 0)begin
				pow_state_w = S_POW_IDLE;
			end
			else begin
				if (e & (1 << pow_cnt_r)) begin //need_it
					mul_a = ans_r;
					mul_b = a256_r;
					pow_state_w = S_POW_WAIT_NEEDIT;
					mul_state_w = S_MUL_START;
				end else pow_state_w = S_POW_LOOP;
			end
		end

		S_POW_WAIT_NEEDIT:begin
			if(mul_state_r == S_MUL_IDLE)begin
				ans_w = mul_ans_r;
				mul_state_w = S_MUL_IDLE;
				pow_state_w = S_POW_LOOP;
			end
			else begin
				pow_state_w = S_POW_WAIT_NEEDIT;
			end
		end

		S_POW_LOOP:begin
			mul_a = a256_r;
			mul_b = a256_r;
			pow_state_w = S_POW_WAIT;
			mul_state_w = S_MUL_START;
		end

		S_POW_WAIT:begin
			if(mul_state_r == S_MUL_IDLE)begin
				a256_w = mul_ans_r;
				pow_cnt_w = pow_cnt_r - 1;
				pow_state_w = S_POW_LOOP_READY;
			end
			else begin
				pow_state_w = S_POW_WAIT;
			end
		end

		S_POW_IDLE:begin
			o_a_pow_e = ans_r;
			pow_state_w = S_POW_IDLE;
		end
	endcase
	//Multiply-Mont Block
	case(mul_state_r)
		S_MUL_IDLE:begin
			mul_state_w = S_MUL_IDLE;
		end

		S_MUL_START:begin
			mul_ans_w = 0;
			mul_cnt_w = 255;
			mul_state_w = S_MUL_CALC;
		end

		S_MUL_CALC:begin
			if(mul_cnt_r == 0) mul_state_w = S_MUL_END;
			else begin
				mul_cnt_w = mul_cnt_r - 1;
				if (mul_b & (1 << mul_cnt_r)) mul_tmp1 = mul_ans_r + mul_a;//needit
				if (mul_ans_r[0] ) mul_tmp2 = mul_tmp1 + n;
				mul_ans_w = mul_tmp2 << 1;
				mul_state_w = S_MUL_CALC;
			end
		end

		S_MUL_END:begin
			if (mul_ans_r < n) mul_ans_w = mul_ans_r;
			else mul_ans_w = mul_ans_r - n;

			mul_state_w = S_MUL_IDLE;
		end
	endcase
end

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

		a256_r <=0;
	end
	else begin
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
