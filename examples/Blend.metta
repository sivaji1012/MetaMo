;;;; Blend.metta — Example: equation #9 incremental blend
;;;; Tests: blend-vec primitive, alpha computation, single-step update

!(import! &self "../lib_metamo.metta")

; Test 1: blend-vec preserves tag and blends numerics
!(let $result (MetaMo.blend-vec 0.1 (G 0.8 0.3) (G 0.6 0.7))
  (assertEqual (car-atom $result) G))

; Test 2: blend moves toward target by alpha fraction
; (1-0.1)*0.8 + 0.1*0.6 = 0.78
!(let $result (MetaMo.blend-vec 0.1 (G 0.8) (G 0.6))
  (assertEqual (index-atom $result 1) 0.78))

; Test 3: alpha = 0 → no change
!(let $result (MetaMo.blend-vec 0 (G 0.8 0.3) (G 0.6 0.7))
  (assertEqual $result (G 0.8 0.3)))

; Test 4: alpha = 1 → full replacement with target
!(let $result (MetaMo.blend-vec 1 (G 0.8 0.3) (G 0.6 0.7))
  (assertEqual $result (G 0.6 0.7)))

; Test 5: alpha formula — stub overshoot=0 gives Config.Alpha0
!(assertEqual (MetaMo.alpha 0 0) (MetaMo.Config.Alpha0))

; Test 6: high individuation slows blend (α decreases)
!(let* (($a-base (MetaMo.alpha 0 0))
        ($a-slow (MetaMo.alpha 0.8 0)))
  (assertEqual (< $a-slow $a-base) True))

!(println! "Blend.metta: all tests passed ✓")
