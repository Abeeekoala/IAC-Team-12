module ff1 (
    input logic             clk,
    input logic [31:0]      InstrF,
    input logic [31:0]      PCF,
    input logic [31:0]      inc_PCF,
    input logic             stall_in,
    
    output logic [31:0]     InstrD,
    output logic [31:0]     PCD,
    output logic [31:0]     inc_PCD
);

always_ff @ (posedge clk)
    begin
        if (!stall_in) begin
            InstrD <= InstrF; 
            PCD <= PCF;
            inc_PCD <= inc_PCF;
        end
    end

endmodule
