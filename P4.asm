.Data

test1 DSW 1
test2 DSW 1
test3 DSW 1
test4 DSW 1

                grille DSW 35                   ;grille de 5x7 cases initialisé en blanc 
                hauteurBarreSuperieure DW 30
                nbLignes DW 5
                nbColonnes DW 7
                couleurCourante DW 0           ;0 jaune, 1 rouge
                colonneCourante DW 3           ;0-6 : colonne sur laquelle est la souris du joueur


                largeurColonnes DSW 1           ;largeur d une seule colonne 2d
                diametreCercle DSW 1            ;diametre cercle 2d
                margeCercleDansColonne DSW 1    ;marge entre le cercle et les cotes dans sa colonne 2d
                resultatAction DSW 1            ;resultat d une action : 0 pas de gagnant, 1 jeton implaçable, 2 puissance 4
                gagnant DW 2                    ;0 gagnant jaune, 1 gagnant rouge, 2 aucun gagnant
;PROGRAMME PRINCIPAL
.Code   
                ;Initialisations
LD R0, 0
ST R0, test1
ST R0, test2
ST R0, test3
ST R0, test4
                LEA SP, STACK
                CALL initVar
                CALL initAff 

                ;Debut partie
    bouclePartie:   LEA R0, colonneCourante     ;emplacement du resultat de la fonction
                    LD R1, 0                    ;Indique si la souris du joueur a change de colonne
                    LD R2, 0                    ;Indique si le joueur a cliqué
                    LD R3, 0                    ;Indique si le joueur a abandonné
                    LD R4, colonneCourante      ;Sauvegare de l ancienne colonne courante
                    CALL gereAction             ;R0, &R1, &R2, &R3 --> Met a jour la colonne courante et si une action a ete faites, indique laquelle 

        ifSouris:   CMP R1, 0
                    BEQ ifJoue                  ;Souris ne s est pas deplacee
                    PUSH R4                     ;ancienne colonnne courante
                    PUSH colonneCourante
                    CALL majAffColonnesSelectionnee

        ifJoue:     CMP R2, 1
                    BNE ifAbandon               ;Joueur ne joue pas
                    PUSH couleurCourante        ;couleur
                    PUSH colonneCourante        ;colonne
                    LEA R0, grille
                    PUSH R0                     ;@grille
                    LEA R0, resultatAction
                    PUSH R0                     ;@resultat jeux
                    LEA R0, gagnant
                    PUSH R0                     ;@gagnant
                    CALL tenteJouerJeton   

                    LEA R0, resultatAction
                    CMP [R0], 1
                    BEQ bouclePartie            ;jeton impossible a placer
                    CMP [R0], 2
                    BEQ finPartie               ;qqn gagne

                    ;changement de participant
                    LEA R0, couleurCourante
                    PUSH R0
                    CALL inverseCouleur

                    PUSH couleurCourante
                    CALL affBarreSuperieure

                    JMP bouclePartie

        ifAbandon:  CMP R3, 1                   
                    BNE bouclePartie            ;Abandon non souhaite

                ;Fin partie
    finPartie:      HLT


;SOUS-PROGRAMMES
;
;
;Initialisation
initVar:                PUSH R0
                        PUSH R1

                        LD R0, 0            ;iterateur
                        LEA R1, grille      ;emplacement premiere case de la grille
    boucleColoriage:    LD [R1], 2          ;Mise de la case en blanc
                        INC R0          
                        INC R1
                        CMP R0, 35
                        BLTU boucleColoriage

                        LD R0, 255          ;Largeur d une colonnne avec 2 decimales
                        MUL R0, 100         ;Transformation en decimal a 2 valeurs
                        DIV R0, nbColonnes  ;Calcul de la largeur d une colonne
                        INC R0              ;Ajout pour pas qu'il y ait une 7e colonne
                        ST R0, largeurColonnes

                        DIV R0, 10       ;Marge entre un cercle et le bord de sa colonne horizontalement
                        ST R0, margeCercleDansColonne

                        LD R1, largeurColonnes
                        MUL R0, 2       ;marges totales
                        SUB R1, R0      ;diametre cercle
                        ST R1, diametreCercle

                        LD R0, 0
                        OUT R0, 0
                        OUT R0, 6
                        OUT R0, 7
                        

                        PULL R1
                        PULL R0
                        RET

            
