#!/bin/bash

SHORTCUTS_DIR=$HOME/.local/share/applications

rm -rf ${SHORTCUTS_DIR}/tizen
mkdir ${SHORTCUTS_DIR}/tizen
cp ./*.png ${SHORTCUTS_DIR}/tizen
cp ./tizen*.sh ${SHORTCUTS_DIR}/tizen

printf "[Desktop Entry]\n\
Encoding=UTF-8\n\
Version=1.0\n\
Type=Application\n\
Terminal=false\n\
Name=Tizen Studio\n\
Comment=Tizen Studio IDE\n\
Categories=Development;IDE;\n\
StartupNotify=true\n\
NoDisplay=false\n\
Path[$e]=${SHORTCUTS_DIR}/tizen
Icon=${SHORTCUTS_DIR}/tizen/tizen-studio.png\n\
Exec=\"${SHORTCUTS_DIR}/tizen/tizen-ide.sh\"" > ${SHORTCUTS_DIR}/tizen-studio.desktop

printf "[Desktop Entry]\n\
Encoding=UTF-8\n\
Version=1.0\n\
Type=Application\n\
Terminal=false\n\
Name=Tizen Package Manager\n\
Comment=Tizen Package Manager \n\
Categories=Development;IDE;\n\
StartupNotify=true\n\
NoDisplay=false\n\
Path[$e]=${SHORTCUTS_DIR}/tizen
Icon=${SHORTCUTS_DIR}/tizen/tizen-studio-package-manager.png\n\
Exec=\"${SHORTCUTS_DIR}/tizen/tizen-package-manager.sh\"" > ${SHORTCUTS_DIR}/tizen-package-manager.desktop

printf "[Desktop Entry]\n\
Encoding=UTF-8\n\
Version=1.0\n\
Type=Application\n\
Terminal=false\n\
Name=Certificate Manager\n\
Comment=Tizen Certificate Manager \n\
Categories=Development;IDE;\n\
StartupNotify=true\n\
NoDisplay=false\n\
Path[$e]=${SHORTCUTS_DIR}/tizen
Icon=${SHORTCUTS_DIR}/tizen/tizen-studio-certificate-manager.png\n\
Exec=\"${SHORTCUTS_DIR}/tizen/tizen-cert-manager.sh\"" > ${SHORTCUTS_DIR}/tizen-cert-manager.desktop