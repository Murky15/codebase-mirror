@echo off
setlocal enableextensions

set source=%~dp0
if not exist assets (
  echo This script must be run from the root directory!
  exit /b 1
) else (
  set assets=%cd%assets\
)

set includes=-I%source%lib\SDL3-3.4.14\include\
set includes=%includes% -I%source%lib\SDL3_image-3.4.4\include\
set includes=%includes% -I%source%lib\SDL3_ttf-3.2.2\include\

if not exist build mkdir build
pushd build
cl -nologo %includes% %source%galaxie.c -FeGalaxie.exe || exit /b 1
popd