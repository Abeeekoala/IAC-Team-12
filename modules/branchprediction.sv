module branchprediction#(
    parameter BTB_size = 256,        //branch target buffer
              PC_Width = 5,     //index table with lower bits of PC (log2BTB)
)(
    input logic                 clk,
    input logic                 rst,
    input logic [PC_Width-1:0]  PC,
    input logic                 branch_taken, //1: taken, 0: not taken
    output logic                prediction
);

typedef enum logic [1:0]{
    SNT = 2'b00;            //strongly not taken
    WNT = 2'b01;            //weakly not taken
    WT = 2'b10;             //weakly taken
    ST = 2'b11;             //strongly taken
} state_t;

//branch history table: indexed by PC, stores 2-bit states
state_t BTB[BTB_SIZE-1:0];

//temporary signals for gate level logic
logic pred_taken, pred_not_taken;           //AND gate outputs
logic result_taken, result_not_taken;       //signals for prediction and result matching

//predicted outcome based on BHT entry
assign prediction = (BTB[PC_out] == WT || BTB[PC_out] == ST);

//based on outcome of branch_taken, the FSM transitions between states
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin                                   //all BTB initialised to SNT
        for (int i = 0; i < BTB_SIZE, i++) begin
            BTB[i] <= SNT;
        end
    end
    else begin
        //update BTB based on actual branch outcome 
        case (BTB[PC])
        SNT: BTB[PC] <= branch_taken ? WNT : SNT; //transition to WNT if taken
        WNT: BTB[PC] <= branch_taken ? WT : SNT; //move to WT or back to SNT
        WT: BTB[PC] <= branch_taken ? ST : WNT; //move to ST or back to WNT
        ST: BTB[PC] <= branch_taken ? ST : WT; //stay in ST or move to WT
        endcase
    end
end

//AND gate logic
assign pred_taken = (BTB[PC] == WT || BTB[PC] == ST);
assign pred_not_taken = ~pred_taken;

//final prediction logic
assign prediction = result_taken | result_not_taken;

endmodule
        