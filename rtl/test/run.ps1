# Clean previous outputs
Remove-Item -ErrorAction SilentlyContinue test_out
Remove-Item -ErrorAction SilentlyContinue processor.vcd

# Compile design
iverilog -g2012 `
    -I../pipeline `
    -I../core `
    -I../memory `
    -I../pipeline/pipeline_registers `
    -I../ `
    -o test_out `
    processor_tb.v `
    ../top/processor_top.v `
    ../pipeline/*.v `
    ../pipeline/pipeline_registers/*.v `
    ../core/*.v `
    ../memory/*.v

if ($LASTEXITCODE -eq 0) {
    # Run simulation
    vvp test_out
    
    # Open waveform (if GTKWave is installed)
    gtkwave processor.vcd
} else {
    Write-Host "Compilation failed!"
}