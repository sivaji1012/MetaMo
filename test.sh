#!/bin/bash
# test.sh — Run MetaMo examples via MeTTaCore (sivaji1012/Core)
#
# Usage:
#   ./test.sh                         # run all examples/
#   ./test.sh examples/Blend.metta    # run single file
#   METTACORE_PATH=/path/to/Core ./test.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLES_DIR="$SCRIPT_DIR/examples"

if [ -n "${METTACORE_PATH:-}" ]; then
    CORE="$METTACORE_PATH"
elif [ -d "$SCRIPT_DIR/../Core" ]; then
    CORE="$SCRIPT_DIR/../Core"
else
    echo "ERROR: MeTTaCore not found. Set METTACORE_PATH or place Core/ adjacent to MetaMo/." >&2
    exit 1
fi

FILES=("${@}");
[ ${#FILES[@]} -eq 0 ] && FILES=("$EXAMPLES_DIR"/*.metta)

# Run all examples in ONE Julia process — one JIT warmup, not N.
# For interactive development use repl_test.jl with Revise.jl instead.
julia --project="$CORE" - "${FILES[@]}" << 'JLEOF'
using MeTTaCore

PASS = 0; FAIL = 0

for f in ARGS
    name = basename(f)
    print("  $(rpad(name, 44))")
    s = new_core_space()
    register_for_space!(s)
    load_stdlib!(s)
    results = try run_file(f, s) catch e; println("❌  ($e)"); global FAIL+=1; continue end
    errors = filter(r -> r isa Vector && !isempty(r) && r[1] === :Error, results)
    if isempty(errors)
        println("✅"); global PASS += 1
    else
        println("❌")
        for e in errors; println("    FAIL: $(to_sexpr(e))"); end
        global FAIL += 1
    end
end

println("\n=== $PASS passed  $FAIL failed ===")
exit(FAIL > 0 ? 1 : 0)
JLEOF
