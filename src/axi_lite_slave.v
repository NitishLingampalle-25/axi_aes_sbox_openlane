module axi_lite_slave (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [3:0]  s_axi_awaddr,
    input  wire        s_axi_awvalid,
    output wire        s_axi_awready,
    input  wire [31:0] s_axi_wdata,
    input  wire        s_axi_wvalid,
    output wire        s_axi_wready,
    output wire [1:0]  s_axi_bresp,
    output reg         s_axi_bvalid,
    input  wire        s_axi_bready,
    input  wire [3:0]  s_axi_araddr,
    input  wire        s_axi_arvalid,
    output wire        s_axi_arready,
    output reg  [31:0] s_axi_rdata,
    output reg  [1:0]  s_axi_rresp,
    output reg         s_axi_rvalid,
    input  wire        s_axi_rready
);

    // Internal Registers
    reg [31:0] reg_in_data;
    reg [31:0] reg_control;
    reg [31:0] reg_status;
    wire [31:0] reg_out_data;

    // FSM States
    localparam STATE_IDLE    = 2'b00;
    localparam STATE_COMPUTE = 2'b01;
    localparam STATE_DONE    = 2'b10;
    reg [1:0] current_state, next_state;

    // Core Instantiation
    aes_core_32bit crypto_core_inst (
        .data_in (reg_in_data),
        .data_out(reg_out_data)
    );

    // Combinational AXI Handshake Assignments
    assign s_axi_awready = !s_axi_bvalid; 
    assign s_axi_wready  = !s_axi_bvalid;
    assign s_axi_bresp   = 2'b00; // OKAY
    assign s_axi_arready = !s_axi_rvalid;
    assign s_axi_rresp   = 2'b00; // OKAY

    // FSM State Updates
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= STATE_IDLE;
        else        current_state <= next_state;
    end

    always @(*) begin
        next_state = current_state;
        case (current_state)
            STATE_IDLE:    if (reg_control[0]) next_state = STATE_COMPUTE;
            STATE_COMPUTE: next_state = STATE_DONE;
            STATE_DONE:    next_state = STATE_IDLE;
            default:       next_state = STATE_IDLE;
        endcase
    end

    // Register Write & FSM Execution Block
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_status  <= 32'h0;
            reg_control <= 32'h0;
            reg_in_data <= 32'h0;
            s_axi_bvalid <= 1'b0;
        end else begin
            // Write Channel Catch
            if (s_axi_awvalid && s_axi_wvalid && !s_axi_bvalid) begin
                s_axi_bvalid <= 1'b1;
                case (s_axi_awaddr)
                    4'h0: reg_in_data <= s_axi_wdata;
                    4'h4: if (current_state == STATE_IDLE) reg_control[0] <= s_axi_wdata[0];
                    default: ;
                endcase
            end else if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end

            // State Machine Status Flags Management
            case (current_state)
                STATE_IDLE: begin
                    reg_status[0] <= 1'b0; // BUSY = 0
                end
                STATE_COMPUTE: begin
                    reg_control[0] <= 1'b0; // Auto-clear start
                    reg_status[0]  <= 1'b1; // BUSY = 1
                    reg_status[1]  <= 1'b0; // DONE = 0
                end
                STATE_DONE: begin
                    reg_status[0]  <= 1'b0; // BUSY = 0
                    reg_status[1]  <= 1'b1; // DONE = 1
                end
            endcase
        end
    end

    // Read Channel Management
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_rvalid <= 1'b0;
            s_axi_rdata  <= 32'h0;
        end else begin
            if (s_axi_arvalid && !s_axi_rvalid) begin
                s_axi_rvalid <= 1'b1;
                case (s_axi_araddr)
                    4'h0: s_axi_rdata <= reg_in_data;
                    4'h4: s_axi_rdata <= reg_control;
                    4'h8: s_axi_rdata <= reg_status;
                    4'hC: s_axi_rdata <= reg_out_data;
                    default: s_axi_rdata <= 32'hDEADBEEF;
                endcase
            end else if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end

endmodule
