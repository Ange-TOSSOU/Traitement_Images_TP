% 8-

function [CavitesDilate, Cavites] = cavite(I)
    % Récupérer les éléments structurants nord à ouest
    strel_nord = structurant_nord(I);
    strel_est = structurant_est(I);
    strel_sud = structurant_sud(I);
    strel_ouest = structurant_ouest(I);

    % Dilater l'image avec chaque élément structurant de nord à ouest
    I_est_dilate = imdilate(I, strel_est);
    I_ouest_dilate = imdilate(I, strel_ouest);
    I_nord_dilate = imdilate(I, strel_nord);
    I_sud_dilate = imdilate(I, strel_sud);

    % Initialiser les cavités dilatés à retourner
    myKeys = ["est" "sud" "ouest" "nord"];
    myValues = {I_est_dilate, I_sud_dilate, I_ouest_dilate, I_nord_dilate};
    CavitesDilate = containers.Map(myKeys, myValues);

    % Déterminer les cavités nord à ouest
    I_rencontre_vers_ouest = I_est_dilate;
    I_rencontre_vers_est = I_ouest_dilate;
    I_rencontre_vers_nord = I_sud_dilate;
    I_rencontre_vers_sud = I_nord_dilate;

    I_nord = ~I & I_rencontre_vers_est & I_rencontre_vers_ouest & ~I_rencontre_vers_nord & I_rencontre_vers_sud;
    I_est = ~I & ~I_rencontre_vers_est & I_rencontre_vers_ouest & I_rencontre_vers_nord & I_rencontre_vers_sud;
    I_sud = ~I & I_rencontre_vers_est & I_rencontre_vers_ouest & I_rencontre_vers_nord & ~I_rencontre_vers_sud;
    I_ouest = ~I & I_rencontre_vers_est & ~I_rencontre_vers_ouest & I_rencontre_vers_nord & I_rencontre_vers_sud;
    I_central = ~I & I_rencontre_vers_est & I_rencontre_vers_ouest & I_rencontre_vers_nord & I_rencontre_vers_sud;

    % Initialiser les cavités à retourner
    myKeys = ["est" "sud" "ouest" "nord" "central"];
    myValues = {I_est, I_sud, I_ouest, I_nord, I_central};
    Cavites = containers.Map(myKeys, myValues);
end

% Définir l'élément structurant nord
function struct_nord = structurant_nord(I)
    taille = size(I);

    struct_nord = strel('arbitrary', vertcat(ones(taille(2)+1, 1), zeros(taille(2), 1)));
end

% Définir l'élément structurant est
function struct_est = structurant_est(I)
    taille = size(I);

    struct_est = strel('arbitrary', [zeros(1, taille(2)) ones(1, taille(2)+1)]);
end

% Définir l'élément structurant sud
function struct_sud = structurant_sud(I)
    taille = size(I);

    struct_sud = strel('arbitrary', vertcat(zeros(taille(1), 1), ones(taille(1)+1, 1)));
end

% Définir l'élément structurant ouest
function struct_ouest = structurant_ouest(I)
    taille = size(I);

    struct_ouest = strel('arbitrary', [ones(1, taille(1)+1) zeros(1, taille(1))]);
end
