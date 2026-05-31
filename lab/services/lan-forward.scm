;;; LAN port-forwarders: expose lab-internal TCP ports on framework's
;;; LAN interface using socat. One Shepherd service per forward.
;;;
;;; Use this until the AdGuard DNS VM lands and we can replace these
;;; with proper nginx vhosts on pretty *.lab names.

(define-module (lab services lan-forward)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages networking)
  #:use-module (guix gexp)
  #:export (lan-forwarders))

(define (socat-shepherd-service name lan-port target-host target-port)
  (shepherd-service
   (provision (list name))
   (requirement '(networking))
   (documentation
    (string-append "TCP forward 0.0.0.0:"
                   (number->string lan-port)
                   " -> " target-host ":"
                   (number->string target-port)))
   (start #~(make-forkexec-constructor
             (list #$(file-append socat "/bin/socat")
                   "-d"
                   (string-append "TCP-LISTEN:"
                                  #$(number->string lan-port)
                                  ",fork,reuseaddr")
                   (string-append "TCP:"
                                  #$target-host ":"
                                  #$(number->string target-port)))
             #:log-file (string-append "/var/log/"
                                       #$(symbol->string name)
                                       ".log")))
   (stop #~(make-kill-destructor))
   (respawn? #t)))

(define (lan-forwarders forwards)
  "FORWARDS is a list of (NAME LAN-PORT TARGET-HOST TARGET-PORT).
Returns a service that registers one Shepherd service per forward."
  (list
   (simple-service 'lan-forwarders shepherd-root-service-type
                   (map (lambda (f)
                          (apply socat-shepherd-service f))
                        forwards))))
