;;; Shared settings-layer and helpers
;;;
;;; (system-setting 'key)  — resolves override-<key> in (system-overrides)
;;;                          if present, falls back to default-<key> in
;;;                          (etc systems defaults).
;;; (home-setting   'key)  — same shape against (home-overrides) and
;;;                          (home defaults).
;;;
;;; Override modules live under per-host/<host>/ and are picked up at
;;; reconfigure time via `-L ~/dots/per-host/<host>`.

(define-module (etc prelude)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:export (system-setting home-setting with-nonguix-substitutes))

(define-syntax-rule (%setting overrides-mod defaults-mod key)
  (let* ((default-name (format #f "default-~a" key))
         (default-var  (module-variable (resolve-module 'defaults-mod)
                                        (string->symbol default-name)))
         (override-mod (false-if-exception
                        (resolve-module 'overrides-mod #:ensure #f)))
         (override-var (and override-mod
                            (module-variable
                             override-mod
                             (string->symbol
                              (format #f "override-~a" key))))))
    (if (and override-var (variable-ref override-var))
        (variable-ref override-var)
        (variable-ref default-var))))

(define-syntax-rule (system-setting key)
  (%setting (system-overrides) (etc systems defaults) key))

(define-syntax-rule (home-setting key)
  (%setting (home-overrides) (home defaults) key))

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
