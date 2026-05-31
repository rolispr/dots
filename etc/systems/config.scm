;;; THE system operating-system form. Every field reads from the
;;; settings layer via (system-setting 'key). Per-host differences
;;; live in per-host/<host>/system.scm as (system-overrides).
;;;
;;; Reconfigure:
;;;   sudo -E guix system -L ~/dots -L ~/dots/per-host/$(hostname) \
;;;        reconfigure ~/dots/etc/systems/config.scm

(define-module (etc systems config)
  #:use-module (gnu)
  #:use-module (gnu system nss)
  #:use-module (gnu services desktop)
  #:use-module (srfi srfi-1)
  #:use-module (etc prelude)
  #:use-module (etc systems defaults))

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
 (users           (append (system-setting 'users)  %base-user-accounts))
 ;; delete-duplicates by name: libvirt-service-type also extends
 ;; account-service-type with the libvirt group; without dedup we'd
 ;; warn "groups appear more than once: libvirt".
 (groups          (delete-duplicates
                   (append (system-setting 'groups) %base-groups)
                   (lambda (a b) (string=? (user-group-name a)
                                           (user-group-name b)))))
 (packages        (append (system-setting 'extra-packages) %base-packages))
 (services        (append (system-setting 'extra-services)
                          (with-nonguix-substitutes
                           (cons (service gnome-desktop-service-type)
                                 %desktop-services))))
 (name-service-switch %mdns-host-lookup-nss))
