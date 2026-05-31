;;; `guix deploy` entry — reconfigures lab VMs in-place over SSH.
;;;
;;; Workflow:
;;;   - First time a machine exists:
;;;       guix system image -t qcow2 -L ~/dots ~/dots/lab/machines/NAME.scm
;;;       virt-install --import --name NAME --disk path=... ...
;;;   - Every change after that:
;;;       guix deploy ~/dots/lab/fleet.scm
;;;     (optionally `-- NAME1 NAME2` to deploy only a subset)
;;;
;;; The VM disk is never replaced, so /srv/* state (Jellyfin config,
;;; Docker image layers, restic snapshots, ...) survives every change.
;;; Roll back per-VM with `ssh root@VM 'guix system roll-back'`.

(define-module (lab fleet)
  #:use-module (gnu machine)
  #:use-module (gnu machine ssh)
  #:use-module (lab machines builder)
  #:use-module (lab machines media))

(define (lab-machine os ip)
  (machine
   (operating-system os)
   (environment managed-host-environment-type)
   (configuration
    (machine-ssh-configuration
     (host-name ip)
     (system "x86_64-linux")
     (user "root")
     (port 2226)
     (identity "/home/bfh/.ssh/id_ed25519")))))

(list (lab-machine builder-os "10.20.0.10")
      (lab-machine media-os   "10.20.0.11"))
