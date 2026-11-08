#!/bin/sh
# Usage: sh scripts/check-links.sh   (run from the repo root; needs curl)
# Fails if any http(s) link in README.md answers 4xx/5xx.
# A timeout or DNS error (code 000) is a network problem, not a dead link: warn only.
fail=0
[ -f README.md ] || { echo "FAIL README.md not found"; exit 1; }
# tr strips CR so CRLF files do not send "url\r" to curl
for u in $(grep -o 'https\?://[^ )>"`]*' README.md | tr -d '\r' | sed 's/[.,]$//' | sort -u); do
  c=$(curl -sIL -o /dev/null -w '%{http_code}' --max-time 15 "$u")
  case $c in 2*|3*) echo "ok   $c $u";; 000) echo "WARN 000 $u (no response; not counted)";; *) echo "FAIL $c $u"; fail=1;; esac
done
exit $fail
