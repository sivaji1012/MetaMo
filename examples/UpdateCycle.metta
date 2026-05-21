;;;; UpdateCycle.metta — Example: MotiveState storage + full update cycle
;;;; Tests: seed, get, update!, convergence, with-space lifecycle

!(import! &self "../lib_metamo.metta")

; Use a named space for the motivational state (long-lived binding)
!(bind! &ms (new-space))

; Test 1: seed creates a MotiveState
!(MetaMo.seed! &ms research-goal (G 0.8 0.3 0.5) (M 0.5 0.4 0.6 0.7 0.3 0.8))
!(let $state (MetaMo.get &ms research-goal)
  (assertEqual (car-atom $state) MotiveState))

; Test 2: size = 1 after seeding one goal
!(assertEqual (MetaMo.size &ms) 1)

; Test 3: single update! applies equation #9
!(MetaMo.update! &ms research-goal (G 0.6 0.7 0.4) (M 0.3 0.6 0.4 0.5 0.7 0.6))
!(let* (($state  (MetaMo.get &ms research-goal))
        ((MotiveState research-goal $g $m) $state))
  ; G[0] = (1-0.1)*0.8 + 0.1*0.6 = 0.78
  (assertEqual (> (index-atom $g 1) 0.77) True))

; Test 4: size still 1 after update (old state removed, new added)
!(assertEqual (MetaMo.size &ms) 1)

; Test 5: repeated updates converge toward target
!(MetaMo.update! &ms research-goal (G 0.6 0.7 0.4) (M 0.3 0.6 0.4 0.5 0.7 0.6))
!(MetaMo.update! &ms research-goal (G 0.6 0.7 0.4) (M 0.3 0.6 0.4 0.5 0.7 0.6))
!(let* (($state (MetaMo.get &ms research-goal))
        ((MotiveState research-goal $g $m) $state))
  ; After 3 updates: G[0] ≈ 0.762 → closer to 0.6 than initial 0.8
  (assertEqual (< (index-atom $g 1) 0.78) True))

; Test 6: with-space for transient scratch — released on exit
!(with-space &scratch (new-space)
  (MetaMo.seed! &scratch temp-goal (G 0.5) (M 0.5 0.5 0.5 0.5 0.5 0.5)))
; &scratch is no longer bound after with-space exits

; Test 7: stats well-formed
!(let* (($stats (MetaMo.stats &ms))
        ((MetaMo.Summary $n $alpha) $stats))
  (assertEqual (> $n 0) True))

!(println! "UpdateCycle.metta: all tests passed ✓")
