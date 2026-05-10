#!/bin/bash

#colours
BOLD="\e[1m"
UNDERLINE="\e[4m"
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
CYAN="\e[36m"
NC="\e[0m"
VERSION="3.0"
TIMEOUT=60

PRG=${0##*/}

source config.txt

Usage() {
        while read -r line; do
                printf "%b\n" "$line"
        done <<-EOF
        \r# ${BOLD}${GREEN}Options:${NC}
        \r      -d, --domain            - Domain to enumerate
        \r      -l, --list              - List of root domains to enumerate
        \r      -u, --use               - Specify which tools to be used
        \r      -e, --exclude           - Specify which tools to be excluded
        \r      -o, --output            - Output file to save results
        \r      -s, --silent            - Show only subdomains in output
        \r      -ps, --passive          - MODE 1: Passive Only (APIs, Archives, Logs)
        \r      -as, --active           - MODE 2: Active Only (DNS Bruteforce, SSL Scraping)
        \r      -hard                   - MODE 3: Complete Scan (Passive + Active + Permutations)
        \r      -p, --parallel          - Run parallely for faster results
        \r      -hp, --http-probe       - probe for working http/https servers
        \r      -k, --keep              - keep the temporary files
        \r      -h, --help              - Display this help message and exit
        \r      -v, --version           - Display the version and exit
        \r      -ls, --list-sources     - Display all available sources/tools

EOF
        exit 1
}

ListSources() {
    echo -e "${BOLD}${CYAN}Available Sources/Tools:${NC}"
    echo "Subfinder"
    echo "Amass"
    echo "Assetfinder"
    echo "Chaos"
    echo "Findomain"
    echo "Haktrails"
    echo "Gau"
    echo "Github-subdomains"
    echo "Gitlab-subdomains"
    echo "Cero"
    echo "Shosubgo"
    echo "Censys"
    echo "Crtsh"
    echo "JLDC-anubis"
    echo "Alienvault"
    echo "Subdomain-center"
    echo "Certspotter"
    echo "Puredns"
    echo "VirusTotal"
    echo "HackerTarget"
    echo "RapidDNS"
    echo "Webarchive"
    exit 1
}


spinner() {
        processing="${1}"
        while true;
        do
                dots=( "/" "-" "\\" "|" )
                for dot in ${dots[@]};
                do
                        printf "[${dot}] ${processing} \U1F50E"
                        printf "                                        \r"
                        sleep 0.2
                done
        done
}

Subfinder() {
	[ "$silent" == True ] && subfinder -all -silent -d $domain -pc $SUBFINDER_CONFIG 2>/dev/null | anew pirate-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}Subfinder${NC}" &
			PID="$!"
		}
		subfinder -all -silent -d $domain -pc $SUBFINDER_CONFIG 1> tmp-subfinder-$domain 2>/dev/null
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$BOLD[*] Subfinder$NC: $(wc -l < tmp-subfinder-$domain)"
	}
}

Amass() {
	[ "$silent" == True ] && amass enum -passive -norecursive -noalts -d $domain -config $AMASS_CONFIG 2>/dev/null | anew pirate-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}Amass${NC}" &
			PID="$!"
		}
		amass enum -passive -norecursive -noalts -d $domain -config $AMASS_CONFIG 1> tmp-amass-$domain 2>/dev/null
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$BOLD[*] Amass$NC: $(wc -l < tmp-amass-$domain)"
	}
}

Assetfinder() {
	[ "$silent" == True ] && assetfinder --subs-only $domain | anew pirate-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}Assetfinder${NC}" &
			PID="$!"
		}
		assetfinder --subs-only $domain > tmp-assetfinder-$domain
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$BOLD[*] Assetfinder$NC: $(wc -l < tmp-assetfinder-$domain)"
	}
}

Chaos() {
	[ "$silent" == True ] && chaos -silent -key $CHAOS_API_KEY -d $domain | anew pirate-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}Chaos${NC}" &
			PID="$!"
		}
		chaos -silent -key $CHAOS_API_KEY -d $domain > tmp-chaos-$domain
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$BOLD[*] Chaos$NC: $(wc -l < tmp-chaos-$domain)"
	}
}

