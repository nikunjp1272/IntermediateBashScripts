#!/bin/bash

# Basic Web Analysis Script
# This script performs website analysis using only standard Linux tools
# Usage: ./basic_web_analyzer.sh <domain_or_ip>

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}======================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${BLUE}======================================${NC}\n"
}

# Check for required arguments
if [ $# -ne 1 ]; then
    echo -e "${RED}Error: Missing required argument${NC}"
    echo "Usage: $0 <domain_or_ip>"
    exit 1
fi

TARGET=$1

# Determine if input is a domain or IP
if [[ $TARGET =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    IS_IP=true
    echo -e "${GREEN}Target is an IP address: $TARGET${NC}"

    # Try to get reverse DNS
    if command -v host >/dev/null 2>&1; then
        DOMAIN=$(host $TARGET | grep "domain name pointer" | awk '{print $NF}' | sed 's/\.$//')
        if [ -n "$DOMAIN" ]; then
            echo -e "${GREEN}Resolved domain: $DOMAIN${NC}"
        else
            echo -e "${YELLOW}Could not resolve domain name for this IP${NC}"
        fi
    fi
else
    IS_IP=false
    DOMAIN=$TARGET
    echo -e "${GREEN}Target is a domain: $DOMAIN${NC}"

    # Try to resolve IP using host command
    if command -v host >/dev/null 2>&1; then
        IP=$(host $DOMAIN | grep "has address" | head -n 1 | awk '{print $NF}')
        if [ -n "$IP" ]; then
            echo -e "${GREEN}Resolved IP: $IP${NC}"
        else
            echo -e "${YELLOW}Could not resolve IP for this domain${NC}"
        fi
    # Fallback to ping if host is not available
    elif command -v ping >/dev/null 2>&1; then
        IP=$(ping -c 1 $DOMAIN | grep "PING" | awk -F'[()]' '{print $2}')
        if [ -n "$IP" ]; then
            echo -e "${GREEN}Resolved IP: $IP${NC}"
        else
            echo -e "${YELLOW}Could not resolve IP for this domain${NC}"
        fi
    fi
fi

# Create report directory
REPORT_DIR="report_${TARGET}_$(date +%Y%m%d%H%M%S)"
mkdir -p "$REPORT_DIR"
echo -e "${GREEN}Report will be saved to $REPORT_DIR/${NC}"

# Log file
LOG_FILE="$REPORT_DIR/analysis.log"
touch "$LOG_FILE"

# Function to run and log commands
run_cmd() {
    local cmd=$1
    local output_file=$2
    local description=$3

    echo -e "${YELLOW}Running: $cmd${NC}"
    echo "=== $description ===" >> "$output_file"
    echo "Command: $cmd" >> "$output_file"
    echo "Time: $(date)" >> "$output_file"
    echo "" >> "$output_file"

    # Run command and capture output
    eval "$cmd" >> "$output_file" 2>&1
    local status=$?

    echo "" >> "$output_file"
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}Command completed successfully${NC}"
        echo "Status: Success" >> "$output_file"
    else
        echo -e "${RED}Command failed with status $status${NC}"
        echo "Status: Failed (error code $status)" >> "$output_file"
    fi
    echo "=========================================" >> "$output_file"
    echo "" >> "$output_file"

    return $status
}

# Basic information gathering
print_header "Basic Information Gathering"

# Ping test
if command -v ping >/dev/null 2>&1; then
    PING_FILE="$REPORT_DIR/ping.txt"
    run_cmd "ping -c 4 $TARGET" "$PING_FILE" "PING Test"

    # Display basic ping stats
    if [ -f "$PING_FILE" ]; then
        PING_SUMMARY=$(grep -E "transmitted|rtt" "$PING_FILE" | tail -n 2)
        if [ -n "$PING_SUMMARY" ]; then
            echo -e "${CYAN}Ping Summary:${NC}"
            echo -e "${GREEN}$PING_SUMMARY${NC}"
        fi
    fi
else
    echo -e "${YELLOW}Warning: ping command not found${NC}"
fi

# DNS information using host command
if command -v host >/dev/null 2>&1 && [ "$IS_IP" = false ]; then
    print_header "DNS Information"
    DNS_FILE="$REPORT_DIR/dns.txt"

    # A records (IPv4)
    run_cmd "host -t A $DOMAIN" "$DNS_FILE" "A Records for $DOMAIN"

    # AAAA records (IPv6)
    run_cmd "host -t AAAA $DOMAIN" "$DNS_FILE" "AAAA Records for $DOMAIN"

    # MX records (Mail)
    run_cmd "host -t MX $DOMAIN" "$DNS_FILE" "MX Records for $DOMAIN"

    # NS records (Name Servers)
    run_cmd "host -t NS $DOMAIN" "$DNS_FILE" "NS Records for $DOMAIN"

    # TXT records
    run_cmd "host -t TXT $DOMAIN" "$DNS_FILE" "TXT Records for $DOMAIN"

    # Complete DNS information
    run_cmd "host -a $DOMAIN" "$DNS_FILE" "All DNS Records for $DOMAIN"

    # Display key DNS information
    echo -e "${CYAN}Key DNS Information:${NC}"

    # A Records
    A_RECORDS=$(grep "has address" "$DNS_FILE")
    if [ -n "$A_RECORDS" ]; then
        echo -e "${GREEN}IPv4 Addresses:${NC}"
        echo "$A_RECORDS" | while read -r line; do
            echo -e "  ${GREEN}$line${NC}"
        done
    fi

    # AAAA Records
    AAAA_RECORDS=$(grep "has IPv6 address" "$DNS_FILE")
    if [ -n "$AAAA_RECORDS" ]; then
        echo -e "${GREEN}IPv6 Addresses:${NC}"
        echo "$AAAA_RECORDS" | while read -r line; do
            echo -e "  ${GREEN}$line${NC}"
        done
    fi

    # MX Records
    MX_RECORDS=$(grep "mail is handled by" "$DNS_FILE")
    if [ -n "$MX_RECORDS" ]; then
        echo -e "${GREEN}Mail Servers:${NC}"
        echo "$MX_RECORDS" | while read -r line; do
            echo -e "  ${GREEN}$line${NC}"
        done
    fi

    # NS Records
    NS_RECORDS=$(grep "name server" "$DNS_FILE")
    if [ -n "$NS_RECORDS" ]; then
        echo -e "${GREEN}Name Servers:${NC}"
        echo "$NS_RECORDS" | while read -r line; do
            echo -e "  ${GREEN}$line${NC}"
        done
    fi
else
    echo -e "${YELLOW}Warning: host command not found for DNS lookups${NC}"
fi

# WHOIS information
if command -v whois >/dev/null 2>&1; then
    print_header "WHOIS Information"
    WHOIS_FILE="$REPORT_DIR/whois.txt"

    if [ "$IS_IP" = true ]; then
        run_cmd "whois $TARGET" "$WHOIS_FILE" "WHOIS Information for IP $TARGET"
    else
        run_cmd "whois $DOMAIN" "$WHOIS_FILE" "WHOIS Information for Domain $DOMAIN"
    fi

    # Extract key WHOIS information
    if [ -f "$WHOIS_FILE" ]; then
        echo -e "${CYAN}Key WHOIS Information:${NC}"

        if [ "$IS_IP" = false ]; then
            # Domain registration info (different registrars use different formats)
            REGISTRAR=$(grep -i "Registrar:" "$WHOIS_FILE" | head -n 1)
            CREATION=$(grep -i -E "Creation Date:|Created:|Registration Date:" "$WHOIS_FILE" | head -n 1)
            EXPIRY=$(grep -i -E "Expir(y|ation) Date:|Registry Expiry Date:" "$WHOIS_FILE" | head -n 1)
            UPDATED=$(grep -i -E "Updated Date:|Last Modified:" "$WHOIS_FILE" | head -n 1)

            if [ -n "$REGISTRAR" ]; then echo -e "${GREEN}$REGISTRAR${NC}"; fi
            if [ -n "$CREATION" ]; then echo -e "${GREEN}$CREATION${NC}"; fi
            if [ -n "$EXPIRY" ]; then echo -e "${GREEN}$EXPIRY${NC}"; fi
            if [ -n "$UPDATED" ]; then echo -e "${GREEN}$UPDATED${NC}"; fi
        else
            # IP allocation info
            NETRANGE=$(grep -i -E "NetRange:|CIDR:|inetnum:|IP Range:" "$WHOIS_FILE" | head -n 1)
            ORGNAME=$(grep -i -E "OrgName:|Organization:|org-name:|owner:" "$WHOIS_FILE" | head -n 1)
            COUNTRY=$(grep -i -E "Country:|country:" "$WHOIS_FILE" | head -n 1)

            if [ -n "$NETRANGE" ]; then echo -e "${GREEN}$NETRANGE${NC}"; fi
            if [ -n "$ORGNAME" ]; then echo -e "${GREEN}$ORGNAME${NC}"; fi
            if [ -n "$COUNTRY" ]; then echo -e "${GREEN}$COUNTRY${NC}"; fi
        fi
    fi
else
    echo -e "${YELLOW}Warning: whois command not found${NC}"
fi

# HTTP/HTTPS headers with curl
if command -v curl >/dev/null 2>&1; then
    print_header "HTTP/HTTPS Headers"
    HEADERS_FILE="$REPORT_DIR/http_headers.txt"

    # Get HTTP headers
    run_cmd "curl -I -L -s http://$TARGET" "$HEADERS_FILE" "HTTP Headers"

    # Get HTTPS headers
    run_cmd "curl -I -L -s https://$TARGET" "$HEADERS_FILE" "HTTPS Headers"

    # Extract important headers
    if [ -f "$HEADERS_FILE" ]; then
        echo -e "${CYAN}Key HTTP Headers:${NC}"

        SERVER=$(grep -i "Server:" "$HEADERS_FILE" | head -n 1)
        CONTENT_TYPE=$(grep -i "Content-Type:" "$HEADERS_FILE" | head -n 1)
        X_POWERED=$(grep -i "X-Powered-By:" "$HEADERS_FILE" | head -n 1)

        # Security headers
        SECURITY_HEADERS=$(grep -i -E "Strict-Transport-Security:|Content-Security-Policy:|X-XSS-Protection:|X-Frame-Options:|X-Content-Type-Options:" "$HEADERS_FILE")

        if [ -n "$SERVER" ]; then echo -e "${GREEN}$SERVER${NC}"; fi
        if [ -n "$CONTENT_TYPE" ]; then echo -e "${GREEN}$CONTENT_TYPE${NC}"; fi
        if [ -n "$X_POWERED" ]; then echo -e "${GREEN}$X_POWERED${NC}"; fi

        if [ -n "$SECURITY_HEADERS" ]; then
            echo -e "${GREEN}Security Headers:${NC}"
            echo "$SECURITY_HEADERS" | while read -r line; do
                echo -e "  ${GREEN}$line${NC}"
            done
        else
            echo -e "${YELLOW}No security headers detected${NC}"
        fi
    fi

    # Try to detect technologies based on HTTP headers
    if [ -f "$HEADERS_FILE" ]; then
        echo -e "${CYAN}Web Technologies (based on headers):${NC}"

        # Check for common technologies
        if grep -q -i "WordPress" "$HEADERS_FILE"; then
            echo -e "${GREEN}WordPress detected${NC}"
        fi

        if grep -q -i "Drupal" "$HEADERS_FILE"; then
            echo -e "${GREEN}Drupal detected${NC}"
        fi

        if grep -q -i "Joomla" "$HEADERS_FILE"; then
            echo -e "${GREEN}Joomla detected${NC}"
        fi

        if grep -q -i "PHP" "$HEADERS_FILE"; then
            echo -e "${GREEN}PHP detected${NC}"
        fi

        if grep -q -i "ASP.NET" "$HEADERS_FILE"; then
            echo -e "${GREEN}ASP.NET detected${NC}"
        fi

        if grep -q -i "nginx" "$HEADERS_FILE"; then
            echo -e "${GREEN}Nginx detected${NC}"
        fi

        if grep -q -i "Apache" "$HEADERS_FILE"; then
            echo -e "${GREEN}Apache detected${NC}"
        fi

        if grep -q -i "IIS" "$HEADERS_FILE"; then
            echo -e "${GREEN}IIS detected${NC}"
        fi
    fi
else
    echo -e "${YELLOW}Warning: curl command not found${NC}"
fi

# SSL/TLS certificate information with openssl
SSL_TARGET=$TARGET
if [ "$IS_IP" = true ] && [ -n "$DOMAIN" ]; then
    SSL_TARGET=$DOMAIN
fi

if command -v openssl >/dev/null 2>&1; then
    print_header "SSL/TLS Certificate Information"
    SSL_FILE="$REPORT_DIR/ssl.txt"

    # Test HTTPS connection
    echo | openssl s_client -connect $SSL_TARGET:443 -servername $SSL_TARGET 2>/dev/null >/dev/null
    if [ $? -eq 0 ]; then
        # Get certificate information
        run_cmd "echo | openssl s_client -showcerts -servername $SSL_TARGET -connect $SSL_TARGET:443 2>/dev/null | openssl x509 -text -noout" "$SSL_FILE" "SSL Certificate Details"

        # Get certificate validity dates
        CERT_DATES=$(echo | openssl s_client -connect $SSL_TARGET:443 -servername $SSL_TARGET 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)
        if [ -n "$CERT_DATES" ]; then
            echo -e "${CYAN}Certificate Validity:${NC}"
            echo -e "${GREEN}$CERT_DATES${NC}"

            # Extract and check expiry date
            NOTBEFORE=$(echo "$CERT_DATES" | grep "notBefore" | cut -d= -f2)
            NOTAFTER=$(echo "$CERT_DATES" | grep "notAfter" | cut -d= -f2)

            echo -e "${GREEN}Valid From: $NOTBEFORE${NC}"
            echo -e "${GREEN}Valid Until: $NOTAFTER${NC}"

            # Try to determine days until expiry
            if command -v date >/dev/null 2>&1; then
                # Different date formats for different systems
                EXPIRY_SECONDS=$(date -d "$NOTAFTER" +%s 2>/dev/null || date -j -f "%b %d %H:%M:%S %Y %Z" "$NOTAFTER" +%s 2>/dev/null)
                NOW_SECONDS=$(date +%s)

                if [ -n "$EXPIRY_SECONDS" ]; then
                    DAYS_LEFT=$(( ($EXPIRY_SECONDS - $NOW_SECONDS) / 86400 ))
                    if [ $DAYS_LEFT -lt 30 ]; then
                        echo -e "${RED}WARNING: Certificate expires in $DAYS_LEFT days!${NC}"
                    else
                        echo -e "${GREEN}Certificate valid for $DAYS_LEFT more days${NC}"
                    fi
                fi
            fi
        fi

        # Get certificate issuer and subject
        CERT_ISSUER=$(echo | openssl s_client -connect $SSL_TARGET:443 -servername $SSL_TARGET 2>/dev/null | openssl x509 -noout -issuer 2>/dev/null)
        CERT_SUBJECT=$(echo | openssl s_client -connect $SSL_TARGET:443 -servername $SSL_TARGET 2>/dev/null | openssl x509 -noout -subject 2>/dev/null)

        if [ -n "$CERT_ISSUER" ]; then
            echo -e "${GREEN}$CERT_ISSUER${NC}"
        fi

        if [ -n "$CERT_SUBJECT" ]; then
            echo -e "${GREEN}$CERT_SUBJECT${NC}"
        fi

        # Check for basic TLS protocols
        echo -e "${CYAN}Checking supported SSL/TLS protocols:${NC}"

        # Try to test common protocols based on OpenSSL version
        for protocol in ssl2 ssl3 tls1 tls1_1 tls1_2 tls1_3; do
            # Try with different OpenSSL versions (syntax varies)
            echo -n "Testing $protocol: "
            if echo | openssl s_client -connect $SSL_TARGET:443 -$protocol -servername $SSL_TARGET </dev/null >/dev/null 2>&1; then
                echo -e "${GREEN}Supported${NC}"
                echo "Protocol $protocol: Supported" >> "$SSL_FILE"
            else
                # Try alternative format for older OpenSSL versions
                if [ "$protocol" = "tls1_1" ] && echo | openssl s_client -connect $SSL_TARGET:443 -tls1_1 -servername $SSL_TARGET </dev/null >/dev/null 2>&1; then
                    echo -e "${GREEN}Supported${NC}"
                    echo "Protocol $protocol: Supported" >> "$SSL_FILE"
                elif [ "$protocol" = "tls1_2" ] && echo | openssl s_client -connect $SSL_TARGET:443 -tls1_2 -servername $SSL_TARGET </dev/null >/dev/null 2>&1; then
                    echo -e "${GREEN}Supported${NC}"
                    echo "Protocol $protocol: Supported" >> "$SSL_FILE"
                elif [ "$protocol" = "tls1_3" ] && echo | openssl s_client -connect $SSL_TARGET:443 -tls1_3 -servername $SSL_TARGET </dev/null >/dev/null 2>&1; then
                    echo -e "${GREEN}Supported${NC}"
                    echo "Protocol $protocol: Supported" >> "$SSL_FILE"
                else
                    echo -e "${RED}Not Supported (or test failed)${NC}"
                    echo "Protocol $protocol: Not Supported (or test failed)" >> "$SSL_FILE"
                fi
            fi
        done
    else
        echo -e "${YELLOW}HTTPS not available on $SSL_TARGET${NC}"
        echo "HTTPS not available on $SSL_TARGET" >> "$SSL_FILE"
    fi
else
    echo -e "${YELLOW}Warning: openssl command not found${NC}"
fi

# TCP port scan using netcat if available
if command -v nc >/dev/null 2>&1; then
    print_header "Basic Port Scan (using netcat)"
    PORTSCAN_FILE="$REPORT_DIR/portscan.txt"

    echo -e "${CYAN}Scanning common ports...${NC}"

    # Define common ports to scan
    COMMON_PORTS="21 22 23 25 53 80 110 143 443 465 587 993 995 3306 3389 5432 8080 8443"

    # Loop through ports and check if they're open
    for port in $COMMON_PORTS; do
        echo -n "Checking port $port: "
        if nc -z -w 1 $TARGET $port 2>/dev/null; then
            echo -e "${GREEN}Open${NC}"
            echo "Port $port: Open" >> "$PORTSCAN_FILE"

            # Try to get service banner for open ports
            if [ $port -eq 80 ]; then
                echo "HEAD / HTTP/1.0" | nc -w 5 $TARGET $port > "$REPORT_DIR/banner_$port.txt" 2>/dev/null
            elif [ $port -eq 443 ]; then
                # For HTTPS, we'd need openssl to get a proper banner
                if command -v openssl >/dev/null 2>&1; then
                    echo | openssl s_client -connect $TARGET:$port 2>/dev/null | grep "Server:" > "$REPORT_DIR/banner_$port.txt"
                fi
            else
                # Generic banner grabbing
                echo "" | nc -w 5 $TARGET $port > "$REPORT_DIR/banner_$port.txt" 2>/dev/null
            fi

            # Check if we got a banner
            if [ -s "$REPORT_DIR/banner_$port.txt" ]; then
                BANNER=$(head -n 1 "$REPORT_DIR/banner_$port.txt")
                echo "  ${YELLOW}Banner: ${BANNER:0:50}${NC}"
                echo "Banner: ${BANNER:0:50}" >> "$PORTSCAN_FILE"
            fi
        else
            echo -e "${RED}Closed${NC}"
            echo "Port $port: Closed" >> "$PORTSCAN_FILE"
        fi
    done
elif command -v bash >/dev/null 2>&1; then
    # Fallback to bash's built-in /dev/tcp if netcat is not available
    print_header "Basic Port Scan (using Bash /dev/tcp)"
    PORTSCAN_FILE="$REPORT_DIR/portscan.txt"

    echo -e "${CYAN}Scanning common ports...${NC}"

    # Define common ports to scan
    COMMON_PORTS="21 22 23 25 53 80 110 143 443 465 587 993 995 3306 3389 5432 8080 8443"

    # Loop through ports and check if they're open
    for port in $COMMON_PORTS; do
        echo -n "Checking port $port: "
        (echo > /dev/tcp/$TARGET/$port) >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Open${NC}"
            echo "Port $port: Open" >> "$PORTSCAN_FILE"
        else
            echo -e "${RED}Closed${NC}"
            echo "Port $port: Closed" >> "$PORTSCAN_FILE"
        fi
    done
else
    echo -e "${YELLOW}Warning: netcat (nc) command not found, skipping port scan${NC}"
fi

# Traceroute to target
if command -v traceroute >/dev/null 2>&1; then
    print_header "Network Route (traceroute)"
    TRACEROUTE_FILE="$REPORT_DIR/traceroute.txt"

    run_cmd "traceroute -m 20 $TARGET" "$TRACEROUTE_FILE" "Traceroute to $TARGET"

    # Display first few hops
    if [ -f "$TRACEROUTE_FILE" ]; then
        TRACE_SUMMARY=$(grep -v "traceroute to" "$TRACEROUTE_FILE" | head -n 5)
        if [ -n "$TRACE_SUMMARY" ]; then
            echo -e "${CYAN}First few network hops:${NC}"
            echo -e "${GREEN}$TRACE_SUMMARY${NC}"
            if [ $(wc -l < "$TRACEROUTE_FILE") -gt 6 ]; then
                echo -e "${GREEN}...${NC}"
            fi
        fi
    fi
fi

# Summary report
print_header "Analysis Summary"
echo -e "${GREEN}Analysis completed for $TARGET${NC}"
echo -e "${GREEN}Report saved to $REPORT_DIR/${NC}"

# List discovered information
echo -e "${CYAN}Discovered Information:${NC}"

# IP/Domain information
if [ "$IS_IP" = false ] && [ -n "$IP" ]; then
    echo -e "  ${GREEN}Domain: $DOMAIN${NC}"
    echo -e "  ${GREEN}IP Address: $IP${NC}"
elif [ "$IS_IP" = true ] && [ -n "$DOMAIN" ]; then
    echo -e "  ${GREEN}IP Address: $TARGET${NC}"
    echo -e "  ${GREEN}Domain: $DOMAIN${NC}"
elif [ "$IS_IP" = true ]; then
    echo -e "  ${GREEN}IP Address: $TARGET${NC}"
else
    echo -e "  ${GREEN}Domain: $DOMAIN${NC}"
fi

# DNS Information
if [ -f "$REPORT_DIR/dns.txt" ]; then
    echo -e "  ${GREEN}DNS Information: Available${NC}"

    # Count records
    if grep -q "has address" "$REPORT_DIR/dns.txt"; then
        echo -e "  ${GREEN}IPv4 Records: Found${NC}"
    fi

    if grep -q "has IPv6 address" "$REPORT_DIR/dns.txt"; then
        echo -e "  ${GREEN}IPv6 Records: Found${NC}"
    fi

    if grep -q "mail is handled by" "$REPORT_DIR/dns.txt"; then
        echo -e "  ${GREEN}MX Records: Found${NC}"
    fi

    if grep -q "name server" "$REPORT_DIR/dns.txt"; then
        echo -e "  ${GREEN}NS Records: Found${NC}"
    fi
fi

# WHOIS Information
if [ -f "$REPORT_DIR/whois.txt" ]; then
    echo -e "  ${GREEN}WHOIS Information: Available${NC}"
fi

# HTTP/HTTPS Headers
if [ -f "$REPORT_DIR/http_headers.txt" ]; then
    echo -e "  ${GREEN}HTTP Headers: Available${NC}"

    # Check if HTTPS is available
    if grep -q "HTTP/1" "$REPORT_DIR/http_headers.txt" && grep -q "HTTP/2" "$REPORT_DIR/http_headers.txt"; then
        echo -e "  ${GREEN}HTTP/2 Support: Yes${NC}"
    fi

    # Check if security headers were found
    if grep -q -i -E "Strict-Transport-Security:|Content-Security-Policy:|X-XSS-Protection:|X-Frame-Options:" "$REPORT_DIR/http_headers.txt"; then
        echo -e "  ${GREEN}Security Headers: Present${NC}"
    fi
fi

# SSL/TLS Information
if [ -f "$REPORT_DIR/ssl.txt" ]; then
    echo -e "  ${GREEN}SSL/TLS Information: Available${NC}"
fi

# Port scan
if [ -f "$REPORT_DIR/portscan.txt" ]; then
    echo -e "  ${GREEN}Port Scan: Completed${NC}"
    OPEN_PORT_COUNT=$(grep "Open" "$REPORT_DIR/portscan.txt" | wc -l)
    echo -e "  ${GREEN}Open Ports: $OPEN_PORT_COUNT found${NC}"
fi

echo -e "\n${BLUE}======================================${NC}"
echo -e "${CYAN}To view detailed results, check the files in $REPORT_DIR/${NC}"
echo -e "${BLUE}======================================${NC}"
