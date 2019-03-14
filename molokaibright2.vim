" Vim color file
"
" Author: Tomas Restrepo <tomas@winterdom.com>
" https://github.com/tomasr/molokaibright2
"
" Note: Based on the Monokai theme for TextMate
" by Wimer Hazenberg and its darker variant
" by Hamish Stuart Macpherson
"
" modifications by beomagi for brighter higher contrast text
"
hi clear

if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="molokaibright2"

if exists("g:molokaibright2_original")
    let s:molokaibright2_original = g:molokaibright2_original
else
    let s:molokaibright2_original = 0
endif


hi Boolean         guifg=#E5C0FF
hi Character       guifg=#FCF9B3
hi Number          guifg=#E5C0FF
hi String          guifg=#FCF9B3
hi Conditional     guifg=#FE46B1               gui=bold
hi Constant        guifg=#E5C0FF               gui=bold
hi Cursor          guifg=#000000 guibg=#F8F8F0
hi iCursor         guifg=#000000 guibg=#F8F8F0
hi Debug           guifg=#EDDDDD               gui=bold
hi Define          guifg=#A3F9FD
hi Delimiter       guifg=#CDCDCD
hi DiffAdd                       guibg=#13354A
hi DiffChange      guifg=#C8BFBC guibg=#4C4745
hi DiffDelete      guifg=#D30086 guibg=#1E0010
hi DiffText                      guibg=#4C4745 gui=italic,bold

hi Directory       guifg=#DFFB53               gui=bold
hi Error           guifg=#FCF9B3 guibg=#1E0010
hi ErrorMsg        guifg=#FE46B1 guibg=#232526 gui=bold
hi Exception       guifg=#DFFB53               gui=bold
hi Float           guifg=#E5C0FF
hi FoldColumn      guifg=#788C90 guibg=#000000
hi Folded          guifg=#788C90 guibg=#000000
hi Function        guifg=#DFFB53
hi Identifier      guifg=#FED43A
hi Ignore          guifg=#BFBFBF guibg=bg
hi IncSearch       guifg=#F1EEC8 guibg=#000000

hi Keyword         guifg=#FE46B1               gui=bold
hi Label           guifg=#FCF9B3               gui=none
hi Macro           guifg=#F1EEC8               gui=italic
hi SpecialKey      guifg=#A3F9FD               gui=italic

hi MatchParen      guifg=#000000 guibg=#FD971F gui=bold
hi ModeMsg         guifg=#FCF9B3
hi MoreMsg         guifg=#FCF9B3
hi Operator        guifg=#FE46B1

" complete menu
hi Pmenu           guifg=#A3F9FD guibg=#000000
hi PmenuSel                      guibg=#808080
hi PmenuSbar                     guibg=#080808
hi PmenuThumb      guifg=#A3F9FD

hi PreCondit       guifg=#DFFB53               gui=bold
hi PreProc         guifg=#DFFB53
hi Question        guifg=#A3F9FD
hi Repeat          guifg=#FE46B1               gui=bold
hi Search          guifg=#000000 guibg=#FFE792
" marks
hi SignColumn      guifg=#DFFB53 guibg=#232526
hi SpecialChar     guifg=#FE46B1               gui=bold
hi SpecialComment  guifg=#BDCCCF               gui=bold
hi Special         guifg=#A3F9FD guibg=bg      gui=italic
if has("spell")
    hi SpellBad    guisp=#FF0000 gui=undercurl
    hi SpellCap    guisp=#7070F0 gui=undercurl
    hi SpellLocal  guisp=#70F0F0 gui=undercurl
    hi SpellRare   guisp=#FFFFFF gui=undercurl
endif
hi Statement       guifg=#FE46B1               gui=bold
hi StatusLine      guifg=#778A8C guibg=fg
hi StatusLineNC    guifg=#BFBFBF guibg=#080808
hi StorageClass    guifg=#FED43A               gui=italic
hi Structure       guifg=#A3F9FD
hi Tag             guifg=#FE46B1               gui=italic
hi Title           guifg=#FD9265
hi Todo            guifg=#FFFFFF guibg=bg      gui=bold

