`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/27 19:03:42
// Design Name: 
// Module Name: Exhaust_Hood
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
`include "display.v"
`include "uart_tx.v"

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

    // output alias-name offset
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
    wire            set_button;            // advanced setting
    wire            reset_button;          // reset to default
    wire            reset_wt_button;       // reset worktime
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
    wire [1:0] power_button_state;
    wire power_button_rise;

    assign clean_button    = output_grp[C];
    assign gear_button     = output_grp[THREE:ONE];
    assign toggle_light_button    = output_grp[L];
    assign set_button      = output_grp[E];
    assign reset_button    = output_grp[R];
    assign disp_wt_button  = output_grp[O];
    assign disp_ct_button  = output_grp[X];
    assign disp_int_button = output_grp[V];
    assign disp_clk_btn    = output_grp[M];
    assign reset_wt_button = output_grp[T];
    assign power_button    = power_button_state[1];

    // wire net for output of main module
    wire [3:0]      status;
    wire            light;
    wire            alert;
    wire [31:0]     worktime;
    wire [31:0]     interval;
    wire [31:0]     check_time;
    wire [31:0]     count_down;
    wire [1:0]      set_state;
    wire [1:0]      set_ptr;
    wire            out_valid;
    wire            gear3_aval;
    wire [31:0]     systime;
    wire [31:0]     timer;

    assign debug_set_state = set_state;

    // wire net for output of debug
    assign debug_status = status;
    assign debug_light = light;
    assign debug_alert = alert;
    assign debug_T = power_button;

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
    wire [1:0] left_button_state;
    wire [1:0] right_button_state;
    handle_toggle power_on_toggle(
        .clk(clk),
        .rst(rst),
        .toggle(toggle_power_on_button),
        .state(left_button_state),
        .rise(power_on_button)
    );
    handle_toggle power_off_toggle(
        .clk(clk),
        .rst(rst),
        .toggle(toggle_power_off_button),
        .state(right_button_state),
        .rise(power_off_button)
    );
    wire [1:0] up_button_state;
    wire [1:0] down_button_state;
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
        .state(up_button_state),
        .rise(up_button)
    );
    handle_toggle down_toggle(
        .clk(clk),
        .rst(rst),
        .toggle(toggle_down_button),
        .state(down_button_state),
        .rise(down_button)
    );
    wire [1:0] menu_button_state;
    handle_toggle menu_toggle(
        .clk(clk),
        .rst(rst),
        .toggle(toggle_menu_button),
        .state(menu_button_state),
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
    Exhaust_Hood main(
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
        .reset_wt_button(reset_wt_button),
        .set_button(set_button),
        .set_int_button(disp_int_button),
        .set_ct_button(disp_ct_button),
        .set_clk_button(set_clk_button),
        .disp_clk_btn(disp_clk_btn),
        .add_button(up_button),
        .sub_button(down_button),
        .add_button_state(up_button_state[1]),
        .sub_button_state(down_button_state[1]),
        .left_button(left_button),
        .right_button(right_button),

        /* connect view */
        .worktime_view(worktime),
        .interval_view(interval),
        .checktime_view(check_time),
        .count_down(count_down),
        .systime_view(systime),
        .gear3_aval_view(gear3_aval),
        .set_ptr_view(set_ptr),
        .set_state_view(set_state),
        .out_valid_view(out_valid),
        .timer_view(timer),

        .status(status),
        .light(light),
        .alert(alert)
    );

    wire [2:0] disp_state_o;

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

        .disp_state(disp_state_o),
        .seg_left(seg_left),
        .seg_right(seg_right),
        .sel_left(sel_left),
        .sel_right(sel_right)
    );
    wire menu_but_st = menu_button_state[1];
    // UART output instance
    uart_output my_output_inst(
        .clk(clk),
        .rst(rst),
        .data({
            status,light,alert,gear3_aval,power_button,
            set_ptr,set_state,disp_state_o,menu_but_st,
            left_button_state[1],right_button_state[1],up_button_state[1],down_button_state[1],
            12'd0,
            systime,worktime,timer,interval,check_time
        }),
        .data_valid(out_valid),
        .tx_out(uart_tx)
    );

endmodule

module Exhaust_Hood(

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
    input           reset_button ,          // reset to default
    input           reset_wt_button ,       // reset worktime
    input           set_button ,
    input           set_int_button ,
    input           set_ct_button ,
    input           set_clk_button ,
    input           disp_clk_btn ,
    input           add_button ,
    input           sub_button ,
    input           add_button_state ,
    input           sub_button_state ,
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
    output [31:0]   timer_view ,
    output          gear3_aval_view ,
    output [1:0]    set_ptr_view ,
    output [1:0]    set_state_view ,
    output          out_valid_view ,

    /* count down control */
    output [31:0]   count_down
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
    reg [31:0]  add_tick;           // tick of hold time of add button
    reg [31:0]  sub_tick;           // tick of hold time of sub button
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

    reg         do_add;
    reg         do_sub;
    always @(*) begin
        if(!rst) begin
            do_add = 1'b0;
            do_sub = 1'b0;
        end
        else begin
            do_add = add_button || (add_tick >= 50_000_000 && add_tick % 8_000_000 == 0);
            do_sub = sub_button || (sub_tick >= 50_000_000 && sub_tick % 8_000_000 == 0);
        end
    end


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
            power_tick      <= 32'b0;
            add_tick        <= 32'b0;
            sub_tick        <= 32'b0;
            set_position    <= 2'b00;
        end
        else begin
            if (stable_tick == 8_000_000 - 1) begin
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

            if (cur_status == nxt_status && add_button_state) begin
                add_tick <= add_tick + 1;
            end
            else add_tick <= 0;
            if (cur_status == nxt_status && sub_button_state) begin
                sub_tick <= sub_tick + 1;
            end
            else sub_tick <= 0;

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
                modify_time(do_add, do_sub);
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

    task modify_time;
        input is_add;
        input is_sub;
        case (set_position)
            2'b00: systime <= systime;
            2'b01: begin
                if (is_add) begin
                    if (systime >= 24*60*60 - 1) systime <= systime;
                    else systime <= systime + 1;
                end
                else if (is_sub) begin
                    if (systime == 0) systime <= systime;
                    else systime <= systime - 1;
                end
                else systime <= systime;
            end
            2'b10: begin
                if (is_add) begin
                    if (systime >= 24*60*60 - 60) systime <= systime;
                    else systime <= systime + 60;
                end
                else if (is_sub) begin
                    if (systime < 60) systime <= systime;
                    else systime <= systime - 60;
                end
                else systime <= systime;
            end
            2'b11: begin
                if (is_add) begin
                    if (systime >= 24*60*60 - 3600) systime <= systime;
                    else systime <= systime + 3600;
                end
                else if (is_sub) begin
                    if (systime < 3600) systime <= systime;
                    else systime <= systime - 3600;
                end
                else systime <= systime;
            end
            default: systime <= systime;
        endcase
    endtask

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

    // 状main state machine
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
        .reset_button(reset_button | reset_wt_button),
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
                    if (do_add) begin
                        case(set_position)
                            2'b00: interval <= interval;
                            2'b01: interval <= interval + 1;
                            2'b10: interval <= interval + 60;
                            2'b11: interval <= interval + 3600;
                            default: interval <= interval;
                        endcase
                    end
                    else if (do_sub) begin
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
                    if (do_add) begin
                        check_time <= check_time + 1;
                    end
                    else if (do_sub) begin
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

    assign status   = cur_status;
    assign light    = cur_light;

    // output view
    assign worktime_view = cur_worktime;
    assign interval_view = interval;
    assign checktime_view = check_time;
    assign systime_view  = systime;
    assign timer_view = timer;
    assign gear3_aval_view = cur_gear3_available;
    assign set_ptr_view = set_position;
    assign set_state_view = set_state_c;
    assign out_valid_view = out_valid;

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

    // status list
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
