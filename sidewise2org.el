;;; sidewise2org.el --- Convert an export from the Sidewise Chrome plugin to org-links.

;; Copyright (C) 2017 Per Weijnitz

;; Author: Per Weijnitz <per.weijnitz@gmail.com>
;; Version: 0.1
;; Package-Requires: ((json "1.2"))
;; Keywords: sidewise, org, convert
;; URL: https://github.com/perweij/sidewise2org
;; Created: 20 Aug 2017
;; License: GPLv3

;; This file is not part of GNU Emacs.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.


;;; Commentary:

;; Users of the Sidewise Chrome plugin (http://www.sidewise.info/) may want to import
;; the current Sidewise link state into an org-file.
;;
;; Usage:
;;   1. Click the Sidewise toolbar icon, and perform an export to a file.
;;   2. Call pw/sidewise2org with the file as argument, i e:
;;      (pw/sidewise2org "/tmp/sidewise_export.json")
;;   3. The result is shown in a temporary buffer, that you may
;;      save to disk.

(require 'json)


(defun pw/sidewise2org (file)
  (let* ((json-object-type 'hash-table)
         (json-array-type 'list)
         (json-key-type 'string)
         (json (json-read-file file))
         (pagetree (gethash "pageTree" (gethash "chromeStorage" json)))
         (target-buffer-name "*sidewise.org*"))
    (with-output-to-temp-buffer target-buffer-name
      (switch-to-buffer target-buffer-name)
      (pw/sidewise2org-rec pagetree 0)
      (org-mode))))


(defun pw/sidewise2org-rec (pagetree sublevel)
  (mapc (lambda (x)
          (if (and (gethash "title" x) (gethash "url" x))
              (progn
                (dotimes (number sublevel nil)
                  (princ "*"))
                (princ " ")
                (org-insert-link nil (gethash "url" x) (gethash "title" x))))
                (princ "\n")
          (if (gethash "children" x)
              (pw/sidewise2org-rec (gethash "children" x) (+ sublevel 1)))
          ) pagetree))


