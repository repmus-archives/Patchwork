;===============================================(in-package "PWCS");===============================================#|; Each "rule" returns a symbol, number etc. and a s-var where the info is printed; y-row of info ; x-position of the note (* ?1  (?if     (values     (mindex ?1)   ; value returned      ?1            ; note-position to be printed     1))           ; y-row to be printed"mindex of ?1")(* ?1  (?if     (if (= (mod (mindex ?1) 5) 0)    (values     (sindex ?1)   ; value returned      ?1            ; note-position to be printed     1)           ; y-row to be printed    ()))"mindex of ?1 mod 5")(* ?1 ?2 ?3   (?if     (values     (sc-name (list (m ?1) (m ?2) (m ?3)))   ; value returned      ?1                                      ; note-position to be printed     2))                                     ; y-row to be printed"imbricates melodic 3 card scs")(* ?1 (?if        (if (complete-chord? ?1)          (values          (sc-name (cons (m ?1) (hc-midis ?1)))    ; value returned           (pwcs::give-bass-item ?1)                ; note-position to be printed          3                                        ; y-row to be printed          ?1)                                      ; x-position         ()))                                      ; () = no analysis   "harmonic scs")|##|1. patch-value MA-box:    - erase all old MA-info    - make a staff-collection    - run rules     - write to respective note MA info2. while drawing note draw MA-info|#;========================; score-search-engineII;========================(defclass analysis-search-engineII (analysis-search-engine) ()) (defmethod init-MA-string  ((self t)) nil)(defmethod apply-rules-loop ((self analysis-search-engineII) s-variable)  (let* ((prev-items-rev (read-key s-variable :prev-staff-items-rev))         (prev-items (read-key s-variable :svars-list))           (end-sitems-list (read-key s-variable :end-svars-list))         (candidates (domain s-variable))         (fns (rules self))         ;(no-attack-fns (no-attack-rules self))         (sindex (sindex s-variable))          (len sindex))    (if (read-key s-variable :no-attack-s-item)         t ; todo !!!      (progn (setf (nthcdr sindex prev-items) nil)             (dolist (fn fns)               (setf (value s-variable) (car candidates))               (multiple-value-bind  (info s-var y-row x-note)                                     (funcall fn prev-items prev-items-rev len) ;; 3 args len !!                  (when  (and info s-var)                   (pw::append-MA-string                      (read-key s-var :PW-note) (format () "~A" info) y-row                    (read-key x-note :PW-note)))))             (setf (nthcdr sindex prev-items) end-sitems-list)))    t))(defmethod apply-rules ((self analysis-search-engineII) s-variable)  (apply-rules-loop self s-variable)  t)(defmethod init-MA-info ((self analysis-search-engineII))  (mapc #'(lambda (sv) (pw::init-MA-string (read-key sv :PW-note)))        (search-variables-list self)));=========================================================================#|(defun extract-y-pos-from-rule (rule)  (fourth    (second     (find-if #'(lambda (l) (if (atom l) nil (eq (first l)'?if))) rule))));(extract-y-pos-from-rule '(* ?1 (?if (values (sindex ?1) ?1 1)) "sindex of ?1"))|#(defun find-special-symbols (l special-symbols)"find the expression whose car is a member of special-symbols"  (let (fl)    (labels ((special-symbols? (l pl)               ;(print l)                (cond (fl fl)                      ((null l) nil)                      ((atom l) (when (member l special-symbols) (setq fl pl)))                      (t  (special-symbols? (car l) l)                          (special-symbols? (cdr l) l)))))    (special-symbols? l l)    fl)))#|(find-special-symbols    '(* ?1 (?if (let ((midis (search-n-mel-moves 3 ?1)))       (if (= (length midis) 3)          (values            (print (SC-name midis))            ?1            1)         ()))))  '(values))(mapcar #'(lambda (l) (find-special-variables l '(values))) '((* ?1 (?if (values (sindex ?1) ?1 1)) "sindex of ?1") (* ?1 (?if (values (index ?1) ?1 2)) "sindex of ?1")))|#(defun extract-y-pos-from-rule (rule)  (fourth    (find-special-symbols rule '(values))));(extract-y-pos-from-rule '(* ?1 (?if (values (sindex ?1) ?1 1)) "sindex of ?1"))(defun extract-max-y-pos-from-rules (rules)  (let ((y-poses (mapcar #'extract-y-pos-from-rule rules)))    (when (remove nil y-poses)      (apply #'max (remove nil y-poses)))));(extract-max-y-pos-from-rules '((* ?1 (?if (values (sindex ?1) ?1 1)) "sindex of ?1") (* ?1 (?if (values (index ?1) ?1 2)) "sindex of ?1")))(defparameter *current-MA-y-pos-max* ());=========================================================================(defun score-MA-PMCII (m-lines rules                                     &key (prepare-fns+args nil)                                   (class 'analysis-search-engineII) )  (when (atom m-lines) (setq m-lines (list m-lines)))  (assert   (eq (type-of (first m-lines)) 'pw::c-measure-line) ()             "**** 1st input should be a list of pw::c-measure-lines !  ****" ())  (assert   (listp  rules) ()            "**** 2nd input should be a list of rules !! ****" ())  (setf *measure-lines* m-lines)  (setf *current-MA-y-pos-max* (extract-max-y-pos-from-rules rules))  (let* ((ranges (get-score-pitches m-lines))         (staff-coll (polif-score->search m-lines ranges () ()))         (engine (make-score-engine                   staff-coll (mk-PMC-fns rules)                       :prepare-fns+args prepare-fns+args                  :class class)))    (init-MA-info engine)    (start engine)    ()))#|(mapcar #'(lambda (sv)            (read-key (pw::extra (read-key sv :PW-note)) :ma-info))        (sixth (read-key *part-collection* :s-variables-ls-ls)))(mapcar #'(lambda (sv)            (read-key (pw::extra (read-key sv :PW-note)) :x))        (nth 4 (read-key *part-collection* :s-variables-ls-ls)))(mapcar #'(lambda (sv)            (read-key (pw::extra (read-key sv :PW-note)) :x))        (sixth (read-key *part-collection* :s-variables-ls-ls)))(mapcar #'(lambda (sv)            (write-key (pw::extra (read-key sv :PW-note)) :x ()))        (nth 4 (read-key *part-collection* :s-variables-ls-ls)))|#;====================================================================================