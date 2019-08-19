;;;;=========================================================;;;;  KANT PATCH-WORK;;;;  Rep. Mus.;;;;  � 1994 IRCAM ;;;;=========================================================(defpackage "C-PATCH-BOX-KANT"   (:use "COMMON-LISP" "CCL")  (:import-from "PATCH-WORK"                 "PATCH-VALUE" "MAKE-APPLICATION-OBJECT" "APPLICATION-OBJECT" "PW-FUNCTION-STRING" "CHORDS"                "C-PATCH-MIDI" "C-PATCH-MIDI-MOD" "C-MUS-NOT-VIEW" "C-PATCH-APPLICATION" "PW-FUNCTION-STRING" "GIVE-MN-EDITOR"                 "CHORD-LINE" "CHORD-SEQ"  "MAKE-EXTRA-CONTROLS" "C-NUMBOX" "CTRL-SETTINGS" "BEGIN-PROCESS" "COLLECT"                 "C-MN-WINDOW-MOD"  "C-MN-VIEW-MOD" "C-MN-PANEL-MOD" "EXTERNAL-CONTROLS" "SET-UP-DIALOG" "ACTIVE-EDITOR"                 "EXTERNAL-CONTROLS" "SET-DISPLAY-VALUE" "UPDATE-EDITOR" "SET-STAFF-COUNT" "EDITOR-OBJECTS"                 "VIEW-DOUBLE-CLICK-EVENT-HANDLER" "WINDOW-MOUSE-UP-EVENT-HANDLER" "VIEW-MOUSE-UP" "DEFUNP" "PW-ADDMENU"                 "VIEW-KEY-EVENT-HANDLER" "OPEN-APPLICATION-HELP-WINDOW" "VIEW-MOUSE-DRAGGED" )  (:export "C-PATCH-BOX-KANT"  "C-MN-VIEW-MOD-KANT" "C-MN-WINDOW-MOD-KANT"))(in-package "C-PATCH-BOX-KANT")(import '(epw::flat-once ));============= APPLICATION BOX + WINDOW FOR KANT============(defclass C-patch-box-kant (C-patch-midi-Mod )())(defclass C-mn-window-mod-kant  (pw::C-mn-window-mod )())(defclass C-MN-panel-Mod-kant  (pw::C-MN-panel-Mod )())(defclass Kstatic-text-dialog-item (static-text-dialog-item) ())(defmethod collect ((self C-patch-box-kant)) (declare (ignore self)))(defmethod pw::clock ((self C-patch-box-kant)) (pw::clock pw::*global-clock*))(defmethod  begin-process ((self C-patch-box-kant)) (declare (ignore self)))(defmethod yourself-if-collecting ((self C-patch-box-kant)) nil)(defmethod draw-patch-extra :after ((self C-patch-box-kant))  (pw::draw-char (+ -16 (pw::w self)) (- (pw::h self) 4) #\E))(defmethod initialize-instance :after ((self C-patch-box-kant) &key controls)  (declare (ignore controls))  (pw::-make-lock self (make-point (- (pw::w self) 30) (- (pw::h self) 10)))  self)(defmethod window-close-event-handler ((self C-mn-window-mod-kant))  (kill-bpf (car (subviews self)))  (window-hide self)     (window-select (pw::pw-win self)))(defmethod set-dialog-item-text-from-dialog ((self C-patch-box-kant) str)  (declare (ignore str))  (call-next-method)  (let ((editor (application-object self)))    (if (and editor (wptr editor))      (set-window-title editor (pw-function-string self)))))(defmethod pw::decompile ((self  C-patch-box-kant))  (let* ((form (call-next-method ))         (last (first (last form))))    (setf (rest (last last))          (if pw::*decompile-chords-mode*             (list `(quote ,(save-etat (car (subviews (application-object self))))))            (list nil)))    form))    (defmethod pw::complete-box ((self C-patch-box-kant) args)  (declare (special *list-method-seg*))  (declare (special *list-method-arch*))  (call-next-method)  (let ((argu  (third args))        (objet (car (subviews (application-object self)))))    (if (not (null argu ))      (if (and (eq (length (nth 15 argu)) (+ 2 (length *list-method-seg*)))               (eq (length (nth 16 argu)) (+ 1 (length *list-method-arch*))) (eq (length argu) 29))          (progn          (setf (active-menu objet) (nth 0 argu))          (setf (entre objet) (nth 1 argu))          (setf (entre-m2 objet) (nth 2 argu))          (setf (domaine objet) (nth 3 argu))          (setf (rep-seg objet) (nth 4 argu))          (setf (compaces objet) (nth 5 argu))          (setf (resume-m1 objet) (nth 6 argu))          (setf (rep-m1 objet) (nth 7 argu))          (setf (rep-m2 objet) (nth 8 argu))          (setf (resume-m2 objet) (nth 9 argu))          (setf (parametre-seg objet) (nth 10 argu))          (setf (parametre-arch objet) (nth 11 argu))          (setf (parametre-gral objet) (nth 12 argu))          (set-dialog-item-text (tol1  objet) (first (parametre-gral objet)))          (set-dialog-item-text (tol2 objet) (second (parametre-gral objet)))          (set-dialog-item-text (slot-value objet 'minsd) (third (parametre-gral objet)))          (set-dialog-item-text (slot-value objet 'btimes) (fourth (parametre-gral objet)))          (set-dialog-item-text (slot-value objet 'maxi) (fifth (parametre-gral objet)))          (set-dialog-item-text (slot-value objet 'preci) (sixth (parametre-gral objet)))          (set-dialog-item-text (slot-value objet 'forbid) (seventh (parametre-gral objet)))          (setf (papa objet) self)          (setf (entre2 objet) (nth 13 argu))          (setf (list-of-mes objet) (nth 14 argu))          (setf (marcas-seg objet) (nth 15 argu))          (setf (marcas-archi objet) (nth 16 argu))          (setf (forbid-list objet) (nth 17 argu))          (setf (preci-list objet) (nth 18 argu))          (setf (max-list objet) (nth 19 argu))          (setf (entre3 objet) (nth 20 argu))          (setf (entre-pitch objet) (nth 21 argu))          (setf (entre2-pitch objet) (nth 22 argu))          (setf (selection-m1 objet) (nth 23 argu))          (setf (entre3-pitch objet) (nth 24 argu))          (setf (entre-velo objet) (nth 25 argu))          (setf (entre2-velo objet) (nth 26 argu))          (setf (entre3-velo objet) (nth 27 argu))          (setf (tot-or-rel objet) (nth 28 argu))          (setf (ant-size objet) 0))        (progn (ed-beep)                (print "change in the number of methods, the last state has been deleted")               (ed-beep))))    (case (active-menu objet)      (1 (progn           (disable-menu objet 3)           (disable-menu objet 2)))      (2 (progn           (setf (cambio-resume objet) 0)           (setf (ant-menu objet) 2)           (setf (enable (popUpBox2 objet)) t)           (disable-menu objet 3))       )      (3 (progn           (setf (cambio-resume objet) 0)           (setf (ant-menu objet) 3)           (setf (enable (popUpBox2 objet)) t)           (setf (enable (popUpBox3 objet)) t)           (set-part-color (popUpBox3 objet) :body 0)           (set-part-color (popUpBox3 objet) :text 16777215))))))    (defmethod correct-extension-box ((self C-patch-box-kant) new-box values)  (declare (ignore values))  (let* ((new-win (application-object new-box))         (new-editor          (car (pw::editor-objects (car (subviews new-win))))))    (if (wptr (application-object self)) (window-close(application-object self)))    (setf (chord-seq new-box) (chord-seq self))    (setf (chord-line new-editor) (chord-seq new-box))    (pw::put-window-state new-box new-win (pw::window-state self))))(defun check-and-def (lista refer num)  (let* ((i -1))    (mapcar #'(lambda (mes)                (incf i)                (let* ((j 0))                  (mapcar #' (lambda (mes1)                               (if (< mes1 0) 0                                   (if (nth j (nth i lista))                                     (prog1  (nth j (nth i lista))                                         (incf j))                                      (case num (1 6000) (2 100))))) mes))) refer)))(defun sumelos (num lis lis2)  (mapcar #'(lambda (li dur)              (if (> dur 0)                (+ num li)                (* -1 (+ num li)))) lis lis2))(defun to-durations (lis)  (let* ((i 1) (long (length lis)) resp)    (while (< i long)      (push (if (>= (nth (- i 1) lis) 0) (- (abs (nth i lis)) (abs (nth (- i 1) lis)))                (* -1 (- (abs (nth i lis)) (abs (nth (- i 1) lis))))) resp)      (incf i))    (reverse (delete 0 resp))))    (defmethod get-from-obj ((self pw::C-chord-line) num)  (let* ((rep (pw::flat (mapcar #'(lambda (lis)                        (case num                          (1 (sumelos (pw::t-time lis) (pw::ask-all (pw::notes lis) 'pw::offset-time) (pw::ask-all (pw::notes lis) 'pw::dur)))                          (2 (pw::ask-all (pw::notes lis) 'pw::midic))                          (3 (pw::ask-all (pw::notes lis) 'pw::vel)))) (pw::chords self)))))    (if (= num 1)      (concatenate 'list (to-durations rep) (last (pw::ask-all (pw::notes (car (last (pw::chords self)))) 'pw::dur)))      rep)))(defmethod patch-value ((self C-patch-box-kant) obj)  (if (pw::value  self)    (reverse (sortie (car (subviews (application-object self)))))    (let* ((durs (patch-value (first (pw::input-objects self)) obj))           (durs (if (listp (car durs)) durs (list durs)))           (pitchs (patch-value (second (pw::input-objects self)) obj))           (velos (patch-value (third (pw::input-objects self)) obj))           (objs (and (fourth (pw::input-objects self)) (patch-value (fourth (pw::input-objects self)) obj)))           (objs (if (listp objs) objs (list objs)))           (objet (car (subviews (application-object self))))           cord n )       (setf (papa objet) self)      (setf (cambio-resume objet) 1)      (when pitchs        (if (not (listp (car pitchs))) (setf pitchs (list pitchs))))      (when velos        (if (not (listp (car velos))) (setf velos (list velos))))      (if objs        (progn            (setf (entre objet) (mapcar #' (lambda (lis) (get-from-obj lis 1)) objs))            (setf (entre-pitch objet)  (mapcar #' (lambda (lis) (get-from-obj lis 2)) objs))          (setf (entre-velo objet)  (mapcar #' (lambda (lis) (get-from-obj lis 3)) objs)))        (progn          (setf (entre objet) durs)           (setf (entre-pitch objet) (check-and-def pitchs (entre objet) 1 ))          (setf (entre-velo objet) (check-and-def velos (entre objet) 2))))      (setf n (length (entre objet)))      (setf cord (mk-aficha (entre objet))) ; ojo este mete los nuevos valores negativos      (setf (pw::chords (pw::chord-seq self))             (butlast cord n))      (setf (marcas-archi objet) (mapcan #'(lambda (mes)                                             (declare (ignore mes))                                             (list nil)) (marcas-archi objet)))      (setf (domaine objet) (list 0   (- (length cord) 1)))        (setf (resume-m1 objet) (domaine objet))      (setf (active-menu objet) 1)      (disable-menu objet 3)      (disable-menu objet 2)          (reverse (sortie (car (subviews (application-object self))))))))  (defmethod make-application-object ((self C-patch-box-kant))  (setf  pw::*MN-C5* 100)  (setf (application-object self)        (pw::make-music-notation-editor 'C-mn-window-mod-kant 'C-MN-view-mod-kant 'C-MN-panel-Mod-kant                                        (make-point 650 200) pw::*g-plain-staffs*                                        (pw-function-string self)))  (let* ((objet (car (subviews (application-object self)))))    (all-methodes objet)    (setf (chord-line (give-MN-editor self)) (chord-seq self))    (setf pw::*mn-view-offset-flag* t)    (when (car (last (pw::chords (pw::chord-seq self))))      (setf (cambio-resume objet) 1)      (setf (active-menu objet) 1)      (disable-menu objet 3)      (disable-menu objet 2)          (setf (papa objet) self)      (setf (domaine objet) (list 0  (+ (length (pw::chords (pw::chord-seq self))) (- (length (entre objet)) 1))))      (setf (resume-m1  objet) (domaine  objet)))    (application-object self)));VIEW-MOD KANT(defclass C-MN-view-mod-kant (C-mus-not-view)   ((papa :initform nil :accessor papa)   (sortie :initform nil :accessor sortie)   (active-menu :initform 1 :accessor active-menu)   (entre :initform nil :accessor entre)   (entre-velo :initform nil :accessor entre-velo)   (entre2-velo :initform nil :accessor entre2-velo)   (entre3-velo :initform nil :accessor entre3-velo)   (entre-pitch :initform nil :accessor entre-pitch)   (entre2-pitch :initform nil :accessor entre2-pitch)   (entre3-pitch :initform nil :accessor entre3-pitch)   (entre2 :initform nil :accessor entre2)   (entre3 :initform nil :accessor entre3)   (entre-m2 :initform nil :accessor entre-m2)   (patte :initform nil :accessor patte)   (domaine :initform nil :accessor domaine)   (rep-kant :initform nil :accessor rep-kant)   (pos-mouse :initform nil :accessor pos-mouse)   (selected-par :initform nil :accessor selected-par)   (selection-m1 :initform nil :accessor selection-m1)   (car-select :initform nil :accessor car-select)   (act-num :initform 0 :accessor act-num)   (num-kant :initform 0 :accessor num-kant)   (ant-scroll-v :initform nil :accessor ant-scroll-v)   (ant-zoom :initform 0 :accessor ant-zoom)   (marcas-seg :initform '(nil nil) :accessor marcas-seg)   (marcas-archi :initform '(nil) :accessor marcas-archi)   (simbol-seg :initform '("�"  "#") :accessor simbol-seg)   (parametre-seg :initform '(nil) :accessor parametre-seg)   (parametre-arch :initform nil :accessor parametre-arch)   (parametre-gral :initform nil :accessor parametre-gral)   (simbol-archi :initform '("�") :accessor simbol-archi)    (vis-marcas-archi :initform '( nil) :accessor vis-marcas-archi)   (vis-marcas-seg :initform '( nil  nil ) :accessor vis-marcas-seg)   (rep-seg :initform nil :accessor rep-seg)   (vis-compaces :initform nil :accessor vis-compaces)   (compaces :initform nil :accessor compaces)   (cambio-marca :initform 0 :accessor cambio-marca)   (cambio-resume :initform 1 :accessor cambio-resume)   (resume-selected :initform nil :accessor resume-selected)   (popUpBox1 :initform nil :accessor popUpBox1)   (popUpBox2 :initform nil :accessor popUpBox2)   (popUpBox3 :initform nil :accessor popUpBox3)   (*Kant-popUpMenu1* :initform nil)   (*Kant-popUpMenu2* :initform nil)   (*Kant-popUpMenu3* :initform nil)   (list-of-mes :initform nil :accessor list-of-mes)   (minnotes1 :initform nil)   (minnotes2 :initform nil)   (maxnotes1 :initform nil)   (maxnotes2 :initform nil)   (err1 :initform nil)   (err2 :initform nil)   (val-tol1 :initform nil :accessor tol1)   (val-tol2 :initform nil :accessor tol2)   (forbid :initform nil)   (forb2 :initform nil)   (active-diag :initform nil :accessor active-diag)   (maxi :initform nil)   (maxi2 :initform nil)   (deltachord :initform nil)   (preci :initform nil)   (preci2 :initform nil)   (kant1 :initform nil)   (kant2 :initform nil)   (btimes :initform nil :accessor btimes)   (minsd :initform nil :accessor minsd)   (sequence :initform nil :accessor sequence)   (auto-tol :initform nil :accessor auto-tol)   (bpf :initform nil :accessor bpf)   (bpf-p :initform nil :accessor bpf-p)   (bpf-v :initform nil :accessor bpf-v)   (ant-scroll :initform 0 :accessor ant-scroll)   (ant-size :initform 0 :accessor ant-size)   (edit-archi :initform nil :accessor edit-archi)   (edit-mesu :initform nil :accessor edit-mesu)   (new-view :initform nil :accessor new-view)   (resume-m1 :initform nil :accessor resume-m1)   (rep-m1 :initform nil :accessor rep-m1)   (rep-m2 :initform nil :accessor rep-m2)   (vis-resume-m1 :initform nil :accessor vis-resume-m1)   (resume-m2 :initform nil :accessor resume-m2)   (vis-resume-m2 :initform nil :accessor vis-resume-m2)   (forbid-list :initform nil :accessor forbid-list)   (vis-forbid :initform nil :accessor vis-forbid)   (max-list :initform nil :accessor max-list)   (vis-max :initform nil :accessor vis-max)   (preci-list :initform nil :accessor preci-list)   (vis-preci :initform nil :accessor vis-preci)   (cont :initform 0 :accessor cont)   (ant-menu :initform 1 :accessor ant-menu)   (cambio-par :initform 0 :accessor cambio-par)   (multi-sele :initform nil :accessor multi-sele)   (ok-b :initform nil :accessor ok-b)   (item-selc :initform nil :accessor item-selec)   (item-selected :initform nil :accessor item-selected)   (tot-or-rel :initform 1 :accessor tot-or-rel)   (OK-button :initform nil)   (cancel-button :initform nil)))(defmethod set-up-dialog ((self C-MN-view-mod-kant))  (setf (slot-value self 'minnotes1)        (make-instance 'pw::editable-text-dialog-item          :dialog-item-text  "0"           :view-position (make-point 65 10)          :view-size (make-point 40 16)          :view-font '("monaco" 9 :srcor)))  (setf (slot-value self 'minnotes2)        (make-instance 'pw::editable-text-dialog-item          :dialog-item-text  "0"           :view-position (make-point 188 10)          :view-size (make-point 40 16)          :view-font '("monaco" 9 :srcor)))  (setf (slot-value self 'maxnotes1)        (make-instance 'pw::editable-text-dialog-item          :dialog-item-text  "10"           :view-position (make-point 65 45)          :view-size (make-point 40 16)          :view-font '("monaco" 9 :srcor)))  (setf (slot-value self 'maxnotes2)        (make-instance 'pw::editable-text-dialog-item          :dialog-item-text  "500"           :view-position (make-point 188 45)          :view-size (make-point 40 16)          :view-font '("monaco" 9 :srcor)))  (setf (slot-value self 'err1)        (make-instance 'pw::editable-text-dialog-item          :dialog-item-text  "0"           :view-position (make-point 65 80)          :view-size (make-point 40 16)          :view-font '("monaco" 9 :srcor)))  (setf (slot-value self 'err2)        (make-instance 'pw::editable-text-dialog-item          :dialog-item-text  "0"           :view-position (make-point 188 80)          :view-size (make-point 40 16)          :view-font '("monaco" 9 :srcor)))  (setf (slot-value self 'val-tol1)        (make-instance 'pw::editable-text-dialog-item                       :dialog-item-text  "0.01"                        :view-position (make-point 186 40)                       :view-size (make-point 40 16)                       :view-font '("monaco" 9 :srcor)))  (setf (slot-value self 'val-tol2 )        (make-instance 'pw::editable-text-dialog-item                       :dialog-item-text  "0.01"                        :view-position (make-point 186 60)                       :view-size (make-point 40 16)                       :view-font '("monaco" 9 :srcor)))   (setf (slot-value self 'minsd)        (make-instance 'pw::editable-text-dialog-item                       :dialog-item-text  "30"                        :view-position (make-point 186 80)                       :view-size (make-point 40 16)                       :view-font '("monaco" 9 :srcor))) (setf (slot-value self 'sequence)        (make-instance 'pw::editable-text-dialog-item                       :dialog-item-text "()"                       :view-position (make-point 66 115)                       :view-size (make-point 195 16)                       :view-font '("monaco" 9 :srcor)))  (setf (slot-value self 'btimes)        (make-instance 'pw::editable-text-dialog-item                       :dialog-item-text  "1"                       :view-position (make-point 186 100)                       :view-size (make-point 40 16)                       :view-font '("monaco" 9 :srcor)))(setf (slot-value self 'kant1)        (make-instance 'pw::radio-button-dialog-item                       :view-position (make-point 15 120)                       :dialog-item-text " _/4"                       :view-font '("monaco" 9 :srcor)                       :dialog-item-action                       #'(lambda(item) (declare (ignore item)) (setf (num-kant self) 0)))) (setf (slot-value self 'kant2)        (make-instance 'pw::radio-button-dialog-item                       :view-position (make-point 115 120)                       :dialog-item-text " _/8"                       :view-font '("monaco" 9 :srcor)                       :dialog-item-action                       #'(lambda(item) (declare (ignore item)) (setf (num-kant self) 1)))) (setf (slot-value self 'maxi)        (make-instance 'pw::editable-text-dialog-item                       :dialog-item-text  "8"                        :view-position (make-point 186 40)                       :view-size (make-point 40 16)                       :view-font '("monaco" 9 :srcor)))  (setf (slot-value self 'auto-tol)        (make-instance 'pw::check-box-dialog-item                       :view-position (make-point 15 10)))  (check-box-check (slot-value self 'auto-tol))  (setf (slot-value self 'maxi2)        (make-instance 'pw::editable-text-dialog-item                       :dialog-item-text "8"                       :view-position (make-point 50 10)                       :view-size (make-point 220 16)                       :view-font '("monaco" 9 :srcor)))    (setf (slot-value self 'preci )        (make-instance 'pw::editable-text-dialog-item                       :dialog-item-text  "0.2"                        :view-position (make-point 186 60)                       :view-size (make-point 40 16)                       :view-font '("monaco" 9 :srcor)))   (setf (slot-value self 'preci2 )        (make-instance 'pw::editable-text-dialog-item                       :dialog-item-text "0.2"                       :view-position (make-point 50 10)                       :view-size (make-point 220 16)                       :view-font '("monaco" 9 :srcor)))  (setf (slot-value self 'forbid)        (make-instance 'pw::editable-text-dialog-item                       :dialog-item-text  "()"                        :view-position (make-point 186 80)                       :view-size (make-point 40 16)                       :view-font '("monaco" 9 :srcor)))  (setf (slot-value self 'forb2)        (make-instance 'pw::editable-text-dialog-item                       :dialog-item-text "( )"                       :view-position (make-point 50 10)                       :view-size (make-point 220 16)                       :view-font '("monaco" 9 :srcor))) (setf (slot-value self 'OK-button)        (make-instance 'pw::button-dialog-item                       :default-button t                       :dialog-item-text "OK"                       :view-position (make-point 80 150)                       :view-size (make-point 40 23)                       :dialog-item-action                       #'(lambda(item) (declare (ignore item)) (do-chosen-action self)))) (setf (slot-value self 'Cancel-button)         (make-instance 'pw::button-dialog-item                       :default-button ()                       :dialog-item-text "cancel"                       :view-position (make-point 160 150)                       :view-size (make-point 60 25)                       :dialog-item-action                       #'(lambda(item) (declare (ignore item)) (return-from-modal-dialog nil))))  )(defmethod make-extra-controls ((self C-MN-view-mod-kant))  (let ((v-extreme (+  (point-v (view-position self)) (point-v (view-size self)) 10))        (h-initial (+ 2 (point-h (view-position self)))))    (setf (external-controls self)          (list           (make-instance             'pw::C-zoomer             :the-view self             :view-container (view-window self)             :view-position (make-point h-initial v-extreme)             :min-val -1000)           (make-instance             'static-text-dialog-item             :view-container (view-window self)             :view-position              (make-point (+ h-initial 60) (- v-extreme 2))             :dialog-item-text "zoom"             :view-font '("monaco"  9  :srcor))))    (setf (ctrl-settings self) nil)))(defmethod make-extra-controls :after ((self C-MN-view-mod-kant))  (make-kant-menu self)  (let* ((x-pos (+ 86 (point-h (view-position self))))         (y-pos (+  (point-v (view-position self)) (point-v (view-size self)) -35))         (ctrls (list                 (setf (popUpBox1 self) (make-popUpkant "archi" self                                                        (slot-value self '*Kant-popUpMenu1*)                                                        :view-position (make-point (+ x-pos 160) (+ y-pos 18))                                                        :view-container (view-window self)))                 (setf (popUpBox2 self) (make-popUpkant "measure" self                                                        (slot-value self '*Kant-popUpMenu2*)                                                        :view-position (make-point (+ x-pos 210) (+ y-pos 18))                                                        :view-container (view-window self)))                 (setf (popUpBox3 self) (make-popUpkant "quantify" self                                                        (slot-value self '*Kant-popUpMenu3*)                                                        :view-position (make-point (+ x-pos 283) (+ y-pos 18))                                                        :view-container (view-window self)))                 (make-instance 'pw::C-numbox-staffcnt                     :view-size (make-point 36 14)                   :value 1 :min-val 1 :max-val 10                   :type-list '(fixnum)                   :view-container (view-window self)                   :view-position (make-point (+ x-pos 104) (+ y-pos 16)))                 (make-instance 'pw::static-text-dialog-item                   :view-container (view-window self)                   :view-position (make-point (+ x-pos 104) (+ y-pos 2))                   :dialog-item-text "stcnt"                   :view-font '("monaco"  9  :srcor)                   :view-size (make-point 36 12))                 (make-instance 'pw::static-text-dialog-item                   :view-container (view-window self)                   :view-position (make-point (+ x-pos 44) (+ y-pos 16))                   :dialog-item-text " "                   :view-font '("monaco"  9  :srcor)                   :view-size (make-point 50 12)))))    (setf (enable (popUpBox1 self)) t)    (setf (kant-ob (popUpBox1 self)) self)    (setf (kant-ob (popUpBox3 self)) self)    (setf (kant-ob (popUpBox2 self)) self)    (setf (num (popUpBox1 self)) 1)    (setf (num (popUpBox2 self)) 2)    (setf (num (popUpBox3 self)) 3)    (setf (pw::external-controls self) (append (pw::external-controls self) ctrls))    (set-up-dialog self)))(defmethod save-etat ((self C-MN-view-mod-kant)) (let (rep)   (setf rep (cons (active-menu self) rep))   (setf rep (cons (entre self) rep))   (setf rep (cons (entre-m2 self) rep))   (setf rep (cons (domaine self) rep))   (setf rep (cons (rep-seg self) rep))   (setf rep (cons (compaces self) rep))   (setf rep (cons (resume-m1 self) rep))   (setf rep (cons (rep-m1 self) rep))   (setf rep (cons (rep-m2 self) rep))   (setf rep (cons (resume-m2 self) rep))   (setf rep (cons (parametre-seg self) rep))   (setf rep (cons (parametre-arch self) rep))   (setf (parametre-gral self)         (list (dialog-item-text (slot-value self 'val-tol1))               (dialog-item-text (slot-value self 'val-tol2))               (dialog-item-text (slot-value self 'minsd))               (dialog-item-text (slot-value self 'btimes))               (dialog-item-text (slot-value self 'maxi))               (dialog-item-text (slot-value self 'preci))               (dialog-item-text (slot-value self 'forbid))))   (setf rep (cons (parametre-gral self) rep))   (setf rep (cons (entre2 self) rep))   (setf rep (cons (list-of-mes self) rep))   (setf rep (cons (marcas-seg self) rep))   (setf rep (cons (marcas-archi self) rep))   (setf rep (cons (forbid-list self) rep))   (setf rep (cons (preci-list self) rep))   (setf rep (cons (max-list self) rep))   (setf rep (cons (entre3 self) rep))   (setf rep (cons (entre-pitch self) rep))   (setf rep (cons (entre2-pitch self) rep))   (setf rep (cons (selection-m1  self) rep))   (setf rep (cons (entre3-pitch  self) rep))   (setf rep (cons (entre-velo self) rep))   (setf rep (cons (entre2-velo self) rep))   (setf rep (cons (entre3-velo self) rep))   (setf rep (cons (tot-or-rel self) rep))   (reverse rep)))