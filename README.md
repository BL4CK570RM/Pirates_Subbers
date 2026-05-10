# 🏴‍☠️ Pirate-Subbers v3.0

![Pirate-Subbers Banner](Pirate_Subbers.png)

**Pirate-Subbers** is a professional-grade subdomain enumeration suite designed for Bug Bounty hunters and Security Researchers. It consolidates **22+ industry-standard tools** into a single, high-speed engine, specializing in both passive data harvesting and active DNS discovery.

Developed by **Kazi Sabbir**.

---

## 🚀 The 3 Specialized Modes

Pirate-Subz is engineered with three distinct operational modes to optimize your reconnaissance workflow:

### 1. 🔍 Passive Mode (`-ps` / `--passive`)
**Stealth-focused data gathering.**
- **Workflow**: Queries 20+ external APIs, archives, and certificate logs.
- **Tools**: Subfinder, Amass (Passive), Assetfinder, Chaos, Findomain, Haktrails, Gau, Github, Gitlab, Shosubgo, Censys, Crt.sh, JLDC, Alienvault, Subdomain-center, Certspotter, VirusTotal, HackerTarget, RapidDNS, and WebArchive.
- **Detection Risk**: Zero. It does not interact with the target's infrastructure.

### 2. ⚡ Active Mode (`-as` / `--active`)
**Intrusive discovery and validation.**
- **Workflow**: Performs high-speed DNS bruteforcing and SSL scraping.
- **Tools**: **Puredns** (DNS Bruteforce) and **Cero** (SSL/TLS SAN extraction).
- **Detection Risk**: High. Connects directly to the target's servers.

### 3. 🛡️ Hard Mode (`-hard`)
**The Complete Engine (Recommended for Deep Recon).**
- **Step 1**: Runs a full **Passive Scan** to build a base list.
- **Step 2**: Runs an **Active Scan** to find hidden hostnames.
- **Step 3**: Combines both results into a **"Seed List"**.
- **Step 4**: Uses **AlterX** to generate millions of intelligent DNS mutations from the seeds.
- **Step 5**: Validates mutations using **Puredns** to find undocumented assets.

---

## 🛠️ Installation & Setup

1. **Clone & Install**:
   ```bash
   git clone https://github.com/kazisabu/Pirates_Subbers.git
   cd Pirate-Subbers
   chmod +x Pirate_Subbers.sh
   ./Pirate_Subbers.sh
   ```
2. **Configure**: Open `config.txt` and add your API keys for Chaos, Shodan, and GitHub to maximize results.
3. **DNS Resolvers**: Ensure `resolvers.txt` is updated for accurate `Puredns` results.

---

## 📖 Usage Examples

### Standard Recon (Balanced)
```bash
./Pirate-Subbers.sh -d example.com -p -hp
```

### Stealth Monitoring (Passive Only)
```bash
./Pirate-Subbers.sh -d example.com -ps -p -s | anew live_subdomains.txt
```

### Deep Asset Discovery (Hard Mode)
```bash
./Pirate-Subbers.sh -d example.com -hard -p -hp
```

---

## ⚙️ Key Options

- `-d, --domain`: Target domain.
- `-l, --list`: List of multiple domains to scan.
- `-p, --parallel`: Enables multi-threaded tool execution (much faster).
- `-hp, --http-probe`: Verifies if discovered subdomains are running a web server.
- `-s, --silent`: Clean output for piping into other tools.

---

## 👤 Contact & Credits

**Author**: Kazi Sabbir    
**LinkedIn**: [linkedin.com/in/kazisabbir1337](https://www.linkedin.com/in/kazisabbir1337)  

