#!/usr/bin/bash

# Comment out copies of non existing compcert files in installer
sed -i 's/cp source.coq-compcert/# cp source/' '/platform/windows/create_installer_windows.sh'

# Add `!include "EnVar.nsh"\n` before the first !include 
# to add the EnVar plugin https://nsis.sourceforge.io/EnVar_plug-in
sed -i '0,/!include/{s/!include/!include "EnVar.nsh"\n!include/}' '/platform/windows/create_installer_windows.sh'

# Use the Envar plugin to add installation dir to PATH
sed -i 's|SetOutPath "$INSTDIR\\bin\\"|SetOutPath "$INSTDIR\\bin\\"\
  EnVar::AddToPath "$INSTDIR\\bin"\
  EnVar::UpdateSystem|' '/platform/windows/create_installer_windows.sh'