Findomain() {
	[ "$silent" == True ] && findomain -t $domain -q 2>/dev/null | anew pirate-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}Findomain${NC}" &
			PID="$!"
		}
		findomain -t $domain -q > tmp-findomain-$domain &>/dev/null
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$BOLD[*] Findomain$NC: $(wc -l tmp-findomain-$domain)"
	}
}

Haktrails() {
	[ "$silent" == True ] && echo "$domain" | haktrails subdomains 2>/dev/null | anew pirate-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}Haktrails${NC}" &
			PID="$!"
		}
		echo "$domain" | haktrails subdomains 1> tmp-haktrails-$domain 2>/dev/null
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$BOLD[*] Haktrails$NC: $(wc -l < tmp-haktrails-$domain 2>/dev/null || echo 0)"
	}
}

Gau() {
        [ "$silent" == True ] &&  gau --threads 10 --subs $domain 2>/dev/null |  unfurl -u domains | anew pirate-$domain.txt || {
                [[ ${PARALLEL} == True ]] || { spinner "${BOLD}Gau${NC}" &
                        PID="$!"
                }
                gau --threads 10 --subs $domain 2>/dev/null | unfurl -u domains > tmp-gau-$domain
                [[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
                echo -e "$BOLD[*] Gau$NC: $( wc -l < tmp-gau-$domain 2>/dev/null || echo 0)"
        }
}

Github-subdomains() {
        [ "$silent" == True ] && github-subdomains -d $domain -t $GITHUB_TOKEN -raw 2>/dev/null | anew pirate-$domain.txt || {
                [[ ${PARALLEL} == True ]] || { spinner "${BOLD}Github-Subdomains${NC}" &
                        PID="$!"
                }
                github-subdomains -d $domain -t $GITHUB_TOKEN -raw 1> tmp-github-subdomains-$domain 2>/dev/null
                [[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
                echo -e "$BOLD[*] Github-Subdomains$NC: $( wc -l < tmp-github-subdomains-$domain)"
        }
}

Gitlab-subdomains() {
        [ "$silent" == True ] && gitlab-subdomains -d $domain -t $GITLAB_TOKEN 2>/dev/null | anew pirate-$domain.txt || {
                [[ ${PARALLEL} == True ]] || { spinner "${BOLD}Gitlab-Subdomains${NC}" &
                        PID="$!"
                }
                gitlab-subdomains -d $domain -t $GITLAB_TOKEN 1> tmp-gitlab-subdomains-$domain 2>/dev/null
                [[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
                echo -e "$BOLD[*] Github-Subdomains$NC: $( wc -l < tmp-gitlab-subdomains-$domain)"
        }
}

Cero() {
	[ "$silent" == True ] && cero $domain 2>/dev/null | anew pirate-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}Cero${NC}" &
			PID="$!"
		}
		cero $domain 1> tmp-cero-$domain 2>/dev/null
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$BOLD[*] Cero$NC: $( wc -l < tmp-cero-$domain)"
	}
}

Shosubgo() {
	[ -z "$SHODAN_API_KEY" ] && return
	[ "$silent" == True ] && shosubgo -d $domain -s $SHODAN_API_KEY 2>/dev/null | anew pirate-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}Shosubgo${NC}" &
			PID="$!"
		}
		shosubgo -d $domain -s $SHODAN_API_KEY 1> tmp-shosubgo-$domain 2>/dev/null
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$BOLD[*] Shosubgo$NC: $( wc -l < tmp-shosubgo-$domain 2>/dev/null || echo 0)"
	}
}

Censys() {
	[ "$silent" == True ] && censys subdomains $domain | sed 's/^[ \t]*-//; s/-//g' 2>/dev/null | anew pirate-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}Censys${NC}" &
			PID="$!"
		}
		censys subdomains $domain | sed 's/^[ \t]*-//; s/-//g' 1> tmp-censys-$domain 2>/dev/null
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$BOLD[*] Censys$NC: $( wc -l < tmp-censys-$domain)"
	}
}

