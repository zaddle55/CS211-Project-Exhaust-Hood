`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/01 17:13:10
// Design Name: 
// Module Name: 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: define ps2 keyboard code
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// make code for ps2 keyboard
`define     PS2_A       8'h1C
`define     PS2_B       8'h32
`define     PS2_C       8'h21
`define     PS2_D       8'h23
`define     PS2_E       8'h24
`define     PS2_F       8'h2B
`define     PS2_G       8'h34
`define     PS2_H       8'h33
`define     PS2_I       8'h43
`define     PS2_J       8'h3B
`define     PS2_K       8'h42
`define     PS2_L       8'h4B
`define     PS2_M       8'h3A
`define     PS2_N       8'h31
`define     PS2_O       8'h44
`define     PS2_P       8'h4D
`define     PS2_Q       8'h15
`define     PS2_R       8'h2D
`define     PS2_S       8'h1B
`define     PS2_T       8'h2C
`define     PS2_U       8'h3C
`define     PS2_V       8'h2A
`define     PS2_W       8'h1D
`define     PS2_X       8'h22
`define     PS2_Y       8'h35
`define     PS2_Z       8'h1A
`define     PS2_0       8'h45
`define     PS2_1       8'h16
`define     PS2_2       8'h1E
`define     PS2_3       8'h26
`define     PS2_4       8'h25
`define     PS2_5       8'h2E
`define     PS2_6       8'h36
`define     PS2_7       8'h3D
`define     PS2_8       8'h3E
`define     PS2_9       8'h46
`define     PS2_F1      8'h05
`define     PS2_F2      8'h06
`define     PS2_F3      8'h04
`define     PS2_F4      8'h0C
`define     PS2_F5      8'h03
`define     PS2_F6      8'h0B
`define     PS2_F7      8'h83
`define     PS2_F8      8'h0A
`define     PS2_F9      8'h01
`define     PS2_F10     8'h09
`define     PS2_F11     8'h78
`define     PS2_F12     8'h07
`define     PS2_ESC     8'h76
`define     PS2_TAB     8'h0D
`define     PS2_ENTER   8'h5A
`define     PS2_SPACE   8'h29
`define     PS2_BACK    8'h66
`define     PS2_LSHIFT  8'h12
`define     PS2_RSHIFT  8'h59
`define     PS2_LCTRL   8'h14
`define     PS2_RCTRL   8'h14
`define     PS2_LALT    8'h11
`define     PS2_RALT    8'h11
`define     PS2_CAPS    8'h58
`define     PS2_NUM     8'h77
`define     PS2_SCROLL  8'h7E
`define     PS2_INSERT  8'hE0
`define     PS2_DELETE  8'h71

// extended code
`define     PS2_HOME    8'h6C
`define     PS2_END     8'h69
`define     PS2_PGUP    8'h7D
`define     PS2_PGDN    8'h7A
`define     PS2_UP      8'h75
`define     PS2_DOWN    8'h72
`define     PS2_LEFT    8'h6B
`define     PS2_RIGHT   8'h74
`define     PS2_PRINT   8'h7C
`define     PS2_PAUSE   8'hE1
`define     PS2_BREAK   8'hE1
`define     PS2_WIN     8'hE0
`define     PS2_MENU    8'hE0
`define     PS2_APPS    8'hE0

// keypad code
`define     PS2_KP0     8'h70
`define     PS2_KP1     8'h69
`define     PS2_KP2     8'h72
`define     PS2_KP3     8'h7A
`define     PS2_KP4     8'h6B
`define     PS2_KP5     8'h73
`define     PS2_KP6     8'h74
`define     PS2_KP7     8'h6C
`define     PS2_KP8     8'h75
`define     PS2_KP9     8'h7D
`define     PS2_KPSTAR  8'h7C
`define     PS2_KPPLUS  8'h79
`define     PS2_KPMINUS 8'h7B
`define     PS2_KPPOINT 8'h71
`define     PS2_KPSLASH 8'hE0
`define     PS2_KPENTER 8'hE0
`define     PS2_KPDOT   8'h71
`define     PS2_KPCOMMA 8'h70
`define     PS2_KPEQUAL 8'h75
`define     PS2_KPEQUAL2 8'h79
`define     PS2_KPEQUAL3 8'h7D


// break code
`define     PS2_BREAK_PREFIX    8'hF0
