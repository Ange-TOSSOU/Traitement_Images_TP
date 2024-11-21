function chiffre = choix_voisin(Cavites, pourcentages, M, P, p)
    ancienne_norme = 0;
    for i = 1:M
        for j = 1:P
            a = [];
            b = [];
            for k = keys(Cavites)
                objet1 = Cavites(k{1});
                objet2 = objet1{i};
                a = [a objet2(j)];
                b = [b pourcentages(k{1})];
            end
            c = a - b;
            nouvelle_norme = norm(c, p);

            if i == 1 && j == 1
                ancienne_norme = nouvelle_norme;
                chiffre = i - 1;
            elseif nouvelle_norme < ancienne_norme
                ancienne_norme = nouvelle_norme;
                chiffre = i - 1;
            end
        end
    end
end