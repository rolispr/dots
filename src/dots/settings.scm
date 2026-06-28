;;; Settings layer: route per-host overrides over shared defaults.
;;;
;;; (system-setting 'key)  -- override-<key> from (dots hosts <host> system),
;;;                           else default-<key> from (dots system defaults).
;;; (home-setting   'key)  -- override-<key> from (dots hosts <host> home),
;;;                           else default-<key> from (dots home defaults).
;;;
;;; <host> is $DOTS_HOSTNAME or (gethostname); set DOTS_HOSTNAME to build
;;; another machine's config from this one. Host modules live at
;;; src/dots/hosts/<host>/{system,home}.scm and resolve over -L src.

(define-module (dots settings)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:export (system-setting
            home-setting
            with-nonguix-substitutes
            current-hostname))

(define (current-hostname)
  (or (getenv "DOTS_HOSTNAME") (gethostname)))

(define (overrides-module-name kind)
  `(dots hosts ,(string->symbol (current-hostname)) ,kind))

(define (defaults-module-name kind)
  (case kind
    ((system) '(dots system defaults))
    ((home)   '(dots home defaults))
    (else (error "unknown setting kind" kind))))

(define (lookup-setting kind key)
  (let* ((default-name  (string->symbol (format #f "default-~a"  key)))
         (override-name (string->symbol (format #f "override-~a" key)))
         (override-mod  (false-if-exception
                         (resolve-interface (overrides-module-name kind))))
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
        (cons (local-file "../../keys/nonguix.pub")
              %default-authorized-guix-keys))))))
