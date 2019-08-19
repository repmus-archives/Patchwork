#|(defun mk-1-card-subs (SC)  (remove-duplicates    (mapcar #'sc-name (pcs::make-sub-lsts (prime SC) (1- (card SC))))));(time (mk-1-card-subs '6-1))(defun store-SC-1-subs ()  (dolist (SCs *all-SC-names*)    (dolist (SC SCs)      (setf (get SC :card-1-subs) (mk-1-card-subs SC)))));(6.009 seconds);(time (store-SC-1-subs))(defun 1-subs (SC)  (get SC :card-1-subs));(time (repeat 1000 (1-subs '8-2a)));(1-subs '1-1);(1-subs '2-1);(1-subs '4-1)(defun all-subs1 (SC)  (let* ((SCs (append (1-subs SC) (list SC)))         (res (list SCs)) temp)    (while (not (eq (first SCs) '1-1))       (setq temp ())      (dolist (sub SCs)        (let ((1-subs (1-subs sub)))          (dolist (sub1 1-subs)            (push (1-subs sub1) temp))))      (setq temp (delete-duplicates (apply #'append temp)))      (push temp res)      (setq SCs temp))    (cons '0-1 (apply #'append res)))) ;(time (all-subs1 '5-1));(time (all-subs1 '10-1)) ;(time (all-subs1 '6-z6)) ;(time (all-subs '6-z6)) |#(in-package "PWCS");=======================================================; make instances of s-engines only once(defparameter *sub-engines*  (let (ss)     (for (i 1 1 11)      (PMC-subsets '1-12 i)      (push (engine) ss))    (nreverse ss)))  ;=======================================================(defun PMC-subsets* (SC card)  (let ((s-space (make-list card :initial-element (prime SC)))        (engine (nth (1- card) *sub-engines*))        all-sols sc res)      (setf *current-SE* engine)    (dolist (sv (search-variables-list engine))              (setf (domain sv) (car s-space))               (setf (domain-copy sv) (pop s-space)))    (start engine)    (setq all-sols (all-sols engine))    (while all-sols      (unless (member (setq sc (SC-name-from-pcs (car all-sols))) res)        (push  sc res))      (pop all-sols))    res));(time (PMC-subsets '6-18a 4)) ;(time (PMC-subsets* '6-18a 4));(time (mapcar #'first (pcs::subsets-supersets  '6-18a 4))) ;(time (PMC-subsets '8-6 4)) ;(time (PMC-subsets* '8-6 4));(time (mapcar #'first (pcs::subsets-supersets  '8-6 4))) ;(time (PMC-subsets '12-1 4)) ;(time (PMC-subsets* '12-1 4));(time (mapcar #'first (pcs::subsets-supersets  '12-1 4)))  