`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: perceptron
//////////////////////////////////////////////////////////////////////////////////
//`define DEBUG
`include "include.v"
`include "config.vh"

module neuron #(parameter layerNo=0,neuronNo=0,numWeight=784,dataWidth=16,sigmoidSize=10,weightIntWidth=4,actType="relu",biasFile="",weightFile="")(
    input           clk,
    input           rst,
    input [dataWidth-1:0]    myinput,
    input           myinputValid,
    input           weightValid,
    input           biasValid,
    input [31:0]    weightValue,
    input [31:0]    biasValue,
    input [31:0]    config_layer_num,
    input [31:0]    config_neuron_num,
    output[dataWidth-1:0]    out,
    output reg      outvalid   
    );
    
    parameter addressWidth = $clog2(numWeight);
    
    reg         wen;
    wire        ren;
    reg [addressWidth-1:0] w_addr;
    reg [addressWidth:0]   r_addr;//read address has to reach until numWeight hence width is 1 bit more
    reg [dataWidth-1:0]  w_in;
    wire [dataWidth-1:0] w_out;
    reg [2*dataWidth-1:0]  mul; 
    reg [2*dataWidth-1:0]  sum;
    reg [2*dataWidth-1:0]  bias;
    reg [31:0]    biasReg[0:0];
    reg         weight_valid;
    reg         mult_valid;
    wire        mux_valid;
    reg         sigValid; 
    wire [2*dataWidth:0] comboAdd;
    wire [2*dataWidth:0] BiasAdd;
    reg  [dataWidth-1:0] myinputd;
    reg muxValid_d;
    reg muxValid_f;
    reg addr=0;
    
   
   //Loading weight values into the momory
    always @(posedge clk)
    begin
        if(rst)
        begin
            w_addr <= {addressWidth{1'b1}};
            wen <=0;
        end
        else if(weightValid & (config_layer_num==layerNo) & (config_neuron_num==neuronNo))
        begin
            w_in <= weightValue;
            w_addr <= w_addr + 1;
            wen <= 1;
        end
        else
            wen <= 0;
    end
	
    assign mux_valid = mult_valid;
    assign comboAdd = mul + sum;
    assign BiasAdd = bias + sum;
    assign ren = myinputValid;
    
	`ifdef pretrained
		initial
		begin
			case (layerNo)
				0: case (neuronNo) // Layer 0 with 30 neurons
						0: $readmemb(`BIAS_FILE_0_0, biasReg);
						1: $readmemb(`BIAS_FILE_0_1, biasReg);
						2: $readmemb(`BIAS_FILE_0_2, biasReg);
						3: $readmemb(`BIAS_FILE_0_3, biasReg);
						4: $readmemb(`BIAS_FILE_0_4, biasReg);
						5: $readmemb(`BIAS_FILE_0_5, biasReg);
						6: $readmemb(`BIAS_FILE_0_6, biasReg);
						7: $readmemb(`BIAS_FILE_0_7, biasReg);
						8: $readmemb(`BIAS_FILE_0_8, biasReg);
						9: $readmemb(`BIAS_FILE_0_9, biasReg);
						10: $readmemb(`BIAS_FILE_0_10, biasReg);
						11: $readmemb(`BIAS_FILE_0_11, biasReg);
						12: $readmemb(`BIAS_FILE_0_12, biasReg);
						13: $readmemb(`BIAS_FILE_0_13, biasReg);
						14: $readmemb(`BIAS_FILE_0_14, biasReg);
						15: $readmemb(`BIAS_FILE_0_15, biasReg);
						16: $readmemb(`BIAS_FILE_0_16, biasReg);
						17: $readmemb(`BIAS_FILE_0_17, biasReg);
						18: $readmemb(`BIAS_FILE_0_18, biasReg);
						19: $readmemb(`BIAS_FILE_0_19, biasReg);
						20: $readmemb(`BIAS_FILE_0_20, biasReg);
						21: $readmemb(`BIAS_FILE_0_21, biasReg);
						22: $readmemb(`BIAS_FILE_0_22, biasReg);
						23: $readmemb(`BIAS_FILE_0_23, biasReg);
						24: $readmemb(`BIAS_FILE_0_24, biasReg);
						25: $readmemb(`BIAS_FILE_0_25, biasReg);
						26: $readmemb(`BIAS_FILE_0_26, biasReg);
						27: $readmemb(`BIAS_FILE_0_27, biasReg);
						28: $readmemb(`BIAS_FILE_0_28, biasReg);
						29: $readmemb(`BIAS_FILE_0_29, biasReg);
				   endcase
				1: case (neuronNo) // Layer 1 with 30 neurons
						0: $readmemb(`BIAS_FILE_1_0, biasReg);
						1: $readmemb(`BIAS_FILE_1_1, biasReg);
						2: $readmemb(`BIAS_FILE_1_2, biasReg);
						3: $readmemb(`BIAS_FILE_1_3, biasReg);
						4: $readmemb(`BIAS_FILE_1_4, biasReg);
						5: $readmemb(`BIAS_FILE_1_5, biasReg);
						6: $readmemb(`BIAS_FILE_1_6, biasReg);
						7: $readmemb(`BIAS_FILE_1_7, biasReg);
						8: $readmemb(`BIAS_FILE_1_8, biasReg);
						9: $readmemb(`BIAS_FILE_1_9, biasReg);
						10: $readmemb(`BIAS_FILE_1_10, biasReg);
						11: $readmemb(`BIAS_FILE_1_11, biasReg);
						12: $readmemb(`BIAS_FILE_1_12, biasReg);
						13: $readmemb(`BIAS_FILE_1_13, biasReg);
						14: $readmemb(`BIAS_FILE_1_14, biasReg);
						15: $readmemb(`BIAS_FILE_1_15, biasReg);
						16: $readmemb(`BIAS_FILE_1_16, biasReg);
						17: $readmemb(`BIAS_FILE_1_17, biasReg);
						18: $readmemb(`BIAS_FILE_1_18, biasReg);
						19: $readmemb(`BIAS_FILE_1_19, biasReg);
						20: $readmemb(`BIAS_FILE_1_20, biasReg);
						21: $readmemb(`BIAS_FILE_1_21, biasReg);
						22: $readmemb(`BIAS_FILE_1_22, biasReg);
						23: $readmemb(`BIAS_FILE_1_23, biasReg);
						24: $readmemb(`BIAS_FILE_1_24, biasReg);
						25: $readmemb(`BIAS_FILE_1_25, biasReg);
						26: $readmemb(`BIAS_FILE_1_26, biasReg);
						27: $readmemb(`BIAS_FILE_1_27, biasReg);
						28: $readmemb(`BIAS_FILE_1_28, biasReg);
						29: $readmemb(`BIAS_FILE_1_29, biasReg);
				   endcase
				2: case (neuronNo) // Layer 2 with 10 neurons
						0: $readmemb(`BIAS_FILE_2_0, biasReg);
						1: $readmemb(`BIAS_FILE_2_1, biasReg);
						2: $readmemb(`BIAS_FILE_2_2, biasReg);
						3: $readmemb(`BIAS_FILE_2_3, biasReg);
						4: $readmemb(`BIAS_FILE_2_4, biasReg);
						5: $readmemb(`BIAS_FILE_2_5, biasReg);
						6: $readmemb(`BIAS_FILE_2_6, biasReg);
						7: $readmemb(`BIAS_FILE_2_7, biasReg);
						8: $readmemb(`BIAS_FILE_2_8, biasReg);
						9: $readmemb(`BIAS_FILE_2_9, biasReg);
				   endcase
				3: case (neuronNo) // Layer 3 with 1 neuron
						0: $readmemb(`BIAS_FILE_3_0, biasReg);
				   endcase
			endcase
		end
		always @(posedge clk)
		begin
            bias <= {biasReg[addr][dataWidth-1:0],{dataWidth{1'b0}}};
        end
	`else
		always @(posedge clk)
		begin
			if(biasValid & (config_layer_num==layerNo) & (config_neuron_num==neuronNo))
			begin
				bias <= {biasValue[dataWidth-1:0],{dataWidth{1'b0}}};
			end
		end
	`endif
    
    
    always @(posedge clk)
    begin
        if(rst|outvalid)
            r_addr <= 0;
        else if(myinputValid)
            r_addr <= r_addr + 1;
    end
    
    always @(posedge clk)
    begin
        mul  <= $signed(myinputd) * $signed(w_out);
    end
    
    
    always @(posedge clk)
    begin
        if(rst|outvalid)
            sum <= 0;
        else if((r_addr == numWeight) & muxValid_f)
        begin
            if(!bias[2*dataWidth-1] &!sum[2*dataWidth-1] & BiasAdd[2*dataWidth-1]) //If bias and sum are positive and after adding bias to sum, if sign bit becomes 1, saturate
            begin
                sum[2*dataWidth-1] <= 1'b0;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b1}};
            end
            else if(bias[2*dataWidth-1] & sum[2*dataWidth-1] &  !BiasAdd[2*dataWidth-1]) //If bias and sum are negative and after addition if sign bit is 0, saturate
            begin
                sum[2*dataWidth-1] <= 1'b1;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b0}};
            end
            else
                sum <= BiasAdd; 
        end
        else if(mux_valid)
        begin
            if(!mul[2*dataWidth-1] & !sum[2*dataWidth-1] & comboAdd[2*dataWidth-1])
            begin
                sum[2*dataWidth-1] <= 1'b0;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b1}};
            end
            else if(mul[2*dataWidth-1] & sum[2*dataWidth-1] & !comboAdd[2*dataWidth-1])
            begin
                sum[2*dataWidth-1] <= 1'b1;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b0}};
            end
            else
                sum <= comboAdd; 
        end
    end
    
    always @(posedge clk)
    begin
        myinputd <= myinput;
        weight_valid <= myinputValid;
        mult_valid <= weight_valid;
        sigValid <= ((r_addr == numWeight) & muxValid_f) ? 1'b1 : 1'b0;
        outvalid <= sigValid;
        muxValid_d <= mux_valid;
        muxValid_f <= !mux_valid & muxValid_d;
    end
    
    
    //Instantiation of Memory for Weights
    Weight_Memory #(.numWeight(numWeight),.neuronNo(neuronNo),.layerNo(layerNo),.addressWidth(addressWidth),.dataWidth(dataWidth),.weightFile(weightFile)) WM(
        .clk(clk),
        .wen(wen),
        .ren(ren),
        .wadd(w_addr),
        .radd(r_addr),
        .win(w_in),
        .wout(w_out)
    );
    
    generate
        if(actType == "sigmoid")
        begin:siginst
        //Instantiation of ROM for sigmoid
            Sig_ROM #(.inWidth(sigmoidSize),.dataWidth(dataWidth)) s1(
            .clk(clk),
            .x(sum[2*dataWidth-1-:sigmoidSize]),
            .out(out)
        );
        end
        else
        begin:ReLUinst
            ReLU #(.dataWidth(dataWidth),.weightIntWidth(weightIntWidth)) s1 (
            .clk(clk),
            .x(sum),
            .out(out)
        );
        end
    endgenerate

    `ifdef DEBUG
    always @(posedge clk)
    begin
        if(outvalid)
            $display(neuronNo,,,,"%b",out);
    end
    `endif
endmodule