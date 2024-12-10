function [prediction] = ReconnaissanceCorrelation(I_test)

    M = 10;
    
    % j = Les 10 images
    pic = 0;
    for j = 1:M
        I = imread(['base_apprentissage\chiffre_' num2str(j-1) '.png']);
        I_ndg = rgb2gray(I);

        i_test_size = size(I_test);
        i_size = size(I_ndg);
        if i_size(2) < i_test_size(2)
            complement = 200 + zeros(i_size(1), i_test_size(2)-i_size(2));
            I_ndg = [I_ndg complement];
        end

        i_test_size = size(I_test);
        i_size = size(I_ndg);
        if i_size(1) < i_test_size(1)
            complement = 200 + zeros(i_test_size(1)-i_size(1), i_size(2));
            I_ndg = vertcat(I_ndg, complement);
        end

        corr_visualisation = normxcorr2(I_test, I_ndg);

        noouveau_pic = max(corr_visualisation(:));

        if noouveau_pic > pic
            pic = noouveau_pic;
            prediction = j - 1;
        end
    
%         figure
%         subplot(1, 3, 1);
%         imshow(I_test);
%         subplot(1, 3, 2);
%         imshow(I);
%         subplot(1, 3, 3);
%         surf(corr_visualisation);
%         shading flat;
    end
end
