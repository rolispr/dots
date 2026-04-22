;;; Framework system overrides — consumed by (system-setting 'key).
;;; Loaded when reconfigure gets `-L ~/dots/per-host/framework`.

(define-module (system-overrides)
  #:use-module (gnu)
  #:use-module (gnu services ssh)
  #:use-module (etc users bfh)
  #:export (override-hostname
            override-users
            override-file-systems
            override-swap-devices
            override-extra-services))

(define override-hostname "framework")

(define override-users (list %bfh))

(define override-file-systems
  (list (file-system
          (device (file-system-label "root"))
          (mount-point "/")
          (type "ext4"))
        (file-system
          (device (uuid "DD8A-2ACD" 'fat))
          (mount-point "/boot/efi")
          (type "vfat"))))

(define override-swap-devices
  (list (swap-space
         (target (uuid "008ed7c6-e6cb-4106-99b4-5eee8e5a7eec")))))

(define override-extra-services
  (list (service openssh-service-type
                 (openssh-configuration
                  (port-number 2226)
                  (password-authentication? #t)
                  (permit-root-login 'prohibit-password)))))
