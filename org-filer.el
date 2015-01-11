;;; org-filer --- org-filer
;;; Commentary:
;;; Code:
(require 'org)
(require 'org-agenda)

(defgroup org-filer nil
  "org-filer"
  :prefix "org-filer"
  :group 'org)

(defcustom org-filer-file "Path(s) to filer file."
  :group 'org-filer
  nil)

(defcustom org-filer-scanner-cmd
  "Command invoked to scan file for filing."
  :group 'org-filer
  :risky t
  "scanimage")

(defcustom org-filer-file-control-str
  "Control string for the name of the file for filing."
  :group 'org-filer
  "")

(defcustom org-filer-auto-commit
  "Automatically run git commit after filing a new file."
  :group 'org-filer
  t)

(defcustom org-filer-auto-commit-message
  "Control for auto commit messages"
  :group 'org-filer
  "")

(defcustom org-filer-auto-commit-pre-command
  "Command to run before an auto commit."
  :group 'org-filer
  :risky t
  nil)

(defcustom org-filer-auto-commit-post-command
  "Command to run after an auto commit."
  :group 'org-filer
  :risky t
  nil)

(defun org-filer-search (tag-string)
  "Search org-filer-file with TAG-STRING."
  (let ((org-agenda-files org-filer-file))
    (org-tags-view nil tag-string)))

(defun org-filer-capture-scaned-file ()
  "Capture a new file entry,"
  )

(provide 'org-filer)
;;; org-filer.el ends here
