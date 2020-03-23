function main_smoothfilters = main_smoothfilters(gray,noise,noise_den,mean,var_g,domain,filter,pass,kernel,sigma,m,n,fo,ccr,inp)
    
    %addnoise to image
    if(noise=="sp")
        imWnoise = addnoiseSP(gray,nd);
    elseif(noise=="gauss")
        imWnoise = addnoiseG(gray,mean,var_g);
    else
        imWnoise=gray;
    end
    
    
    %if/elseif/else applies filter
    %Spatial Domain
    %Apply averaging filter
    if(domain=="espacial")
        if(filter=="media")
            imfiltered = applyfilterAv(imWnoise,kernel);
        %Apply gaussian filter (spatial)
        elseif(filter=="gaussiana" && domain=="espacial")
            imfiltered = applyfilterGS(imWnoise,sigma,kernel);
        %Apply median filter
        else
            imfiltered = applyfilterMed(imWnoise,m,n);
        end
    end
       
    
    %Frequency Domain
    
    if(domain=="freq")
        
        %preparation
        cim = double(imWnoise);
        [r,c] = size(cim);
        
        r1 = 2*r;
        c1 = 2*c;
        
        pim = zeros((r1),(c1));
        kim = zeros((r1),(c1));
        
        %padding
        for i=1:r
            for j=1:c
                pim(i,j)=cim(i,j);
            end
        end
        
        %center the transform
        for i=1:r
            for j=1:c
                kim(i,j)=pim(i,j)*((-1)^(i+j));
            en
        end
        
        %2D fft
        fim=fft2(kim);
        imnoise = fft2(imWnoise);
        imorig = fft2(gray);
        
        %low pass filters
        if(pass=="low")
            %Apply gaussian filter (frequency)
            if(filter=="gaussiana")
                him = applyfilterGFL(fim,ccr); 
            %Apply butterworth filter
            else
                him = applyfilterBL(fim,ccr,fo);
            end
        end
        
        %high pass filters
        if(pass=="high")
             %Apply gaussian filter (frequency)
            if(filter=="gaussiana")
                him = applyfilterGFH(fim,ccr); 
            %Apply butterworth filter
            else
                him = applyfilterBH(fim,ccr,fo);
            end
        end
        
  
        %inverse 2D fft
        ifim = ifft2(him);
        
        for i=1:r1
            for j=1:c1
                ifim(i,j)=ifim(i,j)*((-1)^(i+j));
            end
        end
        
        %imshow(uint8(fim));title('Transform Centering');figure;
        %imshow(uint8(him));title('Fourier Transform Filtered');figure;
        %imshow(uint8(imorig));title('Fourier Transform Original');figure;
        %imshow(uint8(imnoise));title('Fourier Transform Noise');figure;       
        
        %removing the padding
        for i=1:r
            for j=1:c
                rim(i,j)=ifim(i,j);
            end
        end
        
        %maintain the real parts of the matrix
        imfiltered = uint8(real(rim));
        %imfiltered = uint8(rim);
        
        %imshow(imfiltered);figure;title('final')
        
    end
        
    
    
    %imshowpair(gray,imWnoise,'montage');
    %figure;
    imshow(imfiltered);
    
    main_smoothfilters = 'done';
    
    %save noisy image and smoothed image
    if(noise=="sp") %Salt & Pepper
        s = [str '_' noise '_' 'noise_density' num2str(nd) '.png'];
    else %Gaussian
        s = [str '_' noise '_mean' num2str(mean) '_variance' num2str(var_gauss) '.png'];
    end
    
    if(filter=="media")
        s1 = [str '_smooth_' filter '_kernel_size' num2str(kernel) '.png'];
    elseif(filter=="gaussiana" && domain=="spatial")
        s1 = [str '_smooth_' filter 'S' '_deviation' num2str(sigma) '_kernel' num2str(kernel) '.png'];
    elseif(filter=="gaussiana" && domain=="freq")
        s1 = [str '_smooth_' filter 'F' '_' pass '_cutoff_circle_radius' num2str(ccr) '.png'];
    elseif(filter=="mediana")
        s1 = [str '_smooth_' filter '_neighbourhood' '[' num2str(m) ' ' num2str(n) ']' '.png'];
    else %Butterworth 
        s1 = [str '_smooth_' filter '_' pass '_filter_order' num2str(fo) 'cutoff_circle_radius' num2str(ccr) '.png'];
    end
        
        
    imwrite(imWnoise,s);
    imwrite(imfiltered,s1);
    
