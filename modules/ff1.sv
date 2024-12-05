module ff1 (
    input logic             clk,
    input logic [31:0]      InstF,
    input logic [31:0]      PCF,
    input logic [31:0]      inc_PCF,
    
    output logic [31:0]     InstrD,
    output logic [31:0]     PCD,
    output logic [31:0]     inc_PCD
);

always_ff @ (posedge clk)
    begin
        InstrD <= InstF;
        PCD <= PCF;
        inc_PCD <= inc_PCF;
    end

endmodule
