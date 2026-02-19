module i2s_tx (
input wire clk, // System Clock
input wire reset, // high reset
  input wire [15:0] left_data, // 16-bit Left Channel Audio  Here if we change 15 to 23 to make it 24 bit 
input wire [15:0] right_data,// 16-bit Right Channel Audio
output reg sck, // Serial Clock (derived)
output reg ws, // Word Select (Left=0, Right=1)
output reg sd // Serial Data
);
  // 1. Clock Generation
// We will divide the system clock by 2 to create SCK
always @(posedge clk or posedge reset) begin
if (reset)
sck <= 0;
else
sck <= ~sck;
end
  // 2. Main I2S Logic
reg [4:0] bit_counter; // Counts 0 to 31 (32 bits per frame)
reg [15:0] shift_reg; // Holds the data being sent
reg ws_delayed; // Used to detect edges
  always @(negedge sck or posedge reset) begin
if (reset) begin
bit_counter <= 0;
ws <= 0;
sd <= 0;
shift_reg <= 0;
end else begin
// Increment bit counter
bit_counter <= bit_counter + 1;
  // Generate Word Select (WS)
// 0-15: Left Channel (WS=0), 16-31: Right Channel (WS=1)
if (bit_counter < 15)
ws <= 0;
else if (bit_counter == 31) // Reset for next cycle
ws <= 0;
else
ws <= 1;
  // Load Shift Register// The protocol says MSB is sent 1 clock AFTER WS changes.
// We load data exactly when we are about to switch channels.
if (bit_counter == 31) begin
shift_reg <= left_data; // Load Left Data
end else if (bit_counter == 15) begin
shift_reg <= right_data; // Load Right Data
end else begin
shift_reg <= {shift_reg[14:0], 1'b0}; // Shift Left
end
  // Output Data (MSB First)
sd <= shift_reg[15];
end
end
endmodule
