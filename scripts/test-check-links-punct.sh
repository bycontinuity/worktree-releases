#!/bin/bash
# Trailing-punctuation tests for scripts/check-links.sh. curl is stubbed via PATH; no network.
# Stub: any URL ending in ! ? ; or : gets 404 (it means the punctuation leaked into the URL).
set -u
here=$(cd "$(dirname "$0")" && pwd)
checker="$here/check-links.sh"
fails=0

run_case() {  # name, expected rc (0 or nonzero), README content (printf format)
  name=$1; want=$2; body=$3
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/clp.XXXXXX") || exit 1
  mkdir "$tmp/bin"
  cat > "$tmp/bin/curl" <<'EOF'
#!/bin/sh
for a; do u=$a; done
case "$u" in *[?\;:!]) echo 404;; *) echo 200;; esac
EOF
  chmod +x "$tmp/bin/curl"
  printf "$body" > "$tmp/README.md"
  (cd "$tmp" && PATH="$tmp/bin:$PATH" sh "$checker" >"$tmp/out" 2>&1)
  rc=$?
  if { [ "$want" = 0 ] && [ "$rc" -ne 0 ]; } || { [ "$want" != 0 ] && [ "$rc" -eq 0 ]; }; then
    echo "FAIL $name: rc=$rc want=$want"; sed 's/^/     /' "$tmp/out"; fails=$((fails+1))
  else
    echo "ok   $name (rc=$rc)"
  fi
  rm -rf "$tmp"
}

run_case "exclamation after link is not part of URL" 0 'Visit https://example.com/x!\n'
run_case "question mark after link is not part of URL" 0 'Why https://example.com/x?\n'
run_case "semicolon after link is not part of URL" 0 'See https://example.com/x;\n'
run_case "colon after link is not part of URL" 0 'Site: https://example.com/x:\n'

echo
if [ "$fails" -ne 0 ]; then echo "$fails case(s) failed"; exit 1; fi
echo "all cases passed"