Crtsh() {
	[ "$silent" == True ] && timeout $TIMEOUT curl -sk "https://crt.sh/?q=%.$domain&output=json" | tr ',' '\n' | awk -F'"' '/name_value/ {gsub(/\*\./, "", $4); gsub(/\\n/,"\n",$4);print $4}' | grep -w "$domain\$" | anew pirate-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}Crtsh${NC}" &
			PID="$!"
		}
		timeout $TIMEOUT curl -sk "https://crt.sh/?q=%.$domain&output=json" 2>/dev/null | tr ',' '\n' | awk -F'"' '/name_value/ {gsub(/\*\./, "", $4); gsub(/\\n/,"\n",$4);print $4}' | grep -w "$domain\$" | sort -u > tmp-crt-$domain
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$BOLD[*] Crtsh$NC: $( wc -l < tmp-crt-$domain 2>/dev/null || echo 0)"
	}
}

JLDC() {
  [ "$silent" == True ] && timeout $TIMEOUT curl -sk "https://jldc.me/anubis/subdomains/$domain" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | anew pirate-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}JLDC${NC}" &
			PID="$!"
		}
		timeout $TIMEOUT curl -sk "https://jldc.me/anubis/subdomains/$domain" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u > tmp-jldc-$domain
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$BOLD[*] JLDC$NC: $( wc -l < tmp-jldc-$domain 2>/dev/null || echo 0)"
	}
}

Alienvault() {
  [ "$silent" == True ] && timeout $TIMEOUT curl -s "https://otx.alienvault.com/api/v1/indicators/domain/$domain/url_list?limit=1000&page=100" | grep -o '"hostname": *"[^"]*' | sed 's/"hostname": "//' | anew pirate-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}Alienvault${NC}" &
			PID="$!"
		}
		timeout $TIMEOUT curl -s "https://otx.alienvault.com/api/v1/indicators/domain/$domain/url_list?limit=1000&page=100" | grep -o '"hostname": *"[^"]*' | sed 's/"hostname": "//' | sort -u > tmp-alienvault-$domain
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$BOLD[*] Alienvault$NC: $( wc -l < tmp-alienvault-$domain 2>/dev/null || echo 0)"
	}
}

Subdomain-center() {
  [ "$silent" == True ] && timeout $TIMEOUT curl "https://api.subdomain.center/?domain=$domain" -s | jq -r '.[]' 2>/dev/null | sort -u | anew pirate-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}Subdomain center${NC}" &
			PID="$!"
		}
		timeout $TIMEOUT curl "https://api.subdomain.center/?domain=$domain" -s | jq -r '.[]' 2>/dev/null | sort -u > tmp-subdomaincenter-$domain
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$BOLD[*] Subdomain center$NC: $( wc -l < tmp-subdomaincenter-$domain 2>/dev/null || echo 0)"
	}
}

Certspotter() {
  [ "$silent" == True ] && timeout $TIMEOUT curl -sk "https://api.certspotter.com/v1/issuances?domain=$domain&include_subdomains=true&expand=dns_names" | jq -r '.[].dns_names[]' | anew pirate-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}CertSpotter${NC}" &
			PID="$!"
		}
		timeout $TIMEOUT curl -sk "https://api.certspotter.com/v1/issuances?domain=$domain&include_subdomains=true&expand=dns_names" 2>/dev/null | jq -r '.[].dns_names[]' 2>/dev/null | sort -u > tmp-certspotter-$domain
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$BOLD[*] CertSpotter$NC: $( wc -l < tmp-certspotter-$domain 2>/dev/null || echo 0)"
	}
}

VirusTotal() {
  [ "$silent" == True ] && timeout $TIMEOUT curl -s "https://www.virustotal.com/vtapi/v2/domain/report?apikey=$VIRUSTOTAL_API_KEY&domain=$domain" | jq | egrep -v "http|Alexa domain info" | grep "$domain" | sed 's/[",]//g' | sed 's/^[[:space:]]*//' | anew pirate-$domain.txt || {
  		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}VirusTotal${NC}" &
    			PID="$!"
       		}
	 	timeout $TIMEOUT curl -s "https://www.virustotal.com/vtapi/v2/domain/report?apikey=$VIRUSTOTAL_API_KEY&domain=$domain" 2>/dev/null | jq 2>/dev/null | egrep -v "http|Alexa domain info" | grep "$domain" | sed 's/[",]//g' | sed 's/^[[:space:]]*//' | sort -u > tmp-virustotal-$domain
   		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
     		echo -e "$BOLD[*] VirusTotal$NC: $( wc -l < tmp-virustotal-$domain 2>/dev/null || echo 0)"
       }
}

