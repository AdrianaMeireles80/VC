prompt = 'Qual é a imagem que pretende? Escreva castle, lena ou baboon: ';
inp = input(prompt,'s');

if(inp=="castle")
    I= imread('images/castle.jpg');
  
elseif(inp=="lena")
    I= imread('images/lena.png');
 
else
    I= imread('images/baboon.png');
end

prompt = 'Tipo de barulho? Escreva sp ou gauss: ';
noise = input(prompt,'s');

if(noise=="sp")
    prompt = 'Insira o Parâmetro do barulho e a Densidade do barulho: ';
    noise_den = input(prompt);
    mean = 0;
    var_g = 0;
else
    prompt = 'Insira a Média dos Parâmetros do barulho: ';
    mean = input(prompt);
    prompt = 'Variância de Gauss: ';
    var_g = input(prompt);
    noise_den = 0;
end

prompt = 'Domino de Filtragem? Escreva espacial ou freq: ';
domain = input(prompt,'s');

if(domain=="espacial")
   prompt ='Que filtro deseja usar? Escreva media, gaussiana ou mediana: ';
   filter = input(prompt,'s');

else
    prompt='Que filtro deseja usar? Escrevae gaussiana ou butter: ';
    filter = input(prompt,'s');
end
    
if(filter=="media")
    prompt = 'Tamanho do filtro (3 para 3x3 5 para 5x5): ';
    kernel = input(prompt);
    sigma=0;
    m=0;
    n=0;
    fo=0;
    ccr=0;
    pass="";
    
elseif(filter=="gaussiana" && domain=="espacial")
    prompt = 'Desvio do Filtro?(sigma): ';
    sigma = input(prompt);
    prompt = 'Filter size (3 for 3x3 5 for 5x5): ';
    kernel= input(prompt);
    m=0;
    n=0;
    fo=0;
    ccr=0;
    pass="";
   
elseif(filter=="mediana")
    prompt = 'Neighborhood: ? M= ';
    m = input(prompt);
    prompt = 'N= ';
    n = input(prompt);
    sigma=0;
    kernel=0;
    fo=0;
    ccr=0;
    pass="";
    
elseif(filter=="gaussiana" && domain=="freq")
    prompt = 'Lowpass ou Highpass? Escreva low ou high: ';
    pass = input(prompt,'s');
    prompt = 'Raio do círculo de corte?: ';
    ccr = input(prompt);
    fo=0;
    m=0;
    n=0;
    sigma=0;
    kernel=0;
    
else
    prompt = 'Lowpass ou Highpass? Escreva low ou high: ';
    pass = input(prompt,'s');
    prompt='Ordem do Filtro?: ';
    fo = input(prompt);
    prompt='Raio do círculo de corte?: ';
    ccr = input(prompt);
    m=0;
    n=0;
    sigma=0;
    kernel=0;
end

%I - image
%gray - grayscale image
%noise - image noise 
%noise_den - noise density for Salt-anoise_den-Pepper noise
%mean anoise_den var_gauss - mean anoise_den variance for Gaussian noise
%domain - Filtering domain (spatial or frequency)
%filter - Filter that was chosen
%kernel - Kernel size for Averaging or Gaussian filter
%sigma - Stanoise_denard deviation for Gaussian filter (Spatial)
%m anoise_den n - Neighbourhood size (3x3, 5x5, etc) for Median filter
%fo anoise_den ccr - filter order anoise_den cutoff circle radius for Butterworth filter

gray = rgb2gray(I);

main_smoothfilters(gray,noise,noise_den,mean,var_g,domain,filter,pass,kernel,sigma,m,n,fo,ccr,inp);
