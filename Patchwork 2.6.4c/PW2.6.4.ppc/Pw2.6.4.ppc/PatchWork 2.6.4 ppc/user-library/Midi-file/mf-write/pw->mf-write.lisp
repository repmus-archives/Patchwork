(in-package "PW");(defvar *coin*);(setf *coin* (make-instance 'lp-scores));(setf (scores *coin*) (read-midi-file));(regroupe *coin*);(get-events (cadr (scores *coin*)));skjfhslhglkjfh;************************************************(defun rtm->chds (m-line)  "convert a RTM modul into a list of chords"  (let ((L ()))    (if (listp m-line)       (dolist (m-l m-line (reverse (pw::flat-once L)))        (push (rtm-chds-A m-l) L))      (rtm-chds-A m-line)      )))(defun rtm-chds-A (m-line)  (ask-all    (collect-all-chord-beat-leafs m-line)   #'beat-chord))(defunp Chds->MFevts ((chords midic (:type-list (list  collector)))                    &optional (precision fix/float)                    ) list         "input: a list of chords, output: a list of events for the Write-MF modulesi la valeur nil est donn�e dans pr�cision, l'approximation est au 1/2 tonsi la valeur 1 est donn�e dans pr�cision, l'approximation es t au 1/8e de tonavec sauvegarde sur une m�me piste mais avec des canaux diff�rents (ch = 1, 2, 3 et 4)"(if (eq 1 precision) (chords->events chords 1) (chords->events chords 0)))(defunp Mn->MFevts ((chord-line midic (:type-list (list  collector)))                    &optional (precision fix/float)                    ) list         "donne les events fournis par chordseq par ex pour �criture en MidiFilesi la valeur nil est donn�e dans pr�cision, l'approximation est au 1/2 tonsi la valeur 1 est donn�e dans pr�cision, l'approximation es t au 1/8e de tonavec sauvegarde sur une m�me piste mais avec des canaux diff�rents (ch = 1, 2, 3 et 4)"(if (eq 1 precision) (chords->events (chords chord-line) 1) (chords->events (chords chord-line) 0)))(defunp Mns->MFevts ((chord-lines midic (:type-list (list  list)))                    &optional (precision fix/float)                    ) list         "donne les events fournis par multiseq pour �criture en MidiFilesi la valeur nil est donn�e dans pr�cision, l'approximation est au 1/2 tonsi la valeur 1 est donn�e dans pr�cision, l'approximation es t au 1/8e de tonavec sauvegarde sur une m�me piste mais avec des canaux diff�rents (ch = 1, 2, 3 et 4)"  (let ((score ()))      (dotimes (n (length chord-lines) score)    (if (eq 1 precision)        (setf score (append  (chords->events (chords (nth n chord-lines)) 1) score))        (setf score (append  (chords->events (chords (nth n chord-lines)) 0) score))))))(defunp PB->MFevts ((events list (:value '((50 1 1024))))) list          "donne les events pour �criture en MidiFilepour liste de pitch-bends"         (let ((L ()))         (dolist (event events (reverse L))           (push (cons (car event)                       (cons "pitch-bend"                             (val->pb-2bit (cdr event)))) L))));(PB->MFevts '((50 1 1024))) -->((50 "pitch-bend" 1 0 72))(defunp ctrl->MFevts ((events list (:value '((50 1 7 64))))) list         "donne les events pour �criture en MidiFilepour liste de contr�leurs"  (let ((L ()))    (dolist (event events (reverse L))      (push (cons (car event)                  (cons "ctrl"                              (cdr event))) L))));(ctrl->MFevts '((50 1 7 64))) --> ((50 "ctrl" 1 7 64));  old ((480 "ctrl" 1 7 64))(defunp sysex->MFevts ((events list (:value '((50 1 1024))))) list         "donne les events pour �criture en MidiFilepour liste de contr�leurs"  (let ((L ()))    (dolist (event events (reverse L))      (push (cons (car event)                  (cons "sysex"                              (cdr event))) L))));(sysex->MFevts '((50 1 7 64))) -->((480 "sysex" 1 7 64))(defun sort-evnts (liste)"tri les event par type puis par date"  (sort (sort liste #'string-lessp :key #'second) '< :key #'first))(defun chords->events (chords prec)  (let ((L ()))    (dolist (chord chords (sort-evnts L))      (setf L (append (chord->events chord prec) L)))));(chords->events (list maj maj maj))(defun chord->events (chord prec)  (let ((date (t-time chord))        (Lnots (notes chord))        (L ()))    (dolist (note Lnots (sort L '< :key #'first))      (push (note->not-on date note prec) L)      (push (note->not-off date note prec) L))))#|(setf maj (make-instance 'c-chord :t-time 50 :notes                          (list (make-instance 'c-note :midic 6000 :dur 50 :vel 64 :chan 1)                               (make-instance 'c-note :midic 6400 :dur 50 :vel 64 :chan 1)                               (make-instance 'c-note :midic 6700 :dur 50 :vel 64 :chan 1))))(chord->events maj 1)|#;  ** note = (midic, dur, vel, chan) -> not-on = (date/100*480 ("note-on" ch-1 midic/100 vel)(defun note->not-on (date note precision)  (if (eq precision 1)    (let ((ch-mod (ch-mod (midic note))))      (cons (+ date (offset-time note))             (list "note-on"                   (+ (chan note) ch-mod)                   (* 100 (round (/ (- (midic note) 37.5)  100)))                  (vel note))) )    (cons (+ date (offset-time note)) (list "note-on" (chan note)                      (* 100 (round (/ (midic note) 100)))(vel note)))));**** note = (midic, dur, vel, chan) -> not-off = (date/100*480 ("note-off" ch-1 midic/100 0)(defun note->not-off (date note &optional precision)  (if (eq precision 1)    (let ((ch-mod (ch-mod (midic note))))      (cons (+ date (dur note)(offset-time note))            (list "note-off"                   (+ (chan note) ch-mod)                   (* 100 (round (/ (- (midic note) 37.5)  100)))                  (vel note))) )    (cons (+ date (dur note)(offset-time note))          (list "note-off" (chan note)                 (* 100 (round (/ (midic note) 100)))(vel note)))));***** donne le nombre de 1/8e de ton d'�cart entre une approx au 1/2 et au 1/8e de ton(defun ch-mod (midic)(let ((a (* (round (/ (- midic 37.5) 100)) 4))      (b (round (* (/  midic 100) 4))))  (- b a)));(ch-mod 1088);((0 ("note-on" 0 60 64)) (0 ("note-on" 1 48 64)) (480 ("note-off" 0 60 0)) (480 ("note-on" 0 62 64));(960 ("note-off" 1 48 0));********************* ecriture ***********************(defunp  write-mf ((liste list)(format fix/float)                   &optional (filename list ( :value  '() :type-list '(string)))                   ) nil          "ecrit un fichier MIDI-FILE au format 0 � partir d'une liste d'evts de la forme '((50 \"note-on\" 1 6000 64)(50 \"note-on\" 16 6000 64)) ou '((100 \"ctrl\" 1 7 64)))"  (let ((liste2 (modif-relist1 liste)))    (unless filename       (setf filename             (ccl:choose-new-file-dialog  :directory *lastfile-mid* :prompt "MidiFile")))    ;(CCL:choose-file-dialog :directory *lastfile-mid* :button-string "MidiFile")))    (when  filename      (setf *lastfile-mid* filename)      (format t "  ---> �criture du fichier: ~a ~%" *lastfile-mid*)      (write-midi-file  liste2 format filename)))); GA 2/10/95(defun modif-relist1 (liste)  "passe du format PW au format midifile (converti ch date et dur)"  (let  ((Lr ()))    (dolist (elt liste (reverse Lr))      ; GA 28/09/95 480 is for quarter note      ;(push (cons (round (* (/ (car elt) 50) 480))      (push (cons (round (* (/ (car elt) 100) 480))                  (list (list                         (second elt)                         (1- (third elt))                         (if (or (equal (second elt) "note-on")                                 (equal (second elt) "note-off"))                           (/ (fourth elt) 100)                           (fourth elt))                         (fifth elt)                         ))) Lr))))#|(defun modif-relist1 (liste)  "passe du format PW au format midifile (converti ch date et dur)"  (let  ((Lr ()))    (dolist (elt liste (reverse Lr))      (if (equal (second elt) "sysex")        (push (cons (round (* (/ (car elt) 50) 480))                    (list (cdr elt))) Lr)        (push (cons (round (* (/ (car elt) 50) 480))                    (list (list                           (second elt)                           (1- (third elt))                           (if (or (equal (second elt) "note-on")                                   (equal (second elt) "note-off"))                             (/ (fourth elt) 100)                             (fourth elt))                           (fifth elt)                           ))) Lr)))))|#;(modif-relist1 '((500 "ctrl" 1 7 64)(500 "note-on" 1 6000 64)));(modif-relist1 '((500 "sysex" 1 7 64 4 23)))(defun  write-midi-file (liste format nom-fich)  (let ((score-list (make-instance 'lp-scores))        (current-score (make-instance 'lp-score)))    (set-bits-per-beat current-score 480)           (setf (slot-value current-score 'tempo-bpm) *tempo*)    (if (atom (caar liste))      (progn (setf  (events current-score) liste)             (push current-score (scores  score-list)))      (dolist (elt liste (setf (scores  score-list) (reverse (scores  score-list))))        (push (make-instance 'lp-score :events  elt) (scores  score-list))))    (track-writ-lp (flat  (mf-writ-lp score-list format)) nom-fich)));(events (second (scores  *score-list*)));(mf-writ-lp *score-list* 1); (get-bits-per-beat *current-score*);(PW::PW-addmenu-fun  *MIDI-FILE* 'sort-evnts);(add-menu-items *MIDI-FILE* (new-leafmenu "-" ()))(PW::PW-addmenu-fun  *MIDI-FILE* 'write-mf)(add-menu-items *MIDI-FILE* (new-leafmenu "-" ()))(PW::PW-addmenu-fun  *MIDI-FILE* 'rtm->chds)(PW::PW-addmenu-fun  *MIDI-FILE* 'Chds->MFevts)(PW::PW-addmenu-fun  *MIDI-FILE* 'Mn->MFevts)(PW::PW-addmenu-fun  *MIDI-FILE* 'Mns->MFevts)(PW::PW-addmenu-fun  *MIDI-FILE* 'ctrl->MFevts)(PW::PW-addmenu-fun  *MIDI-FILE* 'PB->MFevts)(PW::PW-addmenu-fun  *MIDI-FILE* 'sysex->MFevts)