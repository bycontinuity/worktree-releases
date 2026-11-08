#!/bin/bash
# Tests for scripts/check-links.sh. curl is stubbed via PATH; no network.
# Stub: URLs containing a CR byte or "bad" get 404, everything else 200.
set -u
here=$(cd "$(dirname "$0")" && pwd)
checker="$here/check-links.sh"
cr=$(printf '\r')
fails=0

run_case() {  # name, expected rc (0 or nonzero), README content (printf format)
  name=$1; want=$2; body=$3
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/cl.XXXXXX") || exit 1
  mkdir "$tmp/bin"
  cat > "$tmp/bin/curl" <<'EOF'
#!/bin/sh
for a; do u=$a; done
case "$u" in *"$(printf '\r')"*|*bad*) echo 404;; *) echo 200;; esac
EOF
  chmod +x "$tmp/bin/curl"
  if [ -n "$body" ]; then printf "$body" > "$tmp/README.md"; fi
  (cd "$tmp" && PATH="$tmp/bin:$PATH" sh "$checker" >"$tmp/out" 2>&1)
  rc=$?
  if { [ "$want" = 0 ] && [ "$rc" -ne 0 ]; } || { [ "$want" != 0 ] && [ "$rc" -eq 0 ]; }; then
    echo "FAIL $name: rc=$rc want=$want"; sed 's/^/     /' "$tmp/out"; fails=$((fails+1))
  else
    echo "ok   $name (rc=$rc)"
  fi
  rm -rf "$tmp"
}

run_case "clean link exits 0" 0 'See https://example.com/doc.\n'
run_case "broken link exits nonzero" 1 'See https://bad.example.com/x\n'
run_case "CRLF README with clean link exits 0" 0 'See https://example.com/doc\r\nMore text\r\n'
run_case "missing README exits nonzero" 1 ''

echo
if [ "$fails" -ne 0 ]; then echo "$fails case(s) failed"; exit 1; fi
echo "all cases passed"
