;;; slaythespire.el -- A pacakge to edit Slay the Spire save files -*- lexical-binding: t; -*-

;; Copyright (C) 2023  Thanh Vuong

;; Author: Thanh Vuong <thanhvg@gmail.com>
;; URL: https://github.com/thanhvg/emacs-slaythespire-editor
;; Package-Requires: ((emacs "28.1") (json "1.4")) 
;; Version: 0.0.1

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
;; This package can edit Slay the Spire save files.
;; an org buffer. Almost everything works. Features that are not supported are
;; account related features. You cannot add comment, downvote or upvote.

;;; Dependencies
;;  emacs 28 and later

;;; Commands
;; slaythespire-open-save-file: open save file and show its decryption in a json buffer
;; slaythespire-save (C-c C-c): save the current json buffer to the save file.
;; slaythespire-reload (C-c C-r): reload the save file into the current json buffer.


(require 'json)

(defvar slaythespire-key "key"
  "Encryption key.")

(defvar-local slaythespire--save-file nil)

(defun slaythespire--xor-str-against-key (str key)
  (string-join (seq-map-indexed
                (lambda (a i)
                  (char-to-string (logxor a
                                          (seq-elt key (% i (length key))))))
                str)))

(defun slaythespire--read-file-content (file)
  "Read the content of FILE into a string."
  (with-temp-buffer
    (insert-file-contents file)
    (buffer-string)))

(defun slaythespire--decode (str)
  "return a decoded string"
  (slaythespire--xor-str-against-key (base64-decode-string str) slaythespire-key))

(defun slaythespire--encode (json)
  (base64-encode-string (slaythespire--xor-str-against-key json slaythespire-key)))

(defun slaythespire-open-save-file (file)
  "Open Slay The Spire save file."
  (interactive "fEnter file path: ")
  (let ((buffer (get-buffer-create (format "*%s*" (file-name-nondirectory file)))))
    (with-current-buffer buffer
      (erase-buffer)
      (insert (slaythespire--decode (slaythespire--read-file-content file)))
      (json-mode)
      (setq-local slaythespire--save-file file)
      (slaythespire-mode))
    (switch-to-buffer buffer)))

(defun slaythespire-save ()
  "Save change to file."
  (interactive)
  (let ((str (buffer-string)))
    (with-temp-file slaythespire--save-file
      (insert (slaythespire--encode str))))
  (message "Change has been saved to %s" slaythespire--save-file))

(defun slaythespire-reload ()
  "Reload change from save file."
  (interactive)
  (slaythespire-open-save-file slaythespire--save-file)
  (message "Reloaded data from %s" slaythespire--save-file))

(define-minor-mode slaythespire-mode
  "Minor mode for Slay The Spire editor."
  ;; The initial value.
  :init-value nil
  ;; The minor mode bindings.
  :keymap
  (list (cons (kbd "C-c C-c") 'slaythespire-save)
        (cons (kbd "C-c C-r") 'slaythespire-reload)))

(provide 'slaythespire)
