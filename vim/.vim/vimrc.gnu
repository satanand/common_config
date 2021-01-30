command Show80Plus syn match GnuError /\%81v.\+/ 
if exists("g:loaded_gnusty")
    finish
endif
let g:loaded_gnusty = 1

augroup gnusty
    autocmd!

    autocmd FileType c,cpp call s:GnuFormatting()
    autocmd FileType c,cpp call s:GnuHighlighting()
augroup END

function s:GnuFormatting()
    setlocal cindent
    setlocal cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
    setlocal shiftwidth=2
    setlocal softtabstop=2
    setlocal textwidth=79
    setlocal fo-=ro fo+=cql
endfunction

function s:GnuHighlighting()
    highlight default link GnuError ErrorMsg

    syn match GnuError / \+\ze\t/     " spaces before tab
    syn match GnuError /\s\+$/        " trailing whitespaces
    syn match GnuError /\%81v.\+/     " virtual column 81 and more
endfunction
" vim: ts=4 et sw=4
