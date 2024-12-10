clear;
close all;
clc;

% Partie 1

% I- Acquisition

% II- Prétraitement

% 2- Lire l'image et la convertir en niveaux de gris
I = imread('images/code_postal_acquisition.jpg');
I_ndg = rgb2gray(I);

figure;
subplot(1, 2, 1);
imshow(I);
title('Image originale');
subplot(1, 2, 2);
imshow(I_ndg);
title('Image en niveaux de gris');

% 3- Binariser l'image
figure;
imhist(I_ndg);

figure
subplot(2, 2, 1);
seuil = 50;
I_bin = ~imbinarize(I_ndg, seuil/255);
imshow(I_bin);
title('Image binarisée (seuil=50)');

subplot(2, 2, 2);
seuil = 100;
I_bin = ~imbinarize(I_ndg, seuil/255);
imshow(I_bin);
title('Image binarisée (seuil=100)');

subplot(2, 2, 3);
seuil = 110;
I_bin = ~imbinarize(I_ndg, seuil/255);
imshow(I_bin);
title('Image binarisée (seuil=110)');

subplot(2, 2, 4);
seuil = 120;
I_bin = ~imbinarize(I_ndg, seuil/255);
imshow(I_bin);
title('Image binarisée (seuil=120)');

seuil = 120;

% 4- Améliration de la qualité de l'image
figure
subplot(2, 2, 1);
I_bin = ~imbinarize(I_ndg, seuil/255);
imshow(I_bin);
title('Image binarisée');

subplot(2, 2, 2);
I_binw = bwareaopen(I_bin, 50);
imshow(I_binw);
title('Image avec bwareaopen');

subplot(2, 2, 3);
I_binw_dila = imdilate(I_binw, strel("disk", 5));
imshow(I_binw_dila);
title('Image dilatée');

subplot(2, 2, 4);
I_binw_dila_erode = imerode(I_binw_dila, strel("disk", 3));
imshow(I_binw_dila_erode);
title('Image érodée');

% III- Localisation des chiffres du code postal

% 5-
figure;
imshow(I_binw_dila_erode);
impixelinfo;

[L, N] = bwlabel(I_binw_dila_erode);
for i = 1:N
    I_chiffre = label2rgb(L);
    imshow(I_chiffre);
end

% 6-
chemin = 'images\';
figure;
imshow(I_binw_dila_erode);
impixelinfo;

I_chiffres = [];

[L, N] = bwlabel(I_binw_dila_erode);
for i = 1:N
    I_chiffre = L==i;
    [r_sup, c_sup] = size(I_chiffre);
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

    % Afficher les différents chiffres de manière isolée
    subplot(1, N, i);
    I_chiffre_recadre = I_chiffre(r_min:r_max, c_min:c_max);
    imshow(I_chiffre_recadre);

    index = length(I_chiffres) + 1;
    I_chiffres{index} = I_chiffre_recadre;

    % Sauvegarder les images de chaque chiffre
    fichier_image = [chemin 'chiffre_' int2str(i) '.jpg'];
    imwrite(I_chiffre_recadre, fichier_image);
end

% 7-

% TO DO

% 9-

N = length(I_chiffres);
for i = 1:N
    I_chiffres_mat = cell2mat(I_chiffres(i));
    [I_dilate, I_cavites] = cavite(I_chiffres_mat);

    figure;
    M = length(I_dilate) + length(I_cavites);
    M = round(M/2);

    subplot(2, M, 1);
    imshow(I_chiffres_mat);
    j = 2;
    for k = keys(I_dilate)
        subplot(2, M, j);
        imshow(I_dilate(k{1}));
        title(append('Dilatation', ' ', k{1}));
        j = j + 1;
    end

    taux_total_cavites = 0;
    for k = keys(I_cavites)
        taux_total_cavites = taux_total_cavites + sum(I_cavites(k{1}), 'all');
    end
    for k = keys(I_cavites)
        taux_cavite = sum(I_cavites(k{1}), 'all') / taux_total_cavites;
        taux_cavite = taux_cavite * 100;

        subplot(2, M, j);
        imshow(I_cavites(k{1}));
        title(append('Cavité', ' ', k{1}, ' : ', num2str(round(taux_cavite, 2)), ' %'));
        j = j + 1;
    end
end

%% Apprentissage

clear;
close all;
clc;

% 15-
[Cavites, Pourcentages] = Reconnaissance();

M = 10; % Les 10 images
P = 5;

for j = 1:M
    for i = 1:P
        to_print = [num2str(j-1) ' :'];
        for k = keys(Cavites)
            objet1 = Cavites(k{1});
            objet2 = objet1{j};
            taux_cavite = objet2(i);
            to_print = [to_print ' ' num2str(round(taux_cavite, 2)) '(' k{1} ')'];
        end
        disp(to_print);
    end

    to_print = ['M :' ' '];
    for k = keys(Pourcentages)
        objet = Pourcentages(k{1});
        to_print = [to_print ' ' num2str(round(objet(j), 2)) '(' k{1} ')'];
    end
    disp(to_print);

    disp('   ----');