Puredns() {
  [ "$silent" == True ] && puredns bruteforce $WORDLISTS $domain --resolvers $RESOLVERS -q | anew pirate-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}Puredns${NC}" &
			PID="$!"
		}
		puredns bruteforce $WORDLISTS $domain --resolvers $RESOLVERS -q > tmp-puredns-$domain
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$BOLD[*] Puredns$NC: $( wc -l < tmp-puredns-$domain 2>/dev/null || echo 0)"
	}
}

HackerTarget() {
	[ "$silent" == True ] && timeout $TIMEOUT curl -s "https://api.hackertarget.com/hostsearch/?q=$domain" | cut -d',' -f1 | grep -E "\.$domain$" | anew pirate-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}HackerTarget${NC}" &
			PID="$!"
		}
		timeout $TIMEOUT curl -s "https://api.hackertarget.com/hostsearch/?q=$domain" | cut -d',' -f1 | grep -E "\.$domain$" | sort -u > tmp-hackertarget-$domain
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$BOLD[*] HackerTarget$NC: $(wc -l < tmp-hackertarget-$domain 2>/dev/null || echo 0)"
	}
}

RapidDNS() {
	[ "$silent" == True ] && timeout $TIMEOUT curl -s "https://rapiddns.io/subdomain/$domain?full=1" | grep -oE "[\.a-zA-Z0-9-]+\.$domain" | anew pirate-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}RapidDNS${NC}" &
			PID="$!"
		}
		timeout $TIMEOUT curl -s "https://rapiddns.io/subdomain/$domain?full=1" | grep -oE "[\.a-zA-Z0-9-]+\.$domain" | sort -u > tmp-rapiddns-$domain
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$BOLD[*] RapidDNS$NC: $(wc -l < tmp-rapiddns-$domain 2>/dev/null || echo 0)"
	}
}

Webarchive() {
	[ "$silent" == True ] && timeout $TIMEOUT curl -s "http://web.archive.org/cdx/search/cdx?url=*.$domain/*&output=text&fl=original&collapse=urlkey" | sed -e 's_https*://__' -e 's/\/.*//' | grep -E "\.$domain$" | anew pirate-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${BOLD}Web Archive${NC}" &
			PID="$!"
		}
		timeout $TIMEOUT curl -s "http://web.archive.org/cdx/search/cdx?url=*.$domain/*&output=text&fl=original&collapse=urlkey" | sed -e 's_https*://__' -e 's/\/.*//' | grep -E "\.$domain$" | sort -u > tmp-webarchive-$domain
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$BOLD[*] Web Archive$NC: $(wc -l < tmp-webarchive-$domain 2>/dev/null || echo 0)"
	}
}

Permute() {
	[ "$silent" == False ] && echo -e "${BOLD}${CYAN}[*] Generating permutations with Alterx...${NC}"
	# Collect all found so far
	sort -u tmp-* 2>/dev/null > tmp-pre-permute-$domain
	[ -s tmp-pre-permute-$domain ] && {
		cat tmp-pre-permute-$domain | alterx -silent | puredns resolve --resolvers $RESOLVERS -q | anew pirate-$domain.txt > tmp-alterx-$domain
		[ "$silent" == False ] && echo -e "$BOLD[*] Alterx Permutations$NC: $(wc -l < tmp-alterx-$domain 2>/dev/null || echo 0)"
	}
}

Use() {
        for i in $lu; 
        do
                $i
        done
        [[ $out != False ]] && Out $out || Out
}

Exclude() {
        for i in ${list[@]}; 
        do
                if [[ " ${le[@]} " =~ " ${i} " ]]; then
                        continue
                else
                        $i
                fi
        done
        [[ $out != False ]] && Out $out || Out
}

