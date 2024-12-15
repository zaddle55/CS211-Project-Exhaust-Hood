`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/01 32:38:21
// Design Name: 
// Module Name: ps2_input
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "ps2_code.v"

module ps2_input(
    /* global clock */
    input  clk,
    input  rst,

    /* ps2 input */
    input ps2_clk,
    input ps2_data,

    /* output */
    output _overflow,
    output _ready,
    output _nextdata_n,
    output [7:0] _data,

    output [31:0] output_grp
);
    wire [31:0] output_grp_raw;

    wire nextdata_n;
    wire [7:0] data;
    wire ready;
    wire overflow;

    ps2_keyboard_data ps2_data_inst(
        .clk(clk),
        .rst(rst),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .nextdata_n(nextdata_n),
        .data(data),
        .ready(ready),
        .overflow(overflow)
    );

    ps2_data_reader ps2_reader_inst(
        .clk(clk),
        .rst(rst),
        .data(data),
        .ready(ready),
        .overflow(overflow),
        .nextdata_n(nextdata_n),
        .output_grp(output_grp_raw)
    );

    key_pos_filter #(.N(32)) key_filter_inst(
        .clk(clk),
        .rst(rst),
        .key(output_grp_raw),
        .key_filtered(output_grp)
    );

    assign _overflow = overflow;
    assign _nextdata_n = nextdata_n;
    assign _ready = ready;
    assign _data = data;


endmodule

module key_pos_filter #(
    parameter N = 5,
    parameter INGORE_BIT = 31 // null
) (
    input clk,
    input rst,
    input [N-1:0] key,
    output reg [N-1:0] key_filtered
);
    reg [N-1:0] key_sync_0, key_sync_1;

    initial begin
        key_filtered = {N{1'b0}};
    end

    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            key_sync_0 <= {N{1'b0}};
            key_sync_1 <= {N{1'b0}};
        end else begin
            key_sync_0 <= key;
            key_sync_1 <= key_sync_0;
        end
    end

    integer i;

    always @(*) begin
        for (i = 0; i < N; i = i + 1) begin
            if (i == INGORE_BIT) begin
                key_filtered[i] = key[i];
            end else begin
                key_filtered[i] = key_sync_0[i] & ~key_sync_1[i];
            end
        end
    end

endmodule

module ps2_keyboard_data(
    input  clk,
    input  rst,

    input ps2_clk,
    input ps2_data,

    input nextdata_n,   // read next data when low

    output [7:0] data,  // 8bit data from keyboard
    output reg ready,   // data is ready
    output reg overflow // fifo is overflow
);

    // internal signals
    reg [9:0] buffer;       // ps2_data bits
    reg [7:0] fifo [7:0];   // 8bit fifo
    reg [2:0] w_ptr, r_ptr; // write and read pointer
    reg [3:0] count;        // fifo count
    reg [2:0] ps2_clk_sync; // detect ps2_clk falling edge

    always @(posedge clk) begin
        ps2_clk_sync <= {ps2_clk_sync[1:0], ps2_clk};
    end

    wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1]; // falling edge of ps2_clk

    always @(posedge clk or negedge rst) begin
        if (rst == 0) begin
            count <= 0; w_ptr <= 0; r_ptr <= 0; overflow <= 0; ready <= 0;
        end
        else begin
            if (ready) begin
                if (nextdata_n == 0) begin
                    r_ptr <= r_ptr + 3'b1;
                    if (w_ptr == r_ptr + 3'b1)
                        ready <= 0; // fifo is empty
                end
            end
            if (sampling) begin
                if (count == 4'd10) begin
                    if ((buffer[0] == 0) &&
                        (ps2_data) &&
                        (^buffer[9:1])) begin // odd parity
                        fifo[w_ptr] <= buffer[8:1];
                        w_ptr <= w_ptr + 3'b1;
                        ready <= 1;
                        overflow <= overflow | (w_ptr == (r_ptr + 3'b1));
                    end
                    count <= 0;
                end else begin
                    buffer[count] <= ps2_data;
                    count <= count + 3'b1;
                end
            end
        end
    end
    assign data = fifo[r_ptr];

endmodule

module ps2_data_reader(
    input  clk,
    input  rst,

    input [7:0] data,
    input ready,
    input overflow,

    output reg nextdata_n,


    /* output signals bus */
    output reg [31:0] output_grp
);
    /*
    handle data read
    */
    reg [7:0] data_reg;

    reg [31:0] output_grp_n = {32{1'b0}};    // next output_grp

     // output name offset
    parameter A = 'd0;
    parameter C = 'd1;
    parameter D = 'd2;
    parameter P = 'd3;
    parameter L = 'd4;
    parameter SPACE = 'd5;
    parameter ONE = 'd6;
    parameter TWO = 'd7;
    parameter THREE = 'd8;
    parameter S = 'd9;
    parameter W = 'd10;
    parameter T = 'd11;
    parameter X = 'd12;
    parameter E = 'd13;
    parameter R = 'd14;
    parameter O = 'd15;
    parameter I = 'd16;
    parameter LEFT = 'd17;
    parameter RIGHT = 'd18;
    parameter N = 'd19;
    parameter M = 'd20;
    parameter V = 'd21;
    // ...

    parameter MAKE  = 1'b1; // make code
    parameter BREAK = 1'b0; // break code

    reg output_state = MAKE;
    reg next_output_state = MAKE;

    always @(posedge clk or negedge rst) begin
        if (rst == 0) begin
            nextdata_n <= 1;
            data_reg <= 0;
            output_state <= MAKE;
            output_grp <= {32{1'b0}};
        end
        else begin
            if (ready) begin
                nextdata_n <= 0;
                data_reg <= data;
            end
            else begin
                nextdata_n <= 1;
            end
            output_state <= next_output_state;
            output_grp <= output_grp_n;
        end
    end

    always @(*) begin
        /*
        handle the key binding
        */
        case (data_reg)
            `PS2_A: begin
                output_grp_n[A] = output_state;
                next_output_state = MAKE;
            end
            `PS2_D: begin
                output_grp_n[D] = output_state;
                next_output_state = MAKE;
            end
            `PS2_P: begin
                output_grp_n[P] = output_state;
                next_output_state = MAKE;
            end
            `PS2_C: begin
                output_grp_n[C] = output_state;
                next_output_state = MAKE;
            end
            `PS2_L: begin
                output_grp_n[L] = output_state;
                next_output_state = MAKE;
            end
            `PS2_SPACE: begin
                output_grp_n[SPACE] = output_state;
                next_output_state = MAKE;
            end
            `PS2_1: begin
                output_grp_n[ONE] = output_state;
                next_output_state = MAKE;
            end
            `PS2_2: begin
                output_grp_n[TWO] = output_state;
                next_output_state = MAKE;
            end
            `PS2_3: begin
                output_grp_n[THREE] = output_state;
                next_output_state = MAKE;
            end
            `PS2_X: begin
                output_grp_n[X] = output_state;
                next_output_state = MAKE;
            end
            `PS2_O: begin
                output_grp_n[O] = output_state;
                next_output_state = MAKE;
            end
            `PS2_E: begin
                output_grp_n[E] = output_state;
                next_output_state = MAKE;
            end
            `PS2_W: begin
                output_grp_n[W] = output_state;
                next_output_state = MAKE;
            end
            `PS2_S: begin
                output_grp_n[S] = output_state;
                next_output_state = MAKE;
            end
            `PS2_R: begin
                output_grp_n[R] = output_state;
                next_output_state = MAKE;
            end
            `PS2_I: begin
                output_grp_n[I] = output_state;
                next_output_state = MAKE;
            end
            `PS2_T: begin
                output_grp_n[T] = output_state;
                next_output_state = MAKE;
            end
            `PS2_LEFT: begin
                output_grp_n[LEFT] = output_state;
                next_output_state = MAKE;
            end
            `PS2_RIGHT: begin
                output_grp_n[RIGHT] = output_state;
                next_output_state = MAKE;
            end
            `PS2_M: begin
                output_grp_n[M] = output_state;
                next_output_state = MAKE;
            end
            `PS2_N: begin
                output_grp_n[N] = output_state;
                next_output_state = MAKE;
            end
            `PS2_V: begin
                output_grp_n[V] = output_state;
                next_output_state = MAKE;
            end
            
            /*
            ... other keys
            */
            `PS2_BREAK_PREFIX: begin
                next_output_state = BREAK;
            end
            default: output_grp_n = {32{1'b0}}; // do nothing
        endcase
    end

endmodule
