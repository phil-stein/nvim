" Vim syntax file
" Language: mooh 
" used tutorial: https://vim.fandom.com/wiki/Creating_your_own_syntax_files

if exists("b:current_syntax")
  finish
endif

" basic integer numbers
syn match    moohNumber '\d\+'
" Floating point number with decimal no E or e 
syn match    moohNumber '[-+]\d\+\.\d*'
syn keyword  moohType  red black " $$ $b$ $r$ $g$ $y$ $b$

let b:current_syntax = "mooh"

hi def link moohTodo        Todo
hi def link moohComment     Comment
hi def link moohBlockCmd    Statement
hi def link moohType        Type
hi def link moohString      Constant
hi def link moohDesc        PreProc
hi def link moohNumber      Constant
