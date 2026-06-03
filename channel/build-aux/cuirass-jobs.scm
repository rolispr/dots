;;; Cuirass jobset entry point. Returns one job per package surfaced
;;; by (bfh packages). Cuirass calls (cuirass-jobs store arguments)
;;; once per evaluation of the bfh jobset.

(define-module (build-aux cuirass-jobs)
  #:use-module (guix)
  #:use-module (guix packages)
  #:use-module (bfh packages)
  #:use-module (etc packages stumpwm)
  #:use-module (etc packages guile-hoot)
  #:use-module (etc packages guile-websocket)
  #:use-module (etc packages claude-code)
  #:use-module (etc packages qwen-code)
  #:use-module (etc packages llama-cpp)
  #:export (cuirass-jobs))

(define %bfh-package-list
  (list stumpwm-dev
        stumpwm-dev+servers
        guile-hoot-latest
        guile-websocket-fixed
        claude-code
        qwen-code
        llama-cpp-latest))

(define (package->cuirass-job store pkg)
  `((#:job-name   . ,(string-append (package-name pkg)
                                    "-" (package-version pkg)))
    (#:derivation . ,(derivation-file-name
                      (package-derivation store pkg)))))

(define (cuirass-jobs store arguments)
  (map (lambda (pkg) (package->cuirass-job store pkg))
       %bfh-package-list))
