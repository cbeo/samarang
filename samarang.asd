;;;; samarang.asd

(asdf:defsystem #:samarang
  :description "Describe samarang here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (:gtwiwtg :lambda-tools)
  :components ((:file "package")
               (:file "samarang")))