end

% 16-

Q = 10;

myKeys = ["est" "sud" "ouest" "nord" "central"];
myValues = {0, 0, 0, 0, 0};
pourcentages = containers.Map(myKeys, myValues);

for j = 1:Q
    I = imread(['base_test\test_' num2str(j) '.png']);
    
    I_chiffres = diviser(I, false, false);
    N = length(I_chiffres);

    figure;
    for i = 1:N
        I_chiffres_mat = cell2mat(I_chiffres(i));
        [~, I_cavites] = cavite(I_chiffres_mat);

        taux_total_cavites = 0;
        for k = keys(I_cavites)
            taux_total_cavites = taux_total_cavites + sum(I_cavites(k{1}), 'all');
        end
    
        for k = keys(I_cavites)
            taux_cavite = 0;
            if taux_total_cavites ~= 0
                taux_cavite = sum(I_cavites(k{1}), 'all') / taux_total_cavites;
            end
            pourcentages(k{1}) = taux_cavite;
        end

        % Norme 1 - Classifieur du plus proche voisin
        chiffre3 = choix_voisin(Cavites, pourcentages, M, P, 1);

        % Norme 2 - Classifieur du plus proche voisin
        chiffre4 = choix_voisin(Cavites, pourcentages, M, P, 2);

        % Norme 1 - Classifieur du plus proche barycentre
        chiffre1 = choix_barycentre(Pourcentages, pourcentages, M, 1);

        % Norme 2 - Classifieur du plus proche barycentre
        chiffre2 = choix_barycentre(Pourcentages, pourcentages, M, 2);

        subplot(4, N, i);
        imshow(I_chiffres_mat);
        title(['Manhattan - Voisin : ' num2str(chiffre3)]);

        subplot(4, N, i+N);
        imshow(I_chiffres_mat);
        title(['Euclide - Voisin : ' num2str(chiffre4)]);

        subplot(4, N, i+2*N);
        imshow(I_chiffres_mat);
        title(['Manhattan - Barycentre : ' num2str(chiffre1)]);

        subplot(4, N, i+3*N);
        imshow(I_chiffres_mat);
        title(['Euclide - Barycentre : ' num2str(chiffre2)]);
    end
end

taux_erreur_norme1_voi = 4/50;
taux_erreur_norme2_voi = 4/50;
taux_erreur_norme1_bar = 13/50;
taux_erreur_norme2_bar = 18/50;

disp(['Taux d-erreur distance de Manhattan - Voisin : ' num2str(round(taux_erreur_norme1_voi*100, 2)) '%']);
disp(['Taux d-erreur distance Euclidienne - Voisin : ' num2str(round(taux_erreur_norme2_voi*100, 2)) '%']);
disp(['Taux d-erreur distance de Manhattan - Barycentre : ' num2str(round(taux_erreur_norme1_bar*100, 2)) '%']);
disp(['Taux d-erreur distance Euclidienne - Barycentre : ' num2str(round(taux_erreur_norme2_bar*100, 2)) '%']);

%% Corrélation

clear;
close all;
clc;

Q = 10;

for j = 1:Q
    I_test = imread(['base_test\test_' num2str(j) '.png']);

    I_chiffres = diviser(I_test, false, true);
    N = length(I_chiffres);

    figure
    subplot(2, 3, 1);
    imshow(I_test);
    title('Image originale');
    for i = 1:N
        I_chiffre = cell2mat(I_chiffres(i));

        prediction = ReconnaissanceCorrelation(I_chiffre);

        subplot(2, 3, i+1);
        imshow(I_chiffre);
        title(['Prediction : ' num2str(prediction)]);
    end
end

taux_erreur = 0/50;

disp(['Taux d-erreur : ' num2str(round(taux_erreur*100, 2)) '%']);

%% Crop

clear;
close all;
clc;

I = imread('base_test\test_1.png');
s = size(I);
J1 = imcrop(I, [0 0 55-0 s(2)]);
J2 = imcrop(I, [55 0 115-55 s(2)]);
J3 = imcrop(I, [115 0 190-115 s(2)]);
J4 = imcrop(I, [190 0 260-190 s(2)]);
J5 = imcrop(I, [260 0 315-260 s(2)]);
figure
imshow(J1)
figure
imshow(J2)
figure
imshow(J3)
figure
imshow(J4)
figure
imshow(J5)

% imwrite(J1, 'base_apprentissage\neuf_1.jpg');
% imwrite(J2, 'base_apprentissage\neuf_2.jpg');
% imwrite(J3, 'base_apprentissage\neuf_3.jpg');
% imwrite(J4, 'base_apprentissage\neuf_4.jpg');
% imwrite(J5, 'base_apprentissage\neuf_5.jpg');

