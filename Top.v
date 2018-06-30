module Top (
    input         i_clk,
    input         i_rst_n,
    input  [6:0]  i_mode,
    input         i_setup,
    input         i_degplus,
    input         i_degsub,
    input  [2:0]  i_rotate,
    output [5:0]  o_deg,
    output [2:0]  o_mode,
    output        o_newtask
);

	reg  [2:0]  mode, mode_nxt;
	reg  [5:0]  deg, deg_nxt;
    reg         newtask, newtask_nxt;
    reg         state, state_nxt;
    reg  [25:0] counter, counter_nxt;

    assign o_deg     = deg;
    assign o_mode    = mode;
    assign o_newtask = newtask_nxt;
    
    parameter IDLE = 1'b0;
    parameter NEWTASK = 1'b1;

	always @(*)
	begin
        deg_nxt = deg;
        mode_nxt = mode;
        newtask_nxt = newtask;
        state_nxt = state;
        counter_nxt = counter+i_rotate;

        case(state)
            IDLE:
            begin
                if (i_setup)
                begin
                    mode_nxt =  (i_mode == 7'b0000001) ? 3'd1 :
                                (i_mode == 7'b0000010) ? 3'd2 :
                                (i_mode == 7'b0000100) ? 3'd3 :
                                (i_mode == 7'b0001000) ? 3'd4 :
                                (i_mode == 7'b0010000) ? 3'd5 :
                                (i_mode == 7'b0100000) ? 3'd6 :
                                (i_mode == 7'b1000000) ? 3'd7 : 3'd0;
                    if (!(mode_nxt) && !(mode))
                        mode_nxt = mode;
                    else
                    begin
                        deg_nxt  = 6'd6;
                        state_nxt = NEWTASK;
                        newtask_nxt = 1'b1;
                    end
                end
                else if ((i_degplus^i_degsub) && mode)
                begin
                    if (i_degsub)
                        deg_nxt = deg - 1'b1;
                    else
                        deg_nxt = deg + 1'b1;
                    state_nxt = NEWTASK;
                    newtask_nxt = 1'b1;
                end
                else if (counter_nxt[25])
                begin
                    counter_nxt = 26'b0;
                    if (mode)
                    begin
                        deg_nxt = deg + 1'b1;
                        state_nxt = NEWTASK;
                        newtask_nxt = 1'b1;
                    end
                end
            end
            
            NEWTASK:
            begin
                state_nxt = IDLE;
                newtask_nxt = 1'b0;
            end
        endcase
    end

	always @(posedge i_clk or negedge i_rst_n)
	begin
		if (!i_rst_n)
		begin
			deg      <= 6'd6;
            mode     <= 3'd0;
            newtask  <= 1'b0;
            state    <= IDLE;
            counter  <= 26'b0;
		end
		else
		begin
			deg     <= deg_nxt;
			mode    <= mode_nxt;
            state   <= state_nxt;
            newtask <= newtask_nxt;
            counter <= counter_nxt;
		end
	end

endmodule