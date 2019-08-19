(in-package :spdata)(export '(modres-ft))(import '(pw:defunp           pw::g*))(defparameter *analyse-menu* (new-menu "analyse"))(ccl:add-menu-items *spdata* *analyse-menu*)(defun db->lin-iana (lamps)"0 db -> 1, -90 -> 0"(if (atom lamps)(/ (expt 10 (/ (+ lamps 90) 20)) 32000)  (let ((l ()))    (dolist (amp lamps (reverse l))      (push (float (/ (expt 10 (/ (+ amp 90) 20))                      32000)) l)))))(db->lin-iana -90)(expt 10 (/ 0 20));amplitude du formant restreint par la largeur de bande(defun amp-rest (amp bw)(if bw  (if (zerop bw) amp      (/ amp bw)) amp))(* -20 (log 0.0000001))(defun loud-corr (freq amp bw)  "donne l'amplitude ressentie corrig�e selon la fr�quence et la largeur de bande"  (let ((loud (LP-LOUD::amp->loud freq amp)))    (if bw       (if (zerop bw)         loud        (/ loud bw))      loud)));(loud-corr 30 1 10);(LP-LOUD::amp->loud 30 100);**************************************************(defun condition (freq fund seuil)  "condition pour qu'une freq soit accept�e comme harmonique"  (and (< (moddist freq fund)          (/ (* fund seuil) 100))       (< (round (/ freq fund)) 100)))(defun poids-total (lamps lbws)"donne la somme des amps corrig�es par bw des 2 listes"  (if (= (length lamps)(length lbws))    (let ((sum 0))      (dotimes (n (length lamps) sum)       (setf sum (+ sum (amp-corr (nth n lamps)(nth n lbws))))))    (somme lamps)))(defun loud-total (lfreqs lamps lbws)  (let ((llouds (LP-LOUD::amp->loud lfreqs lamps)))  (poids-total llouds lbws)));(loud-total '(1000 2000) '(1 1)'(1 1))(defun n-harms+lds (fund lfreqs lamps lbws seuil nbre loud-total)  (let ((loud 0)(L ()))    (dotimes (n (length lfreqs)                (if (< nbre (length L))                   (list (float (/ loud loud-total))                         (reverse L)) ()))      (if (condition (nth n lfreqs) fund seuil)        (progn (push (nth n lfreqs) L)               (setf loud (+ loud                               (loud-corr                                (nth n lfreqs)                               (nth n lamps)                               (nth n lbws)))))        ()))));(n-harms+lds 100 '(50 100 160 250 300) '(0.1 0.2 0.3 0.4 0.5) '(1 1 1 1 1) 4 1 1);***********************************************************(defun find-fund (lfreq seuil)"fonction qui recherche la fr�quence fondamentalesuivant un seuil en pourcentage de cette fondamentale"  (let (fund (nharm 0) (nmax 0))    (dotimes (n (length lfreq))      (setf nharm (print (n-harm (nth n lfreq)                           (nthcdr n lfreq) seuil)))      (if (< nmax nharm)        (setf nmax nharm              fund (nth n lfreq)              nharm 0)()))    fund));(find-fund '(7 10 20 30 35 36) 10)->10    (defun n-harm (fund lfreq seuil)  "donne le nombre d'harmoniques de fund trouv�s la liste lfreq (distance de elt avec harm < seuil"  (let ((sum 0))    (dolist (freq lfreq sum)      (if (condition freq fund seuil)        (setf sum (1+ sum))))));(n-harm 10 '(10 20 31 35 36) 12)(defun n-harms (fund lfreq seuil nbre)"donne la liste des harmoniques de fundtrouv�s dans lfreq s'il en existe au moins'nbre"  (let ((L ()))    (dolist (freq lfreq (if (< nbre (length L)) (reverse L) ()))      (if (condition freq fund seuil)        (push freq L)()))    ));(n-harms 10 '(10 20 300 35 36) 12 2)(defun moddist (nbre div)"fonction modulo qui donne la distance la plus faibleentre nbre et un multiple de div"  (min (mod nbre div)        (mod (- nbre (* 2 (mod nbre div))) div)));(moddist 22 10);(n-harms 10 '(7 10 20 31 35 36) 0 1)->(10 20);************************************************************(defunp find-funds ((spdata spdata)(seuil fix/float (:value 4))(nbre fix/float (:value 8))) list "fonction qui recherche les fr�quences fondamentales et donneleurs harmoniques possibles (recherche si nbre d'harmoniques>nbre)suivant un seuil en pourcentage de cette fondamentale"  (let ((Lfund ())(lfreq (freqs spdata)))    (dotimes (n (length lfreq))      (push (n-harms (nth n lfreq)                      (nthcdr n lfreq) seuil nbre) Lfund))   (remove nil (reverse Lfund))));(find-funds '(7 10 19 30 35 36) 20 1)(defunp find-fund-sens ((spdata spdata)                        (seuil fix/float)(nbre fix/float)) list  "fonction qui recherche les fr�quences fondamentales et donneleurs harmoniques possibles (recherche si nbre d'harmoniques>nbre)ainsi que le poids relatif de la liste, suivant un seuil en pourcentagede cette fondamentale"  (let ((Lfund ()) loud-total (lfreqs (freqs spdata))(lamps (amps spdata))(lbws (bws spdata)))(setf loud-total (loud-total lfreqs lamps lbws))    (dotimes (n (length lfreqs))      (push (n-harms+lds (nth n lfreqs)                      (nthcdr n lfreqs)                     (nthcdr n lamps)                     (nthcdr n lbws)                     seuil nbre loud-total) Lfund))(sort (remove nil Lfund) '> :key 'first)))(defunp find-fund-datas ((spdata spdata)                        (seuil fix/float)(nbre fix/float)) list        "fonction qui recherche les fr�quences fondamentales et donneleurs harmoniques possibles (recherche si nbre d'harmoniques>nbre)ainsi que le poids relatif de la liste, suivant un seuil en pourcentagede cette fondamentale"  (let ((Lfundf ())(Lfunda ())(Lfundbw ()) inds loud-total(lfreqs (freqs spdata))(lamps (amps spdata))(lbws (bws spdata)))    (setf loud-total (loud-total lfreqs lamps lbws))    (dotimes (n (length lfreqs))      (push (n-harms+lds (nth n lfreqs)                          (nthcdr n lfreqs)                         (nthcdr n lamps)                         (nthcdr n lbws)                         seuil nbre loud-total) Lfundf))    (setf Lfundf (sort (remove nil Lfundf) '> :key 'first))    (setf inds (mapcar 'first Lfundf))    (setf Lfundf (mapcar 'second Lfundf))    (setf Lfunda (get-py-px Lfundf lfreqs lamps))    (setf Lfundbw (get-py-px Lfundf lfreqs lbws))    (list inds Lfundf Lfunda Lfundbw)))(defun get-py-px (Ldevals valsref datas)  (get-py/px Ldevals valsref datas))  ; for compatibitity(defun get-py/px (Ldevals valsref datas)  "cherche les valeurs de Ldevals dans valsref etdonne les valeurs aux m�me position dans datason suppose valsref et datas m�me structure et m�me tailleon suppose toutes les valeurs de Ldevals existent dans valsref"  (cond ((null Ldevals)         ())        ((atom Ldevals)         (nth (position Ldevals valsref) datas))        (t         (cons (get-py-px (car Ldevals) valsref datas)               (get-py-px (rest Ldevals) valsref datas)))))                     ;(get-py-px '(5 (5 1) 1) '(1 2 3 4 5 6 7) '(a b c d e f g h)) (defunp find-the-fund ((spdata spdata)                        (seuil fix/float)(nbre fix/float)) list  "fonction qui recherche les fr�quences fondamentales et donnecelle qui est la plus repr�sentative avec ses harmoniques"  (let* ((Lfund (find-fund-sens spdata seuil nbre)))    (cadar (sort  Lfund '> :key 'first))));************************************************************(defunp modres-ft ((spdata object(:type-list (list spdata spdata-seq)))                     (temps (fix/float)))        spdata         "creates a new spdata object with values the selected slot scaled between"  (let ((nspdata (copy-instance spdata)))    (setf (amps nspdata) (g* (amps spdata)                                 (mapcar #'(lambda (band) (expt 2.718281828459045 (- 0 (* temps band))))                                         (bws spdata))                                 ))    nspdata));************************************************************;recherche de la fraction d'attaque;crit�res: relation avec le coefft resmoy & dur�e absolue;une fof d'amp i et de bw b a une reson moy de i/b;on veut i/b < ;(pw-addmenu *analyse-menu*  '(find-funds));(pw-addmenu *analyse-menu*  '(find-fund-sens))(pw-addmenu *analyse-menu*  '(find-fund-datas));(pw-addmenu *analyse-menu*  '(find-the-fund))(pw-addmenu *analyse-menu*  '(get-py/px))(pw-addmenu *analyse-menu*  '(resmoy-coef))(export '(find-funds           find-fund-sens           find-the-fund           resmoy-coef          get-py-px          find-fund-datas))