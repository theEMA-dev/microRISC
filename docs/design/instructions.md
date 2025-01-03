# Instruction Formats

This document describes the instruction formats for the microRISC processor. All instructions are exactly 16 bits wide and are classified into three types: **R-Type**, **I-Type**, and **J-Type**. These formats are optimized for simplicity, ease of implementation and expandability.

---

## **1. R-Type Instructions**
R-Type instructions perform register-to-register operations such as arithmetic and logical operations.

### **Format**
```
| opcode (4) | rs or shamt (3) | rt (3) | rd (3) | funct (3) |
```
- **opcode (4 bits):** Specifies the instruction type (e.g., R-Type operations).
- **rs or shamt (3 bits):** First source register, can be used as *shamt* in sll and srl operations.
- **rt (3 bits):** Second source register.
- **rd (3 bits):** Destination register.
- **funct (3 bits):** Specifies the exact operation (e.g., `add`, `sub`).

### **Example Instructions**
1. **`add R1, R2, R3`**
   - **Fields:**
     - opcode = `0000`
     - rs = `001` (R2)
     - rt = `010` (R3)
     - rd = `011` (R1)
     - funct = `000` (add)
   - **Binary Encoding:**
     ```
     0000 001 010 011 000
     ```

2. **`sub R4, R5, R6`**
   - **Fields:**
     - opcode = `0000`
     - rs = `101` (R5)
     - rt = `110` (R6)
     - rd = `100` (R4)
     - funct = `001` (sub)
   - **Binary Encoding:**
     ```
     0000 101 110 100 001
     ```

---

## **2. I-Type Instructions**
I-Type instructions involve immediate values or memory operations. Examples include `addi`, `lw`, and `sw`.

### **Format**
```
| opcode (4) | rs (3) | rt (3) | immediate (6) |
```
- **opcode (4 bits):** Specifies the instruction type (e.g., immediate arithmetic or memory operation).
- **rs (3 bits):** Source register or base register for memory operations.
- **rt (3 bits):** Destination register (or target register for memory operations).
- **immediate (6 bits):** 6-bit signed immediate value or offset.

### **Example Instructions**
1. **`addi R2, R3, 5`**
   - **Fields:**
     - opcode = `0001`
     - rs = `011` (R3)
     - rt = `010` (R2)
     - immediate = `000101` (5)
   - **Binary Encoding:**
     ```
     0001 011 010 000101
     ```

2. **`lw R4, 8(R2)`**
   - **Fields:**
     - opcode = `0010`
     - rs = `010` (R2)
     - rt = `100` (R4)
     - immediate = `001000` (8)
   - **Binary Encoding:**
     ```
     0010 010 100 001000
     ```

3. **`beq R1, R3, -4`**
   - **Fields:**
     - opcode = `0100`
     - rs = `001` (R1)
     - rt = `011` (R3)
     - immediate = `111100` (-4, 2’s complement)
   - **Binary Encoding:**
     ```
     0100 001 011 111100
     ```

---

## **3. J-Type Instructions**
J-Type instructions are used for unconditional jumps, such as `j` and `jal`.

### **Format**
```
| opcode (4) | target address (12) |
```
- **opcode (4 bits):** Specifies the instruction type (e.g., jump).
- **target address (12 bits):** Specifies the word-aligned jump address (left-shifted by 1 or 2 in hardware).

### **Example Instructions**
1. **`j 0x040`**
   - **Fields:**
     - opcode = `1100`
     - target address = `000001000000`
   - **Binary Encoding:**
     ```
     1100 0000 0100 0000
     ```

2. **`jal 0x080`**
   - **Fields:**
     - opcode = `1101`
     - target address = `000010000000`
   - **Binary Encoding:**
     ```
     1101 0000 1000 0000
     ```

---

## **4. Opcode Mapping**
Below is the mapping of opcodes for the instruction set:

| Instruction | Type   | Opcode | Funct (if R-Type) |
|-------------|--------|--------|-------------------|
| `add`       | R-Type | 0000   | 000               |
| `sub`       | R-Type | 0000   | 001               |
| `and`       | R-Type | 0000   | 010               |
| `or`        | R-Type | 0000   | 011               |
| `slt`       | R-Type | 0000   | 100               |
| `sll`       | R-Type | 0000   | 101               |
| `srl`       | R-Type | 0000   | 110               |
| `addi`      | I-Type | 0001   | N/A               |
| `lw`        | I-Type | 0010   | N/A               |
| `sw`        | I-Type | 0011   | N/A               |
| `beq`       | I-Type | 0100   | N/A               |
| `bne`       | I-Type | 0101   | N/A               |
| `j`         | J-Type | 1100   | N/A               |
| `jal`       | J-Type | 1101   | N/A               |
| `jr`        | J-Type | 1110   | N/A               |


