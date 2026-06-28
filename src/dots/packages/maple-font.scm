;;; Maple Mono, Nerd Font variant: one monospace family carrying programming
;;; ligatures and embedded Nerd-Font icon glyphs, installed from the upstream
;;; prebuilt TTF release. Used as the single font + icon source for the desktop.

(define-module (dots packages maple-font)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system font)
  #:use-module (gnu packages compression))

(define-public font-maple-mono-nf
  (package
    (name "font-maple-mono-nf")
    (version "7.9")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/subframe7536/maple-font/releases/download/v"
             version "/MapleMono-NF.zip"))
       (sha256
        (base32 "12gv6ng5iv18naaq2hjmbfrb5qha0240ws1pbmip3n4mr23qn2ar"))))
    (build-system font-build-system)
    (native-inputs (list unzip))
    (home-page "https://github.com/subframe7536/maple-font")
    (synopsis "Maple Mono with ligatures and embedded Nerd-Font icons")
    (description
     "Maple Mono is a monospace typeface with rounded letterforms and smart
programming ligatures.  This @code{NF} variant embeds a full set of Nerd-Font
icon glyphs in the same family, so one font supplies both the text face and the
icon coverage a status bar or shell prompt needs, across every weight and
italic.")
    (license license:silofl1.1)))
