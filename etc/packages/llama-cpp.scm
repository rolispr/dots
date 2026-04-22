(define-module (etc packages llama-cpp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (gnu packages machine-learning))

(define %tag "b8855")

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
    (arguments
     (substitute-keyword-arguments (package-arguments llama-cpp)
       ((#:tests? _ #f) #f)
       ((#:configure-flags flags)
        #~(cons "-DLLAMA_BUILD_TESTS=OFF" #$flags))))))
