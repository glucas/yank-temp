;;; yank-temp.el --- Copy to temporary buffers.  -*- lexical-binding: t; -*-

;; Copyright (C) 2015 Greg Lucas

;; Author:  <greg@glucas.net>
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;

;; Create temporary buffers with some initial yanked content.
;; See the README for more details.

;;; Code:

(defvar yank-temp-initialized-hook)

(defun yank-temp-new ()
  "Create a new temporary buffer."
  (generate-new-buffer "temp"))

(defmacro yank-temp-init (&rest body)
  "Create a new temporary buffer and execute BODY to set the initial content."
  (declare (indent defun) (debug t))
  `(progn
     (switch-to-buffer (yank-temp-new))
     ,@body
     (yank-temp-set-revert-point)
     (run-hooks 'yank-temp-initialized-hook)))

(defun yank-temp-with-text (text)
  "Insert TEXT in to a new temporary buffer."
  (interactive "sText: ")
  (yank-temp-init (insert text)))

(defun yank-temp-from-clipboard ()
  "Insert the clipboard contents or last killed text in to a new temporary buffer."
  (interactive)
  (yank-temp-init (clipboard-yank)))

(defun yank-temp-from-region (start end)
  "Copy the current region to a temporary buffer.
When called non-interactively, arguments START and END specify
the region to be copied."
(interactive "r")
(let ((oldbuf (current-buffer))
      (mode major-mode))
  (yank-temp-init
    (insert-buffer-substring oldbuf start end)
    (funcall (symbol-function mode)))))

(defun yank-temp-undo-all (&optional ignore-auto noconfirm)
  "Undo all edits in the current buffer.
With a prefix argument, do not prompt for confirmation.

This function can be used as a `revert-buffer-function'.  The
argument IGNORE-AUTO is ignored if specified.  Optional second
argument NOCONFIRM means don't ask for confirmation."
  (interactive)
  (or ignore-auto)                      ; silence compiler
  (if (or noconfirm
	  current-prefix-arg
          (not (buffer-modified-p))
          (yes-or-no-p (format "Undo all edits? ")))
      (progn
        (when (buffer-modified-p)
          (undo))
        (while (buffer-modified-p)
          (undo-more 1)))))

(defun yank-temp-set-revert-point ()
  "Save the current buffer state for the next call to `revert-buffer'.
Marks the current buffer unmodified, clears the buffer undo list,
and registers a custom `revert-buffer-function'."
  (interactive)
  (unless (buffer-file-name)
    (setq-local revert-buffer-function #'yank-temp-undo-all)
    (setq buffer-undo-list nil)
    (set-buffer-modified-p nil)))

(provide 'yank-temp)
;;; yank-temp.el ends here
