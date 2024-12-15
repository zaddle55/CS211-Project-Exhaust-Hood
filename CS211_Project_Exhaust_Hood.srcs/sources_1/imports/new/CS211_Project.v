`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/27 19:03:42
// Design Name: 
// Module Name: CS211_Project
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
`include "ps2_input.v"

module top(
        input       clk,
        input       rst,

        /*      ps2 input       */
        input       ps2_data,
        input       ps2_clk,

        /*      uart send      */
        output uart_tx,

        /* output for debug */
        output [3:0] debug_status,
        output debug_light,
        output debug_alert,
        output [1:0] debug_set_state,
        output [2:0] debug_clock_state,
        output debug_T,
        // output [15:0] debug_output_grp,

        /* output for segment display */
        output [7:0] seg_left,
        output [7:0] seg_right,
        output [3:0] sel_left,
        output [3:0] sel_right
        // ...
    );

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

    // wire net for input of main module
    wire            power_button;
    wire [2:0]      light_button;
    wire [2:0]      gear_button;
    wire            power_on_button;
    wire            power_off_button;
    wire            menu_button;
    wire            clean_button;
    wire            toggle_light_button;
    wire            up_button;
    wire            down_button;
    wire            set_button;            // priority setting
    wire            reset_button;           // reset worktime
    wire            disp_wt_button;        // display worktime
    wire            disp_int_button;       // button for interval lookup
    wire            disp_ct_button;        // button for checktime lookup
    wire            set_clk_button;        // clock setting button
    wire            disp_clk_btn;          // display clock button
    wire            press_light_button;    // if light button is pressed
    wire            left_button;
    wire            right_button;
    wire [31:0]     output_grp;
    //..

    wire toggle_power_button = output_grp[P];
    wire toggle_power_on_button = output_grp[A];
    wire toggle_power_off_button = output_grp[D];
    wire toggle_menu_button     = output_grp[SPACE];
    wire toggle_left_button = output_grp[LEFT];
    wire toggle_right_button = output_grp[LEFT];
    wire toggle_up_button = output_grp[W];
    wire toggle_down_button = output_grp[S];
    wire toggle_set_clk_button = output_grp[N];

    assign clean_button    = output_grp[C];
    assign gear_button     = output_grp[THREE:ONE];
    assign toggle_light_button    = output_grp[L];
    assign set_button      = output_grp[E];
    assign reset_button    = output_grp[R];
    assign disp_wt_button  = output_grp[O];
    assign disp_ct_button  = output_grp[X];
    assign disp_int_button = output_grp[V];
    assign disp_clk_btn    = output_grp[M];
    wire [1:0] power_button_state;
    wire power_button_rise;
    assign power_button    = power_button_state[1];

    // wire net for output of main module
    wire [3:0]      status;
    wire            light;
    wire            alert;
    wire [31:0]     worktime;
    wire [31:0]     interval;
    wire [31:0]     check_time;
    wire [31:0]     count_down;

    // wire net for output of debug
    assign debug_status = status;
    assign debug_light = light;
    assign debug_alert = alert;
    assign debug_T = power_button;
    // assign debug_output_grp = output_grp;


    // wire net for output of clock
    wire [2:0] clock_state;
    wire [31:0] systime;

    // input handle
    ps2_input translator(
        .clk(clk),
        .rst(rst),

        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),

        .output_grp(output_grp)
    );

    handle_toggle light_toggle(
        .clk(clk),
        .rst(rst),
        .toggle(toggle_light_button),
        .state(),
        .rise(press_light_button)
    );
    handle_toggle light_press_toggle(
        .clk(clk),
        .rst(rst),
        .toggle(press_light_button),
        .state(light_button),
        .rise()
    );
    handle_toggle power_toggle(
        .clk(clk),
        .rst(rst),
        .toggle(toggle_power_button),
        .state(power_button_state),
        .rise(power_button_rise)
    );
    handle_toggle power_on_toggle(
        .clk(clk),
        .rst(rst),
        .toggle(toggle_power_on_button),
        .state(),
        .rise(power_on_button)
    );
    handle_toggle power_off_toggle(
        .clk(clk),
        .rst(rst),
        .toggle(toggle_power_off_button),
        .state(),
        .rise(power_off_button)
    );
    handle_toggle left_toggle(
        .clk(clk),
        .rst(rst),
        .toggle(toggle_left_button),
        .state(),
        .rise(left_button)
    );
    handle_toggle right_toggle(
        .clk(clk),
        .rst(rst),
        .toggle(toggle_right_button),
        .state(),
        .rise(right_button)
    );
    handle_toggle up_toggle(
        .clk(clk),
        .rst(rst),
        .toggle(toggle_up_button),
        .state(),
        .rise(up_button)
    );
    handle_toggle down_toggle(
        .clk(clk),
        .rst(rst),
        .toggle(toggle_down_button),
        .state(),
        .rise(down_button)
    );
    handle_toggle menu_toggle(
        .clk(clk),
        .rst(rst),
        .toggle(toggle_menu_button),
        .state(),
        .rise(menu_button)
    );
    handle_toggle set_clk_toggle(
        .clk(clk),
        .rst(rst),
        .toggle(toggle_set_clk_button),
        .state(),
        .rise(set_clk_button)
    );

    // main module
    CS211_Project main(
        .clk(clk),
        .rst(rst),

        .power_button(power_button),
        .power_button_rise(power_button_rise),
        .power_on_button(power_on_button),
        .power_off_button(power_off_button),
        .menu_button(menu_button),
        .clean_button(clean_button),

        .light_button(light_button),
        .gear_button(gear_button),
        .reset_button(reset_button),
        .set_button(set_button),
        .set_int_button(disp_int_button),
        .set_ct_button(disp_ct_button),
        .set_clk_button(set_clk_button),
        .disp_clk_btn(disp_clk_btn),
        .add_button(up_button),
        .sub_button(down_button),
        .left_button(left_button),
        .right_button(right_button),

        .worktime_view(worktime),
        .interval_view(interval),
        .checktime_view(check_time),
        .count_down(count_down),
        .systime_view(systime),

        .debug_set_state(debug_set_state),

        .status(status),
        .light(light),
        .alert(alert),

        .uart_tx(uart_tx)
    );


    // display handle
    handle_display display_handle(
        .clk(clk),
        .rst(rst),
        .fsm_state(status),

        .clk_time(systime),
        .disp_clk_btn(set_clk_button | menu_button | disp_clk_btn),

        .worktime(worktime),
        .disp_wt_btn(disp_wt_button),

        .checktime(check_time),
        .disp_ct_btn(disp_ct_button),

        .interval(interval),
        .disp_int_btn(disp_int_button),

        .count_down(count_down),
        .power_on_button(power_on_button),
        .power_off_button(power_off_button),
        .gear_button(gear_button),
        .clean_button(clean_button),

        .disp_state(),
        .seg_left(seg_left),
        .seg_right(seg_right),
        .sel_left(sel_left),
        .sel_right(sel_right)
    );


