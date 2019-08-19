(in-package :spdata)(defclass liste-double ()  ((LdeP :initform () :initarg :LdeP :accessor LdeP)   (lg :initform () :initarg :lg :accessor lg)   (ld :initform () :initarg :ld :accessor ld)   (nbre-P :initform 1 :initarg :nbre-P :accessor nbre-P)))(defclass liste-multiple (liste-double)  ((nbre-instts :initform 2 :accessor nbre-instts)));************************************************************(defun make-ldouble (L1 L2)    (make-instance 'liste-double :Lg L1                 :Ld L2))(defun make-lmultiple (L1 L2)    (make-instance 'liste-multiple :Lg L1                 :Ld L2))(defun make-LdeP (LdeP)  (make-instance 'liste-double :LdeP LdeP                 :nbre-P (length LdeP)))(defun xmake-LdeP (LdeP)  (make-instance 'liste-multiple :LdeP LdeP                 :nbre-P (length LdeP)));(setf glon (make-LdeP '((0 1)(2 3)(4 5))));(nbre-P glon);**********************************************************(defmethod apari ((self liste-double) seuil)  (let ((L1 (lg self))(L2 (ld self))(L ()))    (dolist (elt L1 (setf (LdeP self)(reverse L)))      (if (find-elt-seuil elt l2 seuil)        (push (find-elt-seuil elt l2 seuil) L)))))(defmethod apari ((self liste-multiple) seuil)  (let ((L1 (lg self))(L2 (ld self))(L ()))    (dolist (elt L1 (setf (LdeP self)(reverse L)))      (if (xfind-elt-seuil elt l2 seuil)        (push (xfind-elt-seuil elt l2 seuil) L)))));(setf LdeP (make-ldouble  '(500 600 700)   '(510 720 900)));(apari LdeP 100);(Ldep Ldep)(defmethod optim1-l ((self liste-double) i)  ;;((10 8) (10 9) (10 12) (10 0))  (let ((liste (nth i (LdeP self))))   (do* ((n 0 (1+ n))         (ind 0 ))        ((eq n (length liste))(nth ind liste))    (setf ind (if (< (diff-de-P (nth n liste))                     (diff-de-P (nth ind liste)))                n ind)))))(defmethod optim1-l((self liste-multiple) i)  ;;((10 8) (10 9) (10 12) (10 0))   (let ((liste (nth i (LdeP self))))    (do* ((n 0 (1+ n))        (ind 0 ))       ((eq n (length liste))(nth ind liste))    (setf ind (if (< (xdiff-de-P (nth n liste))                     (xdiff-de-P (nth ind liste)))                n ind)))))(defmethod  optim1-apari ((self liste-double))  ;et multiple    (do ((n 0 (1+ n)) L)        ((eq n (length (LdeP self))) (setf (LdeP self) (reverse L)))      (push (optim1-l  self n) L)))(defmethod optim2-apari ((self liste-double))  (let ((L ())        (P ())        (D ()))    (while (setq P (pop (LdeP self)))      (setf D (car (LdeP self)))      (if (equal (max 1 (second P))              (second D))              ;->deux pareils cons�cutifs        (if (< (diff-de-P P)               (diff-de-P D))             ;si le premier �cart est + faible          (and (pop (LdeP self)) (push P (LdeP self)))())        (push P L))) (setf (LdeP self) (reverse L))))(defmethod optim2-apari ((self liste-multiple))  ; remove les duplicats  (let (stockage P D)    (while (setq P (pop (LdeP self)))      (setf D (car (LdeP self)))      (if (equal (max 1 (moy-dt-x (second P)))  ;-->lp 16/8/92                 (moy-dt-x (second D)))           ;->deux pareils cons�cutifs        (if (< (xdiff-de-P P)               ( xdiff-de-P D))             ;si le premier �cart est + faible          (and (pop (LdeP self)) (push P (LdeP self)))())        (push P stockage)))(setf (LdeP self) (reverse stockage))))    ;(setf gui (make-lmultiple '((x 120.0) (220.0 230.0) (440.0 x) (659.2 x) (1108.0 x) (1760.0 x) (x 4000.0); (x 6020.0) (x 7000.0)) '((120.0 x) (240.0 220.0) (x 880.0) (6000.0 x) (7000.0 x) (8000.0 x))));(apari gui 1000);(optim1-apari gui);(optim2-apari gui);(recup-elts gui);(LdeP (optim2-apari (make-LdeP '((1 1) (2 1) (3 3) (4 3) (5 5) ;(6 5) (7 8) (8 8) (9 8)))))(defmethod insert-si-absent ((self liste-double) numero rang n)  (declare (ignore n))  (let ((elt (nth numero (if (eq rang 0) (lg self)(ld self))))        (Lelt ()) stockage)    (push elt Lelt)    (while Lelt      (let ((Paire (pop (LdeP self))))        (cond ((null Paire) (push (cons-x-paire (pop Lelt) rang) stockage))              ((equal (nth rang Paire) elt)               (and (pop Lelt)(push Paire stockage)))              ((> (moy-dt-x Paire) elt)               (and (push (cons-x-paire (pop Lelt) rang) stockage)                    (push Paire stockage)))              (t (push Paire stockage)))))    (setf (LdeP self) (append (reverse stockage) (LdeP self)))))(defmethod insert-si-absent ((self liste-multiple) numero rang n)  (let ((elt (nth numero (if (eq rang 0) (lg self)(ld self))))        (Lelt ()) stockage)    (push elt Lelt)    (while Lelt      (let ((Paire (pop (LdeP self))))        (cond ((null Paire) (push (cons-x-elt  (pop Lelt) rang n) stockage))              ((equal (nth rang Paire) elt)               (and (pop Lelt)(push Paire stockage)))              ((> (moy-dt-x Paire) (moy-dt-x elt))               (and (push (cons-x-elt  (pop Lelt) rang n) stockage)                    (push Paire stockage)))              (t (push Paire stockage)))))    (setf (LdeP self) (append (reverse stockage) (LdeP self))))); (insert-si-absent obj 0 0 1)(defmethod recup-elts ((self liste-double))    (do ((n 0 (1+ n)))      ((eq n (length (Lg self))) ()) (insert-si-absent self n 0 1))  (do ((n 0 (1+ n)))      ((eq n (length (Ld self))) ()) (insert-si-absent self n 1 1)))(defmethod recup-elts ((self liste-multiple))   (do ((n 0 (1+ n)))      ((eq n (length (Lg self))) ())     (insert-si-absent self n 0 (taille (car (Ld self)))))  (do ((n 0 (1+ n)))      ((eq n (length (Ld self))) ())     (insert-si-absent self n 1 (taille (car (Lg self))))))#|;-->test(setf obj3 (make-lmultiple '((10 11)(20 21)(31 32)) '(10 16 32 65)))(progn  (setf obj (make-ldouble '(10 15 30 50) '(10 16 32 65)))   (apari obj 100)  (optim1-apari obj)  (optim2-apari obj)  (recup-elts obj)(LdeP obj))|#(defmethod appariement ((self liste-double) seuil)   (apari self seuil)  (optim1-apari self)  (optim2-apari self)  (recup-elts self)(LdeP self))(defmethod appariement ((self liste-multiple) seuil)   (apari self seuil)  (optim1-apari self)  (optim2-apari self)  (recup-elts self)(LdeP self));************** old pour compatibilit� ***************************************************(defmethod appariement2 ((self liste-double) seuil type)"type = type du seuil puis type de la liste"  (let ((l1 (lg self))        (l2 (ld self)))    (cond ((equal type '("midic" "Hz"))           (setf (LdeP self)                  (f->mc2                   (appariement                    (make-ldouble (mc->f2 L1)                                 (mc->f2 L2))                    (- 0 seuil)))))          ((equal type '("Hz" "midic"))           (appariement self seuil))          (t           (appariement self (- 0 seuil))))    (LdeP self)))(defmethod appariement2 ((self liste-multiple) seuil type)  (let ((l1 (lg self))        (l2 (ld self)))    (cond ((equal type '("midic" "Hz"))           (setf (LdeP self)                  (f->mc2                   (appariement                    (make-lmultiple (mc->f2 L1)                                 (mc->f2 L2))                    (- 0 seuil)))))          ((equal type '("Hz" "midic"))           (appariement self seuil))          (t           (appariement self (- 0 seuil))))    (LdeP self)))  ;************** new pour plus de simplicit�  ***************************************************(defmethod appariement3 ((self liste-double) seuil type)"type = type du seuil puis type de la liste"    (cond ((equal type "Hz")           (appariement self (- 0 seuil)))          (t           (appariement self seuil)))    (LdeP self))(defmethod appariement3 ((self liste-multiple) seuil type)    (cond ((equal type "Hz")           (appariement self (- 0 seuil)))          (t           (appariement self seuil)))    (LdeP self));(appariement (make-lmultiple '((10 11)(20 21)(25 25)(29 30)) '(10 16 32 65)) 100);(appariement2 (make-lmultiple '((10 11)(20 21)(25 25)(29 30)) '(10 16 32 65)) 100 "midic");(appariement3 (make-lmultiple '((10 11)(20 21)(25 25)(29 30)) '(10 16 32 65)) 100 "midic");****************************************************************************(defmethod compar-apari ((objf liste-double) (obj2 liste-double))  (let* (( LdeP2 ())         (L1 (lg obj2))         (L2 (ld obj2))         (n1 (taille (car L1)))         (n2 (taille (car L2))))      (dolist (Paire (LdeP objf) (setf (LdeP obj2) (reverse LdeP2)))        (cond ((zerop (moy-dt-x (car Paire)))               (push (cons-x-elt (pop L2) 1 n1) LdeP2))              ((zerop (moy-dt-x (second Paire)))               (push (cons-x-elt (pop L1) 0 n2) LdeP2))              (t               (push (list (pop L1)(pop L2)) LdeP2))))));(setf obj2 (make-ldouble '(1 1 1 1) '(10 10 10 10)));(compar-apari obj obj2) (LdeP obj2);**************************************************************************;**********************    INTERPOLATIONS      ****************************;**************************************************************************;interpolations doubles:(defmethod intpolf1 ((self liste-double) scaler)  (let (L)    (dolist (P (LdeP self) (reverse L))      (push (if (zerop (min (moy-dt-x(car P))(moy-dt-x(cadr P))))              (max (moy-dt-x(car P))(moy-dt-x(cadr P)))            (+ (* (- 1 scaler) (car P))(* scaler (cadr P)))) L ))))(defmethod intersect ((self liste-double) scaler)  (let (L)    (dolist (P (LdeP self) (reverse L))      (if (zerop (min (moy-dt-x(car P))(moy-dt-x(cadr P))))        ()        (push (+ (* (- 1 scaler) (car P))(* scaler (cadr P))) L)))))(defmethod intpolfreqs ((self liste-double) scaler flag)  (let ((scalspec (cond                    ((< scaler 0.25) 0)                   ((< scaler 0.5)(- (* 4 scaler) 1))                   ((< scaler 0.75) 1)                   (t (- 4 (* 4 scaler))))))    (cond ((= flag 0) ;elt gauche seult            (lg self))          ((or (= flag 1)(= flag 4)) ; intersec + mixage               (intpolf1 self scaler))          ((or (= flag 2)(= flag 5)) ; mixage (pas d'appariements)               (append (lg self) (ld self)))          ((= flag 3) ; intersec seult (pas de freq isol�es)           (intersect self scaler))          ((= flag 6) ; = scaler <0.5 instg sinon instd pour freqs           (if (< scaler 0.5) (lg self) (ld self)))          ((= flag 7) ; double interpol pour les freqs           (intpolf1  self scalspec)))));(intpolfreqs obj 0.5 7)#|(progn  (setf obj (make-ldouble '(100 105 205 300 500 800) '(100 106 302 605)))   (apari obj 100)  (optim1-apari obj)  (optim2-apari obj)  (recup-elts obj)(intpolfreqs obj 0.4 7))|#;**************************************************;amplitudes(defmethod intpola1 ((self liste-double) scaler)  (let (Lamps        (Lamps1 (Lg self))        (Lamps2 (Ld self)))    (dolist (P (LdeP self) (reverse Lamps))      (if (< (length (pw::flat P)) 3)        (push (scal-Pair-dtx P scaler) Lamps)        (cond ((zerop (moy-dt-x (car P)))               (push (* scaler (pop Lamps2)) Lamps))            ((zerop (moy-dt-x (second P)))             (push (* (- 1 scaler) (pop Lamps1)) Lamps))            (t             (push (abs (+ (* (- 1 scaler)(pop Lamps1))                           (* scaler (pop Lamps2)))) Lamps)))))))#|; des probl�mes se posent lorsqu'on interpole des mod�les dont les amplitudes sont nulles(defun scal-Pair-dtx (Paire scaler)  (let ((A (car Paire))        (B (second Paire)))    (setf A (if (numberp A) A 0)          B (if (numberp B) B 0))    (abs (+ (* (- 1 scaler) A)(* scaler B)))))|#;(intersecta obj2 0)(defmethod intersecta ((self liste-double) scaler)  (let (Lamps        (Lamps1 (Lg self))        (Lamps2 (Ld self)))    (dolist (P (LdeP self) (reverse Lamps))      (cond ((zerop (moy-dt-x (car P)))(pop Lamps2))            ((zerop (moy-dt-x (second P)))(pop Lamps1))            (t             (push (abs (+                          (* (- 1 scaler) (pop Lamps1))                         (* scaler (pop Lamps2)))) Lamps))))))(defmethod intpolamps ((self liste-double) scaler flag)  (let ((scalspec (cond                    ((< scaler 0.25) 0)                   ((< scaler 0.5)(- (* 4 scaler) 1))                   ((< scaler 0.75) 1)                   (t (- 4 (* 4 scaler))))))    (cond ((= flag 0) ;elt gauche seult            (lg self))          ((or (= flag 1) (= flag 4)); intersec + mixage           (intpola1 self scaler))          ((or (= flag 2)(= flag 5)) ; mixage (pas d'appariements)           (append (rescale (lg self)(- 1 scaler))                   (rescale (ld self) scaler)))          ((= flag 3) ; intersec seult (pas de freq isol�es)           (intersecta self scaler))          ((= flag 6) ; = scaler <0.5 instg sinon instd pour freqs           (if (< scaler 0.5) (lg self)(ld self)))          ((= flag 7) ; double interpol pour les freqs           (intpola1 self scalspec)))));***********************************************************************;largeurs de bandes(defmethod intpolbw1 ((self liste-double) scaler)   (let (Lbws        (Lbws1 (Lg self))        (Lbws2 (Ld self)))    (dolist (P (LdeP self) (reverse Lbws))      (cond ((zerop (moy-dt-x (car P))) (push (pop Lbws2) Lbws))            ((zerop (moy-dt-x (second P))) (push (pop Lbws1) Lbws))            (t (push (scalbw (pop Lbws1)(pop Lbws2) scaler) Lbws))))));(intersectbw obj2 0.8)(defmethod intersectbw ((self liste-double) scaler)  (let (Lbws        (Lbws1 (Lg self))        (Lbws2 (Ld self)))    (dolist (P (LdeP self) (reverse Lbws))      (cond ((zerop (moy-dt-x (car P)))(pop Lbws2))            ((zerop (moy-dt-x (second P)))(pop Lbws1))            (t (push (scalbw (pop Lbws1)(pop Lbws2) scaler) Lbws))))))(defmethod intpolbwres       ((self liste-double) scaler resmoy1/2) ;-->les freq appari�es restent interpol�es   (let (Lbws        (Lbws1 (Lg self))        (Lbws2 (Ld self)))   (dolist (P (LdeP self) (reverse Lbws))     (cond ((zerop (moy-dt-x (car P)))(push (* (pop Lbws2)                                     (expt resmoy1/2 (- scaler 1))) Lbws))            ((zerop (moy-dt-x (second P))) (push (* (pop Lbws1)                                        (expt resmoy1/2 scaler)) Lbws))           (t (push (scalbw (pop Lbws1)(pop Lbws2) scaler) Lbws))))));(intpolbws obj2 0.7 10 7)(defmethod intpolbws  ((self liste-double) scaler flag resmoy1/2)  (let ((scalspec (cond                    ((< scaler 0.25) (* 4 scaler))                   ((< scaler 0.5) 1)                   ((< scaler 0.75)(- 3 (* 4 scaler)))                   (t 0))))    (cond  ((= flag 0) ;elt gauche seult             (lg self))           ((= flag 1) ; intersec + mixage            (intpolbw1 self scaler))           ((= flag 2) ; mixage (pas d'appariements)            (append (lg self)(ld self)))           ((= flag 3) ; intersec seult (pas de freq isol�es)            (intersectbw self scaler))           ((= flag 4) ; = resmoy !            (intpolbwres self scaler resmoy1/2))           ((= flag 5) ; = type2 pour les freq            (append (rescale (lg self) (expt resmoy1/2 scaler))                    (rescale (ld self) (expt resmoy1/2 (- scaler 1)))))           ((= flag 6) ; = scaler <0.5 instg sinon instd pour freqs            (if (< scaler 0.5) (rescale (lg self) (expt resmoy1/2 (* 2 scaler)))                (rescale (ld self) (expt resmoy1/2 (- 1 (* 2 scaler)))))) ;-->� v�rifier           ((= flag 7) ; double interpol pour les freqs            (intpolbwres self scalspec resmoy1/2)))));*******************************************************************************************************;*******************************************************************************************************;**cr�ation d'un module permettant de tester l'interpolation entre deux instruments sur des listes***(defunp apprt-Hzs ((Lfg list)(Lfd list)                    (seuil numbers?) &optional                    (sl-typ menu (:menu-box-list (("midic" . "midic") ("Hz" . "Hz"))                                                :type-list (no-connection)))                   ) list        "fournit une liste de paires de frequence apr�s intersection des   deux listes en entr�e, les valeurs proches sont appari�es de fa�on optimale   pour des distances inf�rieures � seuil" (appariement3 (make-lmultiple Lfg Lfd) seuil sl-typ))(pw-addmenu *analyse-menu*  '(apprt-Hzs))(export 'apprt-Hzs);**************************************************************************;**************************************************************************;interpolations multiples:;----fonctions pr�alables:-------------;(defun fmultiscal (Paire scalers) ;fi = S(fi*si)/S(si) (pour fi<>0)  (let ((sum 0)(sumscal 0)        (liste (remove 'x (pw::flat  Paire)))        (scalers2 (remove 'x (x->0compare (pw::flat paire) scalers))))(if (zerop (moy-dt-x scalers2)) (cons (moy-dt-x liste)())   ; (if (eq 1 (length liste)) liste        (do ((n 0 (1+ n)))            ((eq n (length liste))(cons (/ sumscal sum)()))          (setf sum (+ sum (nth n scalers2)))          (setf sumscal (+  sumscal (* (nth n scalers2)                                       (moy-dt-x (nth n liste)))))))));(fmultiscal '((x 142.0123456789)(x x)) '(0.0 0.0 0.0 0.0))(defun amultiscal (Paire liste-de-scaler)  ;ai = S(ai*si)/S(si) pour tout ai  (let ((sum 0)(sumscal 0)(scalers liste-de-scaler)(liste (pw::flat paire)))(if (zerop (som-dt-x (compar-l-scal liste liste-de-scaler))) '(0)    (dolist (elt liste (cons (/ sum sumscal)()))          (and (setf sum (+ (* (moy-dt-x elt) (car scalers)) sum))               (setf sumscal (+ (pop scalers) sumscal)))))));(amultiscal '((1 x) 1) '(1 0 0))(defun bwmultiscal (paire liste-de-scalers)  (let* ((result 0)         (liste (pw::flat paire))         (sumscal 0))    (if (zerop (som-dt-x (compar-l-scal liste liste-de-scalers)))(moybw liste)        (do ((n 0 (1+ n)))            ((eq n (length liste)) (/  sumscal result))          (if (zerop (moy-dt-x (nth n liste))) ()              (and (setf result (+ result                                    (/ (nth n liste-de-scalers)                                       (moy-dt-x (nth n liste)))))                   (setf sumscal (+ sumscal (nth n liste-de-scalers)))))))));(float (bwmultiscal '((1 10)(x x)) '(1 1 0 1)))(defun scal1/2 (n1 n2 scalers)  (if (endp scalers) 0       (let ((a  (som-dt-x (extrait scalers 0 n1)))            (b (som-dt-x (extrait scalers n1 n2))))        (if (= b 0) 0 (/ b (+ a b))))));(scal1/2 2 2 '(0 0 0 0))(defun x->0compare (mf mbw)    (do ((n 0 (1+ n))(l ()))      ((eq n (length mf))  (reverse L))    (push (if (zerop (moy-dt-x (nth n mf))) 'x (nth n mbw)) l)));(x->0compare '(1 x 5 0 1) '(10 2 1 2 3))(defun xrescale (Paire scalers)  (do ((n 0 (1+ n)) (liste (pw::flat Paire)) result)      ((eq n (length liste))(reverse result))    (if (numberp (nth n liste))      (push (/ (* (moy-dt-x (nth n liste))                  (nth n scalers))(som-dt-x scalers)) result)())));(xrescale '(1 x)'(1 9))(defun resmoyscal (scalers resmoy)  ;S(resmoy ^ scal)  (let ((resmoyscal 0)(sumscal (som-dt-x scalers)))    (do ((n 0 (1+ n)))        ((eq n (length resmoy)) (/ resmoyscal sumscal))      (setf resmoyscal (+ (* (nth n resmoy)(nth n scalers)) resmoyscal)))));(resmoyscal '(1 1 1 1)  '(1 2 3 4))(defun scal-bw/res (bw0 scal0 res0 scalers resmoyscal)  (* bw0 (expt (/ res0 resmoyscal)               (/ (- (som-dt-x scalers) scal0)                  (som-dt-x scalers)))));****************************************(defmethod Pdefi->lf ((self liste-multiple) i scalers flag) (let*  ((Paire (nth i (LdeP self)))         (scalers2 (extrait scalers 0 (length (pw::flat Paire))))         (scal1/2 (scal1/2 (taille (car Paire)) (taille (cadr Paire)) scalers2)))   (cond ((= flag 0) (cons (car (pw::flat Paire))()))          ((or (= flag 1)(= flag 4)) (fmultiscal Paire scalers2))           ((or (= flag 2)(= flag 5))(remove 'x (pw::flat Paire)))          ((= flag 3) (if (member 'x (pw::flat Paire)) 'x                          (fmultiscal Paire scalers2)))            ((= flag 6) (fmultiscal Paire (cons 1 (make-list (- (length (pw::flat paire)) 1)                                                           :initial-element 0))))          ((= flag 7) (cond ((< scal1/2 0.25)                             (car Paire))                            ((> scal1/2 0.75)                             (cadr Paire))                            (t (fmultiscal Paire scalers2)))))))(defmethod intpolfreqs ((self liste-multiple) scalers flag)  (do* ((n 0 (1+ n))        Lf         Ldef)       ((eq n (length (LdeP self))) (remove 'x (reverse (pw::flat Ldef ))))    (setf Lf (Pdefi->lf self n scalers flag))        (if (equal 'x Lf)()            (push (reverse Lf) Ldef))));(intpolfreqs obj3 '(1 1 1) 3);******* amplitudes(defmethod Pdeai->la ((self liste-multiple) i scalers flag)  (let* ((Paire (nth i (LdeP self)))         (scalers (extrait scalers 0 (length (pw::flat Paire))))         (scal1/2 (scal1/2 (taille (car Paire)) (taille (cadr Paire)) scalers)))    (cond ((= flag 0) (cons (car (pw::flat Paire))()))                    ((or (= flag 1)(= flag 4)) (amultiscal Paire scalers))           ((or (= flag 2)(= flag 5)) (xrescale Paire scalers))          ((= flag 3)(if (member 'x (pw::flat Paire)) 'x                          (amultiscal Paire scalers)))                ((= flag 6) (amultiscal Paire (cons 1 (make-list (- (length (pw::flat paire)) 1)                                                           :initial-element 0))))          ((= flag 7) (cond ((< scal1/2 0.25)                             (car Paire))                            ((> scal1/2 0.75)                             (cadr Paire))                            (t (amultiscal Paire scalers)))))))(defmethod intpolamps ((self liste-multiple) scalers flag)  (do* ((n 0 (1+ n)) La Ldea)       ((eq n (length (LdeP self))) (remove 'x (reverse (pw::flat Ldea ))))    (setf La (Pdeai->la self n scalers flag))    (if (equal 'x La)()        (push (reverse La) Ldea))));(intpolamps obj3 '(1 1 1) 0)(defmethod calc-resmoys ((obja liste-double)(objb liste-double))  (let ((La (mapcar #'pw::flat (LdeP obja)))(Lbw (mapcar #'pw::flat (LdeP objb)))         resmoy (sumres 0)(sumamp 0))    (do ((n 0 (1+ n)))        ((eq n (length (car La))) (reverse resmoy))      (setf sumres 0 sumamp 0)      (do ((i 0 (1+ i)))          ((eq i (length La))(push (expt (/ sumres sumamp) 0.5) resmoy))        (if (equal 'x (nth n (nth i Lbw)))()            (and             (setf sumres (+ sumres (* (nth n (nth i La))                                       (expt (/ (nth n (nth i Lbw))) 2))))             (setf sumamp (+ sumamp (nth n (nth i La))))))))));(calc-resmoys obj3 obj3)(defmethod scalres ((self liste-multiple) i scalers resmoy )  (let ((result ())        (liste (pw::flat (nth i (LdeP self)))))    (do ((n 0 (1+ n)))        ((eq n (length liste)) (reverse result))      (if (zerop (moy-dt-x (nth n liste))) ()          (push            (scal-bw/res (nth n liste)                     (nth n scalers)                    (nth n resmoy)                     scalers                    (resmoyscal scalers resmoy))           result)))))(defmethod scalres2 ((self liste-multiple) i scalers resmoy )  (let* ((liste (pw::flat (nth i (LdeP self))))         (liste2 (remove 'x liste)))    (if (eq 1 (length liste2))  (scal-bw/res (car liste2)           (moy-dt-x (x->0compare liste scalers))           (moy-dt-x (x->0compare liste resmoy))           scalers            (resmoyscal scalers resmoy))(bwmultiscal (nth i (LdeP self)) scalers))))(defmethod  Pdebwi->lbw ((self liste-multiple) i scalers flag resmoy)  (let* ((Pairebw (nth i (LdeP self)))         (scalers (extrait scalers 0 (length (pw::flat Pairebw)))))  (cond ((= flag 0) (cons (car (pw::flat Pairebw))()))        ((= flag 1) (bwmultiscal Pairebw scalers))        ((= flag 2) (remove 'x (pw::flat Pairebw)))        ((= flag 3) (if (member 'x (pw::flat Pairebw)) 'x                      (bwmultiscal Pairebw scalers)))         ((= flag 4) (cons (scalres2 self i scalers resmoy)()))        ((= flag 5) (scalres self i scalers resmoy))        ((= flag 6) (cons (scalres2 self i scalers resmoy)()))        ((= flag 7) (bwmultiscal Pairebw scalers)))))(defmethod intpolbws ((self liste-multiple) scalers flag resmoy)  (do ((n 0 (1+ n))       (Lbw (Pdebwi->lbw self 0 scalers flag resmoy)            (Pdebwi->lbw self (+ n 1) scalers flag resmoy))       Ldebw)      ((eq n (length (LdeP self))) (remove 'x (reverse (pw::flat Ldebw))))    (if (equal 'x Lbw)() (push (if (atom Lbw) Lbw (reverse Lbw)) Ldebw))));coin  