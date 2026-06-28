(define-module (dots packages opentofu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages nss))

(define-public opentofu
  (package
    (name "opentofu")
    (version "1.12.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/opentofu/opentofu/releases/download/v"
             version "/tofu_" version "_linux_amd64.zip"))
       (sha256
        (base32 "0dqipg2xf1dri0b4zk5wfr9h7afhrj9l6q27yzwr1mxn8bym0xld"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~(quote (("tofu" "libexec/opentofu/tofu")))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'write-wrapper
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out     (assoc-ref outputs "out"))
                     (real    (string-append out "/libexec/opentofu/tofu"))
                     (bin-dir (string-append out "/bin"))
                     (wrapper (string-append bin-dir "/tofu"))
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
    (native-inputs (list unzip))
    (inputs
     `(("bash-minimal" ,bash-minimal)
       ("nss-certs"    ,nss-certs)))
    (home-page "https://opentofu.org")
    (synopsis "OpenTofu — open-source Terraform fork")
    (description
     "OpenTofu is an open-source infrastructure-as-code tool, forked from
HashiCorp Terraform after the BSL license change.  Packaged from the upstream
linux/amd64 release zip; the Go binary is statically linked, so only a small
wrapper is needed to point at the Guix CA bundle for the registry.")
    (license license:mpl2.0)))
