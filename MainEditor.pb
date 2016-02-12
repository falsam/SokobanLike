;Sobokan Like - Editeur de niveau
;

Enumeration
  #JSONFile
EndEnumeration

;grille de 12 x 12 - Dimension d'une case 64 x 64
Global Dim Grid(12, 12), GridWidth = 13*64, GridHeight = 13*64

;La grille est composé de 169 cases
;Chaque case contient une valeur correspondant à l'identificateur du sprite à afficher
; 0 : De l'herbe (valeur par défaut)
; 1 : Un mur
; 2 : Une caisse à déplacer
; 3 : Une caisse sur une cible 
; 8 : Une cible

;Joueur
Structure NewSprite
  x.i               ;Position x du joueur
  y.i               ;Position y du joueur
  Direction.i       ;Déplacement du joueur (Gauche=10, droite=11, bas=12, haut=13)
  CountTargets.i    ;Nombre de cible crée par le joueur
EndStructure
Global Player.NewSprite

;Initialisation
InitSprite() : InitKeyboard() : InitMouse()

;Creation du screen
OpenWindow(0, 0, 0, GridWidth, GridHeight, "Test", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, GridWidth, GridHeight)

;Chargement des sprites
UsePNGImageDecoder()

;Fond vert : Il doit porter l'identifiant 0 
LoadSprite(0, "assets\GroundGravel_Grass.png", #PB_Sprite_AlphaBlending)

;Mur
LoadSprite(1, "assets\WallRound_Black.png", #PB_Sprite_AlphaBlending)

;Caisse
LoadSprite(2, "assets\Crate_Yellow.png", #PB_Sprite_AlphaBlending)
LoadSprite(3, "assets\Crate_Red.png", #PB_Sprite_AlphaBlending)

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
  
  If KeyboardReleased(#PB_Key_Left) And Player\x > 0
    Player\x - 1
    Player\Direction = 10
  EndIf  
  
  If KeyboardReleased(#PB_Key_Right) And Player\x < 12
    Player\x + 1
    Player\Direction = 11
  EndIf
    
  If KeyboardReleased(#PB_Key_Down) And Player\y < 12
    Player\y + 1
    Player\Direction = 12
  EndIf
  
  If KeyboardReleased(#PB_Key_Up) And Player\y > 0
    Player\y - 1
    Player\Direction = 13
  EndIf
    
  ;-Création du décors
    
  ;Creation mur (Sprite id 1)
  If KeyboardReleased(#PB_Key_1) Or KeyboardReleased(#PB_Key_Pad1)
    Grid(Player\x, Player\y) = 1 
  EndIf
  
  ;Creation caisse (Sprite id 2)
  If KeyboardReleased(#PB_Key_2) Or KeyboardReleased(#PB_Key_Pad2)
    Grid(Player\x, Player\y) = 2 
  EndIf
  
  ;Creation cible (Sprite id 8)
  If KeyboardReleased(#PB_Key_8) Or KeyboardReleased(#PB_Key_Pad8)
    Grid(Player\x, Player\y) = 8 
  EndIf  
  
  ;Suppression d'un élément de décors
  If KeyboardReleased(#PB_Key_Delete)
    Grid(Player\x, Player\y) = 0 
  EndIf
    
  ;Affichage de la scene
  For x=0 To 12
    For y=0 To 12
      DisplayTransparentSprite(grid(x,y), x*64, y*64)
    Next
  Next
  
  ;Affichage du joueur
  SetWindowTitle(0, "Sobokan (" + Str(Player\x) + " - " + Str(Player\y) + ")")
  DisplayTransparentSprite(Player\Direction, Player\x * 64, Player\y * 64)
  
Until KeyboardPushed(#PB_Key_Escape)

;Sauvegarde de la grille et des parametres du joueur
;Le nom de sauvegarde est figé 
;Il est facile de créer une Interface pour saisir le nom du fichier

;Combien de cibles crées ?
Player\CountTargets = 0

For x=0 To 12
  For y=0 To 12
    If Grid(x, y) = 8
      Player\CountTargets + 1
    EndIf
  Next
Next

CreateJSON(#JSONFile)

;Sauvegarde de la grille 
InsertJSONArray(JSONValue(#JSONFile), Grid())
SaveJSON(#JSONFile, "grid.json")

;Sauvegarde des parametres du joueur
InsertJSONStructure(JSONValue(#JSONFile), Player, NewSprite)
SaveJSON(#JSONFile, "gridsetup.json")
; IDE Options = PureBasic 5.42 Beta 1 LTS (Windows - x86)
; CursorPosition = 161
; FirstLine = 132
; EnableUnicode
; EnableXP