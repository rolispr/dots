;;; Cuirass jobset spec for the private 'bfh' channel.
;;;
;;; The 'bfh' channel re-exports custom packages from etc/packages/ and is
;;; published from the forge VM at https://git.lab.local/bfh/dots.git
;;; (path 'channel/' inside the repo). Until forge is up in Phase 2, you
;;; can flip the URL below to a file:// or local-https URL the builder VM
;;; can reach.
;;;
;;; The jobs are emitted by channel/build-aux/cuirass-jobs.scm — one
;;; job per re-exported package.

(define-module (lab services cuirass-spec)
  #:use-module (guix gexp)
  #:export (%bfh-cuirass-specs))

;; load-path "." for the bfh input puts the entire dots checkout on the
;; load path so channel/bfh/packages.scm can `use-module (etc packages …)`
;; without duplicating package definitions into the channel directory.
(define %bfh-cuirass-specs
  #~(list
     '((#:name . "bfh")
       (#:load-path-inputs    . ("guix" "bfh"))
       (#:package-path-inputs . ("bfh"))
       (#:proc-input          . "bfh")
       (#:proc-file           . "channel/build-aux/cuirass-jobs.scm")
       (#:proc                . cuirass-jobs)
       (#:inputs
        . (((#:name      . "guix")
            (#:url       . "https://git.savannah.gnu.org/git/guix.git")
            (#:load-path . ".")
            (#:branch    . "master"))
           ((#:name      . "bfh")
            (#:url       . "https://git.lab.local/bfh/dots.git")
            (#:load-path . ".")
            (#:branch    . "main"))))
       (#:build-outputs . ()))))
