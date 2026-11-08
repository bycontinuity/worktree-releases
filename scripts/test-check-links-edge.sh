#!/bin/bash
# Edge-case tests for scripts/check-links.sh (complements test-check-links.sh). curl is stubbed via PATH; no network.
# Stub by URL: "bad" -> 404, "down" -> 503, "moved" -> 301, "timeout" -> 000, everything else 200.
set -u
here=$(cd "$(dirname "$0")" && pwd)
checker="$here/check-links.sh"
fails=0

run_case() {  # name, expected rc (0 or nonzero), README content (printf format), expected output regex
  name=$1; want=$2; body=$3; expect=$4
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/cle.XXXXXX") || exit 1
  mkdir "$tmp/bin"
  cat > "$tmp/bin/curl" <<'EOF'
#!/bin/sh
for a; do u=$a; done
case "$u" in *bad*) echo 404;; *down*) echo 503;; *moved*) echo 301;; *timeout*) echo 000;; *) echo 200;; esac
EOF
  chmod +x "$tmp/bin/curl"
  printf "$body" > "$tmp/README.md"
  (cd "$tmp" && PATH="$tmp/bin:$PATH" sh "$checker" >"$tmp/out" 2>&1)
  rc=$?
  bad=0
  if { [ "$want" = 0 ] && [ "$rc" -ne 0 ]; } || { [ "$want" != 0 ] && [ "$rc" -eq 0 ]; }; then bad=1; fi
  if [ -n "$expect" ] && ! grep -Eq "$expect" "$tmp/out"; then bad=1; fi
  if [ "$bad" -ne 0 ]; then
    echo "FAIL $name: rc=$rc want=$want"; sed 's/^/     /' "$tmp/out"; fails=$((fails+1))
  else
    echo "ok   $name (rc=$rc)"
  fi
  rm -rf "$tmp"
}

run_case "README without links exits 0" 0 'No links here.\n' ''
run_case "timeout (000) warns and exits 0" 0 'See https://timeout.example.com/x\n' '^WARN 000 '
run_case "5xx answer fails" 1 'See https://down.example.com/x\n' '^FAIL 503 '
run_case "3xx answer counts as ok" 0 'See https://moved.example.com/x\n' '^ok   301 '
run_case "markdown link stops at closing paren" 1 'See [x](https://bad.example.com/x)\n' '^FAIL 404 https://bad.example.com/x$'

echo
if [ "$fails" -ne 0 ]; then echo "$fails case(s) failed"; exit 1; fi
echo "all cases passed"
