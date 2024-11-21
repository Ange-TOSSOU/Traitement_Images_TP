function I_chiffres = diviser(I, pretraitement)    
    I_ndg = rgb2gray(I);
    I_bin = ~imbinarize(I_ndg);

    if pretraitement
        I_bin_dila = imdilate(I_bin, strel("disk", 3));
        I_bin_dila_erode = imerode(I_bin_dila, strel("disk", 3));
        I_bin = I_bin_dila_erode;
    end

    chemin = 'images\';
    I_chiffres = [];

    [L, N] = bwlabel(I_bin);
    for i = 1:N
        I_chiffre = L==i;
        [~, c_sup] = size(I_chiffre);
        [r, c] = find(I_chiffre);
        [r_min, r_max, c_min, c_max] = deal(min(r), max(r), min(c), max(c));
        
        espace_au_bord = 10;
        % Elargir à gauche
        for k = 1:espace_au_bord
            if c_min == 1
                break;
            end
            c_min = c_min - 1;
        end
        % Elargir à droite
        for k = 1:espace_au_bord
            if c_max == c_sup
                break;
            end
            c_max = c_max + 1;
        end
        
        % Les différents chiffres isolés
        I_chiffre_recadre = I_chiffre(r_min:r_max, c_min:c_max);
        index = length(I_chiffres) + 1;
        I_chiffres{index} = I_chiffre_recadre;
        
        % Sauvegarder les images de chaque chiffre
        fichier_image = [chemin 'chiffre_' int2str(i) '.png'];
        imwrite(I_chiffre_recadre, fichier_image);
    end
end