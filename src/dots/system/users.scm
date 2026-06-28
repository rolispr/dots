(define-module (dots system users)
  #:use-module (gnu)
  #:export (%bfh))

(define %bfh
  (user-account
   (name "bfh")
   (comment "some guy")
   (group "users")
   (home-directory "/home/bfh")
   (supplementary-groups '("tty" "lp" "wheel" "netdev" "audio" "video"
                           "kvm" "libvirt" "i2c"))))
