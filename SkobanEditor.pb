;Sokoban Like - Editeur de niveau
;

EnableExplicit

Enumeration
  #JSONFile
EndEnumeration

Enumeration Window
  #MainForm
EndEnumeration

Enumeration Menu
  #MainMenu
  #SceneNew
  #SceneLoad
  #SceneRename
  #SceneSave
  #SceneDelete
  
  #EditorExit
EndEnumeration

Enumeration Gadget
  #CurrentPostion
EndEnumeration

Global ApplicationName.s = "Sokoban Scene Editor"

Global Event

;grille de 12 x 12 - Dimension d'une case 64 x 64
Global LevelName.s = "NewScene" ;Nom de scéne par défaut
Global SetX=12, SetY=10         ;Taille de la grille
Global Dim Grid(SetX, SetY), GridWidth = (SetX + 1) *64, GridHeight = (SetY + 1) *64, x, y ;Définition dela grille

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


;Plan du code
Declare Prologue()        ;Initialisation & Création des fenetres 
Declare Update()          ;Rendering 
Declare SpritesLoad()     ;Chargement des sprites
Declare SceneNew()        ;Nouvelle scéne
Declare SceneLoad()       ;Chargement d'une scéne
Declare SceneRename()     ;Renommer une scéne
Declare SceneSave()       ;Sauver une scéne
Declare SceneDelete()     ;Supprimer une scéne
Declare Exit()            ;Quitter l'application 

Prologue()

