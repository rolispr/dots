(define-module (etc packages llama-cpp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (gnu packages machine-learning))

(define %tag "b8855")

;; Upstream Guix llama-cpp links against an external ggml package (currently
;; 0.9.8). Bleeding-edge llama.cpp tags ship llama/ggml as a co-evolving pair
;; — newer llama-model.cpp references ggml symbols (GGML_BACKEND_SPLIT_AXIS_*,
;; GGML_TYPE_Q1_0, ggml_backend_meta_split_state) that don't exist in the
;; pinned external ggml. Drop the system-ggml glue and use the vendored copy.
(define-public llama-cpp-latest
  (package
    (inherit llama-cpp)
    (name "llama-cpp")
    (version (string-append "0.0.0-" %tag))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ggml-org/llama.cpp")
             (commit %tag)))
       (file-name (git-file-name "llama-cpp" %tag))
       (sha256
        (base32 "0wkssfz65yw0z78bz1hbbn9fyja0ksqrkpk01jcjyvrf5wc39xrs"))))
    (inputs
     (modify-inputs (package-inputs llama-cpp)
       (delete "ggml")))
    (arguments
     (substitute-keyword-arguments (package-arguments llama-cpp)
       ((#:tests? _ #f) #f)
       ((#:configure-flags _)
        #~(list "-DBUILD_SHARED_LIBS=ON"
                "-DLLAMA_USE_SYSTEM_GGML=OFF"
                "-DLLAMA_BUILD_TESTS=OFF"))))))
