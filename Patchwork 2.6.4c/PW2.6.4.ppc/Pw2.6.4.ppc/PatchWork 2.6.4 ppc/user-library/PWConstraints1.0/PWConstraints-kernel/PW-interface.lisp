;===============================================;===============================================;;; PWConstraints by Mikael Laurson (c), 1995;===============================================;===============================================(in-package :PW);==============================================================================;      A general PW-box that evaluates its inputs within the package "PWCS";==============================================================================(defclass C-PMC-box (C-patch) ())(defmethod patch-value ((self C-PMC-box) obj)  (declare (ignore obj))  (unwind-protect ;; ??    (let ((res ())          (old-package *package*))       (ccl::set-package "PWCS")      (setq res (call-next-method))      (ccl::set-package old-package)      res)));==============================================================================;     menubox-list for list of lists;==============================================================================(defclass C-menubox-lst-lst (C-menubox)    ((list-pointer :initform 0 :initarg :list-pointer :accessor list-pointer)    (box-list-pointer :initform 3 :initarg :box-list-pointer :accessor box-list-pointer))) (defmethod decompile ((self C-menubox-lst-lst))  `(make-instance ',(class-name (class-of self))          :view-position ,(view-position self)          :view-size ,(view-size self)          :dialog-item-text ,(dialog-item-text self)          :VIEW-FONT ',(VIEW-FONT self)          :doc-string ,(doc-string self)          :type-list ',(type-list self)          :list-pointer   ,(list-pointer self)          :min-val  ,(min-val self)          :max-val ,(max-val self)          :menu-box-list ',(menu-box-list self)          :box-list-pointer ,(box-list-pointer self)))(defmethod value ((self C-menubox-lst-lst)) `(list ,(list-pointer self) ,(box-list-pointer self)))(defmethod (setf value) (value (self C-menubox-lst-lst)) (when (listp value)  (setf (list-pointer self) (first value))  (setf (box-list-pointer self) (second value))))(defmethod set-numbox-item-text  ((self C-menubox-lst-lst) value)  (declare (ignore value))  (set-dialog-item-text self (menubox-value self))) (defmethod menubox-value  ((self C-menubox-lst-lst))  (let ((lst-now             (nth (mod (box-list-pointer self)(length pwcs::*all-SC-names*))                 pwcs::*all-SC-names*)))     (string (nth (mod (list-pointer self) (length lst-now)) lst-now)))) (defmethod view-draw-contents ((self C-menubox-lst-lst)) (with-font-focused-view self   (if (open-state self)       (call-next-method)       (draw-string 3 9 (doc-string self)))   (draw-rect 0 0 (w self)(h self))))(defmethod view-click-event-handler ((self C-menubox-lst-lst) where) (declare (ignore where)) (cond ((option-key-p)           (setf (box-list-pointer self)             (if (command-key-p)              (mod (1- (box-list-pointer self)) (length pwcs::*all-SC-names*))              (mod (1+ (box-list-pointer self)) (length pwcs::*all-SC-names*))))           (set-numbox-item-text self (box-list-pointer self))           (view-draw-contents self))        ((when (open-state self)            (with-focused-view self              (draw-rect 1 1 (- (w self) 2)(- (h self) 2)))                 (let* ((win (view-window self))                   (first-v (point-v (view-mouse-position win)))                   (last-mp (view-mouse-position win))                  (last-value (list-pointer self)))              (loop                (event-dispatch)                (unless (mouse-down-p) (return))                (let ((mp (view-mouse-position win)))                (unless (eql mp last-mp)                 (setq last-mp mp)                  (set-numbox-item-text self  ;;;;;                       (setf (list-pointer self)                        (max (min-val self) (min (max-val self)                          (+ last-value                           (* (map-mouse-increment self) (- first-v (point-v last-mp))))))))                 (view-draw-contents self)                (with-focused-view self                  (draw-rect 1 1 (- (w self) 2)(- (h self) 2)))))))          (view-draw-contents self))))      (item-action-after-drag self));================================================================;         new PW types;================================================================(defparameter *PC-name-ls-ls-type*  (make-type-object 'SC-name-list 'C-menubox-lst-lst      (list  :view-size (make-point 36 14)  :dialog-item-text "3-1"  :value 0                :type-list '(symbol list))))(add-type *PW-all-basic-types* *PC-name-ls-ls-type*)(defvar *pw-boolean-menu-type*  (make-type-object 'boolean 'C-menubox-val                    (list :view-size #@(36 14) :type-list '(no-connection) :value 0                    :menu-box-list '(("nil" . nil)("t" . t) ))))(add-type *PW-all-basic-types* *pw-boolean-menu-type*)(defparameter *-PC-function-type-*  (make-type-object '-sc-function- 'C-menubox      (list  :view-size (make-point 36 14) :dialog-item-text "SC" :value 0                :menu-box-list '("CARD" "PRIME" "ICV" "MEMBER-SETS" "COMPLEMENT-PCS") ; "SUBSETS" "SUPERSETS"                :type-list '(fix))))(add-type *PW-all-basic-types* *-PC-function-type-*)(add-alias-to-pw  'sc-card '(integer . (:value 3 :min-val 1 :max-val 12)))     (defparameter *engine-fns-type*  (make-type-object 'engine-fns 'C-menubox      (list  :view-size (make-point 36 14) :dialog-item-text "enginefn" :value 0                :menu-box-list '("engine" "allsols" "partialsol" "domains" "other-values")               :type-list '(fix))))(add-type *PW-all-basic-types* *engine-fns-type*);================================================================;================================================================;                      Menus;================================================================;================================================================; main menu(defparameter *PWCs-constraints-menu* (new-menu "PWConstraints"))(add-menu-items *pw-menu-Music* *PWCs-constraints-menu*);================================================================;================================================================;         PWCs menus;================================================================(defparameter *PWCs-menu* (new-menu "PWCs"))(add-menu-items *PWCs-constraints-menu* *PWCs-menu*)(defunp pw::PMC         ((s-space (list (:dialog-item-text "()")))          (rules  (list (:dialog-item-text "()")))          (fwc-rules (list (:dialog-item-text "()")))          (heuristic-rules (list (:dialog-item-text "()")))           (sols-mode (list (:dialog-item-text ":once")))          (rnd? boolean)         (print-fl boolean)) list"PMC is the first one of the two primary PWConstraints functions (the second one is score-PMC).PMC first creates a search-engine and then starts the search.  After the search is completed, PMC returns a list of solutions. The solutions should satisfy the constraintsgiven by the user. For more details, refer to the PWConstraints documentation.PMC has the following arguments:- s-space      a list of domains for each search-variable  - rules        a list of rules ('ordinary' PWConstraints rules)  - fwc-rules    a list of forward-checking rules  - heuristic-rules  a list of heuristic rules - sols-mode   indicates the number of solutions required:    :once, the default case, one solution,    :all   all solutions,      sols-mode can also be a positive integer giving the number of desired solutions. - rnd?       a flag indicating whether or not the search-space          is randomly reordered (by default rnd? is nil). - print-fl   a flag. If print-fl is true then the index of the current search-variable is printed    on the Listener window indicating how far the search has proceeded. "     (pwcs::pmc s-space rules                :fwc-rules fwc-rules                :heuristic-rules heuristic-rules                 :sols-mode sols-mode                :rnd? rnd?                :print-fl print-fl))(PW-addmenu-fun  *PWCs-menu* 'pw::PMC 'C-PMC-box);============================================================(defclass C-score-PMC-box (c-patch) ())(defmethod patch-value ((self C-score-PMC-box) obj)  (declare (ignore obj))  (assert (nth-connected-p self 0) ()          "*** 1st input should be connected to a polyfonic RTM-editor! ***!" ())  (let ((RTM-window (application-object (first (input-objects self)))))     (assert (eq (type-of RTM-window) 'c-rtm-editor-window) ()            "*** 1st input should be a polyfonic RTM-editor! ***!" ())    (setf *current-score-PMC-RTM-window* RTM-window)    (unwind-protect       (let ((res ())            (old-package *package*))         (ccl::set-package "PWCS")        (setq res (call-next-method))        (ccl::set-package old-package)        res))))(defunp pw::score-PMC         ((m-lines (list (:dialog-item-text "()")))          (ranges (list (:dialog-item-text "()")))         (rules  (list (:dialog-item-text "()")))          (fwc-rules (list (:dialog-item-text "()")))          (heuristic-rules (list (:dialog-item-text "()")))           (no-attack-rules (list (:dialog-item-text "()")))           (prepare-fns+args (list (:dialog-item-text "()")))         (allowed-pcs (list (:dialog-item-text "()")))         (sols-mode (list (:dialog-item-text ":once")))          (rnd? boolean)         (print-fl boolean)) list"score-PMC is the second one of the two primary PWConstraints functions (the first one is PMC).The main difference between PMC and score-PMC is that score-PMC uses always a prepared rhythmic structure (the first input of a score-PMC box). score-PMC first reads its inputs, creates a search-engine and then starts the search.  After the search is completed, score-PMC updates the input-score. The solution should satisfy the constraints given by the user.For more details, refer to the PWConstraints documentation.score-PMC has the following arguments:- m-lines  a list of measure-lines, defining the input score.  - ranges   either a simple range list, a list of lists of ranges or a list of measure-lines.             In the latter case the argument is given as a search-space score.  The next three arguments define the different rule types given by the user: - rules              a list of ordinary PWConstraints rules- heuristic-rules    a list of heuristic rules.  - non-attack-rules   a list of non-attack rules.  - prepare-fns+args  a list of user-definable preparation functions that are called before the search starts.                     They allow the user to customise the search problem. - allowed-pcs       a list of allowed pitch-classes. It is used to filter unwanted pitch-classes from the domains                     of the search-variables. For instance, by giving the list (0 2 4 5 7 9 11) we permit only 'white'                    notes of the piano keyboard.	- sols-mode   indicates the number of solutions required:              :once, the default case, one solution,              :all   all solutions,                sols-mode can also be a positive integer giving the number of desired solutions. - rnd?       a flag indicating whether or not the search-space              is randomly reordered (by default rnd? is nil). - print-fl   a flag. If print-fl is true then the index of the current search-variable is printed              on the Listener window indicating how far the search has proceeded."     (pwcs::score-PMC m-lines ranges rules                :fwc-rules fwc-rules                :heuristic-rules heuristic-rules                 :no-attack-rules no-attack-rules                :sols-mode sols-mode                :prepare-fns+args prepare-fns+args                :allowed-pcs allowed-pcs                :rnd? rnd?                :print-fl print-fl))(PW-addmenu-fun   *PWCs-menu* 'pw::score-PMC 'C-score-PMC-box);================================================================;         Utilities menu;================================================================(defparameter *PWCs-utilities-menu* (new-menu "Utilities"))(add-menu-items  *PWCs-constraints-menu* *PWCs-utilities-menu*)(defparameter *update-score-menu* (new-leafmenu "update score" 'pwcs::update-score)) (set-command-key *update-score-menu* #\U)(add-menu-items *PWCs-utilities-menu* *update-score-menu*)(defparameter *update-score-menu2* (new-leafmenu "update score" 'pwcs::update-score)) (set-command-key *update-score-menu2* #\U)(add-menu-items *RTM-menu* *update-score-menu2*)(add-menu-items *PWCs-utilities-menu* (new-leafmenu "scramble domains" 'pwcs::scramble-domains));(add-menu-items *PWCs-utilities-menu* (new-leafmenu "jumback ..." 'pwcs::jumpback-in-score));(add-menu-items *PWCs-utilities-menu* (new-leafmenu "continue search" 'pwcs::continue-search));;; (PW-addmenu  *PWCs-utilities-menu* '(pwcs::jumpback-in-score)) left out !!;================================================================;         Debug menu;================================================================(defparameter *PWCs-debug-menu* (new-menu "Debug"))(add-menu-items  *PWCs-constraints-menu* *PWCs-debug-menu*)(defparameter *Rule-diagnostics-menu* (new-leafmenu "rule diagnostics flag" 'set-Rule-diagnostics-fl))(add-menu-items *PWCs-debug-menu* *Rule-diagnostics-menu*)(defun set-Rule-diagnostics-fl ()  (setf pwcs::*constraint-diagnostics* (not pwcs::*constraint-diagnostics*))  (set-menu-item-check-mark *Rule-diagnostics-menu* pwcs::*constraint-diagnostics*));("Engine" "Allsols" "Partialsol")(defunp pwcs::engine-info ((function engine-fns)) list "allows the user to access some of the internals of the current search-engine. This box is useful for debugging purposes"  (let ((fn function))    (cond       ((string= fn "engine") (pwcs::engine))      ((string= fn "allsols") (when (pwcs::engine) (pwcs::all-sols (pwcs::engine))))      ((string= fn "domains")         (when (pwcs::engine) (mapcar #'(lambda (sv) (pwcs::domain sv)) (pwcs::search-variables-list (pwcs::engine)))))      ((string= fn "other-values")        (when (pwcs::engine) (mapcar #'(lambda (sv) (pwcs::other-values sv)) (pwcs::search-variables-list (pwcs::engine)))))      ((string= fn "partialsol")        (when (pwcs::engine) (mapcar #'pwcs::value (pwcs::search-variables-list (pwcs::engine))))))))(PW-addmenu  *PWCs-debug-menu* '(pwcs::engine-info));================================================================;         PCs menu;================================================================(defparameter *pcs-menu* (new-menu "PC-set-theory"))(add-menu-items *PWCs-constraints-menu* *pcs-menu*)(defun pwcs::sc (sc) sc)(defun pwcs::MEMBER-SETS (sc)   (let ((prime (pwcs::prime sc)) res)    (for (int 0 1 11)      (push (mapcar #'(lambda (n) (mod (+ int n) 12)) prime) res))    (nreverse res))) (defun pwcs::complement-pcs (sc)   (reverse (set-difference '(0 1 2 3 4 5 6 7 8 9 10 11) (pwcs::prime sc))))(defunt pwcs::sc-name  ((midis (list (:dialog-item-text "(60 61)")))) ()) (defunt pwcs::sc+off  ((midis (list (:dialog-item-text "(60 61)")))) ()) (defun pwcs::scs/card (card) "returns all SCs of a given cardinality (card)"  (nth card pwcs::*all-SC-names*))(defunt pwcs::scs/card ((card sc-card)) list)(PW-addmenu  *pcs-menu* '(pwcs::sc-name  pwcs::sc+off pwcs::scs/card));;(defunp pwcs::sc-info ((function -sc-function-) (sc-name SC-name-list)) list "allows to access information of a given SC (second input, SC-name). The type of information is defined by the first input (function). This input is a menu-box and contains the following menu-items:CARD          returns the cardinality of SC   PRIME         returns the prime form of SCICV           returns the interval-class vector of SCMEMBER-SETS   returns a list of the member-sets of SC              (i.e. all 12 transpositions of the prime form)COMPLEMENT-PCs   returns a list of PCs not included in the prime form of SC The second input is also a menu-box, where the user selectsthe SC-name. When the input is scrolled, it displays all SC-namesof a given cardinality. The cardinality can be incremented by alt-clicking  or decremented by alt-command-clicking the input.The input accepts also a list of SC-names. In this casethe SC-info box returns the requested information for all given SC-names."  ;(print (type-of (read-from-string  sc-name)))  (if (atom sc-name)    (funcall (read-from-string function)              (if (stringp sc-name)  (read-from-string sc-name) sc-name))    (let ((fn (read-from-string function)))      (mapcar #'(lambda (sc)                  (funcall fn (if (stringp sc)  (read-from-string sc) sc))) sc-name))))(PW-addmenu-fun   *pcs-menu* 'pwcs::sc-info 'C-PMC-box);;;;;; sub/supersets(defunp pw::sub/supersets ((sc-name SC-name-list) (card sc-card))         list"returns all subset classes of SC (when card is less than the cardinality of SC)or superset classes (when card is greater than the cardinality of SC) of cardinality card..The first input is a menu-box, where the user selectsthe SC-name. When the input is scrolled, it displays all SC-namesof a given cardinality. The cardinality can be incremented by alt-clicking  or decremented by alt-command-clicking the input."  (pwcs::sub/supersets (if (listp sc-name) sc-name (read-from-string sc-name)) card)) (PW-addmenu-fun   *pcs-menu* 'pw::sub/supersets 'C-PMC-box)(defunp pw::all-subs ((sc-name SC-name-list))         list"returns all subset classes of the given SC (SC-name),accepts also a list of SCs in which case all subset classes of the given SCs are appended (all duplicates are removed from the result).The first input is a menu-box, where the user selectsthe SC-name. When the input is scrolled, it displays all SC-namesof a given cardinality. The cardinality can be incremented by alt-clicking  or decremented by alt-command-clicking the input."  (pwcs::all-subs (if (listp sc-name) sc-name (read-from-string sc-name)))) (PW-addmenu-fun   *pcs-menu* 'pw::all-subs 'C-PMC-box);================================================================;         Music analysis menu;================================================================(defparameter *PMC-MA-menu* (new-menu "Music Analysis"))(add-menu-items *PWCs-constraints-menu* *PMC-MA-menu*)(defunp pw::MA-PMC1         ((m-lines (list (:dialog-item-text "()")))          (rules  (list (:dialog-item-text "()")))) list"MA-PMC1 is the first one of the two primary music analysis tools (the second one is MA-PMC2) providedby PWConstraints . MA-PMC1 has the following arguments:-  m-lines    a list of measure-lines (typically the output from a polyphonic RTM-box)             defining the input score - rules      a list of PWConstraints rulesMA-PMC1 is meant to be used to analyse a given score with standard PWConstraints rules. The rules are run for each note in the score (just like in score-PMC). If a given rule fails at some note, a message willbe printed to the Listener window, giving the number of the rule, the name of the rule and the exact position of the failure. For instance if we assume that a rule allowing only certain melodic intervals fails at measure 2 of part 1,  we get the following message:Rule no 1 'allowed ints' failed at: part 1, measure 2, beat 2, note 71 (B3)."      (pwcs::score-MA-PMC m-lines  rules))(PW-addmenu-fun   *PMC-MA-menu* 'pw::MA-PMC1 'C-PMC-box);===================================================(defclass C-score-MA-PMC-boxII (c-patch) ())(defmethod patch-value ((self C-score-MA-PMC-boxII) obj)  (declare (ignore obj))  (assert (nth-connected-p self 0) ()          "*** 1st input should be connected to a polyfonic RTM-editor! ***!" ())  (let ((RTM-window (application-object (first (input-objects self)))))     (assert (eq (type-of RTM-window) 'c-rtm-editor-window) ()            "*** 1st input should be a polyfonic RTM-editor! ***!" ())    (with-cursor *watch-cursor*      ;      (call-next-method)      (unwind-protect         (let ((res ())              (old-package *package*))           (ccl::set-package "PWCS")          (setq res (call-next-method))          (ccl::set-package old-package)          res)))    (setf (analysis-info (editor-collection-object  RTM-window)) pwcs::*part-collection*)))(defunp pw::MA-PMC2         ((m-lines (list (:dialog-item-text "()")))          (rules  (list (:dialog-item-text "()")))) list"MA-PMC2 is the second one of the two primary music analysis tools (the first one is MA-PMC1) providedby PWConstraints . MA-PMC2 has the following arguments:- m-lines    a list of measure-lines (a polyphonic RTM-box) defining the input score - rules      a list of PWConstraints 'analysis-rules'MA-PMC2 is meant to be used to write some analysis information directly to a PW RTM-editor.The rules used by MA-PMC2, called 'analysis-rules', are standard PWConstraints rules with apattern-matching part and a Lisp-code part, except the value returned by an  analysis-rule is not a truth value,but a collection of information consisting of:1.  the information to be printed below a note in the score2.  the 'note-position' where the information is to be printed. This    information is given as a variable name (i.e. ?1, ?2, etc.) given in the     pattern-matching part.3.   the row number where the information is to be printed. This allows the user to control the      layout of the information. For instance the following analysis-rule prints the melodic-index (mindex) of each notein the input score:(* ?1  (?if     (values     (mindex ?1)   ; information to be printed      ?1            ;  note-position     1)))           ; print at row number 1The following analysis-rule prints the SC identity of each melodic three notesuccession in the input score:(* ?1 ?2 ?3   (?if     (values     (sc-name (list (m ?1) (m ?2) (m ?3)))   ; information to be printed      ?1                                      ; note-position (print below ?1)     2)))                                    ; print at row number 2"     (pwcs::score-MA-PMCII m-lines  rules))(PW-addmenu-fun *PMC-MA-menu* 'pw::MA-PMC2 'C-score-MA-PMC-boxII);================================================================;         Doc menu;================================================================(defparameter *PWCS-doc-menu* (new-menu "DOC"))(add-menu-items *PWCs-constraints-menu* *PWCS-doc-menu*)(add-menu-items *PWCS-doc-menu*  (new-leafmenu "PMC" #'(lambda () (mapc #'show-documentation pwcs::*PMC-utility-fns*)))  (new-leafmenu "Lisp" #'(lambda () (mapc #'show-documentation pwcs::*Lisp-utility-fns*)))  (new-leafmenu "PC-set-theory" #'(lambda () (mapc #'show-documentation pwcs::*PC-set-theory-utility-fns*)))  (new-leafmenu "example functions" #'(lambda () (mapc #'show-documentation pwcs::*PWCS-example-utility-fns*)))  (new-leafmenu "-" nil)  (new-leafmenu "score-PMC" #'(lambda () (mapc #'show-documentation pwcs::*score-PMC-utility-fns*)))  (new-leafmenu "misc" #'(lambda () (mapc #'show-documentation pwcs::*score-PMC-misc-utility-fns*)))  (new-leafmenu "counterpoint" #'(lambda () (mapc #'show-documentation pwcs::*score-PMC-counterpoint-utility-fns*)))  (new-leafmenu "groups" #'(lambda () (mapc #'show-documentation pwcs::*score-PMC-group-utility-fns*))))