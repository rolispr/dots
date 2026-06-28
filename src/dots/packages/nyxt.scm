;;; Nyxt 4 -- the keyboard-driven browser, now on an Electron renderer (the v4
;;; series replaced WebKitGTK/WebEngine with the "Electron port").  This is a
;;; WORKING SKELETON, not a finished package: the Common Lisp core builds from
;;; a recursive checkout, but the Electron side still needs its node deps fed in
;;; offline -- see the TODOs.  Electron itself comes from nonguix.

(define-module (dots packages nyxt)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages lisp)          ; sbcl
  #:use-module (gnu packages node)          ; node-lts (npm + node)
  #:use-module (nongnu packages electron)   ; electron-36, electron-36-node-headers
  #:use-module (dots packages node-deps-nyxt)) ; cl-electron server.js node deps

(define-public nyxt
  (package
    (name "nyxt")
    (version "4.0.0")
    (source
     (origin
       ;; git, NOT the release tarball: the CL deps live in _build/ as
       ;; submodules and the GitHub tarball omits them.
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/atlas-engineer/nyxt")
             (commit version)
             (recursive? #t)))
       (file-name (git-file-name name version))
       ;; TODO: fill in -- `guix hash -rx .` on a fresh recursive checkout, or
       ;; `guix build -f` once and copy the reported hash.
       (sha256 (base32 "0000000000000000000000000000000000000000000000000000"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f                            ; the test-system needs a display
      #:make-flags
      #~(list "LISP=sbcl"
              "NYXT_RENDERER=electron"
              "NYXT_SUBMODULES=true"         ; resolve CL deps from ./_build
              "NODE_SETUP=false"             ; we provide node deps; never npm-install
              (string-append "NYXT_VERSION=" #$version)
              (string-append "PREFIX=" #$output)
              "DESTDIR=/")
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)               ; plain makefile, no ./configure

          ;; cl-electron's server.js require()s @ghostery/adblocker-electron,
          ;; cross-fetch and synchronous-socket. These are vendored as Guix
          ;; node packages (dots packages node-deps-nyxt); the wrap phase exports
          ;; NODE_PATH so the Electron process resolves them from the store.
          ;; TODO: confirm node resolves the full transitive closure via
          ;; NODE_PATH alone; if not, assemble a flat node_modules here. The
          ;; native synchronous-socket must be ABI-built against Electron's node
          ;; (electron-36-node-headers), not plain node -- the one real unknown
          ;; that needs an actual build to settle.

          ;; Point cl-electron at the Guix electron instead of `npm run start`,
          ;; so launch never shells npm. The source-dir cwd is kept because
          ;; server.js still loads its node_modules relative to it.
          (add-after 'unpack 'patch-electron-launch
            (lambda* (#:key inputs #:allow-other-keys)
              (substitute* "_build/cl-electron/source/core.lisp"
                (("\\(list \"npm\" \"run\" \"start\" \"--\"\\)")
                 (string-append
                  "(list \""
                  (search-input-file inputs "/bin/electron")
                  "\")")))))

          ;; nyxt resolves electron at runtime; keep it on PATH as a backstop,
          ;; and put the cl-electron server's node deps on NODE_PATH so the
          ;; spawned Electron process (which inherits this env) can require them.
          (add-after 'install 'wrap
            (lambda* (#:key inputs #:allow-other-keys)
              (define (node-modules label)
                (string-append (assoc-ref inputs label) "/lib/node_modules"))
              (wrap-program (string-append #$output "/bin/nyxt")
                `("PATH" ":" prefix
                  (,(dirname (search-input-file inputs "/bin/electron"))))
                `("NODE_PATH" ":" prefix
                  ,(map node-modules
                        '("node-ghostery-adblocker-electron"
                          "node-cross-fetch"
                          "node-synchronous-socket")))))))))
    (native-inputs
     (list sbcl
           node-lts                          ; node-gyp toolchain for native deps
           electron-36-node-headers))        ; headers to build synchronous-socket
    (inputs
     (list electron-36
           node-ghostery-adblocker-electron-2.18.0
           node-cross-fetch-4.1.0
           node-synchronous-socket-0.0.2))
    (home-page "https://nyxt.atlas.engineer")
    (synopsis "Keyboard-driven, Lisp-extensible web browser (Electron renderer)")
    (description
     "Nyxt is a keyboard-oriented, infinitely extensible web browser written and
configured in Common Lisp.  Version 4 renders through Electron rather than
WebKitGTK.  The Lisp core is dumped as an SBCL image that drives an Electron
process over a socket via cl-electron.")
    (license license:bsd-3)))

nyxt
