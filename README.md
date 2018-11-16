# yank-temp

This package provides commands to create a new temporary buffer from
some existing text (e.g. the clipboard or region).

## Revert Behavior

The intial text is treated as the "revert point" for the buffer: you
can make changes and then restore the initial text using the standard
`revert-buffer` command.

## Init Hook

Use the `yank-temp-initialized-hook` to take some action when a new
temp buffer is initialized.

For example: define a hydra with frequently-usde modes or commands,
and have it pop up for a few seconds after a yank-temp buffer is
created:

``` emacs-lisp
  (defhydra hydra-setup-yank-temp (:color blue :timeout 3 :post (yank-temp-set-revert-point))
    ("l" lisp-interaction-mode "lisp")
    ("j" (progn (js-mode) (json-pretty-print-buffer)) "json")
    ("x" (progn (nxml-mode)) "xml")
    ("t" (progn (turn-on-orgtbl) (org-table-convert-region (point-min) (point-max) nil)) "table"))

  (add-hook 'yank-temp-initialized-hook #'hydra-setup-yank-temp/body)
```
