[Setup]
AppName=TradeLMT
AppVersion=1.0.0
AppPublisher=Your Name
DefaultDirName={autopf}\TradeLMT
DefaultGroupName=TradeLMT
OutputDir=C:\Users\rosde\All Project\TradeLMT
OutputBaseFilename=TradeLMT_Setup
Compression=lzma
SolidCompression=yes
RequestExecutionLevel=admin

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"

[Files]
Source: "C:\Users\rosde\All Project\TradeLMT\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\TradeLMT"; Filename: "{app}\raminups.exe"
Name: "{commondesktop}\TradeLMT"; Filename: "{app}\raminups.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\raminups.exe"; Description: "Launch TradeLMT"; Flags: nowait postinstall skipifsilent