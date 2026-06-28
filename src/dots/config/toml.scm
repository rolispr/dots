;;; TOML from data. Input is a list of tables; each table is
;;; (NAME (KEY . VALUE) ...). NAME may be a dotted symbol (colors.primary).
;;; Strings are quoted, numbers/booleans typed, symbols emitted bare.

(define-module (dots config toml)
  #:use-module (ice-9 match)
  #:export (toml))

(define (escape s)
  (string-join
   (map (lambda (ch)
          (case ch ((#\\) "\\\\") ((#\") "\\\"") (else (string ch))))
        (string->list s))
   ""))

(define (name->string k) (if (symbol? k) (symbol->string k) k))

(define (value v)
  (cond ((string? v)  (string-append "\"" (escape v) "\""))
        ((boolean? v) (if v "true" "false"))
        ((number? v)  (number->string v))
        ((symbol? v)  (symbol->string v))
        (else (object->string v))))

(define (table->string t)
  (match t
    ((name . pairs)
     (string-append
      "[" (name->string name) "]\n"
      (string-join
       (map (lambda (kv)
              (string-append (name->string (car kv)) " = " (value (cdr kv))))
            pairs)
       "\n")))))

(define (toml tables)
  "Serialize TABLES -- a list of (NAME (KEY . VALUE) ...) -- to TOML."
  (string-join (map table->string tables) "\n\n"))
