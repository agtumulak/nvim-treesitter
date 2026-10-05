((doctest_block) @injection.content
  (#set! injection.language "python"))

; Directives whose arguments, options, and content can be parsed as a single
; RST body. An exception is made for cases where the directive line continues
; onto the next line. Missing indentation for the first line must be handled
; separately in the next two patterns.
((directive
  name: (type) @_type
  body: (body) @injection.content)
  (#any-of? @_type
    "attention" "caution" "danger" "error" "hint" "important" "note" "tip" "warning" "admonition"
    "line-block" "parsed-literal" "epigraph" "highlights" "pull-quote" "compound" "header" "footer"
    "meta" "replace" "topic" "sidebar" "table" "list-table")
  ; Unless text on the directive line continues onto the next line (see below)
  (#not-lua-match? @injection.content "^%S[^\n]*\n[ \t]*%S")
  (#set! injection.language "rst")
  (#set! injection.include-children))

; Case where the directive line continues onto the next line. This handles the
; first line.
((directive
  name: (type) @_type
  body: (body
    (arguments) @injection.content) @_body)
  (#any-of? @_type
    "attention" "caution" "danger" "error" "hint" "important" "note" "tip" "warning" "admonition"
    "line-block" "parsed-literal" "epigraph" "highlights" "pull-quote" "compound" "header" "footer"
    "meta" "replace" "topic" "sidebar" "table" "list-table")
  (#lua-match? @_body "^%S[^\n]*\n[ \t]*%S")
  (#set! injection.language "rst"))

; Case where the directive line continues onto the next line. This handles all
; content lines below it.
((directive
  name: (type) @_type
  body: (body
    (content) @injection.content) @_body)
  (#any-of? @_type
    "attention" "caution" "danger" "error" "hint" "important" "note" "tip" "warning" "admonition"
    "line-block" "parsed-literal" "epigraph" "highlights" "pull-quote" "compound" "header" "footer"
    "meta" "replace" "topic" "sidebar" "table" "list-table")
  (#lua-match? @_body "^%S[^\n]*\n[ \t]*%S")
  ; Skip the content if its first paragraph also wraps; it starts mid-line too
  (#not-lua-match? @injection.content "^[^\n]*\n[ \t]*%S")
  (#set! injection.language "rst"))

; Directives whose contents can be parsed as RST, but arguments are not RST.
((directive
  name: (type) @_type
  body: (body
    (content) @injection.content))
  (#set! injection.language "rst")
  (#any-of? @_type "figure" "container" "class" "role" "restructuredtext-test-directive"))

; Special directives
((directive
  name: (type) @_type
  body: (body
    (arguments) @injection.language
    (content) @injection.content))
  (#any-of? @_type "raw" "code" "code-block" "sourcecode"))

((directive
  name: (type) @_type
  body: (body
    (content) @injection.content))
  (#set! injection.language "latex")
  (#eq? @_type "math"))

((directive
  name: (type) @_type
  body: (body
    (content) @injection.content))
  (#set! injection.language "csv")
  (#eq? @_type "csv-table"))

; Special roles - prefix
((interpreted_text
  (role) @_role
  "interpreted_text" @injection.content)
  (#eq? @_role ":math:")
  (#set! injection.language "latex"))

; Special roles - suffix
((interpreted_text
  "interpreted_text" @injection.content
  (role) @_role)
  (#eq? @_role ":math:")
  (#set! injection.language "latex"))

((comment) @injection.content
  (#set! injection.language "comment"))
