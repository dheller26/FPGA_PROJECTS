`timescale 1ns / 1ps
///THIS PROJECT WILL IMPLEMENT ECHO TO SERIAL MONITOR 
module uart_loopback_top 
#(
    parameter BAUD_RATE = 9600,
    parameter CLK_HZ = 100_000_000
)
(
    input clk,               // 100 MHz system clock
    input i_rx_serial,       // UART RX from PC
    output o_tx_serial,      // UART TX to PC
    output [7:0] rx_message  // Latest received character (e.g., for LEDs)
);

    // Internal UART RX signals
    wire rx_valid;
    wire [7:0] rx_byte;

    // Internal UART TX control
    reg        tx_valid = 0;
    wire       tx_active;
    wire       tx_done;
    reg [7:0]  tx_data = 8'd0;

    // FSM States
    localparam S_IDLE     = 3'd0,
               S_SEND_CR  = 3'd1,
               S_WAIT_CR  = 3'd2,
               S_SEND_LF  = 3'd3,
               S_WAIT_LF  = 3'd4,
               S_SEND_CHAR = 3'd5,
               S_WAIT_CHAR = 3'd6;

    reg [2:0] state = S_IDLE;
    reg [7:0] char_buffer = 8'd0;  // store RX byte temporarily

    // Instantiate UART RX
    uart_rx #(
        .BAUD_RATE(BAUD_RATE),
        .CLK_HZ(CLK_HZ)
    ) uart_rx_inst (
        .source_clk(clk),
        .i_rx_serial(i_rx_serial),
        .o_rx_valid(rx_valid),
        .o_RX_message(rx_byte)
    );

    // Instantiate UART TX
    uart_tx #(
        .BAUD_RATE(BAUD_RATE),
        .CLK_HZ(CLK_HZ)
    ) uart_tx_inst (
        .source_clk(clk),
        .i_tx_valid(tx_valid),
        .tx_message(tx_data),
        .tx_active(tx_active),
        .tx_serial(o_tx_serial),
        .done(tx_done)
    );

    // FSM: Echo characters or send newline on Enter
    always @(posedge clk) begin
        case (state)
            S_IDLE: begin
                tx_valid <= 0;
                if (rx_valid) begin
                    char_buffer <= rx_byte;
                    if (rx_byte == 8'h0D) begin  // ENTER key (CR)
                        state <= S_SEND_CR;
                    end else begin
                        state <= S_SEND_CHAR;
                    end
                end
            end

            // Handle Enter Key (\r\n)
            S_SEND_CR: begin
                tx_data <= 8'h0D;  // '\r'
                tx_valid <= 1;
                state <= S_WAIT_CR;
            end

            S_WAIT_CR: begin
                tx_valid <= 0;
                if (tx_done)
                    state <= S_SEND_LF;
            end

            S_SEND_LF: begin
                tx_data <= 8'h0A;  // '\n'
                tx_valid <= 1;
                state <= S_WAIT_LF;
            end

            S_WAIT_LF: begin
                tx_valid <= 0;
                if (tx_done)
                    state <= S_IDLE;
            end

            // Handle normal character echo
            S_SEND_CHAR: begin
                tx_data <= char_buffer;
                tx_valid <= 1;
                state <= S_WAIT_CHAR;
            end

            S_WAIT_CHAR: begin
                tx_valid <= 0;
                if (tx_done)
                    state <= S_IDLE;
            end

            default: state <= S_IDLE;
        endcase
    end

    // Optional output to LEDs (or display)
    assign rx_message = char_buffer;

endmodule

