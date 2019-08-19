(in-package "PW");********* variables(defconstant *header-chunk-name* "MThd")(defconstant *track-chunk-name* "MTrk")(defvar *current-score* ())(defvar *end-o-stream* (cons nil nil))(defvar *running-type*)(defvar *running-channel*)(defvar *current-time* 0)(defvar *score-list* ())(defvar *note-off* 0)(defvar *note-on* 1)(defvar *control-change* 3)(defvar *program-change* 4)(defvar *poly-pressure* 2)  (defvar *pitch-bend* 6)   (defvar *channel-pressure* 5) (defvar *tempo* 60)(defvar *tempi* ());(setq  *current-score* (make-instance 'lp-score));(set-bits-per-beat *current-score* 60);(get-bits-per-beat *current-score*)(defclass lp-score ()  ((events :initarg :events :accessor events :initform nil :reader get-events)   (bits-per-beat :initarg :bits-per-beat :initform 480 :reader get-bits-per-beat)   (bits-per-second :initarg :bits-per-second :initform 480)   (tempo-bpm :initarg :tempo-bpm :initform 60 :reader get-tempo-bpm)   (score-name :initarg :score-name :accessor score-name :initform "No Name" :reader get-score-name)   (score-length  :initform 0 :reader get-score-length)   (last-event :initform nil)   (first-event-time :initform nil)   (rest-of-events :initform nil)   (output-channel :initarg :output-channel :initform 0                   :accessor output-channel)))(defmethod set-bits-per-beat ((self lp-score) value)  (setf (slot-value self 'bits-per-second) (round (* value (/ (get-tempo-bpm self) *tempo*)))        (slot-value self 'bits-per-beat) value)  );(setf *coin* (make-instance 'lp-score));(set-bits-per-beat *coin*  480);(round (* (get-bits-per-beat *coin*) 125000) 1000000) ; ?????????????;(defmethod set-tempo-bps ((self lp-score) new-tempo);  "Sets tempo in bits per second (precisely)";  (setf (slot-value self 'bits-per-second);        (round (* new-tempo (slot-value self 'tempo-scale)))));********* lp-scores : doit contenir les pistes d'un MIDIFILE (scores) **************(defclass lp-scores (lp-score)  ((scores :initform nil :accessor scores :initarg :scores :reader get-scores)));********* fonction de d�cryptage **************(defun n-bytes-to-num (num-bytes instream)  (do ((new-number 0 (+ (ash new-number 8) next-byte))       (next-byte (read-byte instream)                  (read-byte instream))       (byte-count 1 (1+ byte-count)))      ((>= byte-count num-bytes)        (+ (ash new-number 8) next-byte))    ))(defun n-bytes-to-string (num-bytes instream)  (let ((top-index (- num-bytes 1)))    (do ((new-string (make-string num-bytes))         (next-char (read-char instream nil *end-o-stream*)                    (read-char instream nil *end-o-stream*))         (letter-count 0 (1+ letter-count)))        ((or (>= letter-count top-index) (eql next-char *end-o-stream*))         (if (equal next-char *end-o-stream*)           (if (= letter-count 0)             *end-o-stream*             (throw 'file-error "ERROR: Unexpected end of stream while reading string"))           (progn             (setf (elt new-string letter-count) next-char)             new-string)))      (setf (elt new-string letter-count) next-char))))(defun get-chunk-type (instream)  (n-bytes-to-string 4 instream))(defun get-var-length-quantity (instream) ;retourne (dans cet ordre) la valeur de vlq??? et length   (do ((next-input (read-byte instream)                   (read-byte instream))       (sum 0 (+ (ash sum 7)(logand next-input #x7f)))       (length 1 (1+ length)))      ((= 0 (logand next-input #x80))       (values         (+ (ash sum 7) next-input)        length))    ))(defun eat-garbage ( garbage-length instream)  (do ((length garbage-length (1- length)))      ((= length 0) t)    (read-byte instream)))(defun read-garbage-chunk ( instream) (declare (ignore instream))); (eat-garbage (n-bytes-to-num 4 instream)) instream));*********************************************************;*********************************************************(defun read-midi-file (&optional (filename (choose-file-dialog :mac-file-type "Midi")))  "permet d'aller lire un fichier MIDI-FILEet retourne une liste d'objets correspondant chacun � une piste du fichier MIDI-FILEattention, suivant le format MIDI-FILE:format 0 = tous les �v�nements sont sur une m�me pisteformat 1 = les pistes sont s�par�es et la premi�rene contient que des infos g�n�rales (tempo etc...)"(setf *score-list* ())  (catch 'file-error    (with-open-file (instream filename                              :element-type 'unsigned-byte)      (do ((chunk-type (get-chunk-type instream) (get-chunk-type instream)))          ((eql chunk-type *end-o-stream*))        (setq *current-score* (make-instance 'lp-score)              *current-time* 0              *running-type* 0              *running-channel* 0)        (cond         ((equal chunk-type *header-chunk-name*)          (read-header instream))         ((equal chunk-type *track-chunk-name*)          (read-track instream))         (t          (read-garbage-chunk instream)))))    (setf *score-list* (reverse *score-list*))));(events (third *score-list* ));*********************************************************;*********************************************************; (read-mf);  (events *current-score*);*********************************************************;*********************************************************(defun read-header (instream)  (let ((length (n-bytes-to-num 4 instream))         (format (n-bytes-to-num 2 instream))         (ntrks  (n-bytes-to-num 2 instream)))    (declare (ignore length format ntrks))    (set-bits-per-beat *current-score* (n-bytes-to-num 2 instream)))) (defun read-track (instream)  (let ((length (1- (n-bytes-to-num 4 instream)))        (next-byte 0))    (while (> length 0)      (multiple-value-bind (delta-time time-length)                            (get-var-length-quantity instream)        (setq length (- length time-length))        (incf *current-time* delta-time)        (setq next-byte (read-byte instream)              length               (- length                  (case next-byte                   (#xFF                    (read-meta-event instream))                   (#xF0                    (read-sysex instream))               ; yet                   (#xF7                    (print "glop"))                 ; yet                   (t                    (let* ((running-status (not (= #x80 (logand next-byte #x80))))                           (message-type (if running-status                                           *running-type*                                           (ash (logand next-byte #x70) -4)))                           (channel-num (if running-status                                          *running-channel*                                          (logand next-byte #x0F))))                      (if running-status                        (read-midi-event message-type instream next-byte)                        (progn (setq *running-type* message-type                               *running-channel* channel-num)                         (read-midi-event message-type instream)))))                   )))))    (setf (events *current-score*) (reverse (events *current-score*)))    (push  *current-score* *score-list*)))(defun read-sysex (instream)  (let ((L '("sysex")) byte (length 2))    (print "sysex !!")    (until (eq #xF7 (setf byte (read-byte instream)))      (push byte L)      (setf length (1+ length))      )    (push      (print (list *current-time* (reverse L))) (events *current-score*))    length))(defun read-midi-event (message-type instream &optional next-byte)  (cond        ((= message-type 0)    (progn (push (list *current-time* (list "note-off" *running-channel*                                          (if next-byte next-byte (read-byte instream))                                          0))                  (events *current-score*))           (read-byte instream)           (if next-byte 2 3)))   ((= message-type 1)    (progn (push (list *current-time* (list "note-on" *running-channel*                                          (if next-byte next-byte (read-byte instream))                                          (read-byte instream)))                  (events *current-score*))           (if next-byte 2 3)))   ((= message-type 2)    (progn (push (list *current-time* (list "poly-p" *running-channel*                                           (if next-byte next-byte (read-byte instream))))                  (events *current-score*))           (if next-byte 1 2)))                   ((= message-type 3)    (progn (push (list *current-time* (list "ctrl" *running-channel*                                          (if next-byte next-byte (read-byte instream))                                          (read-byte instream)))                  (events *current-score*))           (if next-byte 2 3)))            ((= message-type 4)    (progn (push (list *current-time* (list "prg-chg"*running-channel*                                           (if next-byte next-byte (read-byte instream))))                  (events *current-score*))           (if next-byte 1 2)))            ((= message-type 5)    (progn (push (list *current-time* (list "ch-p" *running-channel*                                           (if next-byte next-byte (read-byte instream))))                  (events *current-score*))           (if next-byte 1 2)))             ((= message-type 6)    (progn (push (list *current-time* (list "pitch-bend" *running-channel*                                          (if next-byte next-byte (read-byte instream))                                          (read-byte instream)))                  (events *current-score*))           (if next-byte 2 3)))    ))(defun read-meta-event (instream)  (let ((meta-event-type (read-byte instream)))  ;(format "Meta-event, type: ~x, " meta-event-type)    (case meta-event-type      (0      (read-sequence-num  instream))      (3       (read-track-name instream ))      ((1 2 4 5 6 7)       (read-text-event instream))      (#x2f       (read-end-o-track instream))      (#x51       (read-set-tempo instream))      (#x54       (read-smpte-offset instream))      (#x59       (read-key-signature instream))      (#x58       (read-time-signature instream))      (t       (read-garbage-meta-event instream)))    ))(defun read-sequence-num ( instream)  (multiple-value-bind (length length-o-length) (get-var-length-quantity instream)    (format t "Sequence num :~a~%" (n-bytes-to-string length instream)) ;print le n� des seqs    ;(eat-garbage length instream)    (+ 2 length-o-length length)))(defun read-track-name (instream)  (multiple-value-bind (length length-o-length) (get-var-length-quantity instream)    (let ((name (n-bytes-to-string length instream)))          (format t "nom de la piste = ~a ~%" name)      (setf (score-name  *current-score*) name)      (+ 2 length-o-length length))))(defun read-text-event ( instream)  (multiple-value-bind (length length-o-length) (get-var-length-quantity instream)   ;(format t "text ~%")     (eat-garbage length instream)    (+ 2 length-o-length length)))(defun read-end-o-track ( instream)  (multiple-value-bind (length length-o-length) (get-var-length-quantity instream)   ; (format t "end o track ~%")    (+ 2 length-o-length length)))(defun read-set-tempo ( instream)  (multiple-value-bind (length length-o-length) (get-var-length-quantity instream)     (let ((tempo (round (* (get-bits-per-beat *current-score*) 125000)                        (n-bytes-to-num 3 instream))))      (setf *tempo* tempo)      (format t "tempo ~a ~%"  tempo)      (push (list (round (* (/ *current-time* (get-bits-per-beat *current-score*)) 100)) *tempo*) *tempi*)    (+ 2 length-o-length length)))) ;Return the length(defun read-smpte-offset (instream)  (multiple-value-bind (length length-o-length) (get-var-length-quantity instream) ; (format t "smpte ~%")      (eat-garbage length instream)    (+ 2 length-o-length length)))(defun read-key-signature ( instream)  (multiple-value-bind (length length-o-length) (get-var-length-quantity instream)    ; (format t "key signature ~%" )    (eat-garbage length instream)    (+ 2 length-o-length length))) ;Return the length(defun read-time-signature ( instream)  (multiple-value-bind (length length-o-length) (get-var-length-quantity instream) ;(format t "time signature ~%")    (eat-garbage length instream)    (+ 2 length-o-length length)))(defun read-garbage-meta-event (instream)  (multiple-value-bind (length length-o-length) (get-var-length-quantity instream) (format t "unknown meta-event ~%")    (eat-garbage length instream)    (+ 2 length-o-length length))) ;Return the length