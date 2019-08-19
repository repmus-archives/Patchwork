(in-package :spdata);******************* F R E Q U E N C E S *************************;fr�quence moyenne (pond�r�e amp-corr)(defun freq-moy (liste)  (let ((freqs (car liste))        (amps (cadr liste))        (bws (caddr liste))         (result 0) (poids 0))    (while freqs      (setf poids (+ poids (amp-corr (car amps)(car bws))))      (setf result (+ result (* (pop freqs)                                (amp-corr (pop amps)(pop bws))))))    (if (= 0 poids) 0 (float (/ result poids)))))(defun freq-ecartyp (liste)  (let ((freqs (car liste))        (amps (cadr liste))        (bws (caddr liste))         (result 0) (poids 0))    (while freqs      (setf poids (+ poids (amp-corr (car amps)(car bws))))      (setf result (+ result (* (amp-corr (pop amps)(pop bws))                                (expt (- (pop freqs)                                         (freq-moy liste)) 2)))))    (expt (if (= 0 poids) 0 (/ result poids)) (/ 1 2))));(freq-moy '((440 880)(10.0 1)(1 1)));(freq-ecartyp '((440 880)(10.0 1)(1 1)));(setf slaptub (list l-freqf l-amplf l-bandf));(freq-moy slaptub) -> 208.577;(freq-ecartyp slaptub) -> 255.4                  ;non ex :13.563;(freq-moy vibra6000) -> 978.607;(freq-ecartyp vibra6000) -> 1205.71                   ;non ex : 371.383(defun modif-aux (freq  m1 m sigma1 sigma)  (exp(- (/ (expt (- freq m1) 2) (if (= 0 sigma1) 1 (* 2 (expt sigma1 2))))         (/ (expt (- freq m) 2) (if (= 0 sigma) 1 (* 2 (expt sigma 2)))))));(modif-aux 440  440 330 1000 1000)(defun f-modif-moy (vfreqs vamps m1 m2 sigma1 sigma2)  (let ((Lresult ()))    (do ((n 0 (1+ n)))        ((eq n (length vamps))(reverse Lresult))      (push (* (nth n vamps)(modif-aux (nth n vfreqs)                                       m1 m2                                       sigma1 sigma2))            Lresult))));(f-modif-moy '(440 880) '(1 1) 500 600 100 100)(defun somme (liste)  (let ((result 0))    (dolist (elt liste result)      (setf result (+ result elt)))))(defun f-modif-moy-amps       (vfreqs vamps vbws m  sigma)  (let ((m1 (freq-moy (list vfreqs vamps vbws)))        (sigma1 (freq-ecartyp (list vfreqs vamps vbws))) amps)    (setf amps (f-modif-moy vfreqs vamps m1 m sigma1 sigma))    (mapcar #'(lambda (elt)                 (* elt (/ (somme vamps) (if (= 0 (somme amps)) 1                                             (somme amps))))) amps)));(f-modif-moy-amps '(440 660) '(2 1) '(15 15) 440 110)(defunp f-moy-modif         ((vfreqs list) (vamps list)(vbws list)         (m integer)(sigma integer)) list        "calcule la fr�quence moyenne et l'�carttype d'une s�rie de formantspuis transforme la liste des amplitudes et des bws en fct des nouvellesvaleurs de moy et ecartype"           (let ((m1 (freq-moy (list vfreqs vamps vbws)))        (sigma1 (freq-ecartyp (list vfreqs vamps vbws))) amps)    (setf amps (f-modif-moy vfreqs vamps m1 m sigma1 sigma))    (mapcar #'(lambda (elt)                 (* elt (/ (somme vamps) (if (= 0 (somme amps)) 1                                             (somme amps))))) amps)));********* N O T E S   M I D I ********************;midic moyenne (pond�r�e amp-corr)(defun midic-moy (liste)  (let ((midics (pw::f->mc (car liste)))        (amps (cadr liste))        (bws (caddr liste))        (result 0) (poids 0))    (while midics      (setf poids (+ poids (amp-corr (car amps)(car bws))))      (setf result (+ result (* (pop midics)                                (amp-corr (pop amps)(pop bws))))))    (if (= 0 poids) 0 (float (/ result poids)))))(defun midic-ecartyp (liste)  (let ((midics (pw::f->mc (car liste)))        (amps (cadr liste))        (bws (caddr liste))         (result 0) (poids 0))    (while midics      (setf poids (+ poids (amp-corr (car amps)(car bws))))      (setf result (+ result (* (amp-corr (pop amps)(pop bws))                                (expt (- (pop midics)                                         (midic-moy liste)) 2)))))    (expt (if (= 0 poids) 0 (/ result poids)) (/ 1 2))));(midic-moy '((500 510)(1 1)(1 1)));(midic-ecartyp '((440 880)(1 1)(1 1)));(moymidic vibra -> 7283 midics;(ecartmidic vibra -> 1926 midics(defun modif-aux-midic (freq  mmid1 mmid2 sigma-midi1 sigma-midi2)  (let ((midic (pw::f->mc freq)))    (exp(- (/ (expt (- midic mmid1) 2) (if (= 0 sigma-midi1) 1                                            (* 2 (expt sigma-midi1 2))))           (/ (expt (- midic mmid2) 2) (if (= 0 sigma-midi2) 1                                            (* 2 (expt sigma-midi2 2))))))));(modif-aux-midic 440  6900 5700 1000 1000);(pw::f->mc 440)(defun modif-moy-midic (vfreqs vamps mmid1 mmid2 sigma-midi1 sigma-midi2)  (let ((Lresult ()))    (do ((n 0 (1+ n)))        ((eq n (length vamps))(reverse Lresult))      (push (* (nth n vamps)(modif-aux-midic (nth n vfreqs)                                             mmid1 mmid2                                             sigma-midi1 sigma-midi2))            Lresult))))(defunp m-moy-modif        ((vfreqs list) (vamps list)(vbws list)         (mmidi integer)(sigma-midi integer)) list        "calcule la midicent moyenne et l'�carttype d'une s�rie de formantspuis transforme la liste des amplitudes et des bws en fct des nouvellesvaleurs de moy et ecartype"           (let ((mmidi1 (midic-moy (list vfreqs vamps vbws)))        (sigma-midi1 (midic-ecartyp (list vfreqs vamps vbws))) amps)    (setf amps (modif-moy-midic vfreqs vamps mmidi1 mmidi sigma-midi1 sigma-midi))    (mapcar #'(lambda (elt)                 (* elt (/ (somme vamps) (if (= 0 (somme amps)) 1                                             (somme amps))))) amps)))(defun modif-moy-amps-midic       (vfreqs vamps vbws mmidi  sigma-midi)  (let ((mmidi1 (midic-moy (list vfreqs vamps vbws)))        (sigma-midi1 (midic-ecartyp (list vfreqs vamps vbws))) amps)    (setf amps (modif-moy-midic vfreqs vamps mmidi1 mmidi sigma-midi1 sigma-midi))    (mapcar #'(lambda (elt)                 (* elt (/ (somme vamps) (if (= 0 (somme amps)) 1                                             (somme amps))))) amps)));(modif-moy-amps-midic '(440 660) '(2 1) '(15 15) 7600 100);(mc->f 6900);******************************************************************(defunp L-moy        ((vfreqs list) (vamps list)(vbws list)          (Lf-typ menu (:menu-box-list (("midic" . "midic") ("Hz" . "Hz"))                                      :type-list (no-connection)))         ) list"calcule la fr�quence moyenne d'une s�rie de formants" (if (= (length vamps)(length vbws)) ()     (setf vbws (make-list (length vfreqs):initial-element 1)))(if (equal "midic" Lf-typ)  (midic-moy (list vfreqs vamps vbws))  (freq-moy (list vfreqs vamps vbws))))(defunp L-ecart        ((vfreqs list) (vamps list)(vbws list)          (Lf-typ menu (:menu-box-list (("midic" . "midic") ("Hz" . "Hz"))                                      :type-list (no-connection)))) list        "calcule la fr�quence moyenne d'une s�rie de formants"           (if (= (length vamps)(length vbws)) ()       (setf vbws (make-list (length vfreqs):initial-element 1)))  (if (equal "midic" Lf-typ)    (midic-ecartyp (list vfreqs vamps vbws))    (freq-ecartyp (list vfreqs vamps vbws))))(defunp L-moy-modif         ((vfreqs list) (vamps list)(vbws list)         (Lf-typ menu (:menu-box-list (("midic" . "midic") ("Hz" . "Hz"))                                      :type-list (no-connection)))         (m integer)(sigma integer)) list        "calcule la fr�quence moyenne et l'�carttype d'une s�rie de formantspuis transforme la liste des amplitudes et des bws en fct des nouvellesvaleurs de moy et ecartype"           (if (equal Lf-typ "midic")    (m-moy-modif vfreqs vamps vbws m sigma)    (f-moy-modif vfreqs vamps vbws m sigma )))(pw-addmenu *analyse-menu*  '(L-moy))(pw-addmenu *analyse-menu*   '(L-ecart))(pw-addmenu *spd-processing*  '(L-moy-modif))(export '(L-moy L-ecart L-moy-modif))