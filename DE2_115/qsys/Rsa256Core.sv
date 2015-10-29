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


//loop param
localparam COUNT_DOWN = 256;
localparam COUNT_START = 0;

logic[1:0] main_state_r,main_state_w;
logic[2:0] pow_state_r,pow_state_w;
logic[1:0] mul_state_r,mul_state_w;
logic[15:0] pow_cnt_r,pow_cnt_w,mul_cnt_r,mul_cnt_w,pre_cnt_r,pre_cnt_w;
logic[255:0] a,e,n;
logic[256:0] a256_r,a256_w;
logic[255:0] ans_r,ans_w;
logic[256:0] mul_ans_r,mul_ans_w;
logic[256:0] mul_a_r,mul_a_w,mul_b_r,mul_b_w;
logic[256:0] mul_tmp1,mul_tmp2;
//task InitCalc;
//endtask

assign o_a_pow_e = ans_r;
assign o_finished = (main_state_r == S_MAIN_IDLE);
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
	mul_a_w = mul_a_r;
	mul_b_w = mul_b_r;
	mul_tmp1=0;
	mul_tmp2=0;
	//Main Block
	case(main_state_r)
		S_MAIN_IDLE:begin
			$display(i_start);
			$display("Enter in MAIN IDLE");
			if(i_start) main_state_w = S_MAIN_START;
			else main_state_w = S_MAIN_IDLE;
		end

		S_MAIN_START:begin
			$display("Enter in MAIN Start");
			pow_state_w = S_POW_START;
			main_state_w = S_MAIN_CALC;
		end

		S_MAIN_CALC:begin
			$display("Enter in MAIN CALC");
			if(pow_state_r == S_POW_IDLE) main_state_w = S_MAIN_END;
		end
	
		S_MAIN_END:begin //reset
			$display("Enter in MAIN END");
			main_state_w = S_MAIN_IDLE;
		end
	endcase

	//Power-Mont Block
	case(pow_state_r)
		S_POW_START:begin
			$display("Enter in POW START");
			pre_cnt_w = COUNT_START;
			a256_w = a;
			pow_state_w = S_POW_PREPROCESS;
			ans_w = 1;
		end

		S_POW_PREPROCESS:begin
			$display("Enter in POW Preprocess ");
			if(pre_cnt_r == COUNT_DOWN)begin
				pow_cnt_w = COUNT_START;
				pow_state_w = S_POW_LOOP_READY;
			end
			else begin
				if((a256_r << 1) >= n) begin
					a256_w = (a256_r<<1) - n;
				end
				else begin
					a256_w = a256_r << 1;
				end
				pre_cnt_w = pre_cnt_r + 1;
				pow_state_w = S_POW_PREPROCESS;
				$display("a256_w is %64x",a256_w);
			end
			//process overflow

		end

		S_POW_LOOP_READY:begin
			$display("Enter in POW LOOP_READY ");
			$display("current ans_r is %64x",ans_r);
			if(pow_cnt_r == COUNT_DOWN)begin
				pow_state_w = S_POW_IDLE;
			end
			else begin
				if (e & (1 << pow_cnt_r)) begin //need_it
					mul_a_w = ans_r;
					mul_b_w = a256_r;
					pow_state_w = S_POW_WAIT_NEEDIT;
					mul_state_w = S_MUL_START;
				end
				else begin
					pow_state_w = S_POW_LOOP;
				end
			end
		end

		S_POW_WAIT_NEEDIT:begin
			$display("Enter in POW WAIT_NEEDIT ");
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
			$display("Enter in POW LOOP ");
			mul_a_w = a256_r;
			mul_b_w = a256_r;
			pow_state_w = S_POW_WAIT;
			mul_state_w = S_MUL_START;
		end

		S_POW_WAIT:begin
			$display("Enter in POW WAIT ");
			if(mul_state_r == S_MUL_IDLE)begin
				$display("MUL ANS in second loop %64x",mul_ans_r);
				$display("MUL a in second loop %64x",mul_a_r);
				$display("MUL b in second loop %64x",mul_b_r);
				a256_w = mul_ans_r;
				pow_cnt_w = pow_cnt_r + 1;
				pow_state_w = S_POW_LOOP_READY;
			end
			else begin
				pow_state_w = S_POW_WAIT;
			end
		end

		S_POW_IDLE:begin
			$display("Enter in POW IDLE ");
			//pow_state_w = S_POW_IDLE;
		end
	endcase
	//Multiply-Mont Block
	case(mul_state_r)
		S_MUL_IDLE:begin
			$display("Enter in MUL_IDLE\n");
			//mul_state_w = S_MUL_IDLE;
		end

		S_MUL_START:begin
			$display("Enter in MUL_START\n");
			mul_cnt_w = COUNT_START;
			mul_ans_w = 0;
			mul_state_w = S_MUL_CALC;
		end

		S_MUL_CALC:begin
			$display("Enter in MUL_CALC , current mul_cnt is %8d \n",mul_cnt_r);
			if(mul_cnt_r == COUNT_DOWN) mul_state_w = S_MUL_END;
			else begin
				mul_cnt_w = mul_cnt_r + 1;
				if (mul_b_r & (1 << mul_cnt_r)) mul_tmp1 = mul_ans_r + mul_a_r;//needit
				else mul_tmp1 = mul_ans_r;
				if (mul_tmp1[0] ) mul_tmp2 = mul_tmp1 + n;
				else mul_tmp2 = mul_tmp1;
				mul_ans_w = mul_tmp2 >> 1;
				$display("current mul_tmp1 is %64x",mul_tmp1);
				$display("current mul_tmp2 is %64x",mul_tmp2);
				$display("current mul_a is %64x",mul_a_r);
				$display("current mul_b is %64x",mul_b_r);
				$display("current mul_ans is %64x",mul_ans_w);
				mul_state_w = S_MUL_CALC;
			end
		end

		S_MUL_END:begin
			$display("Enter in MUL_END\n");
			//$display("MUL ANS is %64x",mul_ans_r);
			if (mul_ans_r < n) mul_ans_w = mul_ans_r;
			else mul_ans_w = mul_ans_r - n;

			mul_state_w = S_MUL_IDLE;
		end
	endcase
end

always_ff @(posedge i_clk or posedge i_rst) begin
	//$display(pow_state_r);
	if (i_rst) begin
		main_state_r <= S_MAIN_IDLE;
		pow_state_r <= S_POW_IDLE;
		mul_state_r <= S_MUL_IDLE;

		pre_cnt_r <= COUNT_START;
		pow_cnt_r <= COUNT_START;
		mul_cnt_r <= COUNT_START;
		
		mul_a_r <=0;
		mul_b_r <=0;
		ans_r <= 0;
		mul_ans_r <= 0;

		a256_r <=0;
	end
	else begin
		if(i_start) begin
			a = i_a;
			e = i_e;
			n = i_n;
		end
		mul_a_r <= mul_a_w;
		mul_b_r<= mul_b_w;
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
