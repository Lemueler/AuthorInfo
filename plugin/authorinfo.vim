
"=============================================================================
"  Author:          dantezhu - http://www.vimer.cn
"  Email:           zny2008@gmail.com
"  FileName:        authorinfo.vim
"  Description:
"  Version:         1.5-fixed
"  Modified:        Steve Lemuel <wlemuel@hotmail.com>
"  LastChange:      2015-08-01 19:16:21
"  History:         support bash's #!xxx
"                   fix bug for NerdComment's <leader>
"=============================================================================
if exists('g:loaded_authorinfo')
    finish
endif
let g:loaded_authorinfo= 1

if exists("mapleader")
    let s:t_mapleader = mapleader
elseif exists("g:mapleader")
    let s:t_mapleader = g:mapleader
else
    let s:t_mapleader = '\'
endif

function! g:CheckFileType(type)
    let t_filetypes = split(&filetype,'\.')
    if index(t_filetypes,a:type)>=0
        return 1
    else
        return 0
    endif
endfunction

function s:superbeforeline()
    if &filetype == "sh"
        call append(0,"#!/usr/bin/env bash")
        call append(1,"")
    endif
    if &filetype == "python"
        call append(0,"#!/usr/bin/env python")
        call append(1,"# -*- coding: utf-8 -*-")
        call append(2,"")
    endif
endfunction

function s:DetectFirstLine()
    "跳转到指定区域的第一行，开始操作
    exe 'normal '.1.'G'
    let arrData = [
                \['sh',['^#!.*$']],
                \['python',['^#!.*$','^#.*coding:.*$']],
                \['php',['^<?.*']]
                \]
    let oldNum = line('.')
    while 1
        let line = getline('.')
        let findMatch = 0
        for [t,v] in arrData
            if g:CheckFileType(t)
                for it in v
                    if line =~ it
                        let findMatch = 1
                        break
                    endif
                endfor
            endif
        endfor
        if findMatch != 1
            break
        endif
        normal j
        "到了最后一行了，所以直接o就可以了
        if oldNum == line('.')
            normal o
            return
        endif
        let oldNum = line('.')
    endwhile
    normal O
endfunction

function s:BeforeTitle()
    let arrData = [['python','"""']]
    for [t,v] in arrData
        if g:CheckFileType(t)
            call setline('.',v)
            normal o
            break
        endif
    endfor
endfunction

function s:AfterTitle()
    let arrData = [['python','"""']]
    for [t,v] in arrData
        if g:CheckFileType(t)
            normal o
            call setline('.',v)
            normal k
            break
        endif
    endfor
endfunction

function s:AddTitle()
    if has('g:authorInfo_styleOne')
        let s:mul_data = g:authorInfo_styleOne
    else
        let s:mul_data = ['c','cpp','java']
    endif

    if has('g:authorInfo_styleTwo')
        let s:mul_data = g:authorInfo_styleOne
    else
        let s:sin_data = ['python','sh','ruby','asm']
    endif

    if index(s:mul_data,&ft)<0 && index(s:sin_data,&ft)<0
        finish
    endif

    if exists('g:authorInfo_timeformat')
        let s:timeformat = g:authorInfo_timeformat
    else
        let s:timeformat = '%Y-%m-%d %H:%M:%S'
    endif

    call s:superbeforeline()
    "检查开始插入作者信息的行
    call s:DetectFirstLine()
    "判断是否支持多行注释

    if index(s:mul_data,&ft)>=0
        let hasMul = 1
        let preChar = '*'
        let noTypeChar = ''
        let mulSymbolS = '/*'
        let mulSymbolE = '*/'
    else
        let hasMul = 2
        let preChar = ''
        let noTypeChar = '#'
        let mulSymbolS = ''
        let mulSymbolE = ''
    endif

    "在第一行之前做的事情
    call s:BeforeTitle()

    let firstLine = line('.')
    call setline('.',noTypeChar.mulSymbolS.'=============================================================================')
    normal o
    call setline('.',noTypeChar.preChar.'     FileName: '.expand("%:t"))
    normal o
    call setline('.',noTypeChar.preChar.'         Desc: ')
    let gotoLn = line('.')
    normal o
    if exists('g:authorInfo_license')
        call setline('.',noTypeChar.preChar.'      License: '.g:authorInfo_license)
    else
        call setline('.',noTypeChar.preChar.'      License: GPL')
    endif
    normal o
    if exists('g:authorInfo_author')
        call setline('.',noTypeChar.preChar.'       Author: '.g:authorInfo_author)
        normal o
    endif
    if exists('g:authorInfo_email')
        call setline('.',noTypeChar.preChar.'        Email: '.g:authorInfo_email)
        normal o
    endif
    if exists('g:authorInfo_homepage')
        call setline('.',noTypeChar.preChar.'     HomePage: '.g:authorInfo_homepage)
        normal o
    endif
    call setline('.',noTypeChar.preChar.'      Version: 0.0.1')
    normal o
    call setline('.',noTypeChar.preChar.'   LastChange: '.strftime(s:timeformat))
    normal o
    call setline('.',noTypeChar.preChar.'    CreatedAt: '.strftime(s:timeformat))
    normal o
    call setline('.',noTypeChar.preChar.'============================================================================='.mulSymbolE)
    let lastLine = line('.')

    "在最后一行之后做的事情
    call s:AfterTitle()

    "let hasMulExec = 'normal '.firstLine.'Gv'.lastLine.'G'.s:t_mapleader.'c'
    "if hasMul == 1
        "exe hasMulExec.'m'
    "else
        "exe hasMulExec.'l'
    "endif

    exe 'normal '.gotoLn.'G'
    startinsert!
    echohl WarningMsg | echo "Add the copyright successfully!" | echohl None
endf

function s:TitleDet()
    silent! normal ms
    let updated = 0
    let n = 1
    let msg = "Update"
    "默认为添加
    while n < 20
        let line = getline(n)
        if line =~ '^.*FileName:\S*.*$'
            let newline=substitute(line,':\(\s*\)\(\S.*$\)$',':\1'.expand("%:t"),'g')
            call setline(n,newline)
            let updated = 1
        endif
        if line =~ '^.*LastChange:\S*.*$'
            let newline=substitute(line,':\(\s*\)\(\S.*$\)$',':\1'.strftime("%Y-%m-%d %H:%M:%S"),'g')
            call setline(n,newline)
            let updated = 1
        endif
        if line =~ '^.*Last\ modified:\S*.*$'
            let newline=substitute(line,':\(\s*\)\(\S.*$\)$',':\1'.strftime("%Y-%m-%d %H:%M"),'g')
            call setline(n,newline)
            let updated = 1
        endif
        let n = n + 1
    endwhile

    if updated == 1
        silent! normal 's
        echohl WarningMsg | echo "Update the copyright successfully!" | echohl None
        return
    endif

    if getline(1) == ""
        call s:AddTitle()
    endif
endfunction

command! -nargs=0 AuthorInfoDetect :call s:TitleDet()
command! -nargs=0 AuthorInfoAdd :call s:AddTitle()