end

%adds Salt and Pepper noise to a grayscale image
function imWnoise = addnoiseSP(im,nd)
    imWnoise = imnoise(im,'salt & pepper',nd);
end

%adds Gaussian noise to graysclae image
function imWnoise = addnoiseG(im,mean,var_g)
    imWnoise = imnoise(im,'gaussiana',mean,var_g);
end

%Filters image with Average Filter
function imfiltered = applyfilterAv(im,kernel)
    h = fspecial('media', kernel);
    imfiltered = imfilter(im,h);
end

%Filters image with Gaussian Filter (Spatial)
function imfiltered = applyfilterGS(im,sigma,kernel)
    imfiltered = imgaussfilt(im,sigma,'FilterSize',kernel,'FilterDomain','spatial');
end

%Filters image with Median Filter
function imfiltered = applyfilterMed(im,m,n)
    imfiltered = medfilt2(im,[m n]);
end


%Filters image with Gaussian Filter Low Pass (Frequency)
function him = applyfilterGFL(im,ccr) 
    [r,c]=size(im);
    d0=ccr;
    
    d=zeros(r,c);
    h=zeros(r,c);
    
    for i=1:r
        for j=1:c
            d(i,j) = sqrt( (i-(r/2))^2 + (j-(c/2))^2);
        end
    end
    
    for i=1:r
        for j=1:c
            h(i,j) = exp( -( (d(i,j)^2)/(2*(d0^2)) ) );
        end
    end
    
    for i=1:r
        for j=1:c
            him(i,j)=(h(i,j))*im(i,j);
        end
    end

%imfiltered = imgaussfilt(im,sigma,'FilterSize',kernel,'FilterDomain','frequency');
end

%Filters image with Gaussian Filter High Pass (Frequency)
function him = applyfilterGFH(im,ccr)
    [r,c]=size(im);
    d0=ccr;
    
    d=zeros(r,c);
    h=zeros(r,c);
    
    for i=1:r
        for j=1:c
            d(i,j) = sqrt( (i-(r/2))^2 + (j-(c/2))^2);
        end
    end
    
    for i=1:r
        for j=1:c
            h(i,j) = 1- exp( -( (d(i,j)^2)/(2*(d0^2)) ) );
        end
    end
    
    for i=1:r
        for j=1:c
            him(i,j)=(h(i,j))*im(i,j);
        end
    end
end

%Filters image with Butterworth filter Low Pass
function him = applyfilterBL(im,ccr,fo)
    [r,c] = size(im);
    d0=ccr;
    
    d=zeros(r,c);
    h=zeros(r,c);
    
    for i=1:r
        for j=1:c
            d(i,j) = sqrt( (i-(r/2))^2 + (j-(c/2))^2);
        end
    end
    
    for i=1:r
        for j=1:c
            h(i,j) = 1 / (1+ (d(i,j)/d0)^(2*fo) );
        end
    end
    
    for i=1:r
        for j=1:c
            him(i,j)=(h(i,j))*im(i,j);
        end
    end

end

%Filters image with Butterworth filter High Pass
function him = applyfilterBH(im,ccr,fo)
    [r,c]=size(im);
    d0 = ccr;
    
    d=zeros(r,c);
    h=zeros(r,c);
    
    for i=1:r
        for j=1:c
            d(i,j)= sqrt( (i-(r/2))^2 + (j-(c/2))^2);
        end
    end
    
    for i=1:r
        for j=1:c
            h(i,j)= 1 / (1+ (d0/d(i,j))^(2*fo) );
        end
    end
    
    for i=1:r
        for j=1:c
            him(i,j)=(h(i,j))*im(i,j);
        end
    end
            
end
