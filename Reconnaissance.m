function [Cavites, Pourcentages] = Reconnaissance()

    M = 10; % Le nombre d'images pour l'apprentissage
    P = 5; % Le nombre de chiffres que contient chaque images

    % Initialisation de la matrice des cavités des M*P chiffres
    myKeys = ["est" "sud" "ouest" "nord" "central"];
    myValues = cell(1, P);
    for j = 1:P
        myValues{j} = cell(1, M);
        objet = myValues{j};
        for k = 1:M
            objet{k} = zeros(1, P);
        end
        myValues{j} = objet;
    end
    Cavites = containers.Map(myKeys, myValues);

    % Initialisation du vecteur des cavités moyennes des M*P chiffres
    myKeys = ["est" "sud" "ouest" "nord" "central"];
    myValues = cell(1, P);
    for j = 1:P
        myValues{j} = zeros(1, M);
    end
    Pourcentages = containers.Map(myKeys, myValues);
    
    % Mise à jour de la matrice des cavités et du vecteur des cavités moyennes des M*P chiffres
    % j = Les 10 images d'apprentissage
    for j = 1:M
        I = imread(['base_apprentissage/chiffre_' num2str(j-1) '.png']);
        
        % Récupération des chiffres de l'image de manière isolée
        I_chiffres = diviser(I, false, false);
        N = length(I_chiffres);
    
        % P == N == 5
        % i = Les 5 chiffres de l'image
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

                objet1 = Cavites(k{1});
                objet2 = objet1{j};
                objet2(i) = taux_cavite;
                objet1{j} = objet2;
                Cavites(k{1}) = objet1;

                objet = Pourcentages(k{1});
                objet(j) = objet(j) + taux_cavite;
                Pourcentages(k{1}) = objet;
            end
        end
    
        % Calcul de la moyenne des cavités
        for k = keys(Pourcentages)
            objet = Pourcentages(k{1});
            objet(j) = objet(j) / N;
            Pourcentages(k{1}) = objet;
        end
    end
end
