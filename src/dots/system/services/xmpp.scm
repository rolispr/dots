(define-module (dots system services xmpp)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu services certbot)
  #:use-module (gnu services messaging)
  #:use-module (gnu services networking)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services web)
  #:use-module (guix gexp)
  #:use-module (dots system services messaging-extras)
  #:export (xmpp-services))

(define %xmpp-nftables-ruleset
  "table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;
    ct state established,related accept
    iif lo accept
    icmp type echo-request accept
    icmpv6 type echo-request accept
    tcp dport 22 accept
    tcp dport { 80, 443, 5222, 5269, 5281 } accept
  }
  chain forward {
    type filter hook forward priority 0; policy drop;
  }
  chain output {
    type filter hook output priority 0; policy accept;
  }
}
")

(define* (xmpp-services #:key
                        domain
                        admin-email
                        (muc-subdomain      "conference")
                        (upload-subdomain   "upload")
                        (upload-size-limit  (* 100 1024 1024))
                        (upload-daily-quota (* 500 1024 1024))
                        (upload-expire-after (* 7 24 3600))
                        (open-firewall? #t))
  (let* ((muc-domain    (string-append muc-subdomain    "." domain))
         (upload-domain (string-append upload-subdomain "." domain))
         (admin-jid     (string-append "admin@" domain))
         (cert-dir      (string-append "/etc/letsencrypt/live/" domain))
         (xmpp-components
          (list
           (muc-component-configuration
            (domain muc-domain)
            (name "chat rooms")
            (restrict-room-creation? #f)
            (muc-mam? #t))
           (http-file-share-component-configuration
            (domain upload-domain)
            (size-limit upload-size-limit)
            (daily-quota upload-daily-quota)
            (expire-after upload-expire-after))))
         (xmpp-prosody-service
          (service prosody-service-type
                   (prosody-configuration
                    (admins (list admin-jid))
                    (ssl (ssl-configuration
                          (certificate
                           (string-append cert-dir "/fullchain.pem"))
                          (key
                           (string-append cert-dir "/privkey.pem"))))
                    (modules-enabled
                     '("roster"
                       "saslauth"
                       "tls"
                       "dialback"
                       "disco"
                       "carbons"
                       "pep"
                       "private"
                       "blocklist"
                       "vcard4"
                       "vcard_legacy"
                       "version"
                       "uptime"
                       "time"
                       "ping"
                       "register"
                       "mam"
                       "csi_simple"
                       "smacks"
                       "admin_adhoc"
                       "http_file_share"))
                    (allow-registration? #f)
                    (c2s-require-encryption? #t)
                    (s2s-require-encryption? #t)
                    (s2s-secure-auth? #f)
                    (virtualhosts
                     (list
                      (virtualhost-configuration
                       (domain domain))))
                    (int-components
                     (components->int-components xmpp-components)))))
         (xmpp-certbot-service
          (service certbot-service-type
                   (certbot-configuration
                    (email admin-email)
                    (webroot "/var/lib/letsencrypt/.well-known")
                    (certificates
                     (list
                      (certificate-configuration
                       (name domain)
                       (domains (list domain muc-domain upload-domain))
                       (deploy-hook
                        (program-file
                         "reload-prosody"
                         #~(begin
                             (use-modules (ice-9 popen))
                             (let ((port (open-input-pipe
                                          "herd restart prosody")))
                               (close-pipe port))))))))
                    (default-location
                      (nginx-location-configuration
                       (uri "/")
                       (body (list "return 404;")))))))
         (xmpp-nginx-service
          (service nginx-service-type
                   (nginx-configuration
                    (server-blocks
                     (list
                      (nginx-server-configuration
                       (server-name (list domain muc-domain upload-domain))
                       (listen '("80"))
                       (locations
                        (list
                         (nginx-location-configuration
                          (uri "/.well-known/acme-challenge/")
                          (body
                           (list "root /var/lib/letsencrypt/;")))
                         (nginx-location-configuration
                          (uri "/")
                          (body
                           (list "return 404;")))))))))))
         (xmpp-nftables-service
          (service nftables-service-type
                   (nftables-configuration
                    (ruleset
                     (plain-file "nftables.conf"
                                 %xmpp-nftables-ruleset))))))
    (if open-firewall?
        (list xmpp-prosody-service
              xmpp-certbot-service
              xmpp-nginx-service
              xmpp-nftables-service)
        (list xmpp-prosody-service
              xmpp-certbot-service
              xmpp-nginx-service))))
