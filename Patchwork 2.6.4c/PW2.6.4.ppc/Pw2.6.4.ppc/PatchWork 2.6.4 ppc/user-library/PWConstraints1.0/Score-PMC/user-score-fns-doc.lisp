;===============================================;===============================================;;; PWConstraints by Mikael Laurson (c), 1995;===============================================;===============================================(in-package "PWCS");===============================================(defparameter *PWCs-user-score-functions* '(; basic score-PMC beat measure hc hslice  beatnum measurenum partnum staffnum  mindex ;sindex  all-vect-prev-s-vars all-vect-prev-sols rtm-pattern match-rtm? match-rtm3? mk-imitation-graph hc-midis l->ms startt endt durt  attack-item? collect-only-attacks; groupsnote-in-group-at-pos? note-found-in-nth-group?prev-group-svars prev-group-midisgroup-at-pos-svars group-at-pos-midis; general voice-count constraint?  constraints? one-constraint? attack-items? complete-chord? downbeat? on-main-beat? prev-item-on-downbeat prev-item-on-downbeat-2 bass-num bass-item? sop-item? rest-item? prev-rest? one-prev-rests? last-measure?  nextto-last-measure? last-item? no-pc-duplic-in-prev-slices; voice-crossings etc. no-voice-crossings? no-bass-crossings? no-sop-crossings? no-unisons? inside-voice-distance?; imitation imitation?;  long notes prev-long-note-midis; scale, up-down, parallel etc. movements up-down-movem? scale-movem? stepwise? side-movem? parallel-movements? no-chord-duplicates vertical-interval-range vertical-intervals map-rtm-change search-n-mel-moves harm-slice-scs harm-slice-durs staff-durs))#|(mapc #'show-documentation *PWCs-user-score-functions*)|#