endmodule

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

    output reg [2:0]    disp_state,
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

module CS211_Project(

    /* system input */
    input           clk ,
    input           rst ,

    /* button input */
    input           power_button ,          // basic power button
    input           power_button_rise ,     // rise edge of power button
    input           power_on_button ,       // gesture power on
    input           power_off_button ,      // gesture power off
    input           menu_button ,           // to menu button
    input           clean_button ,          // self clean button
    input [1:0]     light_button ,          // light control button
    input [2:0]     gear_button ,           // gear select button
    input           reset_button ,
    input           set_button ,
    input           set_int_button ,
    input           set_ct_button ,
    input           set_clk_button ,
    input           disp_clk_btn ,
    input           add_button ,
    input           sub_button ,
    input           left_button ,
    input           right_button ,

    /* output */
    output [3:0]    status ,            // current status
    output          light  ,            // light output
    output          alert ,             // alert output

    /* parameter view output */
    output [31:0]   systime_view,
    output [31:0]   worktime_view ,
    output [31:0]   interval_view ,
    output [31:0]   checktime_view ,

    /* count down control */
    output [31:0]   count_down ,

    /* debug output */
    output [1:0]    debug_set_state,

    /* uart output */
    output          uart_tx             // uart signal
    // ...
    );

    reg [31:0]  timer;              // current state going time
    reg [31:0]  timer_tick;
    reg [31:0]  systime;            // poewr on time
    reg [31:0]  sys_tick;           // tick of power on time
    reg [31:0]  cur_worktime;
    wire [31:0] nxt_worktime;
    reg [31:0]  cur_worktick;
    reg [31:0]  power_tick;         // tick of hold time of power button
    wire [31:0] nxt_worktick;
    reg [3:0]   cur_status;
    wire [3:0]  nxt_status;
    reg         cur_light;
    reg         nxt_light;
    reg         out_valid;           // uart output valid signal
    reg         cur_gear3_available; // is gear 3 available
    wire        nxt_gear3_available;
    reg [31:0]  stable_tick;
    reg [1:0]   set_position;        // ptr for clock setting

    // state transition & systime update
    always @(posedge clk or negedge rst) begin
        if (!rst) begin                 // if reset or power off
            cur_status      <= 4'b0;
            cur_light       <= 1'b0;
            systime         <= 32'b0;
            sys_tick        <= 32'b0;
            timer           <= 32'b0;
            timer_tick      <= 32'b0;
            cur_worktick    <= 32'b0;
            cur_worktime    <= 32'b0;
            cur_gear3_available <= 1'b1;
            stable_tick     <= 32'b0;
            set_position    <= 2'b00;
        end
        else begin
            if (stable_tick == 15_000_000 - 1) begin
                out_valid <= 1'b1;
                stable_tick <= 32'b0;
            end
            else begin
                out_valid <= 1'b0;
                stable_tick <= stable_tick + 1;
            end
            if (cur_status == nxt_status && power_button && cur_status <= 1) begin
                power_tick <= power_tick + 1;
            end
            else power_tick <= 0;
            if (cur_status == nxt_status) begin
                if (timer_tick == 1_000_000 - 1) begin
                    timer_tick <= 0;
                    timer <= timer + 1;
                end
                else begin
                    timer_tick <= timer_tick + 1;
                    timer <= timer;
                end
            end
            else begin
                timer <= 32'b0;
                timer_tick <= 32'b0;
            end
            cur_status      <= nxt_status;
            cur_light       <= nxt_light;
            cur_worktime    <= nxt_worktime;
            cur_worktick    <= nxt_worktick;
            cur_gear3_available <= nxt_gear3_available;

            // set_position update
            if (cur_status == 4'b1011 || cur_status == 4'b1000) begin
                if (power_on_button) begin
                    if (set_position == 2'b11) set_position <= set_position;
                    else set_position <= set_position + 1;
                end
                else if (power_off_button) begin
                    if (set_position == 2'b01) set_position <= set_position;
                    else set_position <= set_position - 1;
                end
                else set_position <= set_position;
            end
            else if (nxt_status == 4'b1011 || nxt_status == 4'b1000) begin
                set_position <= 2'b01;
            end
            else begin
                set_position <= 2'b00;
            end

            if (cur_status == 4'b0000 || cur_status == 4'b1001) begin
                systime <= 32'b0;
                sys_tick <= 32'b0;
            end

            // systime update
            else if(cur_status == 4'b1011) begin
                if (add_button) begin
                    case(set_position)
                        2'b00: systime <= systime;
                        2'b01: begin
                            if (systime >= 24*60*60 - 1) systime <= systime;
                            else systime <= systime + 1;
                        end
                        2'b10: begin
                            if (systime >= 24*60*60 - 60) systime <= systime;
                            else systime <= systime + 60;
                        end
                        2'b11: begin
                            if (systime >= 24*60*60 - 3600) systime <= systime;
                            else systime <= systime + 3600;
                        end
                        default: systime <= systime;
                    endcase
                end
                else if (sub_button) begin
                    case(set_position)
                        2'b00: systime <= systime;
                        2'b01: begin
                            if (systime == 0) systime <= systime;
                            else systime <= systime - 1;
                        end
                        2'b10: begin
                            if (systime < 60) systime <= systime;
                            else systime <= systime - 60;
                        end
                        2'b11: begin
                            if (systime < 3600) systime <= systime;
                            else systime <= systime - 3600;
                        end
                        default: systime <= systime;
                    endcase
                end
                else systime <= systime;
                sys_tick <= 32'b0;
            end
            else begin
                if (sys_tick == 100_000_000 - 1) begin
                    sys_tick <= 0;
                    if (systime == 24*60*60 - 1) systime <= 0;
                    else systime <= systime + 1;
                end
                else begin
                    sys_tick <= sys_tick + 1;
                    systime <= systime;
                end
            end
        end
    end

    // light control
    always @(*) begin
        case(cur_status)
            4'b0000: nxt_light = 1'b0;
            4'b1001: nxt_light = 1'b0;
            default:
                case(light_button)
                    2'b01: nxt_light = 1'b0;
                    2'b10: nxt_light = 1'b1;
                    default: nxt_light = cur_light;
                endcase
        endcase
    end

    // parameter default value
    parameter [31:0] DEFAULT_INTERVAL = 10*60*60;   // default maximum worktime  [10h]
    parameter [31:0] DEFAULT_CHECK_TIME = 5;        // default gesture checktime [5s]

    // register initialization
    reg [31:0] interval = DEFAULT_INTERVAL;
    reg [31:0] check_time = DEFAULT_CHECK_TIME;

    // ״main state machine
    state_machine state_machine_inst(
        .power_tick(power_tick),
        .timer(timer),
        .cur_status(cur_status),
        .power_button(power_button),
        .power_button_rise(power_button_rise),
        .power_on_button(power_on_button),
        .power_off_button(power_off_button),
        .menu_button(menu_button),
        .clean_button(clean_button),
        .reset_button(reset_button),
        .set_button(set_button),
        .set_clk_button(set_clk_button),
        .gear_button(gear_button),
        .cur_worktime(cur_worktime),
        .cur_worktick(cur_worktick),
        .nxt_worktime(nxt_worktime),
        .nxt_worktick(nxt_worktick),
        .nxt_status(nxt_status),
        .alert(alert),
        .interval(interval),
        .check_time(check_time),
        .cur_gear3_available(cur_gear3_available),
        .nxt_gear3_available(nxt_gear3_available)
        );

    assign status   = cur_status;
    assign light    = cur_light;

    // output time data
    assign worktime_view = cur_worktime;
    assign interval_view = interval;
    assign checktime_view = check_time;
    assign systime_view  = systime;

    //        -- count down handle --        //
    reg [31:0] cur_cnt_down_ub = 32'b0;
    reg [31:0] nxt_cnt_down_ub = 32'b0;

    localparam GEAR3_COUNTDOWN = 32'd60;
    localparam FORCED_COUNTDOWN = 32'd60;
    localparam CLEAN_COUNTDOWN = 32'd180;

    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            cur_cnt_down_ub <= 0;
        end
        else begin
            cur_cnt_down_ub <= nxt_cnt_down_ub;
        end
    end

    always @(*) begin
        case (cur_status)
            4'b1001: begin
                nxt_cnt_down_ub = check_time;
            end
            4'b1010: begin
                nxt_cnt_down_ub = check_time;
            end
            4'b0011: begin
                nxt_cnt_down_ub = CLEAN_COUNTDOWN;
            end
            4'b0110: begin
                nxt_cnt_down_ub = GEAR3_COUNTDOWN;
            end
            4'b0111: begin
                nxt_cnt_down_ub = FORCED_COUNTDOWN;
            end
            default: begin
                nxt_cnt_down_ub = 32'b0;
            end
        endcase
    end

    assign count_down = cur_cnt_down_ub - timer / 'd100;


    //        -- set handle --        //

    // set state machine
    localparam SET_STATE_IDLE = 2'b00;
    localparam SET_STATE_NORM = 2'b01;
    localparam SET_STATE_INT  = 2'b10;
    localparam SET_STATE_CT   = 2'b11;

    reg [1:0] set_state_n = SET_STATE_IDLE;
    reg [1:0] set_state_c = SET_STATE_IDLE;

    // debug output
    assign debug_set_state = set_state_c;

    // state
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            set_state_c <= SET_STATE_IDLE;
        end
        else begin
            set_state_c <= set_state_n;
        end
    end

    // next state transition
    always @(*) begin
        case (set_state_c)
            SET_STATE_IDLE: begin
                if (cur_status == 4'b1000) begin
                    set_state_n = SET_STATE_NORM;
                end
                else begin
                    set_state_n = SET_STATE_IDLE;
                end
            end
            SET_STATE_NORM: begin
                if (menu_button | (cur_status != 4'b1000) ) begin
                    set_state_n = SET_STATE_IDLE;
                end
                else if (set_int_button) begin
                    set_state_n = SET_STATE_INT;
                end
                else if (set_ct_button) begin
                    set_state_n = SET_STATE_CT;
                end
                else begin
                    set_state_n = SET_STATE_NORM;
                end
            end
            SET_STATE_INT: begin
                if (menu_button | (cur_status != 4'b1000)) begin
                    set_state_n = SET_STATE_IDLE;
                end
                else if (disp_clk_btn) begin
                    set_state_n = SET_STATE_NORM;
                end
                else begin
                    set_state_n = SET_STATE_INT;
                end
            end
            SET_STATE_CT: begin
                if (menu_button | (cur_status != 4'b1000)) begin
                    set_state_n = SET_STATE_IDLE;
                end
                else if (disp_clk_btn) begin
                    set_state_n = SET_STATE_NORM;
                end
                else begin
                    set_state_n = SET_STATE_CT;
                end
            end
            default: begin
                set_state_n = SET_STATE_IDLE;
            end
        endcase
    end

    // set handle
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            interval <= DEFAULT_INTERVAL;
            check_time <= DEFAULT_CHECK_TIME;
        end
        else begin
            case (set_state_c)
                SET_STATE_IDLE: begin
                    if (cur_status == 4'b0010 && reset_button) begin  // reset to default
                        interval <= DEFAULT_INTERVAL;
                        check_time <= DEFAULT_CHECK_TIME;
                    end else begin
                        interval <= interval;
                        check_time <= check_time;
                    end
                end
                SET_STATE_INT: begin
                    if (add_button) begin
                        case(set_position)
                            2'b00: interval <= interval;
                            2'b01: interval <= interval + 1;
                            2'b10: interval <= interval + 60;
                            2'b11: interval <= interval + 3600;
                            default: interval <= interval;
                        endcase
                    end
                    else if (sub_button) begin
                        case(set_position)
                            2'b00: interval <= interval;
                            2'b01: begin
                                if (interval == 0) interval <= interval;
                                else interval <= interval - 1;
                            end
                            2'b10: begin
                                if (interval < 60) interval <= interval;
                                else interval <= interval - 60;
                            end
                            2'b11: begin
                                if (interval < 3600) interval <= interval;
                                else interval <= interval - 3600;
                            end
                            default: interval <= interval;
                        endcase
                    end
                end
                SET_STATE_CT: begin
                    if (add_button) begin
                        check_time <= check_time + 1;
                    end
                    else if (sub_button) begin
                        if (check_time > 0) check_time <= check_time - 1;
                    end
                end
                default: begin
                    interval <= interval;
                    check_time <= check_time;
                end
            endcase
        end
    end

    // UART output instance
    uart_output my_output_inst(
        .clk(clk),
        .rst(rst),
        .data({status,light,alert,cur_gear3_available,power_button,set_position,set_state_c,20'd0,systime,cur_worktime,timer,interval,check_time}),
        .data_valid(out_valid),
        .tx_out(uart_tx)
    );

endmodule

module state_machine(
    /* state variables input*/
    input [31:0]     power_tick ,
    input [31:0]     timer ,
    input [3:0]      cur_status ,           // current status
    input [31:0]     cur_worktime ,
    input [31:0]     cur_worktick ,
    input            cur_gear3_available ,

    /* button input */
    input            power_button ,         // basic power button
    input            power_button_rise ,    // rise edge of power button
    input            power_on_button ,      // gesture power on
    input            power_off_button ,     // gesture power off
    input            menu_button ,          // to menu button
    input            clean_button ,         // self clean button
    input            reset_button ,
    input            set_button ,
    input            set_clk_button ,
    input [2:0]      gear_button ,          // gear select button

    /* parameter input */
    input [31:0]     interval ,
    input [31:0]     check_time ,

    /* state variables output */
    output reg [31:0]     nxt_worktime ,
    output reg [31:0]     nxt_worktick ,
    output reg [3:0]      nxt_status ,           // next status
    output reg            alert ,                // alert if worktime exceed interval
    output reg            nxt_gear3_available    // is gear 3 available
    );

    parameter TICKS_PER_SECOND = 100_000_000;
    parameter [31:0] DEFAULT_WAIT_TICKS = TICKS_PER_SECOND;

    // ���̻�״̬
    parameter [3:0] OFF         = 4'b0000;   // off
    parameter [3:0] STANDBY     = 4'b0001;   // stand by
    parameter [3:0] MENU        = 4'b0010;   // menu
    parameter [3:0] CLEAN       = 4'b0011;   // self clean
    parameter [3:0] GEAR1       = 4'b0100;   // gear 1
    parameter [3:0] GEAR2       = 4'b0101;   // gear 2
    parameter [3:0] GEAR3       = 4'b0110;   // gear 3
    parameter [3:0] FORCED      = 4'b0111;   // forced to stand by
    parameter [3:0] SET         = 4'b1000;   // advanced setting
    parameter [3:0] CHECK_START = 4'b1001;   // start check state
    parameter [3:0] CHECK_OFF   = 4'b1010;   // off check state
    parameter [3:0] TIME_SET    = 4'b1011;   // system time setting


    // worktime & tick initialization
    initial begin
        alert = 1'b0;
        nxt_worktime = 32'b0;
        nxt_worktick = 32'b0;
    end

    // gear3_available
    always @(*) begin
        case (cur_status)
            OFF: nxt_gear3_available = 1'b1;
            GEAR3: nxt_gear3_available = 1'b0;
            default: nxt_gear3_available = cur_gear3_available;
        endcase
    end

    // worktime & tick
    always @(*) begin
        if (cur_status == OFF || cur_status == CLEAN) begin
            nxt_worktime = 32'b0;
            nxt_worktick = 32'b0;
        end
        else if (cur_status == GEAR1 || cur_status == GEAR2 || cur_status == GEAR3 || cur_status == FORCED) begin
            if (cur_worktick == TICKS_PER_SECOND - 1) begin
                nxt_worktime = cur_worktime + 1;
                nxt_worktick = 32'b0;
            end
            else begin
                nxt_worktime = cur_worktime;
                nxt_worktick = cur_worktick + 1;
            end
        end
        else if (cur_status == MENU && reset_button) begin
            nxt_worktick = 32'b0;
            nxt_worktime = 32'b0;
        end
        else begin
            nxt_worktime = cur_worktime;
            nxt_worktick = cur_worktick;
        end
    end

    // state
    always @(*) begin
        case(cur_status)
            OFF: begin
                if (power_button_rise) nxt_status = STANDBY;
                else if (power_on_button) nxt_status = CHECK_START; // start gesture power on countdown
                else nxt_status = OFF;
            end
            /*
            Check start state
                1. if power on button is pressed, and timer is less than check_time, then go to standby state
                2. else if timer is greater than check_time, then go to off state
            */
            CHECK_START:
                if (power_off_button) begin
                    if (timer <= check_time * 100) nxt_status = STANDBY;
                    else nxt_status = OFF;
                end
                else if (timer > check_time * 100) nxt_status = OFF;
                else nxt_status = CHECK_START;
            /*
            Standby state
                1. if menu button is pressed, then go to menu state
                2. if set clock button is pressed, then go to time set state
                3. if power off button is pressed, then go to check off state
                4. if power button is pressed for 3 seconds, then go to off state
            */
            STANDBY:
                if (menu_button) nxt_status = MENU;
                else if (set_clk_button) nxt_status = TIME_SET;
                else if (power_off_button) nxt_status = CHECK_OFF;
                else if (power_button && power_tick >= 3 * TICKS_PER_SECOND) nxt_status = OFF;
                else nxt_status = STANDBY;
            /*
            Check off state
                1. if power on button is pressed, and timer is less than check_time, then go to off state
                2. else if timer is greater than check_time, then go to standby state
            */
            CHECK_OFF:
                if (power_on_button) begin
                    if (timer <= check_time * 100)
                        nxt_status = OFF;
                end
                else if (timer > check_time * 100) nxt_status = STANDBY;
                else nxt_status = CHECK_OFF;
            /*
            Menu state
                1. if gear1/gear2 button is pressed, then go to gear1/gear2 state
                2. if gear3 button is pressed, and gear3 is available, then go to gear3 state
                3. if clean button is pressed, then go to clean state
                4. if reset button is pressed, then go to standby state
                5. if set button is pressed, then go to set state
            */
            MENU:
                if (gear_button[0]) nxt_status = GEAR1;
                else if (gear_button[1]) nxt_status = GEAR2;
                else if (gear_button[2] && cur_gear3_available && ~set_button) nxt_status = GEAR3;
                else if (clean_button) nxt_status = CLEAN;
                else if (reset_button && ~set_button) nxt_status = STANDBY;
                else if (set_button && ~gear_button[2]) nxt_status = SET;
                else nxt_status = MENU;
            /*
            Clean state
                1. work for 180s, then go to standby state
            */
            CLEAN:
                if (timer >= 180 * 100) nxt_status = STANDBY;
                else nxt_status = CLEAN;
            /*
            Gear1 state
                1. if gear2 button is pressed, then go to gear2 state
                2. if menu button is pressed, then go to standby state
            */
            GEAR1:
                if (gear_button[1]) nxt_status = GEAR2;
                else if (menu_button) nxt_status = STANDBY;
                else nxt_status = GEAR1;
            /*
            Gear2 state
                1. if gear1 button is pressed, then go to gear1 state
                2. if menu button is pressed, then go to standby state
            */
            GEAR2:
                if (gear_button[0]) nxt_status = GEAR1;
                else if (menu_button) nxt_status = STANDBY;
                else nxt_status = GEAR2;
            /*
            Gear3 state
                1. work for 60s, then go to gear2 state
                2. if menu button is pressed, then go to forced to standby state
                3. only one time for each power on
            */
            GEAR3:
                if (menu_button) nxt_status = FORCED;
                else if (timer >= 60 * 100) nxt_status = GEAR2;
                else nxt_status = GEAR3;
            /*
            Forced to standby state
                1. wait for 60s, then go to standby state
            */
            FORCED:
                if (timer >= 60 * 100) nxt_status = STANDBY;
                else nxt_status = FORCED;
            /*
            Set state
                1. if menu button is pressed, then go to standby state
                2. you can set maximum worktime and checktime in this state
            */
            SET:
                if (menu_button) nxt_status = STANDBY;
                else nxt_status = SET;
            /*
            Time set state
                1. if menu button is pressed, then go to standby state
                2. you can set system time in this state
            */
            TIME_SET:
                if (menu_button) nxt_status = STANDBY;
                else nxt_status = TIME_SET;
            default: nxt_status  <= OFF;
        endcase
    end

    // alert signal
    always @(cur_worktime) begin
        if (cur_worktime >= interval) begin
            alert = 1'b1;
        end
        else alert = 1'b0;
    end

endmodule


//==============================================

module uart_output(
	input clk ,
	input rst ,
	input [(BYTES*8-1):0] data ,
	input data_valid ,
	output output_done ,
	output tx_out
);
    parameter BYTES = 24;
    reg	[(BYTES*8-1):0] data_reg;
    reg                 tx_busy;
    reg	[7:0]           byte_cnt;
    reg	[7:0]           cur_data;
    reg                 tx_valid;
    reg                 uart_bytes_done_reg;
    reg                 uart_sing_done_reg;

    wire					tx_done;
    assign output_done = uart_bytes_done_reg;

    // data register update
    always @(posedge clk or negedge rst)begin
        if(!rst) data_reg <= 0;
        else if(data_valid && ~tx_busy) data_reg <= data;
        else if(tx_done) data_reg <= data_reg >> 8;
        else data_reg <= data_reg;
    end

    // data valid & tx_busy update
    always @(posedge clk or negedge rst)begin
        if(!rst) tx_busy <= 1'b0;
        else if(data_valid && ~tx_busy) tx_busy <= 1'b1;
        else if(tx_done && byte_cnt == BYTES - 1) tx_busy <= 1'b0;
        else tx_busy <= tx_busy;
    end

    // byte ptr update
    always @(posedge clk or negedge rst)begin
        if(!rst) byte_cnt <= 0;
        else if(tx_busy)begin
            if(tx_done && byte_cnt == BYTES - 1)
                byte_cnt <= 0;
            else if(tx_done)
                byte_cnt <= byte_cnt + 1'b1;
            else byte_cnt <= byte_cnt;
        end		
        else byte_cnt <= 0;	
    end

    always @(posedge clk or negedge rst)begin
        if(!rst) uart_sing_done_reg <= 0;
        else uart_sing_done_reg <= tx_done;	
    end

    // ���͵����ֽڵ�����
    always @(posedge clk or negedge rst)begin
        if(!rst) begin
            cur_data <= 8'd0;
            tx_valid <= 1'b0;
        end
        else if(data_valid && ~tx_busy) begin // update data
            cur_data <= data[7:0];
            tx_valid <= 1'b1;
        end
        else if(uart_sing_done_reg) begin
            cur_data <= data_reg[7:0];
            if (tx_busy) tx_valid <= 1'b1;
            else tx_valid <= 1'b0;
        end
        else begin
            cur_data <= cur_data;
            tx_valid <= 1'b0;
        end
    end

    //done�ź�
    always @(posedge clk or negedge rst)begin
        if(!rst) uart_bytes_done_reg <= 1'b0;
        else if(tx_done && byte_cnt == BYTES - 1) uart_bytes_done_reg <= 1'b1;
        else uart_bytes_done_reg <= 1'b0;
    end

    uart_tx uart_tx_inst(
        .clk(clk),
        .rst(rst),
        .data(cur_data),
        .data_valid(tx_valid),
        .tx_done(tx_done),
        .tx_out(tx_out)
    );

endmodule


module uart_tx(
    input       clk ,
    input       rst ,
    input       [7:0] data ,
    input       data_valid ,
	output reg  tx_done ,
	output reg  tx_out
);
    parameter BPS = 9600;
    parameter TICKS_PER_SEC = 100_000_000;
    parameter BPS_CNT = TICKS_PER_SEC / BPS; // max clk cnt for 1 bit

    reg         tx_state;   // tx send state
    reg [7:0]   data_reg;   // data register
    reg [31:0]  clk_cnt;    // clk counter
    reg [3:0]   bit_cnt;    // bit counter

    always @(posedge clk or negedge rst)begin
        if(!rst) data_reg <=8'd0;
        else if(data_valid) data_reg <= data;
        else data_reg <= data_reg;
    end

    always @(posedge clk or negedge rst)begin
        if(!rst) tx_state <= 1'b0;
        else if(data_valid) tx_state <= 1'b1;
        else if((bit_cnt == 9) && (clk_cnt == BPS_CNT - 1'b1)) tx_state <= 1'b0;
        else tx_state <= tx_state;
    end

    always @(posedge clk or negedge rst) begin
        if(!rst) tx_done <=1'b0;
        else if((bit_cnt == 9) && (clk_cnt == BPS_CNT - 1'b1)) tx_done <=1'b1;
        else tx_done <=1'b0;
    end

    always @(posedge clk or negedge rst) begin
        if(!rst)begin
            clk_cnt <= 32'd0;
            bit_cnt <= 4'd0;
        end
        else if(tx_state) begin
            if(clk_cnt < BPS_CNT - 1'd1) begin
                clk_cnt <= clk_cnt + 1'b1;
                bit_cnt <= bit_cnt;
            end
            else begin
                clk_cnt <= 32'd0;
                bit_cnt <= bit_cnt+1'b1;
            end
        end
        else begin
            clk_cnt <= 32'd0;
            bit_cnt <= 4'd0;
        end
    end

    always @(posedge clk or negedge rst)begin
        if(!rst) tx_out <= 1'b1;
        else if(tx_state)
            case(bit_cnt)
                4'd0: tx_out <= 1'b0;
                4'd1: tx_out <= data_reg[0];
                4'd2: tx_out <= data_reg[1];
                4'd3: tx_out <= data_reg[2];
                4'd4: tx_out <= data_reg[3];
                4'd5: tx_out <= data_reg[4];
                4'd6: tx_out <= data_reg[5];
                4'd7: tx_out <= data_reg[6];
                4'd8: tx_out <= data_reg[7];
                4'd9: tx_out <= 1'b1;
                default:tx_out <= 1'b1;
            endcase
        else tx_out <= 1'b1;
    end
endmodule