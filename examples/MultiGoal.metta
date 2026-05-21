;;;; MultiGoal.metta — Example: multiple goals with independent MotiveStates
;;;; Tests: parallel goal tracking, independent convergence, goal introspection

!(import! &self "../lib_metamo.metta")

!(bind! &ms (new-space))

; Seed three concurrent goals (exploration, service, ethics)
!(MetaMo.seed! &ms exploration-goal (G 0.9 0.1) (M 0.7 0.8 0.5 0.4 0.3 0.6))
!(MetaMo.seed! &ms service-goal     (G 0.3 0.8) (M 0.4 0.3 0.7 0.8 0.6 0.5))
!(MetaMo.seed! &ms ethics-goal      (G 0.5 0.5) (M 0.6 0.5 0.6 0.6 0.8 0.7))

; Test 1: three independent states registered
!(assertEqual (MetaMo.size &ms) 3)

; Test 2: each goal has its own state
!(let $s1 (MetaMo.get &ms exploration-goal)
  (assertEqual (car-atom $s1) MotiveState))
!(let $s2 (MetaMo.get &ms service-goal)
  (assertEqual (car-atom $s2) MotiveState))
!(let $s3 (MetaMo.get &ms ethics-goal)
  (assertEqual (car-atom $s3) MotiveState))

; Test 3: update one goal does not affect others
!(MetaMo.update! &ms exploration-goal (G 0.5 0.5) (M 0.5 0.5 0.5 0.5 0.5 0.5))
!(assertEqual (MetaMo.size &ms) 3)

; Test 4: service-goal state unchanged after updating exploration
!(let* (($s (MetaMo.get &ms service-goal))
        ((MotiveState service-goal $g $m) $s))
  (assertEqual (index-atom $g 1) 0.3))

; Test 5: goal introspection via MetaMo.goal-strength
!(let $strength (MetaMo.goal-strength &ms ethics-goal 1)
  (assertEqual $strength 0.5))

; Test 6: goal introspection via MetaMo.modulator
; ethics-goal M = (M 0.6 0.5 0.6 0.6 0.8 0.7)
; index-atom (tag M at 0): 0=M, 1=valence=0.6, ..., 5=threshold=0.8, 6=securing=0.7
!(let $val (MetaMo.modulator &ms ethics-goal 5)
  ; M[5] = threshold = 0.8
  (assertEqual $val 0.8))

!(println! "MultiGoal.metta: all tests passed ✓")
