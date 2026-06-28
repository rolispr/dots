;;; Arraniz home overrides — consumed by (home-setting 'key).
;;; No llama-cpp (framework is the LLM host). Nothing overridden here;
;;; module exists so (resolve-module '(home-overrides)) succeeds.

(define-module (dots hosts arraniz home)
  #:export ())
