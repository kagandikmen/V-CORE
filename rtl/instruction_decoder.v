// Instruction decoder of the CPU
// Created:     2024-01-20
// Modified:    2025-06-03
// Author:      Kagan Dikmen

module instruction_decoder
    #(
    parameter OPD_LENGTH = 32,
    parameter REG_WIDTH = 32
    )(
    input clk,
    input rst,
    input [31:0] instr,
    
    output reg [4:0] rs1_addr,
    output reg [4:0] rs2_addr,
    output reg [4:0] rd_addr,
    input [REG_WIDTH-1:0] rs1_data,
    input [REG_WIDTH-1:0] rs2_data,

    output reg [OPD_LENGTH-1:0] opd1,
    output reg [OPD_LENGTH-1:0] opd2,
    output bypass_ex_result_rs1,
    output bypass_ex_result_rs2,
    output bypass_me_result_rs1,
    output bypass_me_result_rs2
    );

    `include "../lib/common_library.vh"

    reg [4:0] rd_buff [1:0];

    reg rs1_sourced, rs2_sourced;

    assign bypass_ex_result_rs1 = ((rd_buff[1] == rs1_addr) && (rd_buff[1] != 5'b0) && rs1_sourced) ? 1'b1 : 1'b0;
    assign bypass_ex_result_rs2 = ((rd_buff[1] == rs2_addr) && (rd_buff[1] != 5'b0) && rs2_sourced) ? 1'b1 : 1'b0;

    assign bypass_me_result_rs1 = ((rd_buff[0] == rs1_addr) && (rd_buff[0] != 5'b0) && rs1_sourced) ? 1'b1 : 1'b0;
    assign bypass_me_result_rs2 = ((rd_buff[0] == rs2_addr) && (rd_buff[0] != 5'b0) && rs2_sourced) ? 1'b1 : 1'b0;

    always @(*)
    begin        
        rd_addr = instr [11:7];
        rs1_addr = instr [19:15];
        rs2_addr = instr [24:20];

        opd1 = rs1_data;
        opd2 = rs2_data;

        case(instr[6:0])
            R_OPCODE:
            begin
                rs1_sourced = 1'b1;
                rs2_sourced = 1'b1;
            end
            I_OPCODE:
            begin
                rs1_sourced = 1'b1;
                rs2_sourced = 1'b0;
            end
            LOAD_OPCODE:
            begin
                rs1_sourced = 1'b1;
                rs2_sourced = 1'b0;
            end
            S_OPCODE:
            begin
                rs1_sourced = 1'b1;
                rs2_sourced = 1'b1;
            end
            B_OPCODE:
            begin
                rs1_sourced = 1'b1;
                rs2_sourced = 1'b1;
            end
            JAL_OPCODE:
            begin
                rs1_sourced = 1'b0;
                rs2_sourced = 1'b0;
            end
            JALR_OPCODE:
            begin
                rs1_sourced = 1'b1;
                rs2_sourced = 1'b0;
            end
            LUI_OPCODE:
            begin
                rs1_sourced = 1'b0;
                rs2_sourced = 1'b0;
            end
            AUIPC_OPCODE:
            begin
                rs1_sourced = 1'b0;
                rs2_sourced = 1'b0;
            end
            FENCE_OPCODE:
            begin
                rs1_sourced = 1'b0;
                rs2_sourced = 1'b0;
            end
            SYSTEM_OPCODE:
            begin
                if(instr[14:12] == FUNCT3_ECALL_EBREAK)
                begin
                    rs1_sourced = 1'b0;
                    rs2_sourced = 1'b0;
                end
                else
                begin
                    rs1_sourced = 1'b1;
                    rs2_sourced = 1'b0;
                end
            end
            default:
            begin
                rs1_sourced = 1'b0;
                rs2_sourced = 1'b0;
            end
        endcase
    end

    always @(posedge clk)
    begin
        rd_buff[1] <= rd_addr;
        rd_buff[0] <= rd_buff[1];
        
        if(rst)
        begin
            rd_buff[1] <= 5'b00;
            rd_buff[0] <= 5'b00;
        end
    end

endmodule