(in-package "PW");(defvar *end-o-stream* (cons nil nil))(defvar *wscore-list*)(defvar *wscores*)(defvar *wcurrent-score* ())(defvar *wcurrent-date* 0);************** simule la lecture de bytes *************(defun read-car (liste)  (pop liste))(defun n-car-to-num (num-car liste)  (do ((new-number 0 (+ (ash new-number 8) next-car))       (next-car (pop liste)                  (pop liste))       (car-count 1 (1+ car-count)))      ((>= car-count num-car)        (+ (ash new-number 8) next-car))    ));(n-car-to-num 2 '(01 127 104 100 5))(defun n-car-to-string (num-car liste)  (let ((top-index (- num-car 1)))    (do ((new-string (make-string num-car))         (next-char (character  (pop liste))                  (character (pop liste)))         (letter-count 0 (1+ letter-count)))        ((or (>= letter-count top-index) (eql next-char *end-o-stream*))         (if (equal next-char *end-o-stream*)           (if (= letter-count 0)             *end-o-stream*             (throw 'file-error "ERROR: Unexpected end of stream while reading string"))           (progn             (setf (elt new-string letter-count) next-char)             new-string)))      (setf (elt new-string letter-count) next-char))));(n-car-to-string 4 '(77 84 104 100 5));(character 77);*************** versions de read-midi-file pour tests ************(defun read-midi-file-p (&key (filename (choose-file-dialog )))  (setf *wscore-list* nil)  (catch 'file-error    (with-open-file (instream filename                              :element-type 'unsigned-byte)(while instream (print (n-bytes-to-num 4 instream))))))(defun read-midi-file-s (&key (filename (choose-file-dialog )))  (setf *wscore-list* nil)  (catch 'file-error    (with-open-file (instream filename                              :element-type 'unsigned-byte)(while instream (print (n-bytes-to-string 4 instream))))))(defun read-midi-file-f (&key (filename (choose-file-dialog )))  (setf *wscore-list* nil)  (catch 'file-error    (with-open-file (instream filename                              :element-type 'unsigned-byte)(while instream (print (read-byte  instream))))));(read-midi-file-f);->77 ;*************** ecrit en binaire**************(defun track-writ-lp (liste nom-fich)(with-open-file (instream nom-fich                              :direction :output :if-exists :rename-and-delete                              :if-does-not-exist :create                              :element-type 'unsigned-byte)      (while liste (write-byte  (pop liste) instream)))    (set-mac-file-type nom-fich "Midi"))#|(track-writ-lp (flat '((77 84 114 107) (0 0 0 16) (0 255 88 4 4 2 18 8) (0 255 81 3 158 194 32) (0 145 48 64) (0 144 60 64) (131 96 128 60 0) (131 96 144 62 64) (135 64 129 48 0) (135 64 145 36 64) (135 64 128 62 0) (135 64 144 64 64) (139 32 128 64 0) (139 32 144 65 64) (141 16 128 65 0) (141 16 144 67 64) (143 0 129 36 0) (143 0 128 67 0) (0 255 47 0)))) ->�a marche|#;************************ WRITE MIDI-FILE  ***************************;*** � PARTIR D'INFORMATIONS CONTENUES DANS L'OBJET *SCORES* *********(defun mf-writ-lp (obj format)  (list    (head-chunk obj format)   (tracks-chunk obj format)));(track-writ-lp (flat (mf-writ-lp *coin* 0)));(track-writ-lp (flat (mf-writ-lp *coin* 1)));(set-mac-file-type "dd2:coin" "Midi");ok good!(defmethod head-chunk ((self lp-scores) format)(let ((en-tete (strgs->n-vals "MThd"))      (long-chk (num->n-vals-n (mthd-lenght self) 4))      (n-trks (num->n-vals-n (mthd-nb-pistes self format) 2))      (tim-div (num->n-vals-n (mthd-tps-div self) 2)))  (list en-tete long-chk (num->n-vals-n format 2) n-trks tim-div)))(defmethod tracks-chunk ((self lp-scores) format)  (let ((liste ()))    (cond ((= format 0)           (setf liste (tracks-chunk-0 self)))          ((= format 1)           (push (trackinfo-chunk-1 self) liste)           (dotimes (n (length (scores self)) (setf liste (reverse liste)))             (setf *wcurrent-date* 0)             (push (track-chunk-1 (nth n (scores self))) liste)))  (t (print "error: format MIDI-FILE absent"))) liste));pour format 1 (defmethod trackinfo-chunk-1  ((self lp-scores))  (setf *wcurrent-score* (regroupe self))  (setf *wcurrent-date* 0)  (let ((en-tete (list (strgs->n-vals "MTrk")))        (tempo (list (tempo-mf (car (scores self)))))        (time-sig (list (time-sig-mf (car (scores self)))))        )  (append        en-tete     (list (num->n-vals-n (+ (length (flat tempo))(length (flat time-sig)) 4) 4))     time-sig     tempo     '((00 255 47 00))      ;message de fin     )))(defmethod track-chunk-1  ((self lp-score))  (setf *wcurrent-score* (events self))  (setf *wcurrent-date* 0)  (let ((en-tete (list (strgs->n-vals "MTrk")))        (events (mapcar #'event->n-vals *wcurrent-score*)))    (append        (print en-tete)     (list (num->n-vals-n (+ (length (flat events)) 4) 4))     events     '((00 255 47 00))      ;message de fin     )));pour format 0(defmethod tracks-chunk-0  ((self lp-scores))  (setf  *wcurrent-score* (regroupe self))  (setf *wcurrent-date* 0)  (let ((en-tete (list (strgs->n-vals "MTrk")))        (tempo (list (tempo-mf (car (scores self)))))        (time-sig (list (time-sig-mf (car (scores self)))))        (events (mapcar #'event->n-vals *wcurrent-score*)))  (append        en-tete     (list (num->n-vals-n (+ (length (flat tempo))(length (flat time-sig))(length (flat events)) 4) 4))     time-sig     tempo     events     '((00 255 47 00))      ;message de fin     )));(defvar *coin*);(setf *coin* (make-instance 'lp-scores));(setf (scores *coin*) (read-midi-file));(tempo-mf (car (scores *coin*)));(trackinfo-chunk-1 *coin*)-> ((77 84 114 107) (0 0 0 19) (0 255 88 4 4 2 18 8) (0 255 81 3 7 161 32) (0 255 47 0));(track-chunk-1 (cadr (scores *coin*)));(tracks-chunk  *coin* 1);(mapcar #'num->n-vals-n ( (car (scores *coin*))));(scores *coin*);(cons '((77 84 114 107) (0 0 0 19) ) '(((77 84 114 107) (0 0 0 49)) ((0 144 60 64))));� partir d'une liste de la forme '(500 ("note-on" 0 60 64));on obtient (0 144 60 64) codage midi standart;attention, la date se transforme en delta-time par rapport;� la note pr�c�dente!!!!!!!;sont impl�ment�s (note-on note-off ctrl prg-chg pitch-bend)(defun event->n-vals (event)  (let ((delta-time  (- (car event) *wcurrent-date*))  ;pr�l�vt de la date pr�c�dente ---------------<<<        (evt-type  (caadr event))        (evt-ch (cadadr event))        (evt-v1 (second (cdadr event)))        (evt-v2 (third (cdadr event)))        (L ()))    (setf *wcurrent-date* (car event))     ;r�actualisation de la date    (cond ((equal evt-type "note-on")           (setf L  (append  (dec->hexa-r delta-time)                             (list (cons 9 (dec->hexa evt-ch)))                             (dec->hexa-n evt-v1)                             (dec->hexa-n evt-v2))))          ((equal evt-type "note-off")           (setf L (append (dec->hexa-r delta-time)                            (list  (cons 8 (dec->hexa evt-ch)))                            (dec->hexa-n evt-v1)                           (dec->hexa-n evt-v2))))          ((equal evt-type "ctrl")           (setf L (append (dec->hexa-r delta-time)                            (list (cons 'B (dec->hexa evt-ch)))                           (dec->hexa-n evt-v1)                           (dec->hexa-n evt-v2))))          ((equal evt-type "prg-chg")           (setf L (append (dec->hexa-r delta-time)                            (list  (cons 'C (dec->hexa evt-ch)))                            (dec->hexa-n evt-v1))))          ((equal evt-type "pitch-bend")           (setf L (append (dec->hexa-r delta-time)                            (list  (cons 'E (dec->hexa evt-ch)))                            (dec->hexa-n evt-v1)                           (dec->hexa-n evt-v2))))          ((equal evt-type "sysex")           (setf L (append (dec->hexa-r delta-time)                           (dec->hexa-n 240)                           (apply #'append                                   (mapcar #'dec->hexa-n (cdadr event)))                           (dec->hexa-n 247))))          (t ()))    (mapcar #'hexa->dec             L)));(format t "liste : ~a ~%" L)));(mapcar #'dec->hexa-n '(11 67 16 52 13 0 0 24 0 127));(mapcar #'list '(11 67 16 52 13 0 0 24 0 127));(dec->hexa-n 0);(dec->hexa-r 247);(hexa->dec '(e)) ;(cons 9 (dec->hexa 1);((0 0)(9 0 0)(3 0)(6 4));(hexa->dec (;"poly-p"->2->A;"ctrl" ->B;"prg-chg"->C;"ch-p"->D;"pitch-bend"->6->E;(dec->hexa-r 64);(event->n-vals '(500 ("note-on" 0 60 64)));(event->n-vals '(807 ("pitch-bend" 0 0 127)));(hexa->dec '(5 8));(dec->hexa-n 500000);(num->n-vals-n 500000)(defun tempo-mf (score)(let ((tmp (num->n-vals-n             (* (/ 120 (print (get-tempo-bpm score))) 500000))))  (append (list 0 255 81 (length tmp)) tmp)))(defun  time-sig-mf (score)  (declare (ignore score))  (let ((beats 4)  ;nombre de temps        (beat-div 2) ;puissance de 2 divisant la ronde        (clcks 24)        (32nd-nts 8))    (list 0 255 88 4 beats beat-div clcks 32nd-nts)))(defmethod  regroupe ((self lp-scores))  (let ((L ()))    (dotimes (n (length (scores self)))      (setf L (append (get-events (nth n (scores self))) L)))    (sort L '< :key 'first)));(defvar *coin*);(setf *coin* (make-instance 'lp-scores));(setf (scores *coin*) (read-midi-file));(regroupe *coin*);(get-events (cadr (scores *coin*)))(defmethod mthd-tps-div ((self lp-scores))  (get-bits-per-beat (car (scores self))))(defmethod mthd-nb-pistes ((self lp-scores) format)  (if (= 0 format) 1 (length (scores self))))(defmethod mthd-lenght ((self lp-scores))  6)               ;tant que l'on se limite � un header � trois infos;********************************************************************;*************** regroupements nums et strings->bin *****************(defun num->n-vals-n (number &optional n)(let ((result (mapcar #'hexa->dec (dec->hexa-n number))))(if n (if (< n (length result)) (print "erreur: n < nombre de vals")            (setf result (append (make-list (- n (length result))                             :initial-element 0) result))) ()) result))(defun num->n-vals-r (number &optional n)(let ((result (mapcar #'hexa->dec (dec->hexa-r number))))(if n (if (< n (length result)) (print "erreur: n < nombre de vals")            (setf result (append (make-list (- n (length result))                             :initial-element 0) result))) ()) result)); (num->n-vals-n 480 4);---> (0 0 255 127);(dec->hexa-r 16383)(defun strgs->n-vals (texte)        (let  ((L ()));(mapcar #'dec->hexa   (mapcar #'char-int           (dotimes (n (length texte) (reverse L))             (push (char texte n) L)))));(strgs->n-vals "MThd")   ;->(77 84 104 100);*************** CONVERSIONS HEXA <-> DECI *****************;********** converti une liste de symboles hexa en un nombre decimal(defun hexa->dec (liste)  (let ((liste (reverse liste)) ;;;;;------------->>>>>>>>>>>>print        (result 0));(print liste)   (dotimes (n (length liste) (if (> result 255) (break "was ~a" result) result)) ;-------------------------> lppppppppppp test(if (null (nth n liste))(setf result ())     (setf result (+ (* (expt 16 n) (symb->n (nth n liste))) result))))));(hexa->dec '(5 8 e));(hexa->dec '(1 b b)) -->443;(hexa->dec '(f 7)) -->443;(hexa->dec '((b))) -->443(defun symb->n (symb)  (let ((depart '(0 1 2 3 4 5 6 7 8 9 a b c d e f))        (arrivee '(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15))        val)    (dotimes (n 16 val)      (if (equal symb (nth n depart))(setf val (nth n arrivee))()))));************* converti un nombre decimal en une liste de symboles hexa(defun dec->hexa (number)  (let ((L ()))(if (zerop number) (setf L '(0))    (while (>= number 1)      (multiple-value-bind (q r) (truncate (/ number 16))      (push (x->symb (* 16 r)) L)      (setf number q))))   L));(dec->hexa-r 1);(dec->hexa 3);** les fonctions avec un "n" sont les fonctions faisant intervenir plusieurs bytes pour un m�me nombre;** les fonctions avec un "r" sont les fonctions faisant intervenir plusieurs bytes pour un m�me nombre;** avec le dernier byte moins significatif et les autres plus significatifs (ex: tempo)(defun multihexndec->dec (liste)  (let ((result 0)        (numb (length liste)))    (dotimes (n numb result)      (setf result (+ result (* (nth n liste) (expt 256 (- (1- numb) n))))))))(defun multihexrdec->dec (liste)  (let ((result (car (last liste)))        (numb (1- (length liste))))    (dotimes (n numb result)      (setf result (+ result (* (- (nth n liste) 128) (expt 128 (- numb n))))))));(multihexndec->dec '( 1 224));(multihexrdec->dec '(131 96));**** fonction qui tient compte de la taille du nombre;**** pour cr�er un hexa d�cimale avec un lsb et msb(defun dec->hexa-n (number);(format t "number ~a" number)  (let ((Liste ()))    (if (zerop number) (setf liste '((0)))        (while (>= number 1)          (multiple-value-bind (q r) (truncate (/ number 256))            (push (dec->hexa (* 256 r)) Liste)            (setf number q))))    liste));(dec->hexa-n 0)(defun dec->hexa-r (number)  (let ((Liste ()))    (if (zerop number) (setf liste '((0)))        (while (>= number 1)          (multiple-value-bind (q r) (truncate (/ number 128))            (push (dec->hexa (* 128 r)) Liste)            (setf number q))))    (add-lsb liste)))(defun add-lsb (liste)  (let  ((L ()))    (dotimes (n (1- (length liste))                (reverse (push (car (last liste)) L)))      (push (dec->hexa (+ (hexa->dec (nth n liste)) 128)) L))));(add-lsb '((1 0)));(dec->hexa-r 268435455)(defun x->symb (x)  (let ((depart '(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15))        (arrivee '(0 1 2 3 4 5 6 7 8 9 a b c d e f))        val)    (dotimes (n 16 val)      (if (equal x (nth n depart))(setf val (nth n arrivee))()))));(x->symb 15);(hexa->dec '(0 f f f f f f f));(dec->hexa 154);(symb->n 'f);(hexa->dec '(0 3));(dec->hexa-n 224);(dec->hexa-r 64)