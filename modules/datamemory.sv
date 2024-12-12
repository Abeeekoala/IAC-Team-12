module datamemory #(
    parameter DATA_WIDTH = 32,
              MEM_WIDTH  = 8
) (
    input logic trigger,                // Input trigger (MMIO)
    input logic clk,                    // Clock signal
    input logic WE,                     // Write enable for store instructions
    input logic [DATA_WIDTH-1:0] A,     // Memory address (calculated by ALU)
    input logic [DATA_WIDTH-1:0] WD,    // Data to write into memory
    input logic [2:0] funct3,           // Instruction's funct3 field
    output logic [DATA_WIDTH-1:0] RD    // Data read from memory
);


    typedef enum {IDLE, MMIO_requested, MMIO_recieved} MMIO_state;
    MMIO_state current_state, next_state;
    logic MMIO_access;
    assign MMIO_access = (A == 32'h000000FC);

    // Memory array: 2^17 locations 0x00000000 to 0x0001FFFF, each MEM_WIDTH bits wide
    logic [MEM_WIDTH-1:0] mem [0:2**17-1];

    initial begin
        $readmemh("data.hex", mem, 32'h00010000);
        $display("Data Memory Contents After Initialization:");
        $display("mem[0] = %h", mem[32'h00010000]);
        $display("mem[1] = %h", mem[32'h00010001]);
        $display("mem[2] = %h", mem[32'h00010002]);
        $display("mem[3] = %h", mem[32'h00010003]);
    end

    always_comb begin
        //MMIO FSM next_state logic
        case(current_state)
            IDLE: next_state = MMIO_access ? MMIO_requested : IDLE;
            MMIO_requested: next_state = trigger ? MMIO_recieved : MMIO_requested;
            MMIO_recieved: next_state = MMIO_access ? IDLE : MMIO_recieved;
        endcase

        // Read logic for load instructions
        RD = '0;
        if (MMIO_access && (current_state == MMIO_recieved)) begin
            RD = 32'h00000001;
        end 
        else begin
            // Regular memory read 
            case (funct3)
                3'b000: RD = {{24{mem[A][7]}}, mem[A]};                 // lb
                3'b001: RD = {{16{mem[A+1][7]}}, mem[A+1], mem[A]};    // lh
                3'b010: RD = {mem[A+3], mem[A+2], mem[A+1], mem[A]};    // lw
                3'b100: RD = {24'b0, mem[A]};                           // lbu
                3'b101: RD = {16'b0, mem[A+1], mem[A]};                 // lhu
                default: RD = 32'b0;                                    // Default case
            endcase
        end
    end

    // Write logic for store instructions
    always_ff @(posedge clk) begin
        if (WE) begin // Store instruction
            case (funct3)
                3'b000: mem[A] <= WD[7:0];      // sb
                3'b001: begin
                    mem[A + 1] <= WD[15:8];     // sh
                    mem[A] <= WD[7:0];
                end
                3'b010: begin
                    mem[A + 3] <= WD[31:24];    // sw
                    mem[A + 2] <= WD[23:16];
                    mem[A + 1] <= WD[15:8];
                    mem[A] <= WD[7:0];
                end
            endcase
        end
        // MMIO_FSM state transition logic
        current_state <= next_state;
    end

endmodule
