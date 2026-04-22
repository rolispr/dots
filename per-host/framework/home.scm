;;; Framework home overrides — consumed by (home-setting 'key).
;;; Framework is the LLM host, so the llama-cpp server lives here.

(define-module (home-overrides)
  #:use-module (etc packages llama-cpp)
  #:export (override-extra-packages))

(define override-extra-packages
  (list llama-cpp-latest))
