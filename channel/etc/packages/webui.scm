(define-module (etc packages webui)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages webkit))

(define-public webui
  (package
    (name "webui")
    (version "2.5.0-beta.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/webui-dev/webui")
             (commit "dadf4175d6f2c4060b7a27a32e6e9e64e647116f")))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1s0963crmakxnfmzsykyq25i6ab59ynp017gxjbw8iyflaybbp4d"))))
    (build-system gnu-build-system)
    (inputs
     ;; libwebui's webview path dlopens libgtk-3.so.0 and
     ;; libwebkit2gtk-4.1.so.0 at runtime by bare basename.  These are
     ;; baked into the .so's RUNPATH below so the dlopens succeed
     ;; without LD_LIBRARY_PATH at the call site.
     (list gtk+ webkitgtk-for-gtk3))
    (native-inputs (list patchelf))
    (arguments
     (list
      #:tests? #f
      #:modules '((ice-9 popen)
                  (ice-9 textual-ports)
                  (srfi srfi-13)
                  (guix build gnu-build-system)
                  (guix build utils))
      #:make-flags
      #~(list (string-append "CC=" #$(cc-for-target)))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (replace 'build
            (lambda* (#:key make-flags #:allow-other-keys)
              (apply invoke "make" "-f" "GNUmakefile" "release" make-flags)))
          (replace 'install
            (lambda* (#:key outputs #:allow-other-keys)
              (let* ((out     (assoc-ref outputs "out"))
                     (lib     (string-append out "/lib"))
                     (include (string-append out "/include")))
                (mkdir-p lib)
                (mkdir-p include)
                (install-file "dist/libwebui-2.so"       lib)
                (install-file "dist/libwebui-2-static.a" lib)
                (install-file "include/webui.h"          include))))
          (add-after 'install 'set-runtime-runpath
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out  (assoc-ref outputs "out"))
                     (so   (string-append out "/lib/libwebui-2.so"))
                     (gtk  (assoc-ref inputs "gtk+"))
                     (wk   (assoc-ref inputs "webkitgtk-for-gtk3"))
                     (existing
                      (let* ((port (open-pipe* OPEN_READ
                                               "patchelf" "--print-rpath" so))
                             (s    (get-string-all port)))
                        (close-pipe port)
                        (string-trim-both s)))
                     (rp (string-append existing ":" gtk "/lib:" wk "/lib")))
                (invoke "patchelf" "--set-rpath" rp so)))))))
    (home-page "https://webui.me")
    (synopsis "Local HTTP+WebSocket server with browser-as-GUI bridge")
    (description "Small C library that embeds an HTTP and WebSocket server
on localhost and launches an installed web browser in app mode pointed at
it; the host program drives the browser as a GUI surface through a fast
binary protocol.")
    (license license:expat)))
