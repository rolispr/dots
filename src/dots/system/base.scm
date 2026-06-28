;;; The operating-system for the current host. Every field reads the
;;; settings layer via (system-setting 'key); host differences live in
;;; (dots hosts <host> system). Built by the top-level system.scm entry.

(define-module (dots system base)
  #:use-module (gnu)
  #:use-module (gnu system nss)
  #:use-module (gnu services desktop)
  #:use-module (gnu services networking)
  #:use-module (srfi srfi-1)
  #:use-module (dots settings)
  #:use-module (dots system defaults)
  #:export (operating-system-for-host))

(define (operating-system-for-host)
  (operating-system
   (host-name       (system-setting 'hostname))
   (timezone        (system-setting 'timezone))
   (locale          (system-setting 'locale))
   (keyboard-layout (system-setting 'keyboard-layout))
   (kernel          (system-setting 'kernel))
   (initrd          (system-setting 'initrd))
   (firmware        (system-setting 'firmware))
   (bootloader      (system-setting 'bootloader))
   (file-systems    (append (system-setting 'file-systems) %base-file-systems))
   (swap-devices    (system-setting 'swap-devices))
   (users           (append (system-setting 'users) %base-user-accounts))
   (groups          (delete-duplicates
                     (append (system-setting 'groups) %base-groups)
                     (lambda (a b) (string=? (user-group-name a)
                                             (user-group-name b)))))
   (packages        (append (system-setting 'extra-packages) %base-packages))
   (services        (append (system-setting 'extra-services)
                            (with-nonguix-substitutes
                             (modify-services (cons (service gnome-desktop-service-type)
                                                    %desktop-services)
                               (network-manager-service-type config =>
                                 (network-manager-configuration
                                  (inherit config)
                                  (dns "none")))))))
   (name-service-switch %mdns-host-lookup-nss)))
