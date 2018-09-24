;;;; mnas-vse-gost.asd

(defsystem #:mnas-vse-gost
  :description "Describe mnas-vse-gost here"
  :author "Nick Matvyeyev <mnasoft@gmail.com>"
  :license "GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007 or later"  
  :serial t
  :depends-on (#:postmodern #:hunchentoot #:cl-who #:mnas-string #:mnas-site #:mnas-passwd #:mnas-path #:mnas-site-template)
  :components ((:file "package")
;;;	       (:file "mnas-vse-gost-audio")
               (:file "mnas-vse-gost")
	       ))

