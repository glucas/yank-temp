# yank-temp
Yank text in to a new temporary buffer.

This package provides commands to create a new temporary buffer from
some existing text (e.g. the clipboard or region). 

## Revert Behavior

The intial text is treated as the "revert point" for the buffer: you
can make changes and then restore the initial text using the standard
`revert-buffer' command.

## Init Hook

Use the `yank-temp-initialized-hook` to tkae some action when a new
temp buffer is initialized.

For example, you can define a hydra with some common modes or
commands, and have it pop up for a few seconds:

``` emacs-lisp
  (defhydra hydra-setup-temp-buffer (:color blue :timeout 3 :post (temp-buffer-set-revert-point))
    ("l" lisp-interaction-mode "lisp")
    ("j" (progn (js-mode) (json-pretty-print-buffer)) "json")
    ("x" (progn (nxml-mode)) "xml")
    ("t" (progn (turn-on-orgtbl) (org-table-convert-region (point-min) (point-max) nil)) "table"))

  (add-hook 'temp-buffer-initialized-hook #'hydra-setup-temp-buffer/body)
```
