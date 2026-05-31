;;; THE home-environment form. Every field reads from the settings
;;; layer via (home-setting 'key). Per-host differences live in
;;; per-host/<host>/home.scm as (home-overrides).
;;;
;;; Reconfigure:
;;;   guix home -L ~/dots -L ~/dots/per-host/$(hostname) \
;;;        reconfigure ~/dots/home/config.scm

(define-module (home config)
  #:use-module (gnu home)
  #:use-module (etc prelude)
  #:use-module (home defaults))

(home-environment
 (packages (append (home-setting 'extra-packages)
                   (home-setting 'packages)))
 (services (home-setting 'services)))
