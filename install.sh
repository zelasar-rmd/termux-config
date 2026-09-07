#!/data/data/com.termux/files/usr/bin/bash
# 1-Click Installer for Termux Customizations

echo "🚀 Restoring Termux customizations..."

TERMUX_HOME="/data/data/com.termux/files/home"

mkdir -p ~/.termux "$TERMUX_HOME/.termux" $PREFIX/bin

cp -f termux.properties ~/.termux/termux.properties
cp -f termux.properties "$TERMUX_HOME/.termux/termux.properties"
cp -f inputrc ~/.inputrc
cp -f inputrc "$TERMUX_HOME/.inputrc"
cp -f sys-clean $PREFIX/bin/sys-clean
chmod +x $PREFIX/bin/sys-clean
chmod 644 ~/.termux/termux.properties "$TERMUX_HOME/.termux/termux.properties" ~/.inputrc "$TERMUX_HOME/.inputrc" 2>/dev/null || true

termux-reload-settings 2>/dev/null || true

echo "🎉 Done! Your Termux setup has been restored."
