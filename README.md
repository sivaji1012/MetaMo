# MetaMo — MetaMotivational Framework on MORK

Pure MeTTa implementation of **MetaMo** (Lian & Goertzel 2025) on the
[sivaji1012/Core](https://github.com/sivaji1012/Core) MeTTa engine.

## What it implements

**Equation #9** — incremental self-model blend:

```
x_{t+1} = (1 - α) · x_t  +  α · x*
α = α_0 · (1 - g_over^Ind) + β_0 · g_over^Trans
```

Where `x = (G, M)`:
- `G = (g₁, g₂, …)` — goal intensity vector
- `M = (μ₁, μ₂, …, μ₆)` — modulator vector (valence, arousal, approach, resolution, threshold, securing)

## Paper

Lian & Goertzel (2025). *MetaMo: A Robust Motivational Framework for Open-Ended AGI.*  
AGI 2025 Proceedings (LNAI 16057), Chapter 34, pp. 386–398.

## Usage

```metta
!(import! &self (library lib_metamo))

!(bind! &ms (new-space))
!(MetaMo.seed! &ms my-goal (G 0.8 0.3) (M 0.5 0.4 0.6 0.7 0.3 0.8))
!(MetaMo.update! &ms my-goal (G 0.6 0.7) (M 0.3 0.6 0.4 0.5 0.7 0.6))
!(MetaMo.get &ms my-goal)
; → (MotiveState my-goal (G 0.78 0.34) (M 0.48 0.42 0.58 0.68 0.34 0.78))
```

## API

| Function | Description |
|----------|-------------|
| `(MetaMo.seed! &space goal G M)` | Initialize a goal's MotiveState |
| `(MetaMo.get &space goal)` | Read current MotiveState |
| `(MetaMo.update! &space goal G* M*)` | Apply equation #9 blend |
| `(MetaMo.alpha g-ind g-trans)` | Compute blend rate α |
| `(MetaMo.goal-strength &space goal i)` | Read G[i] |
| `(MetaMo.modulator &space goal i)` | Read M[i] |
| `(MetaMo.stats &space)` | Summary stats |

## Running tests

```bash
# Batch (single JIT warmup)
./test.sh

# Interactive (Revise.jl — instant reruns)
julia --project=../Core
julia> using Revise, MeTTaCore
julia> include("repl_test.jl")
julia> run_metamo_tests()
```

## Scratch spaces

Use `(with-space &scratch (new-space) body...)` for transient evaluation
contexts — releases the space reference on exit, preventing leaks.
Only `bind!` spaces intended to be long-lived.
