(in-package pw);********* cr�ation d'un menu LP dans le menu User**********************************(defparameter *Utils-lp*  (new-menu "Utils-lp"))(add-menu-items PW::*pw-menu-patch* *Utils-lp*)#|;*******************************************************************************;****************** taille fenetre pour Mac SE ***********************************************(defun make-new-pw-window (&optional close-button)  (let ((win)        (win-string (concatenate  'string  "PW" (format nil "~D" (incf *pw-window-counter*)))))    (setq win (make-instance 'C-pw-window                :window-title win-string :close-box-p close-button               :view-position (make-point 50 38)                :view-size (make-point 300 180) :window-show t))    (add-menu-items  *pw-windows-menu*        (setf (wins-menu-item win)         (new-leafmenu win-string #'(lambda ()(window-select win)))))    (push win *pw-window-list*)     (update-wins-menu-items win)    win))|#;********* cr�ation de deux modules: s�rie arithm�tiques et g�om�triques*************(defun algeb (init n pas);;;---> L P 2/8/92  (if (= n 0)()      (cons init (algeb (+ pas init) (1- n) pas))));(algeb 10 5 25)-->(10 35 60 85 110)(defun geomt (init n pas)  (if (= n 0)()    (cons init (geomt (* pas init) (1- n) pas))));(geomt 440 5 2)-->(440 880 1760 3520 7040);(geomt 440 5 0.5)-->(440 220.0 110.0 55.0 27.5)(defun cloche (n m e)  (expt 2.7 (- (/ (expt (- n m) 2 ) (expt e 2)))));(cloche 96 48 24)(defun gauss-1 (a b xval moy ecart)(if (= xval 0)()(let ((result ())      (Lx (algeb a xval (/ (- b a) (1- xval)))))    (dolist (xx Lx (reverse result))      (push (cloche xx moy ecart) result)))));(gauss-1 0 2 3 1 1)(defunp arithm-ser2 ;;;---> L P 2/8/92        ((begin fix/float) (step (fix/float (:value 1)))                    (xval (fix/float (:value 5))))        list  "Returns a list of <xval> numbers starting from <begin> with <step>." (algeb begin xval step))(defunp g-sum ((liste numbers?)) numbers? "somme de liste"  (let ((result 0))    (if (atom liste) liste        (dolist (elt liste result)          (setf result (+ result (g-sum elt))))))); (g-sum '(1 2 (3 4 (5))))(defunp gauss-ser ;;;---> L P 2/8/92        ((a fix/float)(b fix/float)(moy fix/float) (ecart (fix/float (:value 1)))                    (xval (fix/float (:value 5))))        list  "donne les images par une courbe gaussienne de xval valeurs prises entre a et b" (gauss-1 a b xval moy ecart))(defunp geomt-ser2 ;;;---> L P 2/8/92        ((begin fix/float) (step (fix/float (:value 1)))                    (xval (fix/float (:value 5))))        list  "Returns a list of <xval> numbers starting from <begin> with <step>." (geomt begin xval step))(defunp intpolx/a-b ;;;---> L P 28/12/92        ((scaler fix/float (:value 0.5)) (a (fix/float (:value 0)))                    (b (fix/float (:value 1))))        number  "Retourne une valeur x �gale � (scaler.b + (1 - scaler).a)" (+ (* scaler b)(* (- 1 scaler) a)))(defunp atan-ser ((a fix/float)(b fix/float)(xvals fix/float)(ecart fix/float)) list        "donne la transform�e de la suite algebrique allant        de <a> � <b> en <xvals> valeurs        par une atan d'ecart <ecart>        (<ecart> < 1 => forte concentration sur 0         <ecart> > 1 => forte dispersion )"  (let ((L ())        (ecart (if (zerop ecart) 0.00000001 ecart))        (liste (algeb a xvals (/ (- b a) (1- xvals)))))    (dolist (elt liste (reverse L))      (push (/ (atan (/ elt ecart))(/ pi 2)) L))));*********************************************************     ;fonction pour interpolations concaves ou convexes au lieu d'exponentielles(defun hyperx-n (x n)  "cr�e une fonction convexe ou concave pour x entre 0 et 1, y entre 0 et 1  fonction d�croissante, si n = 0 => lin�aire, si n > 0 rapide d�croissance"  (setf n (exp n))  (if (= n 1)    (1+ (* -1 x))    (* (- (/ (expt n 2) (+ 1 (- (* x (expt n 2)) x))) 1)(/ 1 (- (expt n 2) 1)))))(defun hyperbol-n (list n)"fragment de fonction hyperbolique de degr� n"  (if (atom list) (hyperx-n list n)      (mapcar #'(lambda (elt) (hyperx-n elt n)) list)));******************************************************;******************************************************;setf-nth(defun setf-nth (n liste elt)  (setf (nth n liste) elt) liste);********************************************************* ;pour r�duction data bpf(defunp bpf-red ((bpf list)                  (option (menu (:menu-box-list (("relatif" . 0) ("absolu" . 1)))))                 (red (fix/float (:value 23))))        list        "donne une liste de x et y pour une version reduite (en nbre de points de bpf)options : relatif = en % du nombre de points entre 0 et 1absolu = en nbre de points exact de sortie"  (if (listp bpf) (mapcar #'bpf-red bpf (cirlist option)(cirlist red))      (let* ((Lx (copy-list (x-points bpf)))             (Ly (copy-list (y-points bpf))))        (resum Lx Ly option red))));**************************************************************(defun resum (Lx Ly option red)  "reduit le nombre d'�l�ments de la liste Lx en fct de l'inverse des poids Ltetaoption = 0 => red est un taux de reduction, option = 1 => red est le nombre d'elements"  (let ((nmx (if (zerop option)(* red (length Lx)) red)) Lteta temp)    (setf Lteta (calc-lteta Lx Ly))    (while (< nmx (length Lx))      (progn  (setf temp (remov-pt Lx  Lteta))              (setf Lx (first temp))              (setf Ly (first (remov-pt Ly Lteta)))              (setf lteta (calc-lteta-red lx ly lteta (second temp)))              ))    (list  Lx Ly)));(resum '(1 2 3 4 5 6 7 8) '(1 2 1 3 1 4 1 5) 1 4)(defun remov-pt (Lx Lteta)"supprime de Lx l'elt situ� au rg de la plus petite valeur de Lteta"  (let ((Lxr (butlast (rest Lx)))(Ltr (butlast (rest Lteta))) indx)    (setf indx (position (apply 'min Ltr) Ltr))    (list (cons (first Lx)(append (remove-nth Lxr indx)(last Lx))) indx))      );(remov-pt '(1 2 3 4 5 6 7 8) '(1 1 1 1 0.2 1 0.1 1 1))    (defun remove-nth (liste n)  (remove (nth n liste) liste :start n :end (1+ n)));(time (repeat 100 (resum '(1 2 3 4 5 6 7 8) '(1 2 3 4 5 6 7 8) 1 4)))->2.5 seconds;(time (repeat 1000 (remove-nth '(1 2 3 4 5 6 7 8 9 10 11 12 13 14) 12)))->1.0 seconds;*********************************************************************(defun calc-lteta-red (lx ly lteta indx)  "on ne recalcule que les points disparus"  (setf lteta (remove-nth Lteta (1+ indx)))  (if (> indx 0)    (setf (nth indx lteta)          (angle_diff (nth (1- indx) lx)(nth (1- indx) ly)                      (nth indx lx)(nth indx ly)                      (nth (1+ indx) lx)(nth (1+ indx) ly))))  (if (< (+ 2 indx)(length lteta))    (setf (nth (1+ indx) lteta)          (angle_diff (nth indx lx)(nth indx ly)                      (nth (1+ indx) lx)(nth (1+ indx) ly)                      (nth (+ 2 indx) lx)(nth (+ 2 indx) ly)))) lteta)                 (defun calc-lteta (lx ly)  (let ((lx+ (cons (first lx) (append lx (last lx))))        (ly+ (cons (first ly) (append ly (last ly))))        (Lteta ()))    (dotimes (n (length lx) (reverse Lteta))      (push (angle_diff (nth n lx+)(nth n ly+)(nth n lx)(nth n ly)                        (nth (+ 2 n) lx+)(nth (+ 2 n) ly+))            Lteta))))(defun angle_diff(x1 y1 x2 y2 x3 y3)  (mod (abs (-       (+ pi (angle-coord (- y2) x2 (- y1) x1))      (+ pi (angle-coord (- y3) x3 (- y2) x2)))) pi));(calc-lteta '(0 1 2 3 4) '(0 1 2 1 0));(angle_diff 1 1 2 2 3 1)(defun angle-coord (x1 y1 x2 y2)"donne entre -pi/2 et pi/2 l'angle entre ox et oMpour l'angle oy et oM, mettre y a la place de x et -x a la place de ypour l'angle -oy et oM, mettre -y a la place de x et x a la place de ypour l'angle -ox et oM, mettre -x a la place de x et -y a la place de y"(if (zerop (- x2 x1)) (/ pi 2)  (atan (/ (- y2 y1)(- x2 x1)))));(angle-coord 0 0 1 0);*********************************************************     ;*********************************************************     ;compte les valeurs r�p�t�es dans une liste(defun compt-vals (liste &optional prec) "compte les valeurs r�p�t�es dans une liste" (let ((L ()) pp)    (dolist (elt (if prec (g/ (mapcar 'round (g* liste (expt 10 prec)))(expt 10 prec)) liste)(sort L #'> :key 'second))      (setf pp (find elt L :key 'first))      (if pp (setf (nth (position elt L :key 'first) L)(list (car pp)(1+ (cadr pp))))          (push (cons elt '(1)) L)))));(compt-vals '(1 2 4 1 2 5 4 5 8 14 55 74 1 4 7 ));*********************************************************     (defun codes->strg (liste-de-codes)(if (atom liste-de-codes)  (setf liste-de-codes (list liste-de-codes)))  (coerce    (let ((Lint()))     (dolist (n liste-de-codes (reverse Lint))       (push (character (+ n 48)) Lint)))   'string));(coerce (mapcar #'character '(a)) 'string)(defun int-number->string (x)  (let ((l ()))(if (zerop x) "0"    (progn (while (> x 0)      (push (codes->strg (abs (- x (* 10 (floor (/ x 10)))))) l)      (setf x (floor (/ x 10)))) (apply #'concatenate 'string l)))))(defun int-nber->strg-spe (x taille)  (let ((l ()))    (progn (while (> taille 0)      (push (codes->strg (abs (- x (* 10 (floor (/ x 10)))))) l)      (setf x (floor (/ x 10))            taille (1- taille))) (apply #'concatenate 'string l))));existe directement avec (ccl::%integer-to-string 5);                ou avec (ccl::flonum-to-string 5.0);(int-number->string 123456789);(int-nber->strg-spe 1456 8);(apply #' concatenate 'string '("4" "5" "6" "1" "2" "3"));$$$$$$$$$$$$$$$$$$$$$$$$$$$$ et vice-versa *************************(defun string-to-number (string)"transforme un string de chiffres en un nombre correspondant"(let ((result ()))  (dolist (char (coerce string 'list) (base10 (reverse result)))  (push  (- (char-code   char) 48) result))));(string-to-number "1234.789")-->1234.789(defun base10 (liste)"transforme une liste de codes de char en un nombre; att:� une soustraction -48 pr�s  "  (let ((number 0)(signe 1)(exptmx (expt-max liste)))    (if (= -3 (car liste))      (setf signe -1)())    (setf liste (remove -3 (remove -2 liste)))    (dotimes (n (length liste) (float (* signe number)))      (setf number (+ number (* (expt 10 (- exptmx n)) (nth n liste)))))));(base10 '(1 2 3 4 -2 7 8 9))-->1234.789(defun expt-max (liste)  (let (n1 n2 n3)    (dotimes (x (length liste)(- n2 n1))      (cond       ((and (not n1)(< -1 (nth x liste) 10))        (setf n1 x n2 x))       ((= -2 (nth x liste))        (setf n3 0))       ((and n1 (not n3) (< -1 (nth x liste) 10))        (setf n2 x))       (t         ())))));(float (base10 '(-3 1 0 3 -2 0 5 0 9)));(expt-max '(-5 1 0 3 -2 0 5 0 9));$$$$$$$$$$$$$$$$$$$$$$$$$$$$ �criture liste dans file  *************************(defun print-list-in-fil (liste nom-fich)  (with-open-file (stream nom-fich                          :direction :output                          :if-exists :append                          :if-does-not-exist :create)   (format stream "~% ~a" liste)(format t "---> print in file: ~a ~%" nom-fich)))(defun print-lists-in-fil (liste nom-fich)"imprime le texte contenu dans liste, une ligne par liste ou par sequence, dans le fichier nom-fich"  (if (or (null nom-fich)(numberp nom-fich))(setf nom-fich (CCL:choose-new-file-dialog                                      :button-string "file"                                      :prompt "Save W")))      (with-open-file (stream nom-fich                              :direction :output                              :if-exists :rename-and-delete                   ;;;;;;;;;  :if-exists :append                              :if-does-not-exist :create)        (dolist (elt liste)          (format stream "~% ~a" elt))        (format t "---> print in file: ~a ~%" nom-fich)));**************************** �criture de liste de listes d'entiers dans un format tableur **************(defun print-nbres-WGZ (ldel nom-fich)"�criture de liste de listes d'entiers dans un format tableur"(with-open-file (stream nom-fich                              :direction :output                              :if-exists :rename-and-delete                   ;;;;;;;;;  :if-exists :append                              :if-does-not-exist :create)  (dolist (l ldel)    (dolist (elt l)      (format stream "~a~a" elt #\Tab))      (format stream "~%" ))    (format t "---> print in file: ~a~%" nom-fich)));****************************** bpfblackdraw **************************************(defvar *var-pattern* *dark-gray-pattern*)(setf *var-pattern* *black-pattern*);(setf *var-pattern* *dark-gray-pattern*)(defmethod view-draw-contents ((self C-multi-bpf-view))  (set-pen-pattern self *var-pattern*)  (with-focused-view self    (let ((bpfs (break-point-functions self)))      (while bpfs         (draw-bpf-function   (pop bpfs) self nil (h-view-scaler self)(v-view-scaler self)))))  (set-pen-pattern self *black-pattern*)  (call-next-method))(defmethod view-draw-contents ((self C-mini-bpf-view))  (let* ((object (application-object (view-container self)))         (bpfs (and object (break-point-functions (editor-view-object object)))))    (with-focused-view self      (draw-rect (point-h (view-scroll-position self)) (point-v (view-scroll-position self))(w self)(h self))      (if (open-state self)        (progn          (when bpfs            (set-pen-pattern self *var-pattern*)            (while bpfs              (draw-bpf-function                (pop bpfs) self nil (h-view-scaler self)(v-view-scaler self)))            (set-pen-pattern self *black-pattern*))            (when (break-point-function self)             (draw-bpf-function                (break-point-function self) self nil (h-view-scaler self)(v-view-scaler self))))        (draw-string 3 9 (doc-string self))))))(defmethod print-draw-contents ((self C-multi-bpf-view))  (set-pen-pattern self *dark-gray-pattern*)  (with-focused-view self    (dolist (bpf (break-point-functions self))      (draw-bpf-function bpf self nil (h-view-scaler self)(v-view-scaler self))))  (set-pen-pattern self *black-pattern*)  (call-next-method))(defunp bpfblackdraw ((color (menu (:menu-box-list (("black" . *black-pattern*)                                                     ("gray" . *dark-gray-pattern*))))))                      nil "change le trait des trac� multibpf"(setf *var-pattern* (eval color)));(bpfblackdraw *black-pattern*);****************************** menus **************************************(PW-addmenu *Utils-lp* '(arithm-ser2 geomt-ser2 gauss-ser atan-ser intpolx/a-b g-sum hyperbol-n))(pw::add-menu-items pw::*Utils-lp* (pw::new-leafmenu "-" ()))(pw::pw-addmenu *Utils-lp* '(bpf-red compt-vals bpfblackdraw))(pw::add-menu-items pw::*Utils-lp* (pw::new-leafmenu "-" ()))(PW-addmenu *Utils-lp* '(print-lists-in-fil  print-nbres-WGZ));********************************************************************(pw::pw-addmenu *Utils-lp* '(bpf-red compt-vals setf-nth))