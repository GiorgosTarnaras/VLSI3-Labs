`timescale 1ns/1ps

module tb_reg_file;

    reg clk;
    reg rst;
    reg wr_en;
    reg [1:0] w_addr, r_addr0, r_addr1;
    reg [15:0] w_data;
    wire [15:0] r_data0, r_data1;

    reg_file DUT (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .w_addr(w_addr),
        .r_addr0(r_addr0),
        .r_addr1(r_addr1),
        .w_data(w_data),
        .r_data0(r_data0),
        .r_data1(r_data1)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 1;
        rst = 1;
        wr_en = 0;
        w_addr = 0;
        r_addr0 = 0;
        r_addr1 = 0;
        w_data = 0;

        #20;
        rst = 0;

        wr_en = 1;
        w_addr = 2'b00; w_data = 16'hAAAA; #40;
        w_addr = 2'b01; w_data = 16'h5555; #40;
        w_addr = 2'b10; w_data = 16'h1234; #40;
        w_addr = 2'b11; w_data = 16'hFFFF; #40;
        r_addr0 = 2'b00; r_addr1 = 2'b11; #40;
        r_addr0 = 2'b01; r_addr1 = 2'b11; #40;

        #100;
        $stop;
    end


endmodule
