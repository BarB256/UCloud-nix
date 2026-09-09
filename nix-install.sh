#!/usr/bin/env bash
# nixinstall.sh

set -uo pipefail

echo "==> Checking prerequisites (curl, ca-certificates)..."
if ! command -v curl >/dev/null 2>&1; then
    apt update && apt install -y curl ca-certificates
fi

echo "==> Installing Nix (single-user mode)..."
if [ -x "$HOME/.nix-profile/bin/nix" ]; then
    echo "    Nix already installed, skipping installer."
else
    # Skips the 'nixbld group does not exist' failure that hits root installs.
    export NIX_CONFIG="build-users-group ="
    curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --no-daemon
fi

echo "==> Wiring up ~/.bashrc..."
BASHRC="$HOME/.bashrc"
MARKER="# >>> nix single-user setup >>>"
if ! grep -qF "$MARKER" "$BASHRC" 2>/dev/null; then
    cat >> "$BASHRC" << EOF

$MARKER
export USER=\$(whoami)
if [ -e "\$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "\$HOME/.nix-profile/etc/profile.d/nix.sh"
fi
# <<< nix single-user setup <<<
EOF
    echo "    Added Nix sourcing block to $BASHRC"
else
    echo "    $BASHRC already has the Nix block, skipping."
fi

echo "==> Sourcing Nix into this script's shell..."
export USER=$(whoami)
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
else
    echo "    ERROR: nix.sh not found at $HOME/.nix-profile/etc/profile.d/nix.sh"
    exit 1
fi

echo "==> Writing ~/.config/nix/nix.conf..."
mkdir -p "$HOME/.config/nix"
cat > "$HOME/.config/nix/nix.conf" << 'EOF'
experimental-features = nix-command flakes
sandbox = false
EOF

echo "==> Verifying installation..."
if command -v nix >/dev/null 2>&1; then
    echo "    nix found at: $(command -v nix)"
    nix --version
else
    echo "    ERROR: nix still not on PATH."
    exit 1
fi

echo "==> Running a real test build (nix run nixpkgs#hello)..."
if nix run nixpkgs#hello 2>&1 | tee /tmp/nix-hello-test.log | grep -q "Hello, world!"; then
    echo "==> SUCCESS: Nix is fully working."
else
    echo "==> WARNING: test run did not print the expected output."
    echo "    Check /tmp/nix-hello-test.log for details."
fi

echo ""
echo "Done."
echo "  - New shells: Nix loads automatically via ~/.bashrc."
echo "  - This shell: already loaded — try 'nix run nixpkgs#hello' or"
echo "                'nix run github:BarB256/bimg -- <image-path>'."
