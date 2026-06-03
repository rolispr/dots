(define-module (etc packages stb)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system copy)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages))

(define-public stb
  (package
    (name "stb")
    (version "0.0.0-1.31c1ad3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/nothings/stb")
             (commit "31c1ad37456438565541f4919958214b6e762fb4")))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0zdsn985zxg9lg6bjp6wdxywgrwygkj46sq557j11vipa198sv4v"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("stb_c_lexer.h"               "include/stb/")
          ("stb_connected_components.h"  "include/stb/")
          ("stb_divide.h"                "include/stb/")
          ("stb_ds.h"                    "include/stb/")
          ("stb_dxt.h"                   "include/stb/")
          ("stb_easy_font.h"             "include/stb/")
          ("stb_herringbone_wang_tile.h" "include/stb/")
          ("stb_hexwave.h"               "include/stb/")
          ("stb_image.h"                 "include/stb/")
          ("stb_image_write.h"           "include/stb/")
          ("stb_include.h"               "include/stb/")
          ("stb_leakcheck.h"             "include/stb/")
          ("stb_perlin.h"                "include/stb/")
          ("stb_rect_pack.h"             "include/stb/")
          ("stb_sprintf.h"               "include/stb/")
          ("stb_textedit.h"              "include/stb/")
          ("stb_tilemap_editor.h"        "include/stb/")
          ("stb_truetype.h"              "include/stb/")
          ("stb_voxel_render.h"          "include/stb/"))))
    (home-page "https://github.com/nothings/stb")
    (synopsis "Single-file public-domain C libraries")
    (description "Collection of single-file header-only C libraries by Sean
Barrett and contributors.  Includes stb_truetype (TrueType glyph
rasteriser), stb_image (PNG/JPEG/BMP/TGA/PSD/HDR decode), stb_image_write
(PNG/JPG/BMP/TGA encode), stb_rect_pack (rectangle packing for atlases),
stb_textedit (text-edit state machine), and others.  Each header is
included normally and its implementation is enabled in exactly one
translation unit by defining the per-header STB_*_IMPLEMENTATION macro
before the include.")
    (license (list license:expat license:public-domain))))
