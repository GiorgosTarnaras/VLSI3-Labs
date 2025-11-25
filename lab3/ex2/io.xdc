## ----------------------------------------------------------------------------
## CLOCK (125 MHz - PYNQ-Z2)
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN H16 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports clk]

## ----------------------------------------------------------------------------
## INPUTS: SWITCHES (Mapping d[0] and d[1] only)
## ----------------------------------------------------------------------------
## SW0 -> d[0]
set_property PACKAGE_PIN M20 [get_ports {d[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {d[0]}]

## SW1 -> d[1]
set_property PACKAGE_PIN M19 [get_ports {d[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {d[1]}]

## ----------------------------------------------------------------------------
## DUMMY INPUTS (Mapping d[2], d[3] to unused Arduino Header Pins)
## ----------------------------------------------------------------------------
## Because PYNQ only has 2 switches, we map the upper bits to unused pins (T14, U12).
## These will likely float low (0) or high, effectively acting as "don't care" for now.

## Arduino_0 -> d[2]
set_property PACKAGE_PIN T14 [get_ports {d[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {d[2]}]

## Arduino_1 -> d[3]
set_property PACKAGE_PIN U12 [get_ports {d[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {d[3]}]

## ----------------------------------------------------------------------------
## BUTTONS (Controls)
## ----------------------------------------------------------------------------
## BTN0 -> reset (Asynchronous Reset)
set_property PACKAGE_PIN D19 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

## BTN1 -> load
set_property PACKAGE_PIN D20 [get_ports load]
set_property IOSTANDARD LVCMOS33 [get_ports load]

## BTN2 -> en (Hold to Enable)
set_property PACKAGE_PIN L20 [get_ports en]
set_property IOSTANDARD LVCMOS33 [get_ports en]

## BTN3 -> up (Hold to Count Up)
set_property PACKAGE_PIN L19 [get_ports up]
set_property IOSTANDARD LVCMOS33 [get_ports up]

## Arduino_2 -> synch_clr (Mapped to unused pin U13 to avoid conflict with Reset)
set_property PACKAGE_PIN U13 [get_ports synch_clr]
set_property IOSTANDARD LVCMOS33 [get_ports synch_clr]


## ----------------------------------------------------------------------------
## OUTPUTS: Standard LEDs (Mapping Q[3:0])
## ----------------------------------------------------------------------------
## LED0 -> Q[0]
set_property PACKAGE_PIN R14 [get_ports {Q[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Q[0]}]

## LED1 -> Q[1]
set_property PACKAGE_PIN P14 [get_ports {Q[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Q[1]}]

## LED2 -> Q[2]
set_property PACKAGE_PIN N16 [get_ports {Q[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Q[2]}]

## LED3 -> Q[3]
set_property PACKAGE_PIN M14 [get_ports {Q[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Q[3]}]


## ----------------------------------------------------------------------------
## RGB LEDS (Flags max/min)
## ----------------------------------------------------------------------------
## Using the Green channel of the RGB LEDs for status

## RGB LED 4 (Green) -> max (Counter is at 1111)
set_property PACKAGE_PIN G17 [get_ports max]
set_property IOSTANDARD LVCMOS33 [get_ports max]

## RGB LED 5 (Green) -> min (Counter is at 0000)
set_property PACKAGE_PIN L14 [get_ports min]
set_property IOSTANDARD LVCMOS33 [get_ports min]
