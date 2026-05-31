(define-module (etc services lgeh)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu services networking)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services web)
  #:use-module (gnu system shadow)
  #:use-module (guix gexp)
  #:export (lgeh-services))

;;; Phase 2 minimal: nginx serving static lgeh client on :80 of framework.
;;; No TLS, no domain, no app server yet — those come when domain is picked
;;; and Phase 3 produces a server binary.
;;;
;;; Headers: COOP/COEP for Hoot WASM threading prereq.

(define %lgeh-account
  (user-account
   (name "lgeh")
   (group "users")
   (system? #t)
   (comment "lgeh game server")
   (home-directory "/srv/lgeh")
   (create-home-directory? #t)
   (shell (file-append (specification->package "shadow") "/sbin/nologin"))))

(define* (lgeh-services #:key
                        (web-root "/srv/lgeh/static")
                        (listen-port 80))
  (list
   ;; Account for /srv/lgeh ownership (pre-creates the home dir)
   (simple-service 'lgeh-account
                   account-service-type
                   (list %lgeh-account))
   ;; nginx serving static client
   (service nginx-service-type
            (nginx-configuration
             (server-blocks
              (list
               (nginx-server-configuration
                (server-name (list "_"))
                (listen (list (number->string listen-port)))
                (root web-root)
                (raw-content
                 (list
                  "add_header Cross-Origin-Opener-Policy \"same-origin\" always;"
                  "add_header Cross-Origin-Embedder-Policy \"require-corp\" always;"
                  ;; Override the .wasm extension via location instead of a
                  ;; types {} block (which would replace the inherited
                  ;; mime.types map and cause everything else to be served
                  ;; as text/plain).
                  ))
                (locations
                 (list
                  (nginx-location-configuration
                   (uri "~ \\.wasm$")
                   (body
                    (list "default_type application/wasm;")))
                  (nginx-location-configuration
                   (uri "/")
                   (body
                    (list
                     "try_files $uri $uri/ /index.html;"))))))))))))
