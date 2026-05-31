(define-module (etc packages qwen-code)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages node))

(define-public qwen-code
  (package
    (name "qwen-code")
    (version "0.14.5")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://registry.npmjs.org/@qwen-code/qwen-code"
             "/-/qwen-code-" version ".tgz"))
       (sha256
        (base32 "0mdjzfqcazw71xcgzi842s4lvqcank54bv1kdk18dhg9dzs927r0"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("." "share/qwen-code"
           #:include-regexp ("^\\./cli\\.js$"
                             "^\\./package\\.json$"
                             "^\\./LICENSE$"
                             "^\\./README\\.md$"
                             "^\\./locales/"
                             "^\\./bundled/"
                             "^\\./vendor/")))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'write-wrapper
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out     (assoc-ref outputs "out"))
                     (share   (string-append out "/share/qwen-code"))
                     (bin-dir (string-append out "/bin"))
                     (wrapper (string-append bin-dir "/qwen"))
                     (node    (assoc-ref inputs "node"))
                     (bash    (assoc-ref inputs "bash-minimal"))
                     (hashbang (string #\x23 #\x21)))
                (mkdir-p bin-dir)
                (call-with-output-file wrapper
                  (lambda (port)
                    (format port "~a~a/bin/bash~%" hashbang bash)
                    (format port "exec ~a/bin/node ~a/cli.js \"$@\"~%"
                            node share)))
                (chmod wrapper #o555)))))))
    (inputs
     `(("bash-minimal" ,bash-minimal)
       ("node"         ,node)))
    (home-page "https://github.com/QwenLM/qwen-code")
    (synopsis "Qwen Code terminal AI agent")
    (description
     "Open-source terminal AI agent from QwenLM, optimized for Qwen models.
Pure-JS Node CLI.  Launched as @code{qwen}; configure providers (including
a local @code{llama-server}) via @file{~/.qwen/settings.json}.")
    (license license:asl2.0)))
