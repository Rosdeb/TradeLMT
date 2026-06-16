!include "MUI2.nsh"

Name "TradeLMT"
OutFile "TradeLMT_Setup.exe"
InstallDir "$PROGRAMFILES64\TradeLMT"
RequestExecutionLevel admin

!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

Section "Install"
  SetOutPath "$INSTDIR"

  ; সব files copy করো
  File /r "build\windows\x64\runner\Release\*.*"

  ; Desktop shortcut
  CreateShortcut "$DESKTOP\TradeLMT.lnk" "$INSTDIR\tradelmt.exe"

  ; Start Menu shortcut
  CreateDirectory "$SMPROGRAMS\TradeLMT"
  CreateShortcut "$SMPROGRAMS\TradeLMT\TradeLMT.lnk" "$INSTDIR\tradelmt.exe"

  ; Uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Uninstall"
  Delete "$INSTDIR\*.*"
  RMDir /r "$INSTDIR"
  Delete "$DESKTOP\TradeLMT.lnk"
  RMDir /r "$SMPROGRAMS\TradeLMT"
SectionEnd