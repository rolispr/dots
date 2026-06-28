;;; KDL from data, SXML-shaped. A node is
;;;   (NAME ARG ... (@ (PROP VALUE) ...) CHILD-NODE ...)
;;; ARGs are positional scalars (layout "us"); the optional (@ ...) carries
;;; inline properties (offset (@ (x 0) (y 5)) -> offset x=0 y=5); remaining
;;; lists are child nodes, emitted in a { } block. Strings are quoted,
;;; booleans true/false, numbers/symbols bare.

(define-module (dots config kdl)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)
  #:export (kdl))

(define (escape s)
  (string-join
   (map (lambda (ch)
          (case ch ((#\\) "\\\\") ((#\") "\\\"") (else (string ch))))
        (string->list s))
   ""))

(define (name->string k) (if (symbol? k) (symbol->string k) k))

(define (scalar v)
  (cond ((string? v)  (string-append "\"" (escape v) "\""))
        ((boolean? v) (if v "true" "false"))
        ((number? v)  (number->string v))
        ((symbol? v)  (symbol->string v))
        (else (object->string v))))

(define (props? x) (and (pair? x) (eq? (car x) '@)))
(define (child? x) (and (pair? x) (not (props? x))))

(define (node->string node indent)
  (match node
    ((name . rest)
     (let* ((args  (remove pair? rest))
            (props (let ((p (find props? rest))) (if p (cdr p) '())))
            (kids  (filter child? rest))
            (head  (string-append
                    indent (name->string name)
                    (string-join (map (lambda (a) (string-append " " (scalar a))) args) "")
                    (string-join (map (lambda (p) (string-append " " (name->string (car p))
                                                                 "=" (scalar (cadr p))))
                                      props)
                                 ""))))
       (if (null? kids)
           head
           (string-append head " {\n"
                          (string-join (map (lambda (k) (node->string k (string-append indent "  ")))
                                            kids)
                                       "\n")
                          "\n" indent "}"))))))

(define (kdl nodes)
  "Serialize NODES -- a list of SXML-shaped KDL nodes -- to a KDL string."
  (string-join (map (lambda (n) (node->string n "")) nodes) "\n"))
