function main_CannyDetector = main_CannyDetector(im,inp)

    gray = rgb2gray(im);
    gray = double(gray);
    
    %Value for Thresholding
    Low_T = 0.075;
    High_T = 0.1;

    %Apply Gaussian Filter
    prompt='Valor Sigma para Filtro Gaussiana ? : ';
    sigma=input(prompt);
    prompt='Valor Kernel para filtro Gaussiana? (3 for 3x3, 5 for 5x5, etc): ';
    kernel=input(prompt);
    A = applyfilterGS(gray,sigma,kernel);
    
    %Filter for horizontal and vertical direction
    KGx = [-1, 0, 1; -2, 0, 2; -1, 0, 1]; %horizontal kernel
    KGy = [1, 2, 1; 0, 0, 0; -1, -2, -1]; %vertical kernel
    
    %Convolution by image by horizontal and vertical filter
    filt_X = conv2(A, KGx, 'same');
    filt_Y = conv2(A, KGy, 'same');
    
    %Calculate directions/orientations
    arah = atan2(filt_Y, filt_X);
    arah = arah*180/pi;
    
    pan = size(A,1);
    leb = size(A,2);
    
    %Adjustment for negative directions, making all directions positive
    for i=1:pan
        for j=1:leb
            if(arah(i,j)<0)
                arah(i,j)=360+arah(i,j);
            end
        end
    end
    
    arah2=zeros(pan,leb);
    
    %Adjusting directions to nearest 0, 45, 90, 135 degree
    for i = 1  : pan
        for j = 1 : leb
            if ((arah(i, j) >= 0 ) && (arah(i, j) < 22.5) || (arah(i, j) >= 157.5) && (arah(i, j) < 202.5) || (arah(i, j) >= 337.5) && (arah(i, j) <= 360))
                arah2(i, j) = 0;
            elseif ((arah(i, j) >= 22.5) && (arah(i, j) < 67.5) || (arah(i, j) >= 202.5) && (arah(i, j) < 247.5))
                arah2(i, j) = 45;
            elseif ((arah(i, j) >= 67.5 && arah(i, j) < 112.5) || (arah(i, j) >= 247.5 && arah(i, j) < 292.5))
                arah2(i, j) = 90;
            elseif ((arah(i, j) >= 112.5 && arah(i, j) < 157.5) || (arah(i, j) >= 292.5 && arah(i, j) < 337.5))
                arah2(i, j) = 135;
            end
        end
    end
    
    figure, imshow(arah2),title('Antes supressão não máxima');
    figure, imagesc(arah2); colorbar;
    
    %Calculate magnitude
    magnitude = (filt_X.^2) + (filt_Y.^2);
    magnitude2 = sqrt(magnitude);
    
    bw = zeros(pan,leb);
    
    %Non-Maximum Suppression
    for i=2:pan-1
        for j=2:leb-1
            if (arah2(i,j)==0)
                bw(i,j) = (magnitude2(i,j) == max([magnitude2(i,j), magnitude2(i,j+1), magnitude2(i,j-1)]));
            elseif (arah2(i,j)==45)
                bw(i,j) = (magnitude2(i,j) == max([magnitude2(i,j), magnitude2(i+1,j-1), magnitude2(i-1,j+1)]));
            elseif (arah2(i,j)==90)
                bw(i,j) = (magnitude2(i,j) == max([magnitude2(i,j), magnitude2(i+1,j), magnitude2(i-1,j)]));
            elseif (arah2(i,j)==135)
                bw(i,j) = (magnitude2(i,j) == max([magnitude2(i,j), magnitude2(i+1,j+1), magnitude2(i-1,j-1)]));
            end
        end
    end

    bw = bw.*magnitude2;
    figure,imshow(bw),title('Depois supressão não máxima');
    
    %Hysteresis Thresholding
    Low_T = Low_T * max(max(bw));
    High_T = High_T * max(max(bw));
    
    Res_T = zeros(pan,leb);
    
    for i=1:pan
        for j=1:leb
            if(bw(i,j) < Low_T)
                Res_T(i,j) = 0;
            elseif (bw(i,j) > High_T)
                Res_T(i,j) = 1;
            elseif ( bw(i+1,j)>High_T || bw(i-1,j)>High_T || bw(i,j+1)>High_T || bw(i,j-1)>High_T || bw(i-1, j-1)>High_T || bw(i-1, j+1)>High_T || bw(i+1, j+1)>High_T || bw(i+1, j-1)>High_T)
                Res_T(i,j) = 1;
            end
        end
    end
    
    edge_final = uint8(Res_T.*255);
    
    %Show final edge detection result
    figure,imshow(edge_final),title('Imagem final');

    main_CannyDetector = 'ok';

    %Ficheiros Guardar
    s1 = [str '_edge_canny_size' num2str(kernel) '_variance' num2str(sigma) '.png'];
    s2 = [str '_edge_canny_nonmax_size' num2str(kernel) '_variance' num2str(sigma) '.png'];
    s3 = [str '_edge_canny_hysteresis_size' num2str(kernel) '_variance' num2str(sigma) '.png'];

    
    imwrite(arah2,s1);
    imwrite(bw,s2);
    imwrite(edge_final,s3);
    
end

%Apply Gaussian filter (Spatial)
function imfiltered = applyfilterGS(im,sigma,kernel)
    imfiltered = imgaussfilt(im,sigma,'FilterSize',kernel,'FilterDomain','espacial');
end