hi Typedef         guifg=#A3F9FD
hi Type            guifg=#A3F9FD               gui=none
hi Underlined      guifg=#BFBFBF               gui=underline

hi VertSplit       guifg=#BFBFBF guibg=#080808 gui=bold
hi VisualNOS                     guibg=#403D3D
hi Visual                        guibg=#403D3D
hi WarningMsg      guifg=#FFFFFF guibg=#333333 gui=bold
hi WildMenu        guifg=#A3F9FD guibg=#000000

hi TabLineFill     guifg=#333638 guibg=#1B1D1E
hi TabLine         guibg=#1B1D1E guifg=#BFBFBF gui=none

if s:molokaibright2_original == 1
   hi Normal          guifg=#FEFEFE guibg=#272822
   hi Comment         guifg=#B4AF99
   hi CursorLine                    guibg=#3E3D32
   hi CursorLineNr    guifg=#FED43A               gui=none
   hi CursorColumn                  guibg=#3E3D32
   hi ColorColumn                   guibg=#3B3A32
   hi LineNr          guifg=#EDEDED guibg=#3B3A32
   hi NonText         guifg=#B4AF99
   hi SpecialKey      guifg=#B4AF99
else
   hi Normal          guifg=#FEFEFE guibg=#1B1D1E
   hi Comment         guifg=#BDCCCF
   hi CursorLine                    guibg=#293739
   hi CursorLineNr    guifg=#FED43A               gui=none
   hi CursorColumn                  guibg=#293739
   hi ColorColumn                   guibg=#232526
   hi LineNr          guifg=#788C90 guibg=#232526
   hi NonText         guifg=#788C90
   hi SpecialKey      guifg=#788C90
end

