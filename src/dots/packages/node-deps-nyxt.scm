;;; Node dependencies for Nyxt's Electron side (cl-electron's server.js).
;;; Machine-imported via `guix import npm-binary --recursive' for:
;;;   @ghostery/adblocker-electron, cross-fetch, synchronous-socket
;;; The npm `electron' downloader subtree was stripped: require('electron')
;;; resolves to the host Electron (nonguix electron-36) at runtime, not a node
;;; package. synchronous-socket is native (nan) and must be built against the
;;; Electron node ABI, not plain node -- see node-synchronous-socket below.
;;;
;;; TODO: review/clean to channel style; this is the raw import set.

(define-module (dots packages node-deps-nyxt)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix build-system node))

(define-public node-ghostery-url-parser-1.3.1
  (package
    (name "node-ghostery-url-parser")
    (version "1.3.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ghostery/url-parser")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "11255w1x125p7hn39jnkqb0ag31nw3xgiwpfgc4ym0pbnfi5nnfi"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (inputs (list node-tldts-experimental-7.4.4))
    (home-page "https://github.com/ghostery/url-parser")
    (synopsis "Fast URL parser implementation")
    (description "This package provides a Fast URL parser implementation.")
    (license license:mpl2.0)))

(define-public node-remusao-guess-url-type-2.1.0
  (package
    (name "node-remusao-guess-url-type")
    (version "2.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/remusao/mono")
             (commit (string-append "@remusao/badger@" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0a9g5xjg4rikmrr09msz35p8510a1cy33a9jwg0wvakc2vfnr3wv"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (home-page "https://github.com/remusao/mono")
    (synopsis "Guess type of resource based on its URL")
    (description "Guess type of resource based on its URL.")
    (license license:mpl2.0)))

(define-public node-remusao-small-2.1.0
  (package
    (name "node-remusao-small")
    (version "2.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/remusao/mono")
             (commit (string-append "@remusao/badger@" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0a9g5xjg4rikmrr09msz35p8510a1cy33a9jwg0wvakc2vfnr3wv"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (home-page "https://github.com/remusao/mono")
    (synopsis "Smalles files for different MIME types")
    (description "Smalles files for different MIME types.")
    (license license:mpl2.0)))

(define-public node-remusao-trie-2.1.0
  (package
    (name "node-remusao-trie")
    (version "2.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/remusao/mono")
             (commit (string-append "@remusao/badger@" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0a9g5xjg4rikmrr09msz35p8510a1cy33a9jwg0wvakc2vfnr3wv"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (home-page "https://github.com/remusao/mono")
    (synopsis "tiny trie implementation")
    (description "This package provides a tiny trie implementation.")
    (license license:mpl2.0)))

(define-public node-remusao-smaz-compress-2.2.0
  (package
    (name "node-remusao-smaz-compress")
    (version "2.2.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/remusao/mono")
             (commit (string-append "@remusao/smaz-benchmarks@" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0a9g5xjg4rikmrr09msz35p8510a1cy33a9jwg0wvakc2vfnr3wv"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (inputs (list node-remusao-trie-2.1.0))
    (home-page "https://github.com/remusao/mono")
    (synopsis "Compress strings using custom codebooks")
    (description "Compress strings using custom codebooks.")
    (license license:mpl2.0)))

(define-public node-remusao-smaz-decompress-2.2.0
  (package
    (name "node-remusao-smaz-decompress")
    (version "2.2.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/remusao/mono")
             (commit (string-append "@remusao/smaz-benchmarks@" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0a9g5xjg4rikmrr09msz35p8510a1cy33a9jwg0wvakc2vfnr3wv"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (home-page "https://github.com/remusao/mono")
    (synopsis "Decompress strings using custom codebooks")
    (description "Decompress strings using custom codebooks.")
    (license license:mpl2.0)))

(define-public node-remusao-smaz-2.2.0
  (package
    (name "node-remusao-smaz")
    (version "2.2.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/remusao/mono")
             (commit (string-append "@remusao/smaz-benchmarks@" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0a9g5xjg4rikmrr09msz35p8510a1cy33a9jwg0wvakc2vfnr3wv"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (inputs (list node-remusao-smaz-decompress-2.2.0
                  node-remusao-smaz-compress-2.2.0))
    (home-page "https://github.com/remusao/mono")
    (synopsis "Compress strings using custom codebooks")
    (description "Compress strings using custom codebooks.")
    (license license:mpl2.0)))

(define-public node-ghostery-adblocker-2.18.0
  (package
    (name "node-ghostery-adblocker")
    (version "2.18.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://git@github.com/ghostery/adblocker")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "06bfpb4a1kqzw3wbdlpyr6qr4zq1wsyfb1y82qk7yycmb5nmdi7a"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (inputs (list node-tldts-experimental-7.4.4
                  node-remusao-smaz-2.2.0
                  node-remusao-small-2.1.0
                  node-remusao-guess-url-type-2.1.0
                  node-ghostery-url-parser-1.3.1
                  node-ghostery-adblocker-extended-selectors-2.18.0
                  node-ghostery-adblocker-content-2.18.0))
    (home-page "https://github.com/ghostery/adblocker")
    (synopsis "Ghostery adblocker library")
    (description "Ghostery adblocker library.")
    (license license:mpl2.0)))

(define-public node-ghostery-adblocker-extended-selectors-2.18.0
  (package
    (name "node-ghostery-adblocker-extended-selectors")
    (version "2.18.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://git@github.com/ghostery/adblocker")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "06bfpb4a1kqzw3wbdlpyr6qr4zq1wsyfb1y82qk7yycmb5nmdi7a"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (home-page "https://github.com/ghostery/adblocker")
    (synopsis
     "Ghostery adblocker library (extended CSS selectors implementation)")
    (description
     "Ghostery adblocker library (extended CSS selectors implementation).")
    (license license:mpl2.0)))

(define-public node-ghostery-adblocker-content-2.18.0
  (package
    (name "node-ghostery-adblocker-content")
    (version "2.18.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://git@github.com/ghostery/adblocker")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "06bfpb4a1kqzw3wbdlpyr6qr4zq1wsyfb1y82qk7yycmb5nmdi7a"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (inputs (list node-ghostery-adblocker-extended-selectors-2.18.0))
    (home-page "https://github.com/ghostery/adblocker")
    (synopsis "Ghostery adblocker library (content-scripts helpers)")
    (description "Ghostery adblocker library (content-scripts helpers).")
    (license license:mpl2.0)))

(define-public node-ghostery-adblocker-electron-preload-2.18.0
  (package
    (name "node-ghostery-adblocker-electron-preload")
    (version "2.18.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://git@github.com/ghostery/adblocker")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "06bfpb4a1kqzw3wbdlpyr6qr4zq1wsyfb1y82qk7yycmb5nmdi7a"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (inputs (list node-ghostery-adblocker-content-2.18.0))
    (home-page "https://github.com/ghostery/adblocker")
    (synopsis "Ghostery adblocker Electron wrapper preload script")
    (description "Ghostery adblocker Electron wrapper preload script.")
    (license license:mpl2.0)))

(define-public node-tldts-core-7.4.4
  (package
    (name "node-tldts-core")
    (version "7.4.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://git@github.com/remusao/tldts")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "09m2p5x7qc00jk7dqhvn6dd5g31dymbwaifzrq1s8rf6ca2aywh9"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (home-page "https://github.com/remusao/tldts")
    (synopsis "tldts core primitives (internal module)")
    (description "tldts core primitives (internal module).")
    (license license:expat)))

(define-public node-tldts-experimental-7.4.4
  (package
    (name "node-tldts-experimental")
    (version "7.4.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://git@github.com/remusao/tldts")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "09m2p5x7qc00jk7dqhvn6dd5g31dymbwaifzrq1s8rf6ca2aywh9"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (inputs (list node-tldts-core-7.4.4))
    (home-page "https://github.com/remusao/tldts")
    (synopsis
     "Library to work against complex domain names, subdomains and URIs")
    (description
     "Library to work against complex domain names, subdomains and URIs.")
    (license license:expat)))

(define-public node-ghostery-adblocker-electron-2.18.0
  (package
    (name "node-ghostery-adblocker-electron")
    (version "2.18.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://git@github.com/ghostery/adblocker")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "06bfpb4a1kqzw3wbdlpyr6qr4zq1wsyfb1y82qk7yycmb5nmdi7a"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (inputs (list node-tldts-experimental-7.4.4
                  node-ghostery-adblocker-electron-preload-2.18.0
                  node-ghostery-adblocker-2.18.0))
    (home-page "https://github.com/ghostery/adblocker")
    (synopsis "Ghostery adblocker Electron wrapper")
    (description "Ghostery adblocker Electron wrapper.")
    (license license:mpl2.0)))

(define-public node-safer-buffer-2.1.2
  (package
    (name "node-safer-buffer")
    (version "2.1.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ChALkeR/safer-buffer")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "051by8jx2yq2jymcxpir89hsn9mnrsd1lmqs7v757336f6nmw408"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (home-page "https://github.com/ChALkeR/safer-buffer")
    (synopsis "Modern Buffer API polyfill without footguns")
    (description "Modern Buffer API polyfill without footguns.")
    (license license:expat)))

(define-public node-iconv-lite-0.6.3
  (package
    (name "node-iconv-lite")
    (version "0.6.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ashtuchkin/iconv-lite")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1s392ifqzihhk1qqfivhfkpw0fqh7mm0zgznr5v76xgkk1dr5zbm"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (inputs (list node-safer-buffer-2.1.2))
    (home-page "https://github.com/ashtuchkin/iconv-lite")
    (synopsis "Convert character encodings in pure javascript")
    (description "Convert character encodings in pure javascript.")
    (license license:expat)))

(define-public node-encoding-0.1.13
  (package
    (name "node-encoding")
    (version "0.1.13")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/andris9/encoding")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1xjvbdvqcrzs8168j8hd419i7c2z4cjncbsc1s99wf1m5aqimsf7"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (inputs (list node-iconv-lite-0.6.3))
    (home-page "https://github.com/andris9/encoding")
    (synopsis "Convert encodings, uses iconv-lite")
    (description "Convert encodings, uses iconv-lite.")
    (license license:expat)))

(define-public node-tr46-0.0.3
  (package
    (name "node-tr46")
    (version "0.0.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/Sebmaster/tr46.js")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0bq6y7qn458074j3f3xsnpqwhn3gj5s5v8xwjgnrk2bdq63v1b14"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (home-page "https://github.com/Sebmaster/tr46.js")
    (synopsis "An implementation of the Unicode TR46 spec")
    (description "An implementation of the Unicode TR46 spec.")
    (license license:expat)))

(define-public node-webidl-conversions-3.0.1
  (package
    (name "node-webidl-conversions")
    (version "3.0.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jsdom/webidl-conversions")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1m12fsk3i234c3rqvsqljf4l9wnz1bx057f8rrljvzsp6b1snqdn"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (home-page "https://github.com/jsdom/webidl-conversions")
    (synopsis
     "Implements the WebIDL algorithms for converting to and from JavaScript values")
    (description
     "This package implements the @code{WebIDL} algorithms for converting to and from
@code{JavaScript} values.")
    (license license:bsd-2)))

(define-public node-whatwg-url-5.0.0
  (package
    (name "node-whatwg-url")
    (version "5.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jsdom/whatwg-url")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0361rq1cr88qqsvw1bxvnrlc3rn8wbl2kynzp5v2bb4zzz0n97av"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (inputs (list node-webidl-conversions-3.0.1 node-tr46-0.0.3))
    (home-page "https://github.com/jsdom/whatwg-url")
    (synopsis
     "An implementation of the WHATWG URL Standard's URL API and parsing machinery")
    (description
     "An implementation of the WHATWG URL Standard's URL API and parsing machinery.")
    (license license:expat)))

(define-public node-node-fetch-2.7.0
  (package
    (name "node-node-fetch")
    (version "2.7.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/bitinn/node-fetch")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0nj5n90zrh8jyqy09qn6ih4hq8zbp8iwkyp4sq5c7006yw7l52p6"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (inputs (list node-whatwg-url-5.0.0 node-encoding-0.1.13))
    (home-page "https://github.com/bitinn/node-fetch")
    (synopsis "light-weight module that brings window.fetch to node.js")
    (description
     "This package provides a light-weight module that brings window.fetch to node.js.")
    (license license:expat)))

(define-public node-cross-fetch-4.1.0
  (package
    (name "node-cross-fetch")
    (version "4.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/lquixada/cross-fetch")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "18kldfavx72w75yb1y02divizkf5mbpir6cmhpfmklnhd1hnwkhh"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (inputs (list node-node-fetch-2.7.0))
    (home-page "https://github.com/lquixada/cross-fetch")
    (synopsis "Universal WHATWG Fetch API for Node, Browsers and React Native")
    (description
     "Universal WHATWG Fetch API for Node, Browsers and React Native.")
    (license license:expat)))

(define-public node-nan-2.28.0
  (package
    (name "node-nan")
    (version "2.28.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/nodejs/nan")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0m2lv281rg6164dywh3wjlcpk2as1s1y2gn28crqfspviqaaqdz2"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (home-page "https://github.com/nodejs/nan")
    (synopsis
     "Native Abstractions for Node.js: C++ header for Node 0.8 -> 26 compatibility")
    (description
     "Native Abstractions for Node.js: C++ header for Node 0.8 -> 26 compatibility.")
    (license license:expat)))

(define-public node-file-uri-to-path-1.0.0
  (package
    (name "node-file-uri-to-path")
    (version "1.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/TooTallNate/file-uri-to-path")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1qxmmx4iqf11y760bgq1wzr2w2d2mp7g0vdmis4zw80vkzjqyajr"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (home-page "https://github.com/TooTallNate/file-uri-to-path")
    (synopsis "Convert a file: URI to a file path")
    (description "Convert a file: URI to a file path.")
    (license license:expat)))

(define-public node-bindings-1.5.0
  (package
    (name "node-bindings")
    (version "1.5.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/TooTallNate/node-bindings")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "100gp6kpjvd4j1dqnp0sbjr1hqx5mz7r61q9qy527jyhk9mj47wk"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f))
    (inputs (list node-file-uri-to-path-1.0.0))
    (home-page "https://github.com/TooTallNate/node-bindings")
    (synopsis "Helper module for loading your native module's .node file")
    (description "Helper module for loading your native module's .node file.")
    (license license:expat)))

(define-public node-synchronous-socket-0.0.2
  (package
    (name "node-synchronous-socket")
    (version "0.0.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://registry.npmjs.org/synchronous-socket"
                           "/-/synchronous-socket-" version ".tgz"))
       (sha256
        (base32 "1ki52i8bsgrjgca8aaclx8llnv1b07w99qay0d2jgzsbzsqd20gg"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies)))))))
    (inputs (list node-nan-2.28.0 node-bindings-1.5.0))
    (home-page "https://www.npmjs.com/package/node-synchronous-socket")
    (synopsis "Synchronous socket interface for Unix domain sockets")
    (description "Synchronous socket interface for Unix domain sockets.")
    (license license:bsd-3)))

