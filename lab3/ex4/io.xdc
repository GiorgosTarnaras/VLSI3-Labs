## ============================================================================
## io.xdc - Constraints file for Switch Debouncer (Final Optimization)
## Target Device: XC7Z020clg400-1 (PYNQ-Z2 Board)
## ============================================================================

## ----------------------------------------------------------------------------
## CLOCK (125 MHz - PYNQ-Z2)
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN H16 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports clk]

## ----------------------------------------------------------------------------
## RESET BUTTON (BTN0)
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN D19 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

## ----------------------------------------------------------------------------
## SWITCH INPUT (SW0)
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN M20 [get_ports sw]
set_property IOSTANDARD LVCMOS33 [get_ports sw]

## ----------------------------------------------------------------------------
## LED OUTPUT (LED0)
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN R14 [get_ports deb_sw]
set_property IOSTANDARD LVCMOS33 [get_ports deb_sw]

## ----------------------------------------------------------------------------
## TIMING EXCEPTIONS (False Paths)
## ----------------------------------------------------------------------------

## 1. Asynchronous Reset (Input)
## Reset button -> System registers: No timing requirement.
set_false_path -from [get_ports reset] -to [all_registers]

## 2. Switch Input Synchronizer (Input)
## Switch -> First stage of synchronizer: No timing requirement.
## Using 'get_cells' with a filter is the robust way to find the register.
set_false_path -from [get_ports sw] -to [get_cells -hierarchical -filter {NAME =~ *sw_sync_reg[0]*}]

## 3. LED Output (Output) - ADDED
## Register -> LED: Humans can't see nanosecond differences.
## We remove the 'set_output_delay' and replace it with false_path.
set_false_path -from [all_registers] -to [get_ports deb_sw]

## ----------------------------------------------------------------------------
## I/O DELAYS
## ----------------------------------------------------------------------------
## Since we have declared false paths for all I/O above, 
## explicit input/output delay constraints are no longer strictly necessary 
## for timing analysis, but you can keep them for documentation if you wish.
## (I have removed them here to keep the file clean and avoid conflicts).
