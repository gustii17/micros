module ExecutionLine (
    input clk,
    input reset,
    output reg done
);

    // ---------- INTERNAL SIGNALS ----------
    wire [7:0] opcode;
    wire [7:0] operand1;
    wire [7:0] operand2;
    wire write_enable;
    wire [7:0] address;
    wire [23:0] data_out;
    wire loader_done;

    wire [7:0] reg_out1;
    wire [7:0] reg_out2;
    wire [7:0] alu_result;

    reg [7:0] write_address;
    reg [7:0] write_data;
    reg write_enable_reg;

    // ---------- MODULE INSTANCES ----------

    // 1️⃣ Instruction Loader (reads binary file)
    InstructionLoader loader (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .operand1(operand1),
        .operand2(operand2),
        .done(loader_done),
        .write_enable(write_enable),
        .address(address),
        .data_out(data_out)
    );

    // 2️⃣ Register Bank
    RegisterBank regs (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable_reg),
        .write_address(write_address[2:0]),
        .write_data(write_data),
        .read_address1(operand1[2:0]),
        .read_address2(operand2[2:0]),
        .read_data1(reg_out1),
        .read_data2(reg_out2)
    );

    // 3️⃣ ALU (arithmetic and logic unit)
    ALU alu (
        .opcode(opcode),
        .A(reg_out1),
        .B(reg_out2),
        .result(alu_result)
    );

    // ---------- EXECUTION ----------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            write_enable_reg <= 0;
            done <= 0;
        end else if (!loader_done) begin
            case (opcode)
                8'h00: begin // MOV
                    write_address <= operand1;
                    write_data <= operand2;
                    write_enable_reg <= 1;
                    $display("MOV R%d, %d -> R%d = %d", operand1, operand2, operand1, operand2);
                end

                8'h01: begin // ADD
                    write_address <= operand1;
                    write_data <= alu_result;
                    write_enable_reg <= 1;
                    $display("ADD R%d, R%d -> result = %d", operand1, operand2, alu_result);
                end

                8'h02: begin // ADDin (register + immediate)
                    write_address <= operand1;
                    write_data <= alu_result;
                    write_enable_reg <= 1;
                    $display("ADDin R%d, %d -> result = %d", operand1, operand2, alu_result);
                end

                8'h03: begin // SUB
                    write_address <= operand1;
                    write_data <= alu_result;
                    write_enable_reg <= 1;
                    $display("SUB R%d, R%d -> result = %d", operand1, operand2, alu_result);
                end

                8'h04: begin // DIV
                    write_address <= operand1;
                    write_data <= alu_result;
                    write_enable_reg <= 1;
                    $display("DIV R%d, R%d -> result = %d", operand1, operand2, alu_result);
                end

                8'h05: begin // MUL
                    write_address <= operand1;
                    write_data <= alu_result;
                    write_enable_reg <= 1;
                    $display("MUL R%d, R%d -> result = %d", operand1, operand2, alu_result);
                end

                8'h06: begin // RES (special / reserved)
                    write_enable_reg <= 0;
                    $display("RES (reserved instruction)");
                end

                8'h07: begin // CMP
                    write_enable_reg <= 0; // comparação apenas altera flags (não registradores)
                    $display("CMP R%d, R%d", operand1, operand2);
                end

                8'h08: begin // AND
                    write_address <= operand1;
                    write_data <= alu_result;
                    write_enable_reg <= 1;
                    $display("AND R%d, R%d -> result = %d", operand1, operand2, alu_result);
                end

                8'h09: begin // ORR
                    write_address <= operand1;
                    write_data <= alu_result;
                    write_enable_reg <= 1;
                    $display("ORR R%d, R%d -> result = %d", operand1, operand2, alu_result);
                end

                8'h0A: begin // NOT
                    write_address <= operand1;
                    write_data <= alu_result;
                    write_enable_reg <= 1;
                    $display("NOT R%d -> result = %d", operand1, alu_result);
                end

                8'h0B: begin // XOR
                    write_address <= operand1;
                    write_data <= alu_result;
                    write_enable_reg <= 1;
                    $display("XOR R%d, R%d -> result = %d", operand1, operand2, alu_result);
                end

                8'hFF: begin // NOP
                    write_enable_reg <= 0;
                    $display("NOP");
                end

                default: begin
                    write_enable_reg <= 0;
                    $display("Unknown instruction (opcode = %b)", opcode);
                end
            endcase
        end else begin
            done <= 1;
            write_enable_reg <= 0;
            $display("=== Execution finished ===");
        end
    end

endmodule
