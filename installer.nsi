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
	!include LogicLib.nsh
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



Function RegAppendString
System::Store S
Pop $R0 ; append
Pop $R1 ; separator
Pop $R2 ; reg value
Pop $R3 ; reg path
Pop $R4 ; reg hkey
System::Call 'ADVAPI32::RegCreateKey(i$R4,tR3,*i.r1)i.r0'
${If} $0 = 0
    System::Call 'ADVAPI32::RegQueryValueEx(ir1,tR2,i0,*i.r2,i0,*i0r3)i.r0'
    ${If} $0 <> 0
        StrCpy $2 ${REG_SZ}
        StrCpy $3 0
    ${EndIf}
    StrLen $4 $R0
    StrLen $5 $R1
    IntOp $4 $4 + $5
    IntOp $4 $4 + 1 ; For \0
    !if ${NSIS_CHAR_SIZE} > 1
        IntOp $4 $4 * ${NSIS_CHAR_SIZE}
    !endif
    IntOp $4 $4 + $3
    System::Alloc $4
    System::Call 'ADVAPI32::RegQueryValueEx(ir1,tR2,i0,i0,isr9,*ir4r4)i.r0'
    ${If} $0 = 0
    ${OrIf} $0 = ${ERROR_FILE_NOT_FOUND}
        System::Call 'KERNEL32::lstrlen(t)(ir9)i.r0'
        ${If} $0 <> 0
            System::Call 'KERNEL32::lstrcat(t)(ir9,tR1)'
        ${EndIf}
        System::Call 'KERNEL32::lstrcat(t)(ir9,tR0)'
        System::Call 'KERNEL32::lstrlen(t)(ir9)i.r0'
        IntOp $0 $0 + 1
        !if ${NSIS_CHAR_SIZE} > 1
            IntOp $0 $0 * ${NSIS_CHAR_SIZE}
        !endif
        System::Call 'ADVAPI32::RegSetValueEx(ir1,tR2,i0,ir2,ir9,ir0)i.r0'
    ${EndIf}
    System::Free $9
    System::Call 'ADVAPI32::RegCloseKey(ir1)'
${EndIf}
Push $0
System::Store L
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
  
	Push ${HKEY_LOCAL_MACHINE}
	Push "Environment"
	Push "Path"
	Push ";"
	Push "$PROGRAMFILES64\Nova\bin"
	Call RegAppendString
	Pop $0
	DetailPrint RegAppendString:Error=$0

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
  
  # remove the variable
  ReadRegStr $R1 HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path"
  
  #Push "$R1"
  #Push ";$PROGRAMFILES64\Nova\bin"
  #Push ""
  #Push "+"
  #Push $R1
  
  #Call un.WordReplace
  ${un.WordReplace} "$R1" ";$PROGRAMFILES64\Nova\bin" "" "+" $R1
  WriteRegExpandStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path" "$R1"
#  Push PATH_DIR
#  Call un.DeleteEnvStr

  DeleteRegKey /ifempty HKCU "Software\Nova"

SectionEnd