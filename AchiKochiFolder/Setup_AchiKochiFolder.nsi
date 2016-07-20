;ExperienceUI for NSIS
;Basic Example Script
;Written by Dan Fuhry

;OK, I cheated, Joost wrote it. :-)

;--------------------------------
;Include ExperienceUI

  !include "XPUI.nsh"

;--------------------------------
;General

  !define APP "AchiKochiFolder"
  !define TTL "あっちこっちフォルダ"
  !define COM "HIRAOKA HYPERS TOOLS, Inc."
  
  !system 'DefineAsmVer.exe "Release\${APP}.dll" "!define VER ""[SVER]"" " > Tmpver.nsh'
  !include "Tmpver.nsh"
  !searchreplace APV ${VER} "." "_"

  ;Name and file
  Name "${APP} ${VER}"
  OutFile "Setup_${APP}_${APV}.exe"

  ;Default installation folder
  InstallDir "$PROGRAMFILES\${APP}"
  
  ;Get installation folder from registry if available
  InstallDirRegKey HKLM "Software\${COM}\${APP}" "Install_Dir"

  RequestExecutionLevel admin

  !define DOTNET_VERSION "2.0"

  !include "DotNET.nsh"

  !include LogicLib.nsh
  !include x64.nsh
  
  SetOverwrite ifdiff

;--------------------------------
;Interface Settings

  !define XPUI_ABORTWARNING

;--------------------------------
;Pages

  ${LicensePage} "License.rtf"
  ${Page} Directory
  ${Page} Components
  ${Page} InstFiles

  ${UnPage} Welcome
  !insertmacro XPUI_PAGEMODE_UNINST
  !insertmacro XPUI_PAGE_UNINSTCONFIRM_NSIS
  !insertmacro XPUI_PAGE_INSTFILES

;--------------------------------
;Languages
 
  !insertmacro XPUI_LANGUAGE "English"

;--------------------------------
;Installer Sections

Section ""
  !insertmacro CheckDotNET ${DOTNET_VERSION}
SectionEnd

Section "x86版(32ビット版)" x86
  SetOutPath "$INSTDIR\x86"

  ;ADD YOUR OWN FILES HERE...
  File ".\release\AchiKochiFolder.dll"
  File ".\release\AchiKochiFolder.pdb"
  
  ExecWait 'REGSVR32.exe /s "$OUTDIR\AchiKochiFolder.dll"' $0
  DetailPrint "結果: $0"
SectionEnd

Section /o "x64版(64ビット版)" x64
  SetOutPath "$INSTDIR\x64"

  ;ADD YOUR OWN FILES HERE...
  File "x64\release\AchiKochiFolder.dll"
  File "x64\release\AchiKochiFolder.pdb"

  ExecWait 'REGSVR32.exe /s "$OUTDIR\AchiKochiFolder.dll"' $0
  DetailPrint "結果: $0"
SectionEnd

Section ""
  ; Write the installation path into the registry
  WriteRegStr HKLM "Software\${COM}\${APP}" "Install_Dir" "$INSTDIR"

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "DisplayName" "${TTL}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "NoRepair" 1
  WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

Section "設定支援ソフト" Settei
  SetOutPath "$INSTDIR\Settei"
  File "Settei\bin\DEBUG\*.*"

  CreateDirectory "$SMPROGRAMS\${TTL}"
  CreateShortCut  "$SMPROGRAMS\${TTL}\${TTL} 設定支援ソフト.lnk"   "$INSTDIR\Settei\Settei.exe" "$INSTDIR\Settei\Settei.exe"
  CreateShortCut  "$SMPROGRAMS\${TTL}\${TTL} アンインストール.lnk" "$INSTDIR\uninstall.exe"       "$INSTDIR\uninstall.exe"

  Exec '"$INSTDIR\Settei\Settei.exe"'
SectionEnd

Function .onInit
  ${If} ${RunningX64}
    SectionSetFlags ${x64} ${SF_SELECTED}
  ${Else}
    SectionSetFlags ${x64} 0
  ${EndIf}
FunctionEnd

;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_x86 ${LANG_ENGLISH} "32ビット版"
  LangString DESC_x64 ${LANG_ENGLISH} "64ビット版"
  LangString DESC_Settei ${LANG_ENGLISH} "${TTL} 設定支援ソフトを導入"

  ;Assign language strings to sections
  !insertmacro XPUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro XPUI_DESCRIPTION_TEXT ${x86} $(DESC_x86)
    !insertmacro XPUI_DESCRIPTION_TEXT ${x64} $(DESC_x64)
    !insertmacro XPUI_DESCRIPTION_TEXT ${Settei} $(DESC_Settei)
  !insertmacro XPUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"
  ExecWait 'REGSVR32.exe /u /s "$INSTDIR\x86\AchiKochiFolder.dll"' $0
  DetailPrint "結果: $0"
  ExecWait 'REGSVR32.exe /u /s "$INSTDIR\x64\AchiKochiFolder.dll"' $0
  DetailPrint "結果: $0"

  ;ADD YOUR OWN FILES HERE...
  
  Delete /REBOOTOK "$INSTDIR\x86\AchiKochiFolder.dll"
  Delete /REBOOTOK "$INSTDIR\x86\AchiKochiFolder.pdb"
  Delete /REBOOTOK "$INSTDIR\x64\AchiKochiFolder.dll"
  Delete /REBOOTOK "$INSTDIR\x64\AchiKochiFolder.pdb"

  Delete "$INSTDIR\Settei\*.*"

  Delete "$SMPROGRAMS\Settei\${TTL} 設定支援ソフト.lnk"
  Delete "$SMPROGRAMS\Settei\${TTL} アンインストール.lnk"
  RMDir  "$SMPROGRAMS\Settei"

  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}"
  DeleteRegKey HKLM "Software\${COM}\${APP}"

  Delete "$INSTDIR\Uninstall.exe"

  RMDir "$INSTDIR\Settei"
  RMDir "$INSTDIR\x86"
  RMDir "$INSTDIR\x64"
  RMDir "$INSTDIR"
  
  IfRebootFlag 0 noreboot
    MessageBox MB_YESNO|MB_ICONEXCLAMATION "再起動が必要です。直ちに再起動しますか?" IDNO noreboot
      Reboot
  noreboot:
SectionEnd
