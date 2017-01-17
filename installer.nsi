;NSIS Modern User Interface
;Welcome/Finish Page Example Script
;Written by Joost Verburg

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

  !define MUI_ICON "logo.ico"
  !define MUI_UNICON "logo.ico"
  !define MUI_SPECIALBITMAP "logo.bmp"
  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP "logo.bmp"
  !define MUI_HEADERIMAGE_RIGHT

;--------------------------------
;General

	!include "Registry.nsh"
	!include "WordFunc.nsh"
	!include "LogicLib.nsh"
  !include "WordFunc.nsh"

  !insertmacro WordAdd
  !insertmacro un.WordAdd

  !define REG_ENVIRONMENT "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"

  !include WinCore.nsh
	 

  ;Name and file
  Name "Nova"
  OutFile "NovaInstaller.exe"

  ;Default installation folder
  InstallDir "$PROGRAMFILES64\Nova"

  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\Nova" ""

  ;Request application privileges for Windows Vista
  RequestExecutionLevel admin

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "License.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH


!macro DualUseFunctions_ un_
  function ${un_}SetPathVar
  # stack top: <'string to add'> / <AppendFlag>
  Exch $0 ; new string
  Exch
  Exch $1 ; append = 2, prefix = 1, remove = 0
  Push $R0  ; saved working registers

  ReadRegStr $R0 HKLM "${REG_ENVIRONMENT}" "Path"

  ${Select} $1
  ${Case} 0
  ${${un_}WordAdd} "$R0" ";" "-$0" $R0
  ${Case} 1
  ${${un_}WordAdd} "$0" ";" "+$R0" $R0
  ${Case} 2
  ${${un_}WordAdd} "$R0" ";" "+$0" $R0
  ${EndSelect}

  WriteRegExpandStr HKLM "${REG_ENVIRONMENT}" "Path" "$R0"
  System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("PATH", R0).r2'

  Pop $R0 ; restore registers
  Pop $1
  Pop $0
  functionEnd
!macroend
  
!insertmacro DualUseFunctions_ ""
!insertmacro DualUseFunctions_ "un."

Function displayPath
  ReadRegStr $R0 HKLM "${REG_ENVIRONMENT}" "Path"
  MessageBox MB_OK $R0
FunctionEnd

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections

Section "Dummy Section" SecDummy

  SetOutPath "$INSTDIR"

  ;ADD YOUR OWN FILES HERE...
  FILE /r "bin"
  FILE /r /x *.git /x *.gitignore /x *.o /x *.d "..\StandardLibrary"

  ;Store installation folder
  WriteRegStr HKCU "Software\Nova" "" $INSTDIR

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  
	Push 1 ; 1 = append.
  Push "$INSTDIR\bin"
  call displayPath
  Call SetPathVar
  call displayPath

SectionEnd

;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_SecDummy ${LANG_ENGLISH} "A test section."

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDummy} $(DESC_SecDummy)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"
  ;ADD YOUR OWN FILES HERE...
  
  RMDir /r "$INSTDIR\bin"
  RMDir /r "$INSTDIR\StandardLibrary"
  Delete "$INSTDIR\Uninstall.exe"

  RMDir "$INSTDIR"
  
  Push 0 ; 0 = remove
  Push "$INSTDIR\bin"
  Call Un.SetPathVar

  DeleteRegKey /ifempty HKCU "Software\Nova"

SectionEnd