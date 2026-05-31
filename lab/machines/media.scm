;;; The media VM: Jellyfin running as a docker container.
;;;
;;; First-time setup after VM boots:
;;;   ssh -p 2226 root@10.20.0.11 'mkdir -p /srv/jellyfin/config /srv/jellyfin/cache /srv/media && chown -R nobody:users /srv/jellyfin'
;;;   browse http://10.20.0.11:8096 (or http://media.lab via reverse-proxy later)
;;;
;;; Drop movies/TV under /srv/media on the VM (or NFS-mount it from
;;; framework — for now just rsync into the VM).

(define-module (lab machines media)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu services docker)
  #:use-module (gnu services containers)
  #:use-module (gnu services dbus)
  #:use-module (gnu services desktop)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:use-module (lab prelude)
  #:export (media-os))

(define %mount-music-9p
  ;; Mount the host's ~/Music/my-music virtio-9p share at /srv/media.
  ;; Declared as a Shepherd one-shot rather than a (file-system …)
  ;; because `guix deploy` validates declared file-systems against real
  ;; block devices and "music" is a virtio tag, not a /dev path.
  (shepherd-service
   (provision '(mount-music))
   (requirement '(networking))
   (one-shot? #t)
   (start #~(lambda _
              (mkdir-p "/srv/media")
              (system* "/run/current-system/profile/sbin/mount"
                       "-t" "9p" "-o"
                       "trans=virtio,version=9p2000.L,ro"
                       "music" "/srv/media")
              #t))
   (stop #~(const #f))))

(define media-os
  (lab-base
   #:host-name "media"
   #:extra-services
   (list
    (service dbus-root-service-type)
    (service elogind-service-type)
    (service polkit-service-type)
    (service containerd-service-type)
    (service docker-service-type)
    (simple-service 'mount-music shepherd-root-service-type
                    (list %mount-music-9p))
    ;; libvirt's host DNS forwarder times out talking to the home
    ;; router; bypass it with 1.1.1.1 / 8.8.8.8. dhcpcd respects
    ;; /etc/resolv.conf.head, so this survives lease renewals.
    (simple-service 'override-resolv-conf-head etc-service-type
                    `(("resolv.conf.head"
                       ,(plain-file "resolv.conf.head"
                                    "nameserver 1.1.1.1
nameserver 8.8.8.8
"))))
    (service oci-service-type
             (oci-configuration
              (containers
               (list
                (oci-container-configuration
                 (image "jellyfin/jellyfin:latest")
                 (provision "jellyfin")
                 (auto-start? #t)
                 (respawn? #t)
                 (ports '(("8096" . "8096")))
                 (volumes '(("/srv/jellyfin/config" . "/config")
                            ("/srv/jellyfin/cache"  . "/cache")
                            ("/srv/media"           . "/media:ro")))))))))))

media-os
