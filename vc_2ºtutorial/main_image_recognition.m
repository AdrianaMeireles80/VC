function main_image_recognition(s,gray,barulho,noise_den,média,var_g)

    %Addnoise to image
    %Filter image for easier edge detection
    if(barulho=="1")
        imWnoise = addnoiseSP(gray,noise_den);
        img_filt = medfilt2(imWnoise,[5 5]);
    elseif(barulho=="2")
        imWnoise = addnoiseG(gray,média,var_g);
        img_filt = imgaussfilt(imWnoise,0.5);
    else
        imWnoise = gray;
        img_filt = gray;
    end
    
    I1 = adapthisteq(img_filt,'NumTiles',[20 20]);
    figure,imshow(I1),title('After adding noise ,filtering image and doing adpative histogram equalization');
    
    
    I2 = edge(I1,'canny',[0.25 0.35]);
     
    figure, imshow(I2), title('Canny Edge Detector');
    
    [centros,raio,métrica] = find_circ(s,I2);
    
    figure, imshow(I2), title('Imagem final');
    
    vis_circ(centros, raio,'LineStyle','-','LineWidth',1.5,'EdgeColor','r');
    
    for k = 1:length(métrica)
        métrica_string = sprintf('%i',k);
        text(centros(k,1),centros(k,2),métrica_string,'FontSize',35,'FontWeight','bold','color','g','HorizontalAlignment','center','VerticalAlignment','middle');
    end
    
    histo = ar_hist(raio);
    
    amount = count_coins(raio);
    
end

%adds Salt and Pepper noise to a grayscale image
function imWnoise = addnoiseSP(im,noise_den)
    imWnoise = imnoise(im,'salt & pepper',noise_den);
end

%adds Gaussian noise to grayscale image
function imWnoise = addnoiseG(im,média,var_g)
    imWnoise = imnoise(im,'gaussiana',média,var_g);
end

function [centros,raio,métrica] = find_circ(s,im)
    if(s=="1")
        [centros,raio,métrica] = imfindcircles(im,[50 150],'Sensitivity', 0.95, 'EdgeThreshold', 0.32,'ObjectPolarity','bright');  
    elseif(s=="2")
        [centros,raio,métrica] = imfindcircles(im,[50 150],'Sensitivity', 0.95, 'EdgeThreshold', 0.42,'ObjectPolarity','bright');
    else
        [centros,raio,métrica] = imfindcircles(im,[50 150],'Sensitivity', 0.95, 'EdgeThreshold', 0.22,'ObjectPolarity','bright');
    end
end

function histo = ar_hist(raio)
 
    for k = 1: length(raio)
        area(k) = raio(k).^2*pi;
    end 
    
    C = categorical(raio);
    D = categorical(area);
    figure, histogram(C,'BarWidth',0.4); title('Raio das moedas em pixels')
    figure, histogram(D,'BarWidth',0.4); title('Área das moedas em pixels')
    
    histo = 1;

end

function amount = count_coins(raio)
    tip1=0;
    tip2=0;
    
    for k=1:length(raio)
        if raio(k) <= 75
            tip1 = tip1 + 1;
        else
            tip2 = tip2 + 1;       
        end
    end
    
    sum = tip1 + 2*tip2;

    message = sprintf('%i coins where found in the choosen image -> %i type 1(type1 = 1 point) e %i type 2 (type2 = 2*type1 points) rouding to a total of %i points',length(raio),tip1,tip2,sum);
   
    f = msgbox(message,'Sucesso');
     
     amount = sum;
end

