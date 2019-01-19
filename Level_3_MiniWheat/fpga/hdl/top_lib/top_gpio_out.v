/*
*****************************
* MODULE : top_gpio_out
*
* This module is to test a RPi driving
* input and displaying those input on 
* LEDs.
*
* Author : Brandon Bloodget
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

module top_gpio_out
(
    input wire [3:0] rpi_in,
    output wire [3:0] led_out
);

assign led_out[3:0] = rpi_in[3:0];

endmodule

