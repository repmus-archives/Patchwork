;===============================================;===============================================;;; PWConstraints by Mikael Laurson (c), 1995;===============================================;===============================================(in-package "PWCS");===============================================;============================================================;                basic demos;============================================================; cartesian product;============================================================(length  (PMC (make-list 3 :initial-element (pw::arithm-ser 1 1 3)) ()      :sols-mode :all));============================================================; subset indexes;============================================================#|(defun n! (n)   (cond ((= n 0) 1)         (t (* n (n! (1- n))))));(n! 12)  (defun num-of-subsets (card1 card2)  (truncate (n! card1)(* (n! card2) (n! (- card1 card2)))));(num-of-subsets 88 6)   ;(num-of-subsets 50 4)   ;(num-of-subsets 30 4)   ;(num-of-subsets 8 4)   ;(num-of-subsets 8 6)   |#(time  (length   (PMC (make-list 6 :initial-element (pw::arithm-ser 0 1 7))       '((* ?1 ?2 (?if (< ?1 ?2))))       :sols-mode :all)));============================================================; all permutations;============================================================(time  (length   (PMC (make-list 4 :initial-element '(0 1 4 6))       '((* ?1 (?if (not (member ?1 (rest rl))))))       :sols-mode :all)));============================================================; pyth triangle;============================================================(time  (length   (PMC (make-list 3 :initial-element (pw::arithm-ser 1 1 50))       '((* ?1 ?2 (?if (< ?1 ?2))) ;; avoid redundant cases          (?1 ?2 ?3 (?if (=  (+ (* ?1 ?1) (* ?2 ?2)) (* ?3 ?3)))))       :sols-mode :all)));============================================================; Nqueens;============================================================(defun Nqns-noattack (x y tail) (cond ((null tail) t)        ((member y tail) nil)        (t (let ((fl t)(x1 (length tail)))             (while (and fl tail)               (when (= (abs (- y (pop tail))) (- x x1))                  (setq fl nil))               (decf x1))             fl))))(time  (PMC (make-list 8 :initial-element (pw::arithm-ser 1 1 8))      '((* ?1 (?if (Nqns-noattack len ?1  (rest rl)))))       :print-fl nil :sols-mode :all :rnd? nil));============================================================;============================================================