function chiffre = choix_barycentre(Pourcentages, pourcentages, M, p)
    % Isobarycentre
    norme_chiffres = zeros(1, M);
    for i = 1:M
        a = [];
        b = [];
        for k = keys(pourcentages)
            objet = Pourcentages(k{1});
            a = [a objet(i)];
            b = [b pourcentages(k{1})];
        end
        c = a - b;

        norme_chiffres(i) = norm(c, p);
    end
    
    chiffre = 0;
    for i = 1:M
        if i ~= 1 && norme_chiffres(i) < norme_chiffres(chiffre+1)
            chiffre = i-1;
        end
    end
end