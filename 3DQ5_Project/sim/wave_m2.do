onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 20 {Top-level signals}
add wave -noupdate -radix binary /TB/UUT/CLOCK_50_I
add wave -noupdate -radix binary /TB/UUT/resetn
add wave -noupdate /TB/UUT/top_state
add wave -noupdate -radix unsigned /TB/UUT/UART_timer
add wave -noupdate -divider -height 10 {SRAM signals}
add wave -noupdate -radix unsigned /TB/UUT/SRAM_address
add wave -noupdate -radix hexadecimal /TB/UUT/SRAM_write_data
add wave -noupdate -radix binary /TB/UUT/SRAM_we_n
add wave -noupdate -radix hexadecimal /TB/UUT/SRAM_read_data
add wave -noupdate -divider -height 10 {VGA signals}
add wave -noupdate -radix binary /TB/UUT/VGA_unit/VGA_HSYNC_O
add wave -noupdate -radix binary /TB/UUT/VGA_unit/VGA_VSYNC_O
add wave -noupdate -radix unsigned /TB/UUT/VGA_unit/pixel_X_pos
add wave -noupdate -radix unsigned /TB/UUT/VGA_unit/pixel_Y_pos
add wave -noupdate -radix hexadecimal /TB/UUT/VGA_unit/VGA_red
add wave -noupdate -radix hexadecimal /TB/UUT/VGA_unit/VGA_green
add wave -noupdate -radix hexadecimal /TB/UUT/VGA_unit/VGA_blue
add wave -noupdate /TB/UUT/M2_unit/M2_done
add wave -noupdate /TB/UUT/M2_unit/M2_state
add wave -noupdate /TB/UUT/M2_unit/SRAM_we_n
add wave -position insertpoint /TB/UUT/*

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3150899200 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {3150782700 ps} {3150974900 ps}
