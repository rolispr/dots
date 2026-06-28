;;; The home-environment for the current host. Every field reads the
;;; settings layer via (home-setting 'key); host differences live in
;;; (dots hosts <host> home). Built by the top-level home.scm entry.

(define-module (dots home base)
  #:use-module (gnu home)
  #:use-module (dots settings)
  #:use-module (dots home defaults)
  #:export (home-for-host))

(define (home-for-host)
  (home-environment
   (packages (append (home-setting 'extra-packages)
                     (home-setting 'packages)))
   (services (home-setting 'services))))