;
;
;Affichage
initAff:            PUSH R0                     ;Liberation de R0
                    LD R0, 0
                    OUT R0, 5                   ;Effacement console

                    CALL initAffFondBleu

                    PUSH couleurCourante        ;couleur de la barre
                    CALL affBarreSuperieure

                    CALL affInitJetons

                    PULL R0                     ;Recuperation de R0
                    RET

;Met le fond en bleu
initAffFondBleu:    LD R0, 0        ;Coord x et y du depart
                    OUT R0, 1
                    OUT R0, 2
                    LD R0, 255      ;Largeur et hauteur
                    OUT R0, 3
                    OUT R0, 4
                    LD R0, 69       ;Instruction : 64 (bleu fonce) + 5 (rectangle plein)
                    OUT R0, 5
                    RET

;couleur --> affiche la barre superieure de la couleur souhaitee
affBarreSuperieure:     LD R0, 0        ;x et y du point d origine
                            OUT R0, 1
                            OUT R0, 2
                            LD R0, 255      ;largeur
                            OUT R0, 3
                            LD R0, hauteurBarreSuperieure
                            OUT R0, 4
                            LD R0, [SP+1]   ;couleur courrante
                            CMP R0, 0
                            BEQ jaune
                            CMP R0, 1
                            BEQ rouge
                autre:      LD R0, $00      ;noir
                            JMP suite
                jaune:      LD R0, $E0      ;jaune
                            JMP suite
                rouge:      LD R0, $C0      ;rouge vif
                            
                
                suite:      ADD R0, $05     ;Instruction : rectangle plein
                            OUT R0, 5
                            RET 1

;Affiche tous les cercles en blanc
affInitJetons:          PUSH R0
                    LD R0, 0        ;Iterateur colonne
    boucleColonnes: PUSH R0             ;colonne
                    CALL affInitColonne
                    INC R0
                    CMP R0, nbColonnes
                    BLTU boucleColonnes
                    PULL R0
                    RET


;n° colonne --> initialise en blanc tous le jetons d une colonne
affInitColonne:     ; n° colonne
                    ; n° ligne
                    ; couleur
                    ; R1
                    ; R0
                    ; @
                    ; n° colonne

                    PUSH R0
                    PUSH R1
                    
                    LD R0, 0        ;Iterateur ligne
    boucleLigne:    LD R1, 2        ;Blanc
                    PUSH R1         ;couleur
                    PUSH R0         ;numero ligne
                    PUSH [SP+6]     ;ligne+couleur+R1+R0+@dresse+1(je comprend pas) : numero colonne


                    CALL affJeton
                    INC R0
                    CMP R0, 5
                    BLTU boucleLigne

                    PULL R1
                    PULL R0
                    
                    RET 1


; couleur (0, 1 ou autre), ligne, colonne --> affiche un cercle de la position et couleur voulue
affJeton:        PUSH R0

                    LD R0, [SP+2]                   ;numero colonne
                    MUL R0, largeurColonnes         ;coord x decimale
                    ADD R0, margeCercleDansColonne  ;ajout de la marge
                    DIV R0, 100                     ;passage en entier
                    OUT R0, 1

                    LD R0, [SP+3]                   ;numero ligne
                    
                    MUL R0, largeurColonnes         ;coord y decimale
                    ADD R0, margeCercleDansColonne  ;ajout de la marge
                    DIV R0, 100                     ;passage en entier
                    ADD R0, hauteurBarreSuperieure  ;ajout de la barre superieure
                    OUT R0, 2

                    LD R0, diametreCercle           ;diametre du cercle
                    DIV R0, 100                     ;passage en entier
                    OUT R0, 3
                    OUT R0, 4

                    LD R0, [SP+4]
                    CMP R0, 0
                    BEQ jaune1
                    CMP R0, 1
                    BEQ rouge1
    autre1:         LD R0, $F0      ;blanc
                    JMP suite1
    jaune1:         LD R0, $E0      ;jaune
                    JMP suite1
    rouge1:         LD R0, $C0      ;rouge vif
                           
    suite1:         ADD R0, $06     ;Instruction : cercle plein
                    OUT R0, 5                          

                    PULL R0
                    RET 3




