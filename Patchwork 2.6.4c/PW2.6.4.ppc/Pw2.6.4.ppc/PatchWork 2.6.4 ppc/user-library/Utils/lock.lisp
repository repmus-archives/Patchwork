(in-package "PW");; prints all files in all  subdirectories or only files with given extension(defun list-files (dir &optional ext)"returns list of all file names in all subdirectories"(mapcar #'ccl::mac-namestring (directory (concatenate 'string dir                        (if ext (format () "**;*.~A" ext) "**:*")))))(defun list-locked-files (dir)"locks all files in all subdirectories of dir"(when dir (format t "scanning ~S ...." (ccl::mac-namestring dir))(let* ((files (list-files dir))        (locked-fl (mapcar #'ccl::file-locked-p files)))(format t "done~%")  (dotimes (i (length files))    (when (nth i locked-fl) (format t "~S is locked~%" (nth i files)))))))(defun lock-all-files (dir)"locks all files in all subdirectories of dir" (when dir (format t "locking all files in ~S :~% ~S~%" (ccl::mac-namestring dir)        (mapcar #'ccl::lock-file (list-files dir)))))(defun unlock-all-files (dir)"unlocks all files in all subdirectories of dir" (when dir (format t "unlocking all files in ~S :~% ~S~%" (ccl::mac-namestring dir)        (mapcar #'ccl::unlock-file (list-files dir)))));;---------------------#|;(ccl::def-logical-directory "xc" "root;Users:xc");(ccl::full-pathname "xc;");(ccl::mac-namestring "xc;");(list-files "xc;");(list-locked-files "xc;");(lock-all-files "xc;");(unlock-all-files "xc;")(mapcar #'(lambda (x) (progn                       (ccl:set-mac-file-type x "LIB ")                      (format t "set ~S to type lib~%" x)))      (list-files-ext "PW-LIB:" "lib" ))|#