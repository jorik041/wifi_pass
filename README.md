# Wifi password list for cracking
## _resources for ethical hacking_

Collection was from torrent "breachcompilation" - contains 1.4 billions passwords but after sort|uniq|akw 'length>8' it contains 320 millions uniq passwords. List was used for last several years for password testing and some services implement for password check (yes, for stoping re-using passwords) 

- uniq passwords
- help for penetration testers to speed up cracking of WPA/WPA2
- ✨Magic ✨

## How to use
check if you missing command 7z 

chmod +x con.sh

./con.sh

## passcheck.sh
Local password checker that builds a SHA-1 k-Anonymity style database from the wordlist and reports how many times a password appears.

Features:
- Offline database built from the provided wordlist
- k-Anonymity buckets (first 5 chars of SHA-1) to avoid full hash lookup files
- Duplicate counting so you see how common a password is
- Risk levels based on frequency (LOW, MEDIUM, HIGH, CRITICAL)
- Single password, file batch, or interactive mode

Setup:
chmod +x passcheck.sh

Build the database:
./passcheck.sh build wifi_pass_full.txt

Check a single password:
./passcheck.sh check "P@ssw0rd123"

Check a file of passwords (one per line):
./passcheck.sh check -f passwords.txt

Interactive mode:
./passcheck.sh check


## Warning

Use your skills to help people not to harm them. List would never produced to be used for evil purpose.

## Thanks 
Complete hacker community because each day is challenge. 

Special tnx to https://dillinger.io/ for formating this document

## version 0.2
Just created - wordlist will be updated

Added serbian wordlist from https://github.com/tperich/serbian-wordlists

## Benchmark

time: 2h30m 
tool: aircrack 
CPU: AMD Ryzen 5900HX

time: 5 minute 
tool: hashcat 
GPU: 3090 RTX

## Licenses
GPLv3 https://www.gnu.org/licenses/gpl-3.0.en.html
