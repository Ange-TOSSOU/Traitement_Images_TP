clear;
close all;
clc;


% 1- Lire l'image
I = imread('images/code_postal_acquisition.jpg');

% 2- Conversion en niveaux de gris
I_ndg = rgb2gray(I);

figure;
subplot(1, 2, 1);
imshow(I);
title('Image originale');
subplot(1, 2, 2);
imshow(I_ndg);
title('Image en niveaux de gris');

% 3- Binariser l'image
% Choisir le seuil de binarisation en analysant l'histogramme
figure;
imhist(I_ndg);
title("Histogramme de l'image en niveau de gris");

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

% 5- Détermination du nombre de régions
figure;
imshow(I_binw_dila_erode);
impixelinfo;

[L, N] = bwlabel(I_binw_dila_erode);
for i = 1:N
    I_chiffre = label2rgb(L);
    imshow(I_chiffre);
end
title([num2str(N) ' régions']);

% 6- Isolation des chiffres du code postal
chemin = 'images/';
figure;
imshow(I_binw_dila_erode);
impixelinfo;

I_chiffres = [];

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

% 7- Dilatation en utilisant des éléments structurants ligne et colonne
% 8- Voir la fonction cavite.m
% 10- Cavité Nord : intersection des dilatations nord, est et ouest privée de la dilatation sud et des pixels appartenant au chiffre
%     Cavité Est : intersection des dilatations nord, est et sud privée de la dilatation ouest et des pixels appartenant au chiffre
%     Cavité Sud : intersection des dilatations est, sud et ouest privée de la dilatation nord et des pixels appartenant au chiffre
%     Cavité Ouest : intersection des dilatations nord, sud et ouest privée de la dilatation est et des pixels appartenant au chiffre
%     Cavité Centrale : intersection de toutes les dilatations privée des pixels appartenant au chiffre
% Voir la fonction cavite.m pour l'implémentation
% 11-12 Voir la fonction cavite.m
% 9-13 Voir le code ci-dessous


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
    % Afficher tous les taux des cavités pource chiffre
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

    % Afficher la moyenne des cavités
    to_print = ['M :' ' '];
    for k = keys(Pourcentages)
        objet = Pourcentages(k{1});
        to_print = [to_print ' ' num2str(round(objet(j), 2)) '(' k{1} ')'];
    end
    disp(to_print);

    disp('   ----');
end

% 16- Reconnaissance des chiffres de la base de test

Q = 10; % Le nombre d'images de test

% Initialisation du vecteur des cavités pour un seul chiffre
myKeys = ["est" "sud" "ouest" "nord" "central"];
myValues = {0, 0, 0, 0, 0};
pourcentages = containers.Map(myKeys, myValues);

for j = 1:Q
    I = imread(['base_test/test_' num2str(j) '.png']);
    
    % Récupération des chiffres de l'image de manière isolée
    I_chiffres = diviser(I, false, false);
    N = length(I_chiffres);

    figure;
    for i = 1:N
        % Récupération des cavités du chiffre
        I_chiffres_mat = cell2mat(I_chiffres(i));
        [~, I_cavites] = cavite(I_chiffres_mat);

        % Calcul de la somme des surfaces des cavités
        taux_total_cavites = 0;
        for k = keys(I_cavites)
            taux_total_cavites = taux_total_cavites + sum(I_cavites(k{1}), 'all');
        end
    
        for k = keys(I_cavites)
            % Normalisation des cavités
            taux_cavite = 0;
            if taux_total_cavites ~= 0
                taux_cavite = sum(I_cavites(k{1}), 'all') / taux_total_cavites;
            end
            pourcentages(k{1}) = taux_cavite;
        end

        % Norme 1 - Classifieur du plus proche voisin
        prediction1 = choix_voisin(Cavites, pourcentages, M, P, 1);

        % Norme 2 - Classifieur du plus proche voisin
        prediction2 = choix_voisin(Cavites, pourcentages, M, P, 2);

        % Norme 1 - Classifieur du plus proche barycentre
        prediction3 = choix_barycentre(Pourcentages, pourcentages, M, 1);

        % Norme 2 - Classifieur du plus proche barycentre
        prediction4 = choix_barycentre(Pourcentages, pourcentages, M, 2);

        subplot(4, N, i);
        imshow(I_chiffres_mat);
        title(['Manhattan - Voisin : ' num2str(prediction1)]);

        subplot(4, N, i+N);
        imshow(I_chiffres_mat);
        title(['Euclide - Voisin : ' num2str(prediction2)]);

        subplot(4, N, i+2*N);
        imshow(I_chiffres_mat);
        title(['Manhattan - Barycentre : ' num2str(prediction3)]);

        subplot(4, N, i+3*N);
        imshow(I_chiffres_mat);
        title(['Euclide - Barycentre : ' num2str(prediction4)]);
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