Out() {
        [ "$silent" == False ] && { 
		[ -n "$1" ] && output="$1" || output="$domain.txt"
		# Scrub any error messages captured in tmp files
		sort -u tmp-* | grep -vE "Error|json|unmarshal|config|invalid" > tmp-final-clean
		result=$(wc -l < tmp-final-clean)
		cat tmp-final-clean >> $output
		echo -e $GREEN"[+] The Final subdomains:$NC ${result}"
		[ $httprobe == True ] && Alive "$output" "$domain"
		[ $delete == True ] && rm tmp-*	
	}
}

Alive() {
        [ "$silent" == False ] && printf "$BOLD[+] HTTP probing... $NC"
	printf "                        \r"
	cat $1 | httpx -silent > "alive-$2.txt"
	[ "$silent" == False ] && echo -e $GREEN"[+] Alive Subdomains:$NC $(wc -l < alive-$2.txt)"
}

RunTools() {
	local tools_to_run=("$@")
	if [[ ${PARALLEL} == True ]]; then
		spinner "Enumerating" &
		PID="$!"
		export -f Subfinder Amass Assetfinder Chaos Findomain Haktrails Gau Github-subdomains Gitlab-subdomains Shosubgo Censys Crtsh JLDC Alienvault Subdomain-center Certspotter VirusTotal HackerTarget RapidDNS Webarchive Cero Puredns spinner
		export domain silent BOLD NC TIMEOUT WORDLISTS RESOLVERS GITHUB_TOKEN SHODAN_API_KEY CHAOS_API_KEY VIRUSTOTAL_API_KEY SECURITYTRAILS_API_KEY SUBFINDER_CONFIG AMASS_CONFIG
		parallel -j18 ::: "${tools_to_run[@]}"
		kill ${PID}
	else
		for tool in "${tools_to_run[@]}"; do
			$tool
		done
	fi
}

List() {
	lines=$(wc -l < $hosts)
	count=1
	while read domain; do
		[ "$silent" == False ] && echo -e "\n${UNDERLINE}${BOLD}${CYAN}[+] Domain ($count/$lines):${NC} ${domain}"
		if [ "$MODE" == "PASSIVE" ]; then
			RunTools "${passive_list[@]}"
		elif [ "$MODE" == "ACTIVE" ]; then
			RunTools "${active_list[@]}"
		elif [ "$MODE" == "HARD" ]; then
			RunTools "${passive_list[@]}"
			RunTools "${active_list[@]}"
			Permute
		else
			RunTools "${list[@]}"
		fi
		[[ $out != False ]] && Out $out || Out
		let count+=1
	done < $hosts
}

Main() {
	[ $domain == False ] && [ $hosts == False ]
	
	# Global Self-Configuration (Sequential)
	[ ! -f ~/.config/haktools/haktrails-config.yml ] && [ -n "$SECURITYTRAILS_API_KEY" ] && {
		mkdir -p ~/.config/haktools/
		echo "securitytrails:
  key: $SECURITYTRAILS_API_KEY" > ~/.config/haktools/haktrails-config.yml
	}
	[ ! -f ~/.gau.toml ] && wget -q https://raw.githubusercontent.com/lc/gau/master/.gau.toml -O ~/.gau.toml 2>/dev/null

	[ $domain != False ] && { 
		if [ "$MODE" == "PASSIVE" ]; then
			RunTools "${passive_list[@]}"
		elif [ "$MODE" == "ACTIVE" ]; then
			RunTools "${active_list[@]}"
		elif [ "$MODE" == "HARD" ]; then
			RunTools "${passive_list[@]}"
			RunTools "${active_list[@]}"
			Permute
		else
			RunTools "${list[@]}"
		fi
		[ $out == False ] && Out || Out $out
	}
	[ "$hosts" != False ] && List
}

domain=False
hosts=False
use=False
exclude=False
silent=False
delete=True
out=False
httprobe=False
PARALLEL=False
PERMUTE=False
PASSIVE=False
MODE="DEFAULT"

