`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/15 15:42:06
// Design Name: 
// Module Name: display
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


module handle_display (
    input               clk,
    input               rst,
    input [3:0]         fsm_state,

    /* clock input */
    input [31:0]        clk_time,
    input               disp_clk_btn,

    /* worktime input */
    input [31:0]        worktime,
    input               disp_wt_btn,

    /* checktime input */
    input [31:0]        checktime,
    input               disp_ct_btn,

    /* interval input */
    input [31:0]        interval,
    input               disp_int_btn,

    /* count down input */
    input [31:0]        count_down,
    input               power_on_button,
    input               power_off_button,
    input [2:0]         gear_button,
    input               clean_button,

    output [2:0]        disp_state,
    output [7:0]        seg_left,
    output [7:0]        seg_right,
    output [3:0]        sel_left,
    output [3:0]        sel_right
);
    parameter [7:0] SEG_DASH = 8'h02;
    parameter [3:0] DASH     = 4'b1111;

    reg [31:0]          disp_data_r = 32'b0;

    localparam CLOCK        = 3'b000;     // display clock
    localparam INTEVAL      = 3'b001;       // display interval
    localparam WORKTIME     = 3'b010;   // display worktime
    localparam CHECKTIME    = 3'b011;   // display checktime
    localparam COUNT_DOWN   = 3'b100;  // display count down

    reg [2:0]   disp_state_c = CLOCK;    // current state of display
    reg [2:0]   disp_state_n = CLOCK;    // next state of display

    // enable signal
    wire enable;
    assign enable = (disp_state_c == disp_state_n) & (fsm_state != 4'b0000);

    // clock divider for segment display
    wire clk_div;

    // display output handle
    always @(posedge clk, negedge rst) begin
        if (~rst) begin
            disp_state_c <= CLOCK;

        end
        else begin
            disp_state_c <= disp_state_n;
        end
    end

    wire [3:0] clk_hour_h;
    wire [3:0] clk_hour_l;
    wire [3:0] clk_minute_h;
    wire [3:0] clk_minute_l;
    wire [3:0] clk_second_h;
    wire [3:0] clk_second_l;

    time_format clk_format(
        .time_in(clk_time),
        .hour_h(clk_hour_h),
        .hour_l(clk_hour_l),
        .minute_h(clk_minute_h),
        .minute_l(clk_minute_l),
        .second_h(clk_second_h),
        .second_l(clk_second_l)
    );

    wire [3:0] worktime_hour_h;
    wire [3:0] worktime_hour_l;
    wire [3:0] worktime_minute_h;
    wire [3:0] worktime_minute_l;
    wire [3:0] worktime_second_h;
    wire [3:0] worktime_second_l;

    time_format worktime_format(
        .time_in(worktime),
        .hour_h(worktime_hour_h),
        .hour_l(worktime_hour_l),
        .minute_h(worktime_minute_h),
        .minute_l(worktime_minute_l),
        .second_h(worktime_second_h),
        .second_l(worktime_second_l)
    );

    wire [3:0] inteval_hour_h;
    wire [3:0] inteval_hour_l;
    wire [3:0] inteval_minute_h;
    wire [3:0] inteval_minute_l;
    wire [3:0] inteval_second_h;
    wire [3:0] inteval_second_l;

    time_format inteval_format(
        .time_in(interval),
        .hour_h(inteval_hour_h),
        .hour_l(inteval_hour_l),
        .minute_h(inteval_minute_h),
        .minute_l(inteval_minute_l),
        .second_h(inteval_second_h),
        .second_l(inteval_second_l)
    );

    wire [3:0] check_time_7;
    wire [3:0] check_time_6;
    wire [3:0] check_time_5;
    wire [3:0] check_time_4;
    wire [3:0] check_time_3;
    wire [3:0] check_time_2;
    wire [3:0] check_time_1;
    wire [3:0] check_time_0;

    dec_format check_time_format(
        .data(checktime),
        .dec_7(check_time_7),
        .dec_6(check_time_6),
        .dec_5(check_time_5),
        .dec_4(check_time_4),
        .dec_3(check_time_3),
        .dec_2(check_time_2),
        .dec_1(check_time_1),
        .dec_0(check_time_0)
    );

    wire [3:0] count_down_7;
    wire [3:0] count_down_6;
    wire [3:0] count_down_5;
    wire [3:0] count_down_4;
    wire [3:0] count_down_3;
    wire [3:0] count_down_2;
    wire [3:0] count_down_1;
    wire [3:0] count_down_0;

    dec_format count_down_format(
        .data(count_down),
        .dec_7(count_down_7),
        .dec_6(count_down_6),
        .dec_5(count_down_5),
        .dec_4(count_down_4),
        .dec_3(count_down_3),
        .dec_2(count_down_2),
        .dec_1(count_down_1),
        .dec_0(count_down_0)
    );

    always @(*) begin
        case(disp_state_c)
            CLOCK: begin
                disp_data_r = {clk_hour_h, clk_hour_l, DASH, clk_minute_h, clk_minute_l, DASH, clk_second_h, clk_second_l};
            end
            WORKTIME: begin
                disp_data_r = {worktime_hour_h, worktime_hour_l, DASH, worktime_minute_h, worktime_minute_l, DASH, worktime_second_h, worktime_second_l};
            end
            INTEVAL: begin
                disp_data_r = {inteval_hour_h, inteval_hour_l, DASH, inteval_minute_h, inteval_minute_l, DASH, inteval_second_h, inteval_second_l};
            end
            CHECKTIME: begin
                disp_data_r = {check_time_7, check_time_6, check_time_5, check_time_4, check_time_3, check_time_2 , check_time_1, check_time_0};
            end
            COUNT_DOWN: begin
                disp_data_r = {count_down_7, count_down_6, count_down_5, count_down_4, count_down_3, count_down_2, count_down_1, count_down_0};
            end
            default: begin
                disp_data_r = 32'b0;
            end
        endcase
    end

    always @(*) begin
        case(disp_state_c)
            CLOCK: begin
                if (disp_ct_btn & ((fsm_state == 4'b0001) | (fsm_state == 4'b1000))) begin
                    disp_state_n = CHECKTIME;
                end
                else if (disp_int_btn & ((fsm_state == 4'b0001) | (fsm_state == 4'b1000))) begin
                    disp_state_n = INTEVAL;
                end
                else if (disp_wt_btn & ((fsm_state == 4'b0001) | (fsm_state == 4'b1000))) begin
                    disp_state_n = WORKTIME;
                end
                else if (gear_button == 3'b100) begin // gear 3
                    disp_state_n = COUNT_DOWN;
                end
                else if (power_on_button || power_off_button) begin // enter checktime
                    disp_state_n = COUNT_DOWN;
                end
                else if (clean_button) begin
                    disp_state_n = COUNT_DOWN;
                end
                else begin
                    disp_state_n = CLOCK;
                end
            end
            WORKTIME: begin
                if (disp_clk_btn) begin
                    disp_state_n = CLOCK;
                end
                else begin
                    disp_state_n = WORKTIME;
                end
            end
            INTEVAL: begin
                if (disp_clk_btn) begin
                    disp_state_n = CLOCK;
                end
                else begin
                    disp_state_n = INTEVAL;
                end
            end
            CHECKTIME: begin
                if (disp_clk_btn) begin
                    disp_state_n = CLOCK;
                end
                else begin
                    disp_state_n = CHECKTIME;
                end
            end
            COUNT_DOWN: begin
                case (fsm_state)
                    4'b0110: begin
                        disp_state_n = COUNT_DOWN;
                    end
                    4'b0111: begin
                        disp_state_n = COUNT_DOWN;
                    end
                    4'b1001: begin
                        disp_state_n = COUNT_DOWN;
                    end
                    4'b1010: begin
                        disp_state_n = COUNT_DOWN;
                    end
                    4'b0011: begin
                        disp_state_n = COUNT_DOWN;
                    end
                    default: begin
                        disp_state_n = CLOCK;
                    end
                endcase
            end
            default: begin
                disp_state_n = CLOCK;
            end
        endcase
    end

    seg_display seg_display_inst(
        .clk(clk_div),
        .rst(rst),
        .en(enable),
        .data(disp_data_r),
        .seg_left(seg_left),
        .seg_right(seg_right),
        .sel_left(sel_left),
        .sel_right(sel_right)
    );

    frequency_divider freq_div_inst(
        .clk(clk),
        .rst(rst),
        .clk_div(clk_div)
    );
    assign disp_state = disp_state_c;

    // -- segment display -- //

endmodule

module seg_display (
    input clk,                      // clock signal (after frequency division, 1000 ~ 1500 Hz)
    input rst,

    input en,                       // enable signal
    input [32:0] data,              // 24-bit data input

    output reg [7:0] seg_left,      // left 7-segment display (low active)
    output reg [7:0] seg_right,     // right 7-segment display (low active)
    output reg [3:0] sel_left,      // left 7-segment display selector
    output reg [3:0] sel_right      // right 7-segment display selector
);
    parameter [7:0] SEG_DASH = 8'h02;
    parameter [3:0] DASH     = 4'b1111;

    wire [15:0] data_left, data_right;

    assign data_left  = { data[31:16] };  // 16-bit data
    assign data_right = { data[15:0]  };  // 16-bit data

    reg    [3:0] display_state = 4'b0001;  // one-hot state machine
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            sel_left <= 4'b0000;
            sel_right <= 4'b0000;
            seg_left <= 8'b0000_0000;
            seg_right <= 8'b0000_0000;
            display_state <= 4'b0001;
        end
        else begin
            if (en) begin
                case (display_state)
                    4'b0001: begin
                        sel_left <= 4'b0001;
                        seg_left <= seg_decoder(data_left[3:0]);
                        sel_right <= 4'b0001;
                        seg_right <= seg_decoder(data_right[3:0]);
                        display_state <= 4'b0010;
                    end
                    4'b0010: begin
                        sel_left <= 4'b0010;
                        seg_left <= seg_decoder(data_left[7:4]);
                        sel_right <= 4'b0010;
                        seg_right <= seg_decoder(data_right[7:4]);
                        display_state <= 4'b0100;
                    end
                    4'b0100: begin
                        sel_left <= 4'b0100;
                        seg_left <= seg_decoder(data_left[11:8]);
                        sel_right <= 4'b0100;
                        seg_right <= seg_decoder(data_right[11:8]);
                        display_state <= 4'b1000;
                    end
                    4'b1000: begin
                        sel_left <= 4'b1000;
                        seg_left <= seg_decoder(data_left[15:12]);
                        sel_right <= 4'b1000;
                        seg_right <= seg_decoder(data_right[15:12]);
                        display_state <= 4'b0001;
                    end
                    default: begin
                        sel_left <= 4'b0000;
                        sel_right <= 4'b0000;
                        seg_left <= 8'b0000_0000;
                        seg_right <= 8'b0000_0000;
                        display_state <= 4'b0001;
                    end
                endcase
            end
            else begin
                sel_left <= 4'b0000;
                sel_right <= 4'b0000;
                seg_left <= 8'b0000_0000;
                seg_right <= 8'b0000_0000;
                display_state <= 4'b0001;
            end
        end
    end


    function [7:0] seg_decoder;
        input [3:0] data;
        begin
            case (data)  // high active
                4'h0 : seg_decoder = 8'hfc;
                4'h1 : seg_decoder = 8'h60;
                4'h2 : seg_decoder = 8'hda;
                4'h3 : seg_decoder = 8'hf2;
                4'h4 : seg_decoder = 8'h66;
                4'h5 : seg_decoder = 8'hb6;
                4'h6 : seg_decoder = 8'hbe;
                4'h7 : seg_decoder = 8'he4;
                4'h8 : seg_decoder = 8'hfe;
                4'h9 : seg_decoder = 8'hf6;
                4'hA : seg_decoder = 8'hee;
                4'hB : seg_decoder = 8'h3e;
                4'hC : seg_decoder = 8'h9c;
                4'hD : seg_decoder = 8'h7a;
                4'hE : seg_decoder = 8'h9e;
                4'hF : seg_decoder = 8'h02; // DASH
                default : seg_decoder = 8'h00;
            endcase
        end
    endfunction
endmodule

module frequency_divider(
    input clk,
    input rst,
    output reg clk_div
    );

    parameter [31:0] DIVIDE = 'd100_000;

    reg [31:0] cnt;

    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            cnt <= 0;
            clk_div <= 1'b0;
        end else begin
            if (cnt >= DIVIDE) begin
                clk_div <= ~clk_div;
                cnt <= 0;
            end else begin
                cnt <= cnt + 1;
            end
        end
    end

endmodule

module time_format (
    input [31:0]  time_in,
    output [3:0]  hour_h,
    output [3:0]  hour_l,
    output [3:0]  minute_h,
    output [3:0]  minute_l,
    output [3:0]  second_h,
    output [3:0]  second_l
);
    /* format time into hh-mm-ss */
    wire [5:0] hour = time_in / 'd3600;
    wire [5:0] minute = time_in % 'd3600 / 'd60;
    wire [5:0] second  = time_in % 'd60;

    assign hour_h = hour / 'd10;
    assign hour_l = hour % 'd10;

    assign minute_h = minute / 'd10;
    assign minute_l = minute % 'd10;

    assign second_h = second / 'd10;
    assign second_l = second % 'd10;

endmodule

module dec_format (
    input [31:0]   data,
    output [3:0]   dec_7,
    output [3:0]   dec_6,
    output [3:0]   dec_5,
    output [3:0]   dec_4,
    output [3:0]   dec_3,
    output [3:0]   dec_2,
    output [3:0]   dec_1,
    output [3:0]   dec_0
);

    assign dec_7 = data / 'd1000_0000;
    assign dec_6 = (data % 'd1000_0000) / 'd1000_000;
    assign dec_5 = (data % 'd1000_000) / 'd1000_00;
    assign dec_4 = (data % 'd1000_00) / 'd1000_0;
    assign dec_3 = (data % 'd1000_0) / 'd1000;
    assign dec_2 = (data % 'd1000) / 'd100;
    assign dec_1 = (data % 'd100) / 'd10;
    assign dec_0 = data % 'd10;

endmodule

module handle_toggle (
    input               clk,
    input               rst,
    input               toggle,
    output reg [1:0]    state,
    output reg          rise
);

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= 2'b01;
            rise <= 1'b0;
        end else if (toggle) begin
            rise <= state[0];
            state <= {state[0], state[1]};
        end
        else begin
            state <= state;
            rise <= 1'b0;
        end
    end
endmodule
