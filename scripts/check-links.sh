#!/bin/sh
# Fails if any http(s) link in README.md does not answer 2xx/3xx.
fail=0
for u in $(grep -o 'https\?://[^ )>"`]*' README.md | sed 's/[.,]$//' | sort -u); do
  c=$(curl -sIL -o /dev/null -w '%{http_code}' --max-time 15 "$u")
  case $c in 2*|3*) echo "ok   $c $u";; *) echo "FAIL $c $u"; fail=1;; esac
done
exit $fail
