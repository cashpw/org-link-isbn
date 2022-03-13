;;; org-link-isbn.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 Cash Weaver
;;
;; Author: Cash Weaver <cashbweaver@gmail.com>
;; Maintainer: Cash Weaver <cashbweaver@gmail.com>
;; Created: March 13, 2022
;; Modified: March 13, 2022
;; Version: 0.0.1
;; Homepage: https://github.com/cashweaver/org-link-isbn
;; Package-Requires: ((emacs "27.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  This library provides an isbn link in org-mode.
;;
;;; Code:

(require 'ol)
(require 's)

(defcustom org-link-isbn-url-base
  "https://books.google.com/books?vid=ISBN"
  "The URL of Isbn."
  :group 'org-link-follow
  :type 'string
  :safe #'stringp)

(defun org-link-isbn--build-uri (path)
  "Return a uri for the provided PATH."
  (url-encode-url
   (s-format
    "${base-url}${path}"
    'aget
    `(("base-url" . ,org-link-isbn-url-base)
      ("path" . ,path)))))

(defun org-link-isbn-open (path arg)
  "Opens an isbn type link."
  (let ((uri
         (org-link-isbn--build-uri
          path)))
    (browse-url
     uri
     arg)))

(defun org-link-isbn-export (path desc backend info)
  "Export an isbn link.

- PATH: the name.
- DESC: the description of the link, or nil.
- BACKEND: a symbol representing the backend used for export.
- INFO: a a plist containing the export parameters."
  (let ((uri
         (org-link-isbn--build-uri
          path)))
    (pcase backend
      (`md
       (format "[%s](%s)" (or desc uri) uri))
      (`html
       (format "<a href=\"%s\">%s</a>" uri (or desc uri)))
      (`latex
       (if desc (format "\\href{%s}{%s}" uri desc)
         (format "\\url{%s}" uri)))
      (`ascii
       (if (not desc) (format "<%s>" uri)
         (concat (format "[%s]" desc)
                 (and (not (plist-get info :ascii-links-to-notes))
                      (format " (<%s>)" uri)))))
      (`texinfo
       (if (not desc) (format "@uref{%s}" uri)
         (format "@uref{%s, %s}" uri desc)))
      (_ uri))))

(org-link-set-parameters
 "isbn"
 :follow #'org-link-isbn-open
 :export #'org-link-isbn-export)


(provide 'org-link-isbn)
;;; org-link-isbn.el ends here
