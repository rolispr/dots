;;; Cuirass jobset entry point. Returns one job per package surfaced
;;; by (dots packages all). Cuirass calls (cuirass-jobs store arguments)
;;; once per evaluation of the bfh jobset.

(define-module (dots ci cuirass-jobs)
  #:use-module (guix)
  #:use-module (guix packages)
  #:use-module (dots packages all)
  #:use-module (dots packages stumpwm)
  #:use-module (dots packages guile-hoot)
  #:use-module (dots packages guile-websocket)
  #:use-module (dots packages claude-code)
  #:use-module (dots packages claude-agent-acp)
  #:use-module (dots packages qwen-code)
  #:export (cuirass-jobs))

(define %bfh-package-list
  (list stumpwm-dev
        stumpwm-dev+servers
        guile-hoot-latest
        guile-websocket-fixed
        claude-code
        claude-agent-acp
        qwen-code))

(define (package->cuirass-job store pkg)
  `((#:job-name   . ,(string-append (package-name pkg)
                                    "-" (package-version pkg)))
    (#:derivation . ,(derivation-file-name
                      (package-derivation store pkg)))))

(define (cuirass-jobs store arguments)
  (map (lambda (pkg) (package->cuirass-job store pkg))
       %bfh-package-list))
