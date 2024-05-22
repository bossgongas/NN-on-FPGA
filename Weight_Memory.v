`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: Weight_Memory
//////////////////////////////////////////////////////////////////////////////////
`include "include.v"

module Weight_Memory #(parameter numWeight = 3, neuronNo=5,layerNo=1,addressWidth=10,dataWidth=16,weightFile="w_1_15.mif") 
    ( 
    input clk,
    input wen,
    input ren,
    input [addressWidth-1:0] wadd,
    input [addressWidth-1:0] radd,
    input [dataWidth-1:0] win,
    output reg [dataWidth-1:0] wout);
    
    reg [dataWidth-1:0] mem [numWeight-1:0]; //inicialização do buffer

    // no nosso caso a rede será sempre pre treinada - entao vamos ler de file para mem. - Funciona como uma ROM
    `ifdef pretrained
        initial
		begin
	        case (layerNo)
				0: case (neuronNo) // Layer 0 with 30 neurons
						0: $readmemb(`WEIGHT_FILE_0_0, mem);
						1: $readmemb(`WEIGHT_FILE_0_1, mem);
						2: $readmemb(`WEIGHT_FILE_0_2, mem);
						3: $readmemb(`WEIGHT_FILE_0_3, mem);
						4: $readmemb(`WEIGHT_FILE_0_4, mem);
						5: $readmemb(`WEIGHT_FILE_0_5, mem);
						6: $readmemb(`WEIGHT_FILE_0_6, mem);
						7: $readmemb(`WEIGHT_FILE_0_7, mem);
						8: $readmemb(`WEIGHT_FILE_0_8, mem);
						9: $readmemb(`WEIGHT_FILE_0_9, mem);
						10: $readmemb(`WEIGHT_FILE_0_10, mem);
						11: $readmemb(`WEIGHT_FILE_0_11, mem);
						12: $readmemb(`WEIGHT_FILE_0_12, mem);
						13: $readmemb(`WEIGHT_FILE_0_13, mem);
						14: $readmemb(`WEIGHT_FILE_0_14, mem);
						15: $readmemb(`WEIGHT_FILE_0_15, mem);
						16: $readmemb(`WEIGHT_FILE_0_16, mem);
						17: $readmemb(`WEIGHT_FILE_0_17, mem);
						18: $readmemb(`WEIGHT_FILE_0_18, mem);
						19: $readmemb(`WEIGHT_FILE_0_19, mem);
						20: $readmemb(`WEIGHT_FILE_0_20, mem);
						21: $readmemb(`WEIGHT_FILE_0_21, mem);
						22: $readmemb(`WEIGHT_FILE_0_22, mem);
						23: $readmemb(`WEIGHT_FILE_0_23, mem);
						24: $readmemb(`WEIGHT_FILE_0_24, mem);
						25: $readmemb(`WEIGHT_FILE_0_25, mem);
						26: $readmemb(`WEIGHT_FILE_0_26, mem);
						27: $readmemb(`WEIGHT_FILE_0_27, mem);
						28: $readmemb(`WEIGHT_FILE_0_28, mem);
						29: $readmemb(`WEIGHT_FILE_0_29, mem);
				   endcase
				1: case (neuronNo) // Layer 1 with 30 neurons
						0: $readmemb(`WEIGHT_FILE_1_0, mem);
						1: $readmemb(`WEIGHT_FILE_1_1, mem);
						2: $readmemb(`WEIGHT_FILE_1_2, mem);
						3: $readmemb(`WEIGHT_FILE_1_3, mem);
						4: $readmemb(`WEIGHT_FILE_1_4, mem);
						5: $readmemb(`WEIGHT_FILE_1_5, mem);
						6: $readmemb(`WEIGHT_FILE_1_6, mem);
						7: $readmemb(`WEIGHT_FILE_1_7, mem);
						8: $readmemb(`WEIGHT_FILE_1_8, mem);
						9: $readmemb(`WEIGHT_FILE_1_9, mem);
						10: $readmemb(`WEIGHT_FILE_1_10, mem);
						11: $readmemb(`WEIGHT_FILE_1_11, mem);
						12: $readmemb(`WEIGHT_FILE_1_12, mem);
						13: $readmemb(`WEIGHT_FILE_1_13, mem);
						14: $readmemb(`WEIGHT_FILE_1_14, mem);
						15: $readmemb(`WEIGHT_FILE_1_15, mem);
						16: $readmemb(`WEIGHT_FILE_1_16, mem);
						17: $readmemb(`WEIGHT_FILE_1_17, mem);
						18: $readmemb(`WEIGHT_FILE_1_18, mem);
						19: $readmemb(`WEIGHT_FILE_1_19, mem);
						20: $readmemb(`WEIGHT_FILE_1_20, mem);
						21: $readmemb(`WEIGHT_FILE_1_21, mem);
						22: $readmemb(`WEIGHT_FILE_1_22, mem);
						23: $readmemb(`WEIGHT_FILE_1_23, mem);
						24: $readmemb(`WEIGHT_FILE_1_24, mem);
						25: $readmemb(`WEIGHT_FILE_1_25, mem);
						26: $readmemb(`WEIGHT_FILE_1_26, mem);
						27: $readmemb(`WEIGHT_FILE_1_27, mem);
						28: $readmemb(`WEIGHT_FILE_1_28, mem);
						29: $readmemb(`WEIGHT_FILE_1_29, mem);
				   endcase
				2: case (neuronNo) // Layer 2 with 10 neurons
						0: $readmemb(`WEIGHT_FILE_2_0, mem);
						1: $readmemb(`WEIGHT_FILE_2_1, mem);
						2: $readmemb(`WEIGHT_FILE_2_2, mem);
						3: $readmemb(`WEIGHT_FILE_2_3, mem);
						4: $readmemb(`WEIGHT_FILE_2_4, mem);
						5: $readmemb(`WEIGHT_FILE_2_5, mem);
						6: $readmemb(`WEIGHT_FILE_2_6, mem);
						7: $readmemb(`WEIGHT_FILE_2_7, mem);
						8: $readmemb(`WEIGHT_FILE_2_8, mem);
						9: $readmemb(`WEIGHT_FILE_2_9, mem);
				   endcase
				3: case (neuronNo) // Layer 3 with 1 neuron
						0: $readmemb(`WEIGHT_FILE_3_0, mem);
				   endcase
			endcase
	    end
    // c
	`else
		always @(posedge clk)
		begin
			if (wen)
			begin
				mem[wadd] <= win;
			end
		end 
    `endif

    // colocar do buffer para a saida
    always @(posedge clk)
    begin
        if (ren)
        begin
            wout <= mem[radd];
        end
    end 
endmodule