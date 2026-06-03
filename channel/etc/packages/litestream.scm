(define-module (etc packages litestream)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages nss))

(define-public litestream
  (package
    (name "litestream")
    (version "0.5.11")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/benbjohnson/litestream/releases/download/v"
             version "/litestream-" version "-linux-x86_64.tar.gz"))
       (sha256
        (base32 "0mdbyzq1h0k9lql2n1bfyxz9g3nysc1dyyp3dq8pmzx0n2vgv01g"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~(quote (("litestream" "libexec/litestream/litestream")))
      #:phases
      #~(modify-phases %standard-phases
          (replace 'unpack
            (lambda* (#:key source #:allow-other-keys)
              (invoke #$(file-append tar "/bin/tar") "xzf" source)))
          (add-after 'install 'write-wrapper
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out     (assoc-ref outputs "out"))
                     (real    (string-append out "/libexec/litestream/litestream"))
                     (bin-dir (string-append out "/bin"))
                     (wrapper (string-append bin-dir "/litestream"))
                     (bash    (assoc-ref inputs "bash-minimal"))
                     (nss     (assoc-ref inputs "nss-certs"))
                     (certs   (string-append nss "/etc/ssl/certs"))
                     (ca-file (string-append certs "/ca-certificates.crt")))
                (chmod real #o555)
                (mkdir-p bin-dir)
                (call-with-output-file wrapper
                  (lambda (port)
                    (format port "#!~a/bin/bash~%" bash)
                    (format port "export SSL_CERT_DIR=\"${SSL_CERT_DIR:-~a}\"~%" certs)
                    (format port "export SSL_CERT_FILE=\"${SSL_CERT_FILE:-~a}\"~%" ca-file)
                    (format port "exec ~a \"$@\"~%" real)))
                (chmod wrapper #o555)))))))
    (inputs
     `(("bash-minimal" ,bash-minimal)
       ("nss-certs"    ,nss-certs)))
    (home-page "https://litestream.io")
    (synopsis "Streaming replication for SQLite")
    (description
     "Litestream is a standalone disaster-recovery tool for SQLite.  It runs as
a background process and continuously streams WAL frames from a live SQLite
database to one or more replicas (S3, SFTP, GCS, Azure, or a local
filesystem), without interrupting writers.  The @code{litestream restore}
command rebuilds the database from a replica at any point in its retention
window.  Packaged from the upstream linux/amd64 release tarball; the Go
binary is statically linked, so only a thin wrapper is needed for the Guix
CA bundle.")
    (license license:asl2.0)))
