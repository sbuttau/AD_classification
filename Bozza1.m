%Bozza per le 42 cartelle del disc1

filepath1 = "Dataset\disc1";
filepath2 = "\OAS1_000"
filepath3 = "_MR1\OAS1_000"
filepath4 = "_MR1.txt";
nome1 ="RAW\OAS1_000";
nome2 = "_MR1_mpr-";
nome3 = "_anon_sag_66.gif";
n = 1;

for i = 1:42
    if i > 9 
        filepath2 = "\OAS1_00";
        filepath3 = "_MR1\OAS1_00";
        nome1 = "RAW\OAS1_00"
    end
    filepath = filepath1 + filepath2 + num2str(i)+ filepath3 + num2str(i) + filepath4
    CDR = parseSubjectStatus(filepath) %Ricavo il Clinical Dementia Rating (livello di demenza)
    
    img1 = nome1+num2str(i)+nome2+num2str(n)+nome3;
    img2 = nome1+num2str(i)+nome2+num2str(n+1)+nome3;
    img3 = nome1+num2str(i)+nome2+num2str(n+2)+nome3;
    if CDR == 0 %Se è nullo, il paziente è sano
        healthyIndx(i) = CDR %Salvo l'indice
        %Salvo le risonanze in un cell array 
        healthyImgs{i,1} ={img1,img2,img3}
    else
        if CDR > 0 %Se è > 0, il paziente è affetto da demenza
        dementIndx(i) = CDR % Salvo l'indice
        %Salvo le risonanze in un cell array 
        dementImgs{i,1} = {img1,img2,img3}
        end
    end
end


