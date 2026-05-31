;;; The builder VM: signed substitute server (`guix publish`) on :8080.
;;; bootstrap?=#t so it doesn't try to pull substitutes from itself.
;;;
;;; Phase 1.5 (separate work) adds Cuirass on :8081 — the spec format
;;; in current Guix master uses <specification> records rather than the
;;; alist style in lab/services/cuirass-spec.scm; need to port that.
;;;
;;; Day-to-day until Cuirass lands:
;;;   ssh -p 2226 bfh@10.20.0.10
;;;   git clone <dots> ~/dots
;;;   guix build claude-code -L ~/dots         # build whatever you need
;;;   # automatically published at http://10.20.0.10:8080/
;;;
;;; First boot signing key:
;;;   ssh -p 2226 root@10.20.0.10 'guix archive --generate-key'
;;;   ssh -p 2226 root@10.20.0.10 'cat /etc/guix/signing-key.pub' \
;;;       > ~/dots/channel/builder-signing-key.pub
;;;   git -C ~/dots add channel/builder-signing-key.pub && git commit ...
;;;   guix deploy ~/dots/lab/fleet.scm   # other VMs now trust builder

(define-module (lab machines builder)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu services guix)
  #:use-module (lab prelude)
  #:export (builder-os))

(define builder-os
  (lab-base
   #:host-name "builder"
   #:bootstrap? #t
   #:extra-services
   (list
    (service guix-publish-service-type
             (guix-publish-configuration
              (host "0.0.0.0")
              (port 8080)
              (cache "/var/cache/publish")
              (compression '(("zstd" 3))))))))

builder-os