;ancienne colonne courante,  nouvelle colonne --> Colore la colonne courrante et décolore l ancienne colonne selectionnee
majAffColonnesSelectionnee:      PUSH R0
                                ;R0
                                ;@
                                ;nouvelle colonne
                                ;ancienne colonne
                                
                                LD R0, 4                ;bleu fonce
                                PUSH R0
                                LD R0, [SP+4]           ;ancienne colonne
                                PUSH R0
                                CALL affBarresDelimitantes

                                LD R0, 0                ;noir
                                PUSH R0
                                LD R0, [SP+3]           ;nouvelle colonne
                                PUSH R0
                                CALL affBarresDelimitantes

    fin:                        PULL R0
                                RET 2


;
;
;couleur, colonne --> affiche une barre de la couleur souhaitee dans la colonne souhaitee
affBarresDelimitantes:      PUSH R0
							; R0
							; @
							; colonne
							; couleur
							
							;Coord x debut
							LD R0, [SP+2]                       ;n° colonne
							MUL R0, largeurColonnes         
							ADD R0, margeCercleDansColonne
							ADD R0, diametreCercle
							DIV R0, 100                         ;passage en entier
							OUT R0, 1
							;Coord y debut
							LD R0, hauteurBarreSuperieure
							OUT R0, 2
							;Largeur
							LD R0, margeCercleDansColonne   
							DIV R0, 100    
							OUT R0, 3
							;Hauteur
							LD R0, largeurColonnes              ;largeur colonne 2d -> hauteur 2d -> hauteur 
							MUL R0, nbLignes
                            DIV R0, 100
							OUT R0, 4
							;Couleur
							LD R0, [SP+3]                       ;couleur
							MUL R0, 16
							ADD R0, $05                         ;rectangle plein
							OUT R0, 5

							;Coord x debut
							LD R0, [SP+2]                       ;n° colonne
							MUL R0, largeurColonnes         
							DIV R0, 100                         ;passage en entier
							OUT R0, 1
							;Coord y debut
							LD R0, hauteurBarreSuperieure
							OUT R0, 2
							;Largeur
							LD R0, margeCercleDansColonne   
							DIV R0, 100    
							OUT R0, 3
							;Hauteur
							LD R0, largeurColonnes              ;largeur colonne 2d -> hauteur 2d -> hauteur 
							MUL R0, nbLignes
                            DIV R0, 100
							OUT R0, 4
							;Couleur
							LD R0, [SP+3]                       ;couleur
							MUL R0, 16
							ADD R0, $05                         ;rectangle plein
							OUT R0, 5

                            ;Coord x debut
							LD R0, [SP+2]                       ;n° colonne
							MUL R0, largeurColonnes     
							DIV R0, 100                         ;passage en entier
							OUT R0, 1
							;Coord y debut
                            LD R0, largeurColonnes
                            MUL R0, nbLignes
                            DIV R0, 100
							ADD R0, hauteurBarreSuperieure
							OUT R0, 2
							;Largeur
                            LD R0, margeCercleDansColonne
                            MUL R0, 2
                            ADD R0, diametreCercle
							DIV R0, 100    
							OUT R0, 3
							;Hauteur
							LD R0, margeCercleDansColonne
                            DIV R0, 100
							OUT R0, 4
							;Couleur
							LD R0, [SP+3]                       ;couleur
							MUL R0, 16
							ADD R0, $05                         ;rectangle plein
							OUT R0, 5



							PULL R0
							RET 2

