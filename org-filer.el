;;; org-filer --- org-filer
;;; Commentary:
;;; Code:
(require 'org)
(require 'org-agenda)
(require 'f)

(defgroup org-filer nil
  "org-filer"
  :prefix "org-filer"
  :group 'org)

(defcustom org-filer-file nil
  "Path to filer file."
  :group 'org-filer
  :type 'string)

(defcustom org-filer-scanner-cmd "scanimage > '%s'"
  "Command invoked to scan file for filing."
  :group 'org-filer
  :risky t
  :type 'string)

(defcustom org-filer-file-control-str ""
  "Control string for the name of the file for filing."
  :group 'org-filer)

(defcustom org-filer-merge-pdf-cmd "convert *.pnm '%s'"
  "Command invoked to merge scanned images into a single pdf."
  :group 'org-filer
  :risky t)

(defcustom org-filer-auto-commit t
  "Automatically run git commit after filing a new file."
  :group 'org-filer)

(defcustom org-filer-auto-commit-message ""
  "Control for auto commit messages."
  :group 'org-filer)

(defcustom org-filer-auto-commit-pre-command nil
  "Command to run before an auto commit."
  :group 'org-filer
  :risky t)

(defcustom org-filer-auto-commit-post-command nil
  "Command to run after an auto commit."
  :group 'org-filer
  :risky t)

(defun get-new-dir-name (path)
  "Return an unused random directory name in PATH."
  (let ((rand-str (get-random-string 6)))
    (if (not (f-directory? (f-join path rand-str)))
        (f-join path rand-str)
      (get-random-dir path))))

(defmacro with-temporary-dir (root-dir &rest body)
  "Create a temporary directory in ROOT-DIR and execute BODY in pwd.
Removes directory and its contents at the end of execution.
Returns the value of body."
  (let ((olddir default-directory)
        (dir (get-new-dir-name root-dir)))
    `(unwind-protect
         (progn
           (make-directory ,dir)
           (cd ,dir)
           ,@body)
       (progn (cd ,olddir)
              (when (file-exists-p ,dir)
               (delete-directory ,dir t))))))

(defun get-random-string (length)
  "Return a random string of letters and number of size LENGTH."
  (let ((chars "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"))
    (if (= length 1)
        (string (elt chars (random (length chars))))
      (concat (string (elt chars (random (length chars))))
              (get-random-string (1- length))))))

(defun org-filer-search (tag-string)
  "Search org-filer-file with TAG-STRING."
  (let ((org-agenda-files org-filer-file))
    (org-tags-view nil tag-string)))

(defun org-filer-scan-file (file-name)
  "Use an attached scanner to scan multiple pages to FILE-NAME."
  (interactive "F")
  (let ((page-num 0))
    (with-temporary-dir "/tmp"
      (while (org-filer-continue-scan? page-num)
        (org-filer-scan-page
         (f-join default-directory
                 (format "%s%d.pnm" (f-base file-name) page-num)))
        (setf page-num (1+ page-num)))
      (org-filer-merge-pages-to-pdf default-directory
                                    (f-join (f-parent default-directory) file-name)))))

(defun org-filer-continue-scan? (page-num)
  (if (= page-num 0)
      (y-or-n-p "Ready to scan first page? ")
    (y-or-n-p "Ready to scan next page? ")))

(defun org-filer-scan-page (page-file)
  "Use an attached scanner to scan a page to PAGE-FILE."
  (interactive "F")
  (message "Scanning %s... " page-file)
  (let ((retval (call-process-shell-command
                 (format org-filer-scanner-cmd page-file))))
    (message "Finished scanning %s." page-file)
    (if (= retval 0) t nil)))

(defun org-filer-merge-pages-to-pdf (image-path pdf-file)
  "Merge all .PNM files in IMAGE-PATH into PDF-FILE."
  (message "Merging pages into %s... " pdf-file)
  (call-process-shell-command
   (format org-filer-merge-pdf-cmd pdf-file)))

(provide 'org-filer)
;;; org-filer.el ends here
