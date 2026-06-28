(define-module (dots packages claude-agent-acp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages node))

(define acp-sdk-tarball
  (origin
    (method url-fetch)
    (uri "https://registry.npmjs.org/@agentclientprotocol/sdk/-/sdk-0.25.0.tgz")
    (sha256 (base32 "03klfl04fr9gv6rfw86h7zbax9qr87wnywr0l5isz9sfavccx603"))))

(define claude-agent-sdk-tarball
  (origin
    (method url-fetch)
    (uri "https://registry.npmjs.org/@anthropic-ai/claude-agent-sdk/-/claude-agent-sdk-0.3.170.tgz")
    (sha256 (base32 "15939lgp42x6ix7c9zbypzaplb2pxdx3zqz9mb8qhr4xabm2svnm"))))

(define zod-tarball
  (origin
    (method url-fetch)
    (uri "https://registry.npmjs.org/zod/-/zod-3.25.76.tgz")
    (sha256 (base32 "0xw3m1qdqbqam3fhxiv8ag9l9kampywwx4gfcjmis36xy02il7wy"))))

(define-public claude-agent-acp
  (package
    (name "claude-agent-acp")
    (version "0.44.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://registry.npmjs.org/@agentclientprotocol/claude-agent-acp"
             "/-/claude-agent-acp-" version ".tgz"))
       (sha256
        (base32 "08zkkpjcm7hzz03qi2v4yip3vz3faafjsq9pdsnf44g2b520gkm8"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("." "share/claude-agent-acp/"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'install-deps
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out  (assoc-ref outputs "out"))
                     (root (string-append out "/share/claude-agent-acp"))
                     (nm   (string-append root "/node_modules")))
                (define (extract-into tarball dest)
                  (mkdir-p dest)
                  (invoke "tar" "xzf" tarball "-C" dest
                          "--strip-components=1"))
                (mkdir-p (string-append nm "/@agentclientprotocol"))
                (mkdir-p (string-append nm "/@anthropic-ai"))
                (extract-into (assoc-ref inputs "acp-sdk")
                              (string-append nm "/@agentclientprotocol/sdk"))
                (extract-into (assoc-ref inputs "claude-agent-sdk")
                              (string-append nm "/@anthropic-ai/claude-agent-sdk"))
                (extract-into (assoc-ref inputs "zod")
                              (string-append nm "/zod")))))
          (add-after 'install-deps 'write-wrapper
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out     (assoc-ref outputs "out"))
                     (share   (string-append out "/share/claude-agent-acp"))
                     (bin-dir (string-append out "/bin"))
                     (wrapper (string-append bin-dir "/claude-agent-acp"))
                     (node    (assoc-ref inputs "node"))
                     (bash    (assoc-ref inputs "bash-minimal"))
                     (hashbang (string #\x23 #\x21)))
                (mkdir-p bin-dir)
                (call-with-output-file wrapper
                  (lambda (port)
                    (format port "~a~a/bin/bash~%" hashbang bash)
                    (format port "exec ~a/bin/node ~a/dist/index.js \"$@\"~%"
                            node share)))
                (chmod wrapper #o555)))))))
    (inputs
     `(("bash-minimal"     ,bash-minimal)
       ("node"             ,node)
       ("acp-sdk"          ,acp-sdk-tarball)
       ("claude-agent-sdk" ,claude-agent-sdk-tarball)
       ("zod"              ,zod-tarball)))
    (home-page "https://github.com/agentclientprotocol/claude-agent-acp")
    (synopsis "Agent Client Protocol adapter for the Claude Agent SDK")
    (description
     "ACP adapter that wraps the Claude Agent SDK so any Agent Client
Protocol client (Emacs @code{agent-shell}, Zed, etc.) can drive Claude.
Packaged from the published npm tarball with its three runtime
dependencies (@code{zod}, @code{@@agentclientprotocol/sdk},
@code{@@anthropic-ai/claude-agent-sdk}) materialised into a
@file{node_modules} tree next to the script.")
    (license license:asl2.0)))
