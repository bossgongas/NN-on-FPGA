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
	        $readmemb(weightFile, mem); // ler para o buffer
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