;
;
;Modele
;met la colonne courante a jour en fonction de la position de la souris
majSelectionCol:    PUSH R2
                    IN R2, 6                ;Coord X souris
                    MUL R2, 100             ;Transformation en decimale
                    DIV R2, largeurColonnes ;Colonne survolee
                    CMP R2, [R0]            ;Si un changement a eu lieu
                    BEQ fin1          
                    LD [R0], R2             ;Mise a jour de la colonne courante
                    LD R1, 1                ;Met le booleen a juste
    fin1:           PULL R2
                    RET

;Gere l action du joueur : met a jour la colonne courante si la souris a bouge a met a jour les indicateurs. R1 : souris bougee, R2 : joueur joue (clic), R3 : abandon (B)
gereAction:         PUSH R4
                    CALL majSelectionCol    ;Met a jour la colonne courante
                    
                    IN R4, 0                ;Regarde si le joueur a fait quelque chose
                    CMP R4, 199             ;Clic gauche
                    BEQ joue
                    CMP R4, 134             ;B
                    BEQ abandon
                    JMP finProc
    joue:           LD R2, 1
                    JMP finProc
    abandon:        LD R3, 1
                    
    finProc:        PULL R4
                    RET 





;couleur, colonne, @grille, @resultatAction, @gagnant --> essaie de placer le jeton dans la grille, renvoie 0 s'il n'y a pas de gagnant et que le jeton a bien ete place, 1 si le jeton n'a pas pu etre place et 2 si un joueur a gagné et change le joueur dans le cas échéant
tenteJouerJeton:	    ;
                        ;R1
						;R0
						;@RETOUR
                        ;@gagnant
						;@resultatAction
						;@grille
						;n° colonne
						;couleur jeton					
						
						PUSH R0
						PUSH R1

						LD R0, [SP+6]	        ;n° colonne --> @dernier jeton colonne --> @case premiere case libre de la colonne 
						MUL R0, nbLignes        ; * nombre de jetons sur une colonne
						ADD R0, [SP+5]	        ; + emplacement grille
						CMP [R0], 2		        ;regarde si le dernier jeton est blanc
						BNE jetonNonPlacable
	jetonPlacable:		;recherche du premier emplacement libre dans la colonne
						ADD R0, 4
	boucle:				CMP [R0], 2         ;boucle pour rechercher la premiere case libre
						BEQ suite2
						DEC R0
						JMP boucle
    suite2:             ;ajout dans la grille
                        LD [R0], [SP+7]         ;couleur jeton
						;affichage
						PUSH [R0]				;couleur
						SUB R0, [SP+6]          ; - @grille
    while%:             CMP R0, nbLignes        ;Division euclidienne par 5 pour avoir la ligne exacte
                        BLTU suite3
						SUB R0, nbLignes
                        JMP while%        
    suite3:             PUSH R0                 ;n° ligne
						PUSH [SP+9]				;n° colonne
						CALL affJeton
                        ;regarde si un joueur a gagne
                        PUSH R0                 ;n° ligne
                        PUSH [SP+8]             ;n° colonne
                        PUSH [SP+8]             ;@grille
                        PUSH [SP+7]             ;@gagnant
                        CALL partieFinie

                        LD R0, [SP+3]           ;@gagnant
                        LD R1, [SP+4]           ;@resultatAction
                        LD [R1], 0
                        CMP [R0], 2
                        BEQ pasDeGagnant
                        LD [R1], 2
    pasDeGagnant:       JMP suite4

	jetonNonPlacable:	LD R1, [SP+4]           ;@resultatAction
                        LD [R1], 1				;colonne pleine


    suite4:             PULL R1
						PULL R0
						RET 5