"
" Support for 256-color terminal
"
if &t_Co > 255
   if s:molokaibright2_original == 1
      hi Normal                   ctermbg=232
      hi CursorLine               ctermbg=235   cterm=none
      hi CursorLineNr ctermfg=214               cterm=none
   else
      hi Normal       ctermfg=253 ctermbg=232
      hi CursorLine               ctermbg=234   cterm=none
      hi CursorLineNr ctermfg=214               cterm=none
   endif
   hi Boolean         ctermfg=141
   hi Character       ctermfg=186
   hi Number          ctermfg=141
   hi String          ctermfg=186
   hi Conditional     ctermfg=161               cterm=bold
   hi Constant        ctermfg=141               cterm=bold
   hi Cursor          ctermfg=16  ctermbg=253
   hi Debug           ctermfg=229               cterm=bold
   hi Define          ctermfg=87
   hi Delimiter       ctermfg=244

   hi DiffAdd                     ctermbg=24
   hi DiffChange      ctermfg=217 ctermbg=239
   hi DiffDelete      ctermfg=162 ctermbg=53
   hi DiffText                    ctermbg=102 cterm=bold

   hi Directory       ctermfg=154               cterm=bold
   hi Error           ctermfg=224 ctermbg=89
   hi ErrorMsg        ctermfg=205 ctermbg=16    cterm=bold
   hi Exception       ctermfg=154               cterm=bold
   hi Float           ctermfg=141
   hi FoldColumn      ctermfg=69  ctermbg=16
   hi Folded          ctermfg=69  ctermbg=16
   hi Function        ctermfg=154
   hi Identifier      ctermfg=214               cterm=none
   hi Ignore          ctermfg=246 ctermbg=232
   hi IncSearch       ctermfg=194 ctermbg=16

   hi keyword         ctermfg=161               cterm=bold
   hi Label           ctermfg=230               cterm=none
   hi Macro           ctermfg=194
   hi SpecialKey      ctermfg=87

   hi MatchParen      ctermfg=233  ctermbg=208 cterm=bold
   hi ModeMsg         ctermfg=230
   hi MoreMsg         ctermfg=230
   hi Operator        ctermfg=161

   " complete menu
   hi Pmenu           ctermfg=87  ctermbg=16
   hi PmenuSel        ctermfg=255 ctermbg=242
   hi PmenuSbar                   ctermbg=232
   hi PmenuThumb      ctermfg=87

   hi PreCondit       ctermfg=154               cterm=bold
   hi PreProc         ctermfg=154
   hi Question        ctermfg=87
   hi Repeat          ctermfg=161               cterm=bold
   hi Search          ctermfg=0   ctermbg=222   cterm=NONE

   " marks column
   hi SignColumn      ctermfg=154 ctermbg=235
   hi SpecialChar     ctermfg=161               cterm=bold
   hi SpecialComment  ctermfg=248               cterm=bold
   hi Special         ctermfg=87
   if has("spell")
       hi SpellBad                ctermbg=52
       hi SpellCap                ctermbg=17
       hi SpellLocal              ctermbg=17
       hi SpellRare  ctermfg=none ctermbg=none  cterm=reverse
   endif
   hi Statement       ctermfg=161               cterm=bold
   hi StatusLine      ctermfg=241 ctermbg=253
   hi StatusLineNC    ctermfg=246 ctermbg=232
   hi StorageClass    ctermfg=214
   hi Structure       ctermfg=87
   hi Tag             ctermfg=161
   hi Title           ctermfg=166
   hi Todo            ctermfg=231 ctermbg=232   cterm=bold

   hi Typedef         ctermfg=87
   hi Type            ctermfg=87                cterm=none
   hi Underlined      ctermfg=246               cterm=underline

   hi VertSplit       ctermfg=246 ctermbg=232   cterm=bold
   hi VisualNOS                   ctermbg=232
   hi Visual                      ctermbg=235
   hi WarningMsg      ctermfg=231 ctermbg=232   cterm=bold
   hi WildMenu        ctermfg=87  ctermbg=16

   hi Comment         ctermfg=71
   hi CursorColumn                ctermbg=236
   hi ColorColumn                 ctermbg=236
   hi LineNr          ctermfg=251 ctermbg=236
   hi NonText         ctermfg=71

   hi SpecialKey      ctermfg=71

   if exists("g:rehash256") && g:rehash256 == 1
       hi Normal       ctermfg=253 ctermbg=234
       hi CursorLine               ctermbg=236   cterm=none
       hi CursorLineNr ctermfg=214               cterm=none

       hi Boolean         ctermfg=147
       hi Character       ctermfg=223
       hi Number          ctermfg=147
       hi String          ctermfg=223
       hi Conditional     ctermfg=204               cterm=bold
       hi Constant        ctermfg=147               cterm=bold

       hi DiffDelete      ctermfg=162 ctermbg=233

       hi Directory       ctermfg=190               cterm=bold
       hi Error           ctermfg=223 ctermbg=233
       hi Exception       ctermfg=190               cterm=bold
       hi Float           ctermfg=147
       hi Function        ctermfg=190
       hi Identifier      ctermfg=214

       hi Keyword         ctermfg=204               cterm=bold
       hi Operator        ctermfg=204
       hi PreCondit       ctermfg=190               cterm=bold
       hi PreProc         ctermfg=190
       hi Repeat          ctermfg=204               cterm=bold

       hi Statement       ctermfg=204               cterm=bold
       hi Tag             ctermfg=204
       hi Title           ctermfg=209
       hi Visual                      ctermbg=232

       hi Comment         ctermfg=246
       hi LineNr          ctermfg=242 ctermbg=235
       hi NonText         ctermfg=242
       hi SpecialKey      ctermfg=242
   endif
end

" Must be at the end, because of ctermbg=234 bug.
" https://groups.google.com/forum/#!msg/vim_dev/afPqwAFNdrU/nqh6tOM87QUJ
set background=dark
