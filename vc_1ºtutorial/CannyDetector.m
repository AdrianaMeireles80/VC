prompt = 'Qual é a imagem que pretende? Escreva castle, lena ou baboon: ';
inp = input(prompt,'s');

if(inp=="castle")
    I= imread('images/castle.jpg');
  
elseif(inp=="lena")
    I= imread('images/lena.png');
 
else
    I= imread('images/baboon.png');
end

im = imnoise(I,'gaussiana');

main_CannyDetector(im,inp);
