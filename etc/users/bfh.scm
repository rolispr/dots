(define-module (etc users bfh)
  #:use-module (gnu)
  #:export (%bfh))

(define %bfh
  (user-account
   (name "bfh")
   (comment "some guy")
   (group "users")
   (home-directory "/home/bfh")
   (supplementary-groups '("tty" "lp" "wheel" "netdev" "audio" "video"))))
