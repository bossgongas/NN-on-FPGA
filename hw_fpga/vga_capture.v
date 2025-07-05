module vga_capture (
    input wire clk,
    input wire reset,
    input wire [7:0] vga_data, // Assuming 8-bit VGA data
    input wire vga_valid,      // VGA data valid signal
    input wire right_click,    // Right-click signal from mouse
    output reg capture_done,
    output reg [7:0] read_data,
    output reg read_valid,
    input wire read_enable
);
    reg [7:0] frame_buffer [0:783]; // 28x28 frame buffer
    integer i;
    reg capturing;
    reg [9:0] read_index; // Allows indexing up to 1023

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            capturing <= 0;
            capture_done <= 0;
            read_index <= 0;
            for (i = 0; i < 784; i = i + 1) begin
                frame_buffer[i] <= 0;
            end
        end else if (right_click) begin
            capturing <= 1;
            capture_done <= 0;
        end else if (capturing && vga_valid) begin
            for (i = 0; i < 784; i = i + 1) begin
                frame_buffer[i] <= vga_data; // Adjust this if necessary for your VGA data handling
            end
            capturing <= 0;
            capture_done <= 1;
        end else if (read_enable) begin
            if (read_index < 784) begin
                read_data <= frame_buffer[read_index];
                read_valid <= 1;
                read_index <= read_index + 1;
            end else begin
                read_valid <= 0;
            end
        end
    end
endmodule
