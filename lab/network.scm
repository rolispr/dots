;;; libvirt "lab" network: 10.20.0.0/24 NAT, with static DHCP leases keyed
;;; by VM MAC. Defined+autostarted by a Shepherd one-shot that runs after
;;; libvirtd is up. Idempotent — re-running net-define against an unchanged
;;; XML is a no-op.

(define-module (lab network)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages virtualization)
  #:use-module (guix gexp)
  #:export (lab-network-services))

(define %lab-network-xml
  (plain-file "lab-network.xml"
              "<network>
  <name>lab</name>
  <forward mode='nat'/>
  <bridge name='virbr-lab' stp='on' delay='0'/>
  <ip address='10.20.0.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.20.0.100' end='10.20.0.200'/>
      <host mac='52:54:00:00:00:10' name='builder' ip='10.20.0.10'/>
      <host mac='52:54:00:00:00:11' name='media'   ip='10.20.0.11'/>
      <host mac='52:54:00:00:00:12' name='forge'   ip='10.20.0.12'/>
      <host mac='52:54:00:00:00:13' name='backup'  ip='10.20.0.13'/>
      <host mac='52:54:00:00:00:14' name='sync'    ip='10.20.0.14'/>
      <host mac='52:54:00:00:00:15' name='dns'     ip='10.20.0.15'/>
    </dhcp>
  </ip>
</network>
"))

(define %lab-network-shepherd
  (shepherd-service
   (provision '(lab-network))
   (requirement '(libvirtd))
   (one-shot? #t)
   (documentation
    "Define and start the libvirt 'lab' NAT network (10.20.0.0/24).")
   (start
    #~(make-forkexec-constructor
       (list #$(file-append libvirt "/bin/virsh")
             "-c" "qemu:///system"
             "net-define" #$%lab-network-xml)
       #:log-file "/var/log/lab-network.log"))
   (stop #~(const #f))))

(define %lab-network-autostart
  (shepherd-service
   (provision '(lab-network-autostart))
   (requirement '(lab-network))
   (one-shot? #t)
   (start
    #~(lambda _
        (system* #$(file-append libvirt "/bin/virsh")
                "-c" "qemu:///system" "net-autostart" "lab")
        (system* #$(file-append libvirt "/bin/virsh")
                "-c" "qemu:///system" "net-start"     "lab")
        #t))
   (stop #~(const #f))))

(define (lab-network-services)
  (list (simple-service 'lab-network shepherd-root-service-type
                        (list %lab-network-shepherd
                              %lab-network-autostart))))
