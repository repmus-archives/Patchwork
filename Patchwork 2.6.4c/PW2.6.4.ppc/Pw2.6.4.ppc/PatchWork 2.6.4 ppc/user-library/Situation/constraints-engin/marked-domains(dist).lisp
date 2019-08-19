;;;;;;Hierarchical domains;;;;;; By C. Rueda (c) IRCAM 921203;;;(in-package "MARKED-DOMAINS")(defun always-true (&rest args) (declare (ignore args)) t)(defclass  C-tree ()  ((subtrees :initform nil :initarg :subtrees :accessor subtrees)   (father :initform nil :initarg :father :accessor father)   (tree-data :initform nil :initarg :tree-data :accessor tree-data)))(defun make-tree (&rest keys &key (class 'C-tree) subtrees father tree-data                       &allow-other-keys)  (let ((tree (apply #'make-instance class :subtrees subtrees :father father                     :tree-data tree-data :allow-other-keys t keys)))    (mapc #'(lambda (node) (setf (father node) tree)) (subtrees tree))    tree))(defmethod leaf? ((self C-tree)) (not (subtrees self)))(defmethod root? ((self C-tree)) (not (father self)))(defmethod add-subtree ((self C-tree) (subtree C-tree))  (setf (subtrees self) (nconc (subtrees self) (list subtree)))  (setf (father subtree) self))(defmethod leftmost-tree ((self C-tree)                           &optional (ok-if #'leaf?) (down-if #'subtrees))  (if (funcall ok-if self)    self    (if (funcall down-if self)      (let (leftmost)        (dolist (tree (subtrees self))          (setq leftmost (leftmost-tree tree ok-if down-if))          (if leftmost (return leftmost)))))))(defmethod get-nodes-at-depth ((self C-tree) depth &optional (test #'always-true))  (and (funcall test self)       (cond          ((or (zerop depth) (leaf? self)) (list self))        (t (let ((dp-1 (subtrees self)))             (apply #'nconc                     (mapcar #'(lambda (node) (get-nodes-at-depth node (1- depth) test))                            dp-1)))))))(defmethod get-root ((self C-tree))  (if (root? self) self (get-root (father self))))(defmethod copy-all-tree ((self C-tree) &optional (test #'always-true))  (when (funcall test self)    (if (leaf? self) (copy-leaf self)        (let ((root (copy-node self))              (subts                (do ((branches (subtrees self) (rest branches)) (res))                   ((null branches) (nreverse res))                 (when (funcall test (first branches))                   (push (copy-all-tree (first branches) test) res)))))          (setf (subtrees root) subts)          (dolist (tree subts) (setf (father tree) root))          root))))(defmethod copy-node ((self C-tree))  (let ((copy (make-tree :class (class-name (class-of self))                         :tree-data (tree-data self))))    (copy-extra self copy)    copy))(defmethod copy-leaf ((self C-tree)) (copy-node self))(defmethod copy-extra ((self C-tree) new) new);;================================;;Domains;; mark is: -1= not in domain;;           0= may be;;           1= in domain(defclass  C-tree-domain (C-tree)  ((mark :initform 1 :initarg :mark :accessor mark)   (beta-value :initform 1 :accessor beta-value)))(defun make-tree-domain (&rest keys &key (mark 1) (class 'C-tree-domain)                               &allow-other-keys)  (apply #'make-tree :class class :mark mark :allow-other-keys t keys))    (defmethod get-mark ((self C-tree-domain))  (mark self))(defmethod set-node-mark ((self C-tree-domain) mark)  (setf (mark self) mark))(defmethod in-domain? ((self C-tree-domain))  (and (plusp (get-mark self))       (or (> (beta-value self) soft-constr::*beta*)           (= (beta-value self) soft-constr::*beta* 1))))(defmethod not-in-domain? ((self C-tree-domain))  (or (minusp (get-mark self)) (< (beta-value self) soft-constr::*beta*)      (and (= (beta-value self) soft-constr::*beta*) (/= soft-constr::*beta* 1))))(defmethod may-be-in-domain? ((self C-tree-domain)) (zerop (get-mark self)))(defmethod assert-in-domain ((self C-tree-domain))  (set-node-mark self 1)  (up-propagate-marks self 1))(defmethod assert-not-in-domain ((self C-tree-domain))   (set-node-mark self -1)  (up-propagate-marks self -1))(defmethod assert-may-be ((self C-tree-domain))  (set-node-mark self 0)  (up-propagate-marks self 0))(defun all-same-marks (subtrees mark)  (dolist (node subtrees t) (unless (= mark (get-mark node)) (return nil))))(defmethod up-propagate-marks ((self C-tree-domain) mark)  (let ((father (father self)))    (or (not father) (= mark (get-mark father)) (set-new-mark father mark))))(defmethod set-new-mark ((self C-tree-domain) new-mark)  "PRECONDITION: new-mark /= (get-mark self)"    (if (not-in-domain? self)       (assert-may-be self)      (if (all-same-marks (subtrees self) new-mark)        (progn (setf (mark self) new-mark) (up-propagate-marks self new-mark))        (assert-may-be self))))(defmethod get-leftmost-in-domain ((self C-tree-domain)                                    &optional                                    (OK-if #'in-domain?)                                   (down-if #'may-be-in-domain?))  (leftmost-tree self OK-if down-if))(defmethod get-next-right-in ((self C-tree-domain) subtree                              &optional (OK-if #'in-domain?)                              (down-if #'may-be-in-domain?))  (if (leaf? subtree)    (invalidate-leaf subtree)    (assert-not-in-domain subtree))  (get-leftmost-in-domain self OK-if down-if))(defmethod invalidate-leaf ((self C-tree-domain)) (assert-not-in-domain self))(defmethod copy-extra ((self C-tree-domain) new)  (setf (mark new) (mark self)) new)(defmethod get-value ((self C-tree-domain)) (tree-data self))(defmethod get-all-domain ((self C-tree-domain)) (list (tree-data self)))(defmethod remove-from-domain ((self C-tree-domain) value)  (if (eq value (get-value self)) (assert-not-in-domain self)))(defmethod set-value ((self C-tree-domain) value)  (setf (tree-data self) value))(defmethod not-null-domain ((domain C-tree-domain)) (get-leftmost-in-domain domain))(defmethod get-all-marks ((domain C-tree-domain))  (if (leaf? domain) (get-mark domain))      (cons        (get-mark domain)        (mapcar #'get-all-marks (subtrees domain))))(defmacro do-tree-domain (var-exp &body body)  (let ((var (first var-exp))         (tree (second var-exp))        (result-exp (third var-exp)))    `(do*  ((,var (leftmost-tree ,tree                                  ,#'(lambda (node) (and (leaf? node) (in-domain? node)))                                 ,#'(lambda (node) (not (not-in-domain? node))))                  (get-next-right-in ,tree ,var                                  ,#'(lambda (node) (and (leaf? node) (in-domain? node)))                                 ,#'(lambda (node) (not (not-in-domain? node))))))           ((not ,var) ,result-exp) ,@ body)))(defmethod domain-first ((domain C-tree-domain))  (leftmost-tree domain #'(lambda (node) (and (leaf? node) (in-domain? node)))                 #'(lambda (node) (not (not-in-domain? node)))))(defmethod domain-rest ((domain C-tree-domain) &optional current)  (if (leaf? current)    (invalidate-leaf current)    (assert-not-in-domain current)))(defmethod get-one-value ((domain C-tree-domain)) domain)(defmethod not-null-domain? ((domain C-tree-domain))  (get-leftmost-in-domain domain))(defmethod copy-domain ((domain C-tree-domain))  (copy-all-tree domain #'(lambda (node) (or (root? node) (not (not-in-domain? node))))))(defmethod form-tree-values ((domain C-tree-domain))  (cond ((leaf? domain) (get-value domain))        ((root? domain) nil)        (t (cons (get-value domain) (form-tree-values (father domain))))))(defmethod filter-domain ((domain C-tree-domain) (pred function) &optional constraint)  (or (not-in-domain? domain)      (funcall pred (nreverse (form-tree-values domain)))      (let ((degree  (if constraint                        (hd-constraints::necessity-degree constraint)                       1)))        (if  (or (< (- 1 degree) soft-constr::*beta*) (= degree 1))          (assert-not-in-domain domain)          (setf (beta-value domain) (min (beta-value domain) (- 1 degree) )))))  domain)(defmethod filter-deep ((domain C-tree-domain) (pred function) &optional constraint)  (filter-domain domain pred constraint))(defmethod first-in-domain ((domain C-tree-domain))  (let ((node (get-leftmost-in-domain domain)))    (and node (get-value node))))(defmethod nicely-put ((domain C-tree-domain) &optional num-items)  (declare (ignore num-items))   (get-value domain))(defmethod filter-leaves-domain ((domain C-tree-domain) (pred function))  (do ((trees (get-nodes-at-depth domain most-positive-fixnum ;;real deep                                 hd-constraints::*filter-node-pred*)              (rest trees))) ((null trees))    (unless (not-in-domain? (filter-deep (first trees) pred))        (return (tell (rest trees) #'filter-domain pred))))  domain);;;=========================================;;;some specific domain data representations;; domain collections;;lists(defmethod singleton-instance? ((domain-collection cons) var)  (singleton-domain? (nth var domain-collection)))(defmethod get-current-instance ((domain-collection cons) var)  (first-in-domain (nth var domain-collection)))(defmethod set-domain-item ((domain-collection cons) var value)  (setf (nth var domain-collection) value))(defmethod all-domain-of ((domain-collection cons) var)  (nth var domain-collection))(defmethod subcollection ((domain cons) &optional (from 0) upto)  (subseq domain from upto))(defmethod copy-domain-collection ((domain-collection cons)                                &optional (from 0) (upto most-positive-fixnum))  (let* ((length (length domain-collection))         (a (copy-list domain-collection))         (limit (1- (first length)))         (i 0))    (pw::while (< i from) (setf (nth i a) (nth i domain-collection)) (incf i))    ;aaa (dotimes (i 0 from) (setf (nth i a) (nth i domain-collection)))    (do ((i (1+ from) (1+ i))) ((> i (min limit (+ from upto))))      (setf (nth i a) (copy-domain (nth i domain-collection))))    a))(defmethod nicely-put ((domain-collection cons) &optional (num-items 1))  (if (numberp (first domain-collection)) (first domain-collection)  (let (res)    (do ((i 1 (1+ i))) ((> i num-items))      (push (nicely-put (nth i domain-collection)) res))    (nreverse res)))   )(defmethod get-domain-item ((domain-collection cons) var)  (nth var domain-collection))(defmethod get-nodes-at-depth ((self cons) depth &optional (test #'always-true))  (declare (ignore depth test)) (list self));;;vectors(defmethod all-domain-of ((domain-collection vector) var)  (aref domain-collection var))(defmethod get-current-instance ((domain-collection vector) var)  (first-in-domain (aref domain-collection var)))(defmethod get-domain-item ((domain-collection vector) var)  (aref domain-collection var))(defmethod set-domain-item ((domain-collection vector) var value)  (setf (aref domain-collection var) value))(defmethod subcollection ((domain vector) &optional (from 0) upto)  (subcollection (coerce domain 'list) from upto))(defmethod nicely-put ((domain-collection vector) &optional (num-items 1))  (let (res)    (do ((i 1 (1+ i))) ((> i num-items))      (push (nicely-put (aref domain-collection i)) res))    (nreverse res)));;; Items in domain collections(defmethod not-null-domain? ((domain cons)) domain)(defmethod not-null-domain? ((domain null)) nil)(defmethod singleton-domain? ((domain cons)) (not (second domain)))(defmethod not-in-domain? ((domain cons)) nil)(defmethod not-in-domain? ((domain null)) t)(defmethod first-in-domain ((domain cons)) (first domain))(defmethod copy-domain ((domain cons)) (copy-tree domain))(defmethod get-one-value ((domain cons)) (list (first domain)))(defmethod filter-deep ((domain cons) (pred function) &optional constraint)  (filter-domain domain pred constraint))(defmethod filter-domain ((domain cons) (pred function) &optional constraint)  (declare (ignore constraint))  (let ((new-list (remove-if-not pred domain)))    (setf (first domain) (first new-list))    (setf (rest domain) (rest new-list))))  ;;(filter-series pred domain))(defmethod filter-leaves-domain ((domain cons) (pred function))  (filter-domain domain pred))(defmethod get-root ((domain cons)) domain)(defmethod get-root ((domain null)) domain)(defmethod domain-first ((domain cons))  (first domain))(defmethod domain-rest ((domain cons) &optional current)  (declare (ignore current))  (rest domain))(defmethod nicely-put ((domain number) &optional num-items)  (declare (ignore num-items))  domain)(defmethod leftmost-tree ((self cons) &optional ok-if  down-if)  (declare (ignore ok-if down-if)) self)(defmethod get-next-right-in ((tree cons) subtree &optional ok-if down-if)  (declare (ignore ok-if down-if)) (cdr subtree))(defmethod get-next-right-in ((tree null) subtree &optional ok-if down-if)  (declare (ignore ok-if down-if subtree)) tree)  