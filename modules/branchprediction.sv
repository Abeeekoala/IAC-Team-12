module branchprediction#(
    parameter BHT = 256,
              PC_Width = 8,     //index table with lower bits of PC
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
state_t bht [0:BHT_SIZE-1];

//predicted outcome based on BHT entry
assign prediction = (bht[pc] == WT || bht[pc] == ST);

//based on outcome of branch_taken, the FSM transitions between states
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin                                   //all BHT initialised to SNT
        for (int i = 0; i < BHT_SIZE, i++) begin
            bht[i] <= SNT;
        end
    end
    else begin
        //update BHT based on actual branch outcome 
        case (bht[pc])
        SNT: bht[pc] <= branch_taken ? WNT : SNT; //transition to WNT if taken
        WNT: bht[pc] <= branch_taken ? WT : SNT; //move to WT or back to SNT
        WT: bht[pc] <= branch_taken ? ST : WNT; //move to ST or back to WNT
        ST: bht[pc] <= branch_taken ? ST : WT; //stay in ST or move to WT
        endcase
    end
end

endmodule
        