module DimConverter(
    input               i_clk,
    input               i_rst_n,
    input               i_newtask,
    input      [5:0]    i_deg,
    input      [2:0]    i_mode,
    output              o_busy,
    output     [6:0]    o_counter,
    output              o_sram_we_n,
    output     [19:0]   o_sram_addr,
    output     [15:0]   o_sram_dq
);

reg [6:0]  counter, counter_nxt;
reg [3:0]  state, state_nxt;
reg [9:0]  x, y, x_nxt, y_nxt;
reg        busy, busy_nxt;
reg        we, we_nxt;
reg [2:0]  write_counter, next_write_counter;
reg [19:0] sram_addr, sram_addr_nxt;
reg [15:0] data, data_nxt;

reg  [6:0]  angle;
wire [11:0] sine, cosine;

Cordic cordic0(
    .i_angle(angle),
    .o_sine(sine),
    .o_cosine(cosine)
);

wire [15:0] data1, data2;

Painting paint(
    .i_mode(i_mode),
    .i_x(x),
    .i_y(y),
    .o_data1(data1),
    .o_data2(data2)
);

assign o_sram_addr = sram_addr;
assign o_sram_we_n = we;
assign o_sram_dq = data;
assign o_counter = counter;
assign o_busy = busy;

parameter IDLE       = 4'b1111;
parameter WRITEMODE0 = 4'b0000;
parameter WRITEMODE1 = 4'b0001;
parameter WRITEMODE2 = 4'b0010;
parameter WRITEMODE3 = 4'b0011;
parameter WRITEMODE4 = 4'b0100;
parameter WRITEMODE5 = 4'b0101;
parameter WRITEMODE6 = 4'b0110;
parameter WRITEMODE7 = 4'b0111;

