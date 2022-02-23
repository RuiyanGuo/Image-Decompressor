onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 20 {Top-level signals}
add wave -noupdate -radix binary /TB/UUT/CLOCK_50_I
add wave -noupdate -radix binary /TB/UUT/resetn
add wave -noupdate /TB/UUT/top_state
add wave -noupdate -radix unsigned /TB/UUT/UART_timer
add wave -noupdate -divider -height 10 {SRAM signals}
add wave -noupdate -radix unsigned /TB/UUT/SRAM_address
add wave -noupdate -radix decimal/TB/UUT/SRAM_write_data
add wave -noupdate -radix binary /TB/UUT/SRAM_we_n
add wave -noupdate -radix decimal /TB/UUT/SRAM_read_data
add wave -noupdate -divider -height 10 {VGA signals}
add wave -noupdate -radix binary /TB/UUT/VGA_unit/VGA_HSYNC_O
add wave -noupdate -radix binary /TB/UUT/VGA_unit/VGA_VSYNC_O
add wave -noupdate -radix unsigned /TB/UUT/VGA_unit/pixel_X_pos
add wave -noupdate -radix unsigned /TB/UUT/VGA_unit/pixel_Y_pos
add wave -noupdate -radix hexadecimal /TB/UUT/VGA_unit/VGA_red
add wave -noupdate -radix hexadecimal /TB/UUT/VGA_unit/VGA_green
add wave -noupdate -radix hexadecimal /TB/UUT/VGA_unit/VGA_blue
add wave -noupdate /TB/UUT/CLOCK_50_I
add wave -noupdate /TB/UUT/PUSH_BUTTON_N_I
add wave -noupdate /TB/UUT/SWITCH_I
add wave -noupdate /TB/UUT/LED_GREEN_O
add wave -noupdate /TB/UUT/VGA_CLOCK_O
add wave -noupdate /TB/UUT/VGA_HSYNC_O
add wave -noupdate /TB/UUT/VGA_VSYNC_O
add wave -noupdate /TB/UUT/VGA_BLANK_O
add wave -noupdate /TB/UUT/VGA_SYNC_O
add wave -noupdate /TB/UUT/VGA_RED_O
add wave -noupdate /TB/UUT/VGA_GREEN_O
add wave -noupdate /TB/UUT/VGA_BLUE_O
add wave -noupdate /TB/UUT/SRAM_DATA_IO
add wave -noupdate /TB/UUT/SRAM_ADDRESS_O
add wave -noupdate /TB/UUT/SRAM_UB_N_O
add wave -noupdate /TB/UUT/SRAM_LB_N_O
add wave -noupdate /TB/UUT/SRAM_WE_N_O
add wave -noupdate /TB/UUT/SRAM_CE_N_O
add wave -noupdate /TB/UUT/SRAM_OE_N_O
add wave -noupdate /TB/UUT/UART_RX_I
add wave -noupdate /TB/UUT/UART_TX_O
add wave -noupdate /TB/UUT/resetn
add wave -noupdate /TB/UUT/top_state
add wave -noupdate /TB/UUT/PB_pushed
add wave -noupdate /TB/UUT/VGA_enable
add wave -noupdate /TB/UUT/VGA_base_address
add wave -noupdate /TB/UUT/VGA_SRAM_address
add wave -noupdate /TB/UUT/SRAM_address
add wave -noupdate /TB/UUT/SRAM_write_data
add wave -noupdate /TB/UUT/SRAM_we_n
add wave -noupdate /TB/UUT/SRAM_read_data
add wave -noupdate /TB/UUT/SRAM_ready
add wave -noupdate /TB/UUT/UART_rx_enable
add wave -noupdate /TB/UUT/UART_rx_initialize
add wave -noupdate /TB/UUT/UART_SRAM_address
add wave -noupdate /TB/UUT/UART_SRAM_write_data
add wave -noupdate /TB/UUT/UART_SRAM_we_n
add wave -noupdate /TB/UUT/UART_timer
add wave -noupdate /TB/UUT/Frame_error
add wave -noupdate /TB/UUT/M1_start
add wave -noupdate /TB/UUT/M1_done
add wave -noupdate /TB/UUT/M1_we_n
add wave -noupdate /TB/UUT/M1_write_data
add wave -noupdate /TB/UUT/M1_address
add wave -noupdate /TB/UUT/M1_unit/M1_state
add wave -position insertpoint /TB/UUT/*
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {551815000 ps} 0}
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
WaveRestoreZoom {551702700 ps} {551953700 ps}