passive_list=(
        Subfinder
        Amass
        Assetfinder
        Chaos
        Findomain
        Haktrails
        Gau
        Github-subdomains
        Gitlab-subdomains
        Shosubgo
        Censys
        Crtsh
        JLDC
        Alienvault
        Subdomain-center
        Certspotter
	VirusTotal
	HackerTarget
	RapidDNS
	Webarchive
        )

active_list=(
	Cero
	Puredns
	)

list=(
        Subfinder
        Amass
        Assetfinder
        Chaos
        Findomain
        Haktrails
        Gau
        Github-subdomains
        Gitlab-subdomains
        Cero
        Shosubgo
        Censys
        Crtsh
        JLDC
        Alienvault
        Subdomain-center
        Certspotter
	VirusTotal
	Puredns
	HackerTarget
	RapidDNS
	Webarchive
        )

while [ -n "$1" ]; do
	case $1 in
		-d|--domain)
			domain=$2
			shift ;;
		-l|--list)
			hosts=$2
			shift ;;
		-u|--use)
			use=$2
			lu=${use//,/ }
			for i in $lu; do
				if [[ ! " ${list[@]} " =~ " ${i} " ]]; then
					echo -e $RED$UNDERLINE"[-] Unknown Function: $i"$NC
					Usage
				fi
			done
			shift ;;
		-e|--exclude)
			exclude=$2
			le=${exclude//,/ }
			for i in $le; do
				if [[ ! " ${list[@]} " =~ " ${i} " ]]; then
					echo -e $RED$UNDERLINE"[-] Unknown Function: $i"$NC
					Usage
				fi
			done
			shift ;;
		-o|--output)
			out=$2
			shift ;;
		-s|--silent)
			silent=True ;;
		-k|--keep)
			delete=False ;;
		-hp|--http-probe)
			httprobe=True ;;
		-h|--help)
			Usage;;
		-p|--parallel)
			PARALLEL=True ;;
		-ps|--passive)
			MODE="PASSIVE" ;;
		-as|--active)
			MODE="ACTIVE" ;;
		-hard)
			MODE="HARD" ;;
		-pm|--permute)
			PERMUTE=True ;;
		-v|--version)
			echo -e "${BOLD} Pirate-Subbers $VERSION $NC"
			exit 0 ;;
                -ls|--list-sources)
                        ListSources
                        ;;
		*)
			echo "[-] Unknown Option: $1"
			Usage ;;
	esac
	shift
done

