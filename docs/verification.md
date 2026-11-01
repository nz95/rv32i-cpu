# Verification

The processor was verified throughout the project using self-checking SystemVerilog testbenches. Each major component was first tested independently before being integrated into the single-cycle CPU and later the five-stage pipelined CPU. This made it easier to find problems at the component level before testing the full processor.

## Individual Component Testing

The main components of the processor were tested independently before integration. These included the ALU, register file, program counter, instruction memory, immediate generator, control unit, ALU decoder, branch comparator, and data memory.

The pipeline-specific components were also tested independently, including the IF/ID, ID/EX, EX/MEM, and MEM/WB pipeline registers, forwarding unit, and hazard detection unit.

The testbenches used expected values to automatically check outputs and report whether each test passed or failed.

## Single-Cycle CPU Testing

After verifying the individual components, they were integrated into the single-cycle CPU. Several test programs were created to verify that instructions could move through the complete datapath correctly.

Testing included arithmetic and logical instructions, memory operations, branch instructions, JAL and JALR instructions, LUI and AUIPC instructions, and byte and halfword load/store operations.

The single-cycle CPU passed the tests used before the design was extended into the pipelined architecture.

## Pipeline Testing

After converting the CPU into a five-stage pipeline, additional testing was required because multiple instructions could now be active in the processor at the same time. The pipeline was tested for normal instruction execution as well as hazards and dependencies between instructions.

The pipeline verification included the following categories:

- Basic pipeline execution
- EX/MEM and MEM/WB forwarding
- Load-use hazard detection
- Pipeline stalls and bubbles
- WB-to-ID register bypassing
- Branch handling
- JAL and JALR control flow
- Wrong-path instruction flushing
- Mixed instruction stress testing
- Broad RV32I instruction regression
- False-stall corner cases

## Forwarding Verification

Forwarding tests were used to verify that dependent instructions could receive results from earlier instructions without unnecessarily waiting for the result to be written back to the register file.

Both EX/MEM and MEM/WB forwarding paths were tested. The tests also verified that EX/MEM forwarding had priority when both pipeline stages contained a matching destination register.

## Load-Use Hazard Verification

Load-use tests verified situations where an instruction immediately depended on data being loaded from memory by the previous instruction.

The tests confirmed that the program counter and IF/ID pipeline register were held while a bubble was inserted into the ID/EX stage. After the load result became available, execution continued normally.

Additional testing was also used to make sure the hazard detection unit did not create unnecessary stalls when instruction bits happened to match a destination register but the instruction did not actually use that field as a source register.

## Control Hazard Verification

Branches, JAL, and JALR instructions were tested to verify correct program counter redirection.

The tests confirmed that taken branches and jumps redirected the program counter to the correct target and that younger instructions from the incorrect path were flushed before they could update the architectural state.

## Mixed Stress and Regression Testing

A mixed stress test was used to combine several processor features in the same program, including arithmetic instructions, forwarding, memory operations, hazards, branches, and jumps.

A broader RV32I regression test was also created to test many supported instruction types together and verify register results, control flow, memory behavior, and hazard handling.

The final pipelined processor completed all of the verification tests used for the design with:

**81/81 pipeline checks passing**

These results gave confidence that the processor correctly handles normal instruction execution, data dependencies, load-use hazards, register bypassing, and control-flow changes across the five-stage pipeline.