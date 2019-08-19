;============================; NEW FILE : TRANSFER STUFF              (HPST 8/2/95 IRCAM);============================#|    File that contains functions to operate on BPFs.    Note that the BPF class is redefined in BPF-tools,    it inherits from c-gen to take advantage of the generic methods.|#  ;=====================; DEFINE ENVIRONMENT;===================== (in-package :genutils);====================; SAMPLE BPF METHODS;====================(DEFMETHOD GIVE-X-POINTS ((self c-break-point-function)) (x-points self))(DEFMETHOD GIVE-Y-POINTS ((self c-break-point-function)) (y-points self))(DEFMETHOD SAMPLE-TIME ((self c-break-point-function) times)  "sample BPF at points specified by a list (any depth) of <times>"  (epw::deep-mapcar/1 #'(lambda(time) (bpf-out self time (x-points self) 1)) times))(DEFMETHOD SAMPLE-GRID ((self c-break-point-function) grids)  "sample whole BPF from x-min to x-max evenly by <grid>,   if grid is zero then sample at gcd-interval of x-points."  (sample-time self              (epw::deep-mapcar/1 #'(lambda(grid)                     (let* ( (xpts  (x-points self))                             (end   (apply 'max xpts))                             (start (apply 'min xpts))                             (begin (if (= start end) (- end 1.0E-4) start))                             (step  (if (= 0 grid)                                      (apply 'gcd (g-round xpts))                                      (/ (- end begin) (abs grid)))) )                       (arithm-ser begin step end))) grids)) );=====================; SOME BPF JOGGLINGS   only until it is checked, then leave out;=====================;INTERNAL ONLY? norm-bpf, read-bpf;RENAME?        read-bpf  = dur-bpf, ;RENAME?        scale-bpf = match-bpf, ;DO KEEP!       match-bpf, trans-bpf(DEFUN SCALE-BPF (bpf1 bpf2) (match-bpf bpf1 bpf2))(DEFUN READ-BPF (bpf dur) (dur-bpf bpf dur));==============; BPF MODULES;==============(DEFUNP NORM-BPF ((bpf   list (:value "()" :type-list (bpf list)))                  (times list)) all-types  "scale <times> to min/max of the x-range of <bpf>;   meant to 'normalise' <times>, so as to be able to    sample over the whole bpf using fx. trans-bpf.   Input anything to <bpf> and output a list." (epw::deep-mapcar/1 #'(lambda(bpf)       (let ((xpnts (give-x-points bpf)))            (g-scaling (give-y-points times)                       (g-fun #'g-min xpnts) (g-fun #'g-max xpnts)))) bpf));type example:;(bpf-ob list (:value "()" :type-list (bpf list))))(DEFUN SCALE-OBJ (flag source target)       (case  flag         (0  (list target target))         (1  (list target source))         (2  (list source target))         (3  (list source source))))(DEFUNP MATCH-BPF ( (source list (:value "()" :type-list (bpf list)))                    (target list (:value "()" :type-list (bpf list)))                    &optional                    (scale  menu (:menu-box-list ( ("both"  . 0)                                                   ("xlist" . 1)                                                   ("ylist" . 2)                                                   ("none"  . 3) )                                   :value 0)) ) all-types  "scale <source> to the xy-range of <target>;   useful when fx. <bpf-in> & <bpf-map> must match in trans-bpf.   Input anything to <source> & <target> and output a bpf.   An optional menu allows to choose type of scaling-target." (do-any (make-xbpf source) #'(lambda(source target)   (let* ( (objs   (scale-obj scale source target))          (xpnts  (give-x-points (first  objs)))            (ypnts  (give-y-points (second objs)))          (xmin   (g-fun #'g-min xpnts))          (xmax   (g-fun #'g-max xpnts))          (ymin   (g-fun #'g-min ypnts))          (ymax   (g-fun #'g-max ypnts)) )          (make-bpf              (g-scaling (give-x-points source) xmin xmax)               (g-scaling (give-y-points source) ymin ymax)))) (make-xbpf target)))(DEFUNP DUR-BPF ( (bpf  list      (:value "()" :type-list (bpf list)))                   (dur  fix/float (:value 1.0)) ) all-types       "scale x-range of <bpf> to be from 0 to <dur>;   Input anything to <bpf> and output a new bpf." (epw::deep-mapcar/1 #'(lambda(bpf)              (make-bpf (g-scaling (give-x-points bpf) 0 dur) (give-y-points bpf))) bpf))(DEFUNP TRANS-BPF ( (bpf-in  list   (:value "()"    :type-list (bpf list)))                     (bpf-map list   (:value "()"    :type-list (bpf list)))                     (times   list   (:value "(0 1)" :type-list (bpf list)))) list          "sample <bpf-in> by <times> as a input to be transfered by <bpf-map>;   a sampling-cascade takes place: first sample <bpf-map> by <times>,    use that output to sample <bpf-in>. The <bpf-map> correspond to the y-axis   with which <bpf-in> is going to sampled. Could be thougth of a xy-mirror.   Input anything to <bpf-in> & <bpf-map> & <times> and output a new bpf.   Too see effect of Waveshaping, just recover y-points only using get-slot."       (do-any bpf-in #'(lambda(in map time)            (make-bpf time                      (sample-time in (norm-bpf in                           (sample-time map (norm-bpf map time))) ))) bpf-map times));=============================; SOME BOOST/BIAS CONTROLS       ;=============================#| The LOOP construct of these function are all equal   OUTER LOOP : as many as bpf in <bpfs>              : initialise parameters pr bpf   INNER LOOP : as many as number in <bias>              : initialise parameters pr bias              : map bpf, bias and main function |#(DEFUNP BIAS-BPF ((bpfs  list        (:value "()" :type-list (bpf list)))                  (bias  fix/fl/list (:value 0.5))                  &optional                  (grid  fix>0       (:value 2))) all-types  "pull/push <bpf> according to position [0,1] of <bias>;   O means pulling <bpf> towards left, 1 pushing towards right.   if <bias> is 0.5 then <bpf> if left untouched. an optional <grid> tells    minimum points allowed when estimating the resampling resolution.   Input anything to <bpfs>, a num/list to <bias> and   outputs pr. bpf in <bpfs> as many bpfs as number of biases."  (epw::deep-mapcar/1 #'(lambda (bpf)                (let* ( (xpts (give-x-points bpf))                        (xmin (g-fun #'g-min xpts))                        (xmax (g-fun #'g-max xpts))                        (xpin (+ xmin (/ (- xmax xmin) 2)))                        (xbpf (if (listp bpf) (make-bpf xpts xpts 1) bpf))                        (grid (print (max grid (* (length xpts) (1+ (g-min (x->dx xpts))))))) )  ;often too high?                    (epw::deep-mapcar/1 #'(lambda(pin)                            (make-bpf (arithm-ser 1 1 grid)                                      (sample-time xbpf (sample-grid pin grid)) 1))                                      (epw::deep-mapcar/1 #'(lambda (pin)                                                                          (make-bpf (list 0 pin 1) (list xmin xpin xmax) 1)) bias)))) bpfs))     (DEFUN ELASTIC (y mean bias)  "self normalising exponential function"  (* (expt y (* mean bias))     (expt y (* mean (+ -1 bias))))) (DEFUNP BOOST-BPF ((bpfs  list        (:value "()" :type-list (bpf list)))                   (boost fix/fl/list (:value 1.0))) all-types  "boost/cut <bpf> according to position [-1,1] of <boost>;   -1 means reenforcing peaks, alias boost'em, 1 even-out    differences, alias cut'em; 0 forces <bpf> to an equilibre.   meant as a kind of self normalising exponential function.   Input anything to <bpfs>, a num/list to <boost> and   outputs pr. bpf in <bpfs> as many bpfs as number of boosts."  (epw::deep-mapcar/1 #'(lambda (bpf)                (let* ((xpts (give-x-points bpf))                       (ypts (give-y-points bpf))                       (mean (rms ypts))                      ;check for list and NILs as INPUT?                       (accl (rms (x->dx ypts)))              ;ditto?                       (1pts (g-scaling ypts 0.0001 1.0)) )   ;no zeros!                  (epw::deep-mapcar/1 #'(lambda(pin)                                           (make-bpf xpts                                 (mapcar #'(lambda (y) (* mean (elastic y accl pin))) 1pts) 1))                                                  (epw::deep-mapcar/1 #'(lambda (bias)                                            (if (> 0 bias)                             ;unelegant, but what else...?                                             (unit (rem bias 16.0) -1 0 0.499 0.5)    ;scales negative bias'                                             (unit (rem bias 16.0)  0 1 0.5 0.51)))   ;scales positive bias'                                       (g- 0 boost))) )) bpfs))                       ;inverse sign of bias;=============================; SOME INTERPOLATION CONTROLS;=============================     (DEFUNP EVEN-BPF ((bpfs    list        (:value "()" :type-list (bpf list)))                  (bias    fix/fl/list (:value 1.0))                  (measure menu (:menu-box-list (("rms"  . rms)                                                 ("mean" . mean)                                                 ("pow2" . pow2)                                                 ("sum"  . sum))                                                   :type-list (no-connection)))) all-types  "interpolate <bpf> towards axis as given by <measure> at position [-1,1] of <bias>;   the various interpolation reference values of menu <measure> are:   rms  : root mean square energy   mean : average energy   pow2 : product power2 energy   sum  : addup all energy    Input anything to <bpfs>, a num/list to <bias> and   outputs pr. bpf in <bpfs> as many bpfs as number of biases."  (epw::deep-mapcar/1 #'(lambda (bpf)                (let* ( (xpts (give-x-points bpf))                        (ypts (give-y-points bpf))                        (mean (funcall measure ypts)) ) ;should one resample to account for x's?                  (epw::deep-mapcar/1 #'(lambda(pin)                       (make-bpf xpts                            (mapcar #'(lambda(y) (unit pin 0 1 mean y)) ypts) 1)) bias))) bpfs));=========================; 2DIMENSIONAL DISTORTION;=========================(DEFUNP SLANT-BPF ((bpfs  list        (:value "()" :type-list (bpf list)))                   (xbias fix/fl/list (:value 1.0))                   (ybias fix/fl/list (:value 1.0)) ) all-types  "exponentially distort <bpfs> according to factors of <ybias> and <xbias>;   if factor(s) are larger than 1, then peaks are enhanced, if less,    then differences are compressed; 1 leaves <bpfs> untouched.   Note that it generally works best if y-points in <bpfs> goes from min to max.   Input anything to <bpfs>, a num/list to <xbias> & <ybias> and   outputs pr. bpf in <bpfs> as many bpfs as the longest bias."  (let* ((args  (epw::deep-mapcar/1 #'zero! (get-y-points (list xbias ybias)))))      (epw::deep-mapcar/1 #'(lambda (bpf)                  (let* ( (ypts (shift-list (give-y-points bpf)))                          (xpts (shift-list (give-x-points bpf)))                          (ymin (g-fun #'g-min ypts))                          (ymax (g-fun #'g-max ypts))                          (xmin (g-fun #'g-min xpts))                          (xmax (g-fun #'g-max xpts)) )               (epw::arith-tree-mapcar #'(lambda (xbis ybis)                          (make-bpf                             (g-scaling (mapcar 'expt xpts (cirlist xbis)) xmin xmax)                             (g-scaling (mapcar 'expt ypts (cirlist ybis)) ymin ymax)))                                                  (nth 0 args) (nth 1 args)))) bpfs)));===============; END FILE;===============