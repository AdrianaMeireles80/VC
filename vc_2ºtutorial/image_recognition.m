prompt = 'Qual é a imagem que pretende? Escreva 1, 2 ou 3 ';
s = inputdlg(prompt);

if(s=="1")
    I = imread('Images/coins.jpg');
    gray = rgb2gray(imresize(I,[400 600]));
elseif(s=="2")
    I = imread('Images/coins3.jpg');
    gray = rgb2gray(imresize(I,[500 600]));
else
    I = imread('Images/coins2.jpg');
    gray = rgb2gray(imresize(I,[500 600]));
end

prompt = 'Tipo de barulho? Escreva 1 para  barulho Salt-and-Pepper ou 2 para barulho Gaussiana ';
barulho = inputdlg(prompt);

if(barulho=="1")
    prompt = 'Insira Parâmetro de barulho - Densidade do barulho (<0.4 para melhores resultados): ';
    resposta = inputdlg(prompt);
    noise_den = str2num(resposta{1});
    média = 0;
    var_g = 0;
else
    prompt = {'Insira Parâmetro de barulho - média (<0.1 for best results): ', 'variância(<0.05 for best results): '};
    resposta = inputdlg(prompt);
    média = str2num(resposta{1});
    var_g = str2num(resposta{2});
    noise_den = 0;
end

main_image_recognition(s,gray,barulho,noise_den,média,var_g);