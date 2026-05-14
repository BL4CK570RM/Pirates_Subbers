#!/bin/bash
# Pirate-Subbers Dependency Installer (Robust Version)
# Works on fresh Kali Linux – no root required, API keys optional

set +e  # Don't exit on error – we handle failures gracefully

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=============================================="
echo "   Pirate-Subbers Dependency Installer"
echo -e "==============================================${NC}"

if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}Do not run as root. Exiting.${NC}"
    exit 1
fi

# Helper to check commands
command_exists() { command -v "$1" &>/dev/null; }

# Ensure ~/go/bin and ~/.local/bin are in PATH
add_path() {
    if [[ ":$PATH:" != *":$HOME/go/bin:"* ]]; then
        export PATH="$PATH:$HOME/go/bin"
        echo 'export PATH="$PATH:$HOME/go/bin"' >> ~/.bashrc
        echo 'export PATH="$PATH:$HOME/go/bin"' >> ~/.zshrc 2>/dev/null
    fi
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$PATH:$HOME/.local/bin"
        echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
        echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.zshrc 2>/dev/null
    fi
}
add_path

# ----------------- System packages -----------------
echo -e "${YELLOW}[*] Installing system packages (curl, git, jq, parallel, etc)...${NC}"
sudo apt update -y >/dev/null 2>&1 || echo -e "${RED}[!] apt update failed – check internet${NC}"
sudo apt install -y curl wget git jq parallel python3 python3-pip sed gawk coreutils >/dev/null 2>&1 || \
    echo -e "${RED}[!] Some system packages could not be installed – continuing anyway.${NC}"

# ----------------- Go -----------------
if ! command_exists go; then
    echo -e "${YELLOW}[*] Installing Go (1.21.5)...${NC}"
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) GOARCH="amd64" ;;
        aarch64) GOARCH="arm64" ;;
        *) GOARCH="amd64" ;;
    esac
    wget -q "https://go.dev/dl/go1.21.5.linux-${GOARCH}.tar.gz" -O /tmp/go.tar.gz
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
    export PATH="/usr/local/go/bin:$PATH"
    echo 'export PATH="/usr/local/go/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="/usr/local/go/bin:$PATH"' >> ~/.zshrc 2>/dev/null
    echo -e "${GREEN}[+] Go installed.${NC}"
else
    echo -e "${GREEN}[+] Go already present.${NC}"
fi
add_path

# ----------------- Go-based tools -----------------
echo -e "${YELLOW}[*] Installing Go subdomain tools...${NC}"
declare -A go_tools
go_tools=(
    [subfinder]="github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    [amass]="github.com/owasp-amass/amass/v4/...@master"
    [assetfinder]="github.com/tomnomnom/assetfinder@latest"
    [chaos]="github.com/projectdiscovery/chaos-client/cmd/chaos@latest"
    [haktrails]="github.com/hakluke/haktrails@latest"
    [gau]="github.com/lc/gau/v2/cmd/gau@latest"
    [github-subdomains]="github.com/dwisiswant0/github-subdomains@latest"
    [gitlab-subdomains]="github.com/dwisiswant0/gitlab-subdomains@latest"
    [cero]="github.com/d3mondev/cero@latest"
    [shosubgo]="github.com/incogbyte/shosubgo@latest"
    [puredns]="github.com/d3mondev/puredns/v2@latest"
    [httpx]="github.com/projectdiscovery/httpx/cmd/httpx@latest"
    [alterx]="github.com/projectdiscovery/alterx/cmd/alterx@latest"
    [anew]="github.com/tomnomnom/anew@latest"
    [unfurl]="github.com/tomnomnom/unfurl@latest"
)

for bin in "${!go_tools[@]}"; do
    if command_exists "$bin"; then
        echo -e "  ${GREEN}[✓] $bin already installed.${NC}"
    else
        echo -e "  ${YELLOW}[→] Installing $bin...${NC}"
        go install "${go_tools[$bin]}" &>/dev/null || \
            echo -e "  ${RED}[✗] Failed to install $bin – you may try later manually.${NC}"
    fi
done

# ----------------- Findomain (Rust binary) -----------------
if ! command_exists findomain; then
    echo -e "${YELLOW}[*] Installing Findomain...${NC}"
    if [[ $(uname -m) == "aarch64" ]]; then
        URL="https://github.com/Findomain/Findomain/releases/latest/download/findomain-linux-arm64"
    else
        URL="https://github.com/Findomain/Findomain/releases/latest/download/findomain-linux"
    fi
    wget -q "$URL" -O /tmp/findomain && chmod +x /tmp/findomain && sudo mv /tmp/findomain /usr/local/bin/findomain
    if command_exists findomain; then
        echo -e "${GREEN}[+] Findomain installed.${NC}"
    else
        echo -e "${RED}[!] Failed to install Findomain.${NC}"
    fi
else
    echo -e "${GREEN}[+] Findomain already present.${NC}"
fi