;@couleur courante --> Inverse la couleur courante
inverseCouleur:     PUSH R0
                    LD R0, [SP+2]   ;@couleur courante
                    CMP [R0], 0
                    BEQ jaune2
    rouge2:         LD [R0], 0
                    JMP fin2
    jaune2:         LD [R0], 1
    fin2:           PULL R0
                    RET 1



;ligne, colonnne, @grille, @gagnant --> Regarde si un joueur a gagne et met a jour la variable gagnant en consequent
partieFinie:        ;colonne
                    ;ligne
                    ;R6             <-- SP
                    ;R5
                    ;R4
                    ;R3
                    ;R2
                    ;R1
                    ;R0
                    ;@
                    ;@gagnant
                    ;@grille
                    ;colonneJeton
                    ;ligneJeton

                    PUSH R0
                    PUSH R1
                    PUSH R2         ;Colonne minimum
                    PUSH R3         ;Colonne maximum
                    PUSH R4         ;Ligne minimum
                    PUSH R5         ;Ligne maximum
                    PUSH R6         ;nombre de jetons de la meme couleur a la suite

                    ; -- Initialisations -- 
                    LD R1, 0        ;s il y a puissance 4

                    ; -- Recherche dans toutes les directions --
    horizontale:    ; - Horizontale - 
                            ;Calcul de l intervalle de recherche
                            LD R0, [SP+10]      ;colonne
                            CMP R0, 2
                            BLEU  procheAGauche
                            LD R2, R0           ;colonne jeton --> -3
                            SUB R2, 3 
                            JMP suite5
        procheAGauche:      LD R2, 0
        suite5:             CMP R0, 4
                            BGEU  procheADroite
                            LD R3, R0            ;colonne jeton --> +3
                            ADD R3, 3 
                            JMP suite6
        procheADroite:      LD R3, 6      

                            ;Initiailisation d avant boucle
        suite6:             LD R6, 0

                            ;Analyse
        boucleHorizontale:  CMP R2, R3
                            BGTU verticale
                            LD R0, [SP+9]       ;@grille --> couleur du jeton
                            PUSH [SP+12]        ;ligne
                            PUSH R2             ;colonne courante
                            CALL jeton
                            CMP R0, couleurCourante
                            BEQ memeCouleur
                            LD R6, 0
                            JMP suite7
        memeCouleur:        INC test2
                            INC R6 
        suite7:             CMP R6, 4
                            BEQ puissance
                            INC R2
                            JMP boucleHorizontale
                        
    verticale:      ; - Verticale -
                            ;Calcul de l intervalle de recherche
                            LD R4, 0            ;ligne min
                            LD R5, 4            ;ligne max
                            LD R0, [SP+11]      ;ligneJeton
                            CMP R0, 0
                            BEQ  procheEnHaut
                            CMP R0, 4
                            BEQ procheEnBas
                            JMP suite8
        procheEnHaut:       LD R5, 3
                            JMP suite8
        procheEnBas:        LD R4, 1

                            ;Initiailisation d avant boucle
        suite8:             LD R6, 0

                            ;Analyse
        boucleVerticale:  CMP R4, R5
                            BGTU diagonaleD
                            LD R0, [SP+9]       ;@grille --> couleur du jeton
                            PUSH R4             ;ligne courante
                            PUSH [SP+12]        ;colonne
                            CALL jeton
                            CMP R0, couleurCourante
                            BEQ memeCouleur1
                            LD R6, 0
                            JMP suite9
        memeCouleur1:       INC test2
                            INC R6 
        suite9:             CMP R6, 4
                            BEQ puissance
                            INC R4
                            JMP boucleVerticale
                        
    diagonaleD:     ; - Diagonale vers la droite -
                            ;Calcul de l intervalle de recherche
                            LD R0, [SP+10]      ;colonne courante
                            LD R1, [SP+11]      ;ligne courante
        essaiHG:            LD R2, R0           ;colonne minimum
                            LD R4, R1           ;ligne minimum
                            DEC R0
                            DEC R1
                            CMP R0, 6
                            BGTU suite10
                            CMP R1, 4
                            BGTU suite10
                            JMP essaiHG

        suite10:            LD R0, [SP+10]      ;colonne courante
                            LD R1, [SP+11]      ;ligne courante
        essaiBD:            LD R3, R0           ;colonne maximum
                            LD R5, R1           ;ligne maximum
                            INC R0
                            INC R1
                            CMP R0, 6
                            BGTU suite11
                            CMP R1, 4
                            BGTU suite11
                            JMP essaiBD
                            
        suite11:            ;Initiailisation d avant boucle
                            LD R6, 0

                            ;Analyse
        boucleDiagonaleD:   CMP R2, R3
                            BGTU diagonaleG
                            LD R0, [SP+9]       ;@grille --> couleur du jeton
                            PUSH R4             ;ligne courante
                            PUSH R2             ;colonne courante
                            CALL jeton
                            CMP R0, couleurCourante
                            BEQ memeCouleur2
                            LD R6, 0
                            JMP suite12
        memeCouleur2:       INC test2
                            INC R6 
        suite12:            CMP R6, 4
                            BEQ puissance
                            INC R2
                            INC R4
                            JMP boucleDiagonaleD
                        
    diagonaleG:     ; - Digaonale vers la gauche -
