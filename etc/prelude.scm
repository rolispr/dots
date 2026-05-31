;;; Shared settings-layer and helpers for the dots refactor.
;;;
;;; (system-setting 'key)  — looks up override-<key> in the current host's
;;;                          (per-host <hostname> system) module if present;
;;;                          falls back to default-<key> in (etc systems defaults).
;;; (home-setting   'key)  — same, against (per-host <hostname> home) and
;;;                          (home defaults).
;;;
;;; The current hostname comes from $DOTS_HOSTNAME if set, otherwise
;;; (gethostname). Set DOTS_HOSTNAME=other-host to build another machine's
;;; system from this one (e.g., make a USB installer for arraniz from framework).
;;;
;;; Per-host override modules live at:
;;;     ~/dots/per-host/<hostname>/system.scm  →  (per-host <hostname> system)
;;;     ~/dots/per-host/<hostname>/home.scm    →  (per-host <hostname> home)
;;;
;;; Loaded from -L ~/dots alone; no per-host -L needed because the module
;;; name now includes the per-host segment.

(define-module (etc prelude)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:export (system-setting
            home-setting
            with-nonguix-substitutes
            current-hostname))

(define (current-hostname)
  (or (getenv "DOTS_HOSTNAME") (gethostname)))

(define (overrides-module-name kind)
  ;; kind is 'system or 'home
  `(per-host ,(string->symbol (current-hostname)) ,kind))

(define (defaults-module-name kind)
  (case kind
    ((system) '(etc systems defaults))
    ((home)   '(home defaults))
    (else (error "unknown setting kind" kind))))

(define %dots-root
  (or (getenv "DOTS_DIR")
      (string-append (or (getenv "HOME") "/home/bfh") "/dots")))

(define (overrides-file kind)
  ;; Direct path to the per-host file. We keep these without a .scm
  ;; extension so Guile's auto-discovery walk over -L ~/dots doesn't try
  ;; to compile them standalone (which fails because their #:use-module
  ;; imports aren't resolvable in that context, producing noisy "lgeh-
  ;; services: unbound variable" errors). The file still has a
  ;; (define-module …) form so primitive-load registers the module.
  (string-append %dots-root "/per-host/"
                 (current-hostname) "/"
                 (case kind ((system) "system") ((home) "home"))))

(define %loaded-overrides (make-hash-table))

(define (load-overrides! kind)
  "Force the per-host overrides file to load via primitive-load wrapped
in save-module-excursion (so current-module isn't left dangling at the
per-host module). primitive-load is needed because Guile's auto-discovery
walk over -L paths during `guix system` half-loads the file in a context
where its #:use-module imports aren't yet resolvable, then caches that
broken state — re-executing the body in current-module via primitive-load
lets define-module re-create the module and the bindings get resolved."
  (unless (hash-ref %loaded-overrides kind)
    (let ((file (overrides-file kind)))
      (when (file-exists? file)
        (false-if-exception
         (save-module-excursion
          (lambda () (primitive-load file))))))
    (hash-set! %loaded-overrides kind #t)))

(define (lookup-setting kind key)
  (load-overrides! kind)
  (let* ((default-name  (string->symbol (format #f "default-~a"  key)))
         (override-name (string->symbol (format #f "override-~a" key)))
         (override-mod  (false-if-exception
                         (resolve-module (overrides-module-name kind)
                                         #:ensure #f)))
         (override-var  (and override-mod
                             (module-variable override-mod override-name)))
         (default-var   (module-variable
                         (resolve-interface (defaults-module-name kind))
                         default-name)))
    (if (and override-var (variable-bound? override-var)
             (variable-ref override-var))
        (variable-ref override-var)
        (variable-ref default-var))))

(define (system-setting key) (lookup-setting 'system key))
(define (home-setting   key) (lookup-setting 'home   key))

(define (with-nonguix-substitutes services)
  "Inject nonguix substitute-urls and signing key into SERVICES."
  (modify-services services
    (guix-service-type config =>
      (guix-configuration
       (inherit config)
       (substitute-urls
        (cons "https://substitutes.nonguix.org" %default-substitute-urls))
       (authorized-keys
        (cons (local-file "systems/nonguix-signing-key.pub")
              %default-authorized-guix-keys))))))
