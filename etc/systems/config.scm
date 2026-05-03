;;; The system operating-system form. Every field reads from the
;;; settings layer via (system-setting 'key). Per-host differences
;;; live in per-host/<host>/system.scm as (system-overrides).
;;;
;;; Reconfigure:
;;;   sudo -E guix system -L ~/dots -L ~/dots/per-host/$(hostname) \
;;;        reconfigure ~/dots/etc/systems/config.scm

(use-modules (gnu)
             (gnu system nss)
             (gnu services desktop)
             (etc prelude)
             (etc systems defaults))

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
 (packages        (append (system-setting 'extra-packages) %base-packages))
 (services        (append (system-setting 'extra-services)
                          (with-nonguix-substitutes
                           (cons (service gnome-desktop-service-type)
                                 %desktop-services))))
 (name-service-switch %mdns-host-lookup-nss))
