# (re)set the keyboard layout.
cat >/etc/default/keyboard <<'EOF'
# KEYBOARD CONFIGURATION FILE
# Consult the keyboard(5) manual page.
XKBMODEL="pc105"
XKBLAYOUT="us"
XKBVARIANT=""
XKBOPTIONS=""
KEYMAP="us-latin1"
BACKSPACE="guess"
EOF
setupcon