always@(*)
begin
    counter_nxt = counter;
    state_nxt = state;
    x_nxt = x;
    y_nxt = y;
    busy_nxt = busy;
    next_write_counter = write_counter;
    sram_addr_nxt = sram_addr;
    data_nxt = data;
    we_nxt = we;

    case(state)
        IDLE:
        begin
            if (i_newtask)
            begin
                busy_nxt = 1'b1;
                case(i_mode)
                    3'd0: begin
                          state_nxt = WRITEMODE0;
                          next_write_counter = 3'b100;
                          x_nxt = 10'b0;
                          y_nxt = 10'b0;
                          we_nxt = 1'b1;
                          end
                    3'd1: state_nxt = WRITEMODE1;
                    3'd2: state_nxt = WRITEMODE2;
                    3'd3: state_nxt = WRITEMODE3;
                    3'd4: state_nxt = WRITEMODE4;
                    3'd5: state_nxt = WRITEMODE5;
                    3'd6: state_nxt = WRITEMODE6;
                    3'd7: state_nxt = WRITEMODE7;
                endcase
            end
        end

        WRITEMODE0:
        begin
            if (write_counter[2])
            begin
                we_nxt = 1'b1;
                next_write_counter = {1'b0, write_counter[1], 1'b0};
                sram_addr_nxt = {(640*y+x),write_counter[1]};
            end

            else if (write_counter[0])
            begin
                we_nxt = 1'b1;
                next_write_counter = {1'b1, !write_counter[1], 1'b0};
            end

            else if (!write_counter[1])
            begin
                next_write_counter = write_counter+1;
                we_nxt = 1'b0;
                data_nxt = data1;
                if (y == 10'd480) begin
                    busy_nxt = 1'b0;
                    state_nxt = IDLE;
                    counter_nxt = counter+10;
                end
            end
            else
            begin
                next_write_counter = write_counter+1;
                we_nxt = 1'b0;
                data_nxt = data2;
                if (x < 10'd640) begin
                    x_nxt = x + 1'b1;
                    y_nxt = y;
                end
                else begin
                    y_nxt = y + 1'b1;
                    x_nxt = 0;
                end
            end
        end

        WRITEMODE1:
        begin
            counter_nxt = counter+1;
            busy_nxt = 1'b0;
            state_nxt = IDLE;
        end

        WRITEMODE2:
        begin
            counter_nxt = counter+2;
            busy_nxt = 1'b0;
            state_nxt = IDLE;
        end

        /* === ignore === */
        WRITEMODE3:
        begin
            counter_nxt = counter+4;
            busy_nxt = 1'b0;
            state_nxt = IDLE;
        end

        WRITEMODE4:
        begin
            counter_nxt = counter+4;
            busy_nxt = 1'b0;
            state_nxt = IDLE;
        end

        WRITEMODE5:
        begin
            counter_nxt = counter+5;
            busy_nxt = 1'b0;
            state_nxt = IDLE;
        end
        WRITEMODE6:
        begin
            counter_nxt = counter+6;
            busy_nxt = 1'b0;
            state_nxt = IDLE;
        end
        WRITEMODE7:
        begin
            counter_nxt = counter+7;
            busy_nxt = 1'b0;
            state_nxt = IDLE;
        end
        /* ============== */

    endcase
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if (!i_rst_n)
    begin
        counter <= 7'd0;
        state <= WRITEMODE0;
        busy <= 1'b1;
        x <= 10'b0;
        y <= 10'b0;
        write_counter <= 3'b100;
        sram_addr <= 20'b0;
        we <= 1'b1;
    end
    else
    begin
        counter <= counter_nxt;
        state <= state_nxt;
        busy <= busy_nxt;
        x <= x_nxt;
        y <= y_nxt;
        we <= we_nxt;
        write_counter <= next_write_counter;
        sram_addr <= sram_addr_nxt;
        data <= data_nxt;
    end
end
endmodule


module Cordic(
    input      [6:0]  i_angle,
    output reg [11:0] o_sine,
    output reg [11:0] o_cosine
);

    wire [10:0] trig [0:16];

    assign trig[0]  = 11'd0;
    assign trig[1]  = 11'd100;
    assign trig[2]  = 11'd200;
    assign trig[3]  = 11'd297;
    assign trig[4]  = 11'd392;
    assign trig[5]  = 11'd483;
    assign trig[6]  = 11'd569;
    assign trig[7]  = 11'd650;
    assign trig[8]  = 11'd724;
    assign trig[9]  = 11'd792;
    assign trig[10] = 11'd851;
    assign trig[11] = 11'd903;
    assign trig[12] = 11'd946;
    assign trig[13] = 11'd980;
    assign trig[14] = 11'd1004;
    assign trig[15] = 11'd1019;
    assign trig[16] = 11'd1024;

    always@(*)
    begin
        if ((i_angle >= 0) && (i_angle < 16))
        begin
            o_sine   = trig[i_angle];
            o_cosine = trig[16-i_angle];
        end
        if ((i_angle >= 16) && (i_angle < 32))
        begin
            o_sine   = trig[32-i_angle];
            o_cosine = (~trig[i_angle-16])+1'b1;
        end
        if ((i_angle >= 32) && (i_angle < 48))
        begin
            o_sine   = (~trig[i_angle-32])+1'b1;
            o_cosine = (~trig[48-i_angle])+1'b1;
        end
        if ((i_angle >= 48) && (i_angle < 64))
        begin
            o_sine   = (~trig[64-i_angle])+1'b1;
            o_cosine = trig[i_angle-48];
        end
    end

endmodule

module Painting(
    input      [2:0]  i_mode,
    input      [9:0]  i_x,
    input      [9:0]  i_y,
    output reg [15:0] o_data1,
    output reg [15:0] o_data2
);

reg [9:0] delta;
reg       group;

always@(*)
begin
    case(i_mode)
        3'd0:
        begin
            if (i_y < 10'd160)
            begin
                o_data1 = 16'b0;
                o_data2 = {6'b0,8'b1111_1111,2'b0};
            end
            else if (i_y < 10'd320)
            begin
                o_data1 = {1'b0,5'b11111,10'b0};
                o_data2 = {1'b0,3'b11111,12'b0};
            end
            else if (i_y < 10'd480)
            begin
                o_data1 = {6'b0,8'b1111_1111,2'b0};
                o_data2 = 16'b0;
            end
        end

        3'd1:
        begin
            if      (i_y >= 80  & i_y < 128)
                delta = {3'b0, i_y-80}*3 >> 3;
            else if (i_y >= 128 & i_y < 152)
                delta = 18;
            else if (i_y >= 152 & i_y < 200)
                delta = {3'b0, i_y-104}*3 >> 3;
            else
                delta = 36;

            group = {10'b0, i_x-284}*205 >> 10;

            if (i_y >= 80        & i_y < 400 & 
                i_x >= 320-delta & i_x < 320+delta)
            begin
                if ((i_y >= 80 & i_y < 128) | (i_y >= 152 & i_y < 200))
                begin
                    o_data1 = {1'b0, 5'b01011, 8'h55, 2'b0};
                    o_data2 = {1'b0, 3'b011, 2'b0, 8'h45, 2'b0};
                end
                else if (i_x >= 300 & i_x <= 340 & i_y >= 220 & i_y <= 260)
                begin
                    o_data1 = {1'b0, 5'b11111, 8'hfa, 2'b0};
                    o_data2 = {1'b0, 3'b010, 2'b0, 8'hfa, 2'b0};
                end
                else
                begin
                    if (!group)
                    begin
                        o_data1 = {1'b0, 5'b01111, 8'h00, 2'b0};
                        o_data2 = {1'b0, 3'b001, 2'b0, 8'hc4, 2'b0};
                    end
                    else
                    begin
                        o_data1 = {1'b0, 5'b10110, 8'h25, 2'b0};
                        o_data2 = {1'b0, 3'b011, 2'b0, 8'hfe, 2'b0};
                    end
                end
            end
            else
            begin
                o_data1 = 16'b0;
                o_data2 = 16'b0;
            end
        end

        3'd2:
        begin
            delta = {2'b0, i_y-158}*3 >> 2;
            group = {10'b0, i_y-284}*205 >> 10;
            
            if (i_y >= 160       & i_y < 320 & 
                i_x >= 320-delta & i_x < 320+delta)
            begin
                if (!group)
                begin
                    o_data1 = {1'b0, 5'b01100, 8'h0d, 2'b0};
                    o_data2 = {1'b0, 3'b110, 2'b0, 8'hfe, 2'b0};
                end
                else
                begin
                    o_data1 = {1'b0, 5'b10110, 8'h43, 2'b0};
                    o_data2 = {1'b0, 3'b011, 2'b0, 8'hfe, 2'b0};
                end
            end
            else
            begin
                o_data1 = 16'b0;
                o_data2 = 16'b0;
            end
        end 
    endcase
end

endmodule