JMP finAnalyse
; ;                             ;Calcul de l intervalle de recherche
; ;                             LD R0, [SP+10]      ;colonne courante
; ;                             LD R1, [SP+11]      ;ligne courante
; ;         essaiBG:            LD R2, R0           ;colonne minimum
; ;                             LD R5, R1           ;ligne maximum
; ;                             DEC R0
; ;                             INC R1
; ;                             CMP R0, 6
; ;                             BGTU suite13
; ;                             CMP R1, 4
; ;                             BGTU suite13
; ;                             JMP essaiBG

; ;         suite13:            LD R0, [SP+10]      ;colonne courante
; ;                             LD R1, [SP+11]      ;ligne courante
; ;         essaiHD:            LD R3, R0           ;colonne maximum
; ;                             LD R4, R1           ;ligne minimum
; ;                             INC R0
; ;                             DEC R1
; ;                             CMP R0, 6
; ;                             BGTU suite14
; ;                             CMP R1, 4
; ;                             BGTU suite14
; ;                             JMP essaiHD

;         suite14:            
; ST R2, test1
; ST R3, test2
; ST R4, test3
; ST R5, test4
;                             ;Initiailisation d avant boucle
;                             LD R6, 0

;                             ;Analyse
;         boucleDiagonaleG:   CMP R2, R3
;                             BGTU finAnalyse
;                             LD R0, [SP+9]       ;@grille --> couleur du jeton
;                             PUSH R5             ;ligne courante
;                             PUSH R2             ;colonne courante
;                             CALL jeton
;                             CMP R0, couleurCourante
;                             BEQ memeCouleur3
;                             LD R6, 0
;                             JMP suite15
;         memeCouleur3:       INC test2
;                             INC R6 
;         suite15:            CMP R6, 4
;                             BEQ puissance
;                             INC R2
;                             INC R5
;                             JMP boucleDiagonaleG

    puissance:          LD R0, [SP+8]        ;@gagnant
                        LD [R0], couleurCourante


                        ; -- Fin --
    finAnalyse:         PULL R6
                        PULL R5
                        PULL R4
                        PULL R3
                        PULL R2
                        PULL R1
                        PULL R0
                        RET 4


;R0 (@grille), ligne, colonne --> renvoie dans R0 le jeton a la colonne et la ligne en parametres
jeton:                  ;R1
                        ;@
                        ;colonne
                        ;ligne
                        PUSH R1
                        LD R1, [SP+2]       ;colonne -> ... -> jeton
                        MUL R1, nbLignes    ; * nbLignes
                        ADD R1, [SP+3]      ; + ligne
                        ADD R1, R0      ; + @grille
                        LD R0, [R1]
                        PULL R1
                        RET 2
;
;
.Stack 30