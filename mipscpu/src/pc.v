module pc_reg(clk,
        instr_addr,
        reset,
        pc);
input clk;
input reset;
input [31:0] instr_addr;
reg [31:0] pc;

always @(posedge clk or reset) 
begin
    if (reset) 
    begin
        pc <= 32'b0;
    end
    else
    begin
        pc <= pc + 4;        
    end
end
endmodule
