(define-module (etc services messaging-extras)
  #:use-module (gnu services messaging)
  #:use-module (guix records)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)
  #:export (muc-component-configuration
            make-muc-component-configuration
            muc-component-configuration?
            muc-component-configuration-domain
            muc-component-configuration-name
            muc-component-configuration-restrict?
            muc-component-configuration-muc-mam?
            muc-component-configuration-max-history
            muc-component-configuration-extra-modules
            muc-component-configuration-extra-config

            http-file-share-component-configuration
            make-http-file-share-component-configuration
            http-file-share-component-configuration?
            http-file-share-component-configuration-domain
            http-file-share-component-configuration-size-limit
            http-file-share-component-configuration-daily-quota
            http-file-share-component-configuration-expire-after
            http-file-share-component-configuration-extra-config

            muc->int-component
            http-file-share->int-component
            components->int-components

            serialize-muc-component
            serialize-http-file-share-component))

(define-record-type* <muc-component-configuration>
  muc-component-configuration make-muc-component-configuration
  muc-component-configuration?
  (domain                  muc-component-configuration-domain)
  (name                    muc-component-configuration-name
                           (default "Chatrooms"))
  (restrict-room-creation? muc-component-configuration-restrict?
                           (default #f))
  (muc-mam?                muc-component-configuration-muc-mam?
                           (default #t))
  (max-history-messages    muc-component-configuration-max-history
                           (default 50))
  (extra-modules           muc-component-configuration-extra-modules
                           (default '()))
  (extra-config            muc-component-configuration-extra-config
                           (default '())))

(define-record-type* <http-file-share-component-configuration>
  http-file-share-component-configuration
  make-http-file-share-component-configuration
  http-file-share-component-configuration?
  (domain         http-file-share-component-configuration-domain)
  (size-limit     http-file-share-component-configuration-size-limit
                  (default (* 100 1024 1024)))
  (daily-quota    http-file-share-component-configuration-daily-quota
                  (default (* 500 1024 1024)))
  (expire-after   http-file-share-component-configuration-expire-after
                  (default (* 7 24 3600)))
  (extra-config   http-file-share-component-configuration-extra-config
                  (default '())))

(define (muc->int-component c)
  (let* ((domain        (muc-component-configuration-domain c))
         (name          (muc-component-configuration-name c))
         (restrict?     (muc-component-configuration-restrict? c))
         (mam?          (muc-component-configuration-muc-mam? c))
         (max-history   (muc-component-configuration-max-history c))
         (extra-modules (muc-component-configuration-extra-modules c))
         (extra-config  (muc-component-configuration-extra-config c))
         (modules       (if mam?
                            (cons "muc_mam" extra-modules)
                            extra-modules))
         (raw-lines     (append
                         (if (null? modules)
                             '()
                             (list
                              (string-append
                               "modules_enabled = { "
                               (string-join
                                (map (lambda (m)
                                       (string-append "\"" m "\""))
                                     modules)
                                ", ")
                               " }")))
                         extra-config)))
    (int-component-configuration
     (hostname domain)
     (plugin "muc")
     (mod-muc (mod-muc-configuration
               (name name)
               (restrict-room-creation restrict?)
               (max-history-messages max-history)))
     (raw-content (string-join raw-lines "\n")))))

(define (http-file-share->int-component c)
  (let ((domain       (http-file-share-component-configuration-domain c))
        (size-limit   (http-file-share-component-configuration-size-limit c))
        (daily-quota  (http-file-share-component-configuration-daily-quota c))
        (expire-after (http-file-share-component-configuration-expire-after c))
        (extra-config (http-file-share-component-configuration-extra-config c)))
    (int-component-configuration
     (hostname domain)
     (plugin "http_file_share")
     (raw-content
      (string-join
       (append
        (list
         (string-append "http_file_share_size_limit = "
                        (number->string size-limit))
         (string-append "http_file_share_daily_quota = "
                        (number->string daily-quota))
         (string-append "http_file_share_expires_after = "
                        (number->string expire-after)))
        extra-config)
       "\n")))))

(define (components->int-components components)
  (map (lambda (c)
         (cond
          ((muc-component-configuration? c)
           (muc->int-component c))
          ((http-file-share-component-configuration? c)
           (http-file-share->int-component c))
          (else
           (error "Unknown component type" c))))
       components))

(define (serialize-muc-component config)
  (let ((domain        (muc-component-configuration-domain config))
        (name          (muc-component-configuration-name config))
        (restrict?     (muc-component-configuration-restrict? config))
        (mam?          (muc-component-configuration-muc-mam? config))
        (max-history   (muc-component-configuration-max-history config))
        (extra-modules (muc-component-configuration-extra-modules config))
        (extra-config  (muc-component-configuration-extra-config config)))
    (string-append
     "Component \"" domain "\" \"muc\"\n"
     "    name = \"" name "\"\n"
     "    restrict_room_creation = "
     (if restrict? "true" "false") "\n"
     (if mam?
         "    modules_enabled = { \"muc_mam\""
         "    modules_enabled = { ")
     (string-join (map (lambda (m) (string-append ", \"" m "\""))
                       extra-modules)
                  "")
     " }\n"
     "    max_history_messages = "
     (number->string max-history) "\n"
     (string-join extra-config "\n")
     "\n")))

(define (serialize-http-file-share-component config)
  (string-append
   "Component \""
   (http-file-share-component-configuration-domain config)
   "\" \"http_file_share\"\n"
   "    http_file_share_size_limit = "
   (number->string
    (http-file-share-component-configuration-size-limit config))
   "\n"
   "    http_file_share_daily_quota = "
   (number->string
    (http-file-share-component-configuration-daily-quota config))
   "\n"
   "    http_file_share_expires_after = "
   (number->string
    (http-file-share-component-configuration-expire-after config))
   "\n"
   (string-join
    (http-file-share-component-configuration-extra-config config)
    "\n")
   "\n"))
