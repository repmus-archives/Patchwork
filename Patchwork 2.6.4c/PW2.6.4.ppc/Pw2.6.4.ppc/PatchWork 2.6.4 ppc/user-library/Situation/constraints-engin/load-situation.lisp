;;Hierarchical domains package;;; Load-all;;;;;; By C. Rueda (c) IRCAM 921129;;;(setf (logical-pathname-translations "Niob�")      '(("**;" "situation:**;")))(setf (logical-pathname-translations "delay")      '(("**;" "Niob�:delay-constraints;**;")))(eval-when (load eval compile)  (load "delay:delay-packages")  (load-once "delay:lazy-delayed-eval")  (load-once "delay:delay-pattern-match"))(eval-when (load eval compile)  (load-once "Niob�:soft-packages")  (load-once "Niob�:Marked-domains(dist)")  (load-once "Niob�:soft-C-engin(dist)")  (load-once "Niob�:const-class(dist)")  (load-once "Niob�:soft-harmonic(dist)")  (load-once "Niob�:constraint-set(dist)")  (load-once "Niob�:AB-rhythm(Dist)")  (load-once "Niob�:sit-functionals")  (load-once "Niob�:situation-modifs" :if-does-not-exist nil))#|(mapc 'compile-file      '(        "delay:delay-packages"        "delay:lazy-delayed-eval"        "delay:delay-pattern-match"        "Niob�:soft-packages"        "Niob�:Marked-domains(dist)"        "Niob�:soft-C-engin(dist)"        "Niob�:const-class(dist)"        "Niob�:soft-harmonic(dist)"        "Niob�:constraint-set(dist)"        "Niob�:AB-rhythm(Dist)"        "Niob�:sit-functionals"        ))|#