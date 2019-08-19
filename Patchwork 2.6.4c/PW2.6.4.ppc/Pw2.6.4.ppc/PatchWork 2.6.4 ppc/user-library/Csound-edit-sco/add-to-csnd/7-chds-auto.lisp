(in-package "CS-E");********************* suite d'accords de m�me nbre de notes **********************(defun xchds->mn5sco (chdseq)  "ecrit un score csound pour l'orc mn5� partir d'un chordseq comprenant des accords tous de meme taillechaque note suit celle de son rang"  (let* ((chds (pw::chords chdseq))         (dates (mapcar #'pw::t-time chds))         (Lnots (mapcar #'pw::notes chds))         (nchds (length chds))         (nnots (length (first Lnots)))         (vmax (apply 'max (mapcar 'pw::g-max (mapcar #'(lambda (elt) (apply '+ elt))                                                      (mapcar 'pw::get-slot Lnots (pw::cirlist 'pw::vel))))))         (Ltabfs ())         (Ltabas ())         snd-obj p3 p4 p5)    (print (if (< nchds 25) "honk-honk" "ka�-ka�, pmax>50 pour tabs!!"))    (dotimes (n nnots)      (push (xy->tabs dates (mapcar '/ (mapcar  'pw::vel (mapcar 'nth (pw::cirlist n) Lnots))(pw::cirlist vmax))                      1024 (+ 10 n)) Ltabas)      (push (xy->tabs dates (pw::mc->f (mapcar 'pw::midic (mapcar 'nth (pw::cirlist n) Lnots)))                      1024 (+ 10 nnots n)) Ltabfs))        (setf p3 (/ (+ (apply '+ dates) (pw::dur (first (first (last Lnots))))) 100)          p4 (pw::arithm-ser 10 1 (+ 9 nnots))          p5 (pw::arithm-ser (+ 10 nnots) 1 (+ (+ 9 nnots) nnots))          snd-obj (make-obj-snd '(1) '(0) p3 p4 p5 1 32767 1))    (Edit-sco-obj nil snd-obj (append Ltabfs Ltabas '((f 1 0 1024 10 1))))))(defun xy->tabs (Lx Ly npoints no &optional scaler)"ecrit une table gen -7 avec Lx et Lypar d�faut les valeurs de y sont conserv�es sf si scalerqui devient alors la valeur max"  (if scaler (setf Ly (pw::g-scaling/max Ly scaler)))  (first (table no 0 npoints -7 (paramxy (pw::g-round (pw::g-scaling/max Lx npoints))(pw::g-round Ly 4)))));(xy->tabs '(0 10 20 30 40) '(0 10 0 5 0) 1021 1);(xy->tabs '(0 10 20 30 40) '(0 10 0 5 0) 1024 1 1);******************** suite d'accords nombre diff�rents **************************(defun xchds->sco-h (chdseq)  "ecrit un score csound pour l'orc mn6� partir d'un chordseq chaque note monte et descend � freq cste"  (let* ((chds (pw::chords chdseq))         (vmax (apply 'max (mapcar 'pw::g-max                                    (mapcar #'(lambda (elt) (apply '+ elt))                                           (mapcar 'pw::get-slot                                                    (mapcar #'pw::notes chds)                                                   (pw::cirlist 'pw::vel))))))         snd-obj p2 p3 p4 p5)    (print  "honk-honk" )    (setf p2 (pw::g/ (mapcar #'pw::t-time chds) 100)          p3 (pw::g/ (mapcar 'pw::get-slot                                      (mapcar #'pw::notes chds)                                     (pw::cirlist 'pw::dur)) 100)                 p4 (pw::g/ (mapcar 'pw::get-slot                                      (mapcar #'pw::notes chds)                                     (pw::cirlist 'pw::vel)) vmax)          p5 (pw::mc->f (mapcar 'pw::get-slot                                 (mapcar #'pw::notes chds)                                (pw::cirlist 'pw::midic)))          snd-obj (make-obj-snd '(1) p2 p3 p4 p5 1 0.01 0.01 0.1))    (Edit-sco-obj nil snd-obj '((f 1 0 1024 10 1)))))(add-menu-items *utilcsnd* (pw::new-leafmenu "-" ()))(PW-addmenu *utilcsnd*  '(xchds->mn5sco xchds->sco-h))