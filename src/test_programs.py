SAMPLE_PROGRAMS = {
    "fibonacci": """
        # Calculate first 10 Fibonacci numbers
        # Initialize
        addi R1, R0, 1    # F(1) = 1
        addi R2, R0, 1    # F(2) = 1
        addi R3, R0, 10   # Counter = 10
        addi R7, R0, 0    # Memory pointer
        
        # Store initial values
        sw R1, 0(R7)      # Store F(1)
        addi R7, R7, 1
        sw R2, 0(R7)      # Store F(2)
        addi R7, R7, 1
        
    loop:
        add R4, R1, R2    # F(n) = F(n-1) + F(n-2)
        sw R4, 0(R7)      # Store F(n)
        addi R7, R7, 1    # Increment pointer
        
        add R1, R2, R0    # F(n-2) = F(n-1)
        add R2, R4, R0    # F(n-1) = F(n)
        
        addi R3, R3, -1   # Decrement counter
        bne R3, R0, loop  # Continue if counter > 0
        
        # End program
        j end
    end:
        jr R0            # Return to start
    """,
    
    "sort": """
        # Initialize array with test values
        addi R1, R0, 5    # Array length
        addi R2, R0, 0    # Array base address
        
        # Store test values
        addi R3, R0, 9
        sw R3, 0(R2)
        addi R3, R0, 3
        sw R3, 1(R2)
        addi R3, R0, 7
        sw R3, 2(R2)
        addi R3, R0, 1
        sw R3, 3(R2)
        addi R3, R0, 5
        sw R3, 4(R2)
        
    outer_loop:
        addi R4, R0, 0    # i = 0
        
    inner_loop:
        add R5, R2, R4    # Current element address
        lw R6, 0(R5)      # Current element
        lw R7, 1(R5)      # Next element
        
        slt R3, R7, R6    # If next < current
        beq R3, R0, skip  # Skip if in order
        
        # Swap elements
        sw R7, 0(R5)
        sw R6, 1(R5)
        
    skip:
        addi R4, R4, 1    # i++
        addi R3, R1, -1   # length - 1
        bne R4, R3, inner_loop
        
        addi R1, R1, -1   # Decrease length
        addi R3, R0, 1    # Compare with 1
        bne R1, R3, outer_loop
        
        j end
    end:
        jr R0
    """
} 