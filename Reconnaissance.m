function [Cavites, Pourcentages] = Reconnaissance()

    M = 10;
    P = 5;

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

    myKeys = ["est" "sud" "ouest" "nord" "central"];
    myValues = cell(1, P);
    for j = 1:P
        myValues{j} = zeros(1, M);
    end
    Pourcentages = containers.Map(myKeys, myValues);
    
    % j = Les 10 images
    for j = 1:M
        I = imread(['base_apprentissage\chiffre_' num2str(j-1) '.png']);
        
        I_chiffres = diviser(I, false, false);
        N = length(I_chiffres);
    
        % P == N == 5
        % i = Les 5 chiffres de l'image
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
    
        for k = keys(Pourcentages)
            objet = Pourcentages(k{1});
            objet(j) = objet(j) / N;
            Pourcentages(k{1}) = objet;
        end
    end
end
