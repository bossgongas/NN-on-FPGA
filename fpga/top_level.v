module top_level (
    input wire clk,
    input wire reset,
    input wire [7:0] vga_data,
    input wire vga_valid,
    input wire right_click,
    output wire [7:0] classification_result,
    output wire classification_valid
);

    // Neural Network Interface
    reg [`dataWidth-1:0] in;
    reg in_valid;
    wire axis_in_data_ready;
    wire intr;

    // AXI Lite Interface
    wire [31:0] s_axi_awaddr;
    wire s_axi_awvalid;
    wire s_axi_awready;
    wire [31:0] s_axi_wdata;
    wire s_axi_wvalid;
    wire s_axi_wready;
    wire s_axi_bvalid;
    wire s_axi_bready;
    wire [31:0] s_axi_araddr;
    wire [31:0] s_axi_rdata;
    wire s_axi_arvalid;
    wire s_axi_arready;
    wire s_axi_rvalid;
    wire s_axi_rready;
    reg [31:0] axiRdData;

    // VGA Capture Interface
    wire capture_done;
    reg [7:0] frame_buffer [0:783];

    // Instantiate the VGA sync module
    vga_sync vga_sync_inst (
        .clock_50Mhz(clk),
        .red(1'b0),
        .green(1'b0),
        .blue(1'b0),
        .red_out(),
        .green_out(),
        .blue_out(),
        .horiz_sync_out(),
        .vert_sync_out(),
        .video_on(),
        .pixel_clock(),
        .pixel_row(pixel_row),
        .pixel_column(pixel_col)
    );

    // Instantiate the image capture module
    image_capture image_capture_inst (
        .clk(clk),
        .reset(reset),
        .vga_data(vga_data),
        .pixel_row(pixel_row),
        .pixel_col(pixel_col),
        .right_click(right_click),
        .frame_buffer(frame_buffer),
        .capture_done(capture_done)
    );

    // Instantiate the neural network module (zyNet)
    zyNet dut (
        .s_axi_aclk(clk),
        .s_axi_aresetn(~reset),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awprot(0),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(4'hF),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bresp(),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arprot(0),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),
        .axis_in_data(in),
        .axis_in_data_valid(in_valid),
        .axis_in_data_ready(axis_in_data_ready),
        .intr(intr)
    );

    // State Machine for sending data to the neural network
    reg [9:0] read_index;
    reg [1:0] state;
    localparam IDLE = 2'b00, READ = 2'b01, WAIT_INTR = 2'b10;

    reg [31:0] axi_address;
    reg axi_read_pending;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            read_enable <= 0;
            in_valid <= 0;
            read_index <= 0;
            state <= IDLE;
            axi_read_pending <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (capture_done) begin
                        read_enable <= 1;
                        state <= READ;
                    end
                end
                READ: begin
                    if (read_index < 784) begin
                        in <= frame_buffer[read_index];
                        in_valid <= 1;
                        read_index <= read_index + 1;
                    end else begin
                        read_enable <= 0;
                        in_valid <= 0;
                        read_index <= 0;
                        state <= WAIT_INTR;
                    end
                end
                WAIT_INTR: begin
                    if (intr) begin
                        axi_read_pending <= 1;
                        axi_address <= 8;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    assign s_axi_arvalid = axi_read_pending;
    assign s_axi_araddr = axi_address;
    assign s_axi_rready = 1;

    always @(posedge clk) begin
        if (s_axi_rvalid) begin
            axiRdData <= s_axi_rdata;
        end
    end

    // Output the classification result
    assign classification_result = (axiRdData == 1) ? 8'h01 : 8'h00;
    assign classification_valid = intr;

endmodule
