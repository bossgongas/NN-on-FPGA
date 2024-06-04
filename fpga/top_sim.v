`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////// 
// Module Name: top_sim
//////////////////////////////////////////////////////////////////////////////////

//Nota: interface AXI - *Master* top_sim.v - *Slave* zynet.v
`include "include.v"
`include "config.vh"

`define MaxTestSamples 100

module top_sim(

    );
    
    reg reset; //reinicia a zynet
    reg clock; //sincronia de operaçoes na zynet

    reg [`dataWidth-1:0] in; //sinal/reg dados de input da zynet
    reg in_valid; // indica quando dados 'in' estão prontos para entrar na rede
    reg [`dataWidth-1:0] in_mem [784:0]; // mem temporaria para armazenar os dados que serão enviados a rede
    reg [7:0] fileName[23:0]; // nome do ficheiro de onde se le dados de entrada, pesos e bias
    
    reg s_axi_awvalid;       // Master: Indica que o endereço de escrita é válido
    reg [31:0] s_axi_awaddr; // Master: Contém o endereço de escrita
    wire s_axi_awready;      // Slave: Indica que o escravo está pronto para receber o endereço de escrita
    reg [31:0] s_axi_wdata;  // Master: Contém os dados de escrita
    reg s_axi_wvalid;        // Master: Indica que os dados de escrita são válidos
    wire s_axi_wready;       // Slave: Indica que o escravo está pronto para receber os dados de escrita
    wire s_axi_bvalid;       // Slave: Indica que a resposta de escrita é válida
    reg s_axi_bready;        // Master: Indica que o mestre está pronto para receber a resposta de escrita

    wire intr;               // Slave: Indica quando a classificação está completa

    reg [31:0] axiRdData;    // Master: Armazena os dados lidos da interface AXI
    reg [31:0] s_axi_araddr; // Master: Contém o endereço de leitura
    wire [31:0] s_axi_rdata; // Slave: Contém os dados lidos
    reg s_axi_arvalid;       // Master: Indica que o endereço de leitura é válido
    wire s_axi_arready;      // Slave: Indica que o escravo está pronto para receber o endereço de leitura
    wire s_axi_rvalid;       // Slave: Indica que os dados de leitura são válidos
    reg s_axi_rready;        // Master: Indica que o mestre está pronto para receber os dados de leitura

    reg [`dataWidth-1:0] expected; //armazena o valor verdadeiro da classificação para verificação

    wire [31:0] numNeurons[31:1]; //neurons em cada camada
    wire [31:0] numWeights[31:1]; //numero de pesos em cada camada
    assign numNeurons[1] = 30;
    assign numNeurons[2] = 30;
    assign numNeurons[3] = 10;
    assign numNeurons[4] = 1;
    assign numWeights[1] = 784;
    assign numWeights[2] = 30;
    assign numWeights[3] = 30;
    assign numWeights[4] = 1;
    
    integer right=0; // numero de classificaçoes corretas
    integer wrong=0; // "" incorretas
    
    zyNet dut(
    .s_axi_aclk(clock),
    .s_axi_aresetn(reset),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awprot(0),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(4'hF),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),
    .s_axi_bresp(),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arprot(0),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arready(s_axi_arready),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rready(s_axi_rready),
    .axis_in_data(in),
    .axis_in_data_valid(in_valid),
    .axis_in_data_ready(),
    .intr(intr)
    );
    
    // bloco inicial configura os sinais iniciais e define a lógica de clock 
    initial
    begin
        clock = 1'b0;
        s_axi_awvalid = 1'b0;
        s_axi_bready = 1'b0;
        s_axi_wvalid = 1'b0;
        s_axi_arvalid = 1'b0;
    end
    
    //bloco always é usado para alternar o sinal do clock a cada 5 unidades de tempo.
    always
        #5 clock = ~clock;
    
    // Funçao que converte um inteiro para seu valor ASCII correspondente
    function [7:0] to_ascii;
      input integer a;
      begin
        to_ascii = a+48;
      end
    endfunction
    
    // bloco sensivel a borda ascendente do clk
    // garante que o mestre está sempre preparado para receber dados ou respostas, 
    // desde que o escravo os forneça.
    always @(posedge clock)
    begin
        //o mestre(top_sim.v) está pronto para receber a resposta sempre que a resposta for válida.
        s_axi_bready <= s_axi_bvalid; 
        //o mestre está pronto para receber os dados sempre que os dados estiverem válidos.
        s_axi_rready <= s_axi_rvalid;
    end
    
    //Escrita (do Mestre) na interface AXI
    task writeAxi(
    input [31:0] address,
    input [31:0] data
    );
    begin
        @(posedge clock);
        s_axi_awvalid <= 1'b1;
        s_axi_awaddr <= address;
        s_axi_wdata <= data;
        s_axi_wvalid <= 1'b1;
        wait(s_axi_wready);
        @(posedge clock);
        s_axi_awvalid <= 1'b0;
        s_axi_wvalid <= 1'b0;
        @(posedge clock);
    end
    endtask
    
    //Leitura (Mestre) da interface AXI
    task readAxi(
    input [31:0] address
    );
    begin
        @(posedge clock);
        s_axi_arvalid <= 1'b1;
        s_axi_araddr <= address;
        wait(s_axi_arready);
        @(posedge clock);
        s_axi_arvalid <= 1'b0;
        wait(s_axi_rvalid);
        @(posedge clock);
        axiRdData <= s_axi_rdata;
        @(posedge clock);
    end
    endtask
    
    //Configura os pesos dos neurônios lendo de arquivos.
    task configWeights();
    integer k, j, t;
    reg [`dataWidth:0] config_mem [783:0];
    begin
        @(posedge clock);
        for (k = 0; k < `numLayers; k = k + 1) begin
            writeAxi(12, k); // Write layer number
            for (j = 0; j < numNeurons[k]; j = j + 1) begin
                writeAxi(16, j); // Write neuron number
                case (k)
                    0: case (j)
                        0: $readmemb(`WEIGHTS_FILE_0_0, config_mem);
                        1: $readmemb(`WEIGHTS_FILE_0_1, config_mem);
                        2: $readmemb(`WEIGHTS_FILE_0_2, config_mem);
                        3: $readmemb(`WEIGHTS_FILE_0_3, config_mem);
                        4: $readmemb(`WEIGHTS_FILE_0_4, config_mem);
                        5: $readmemb(`WEIGHTS_FILE_0_5, config_mem);
                        6: $readmemb(`WEIGHTS_FILE_0_6, config_mem);
                        7: $readmemb(`WEIGHTS_FILE_0_7, config_mem);
                        8: $readmemb(`WEIGHTS_FILE_0_8, config_mem);
                        9: $readmemb(`WEIGHTS_FILE_0_9, config_mem);
                        10: $readmemb(`WEIGHTS_FILE_0_10, config_mem);
                        11: $readmemb(`WEIGHTS_FILE_0_11, config_mem);
                        12: $readmemb(`WEIGHTS_FILE_0_12, config_mem);
                        13: $readmemb(`WEIGHTS_FILE_0_13, config_mem);
                        14: $readmemb(`WEIGHTS_FILE_0_14, config_mem);
                        15: $readmemb(`WEIGHTS_FILE_0_15, config_mem);
                        16: $readmemb(`WEIGHTS_FILE_0_16, config_mem);
                        17: $readmemb(`WEIGHTS_FILE_0_17, config_mem);
                        18: $readmemb(`WEIGHTS_FILE_0_18, config_mem);
                        19: $readmemb(`WEIGHTS_FILE_0_19, config_mem);
                        20: $readmemb(`WEIGHTS_FILE_0_20, config_mem);
                        21: $readmemb(`WEIGHTS_FILE_0_21, config_mem);
                        22: $readmemb(`WEIGHTS_FILE_0_22, config_mem);
                        23: $readmemb(`WEIGHTS_FILE_0_23, config_mem);
                        24: $readmemb(`WEIGHTS_FILE_0_24, config_mem);
                        25: $readmemb(`WEIGHTS_FILE_0_25, config_mem);
                        26: $readmemb(`WEIGHTS_FILE_0_26, config_mem);
                        27: $readmemb(`WEIGHTS_FILE_0_27, config_mem);
                        28: $readmemb(`WEIGHTS_FILE_0_28, config_mem);
                        29: $readmemb(`WEIGHTS_FILE_0_29, config_mem);
                        endcase
                    1: case (j)
                        0: $readmemb(`WEIGHTS_FILE_1_0, config_mem);
                        1: $readmemb(`WEIGHTS_FILE_1_1, config_mem);
                        2: $readmemb(`WEIGHTS_FILE_1_2, config_mem);
                        3: $readmemb(`WEIGHTS_FILE_1_3, config_mem);
                        4: $readmemb(`WEIGHTS_FILE_1_4, config_mem);
                        5: $readmemb(`WEIGHTS_FILE_1_5, config_mem);
                        6: $readmemb(`WEIGHTS_FILE_1_6, config_mem);
                        7: $readmemb(`WEIGHTS_FILE_1_7, config_mem);
                        8: $readmemb(`WEIGHTS_FILE_1_8, config_mem);
                        9: $readmemb(`WEIGHTS_FILE_1_9, config_mem);
                        10: $readmemb(`WEIGHTS_FILE_1_10, config_mem);
                        11: $readmemb(`WEIGHTS_FILE_1_11, config_mem);
                        12: $readmemb(`WEIGHTS_FILE_1_12, config_mem);
                        13: $readmemb(`WEIGHTS_FILE_1_13, config_mem);
                        14: $readmemb(`WEIGHTS_FILE_1_14, config_mem);
                        15: $readmemb(`WEIGHTS_FILE_1_15, config_mem);
                        16: $readmemb(`WEIGHTS_FILE_1_16, config_mem);
                        17: $readmemb(`WEIGHTS_FILE_1_17, config_mem);
                        18: $readmemb(`WEIGHTS_FILE_1_18, config_mem);
                        19: $readmemb(`WEIGHTS_FILE_1_19, config_mem);
                        20: $readmemb(`WEIGHTS_FILE_1_20, config_mem);
                        21: $readmemb(`WEIGHTS_FILE_1_21, config_mem);
                        22: $readmemb(`WEIGHTS_FILE_1_22, config_mem);
                        23: $readmemb(`WEIGHTS_FILE_1_23, config_mem);
                        24: $readmemb(`WEIGHTS_FILE_1_24, config_mem);
                        25: $readmemb(`WEIGHTS_FILE_1_25, config_mem);
                        26: $readmemb(`WEIGHTS_FILE_1_26, config_mem);
                        27: $readmemb(`WEIGHTS_FILE_1_27, config_mem);
                        28: $readmemb(`WEIGHTS_FILE_1_28, config_mem);
                        29: $readmemb(`WEIGHTS_FILE_1_29, config_mem);
                        endcase
                    2: case (j)
                        0: $readmemb(`WEIGHTS_FILE_2_0, config_mem);
                        1: $readmemb(`WEIGHTS_FILE_2_1, config_mem);
                        2: $readmemb(`WEIGHTS_FILE_2_2, config_mem);
                        3: $readmemb(`WEIGHTS_FILE_2_3, config_mem);
                        4: $readmemb(`WEIGHTS_FILE_2_4, config_mem);
                        5: $readmemb(`WEIGHTS_FILE_2_5, config_mem);
                        6: $readmemb(`WEIGHTS_FILE_2_6, config_mem);
                        7: $readmemb(`WEIGHTS_FILE_2_7, config_mem);
                        8: $readmemb(`WEIGHTS_FILE_2_8, config_mem);
                        9: $readmemb(`WEIGHTS_FILE_2_9, config_mem);
                        endcase
                    3: case (j)
                        0: $readmemb(`WEIGHTS_FILE_3_0, config_mem);
                        endcase
                endcase
                for (t = 0; t < numWeights[k]; t = t + 1) begin
                    writeAxi(0, {15'd0, config_mem[t]});
                end
            end
        end
    end
endtask

    
    // Configura os bias dos neurônios lendo de arquivos.
   task configBias();
    integer k, j;
    reg [31:0] bias[0:0];
    begin
        @(posedge clock);
        for (k = 0; k < `numLayers; k = k + 1) begin
            writeAxi(12, k); // Write layer number
            for (j = 0; j < numNeurons[k]; j = j + 1) begin
                writeAxi(16, j); // Write neuron number
                case (k)
                    0: case (j)
                        0: $readmemb(`BIAS_FILE_0_0, bias);
                        1: $readmemb(`BIAS_FILE_0_1, bias);
                        2: $readmemb(`BIAS_FILE_0_2, bias);
                        3: $readmemb(`BIAS_FILE_0_3, bias);
                        4: $readmemb(`BIAS_FILE_0_4, bias);
                        5: $readmemb(`BIAS_FILE_0_5, bias);
                        6: $readmemb(`BIAS_FILE_0_6, bias);
                        7: $readmemb(`BIAS_FILE_0_7, bias);
                        8: $readmemb(`BIAS_FILE_0_8, bias);
                        9: $readmemb(`BIAS_FILE_0_9, bias);
                        10: $readmemb(`BIAS_FILE_0_10, bias);
                        11: $readmemb(`BIAS_FILE_0_11, bias);
                        12: $readmemb(`BIAS_FILE_0_12, bias);
                        13: $readmemb(`BIAS_FILE_0_13, bias);
                        14: $readmemb(`BIAS_FILE_0_14, bias);
                        15: $readmemb(`BIAS_FILE_0_15, bias);
                        16: $readmemb(`BIAS_FILE_0_16, bias);
                        17: $readmemb(`BIAS_FILE_0_17, bias);
                        18: $readmemb(`BIAS_FILE_0_18, bias);
                        19: $readmemb(`BIAS_FILE_0_19, bias);
                        20: $readmemb(`BIAS_FILE_0_20, bias);
                        21: $readmemb(`BIAS_FILE_0_21, bias);
                        22: $readmemb(`BIAS_FILE_0_22, bias);
                        23: $readmemb(`BIAS_FILE_0_23, bias);
                        24: $readmemb(`BIAS_FILE_0_24, bias);
                        25: $readmemb(`BIAS_FILE_0_25, bias);
                        26: $readmemb(`BIAS_FILE_0_26, bias);
                        27: $readmemb(`BIAS_FILE_0_27, bias);
                        28: $readmemb(`BIAS_FILE_0_28, bias);
                        29: $readmemb(`BIAS_FILE_0_29, bias);
                        endcase
                    1: case (j)
                        0: $readmemb(`BIAS_FILE_1_0, bias);
                        1: $readmemb(`BIAS_FILE_1_1, bias);
                        2: $readmemb(`BIAS_FILE_1_2, bias);
                        3: $readmemb(`BIAS_FILE_1_3, bias);
                        4: $readmemb(`BIAS_FILE_1_4, bias);
                        5: $readmemb(`BIAS_FILE_1_5, bias);
                        6: $readmemb(`BIAS_FILE_1_6, bias);
                        7: $readmemb(`BIAS_FILE_1_7, bias);
                        8: $readmemb(`BIAS_FILE_1_8, bias);
                        9: $readmemb(`BIAS_FILE_1_9, bias);
                        10: $readmemb(`BIAS_FILE_1_10, bias);
                        11: $readmemb(`BIAS_FILE_1_11, bias);
                        12: $readmemb(`BIAS_FILE_1_12, bias);
                        13: $readmemb(`BIAS_FILE_1_13, bias);
                        14: $readmemb(`BIAS_FILE_1_14, bias);
                        15: $readmemb(`BIAS_FILE_1_15, bias);
                        16: $readmemb(`BIAS_FILE_1_16, bias);
                        17: $readmemb(`BIAS_FILE_1_17, bias);
                        18: $readmemb(`BIAS_FILE_1_18, bias);
                        19: $readmemb(`BIAS_FILE_1_19, bias);
                        20: $readmemb(`BIAS_FILE_1_20, bias);
                        21: $readmemb(`BIAS_FILE_1_21, bias);
                        22: $readmemb(`BIAS_FILE_1_22, bias);
                        23: $readmemb(`BIAS_FILE_1_23, bias);
                        24: $readmemb(`BIAS_FILE_1_24, bias);
                        25: $readmemb(`BIAS_FILE_1_25, bias);
                        26: $readmemb(`BIAS_FILE_1_26, bias);
                        27: $readmemb(`BIAS_FILE_1_27, bias);
                        28: $readmemb(`BIAS_FILE_1_28, bias);
                        29: $readmemb(`BIAS_FILE_1_29, bias);
                        endcase
                    2: case (j)
                        0: $readmemb(`BIAS_FILE_2_0, bias);
                        1: $readmemb(`BIAS_FILE_2_1, bias);
                        2: $readmemb(`BIAS_FILE_2_2, bias);
                        3: $readmemb(`BIAS_FILE_2_3, bias);
                        4: $readmemb(`BIAS_FILE_2_4, bias);
                        5: $readmemb(`BIAS_FILE_2_5, bias);
                        6: $readmemb(`BIAS_FILE_2_6, bias);
                        7: $readmemb(`BIAS_FILE_2_7, bias);
                        8: $readmemb(`BIAS_FILE_2_8, bias);
                        9: $readmemb(`BIAS_FILE_2_9, bias);
                        endcase
                    3: case (j)
                        0: $readmemb(`BIAS_FILE_3_0, bias);
                        endcase
                endcase
                writeAxi(4, {15'd0, bias[0]});
            end
        end
    end
endtask

    
    // Envia dados de entrada para o módulo zyNet.
    task sendData();
    //input [25*7:0] fileName;
    integer t;
    begin
        $readmemb(fileName, in_mem);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        for (t=0; t <784; t=t+1) begin
            @(posedge clock);
            in <= in_mem[t];
            in_valid <= 1;
            //@(posedge clock);
            //in_valid <= 0;
        end 
        @(posedge clock);
        in_valid <= 0;
        expected = in_mem[t];
    end
    endtask
   
   //////////////////////////////////////////////////////////////////
   /// Loop de teste envia amostras para a rede e verifica resultados
   //////////////////////////////////////////////////////////////////
    integer i,j,layerNo=1,k;
    integer start;
    integer testDataCount;
    integer testDataCount_int;
    initial
    begin
        reset = 0;
        in_valid = 0;
        #100;
        reset = 1;
        #100
        writeAxi(28,0);//clear soft reset
        start = $time;
        `ifndef pretrained
            configWeights();
            configBias();
        `endif
        $display("Configuration completed",,,,$time-start,,"ns");
        start = $time;
        for(testDataCount=0;testDataCount<`MaxTestSamples;testDataCount=testDataCount+1)
        begin
            testDataCount_int = testDataCount;
            fileName[0] = "t";
            fileName[1] = "x";
            fileName[2] = "t";
            fileName[3] = ".";
            fileName[4] = "0";
            fileName[5] = "0";
            fileName[6] = "0";
            fileName[7] = "0";
            i=0;
            while(testDataCount_int != 0)
            begin
                fileName[i+4] = to_ascii(testDataCount_int%10);
                testDataCount_int = testDataCount_int/10;
                i=i+1;
            end 
            fileName[8] = "_";
            fileName[9] = "a";
            fileName[10] = "t";
            fileName[11] = "a";
            fileName[12] = "d";
            fileName[13] = "_";
            fileName[14] = "t";
            fileName[15] = "s";
            fileName[16] = "e";
            fileName[17] = "t";
            sendData();
            @(posedge intr);
            //readAxi(24);
            //$display("Status: %0x",axiRdData);
            readAxi(8);
            if(axiRdData==expected)
                right = right+1;
            $display("%0d. Accuracy: %f, Detected number: %0x, Expected: %x",testDataCount+1,right*100.0/(testDataCount+1),axiRdData,expected);
            /*$display("Total execution time",,,,$time-start,,"ns");
            j=0;
            repeat(10)
            begin
                readAxi(20);
                $display("Output of Neuron %d: %0x",j,axiRdData);
                j=j+1;
            end*/
        end
        $display("Accuracy: %f",right*100.0/testDataCount);
        $stop;
    end


endmodule