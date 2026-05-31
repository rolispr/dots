;;; Shared base for every lab VM. Each VM file under lab/machines/ is
;;; just (define-module (lab machines NAME)) returning (lab-base ...).
;;;
;;; The substitute config is bootstrap-aware:
;;;
;;;   bootstrap? = #t  → only nonguix + default substitutes (used by the
;;;                      builder VM itself, which can't pull from itself).
;;;   bootstrap? = #f  → also pull from http://10.20.0.10:8080 (the
;;;                      builder VM's guix-publish endpoint).
;;;
;;; The builder's signing key is added only after channel/builder-signing-key.pub
;;; exists (post first boot of the builder VM). Until then, substitutes from
;;; 10.20.0.10 are simply ignored — guix falls back to nonguix / source build.

(define-module (lab prelude)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu services networking)
  #:use-module (gnu services ssh)
  #:use-module (gnu system nss)
  #:use-module (guix gexp)
  #:export (lab-base
            %lab-substitute-config))

(define %dots-root
  ;; Anchor file-system lookups to ~/dots regardless of current working dir.
  (or (getenv "DOTS_DIR")
      (string-append (or (getenv "HOME") "/home/bfh") "/dots")))

(define %builder-key-path
  (string-append %dots-root "/channel/builder-signing-key.pub"))

(define %nonguix-key-path
  (string-append %dots-root "/etc/systems/nonguix-signing-key.pub"))

(define %builder-key-files
  ;; Empty until the builder VM is up and we've copied its public key in.
  (if (and (file-exists? %builder-key-path)
           (> (stat:size (stat %builder-key-path)) 0))
      (list (local-file %builder-key-path))
      '()))

(define (%lab-substitute-config bootstrap?)
  (lambda (config)
    (guix-configuration
     (inherit config)
     (substitute-urls
      (if bootstrap?
          (cons "https://substitutes.nonguix.org" %default-substitute-urls)
          (cons* "http://10.20.0.10:8080"
                 "https://substitutes.nonguix.org"
                 %default-substitute-urls)))
     (authorized-keys
      (append %builder-key-files
              (cons (local-file %nonguix-key-path)
                    %default-authorized-guix-keys))))))

(define* (lab-base #:key
                   host-name
                   (bootstrap? #f)
                   (extra-services '())
                   (extra-packages '())
                   (extra-file-systems '()))
  (operating-system
    (host-name host-name)
    (timezone "America/New_York")
    (locale "en_US.utf8")
    (keyboard-layout (keyboard-layout "us"))
    (bootloader (bootloader-configuration
                 (bootloader grub-bootloader)
                 (targets '("/dev/vda"))
                 (terminal-outputs '(console serial_0))))
    (kernel-arguments '("console=ttyS0,115200"))
    (file-systems (append
                   extra-file-systems
                   (cons (file-system
                           (mount-point "/")
                           ;; `guix system image -t qcow2` labels the
                           ;; root partition "Guix_image" regardless of
                           ;; what we declare here; match that so
                           ;; `guix deploy` can verify the file-system.
                           (device (file-system-label "Guix_image"))
                           (type "ext4"))
                         %base-file-systems)))
    (users (cons (user-account
                  (name "bfh")
                  (group "users")
                  (supplementary-groups '("wheel"))
                  (home-directory "/home/bfh"))
                 %base-user-accounts))
    (packages (append extra-packages %base-packages))
    (services
     (append
      extra-services
      (list (service dhcpcd-service-type)
            (service openssh-service-type
                     (openssh-configuration
                      (port-number 2226)
                      (password-authentication? #f)
                      (permit-root-login 'prohibit-password)
                      (authorized-keys
                       `(("bfh"  ,(local-file
                                   (string-append %dots-root
                                                  "/authorized-keys/bfh.pub")))
                         ("root" ,(local-file
                                   (string-append %dots-root
                                                  "/authorized-keys/bfh.pub"))))))))
      (modify-services %base-services
        (guix-service-type config => ((%lab-substitute-config bootstrap?) config)))))
    (name-service-switch %mdns-host-lookup-nss)))