[ "$silent" == False ] && echo -e $CYAN"""
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⣛⠿⣿⡿⠿⣿⣿⣬⡻⣷⡥⣊⡛⢿⡿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⢪⢿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⡿⣫⣿⢟⣻⣿⣿⣷⡿⣩⣿⣯⣜⣹⢛⢿⣶⢑⣛⢏⣿⣼⣿⣿⣿⣿⣿⣿⡹⣿⣿⣿⣿⣿⣿⢾⢿⣧⢻⣿⣿⣿⣿⣿⣿⣿
⣿⣿⠿⡋⣺⢋⣑⣿⢿⡿⣫⣽⢰⣿⡟⣟⣿⣿⣷⣥⣙⣷⠶⣢⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⡾⣿⣮⡞⣿⣿⣿⣿⣿⣿⣿
⣿⠿⢍⠩⢖⣛⣿⣇⠢⣾⣿⡇⣿⡿⣿⢻⢻⣟⣫⡝⣾⣷⣶⣿⣿⣿⣿⣿⣿⣿⣿⡻⠿⣿⣿⣿⡟⣿⢳⢱⡹⣼⣷⢹⣿⣿⣿⣿⣿⣿
⣼⠟⣡⣾⣿⣿⣿⡿⣺⣦⣾⣽⣿⣷⣿⣿⣩⣢⣿⣿⣿⡿⠿⣟⣛⣭⣭⣷⣶⣶⣶⣾⣿⣿⣿⣶⠲⠾⢥⣵⣓⡿⢹⢸⣿⣿⢿⣿⣿⣿
⣿⠸⣿⣿⣿⣿⡿⠣⢿⡿⠿⢹⡏⣿⣱⣣⣿⠻⣙⣥⣵⠾⢛⣿⣿⣿⣿⣿⣿⣿⣯⣭⡿⠿⠿⠿⣒⣋⣹⣤⣬⣭⣗⢲⣖⡛⢛⣻⣿⡿
⣿⣷⣶⣯⣭⣵⣶⣿⣿⣿⣿⢨⡞⠙⠘⠉⠀⠉⠉⣭⣴⣾⡿⠿⢟⣛⣛⣭⣭⣵⠶⣖⡤⣙⡻⢿⣿⣿⢿⣛⣿⣿⣷⣿⣿⣿⠿⠋⠕⠈
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡜⡀⠀⠀⢀⣀⣠⣬⣥⣴⠒⣿⣿⣿⣿⡿⠿⣿⡯⠭⢿⣷⡒⠯⢍⣿⣿⣭⣥⠞⠋⠉⠉⠉⠀⠀⠀⠀⠀
⣿⣿⠿⠿⢟⣛⣛⣻⣍⢉⡢⠔⣒⣰⠞⠛⣳⣶⣾⣿⣷⣿⣿⣿⣿⣿⣷⣶⣿⣟⣓⣶⣟⣛⣛⠲⠾⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣚
⣾⣿⣿⣿⣿⣿⠫⢕⡛⠛⠛⠛⠻⠭⠜⠿⠿⠛⠛⠁⠘⠿⠿⠛⠛⠋⠉⠝⠃⠛⠛⠹⠍⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿
⠘⠉⠈⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⠠⣶⠐⣶⣶⣿⣿⣯⣵⡆⣦⡀⢡⡆⠀⠀⡴⢋⠡⠀⠀⠀⢢⣴⣼
⣿⣶⣶⣶⣤⣤⣤⣤⣤⣤⠄⠀⡀⠀⡎⡓⢦⢀⠀⢀⣀⣤⣾⣿⣿⢠⣏⠀⢸⠿⣿⣿⣿⣿⣿⣿⣿⡨⠍⠁⠀⠁⠀⢀⠀⠰⣦⡀⣿⣿
⣿⣿⣿⣿⣿⡿⠫⠒⠒⠭⡒⢿⡇⢀⠃⢉⠈⠘⣷⣼⣿⣿⣿⣿⣿⣦⣅⣀⣼⣾⣿⣿⣿⣿⣿⣿⣿⠾⠁⠂⠠⠰⢀⢆⣶⣄⣿⣿⣿⣿
⣿⣿⣿⣿⣿⢡⠁⠀⠀⠀⠀⠑⠑⠻⣎⢈⠰⠀⢹⣿⣿⣿⣿⣿⣿⣿⡿⠿⣛⣛⣛⣛⣛⣛⡿⢿⣯⠐⠌⠀⣠⡴⢫⣾⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⢸⠀⠀⠀⠀⠀⠀⠀⠀⠈⠓⢕⢶⣄⢻⣿⠟⢿⣿⢋⣥⣾⡿⠟⠛⠛⠛⣿⣿⣿⠹⠝⠓⠀⠀⢁⣴⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⠙⢴⡝⣿⣿⣿⣿⣶⣶⣾⣶⣿⣿⣿⣿⠚⠀⠀⠀⠀⠘⠿⠿⠿⢿⡟⠛⠫⠭⠛
⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⢿⣿⣿⣿⣿⣿⣿⠿⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡀⠀⠀⠈⠉⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣿⡿⠛⠛⠉⠉⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣷⣍⡀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣶⣄⡀⢀⣀⣠⣼⠿⣚⣥⢊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⠙⢿⣿⣷⣶⣶⣶⣿⣿⡇⢨⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣶⡈⣿⣿⣿⣿⣿⣿⣿⡏⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⢸⣿⣿⣿⣿⣧⢹⣿⣿⣿⣿⣿⣿⢁⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⣿⣿⣿⣿⣿⣿⠈⣿⣿⣿⣿⣿⡟⢸⣿⢻⢿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠈⣝⡛⠿⣿⣿⡂⠘⣿⣿⣿⣿⡇⢸⣇⢆⡠⠙⠀⠀⠀$VERSION

           Advanced Subdomain Enumeration Suite
                     $GREEN by @K4zi $NC
"""$NC

Main
