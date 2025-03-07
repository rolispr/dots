(define-module (home services mutable-files)
  #:use-module (ice-9 optargs)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (guix gexp)
  #:use-module (gnu home services dotfiles)
  #:use-module (home services home-impure-symlinks)

  #:export (home-mutable-files-service-type))


(define *home-path* "/home/bfh/dots/")

(define (home-utable-files-gexp-service config)
  `(;; the stump experience
    (".config/stumpwm/config"
     ,(string-append *home-path* "stumpwm/config"))
    ))

(define home-mutable-files-service-type
  (service-type (name 'home-mutable-files)
                (description "Service for mutable local file symlinking.")
                (extensions
                 (list (service-extension
                        home-impure-symlinks-service-type
                        home-mutable-files-gexp-service)))
                (default-value #f)))