# ----------------- Censys CLI (Python) -----------------
if ! command_exists censys; then
    echo -e "${YELLOW}[*] Installing Censys CLI (pip3)...${NC}"
    pip3 install --user censys &>/dev/null || \
        echo -e "${RED}[!] Failed to install Censys – you can configure it later.${NC}"
else
    echo -e "${GREEN}[+] Censys CLI already present.${NC}"
fi
add_path

# ----------------- Configuration files -----------------
echo -e "${YELLOW}[*] Setting up configuration and data files...${NC}"
CFGDIR="$HOME/.config/pirate-subbers"
mkdir -p "$CFGDIR"

# config.txt template (API keys optional)
CONFIG_TXT="$CFGDIR/config.txt"
if [ ! -f "$CONFIG_TXT" ]; then
    cat > "$CONFIG_TXT" << 'EOF'
# Pirate-Subbers Configuration
# Leave values empty if you don't have the API key – those sources will be skipped.

SECURITYTRAILS_API_KEY=""
GITHUB_TOKEN=""
GITLAB_TOKEN=""
SHODAN_API_KEY=""
VIRUSTOTAL_API_KEY=""
CHAOS_API_KEY=""

SUBFINDER_CONFIG="$HOME/.config/subfinder/provider-config.yaml"
AMASS_CONFIG="$HOME/.config/amass/config.ini"
WORDLISTS="$HOME/.config/pirate-subbers/subdomains-top1million-5000.txt"
RESOLVERS="$HOME/.config/pirate-subbers/resolvers.txt"
EOF
    echo -e "${GREEN}[+] Created config template at $CONFIG_TXT${NC}"
else
    echo -e "${GREEN}[+] config.txt already exists.${NC}"
fi

# Resolvers
if [ ! -f "$CFGDIR/resolvers.txt" ]; then
    wget -q "https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt" -O "$CFGDIR/resolvers.txt"
    echo -e "${GREEN}[+] resolvers.txt downloaded.${NC}"
else
    echo -e "${GREEN}[+] resolvers.txt found.${NC}"
fi

# Wordlist
if [ ! -f "$CFGDIR/subdomains-top1million-5000.txt" ]; then
    wget -q "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt" -O "$CFGDIR/subdomains-top1million-5000.txt"
    echo -e "${GREEN}[+] Default wordlist downloaded.${NC}"
else
    echo -e "${GREEN}[+] Wordlist found.${NC}"
fi

# Subfinder config
SUBFD="$HOME/.config/subfinder"
mkdir -p "$SUBFD"
if [ ! -f "$SUBFD/provider-config.yaml" ]; then
    cat > "$SUBFD/provider-config.yaml" << 'EOF'
# Subfinder default config – all sources disabled (API keys not needed)
sources:
    - binaryedge:
        - disabled
    - censys:
        - disabled
    - certspotter:
        - disabled
    - chaos:
        - disabled
    - chinaz:
        - disabled
    - dnsdb:
        - disabled
    - github:
        - disabled
    - hackertarget:
        - disabled
    - intelx:
        - disabled
    - passivetotal:
        - disabled
    - rapidssl:
        - disabled
    - securitytrails:
        - disabled
    - shodan:
        - disabled
    - spyse:
        - disabled
    - sublist3r:
        - disabled
    - threatcrowd:
        - disabled
    - threatminer:
        - disabled
    - virustotal:
        - disabled
    - waybackarchive:
        - disabled
    - zoomeye:
        - disabled
EOF
    echo -e "${GREEN}[+] Default Subfinder config created.${NC}"
fi

# Amass config
AMCFG="$HOME/.config/amass"
mkdir -p "$AMCFG"
if [ ! -f "$AMCFG/config.ini" ]; then
    touch "$AMCFG/config.ini"
    echo -e "${GREEN}[+] Empty Amass config created.${NC}"
fi

# .gau.toml
if [ ! -f "$HOME/.gau.toml" ]; then
    wget -q "https://raw.githubusercontent.com/lc/gau/master/.gau.toml" -O "$HOME/.gau.toml" && \
        echo -e "${GREEN}[+] .gau.toml downloaded.${NC}"
fi

# ----------------- Symlink pirate-subbers -----------------
if [ -f "./pirate-subbers.sh" ]; then
    chmod +x ./pirate-subbers.sh
    sudo ln -sf "$PWD/pirate-subbers.sh" /usr/local/bin/pirate-subbers
    echo -e "${GREEN}[+] Symlink created → 'pirate-subbers'${NC}"
else
    echo -e "${YELLOW}[!] pirate-subbers.sh not found in current directory. Skipping symlink.${NC}"
fi

# ----------------- Done -----------------
echo -e "\n${BLUE}=============================================="
echo " Installation Complete"
echo -e "==============================================${NC}"
echo -e "Next steps:"
echo -e "  • Edit config: ${GREEN}$CONFIG_TXT${NC}"
echo -e "    (Add API keys if you have them – they are OPTIONAL.)"
echo -e "  • Test with:  ${GREEN}pirate-subbers -d example.com${NC}"
echo -e "\nHappy hunting! \U0001F3F4\u200D\u2620\uFE0F"
