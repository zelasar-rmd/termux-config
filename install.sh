#!/data/data/com.termux/files/usr/bin/bash
# 1-Click Installer for Termux Customizations

echo "🚀 Restoring Termux customizations..."

mkdir -p ~/.termux $PREFIX/bin

cp -f termux.properties ~/.termux/termux.properties
cp -f inputrc ~/.inputrc
cp -f sys-clean $PREFIX/bin/sys-clean
chmod +x $PREFIX/bin/sys-clean

termux-reload-settings 2>/dev/null || true

echo "🎉 Done! Your Termux setup has been restored."
