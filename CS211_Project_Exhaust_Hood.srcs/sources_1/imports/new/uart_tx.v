`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/15 15:45:04
// Design Name: 
// Module Name: uart_tx
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


module uart_output #
(
    parameter BYTES = 24
)
(
	input clk ,
	input rst ,
	input [(BYTES*8-1):0] data ,
	input data_valid ,
	output output_done ,
	output tx_out
);

    reg	[(BYTES*8-1):0] data_reg;
    reg                 tx_busy;
    reg	[7:0]           byte_cnt;   // bytes have been sent
    reg	[7:0]           cur_data;   // byte to be sent
    reg                 tx_valid;   // control signal of tx
    reg                 bytes_done; // all bytes have been sent
    reg                 sing_done;  // the current byte has been sent

    wire				tx_done;
    assign output_done = bytes_done;

    // data register
    always @(posedge clk or negedge rst)begin
        if(!rst) data_reg <= 0;
        else if(data_valid && ~tx_busy) data_reg <= data;
        else if(tx_done) data_reg <= data_reg >> 8; // right shift to send the next byte
        else data_reg <= data_reg;
    end

    // busy signal
    always @(posedge clk or negedge rst)begin
        if(!rst) tx_busy <= 1'b0;
        else if(data_valid && ~tx_busy) tx_busy <= 1'b1;
        else if(tx_done && byte_cnt == BYTES - 1) tx_busy <= 1'b0;
        else tx_busy <= tx_busy;
    end

    // byte counter
    always @(posedge clk or negedge rst)begin
        if(!rst) byte_cnt <= 0;
        else if(tx_busy)begin
            if(tx_done && byte_cnt == BYTES - 1) byte_cnt <= 0; // all bytes have been sent
            else if(tx_done) byte_cnt <= byte_cnt + 1'b1; // send the next byte
            else byte_cnt <= byte_cnt;
        end		
        else byte_cnt <= 0;	
    end

    always @(posedge clk or negedge rst)begin
        if(!rst) sing_done <= 0;
        else sing_done <= tx_done;
    end

    // send single byte
    always @(posedge clk or negedge rst)begin
        if(!rst) begin
            cur_data <= 8'd0;
            tx_valid <= 1'b0;
        end
        else if(data_valid && ~tx_busy) begin // start: send the first byte
            cur_data <= data[7:0];
            tx_valid <= 1'b1;
        end
        else if(sing_done) begin // send the next byte (after right shift)
            cur_data <= data_reg[7:0];
            if (tx_busy) tx_valid <= 1'b1;
            else tx_valid <= 1'b0;
        end
        else begin
            cur_data <= cur_data;
            tx_valid <= 1'b0;
        end
    end

    // all done signal
    always @(posedge clk or negedge rst)begin
        if(!rst) bytes_done <= 1'b0;
        else if(tx_done && byte_cnt == BYTES - 1) bytes_done <= 1'b1;
        else bytes_done <= 1'b0;
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

    // tx state
    always @(posedge clk or negedge rst)begin
        if(!rst) tx_state <= 1'b0;
        else if(data_valid) tx_state <= 1'b1;
        else if((bit_cnt == 9) && (clk_cnt == BPS_CNT - 1'b1)) tx_state <= 1'b0;
        else tx_state <= tx_state;
    end

    // done signal
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
            if(clk_cnt < BPS_CNT - 1'd1) begin // wait for the clock
                clk_cnt <= clk_cnt + 1'b1;
                bit_cnt <= bit_cnt;
            end
            else begin // send the next bit
                clk_cnt <= 32'd0;
                bit_cnt <= bit_cnt + 1'b1;
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
