;; -*- mode: scheme; -*-

(define-module (etc systems base-system)
  #:use-modules (gnu)
  #:use-modules (guix)
  #:export (base-system))

(use-package-modules ssh)
(use-service-modules networking ssh)

(operating-system
 (host-name "base-system")
 (timezone "America/New_York")
 ;;(timezone "Etc/UTC")
 (locale "en_US.utf8")
 (keyboard-layout (keyboard-layout "us" #:options '("ctrl:swapcaps")))
 (firmware '())
 (bootloader '())
 (file-systems '())
 (users '())
 (services (cons* (service dhcp-client-service-type)
		  (service openssh-service-type)
		  %base-services)))

