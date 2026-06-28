;;; Nyxt 4 -- keyboard-driven browser, Electron renderer (the v4 series replaced
;;; WebKitGTK with cl-electron driving a host Electron over a socket).
;;;
;;; Shape of this package:
;;;  - CL core builds from a recursive checkout (deps live in _build/ submodules).
;;;  - The only runtime node dep on the launch path is synchronous-socket (the
;;;    cl-electron transport); its small flat closure (synchronous-socket,
;;;    bindings, file-uri-to-path) is delivered on NODE_PATH.  No npm at build.
;;;  - Electron itself is the nonguix electron-36 host, not a node package.
;;;  - slynk is made available to the running image the way nymph is: not baked
;;;    in, but on CL_SOURCE_REGISTRY so config can (asdf:load-system :slynk) and
;;;    (slynk:create-server :port 4005 :dont-close t), then connect SLY.
;;;
;;; Still needs a build on the box to settle:
;;;  - the recursive-checkout sha256 (guix hash -rx, or build once and copy)
;;;  - the synchronous-socket node-gyp build against electron-36 headers
;;;    (node-deps-nyxt) -- the one real native unknown.

(define-module (dots packages nyxt)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages lisp)             ; sbcl
  #:use-module (gnu packages lisp-xyz)         ; sbcl-slynk
  #:use-module (gnu packages node)             ; node-lts
  #:use-module (nongnu packages electron)      ; electron-36
  #:use-module (dots packages node-deps-nyxt)) ; synchronous-socket closure

(define %commit "9276cf1d58eee073024e11f6294a8da3d18a6eb5")

(define-public nyxt
  (package
    (name "nyxt")
    (version "4.0.0-pre-3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/atlas-engineer/nyxt")
             (commit %commit)
             (recursive? #t)))
       (file-name (git-file-name name %commit))
       ;; TODO: guix hash -rx on a fresh recursive checkout.
       (sha256 (base32 "0000000000000000000000000000000000000000000000000000"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:make-flags
      #~(list "LISP=sbcl"
              "NYXT_RENDERER=electron"
              "NYXT_SUBMODULES=true"
              "NODE_SETUP=false"
              (string-append "NYXT_VERSION=" #$version)
              (string-append "PREFIX=" #$output)
              "DESTDIR=/")
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)

          ;; Launch the Guix electron directly instead of `npm run start`.
          (add-after 'unpack 'patch-electron-launch
            (lambda* (#:key inputs #:allow-other-keys)
              (substitute* "_build/cl-electron/source/core.lisp"
                (("\\(list \"npm\" \"run\" \"start\" \"--\"\\)")
                 (string-append
                  "(list \""
                  (search-input-file inputs "/bin/electron")
                  "\")")))))

          (add-after 'install 'wrap
            (lambda* (#:key inputs #:allow-other-keys)
              (define (node-modules name)
                (string-append (assoc-ref inputs name) "/lib/node_modules"))
              (wrap-program (string-append #$output "/bin/nyxt")
                ;; electron on PATH as a runtime backstop
                `("PATH" ":" prefix
                  (,(dirname (search-input-file inputs "/bin/electron"))))
                ;; full synchronous-socket closure so server.js's require()s
                ;; resolve -- flat and complete, no transitive gaps
                `("NODE_PATH" ":" prefix
                  ,(map node-modules
                        '("node-synchronous-socket"
                          "node-bindings"
                          "node-file-uri-to-path")))
                ;; slynk reachable for the running image's ASDF (nymph-style)
                `("CL_SOURCE_REGISTRY" ":" prefix
                  (,(string-append (assoc-ref inputs "sbcl-slynk") "//")))))))))
    (native-inputs
     (list sbcl
           node-lts))
    (inputs
     (list electron-36
           sbcl-slynk
           node-synchronous-socket-0.0.2
           node-bindings-1.5.0
           node-file-uri-to-path-1.0.0))
    (home-page "https://nyxt.atlas.engineer")
    (synopsis "Keyboard-driven, Lisp-extensible web browser (Electron renderer)")
    (description
     "Nyxt is a keyboard-oriented, infinitely extensible web browser written and
configured in Common Lisp.  Version 4 renders through Electron via cl-electron,
which drives an Electron process over a socket.  slynk is on the load path so a
SLY REPL can be started from the running browser with
@code{(asdf:load-system :slynk)} and @code{(slynk:create-server :port 4005)}.")
    (license license:bsd-3)))

nyxt
