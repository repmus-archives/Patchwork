(in-package "SPDATA");***************** fcts de distorsion harmonique ***********(defunp distsp ((spdata spdata)(dist fix/float)                &optional (fund fix/float)) spdata"distorsionne les freqs de spdata en appliquant � chaque harmonique un coefft dedistorsion, dist = 1 pas de distorsionsi fund est s�lectionn� et diff�rent de nil, distsp calcule des harmoniques distordussans relation avec les fr�quences des partielss'applique par rapport � cette fondamentale"(if fund (distnspe spdata dist fund)(distpsp spdata dist)))(defun distnsp (spdata dist &optional trfact)"distorsionne les freqs de spdata en regardant uniquement la fond etles numeros d'harmoniques, dist = 1 pas de distorsion"  (let ((to-spdata (copy-instance spdata)))    (setf trfact (if trfact trfact 1)          (slot-value to-spdata 'freqs)          (distn (slot-value to-spdata 'partials)                 (first (slot-value to-spdata 'freqs))                 dist trfact))    to-spdata)) (defun distpsp (spdata dist &optional trfact)"distorsionne les freqs de spdata en apliquant � chaque harmonique par un coefft dedistorsion, dist = 1 pas de distorsion"  (let ((to-spdata (copy-instance spdata)))    (setf trfact (if trfact trfact 1)          (slot-value to-spdata 'freqs)          (distp (slot-value to-spdata 'partials)                 (slot-value to-spdata 'freqs)                 dist trfact))    to-spdata))(defun distnspe (spdata dist fund)"distorsionne les freqs de spdata en regardant uniquement la fond etles numeros d'harmoniques, dist = 1 pas de distorsion"  (let ((to-spdata (copy-instance spdata)))    (setf (slot-value to-spdata 'freqs)          (distn (slot-value to-spdata 'partials)                 fund                 dist 1))    to-spdata))    (defun distn (Lpart freq dist trfact)"freq est la fond et Lpart une liste d'harmoniques que l'on veut"  (let ((L ()))    (dolist (n Lpart (reverse L))      (push (* trfact freq (expt n dist)) L))))(defun distp (Lpart Lfreq dist trfact)"Lfreq est une liste d'harmoniques et Lpart leurs indices"  (let ((L ()))    (dotimes (n (length Lpart) (reverse L))      (push (* trfact (/ (nth n Lfreq)(nth n Lpart))               (expt (nth n Lpart) dist)) L))));(distn '(1 2 3) 100 1.2);************** aplatifreqs remani� ************(defun centre (list n)"a am�liorer"  (let ((L1 (sort (pw::g-round list n) '<))(L2 ()))    (dolist (elt L1)      (if (member elt L2 :key 'first)        (setf (first L2)(list elt (1+ (second (first L2)))))        (push (list elt 1) L2)))    (caar (sort L2 '> :key 'second))));(centre ;'(55.771343 65.103539 64.889404 64.981178 64.979553 65.007004 65.066139 65.186447 65.200905 65.159454 65.131042; 65.164635 65.129364 65.081017 65.046341 65.120781 65.175941 65.112465 65.060593 65.086166 65.098785 65.043793; 65.064995 65.017624 65.062004 64.795776 64.287369 63.970119 63.877342 63.673534 63.607018 63.614025 63.651237; 63.321346 64.637749 0.0) 1)(defun aplatifreqs2 (liste pourcent prec)"aplati liste autour de son centrepourcent est le taux d'aplatissement (entre 0 et 100 en gal ; 0 = applatissement max)prec est la precision pour trouver le centre (nombre de chiffres apres la virg)"  (let ((centre (centre liste prec))(L ()))    (dolist (elt liste (reverse L))      (push (+ centre (* (- elt centre)(/ pourcent 100))) L))))(defmethod aplatifreqs ((self C-spdata) pourcent precp)  (let ((to-spdata (copy-instance self)))    (setf (slot-value to-spdata 'freqs)          (aplatifreqs2 (slot-value to-spdata 'freqs)                        pourcent precp))    to-spdata))(defmethod aplatifreqs ((self C-spdata-seq) pourcent precp)        (let ((to-spdata-seq (copy-instance self)))  (setf (slot-value to-spdata-seq 'spdata)          (mapcar #'(lambda (spd)(aplatifreqs spd pourcent precp))                  (slot-value to-spdata-seq 'spdata)))  to-spdata-seq));(aplatifreqs2 '(1 5 2 4 5 1 2 5 4 4 ) 10.0 0)