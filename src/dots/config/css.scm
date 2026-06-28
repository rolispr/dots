;;; CSS from data. A stylesheet is a list of rules; each rule is
;;; (SELECTOR (PROPERTY . VALUE) ...). SELECTOR is a string (use a comma for
;;; shared selectors); VALUE is a string/number/symbol. Values are emitted
;;; verbatim -- supply your own quotes where the property needs them
;;; (e.g. font-family).

(define-module (dots config css)
  #:use-module (ice-9 match)
  #:export (css))

(define (scalar v)
  (cond ((string? v) v)
        ((number? v) (number->string v))
        ((symbol? v) (symbol->string v))
        (else (object->string v))))

(define (declaration pair)
  (string-append "  " (scalar (car pair)) ": " (scalar (cdr pair)) ";"))

(define (rule->string r)
  (match r
    ((selector . declarations)
     (string-append (scalar selector) " {\n"
                    (string-join (map declaration declarations) "\n")
                    "\n}"))))

(define (css rules)
  "Serialize RULES -- a list of (SELECTOR (PROPERTY . VALUE) ...) -- to CSS."
  (string-join (map rule->string rules) "\n\n"))
