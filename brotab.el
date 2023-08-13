;;; brotab.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023 Vivien Moriarty
;;
;; Author: Vivien Moriarty <goyal.rohan.03@gmail.com>
;; Maintainer: Vivien Moriarty <goyal.rohan.03@gmail.com>
;; Created: August 13, 2023
;; Modified: August 13, 2023
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex tools unix vc wp
;; Homepage: https://github.com/VivianWilde/brotab.el
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;  Use completing-read to interface with brotab.
;;  The main entry point is `brotab`, which opens a completing-read of your open tabs.
;;  If you enter a string not matching a tab, it will google that string for you.
;;
;;; Code:

(require 's)
(require 'ht)
(require 'dash)

(defun bt-parse-line (line)
  (s-split "	" line))


(setq bt-field-to-index
      (ht ("id" 0) ("title" 1) ("name" 1) ("url" 2)))

(defun bt-get-field (field line)
  (nth (ht-get bt-field-to-index field) (bt-parse-line line)))

(defalias 'bt-get-id (-partial 'bt-get-field "id"))
(defalias 'bt-get-url (-partial 'bt-get-field "url"))
(defalias 'bt-get-name (-partial 'bt-get-field "name"))

(defun bt-shell-command-to-string (command)
  "Execute shell command COMMAND and return its output as a string."
  (with-output-to-string
    (with-current-buffer standard-output
      (shell-command command t))))



(defun brotab ()
  (interactive)
  (let* (
         (out (bt-shell-command-to-string "bt list"))
         (name-map (ht-create))
         (ht-args (-each (s-split hard-newline out) (lambda (line) (ht-set name-map (bt-get-name line) (bt-get-id line)) )) )
         (chosen-name (completing-read "Select tab: " name-map nil nil))
         )
    (if (-contains? (ht-keys name-map) chosen-name )
        (shell-command (s-concat "bt activate " (ht-get name-map chosen-name)))
      (shell-command (s-concat "echo ''|bt new 'a' " chosen-name)))))

(provide 'brotab)
;;; brotab.el ends here
