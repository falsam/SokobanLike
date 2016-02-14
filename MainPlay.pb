;Sobokan Like - Jouer un niveau
;

Enumeration
  #JSONFile
EndEnumeration

;grille de 12 x 12 - Dimension d'une case 64 x 64
Global Dim Grid(12, 12), GridWidth = 13*64, GridHeight = 13*64

;Joueur
Structure NewSprite
  x.i               ;Position x
  y.i               ;Position y
  ox.i              ;Ancienne position x
  oy.i              ;Ancienne position y
  
  Direction.i       ;10 Vers la gauche, 11 Vers la droite, 12 Vers le bas, 13 Vers le haut 
  CountTargets.i    ;Nombre de cibles à atteindre
  CountSucess.i     ;Nombre de cibles couvertes par une caisse
EndStructure
Global Player.NewSprite

;Initialisation
InitSprite() : InitKeyboard() : InitMouse()

;Creation du screen
OpenWindow(0, 0, 0, GridWidth, GridHeight, "", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, GridWidth, GridHeight)

;Chargement deq sprites
UsePNGImageDecoder()

;Fond vert
LoadSprite(0, "assets\GroundGravel_Grass.png", #PB_Sprite_AlphaBlending)

;Mur
LoadSprite(1, "assets\WallRound_Black.png", #PB_Sprite_AlphaBlending)

;Caisse 
LoadSprite(2, "assets\Crate_Yellow.png", #PB_Sprite_AlphaBlending)  ;Caisse à pousser
LoadSprite(3, "assets\Crate_Red.png", #PB_Sprite_AlphaBlending)     ;Caisse sur la cible

;Cible
LoadSprite(8, "assets\EndPoint_Yellow.png", #PB_Sprite_AlphaBlending)

;Joueur à gauche
LoadSprite(10, "assets\Character1.png", #PB_Sprite_AlphaBlending)

;Joueur à droite
LoadSprite(11, "assets\Character2.png", #PB_Sprite_AlphaBlending)

;Joueur vers le bas
LoadSprite(12, "assets\Character4.png", #PB_Sprite_AlphaBlending)

;Joueur vers le haut
LoadSprite(13, "assets\Character7.png", #PB_Sprite_AlphaBlending)

;Mise en place d'une scene
If ReadFile(#JSONFile, "grid.json")
  CloseFile(#JSONFile)
  
  LoadJSON(#JSONFile, "grid.json", #PB_JSON_NoCase)
  ExtractJSONArray(JSONValue(#JSONFile), Grid())
  
  LoadJSON(#JSONFile, "gridsetup.json", #PB_JSON_NoCase)
  ExtractJSONStructure(JSONValue(#JSONFile), Player, NewSprite)
Else  
  
  ;Pas de fichier présent
  Player\Direction = 11
EndIf

;Boucle evenementielle
Repeat 
  Repeat 
    Event = WindowEvent()
    
    Select Event    
      Case #PB_Event_CloseWindow
        End
    EndSelect  
  Until Event=0
  
  ClearScreen(RGB(101, 159, 62))
  ExamineKeyboard()
  
  ;-Mémorisation de la position courante du joueur
  With Player
    \ox = \x
    \oy = \y
  EndWith
  
  ;-Déplacement du gardien (On ne se préocupe pas de ce qui se trouve de part et d'autres du gardien)
  
  ;Player se déplace vers la gauche
  If KeyboardReleased(#PB_Key_Left) And Player\x > 0
    Player\x - 1
    Player\Direction = 10
  EndIf  
  
  ;Player se déplace vers la droite
  If KeyboardReleased(#PB_Key_Right) And Player\x < 12
    Player\x + 1
    Player\Direction = 11
  EndIf
  
  ;Player se déplace vers le bas
  If KeyboardReleased(#PB_Key_Down) And Player\y < 12
    Player\y + 1
    Player\Direction = 12
  EndIf
  
  ;Player se déplace vers le haut
  If KeyboardReleased(#PB_Key_Up) And Player\y > 0 
    Player\y - 1
    Player\Direction = 13
  EndIf
  
  ;- Collision avec un mur ou une caisse 
  
  ;On connait l'ancienne position du joueur (\ox & \oy)
  
  With Player
    
    ;Si le niveau de la grille est bien fait, le périmetre de la grille ne devrait pas etre accessible par le gardien
    ;Toutefois un mur peut etre oublié ce qui oblige a ce test suivant préalable.
    If Player\x > 0 And Player\x < 12 And Player\y > 0 And  Player\y < 12
      
      ;Collision avec un Mur : Le gardien revient à sa position initiale (Le mur a l'identifiant 1)
      If Grid(\x, \y) = 1
        \x = \ox
        \y = \oy
      EndIf
      
      ;Collision avec une caisse à placer (La caisse a l'identifiant 2)
      If Grid(\x, \y) = 2  
        Select \Direction
            ;Le raisonnement pour la caisse pousée vers la gauche sera le meme principe pour les autres cas    
          Case 10 ;Pousser la caisse vers la gauche
            If Grid(\x - 1, \y) = 0 
              ;L'espace à gauche de la caisse est libre
              Grid(\x, \y) = 0 ;Oui : L'espace occupé par la caisse devient un espace libre
              Grid(\x - 1 , \y) = 2 ;L'espace libre situé à gauche de la caisse est maintenant occupé par la caisse 
              
            ElseIf Grid(\x - 1 , \y) = 8
              ;L'espace avant la caisse est une cible
              Grid(\x, \y) = 0 ;Oui : L'espace occupé par la caisse devient un espace libre
              Grid(\x - 1, \y) = 3 ;La cible situé à gauche de la caisse devient une caisse bien placé (Caisse rouge identifiant 3) 
              
            Else
              ;Cétait pas les cas précédents : Le gardien bute contre la caisse
              ;Il revient à sa position                 
              \x = \ox
              \y = \oy        
            EndIf
            
          Case 11 ;Pousser la caisse vers la droite
            If Grid(\x + 1, \y) = 0
              Grid(\x, \y) = 0
              Grid(\x + 1 , \y) = 2
              
            ElseIf Grid(\x + 1 , \y) = 8
              Grid(\x, \y) = 0
              Grid(\x + 1, \y) = 3
              
            Else
              \x = \ox
              \y = \oy        
            EndIf
            
          Case 12 ;Pousser la caisse vers le bas
            If Grid(\x, \y + 1) = 0
              Grid(\x, \y) = 0
              Grid(\x, \y + 1) = 2
              
            ElseIf Grid(\x, \y + 1) = 8
              Grid(\x, \y) = 0
              Grid(\x, \y + 1) = 3              
            Else
              \x = \ox
              \y = \oy        
            EndIf
            
          Case 13 ;Poussez la caisse vers le haut
            If Grid(\x, \y - 1) = 0
              Grid(\x, \y) = 0
              Grid(\x, \y - 1) = 2
              
            ElseIf Grid(\x, \y - 1) = 8
              Grid(\x, \y) = 0
              Grid(\x, \y - 1) = 3    
              
            Else
              \x = \ox
              \y = \oy        
            EndIf
        EndSelect 
      EndIf ;Fin test collision avec une caisse à placer sur une cible
      
      ;Collision avec une caisse bien placé 
      If Grid(\x, \y) = 3  
        Select \Direction
          Case 10 ;Pousser la caisse bien placée vers la gauche
            If Grid(\x - 1, \y) = 0
              Grid(\x, \y) = 8
              Grid(\x - 1 , \y) = 2
              
            ElseIf Grid(\x - 1 , \y) = 8
              Grid(\x, \y) = 8
              Grid(\x - 1, \y) = 3 
              
            Else
              \x = \ox
              \y = \oy        
            EndIf
            
          Case 11 ;Pousser la caisse bien placée vers la droite
            If Grid(\x + 1, \y) = 0 
              Grid(\x, \y) = 8
              Grid(\x + 1 , \y) = 2
              
            ElseIf Grid(\x + 1 , \y) = 8
              Grid(\x, \y) = 8
              Grid(\x + 1, \y) = 3
              
            Else
              \x = \ox
              \y = \oy        
            EndIf
            
          Case 12 ;Pousser la caisse bien placée vers le bas
            If Grid(\x, \y + 1) = 0
              Grid(\x, \y) = 8
              Grid(\x, \y + 1) = 2
              
            ElseIf Grid(\x, \y + 1) = 8
              Grid(\x, \y) = 8
              Grid(\x, \y + 1) = 3
              
            Else
              \x = \ox
              \y = \oy        
            EndIf
            
          Case 13 ;Poussez la caisse bien placée vers le haut
            If Grid(\x, \y - 1) = 0
              Grid(\x, \y) = 8
              Grid(\x, \y - 1) = 2
              
            ElseIf Grid(\x, \y - 1) = 8
              Grid(\x, \y) = 8
              Grid(\x, \y - 1) = 3    
              
            Else
              \x = \ox
              \y = \oy        
            EndIf
        EndSelect 
      EndIf ;Fin test collision avec une caisse bien placé
    Else 
      \x = \ox
      \y = \oy
    EndIf
    
  EndWith
  ;- Affichage de la scene
  Player\CountSucess = 0
  
  For x=0 To 12
    For y=0 To 12
      If Grid(x,y) = 3 ;Caisse correctement posée
        Player\CountSucess + 1
      EndIf
      
      DisplayTransparentSprite(Grid(x,y), x*64, y*64)
    Next
  Next
  
  ;-Affichage du joueur
  ;La position du joueur est affichée dans le titre de la fenetre
  SetWindowTitle(0, "Sobokan (" + Str(Player\x) + " - " + Str(Player\y) + ")")
  DisplayTransparentSprite(Player\Direction, Player\x * 64, Player\y* 64)
  
  FlipBuffers()
  
  If Player\CountTargets = Player\CountSucess 
    MessageRequester("Information","La mission est réussi")
    Break
  EndIf
  
Until KeyboardPushed(#PB_Key_Escape)
; IDE Options = PureBasic 5.42 Beta 1 LTS (Windows - x86)
; CursorPosition = 288
; FirstLine = 244
; EnableUnicode
; EnableXP