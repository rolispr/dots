;;; Arraniz system overrides — consumed by (system-setting 'key).
;;; Loaded by (dots settings) via DOTS_HOSTNAME=arraniz; -L src is enough.

(define-module (dots hosts arraniz system)
  #:use-module (gnu)
  #:use-module (dots system users)
  #:export (override-hostname
            override-users
            override-file-systems
            override-swap-devices))

(define override-hostname "arraniz")

(define override-users (list %bfh))

(define override-file-systems
  (list (file-system
          (device (file-system-label "root"))
          (mount-point "/")
          (type "ext4"))
        (file-system
          (device (uuid "D140-4BF5" 'fat))
          (mount-point "/boot/efi")
          (type "vfat"))))

(define override-swap-devices
  (list (swap-space
         (target (uuid "a0bca027-0738-4287-933b-42f5960a25ed")))))
