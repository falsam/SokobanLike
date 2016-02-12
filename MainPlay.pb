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
  CountTargets.i    ;Nombre de cible crée par le joueur
EndStructure
Global Player.NewSprite

;Initialisation
InitSprite() : InitKeyboard() : InitMouse()

;Creation du screen
OpenWindow(0, 0, 0, GridWidth, GridHeight, "", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, GridWidth, GridHeight)

;Chargement deq sprites
UsePNGImageDecoder()

;Fond vert : Il doit porter l'identifiant 0 
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
  
  FlipBuffers()
  ClearScreen(RGB(101, 159, 62))
  ExamineKeyboard()
  
  ;Mémorisation de la position courante du joueur
  With Player
    \ox = \x
    \oy = \y
  EndWith
  
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
  
  ;Collision joueur avec un mur ou une caisse
  With Player
    ;Collision avec un Mur ou avec une caisse bien placé
    If Grid(\x, \y) = 1 Or Grid(\x, \y) = 3 
      \x = \ox
      \y = \oy
    EndIf
    
    ;Collision avec une caisse
    ;Le joueur doit se trouver dans 
    If Grid(\x, \y) = 2  
      Select \Direction
        Case 10 ;Pousser la caisse vers la gauche
          If Player\x > 0 ;Le joueur ne doit pas essayer de pousser la caisee en 
            If Grid(\x - 1, \y) = 0
              Grid(\x, \y) = 0
              Grid(\x - 1 , \y) = 2
              
            ElseIf Grid(\x - 1 , \y) = 8
              Grid(\x, \y) = 0
              Grid(\x - 1, \y) = 3 
              
            Else
              \x = \ox
              \y = \oy        
            EndIf
          Else
            \x = \ox
          EndIf
          
        Case 11 ;Pousser la caisse vers la droite
          If Player\x < 12 ;Le joueur est il en limite de screen ?
            If Grid(\x + 1, \y) = 0 And Player\x < 12
              Grid(\x, \y) = 0
              Grid(\x + 1 , \y) = 2
              
            ElseIf Grid(\x + 1 , \y) = 8
              Grid(\x, \y) = 0
              Grid(\x + 1, \y) = 3
              
            Else
              \x = \ox
              \y = \oy        
            EndIf
          Else
            \x = \ox
          EndIf
          
        Case 12 ;Pousser la caisse vers le bas
          If Player\y < 12 ;Le joueur est il en limite de screen ?
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
            
          Else  ;Le joueur pousse la caisse en dehors des limites du jeu
            \y = \oy
          EndIf
          
        Case 13 ;Poussez la caisse vers le haut
          If Player\y > 0 ; Le joueur ne doit pas  en limite haute du screen
            If Grid(\x, \y - 1) = 0
              Grid(\x, \y) = 0
              Grid(\x, \y - 1) = 2
              
            ElseIf Grid(\x, \y - 1) = 8
              Grid(\x, \y) = 0
              Grid(\x, \y - 1) = 3    
            EndIf
          Else
            \y = \oy
          EndIf
      EndSelect 
    EndIf ;Fin test collision avec une caisse
  EndWith
  
  ;Affichage de la scene
  For x=0 To 12
    For y=0 To 12
      DisplayTransparentSprite(grid(x,y), x*64, y*64)
    Next
  Next
  
  ;Affichage du joueur
  SetWindowTitle(0, "Sobokan (" + Str(Player\x) + " - " + Str(Player\y) + ")")
  DisplayTransparentSprite(Player\Direction, Player\x * 64, Player\y* 64)
  
Until KeyboardPushed(#PB_Key_Escape)
; IDE Options = PureBasic 5.42 Beta 1 LTS (Windows - x86)
; CursorPosition = 212
; FirstLine = 160
; EnableUnicode
; EnableXP