Procedure Prologue()
  
  ;-Fenetre de l'application
  OpenWindow(#MainForm, 0, 0, GridWidth, GridHeight + 50, ApplicationName + " - " + LevelName , #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
  
  CreateMenu(#MainMenu, WindowID(#MainForm))
  MenuTitle("Fichier")
  MenuItem(#SceneNew, "Nouvelle Scéne" + Chr(9) + "Ctrl+N")
  MenuItem(#SceneLoad, "Ouvrir une scéne" + Chr(9) + "Ctrl+O")
  MenuItem(#SceneRename, "Renommer une scéne" + Chr(9) + "F2")
  MenuItem(#SceneSave, "Sauver une scéne" + Chr(9) + "Ctrl+S")
  MenuItem(#SceneDelete, "Supprimer une scéne")
  MenuBar()
  MenuItem(#EditorExit, "Quitter" + Chr(9) + "Esc")
  
  TextGadget(#CurrentPostion, 10, GridHeight + 10, 150, 25, "")
  
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control|#PB_Shortcut_N, #SceneNew)  
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control|#PB_Shortcut_O, #SceneLoad)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_F2, #SceneRename)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control|#PB_Shortcut_S, #SceneSave)        
  
  BindMenuEvent(#MainMenu, #SceneNew, @SceneNew())
  BindMenuEvent(#MainMenu, #SceneLoad, @SceneLoad())
  BindMenuEvent(#MainMenu, #SceneRename, @SceneRename())
  BindMenuEvent(#MainMenu, #SceneSave, @SceneSave())
  BindMenuEvent(#MainMenu, #SceneDelete, @SceneDelete())
  BindMenuEvent(#MainMenu, #EditorExit, @Exit())
  
  ;-Fenetre 2D
  InitSprite() : InitKeyboard() : InitMouse()
  OpenWindowedScreen(WindowID(0), 0, 0, GridWidth, GridHeight)
  
  SpritesLoad() ;Chargement des sprites
  
  Player\Direction = 11 ;Gardien par défaut Vers la droite
  
  Update() ;Rendering
  
  Exit() 
EndProcedure

Procedure Update()
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
    
    If KeyboardReleased(#PB_Key_Left) And Player\x > 0
      Player\x - 1
      Player\Direction = 10
      SetWindowData(#MainForm, #True)
    EndIf  
    
    If KeyboardReleased(#PB_Key_Right) And Player\x < SetX
      Player\x + 1
      Player\Direction = 11
      SetWindowData(#MainForm, #True)
    EndIf
    
    If KeyboardReleased(#PB_Key_Down) And Player\y < SetY
      Player\y + 1
      Player\Direction = 12
      SetWindowData(#MainForm, #True)
    EndIf
    
    If KeyboardReleased(#PB_Key_Up) And Player\y > 0
      Player\y - 1
      Player\Direction = 13
      SetWindowData(#MainForm, #True)
    EndIf
    
    ;-Création du décors
    
    ;Creation mur (Sprite id 1)
    If KeyboardReleased(#PB_Key_1) Or KeyboardReleased(#PB_Key_Pad1)
      Grid(Player\x, Player\y) = 1
      SetWindowData(#MainForm, #True)
    EndIf
    
    ;Creation caisse (Sprite id 2)
    If KeyboardReleased(#PB_Key_2) Or KeyboardReleased(#PB_Key_Pad2)
      Grid(Player\x, Player\y) = 2
      SetWindowData(#MainForm, #True)
    EndIf
    
    ;Creation cible (Sprite id 8)
    If KeyboardReleased(#PB_Key_8) Or KeyboardReleased(#PB_Key_Pad8)
      Grid(Player\x, Player\y) = 8
      SetWindowData(#MainForm, #True)
    EndIf  
    
    ;Creation cible (Sprite id 9)
    If KeyboardReleased(#PB_Key_9) Or KeyboardReleased(#PB_Key_Pad9)
      Grid(Player\x, Player\y) = 3
      SetWindowData(#MainForm, #True)
    EndIf  
    
    ;Suppression d'un élément de décors
    If KeyboardReleased(#PB_Key_Delete)
      Grid(Player\x, Player\y) = 0
      SetWindowData(#MainForm, #True)
    EndIf
    
    ;Affichage de la scene
    For x=0 To SetX
      For y=0 To SetY
        DisplayTransparentSprite(grid(x,y), x*64, y*64)
      Next
    Next
    
    ;Affichage du joueur
    SetGadgetText(#CurrentPostion, "Position: " + Str(Player\x) + " - " + Str(Player\y))
    DisplayTransparentSprite(Player\Direction, Player\x * 64, Player\y * 64)
    
    FlipBuffers()
  Until KeyboardPushed(#PB_Key_Escape)
EndProcedure

;Chargement des sprites
Procedure SpritesLoad()
  UsePNGImageDecoder()
  
  ;Fond vert 
  LoadSprite(0, "Assets\GroundGravel_Grass.png", #PB_Sprite_AlphaBlending)
  
  ;Mur
  LoadSprite(1, "Assets\WallRound_Black.png", #PB_Sprite_AlphaBlending)
  
  ;Caisse
  LoadSprite(2, "Assets\Crate_Yellow.png", #PB_Sprite_AlphaBlending)
  LoadSprite(3, "Assets\Crate_Red.png", #PB_Sprite_AlphaBlending)
  
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

Procedure SceneNew()
  Protected x, y, Buffer.s = LevelName
  
  LevelName = InputRequester("Nouvelle scéne", "Nom de la scéne", LevelName)
  
  If LevelName
    For x = 0 To SetX
      For y = 0 To SetY
        Grid(x, y) = 0
      Next
    Next
    
    ;Gardien par défaut Vers la droite en position 0, 0 
    Player\x = 0
    Player\y = 0
    Player\Direction = 11
  Else
    LevelName = Buffer
  EndIf 
EndProcedure

Procedure SceneLoad()
  Protected Buffer.s = LevelName
  
  LevelName = OpenFileRequester("Open a scene", LevelName  , "Scene (*.grid.json)|*.grid.json", 0)
  
  If LevelName And ReadFile(#JSONFile, LevelName)
    CloseFile(#JSONFile)
    
    LevelName = StringField(GetFilePart(LevelName), 1, ".")
    
    LoadJSON(#JSONFile, GetCurrentDirectory() + "Levels\" + LevelName + ".grid.json", #PB_JSON_NoCase)
    ExtractJSONArray(JSONValue(#JSONFile), Grid())
    
    LoadJSON(#JSONFile, GetCurrentDirectory() + "Levels\" + LevelName + ".setup.json", #PB_JSON_NoCase)
    ExtractJSONStructure(JSONValue(#JSONFile), Player, NewSprite)
    
    SetWindowTitle(#MainForm, ApplicationName + " - Niveau : " + LevelName)
    
    ProcedureReturn #True
  Else
    LevelName = Buffer
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure SceneRename()
  Protected Buffer.s = LevelName
  
  LevelName = InputRequester("Renommer une scéne", "Donner un nouveau nom à la scéne " + LevelName, LevelName)
  
  If LevelName 
    If ReadFile(#JSONFile, GetCurrentDirectory() + "Levels\" + LevelName + ".grid.json" )
      If MessageRequester("Information", "Cette scéne existe déja" + #CRLF$ + "Elle sera sauvegardée sous ce nom", #PB_MessageRequester_YesNo) = #PB_MessageRequester_No
        LevelName = ""
      EndIf
    EndIf
  Else
    LevelName = Buffer
  EndIf
  If LevelName
    SceneSave()
  EndIf
  
EndProcedure  

Procedure SceneSave()
  ;Sauvegarde de la position du gardien
  ;Sauvegarde du nombre de cibles crées ou de caisses sur le ou les cibles
  Player\CountTargets = 0
  
  For x=0 To SetX
    For y=0 To SetY    
      ;Le gardien est il dans un espace dégagé
      If x = Player\x And y = Player\y And (Grid(x, y) = 1 Or Grid(x, y) = 2)
        MessageRequester("Information", "Le gardien ne se trouve pas dans un espace dégagé.")
      EndIf
      
      ;Une cible a été crée
      If Grid(x, y) = 8 Or Grid(x, y) = 3 
        Player\CountTargets + 1
      EndIf
    Next
  Next
  
  CreateJSON(#JSONFile)
  
  ;Sauvegarde de la grille
  InsertJSONArray(JSONValue(#JSONFile), Grid())
  SaveJSON(#JSONFile, GetCurrentDirectory() + "Levels\" + LevelName + ".grid.json")
  
  ;Sauvegarde des parametres du joueur
  InsertJSONStructure(JSONValue(#JSONFile), Player, NewSprite)
  SaveJSON(#JSONFile, GetCurrentDirectory() + "Levels\" + LevelName+ ".setup.json")
  
  SetWindowTitle(#MainForm, ApplicationName + " - Niveau : " + LevelName)
  SetWindowData(#MainForm, #False)
EndProcedure

Procedure SceneDelete()
  Protected Buffer.s = LevelName
  
  LevelName = OpenFileRequester("Open a scene", LevelName  , "Scene (*.grid.json)|*.grid.json", 0)
  
  If LevelName
    LevelName = StringField(GetFilePart(LevelName), 1, ".")
    
    DeleteFile(GetCurrentDirectory() + "Levels\" + LevelName + ".grid.json")    
    DeleteFile(GetCurrentDirectory() + "Levels\" + LevelName + ".setup.json")
  EndIf
  
  If LevelName = Buffer
    ;La scene en cours d'édition n'existe plus sur disque
    ;La sauvegarde devra etre faite
    SetWindowData(#MainForm, #True)
  EndIf 
  
  LevelName = Buffer
EndProcedure


Procedure Exit()
  If GetWindowData(#MainForm) = #True
    If MessageRequester("Information", "Voulez vous sauvegarder le niveau " + LevelName + " ?", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
      SceneSave()
    EndIf
  EndIf
  End
EndProcedure
; IDE Options = PureBasic 5.42 Beta 3 LTS (Windows - x86)
; CursorPosition = 208
; FirstLine = 198
; Folding = --
; EnableUnicode
; EnableXP