Q = 1; % Le nombre d'images de test

for j = 1:Q
    I_test = imread(['base_test/test_' num2str(j) '.png']);

    % Récupération des chiffres de l'image de manière isolée
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

disp(['Taux d-erreur  : ' num2str(round(taux_erreur*100, 2)) '%']);

%% Test grandeur nature
% Limites de la corrélation

clear;
close all;
clc;

I = imread('images/code_postal_acquisition.jpg');

[Cavites, Pourcentages] = Reconnaissance();

% Initialisation du vecteur des cavités pour un seul chiffre
myKeys = ["est" "sud" "ouest" "nord" "central"];
myValues = {0, 0, 0, 0, 0};
pourcentages = containers.Map(myKeys, myValues);

% Récupération des chiffres de l'image de manière isolée
I_chiffres = diviser(I, true, false);

N = length(I_chiffres);

debut = 0;
code_postal_prediction = [0 0 0 0 0];

for i = 1:N
    % Récupération des cavités du chiffre
    I_chiffres_mat = cell2mat(I_chiffres(i));
    [~, I_cavites] = cavite(I_chiffres_mat);

    % Calcul de la somme des surfaces des cavités
    taux_total_cavites = 0;
    for k = keys(I_cavites)
        taux_total_cavites = taux_total_cavites + sum(I_cavites(k{1}), 'all');
    end

    for k = keys(I_cavites)
        % Normalisation des cavités
        taux_cavite = 0;
        if taux_total_cavites ~= 0
            taux_cavite = sum(I_cavites(k{1}), 'all') / taux_total_cavites;
        end
        pourcentages(k{1}) = taux_cavite;
    end

    prediction1 = choix_voisin(Cavites, pourcentages, 10, 5, 1);
    code_postal_prediction(1) = code_postal_prediction(1)*10*debut + prediction1;

    prediction2 = choix_voisin(Cavites, pourcentages, 10, 5, 2);
    code_postal_prediction(2) = code_postal_prediction(2)*10*debut + prediction2;

    prediction3 = choix_barycentre(Pourcentages, pourcentages, 10, 1);
    code_postal_prediction(3) = code_postal_prediction(3)*10*debut + prediction3;

    prediction4 = choix_barycentre(Pourcentages, pourcentages, 10, 2);
    code_postal_prediction(4) = code_postal_prediction(4)*10*debut + prediction4;

    debut = 1;
end

debut = 0;
for i = 1:N
    I_chiffre = cell2mat(I_chiffres(i));

    prediction = ReconnaissanceCorrelation(I_chiffre);

    code_postal_prediction(5) = code_postal_prediction(5)*10*debut + prediction;

    debut = 1;
end

figure
subplot(2, 1, 1)
imshow(I);
title('Code postal à prédire');

start = 800;
gap = 100;
text(0, start + 0*gap, ['Plus proche voisin - Manhattan : ' num2str(code_postal_prediction(1))], 'Fontsize',20, 'Color','blue');
text(0, start + 1*gap, ['Plus proche voisin - Euclidienne : ' num2str(code_postal_prediction(2))], 'Fontsize',20, 'Color','blue');
text(0, start + 2*gap, ['Plus proche barycentre - Manhattan : ' num2str(code_postal_prediction(3))], 'Fontsize',20, 'Color','blue');
text(0, start + 3*gap, ['Plus proche barycentre - Euclidienne : ' num2str(code_postal_prediction(4))], 'Fontsize',20, 'Color','blue');
text(0, start + 4*gap, ['Approche par corrélation : ' num2str(code_postal_prediction(5))], 'Fontsize',20, 'Color','blue');

