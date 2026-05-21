# repl_test.jl — MetaMo warm test runner (use with Revise.jl)
#
# USAGE (one-time JIT warmup, then instant re-runs):
#
#   julia --project=/path/to/Core
#   julia> using Revise, MeTTaCore
#   julia> include("repl_test.jl")
#   julia> run_metamo_tests()

const METAMO_DIR = @__DIR__
const EXAMPLES = ["Blend.metta", "UpdateCycle.metta", "MultiGoal.metta"]

function run_metamo_tests(examples = EXAMPLES; verbose = false)
    println("\n=== MetaMo example suite ===")
    pass = 0; fail = 0

    for name in examples
        f = joinpath(METAMO_DIR, "examples", name)
        print("  $(rpad(name, 30))")
        s = new_core_space(); register_for_space!(s); load_stdlib!(s)

        results = try run_file(f, s) catch e; println("❌  $e"); fail += 1; continue end
        errors = filter(r -> r isa Vector && !isempty(r) && r[1] === :Error, results)

        if isempty(errors)
            println("✓"); pass += 1
        else
            println("❌")
            for e in errors; println("    FAIL: $(to_sexpr(e))"); end
            fail += 1
        end
    end

    println("\n  $pass/$(pass+fail) passed")
    fail == 0
end
