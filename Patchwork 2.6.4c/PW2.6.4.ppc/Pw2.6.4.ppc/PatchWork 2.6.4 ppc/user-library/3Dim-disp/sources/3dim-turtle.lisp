(defpackage "TURTLE"  (:use "COMMON-LISP" "CCL"))(in-package "TURTLE");==================================================(defvar *pi-over-180* (/ pi 180.0))(defun cosdt (theta) (cos (* theta *pi-over-180*)))(defun sindt (theta) (sin (* theta *pi-over-180*)))(defvar *sin-table* (apply #'vector (make-list 360)))(defvar *cos-table* (apply #'vector (make-list 360)))(defparameter *turtle-scaler* 1000)(defun make-sin-table ()   (let ((count 0))      (while (< count 360)       (setf (svref *sin-table* count)  (round (* *turtle-scaler* (sindt count))))      (incf count))))(defun make-cos-table ()   (let ((count 0))      (while (< count 360)       (setf (svref *cos-table* count) (round (* *turtle-scaler* (cosdt count))))      (incf count))))(make-sin-table)(make-cos-table);==================================================(defun group (lst gr-cnt-lst)  (let ((res)(temp-res)(gr-cnt))    (when (numberp gr-cnt-lst) (setq gr-cnt-lst (pw::cirlist  gr-cnt-lst)))    (while lst      (when gr-cnt-lst (setq gr-cnt (pop gr-cnt-lst)))      (repeat gr-cnt        (when (car lst)          (push (car lst) temp-res))        (pop lst))      (push (nreverse temp-res) res)      (setq temp-res ()))     (nreverse res)))#|(defun fill-vector (vect1 vect2)  (dotimes (i 3)(setf (svref vect1 i) (svref vect2 i)))  vect1)|#(defun fill-vector (vect1 vect2) (setf (svref vect1 0) (svref vect2 0)) (setf (svref vect1 1) (svref vect2 1)) (setf (svref vect1 2) (svref vect2 2)) vect1);(defvar vect1 (vector 90 80 70));(defvar vect2 (vector 9 8 7));(time (dotimes (i 100000)(fill-vector vect1 vect2)));(defun cosd (angle)(cos (* angle (/ 3.14159 180))));(defun sind (angle)(sin (* angle (/ 3.14159 180))))(defun cosd (angle) (svref *cos-table* (mod angle 360)))(defun sind (angle) (svref *sin-table* (mod angle 360)));(time (repeat 100000 (cosd 120)))(defvar *temp-turtle-vector* (vector 0 0 0))(defvar *temp-turtle-vector2* (vector 0 0 0))(defvar *temp-turtle-vector3* (vector 0 0 0))(defvar *temp-turtle-vector4* (vector 0 0 0))(defvar *temp-turtle-vector5* (vector 0 0 0))(defun -vect (vect)  (setf (svref *temp-turtle-vector4* 0)  (- (svref vect 0)))  (setf (svref *temp-turtle-vector4* 1)  (- (svref vect 1)))  (setf (svref *temp-turtle-vector4* 2)  (- (svref vect 2)))  *temp-turtle-vector4*)(defun vect+ (vect1 vect2)  (setf (svref *temp-turtle-vector* 0)(+ (svref vect1 0)(svref vect2 0)))  (setf (svref *temp-turtle-vector* 1)(+ (svref vect1 1)(svref vect2 1)))  (setf (svref *temp-turtle-vector* 2)(+ (svref vect1 2)(svref vect2 2)))  *temp-turtle-vector*)(defun vect2+ (vect1 vect2)  (setf (svref *temp-turtle-vector5* 0)(+ (svref vect1 0)(svref vect2 0)))  (setf (svref *temp-turtle-vector5* 1)(+ (svref vect1 1)(svref vect2 1)))  (setf (svref *temp-turtle-vector5* 2)(+ (svref vect1 2)(svref vect2 2)))  *temp-turtle-vector5*)(defun vect* (n vect)  (setf (svref *temp-turtle-vector2* 0) (round (* n (svref vect 0)) *turtle-scaler*))   (setf (svref *temp-turtle-vector2* 1) (round  (* n (svref vect 1)) *turtle-scaler*))   (setf (svref *temp-turtle-vector2* 2) (round  (* n (svref vect 2)) *turtle-scaler*))  *temp-turtle-vector2*)(defun vect2* (n vect)  (setf (svref *temp-turtle-vector3* 0) (round  (* n (svref vect 0)) *turtle-scaler*))   (setf (svref *temp-turtle-vector3* 1) (round  (* n (svref vect 1)) *turtle-scaler*))   (setf (svref *temp-turtle-vector3* 2) (round  (* n (svref vect 2)) *turtle-scaler*))  *temp-turtle-vector3*);(defparameter vv1 (vector 190 250 0));(defparameter vv2 (vector 190 250 0));(time (repeat 100000 (vect+ vv1 vv2)));(time (repeat 100000 (vect* 4 vv2)));(time (repeat 100000 (-vect  vv2)));= #(7 60 12);(vect* 4 (vector 3 55 8));#(12 220 32)(defun rotate (vect prepvect angle)  (vect+ (vect* (cosd angle) vect)  (vect2* (sind angle) prepvect)))(defun rotate2 (vect prepvect angle)  (vect2+ (vect* (cosd angle) vect)  (vect2* (sind angle) prepvect)));(time (repeat 10 (rotate2 vv1 vv2 67)));(defparameter turtle (make-instance 'c-turtle));    (init-turtle-2 turtle 120 120);(time (repeat 1000 (yaw turtle 90)));(time (repeat 1000 (pitch turtle 90)));_______________________________________________________________(defclass C-turtle (dialog-item)  ((turtle-pen-state :initform 'down)   (graphic-object-store :initform ())   (p-vect :initform (vector 0 0 0))   (h-vect :initform (vector 1 0 0))   (l-vect :initform (vector 0 1 0))   (u-vect :initform (vector 0 0 1))   (old-p-vect :initform (vector 0 0 0))   (old-h-vect :initform (vector 1 0 0))   (old-l-vect :initform (vector 0 1 0))   (old-u-vect :initform (vector 0 0 1))))(in-package "TURTLE")(defmethod forward ((self C-turtle) distance)  (let ((new-p (vect+ (slot-value self 'p-vect)                       (vect* distance (slot-value self 'h-vect))))        (old-v (slot-value self 'p-vect)))     (when (eq (slot-value self 'turtle-pen-state) 'down)      (if (slot-value self 'graphic-object-store)        (store-turtle-data (view-window self)                           (svref old-v 0)(svref old-v 1)                            (svref new-p 0)(svref new-p 1))           (progn           (#_MoveTo :long (make-point (svref old-v 0) (svref old-v 1)))          (#_LineTo :long (make-point (svref new-p 0) (svref new-p 1))))        ;(pw::draw-line (svref old-v 0) (svref old-v 1)         ;               (svref new-p 0) (svref new-p 1))        ))       (fill-vector (slot-value self 'p-vect) new-p)))(defmethod yaw ((self C-turtle) angle)  (let ((temp-vect (rotate (slot-value self 'h-vect) (slot-value self 'l-vect) angle)))      (fill-vector (slot-value self 'l-vect)        (rotate2 (slot-value self 'l-vect) (-vect (slot-value self 'h-vect)) angle))      (fill-vector (slot-value self 'h-vect) temp-vect)))(defmethod pitch ((self C-turtle) angle)  (let ((temp-vect (rotate (slot-value self 'h-vect) (slot-value self 'u-vect) angle)))      (fill-vector (slot-value self 'u-vect)        (rotate2 (slot-value self 'u-vect) (-vect (slot-value self 'h-vect)) angle))      (fill-vector (slot-value self 'h-vect) temp-vect)))(defmethod roll ((self C-turtle) angle)  (let ((temp-vect (rotate (slot-value self 'l-vect) (slot-value self 'u-vect) angle)))      (fill-vector (slot-value self 'u-vect)        (rotate2 (slot-value self 'u-vect) (-vect (slot-value self 'l-vect)) angle))      (fill-vector (slot-value self 'l-vect) temp-vect)))(defmethod turtle-pen-up ((self C-turtle))  (setf (slot-value self 'turtle-pen-state) 'up)) (defmethod turtle-pen-down ((self C-turtle))  (setf (slot-value self 'turtle-pen-state) 'down))(defmethod back ((self C-turtle) distance)  (forward self (- distance)));;;;;(defmethod view-draw-contents ((self C-turtle))  (with-focused-view self (draw-turtle self)))(defmethod draw-turtle ((self C-turtle)))(defmethod save-turtle-old-state ((self C-turtle))  (fill-vector (slot-value self 'old-p-vect) (slot-value self 'p-vect));  (print (list 'save 'p-vect(slot-value self 'p-vect) 'old-p-vect (slot-value self 'p-vect)))  (fill-vector (slot-value self 'old-h-vect) (slot-value self 'h-vect))     (fill-vector (slot-value self 'old-l-vect) (slot-value self 'l-vect))   (fill-vector (slot-value self 'old-u-vect) (slot-value self 'u-vect)))   (defmethod restore-turtle-old-state ((self C-turtle))   (fill-vector (slot-value self 'p-vect) (slot-value self 'old-p-vect)) ;  (print (list 'restore 'p-vect(slot-value self 'p-vect) 'old-p-vect (slot-value self 'p-vect)))   (fill-vector (slot-value self 'h-vect) (slot-value self 'old-h-vect))    (fill-vector (slot-value self 'l-vect) (slot-value self 'old-l-vect))    (fill-vector (slot-value self 'u-vect) (slot-value self 'old-u-vect))) (defmethod init-turtle ((self C-turtle))  (fill-vector (slot-value self 'p-vect) (vector 150 150 0));  (print (slot-value self 'p-vect))  (fill-vector (slot-value self 'h-vect) (vector *turtle-scaler* 0 0))  (fill-vector (slot-value self 'l-vect) (vector 0 *turtle-scaler* 0))  (fill-vector (slot-value self 'u-vect) (vector 0 0 *turtle-scaler*))  (setf (slot-value self 'turtle-pen-state) 'down))(defmethod init-turtle-2 ((self C-turtle) x y)  (fill-vector (slot-value self 'p-vect)     (vector  (+ x 150) (+ y 150) (svref (slot-value self 'p-vect) 2)))  (fill-vector (slot-value self 'h-vect) (vector *turtle-scaler* 0 0))  (fill-vector (slot-value self 'l-vect) (vector 0 *turtle-scaler* 0))  (fill-vector (slot-value self 'u-vect) (vector 0 0 *turtle-scaler*))  (setf (slot-value self 'turtle-pen-state) 'down));===========================