#!/bin/bash
# Proves the driver still compiles with the current Spite compiler and still works against a live server.
#   bash check.sh            from anywhere
# The compiler is SPITE when set (the path of Spite's bin/spite), otherwise 'spite' on PATH, otherwise a Spite
# checkout beside this repository. The live run needs MongoDB on 127.0.0.1:27017 and is skipped without one.
cd "$(dirname "$0")" || exit 1

# No em dashes anywhere, neither the character nor two hyphens between spaces standing in for one.
em_dash=$(printf '\342\200\224')
stand_in=' -''- '   # written in two pieces so this file does not contain what it refuses
dashes=$(git grep -n -I -F -e "$em_dash" -e "$stand_in")
if [ -n "$dashes" ]; then
    echo "FAILED: em dashes (end the sentence, or use a colon, a comma or parentheses):"; echo "$dashes"; exit 1
fi
echo "writing: no em dashes"

spite="$SPITE"
[ -z "$spite" ] && spite=$(command -v spite)
for candidate in ../spite-language/bin/spite ../SpiteLanguage/bin/spite; do
    [ -z "$spite" ] && [ -x "$candidate" ] && spite="$(cd "$(dirname "$candidate")" && pwd)/spite"
done
if [ -z "$spite" ]; then
    echo "FAILED: no Spite compiler: set SPITE to the path of Spite's bin/spite"; exit 1
fi

"$spite" mongodb_probe --check || { echo "FAILED: the probe does not compile"; exit 1; }
(cd examples && "$spite" scoreboard --check) || { echo "FAILED: the example does not compile"; exit 1; }
echo "compile: the probe and the example"

if ! (exec 3<>/dev/tcp/127.0.0.1/27017) 2>/dev/null; then
    echo "live: skipped, no MongoDB server on 127.0.0.1:27017"
    exit 0
fi
output=$("$spite" mongodb_probe --debug-memory 2>&1)
echo "$output"
allocations=$(echo "$output" | sed -n 's/^allocations: \([0-9]*\) frees: [0-9]*$/\1/p')
frees=$(echo "$output" | sed -n 's/^allocations: [0-9]* frees: \([0-9]*\)$/\1/p')
if ! echo "$output" | grep -qx "passed true" || [ -z "$allocations" ] || [ "$allocations" != "$frees" ]; then
    echo "FAILED: the probe did not pass with balanced allocations"; exit 1
fi
example=$(cd examples && "$spite" scoreboard 2>&1)
if [ "$example" != "Ada, Bo scored 215" ]; then
    echo "FAILED: the example printed:"; echo "$example"; exit 1
fi
echo "live: the probe passed with balanced allocations, and the example printed what the README says"
