;Sobokan Like - Jouer un niveau
;

Enumeration File
  #JSONFile
EndEnumeration

Enumeration Font
  #FontGlobal
EndEnumeration

Enumeration Gadget
  #Restart
  #Level
  #LevelNames
EndEnumeration

;grille de 12 x 10 - Dimension d'une case 64 x 64
Global LevelName.s, SetX=12, SetY=10, Dim Grid(SetX, SetY), GridWidth = (SetX + 1) *64, GridHeight = (SetY + 1) *64, x, y

;Listes des niveaux
Global Dim LevelNames.s(0), Index.i=0, CountLevels.i

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

Declare Prologue()
Declare Update()
Declare SpritesLoad()
Declare SceneLoad()
Declare Exit()

Prologue()

Procedure Prologue()
  Protected Directory.s = GetCurrentDirectory() + "Levels\"
  Protected Image
  
  ;Initialisation
  InitSprite() : InitKeyboard() : InitMouse() : UsePNGImageDecoder()
  
  LoadFont(#FontGlobal, "", 16)
  SetGadgetFont(#PB_All, FontID(#FontGlobal))
  
  ;-Fenetre de l'application
  OpenWindow(0, 0, 0, GridWidth, GridHeight + 50, "Sokoban", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
  
  ;Bouton Replay
  CanvasGadget(#Restart, 20, GridHeight + 10, 32, 32)
  Image = LoadImage(#PB_Any, "Assets\Reset.png")
  StartDrawing(CanvasOutput(#Restart))
  DrawingMode(#PB_2DDrawing_AlphaBlend)
  DrawImage(ImageID(Image), 0, 0)
  StopDrawing()
  GadgetToolTip(#Restart, "Replay level")
    
  ;Affichage du niveau en cours 
  TextGadget(#Level, 100, GridHeight + 12, 150, 32, "")
  
  ;Liste des niveaux
  ComboBoxGadget(#LevelNames, GridWidth - 210, GridHeight + 10, 200, 32)
  
  ;-Triggers
  BindGadgetEvent(#Restart, @SceneLoad(), #PB_EventType_LeftClick)
  BindGadgetEvent(#LevelNames, @SceneLoad())
  
  ;Lecture de tous les niveaux
  If ExamineDirectory(0, Directory, "*.grid.json")  
    While NextDirectoryEntry(0)
      If DirectoryEntryType(0) = #PB_DirectoryEntry_File
        LevelNames(Index) =  DirectoryEntryName(0)
        AddGadgetItem(#LevelNames, -1, LevelNames(Index))
      EndIf
      Index + 1
      ReDim LevelNames(Index)
    Wend
    FinishDirectory(0)
    
    Index = 0
    SetGadgetState(#LevelNames, 0)
    CountLevels = ArraySize(LevelNames())
          
    ;-[2D]
    OpenWindowedScreen(WindowID(0), 0, 0, GridWidth, GridHeight) 
    SpritesLoad()  
    SceneLoad()
    Update() 
  EndIf
  
  Exit()
EndProcedure

Procedure Update()
  Repeat 
    Repeat 
      Event = WindowEvent()
      
      Select Event    
        Case #PB_Event_CloseWindow
           Exit()
      EndSelect  
    Until Event=0
    
    ClearScreen(RGB(101, 159, 62))
    ExamineKeyboard()
    
    ;-Mémorisation de la position courante du gardien
    With Player
      \ox = \x
      \oy = \y
    EndWith
    
    ;-Déplacement du gardien 
    ; On ne se préocupe pas de ce qui se trouve de part et d'autres du gardien
    
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
    
    ;- Collision du gardien avec un mur ou une caisse 
    With Player
      ;On connait l'ancienne position du joueur (\ox & \oy)
      
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
    
    For x=0 To SetX
      For y=0 To SetY
        If Grid(x,y) = 3 ;Caisse correctement posée
          Player\CountSucess + 1
        EndIf
        
        DisplayTransparentSprite(Grid(x,y), x*64, y*64)
      Next
    Next
    
    ;-Affichage du joueur
    ;La position du joueur est affichée dans le titre de la fenetre
    SetWindowTitle(0, "Sokoban Like")
    DisplayTransparentSprite(Player\Direction, Player\x * 64, Player\y* 64)
    
    FlipBuffers()
    
    If Player\CountTargets = Player\CountSucess 
      If Index < ArraySize(LevelNames()) - 1
        Index + 1
        SetGadgetState(#LevelNames, Index)
        SceneLoad()
      Else
        Debug "Vous avez gagné"
        End
       EndIf   
    EndIf
    
  Until KeyboardPushed(#PB_Key_Escape)
EndProcedure

Procedure SpritesLoad()
  ;Chargement deq sprites
  UsePNGImageDecoder()
  
  ;Fond vert
  LoadSprite(0, "Assets\GroundGravel_Grass.png", #PB_Sprite_AlphaBlending)
  
  ;Mur
  LoadSprite(1, "Assets\WallRound_Black.png", #PB_Sprite_AlphaBlending)
  
  ;Caisse 
  LoadSprite(2, "Assets\Crate_Yellow.png", #PB_Sprite_AlphaBlending)  ;Caisse à pousser
  LoadSprite(3, "Assets\Crate_Red.png", #PB_Sprite_AlphaBlending)     ;Caisse sur la cible
  
  ;Cible
  LoadSprite(8, "Assets\EndPoint_Yellow.png", #PB_Sprite_AlphaBlending)
  
  ;Joueur à gauche
  LoadSprite(10, "Assets\Character1.png", #PB_Sprite_AlphaBlending)
  
  ;Joueur à droite
  LoadSprite(11, "Assets\Character2.png", #PB_Sprite_AlphaBlending)
  
  ;Joueur vers le bas
  LoadSprite(12, "Assets\Character4.png", #PB_Sprite_AlphaBlending)
  
  ;Joueur vers le haut
  LoadSprite(13, "Assets\Character7.png", #PB_Sprite_AlphaBlending)
EndProcedure 

Procedure SceneLoad()
  Index = GetGadgetState(#LevelNames)
  LevelName =  GetCurrentDirectory() + "Levels\" + StringField(LevelNames(Index), 1, ".")
  
  SetGadgetText(#Level, "Level " + Str(Index + 1) + "/" + Str(CountLevels))
    
  If ReadFile(#JSONFile, LevelName + ".grid.json")
    CloseFile(#JSONFile)
    
    LoadJSON(#JSONFile, LevelName + ".grid.json", #PB_JSON_NoCase)
    ExtractJSONArray(JSONValue(#JSONFile), Grid())
    
    LoadJSON(#JSONFile, LevelName + ".setup.json", #PB_JSON_NoCase)
    ExtractJSONStructure(JSONValue(#JSONFile), Player, NewSprite)
  EndIf
SetActiveGadget(#Level)  
EndProcedure

Procedure Exit()
  End
EndProcedure

; IDE Options = PureBasic 5.42 Beta 3 LTS (Windows - x86)
; CursorPosition = 317
; FirstLine = 291
; Folding = -
; EnableUnicode
; EnableXP