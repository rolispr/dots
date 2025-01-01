;; -*- mode: scheme; -*-

(define-module (etc systems base-system)
  #:use-module (gnu)
  #:use-module (guix)
  #:export (base-system
	    base-keyboard-layout
	    base-locale
	    base-timezone))

(use-package-modules ssh)
(use-service-modules networking ssh)

(define base-keyboard-layout 
  (keyboard-layout "us" #:options '("ctrl:swapcaps")))
(define base-locale "en_US.utf8")
(define base-timezone "America/New_York")
(define base-system
  (operating-system
   (host-name "base-system")
   (timezone base-timezone)
   ;;(timezone "Etc/o
   (locale base-locale)
   (keyboard-layout base-keyboard-layout)
   (firmware '())
   (bootloader '())
   (file-systems '())
   (users '())
   (services (cons* (service dhcp-client-service-type)
		    (service openssh-service-type)
		    %base-services)))
  )

