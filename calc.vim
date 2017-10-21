" Vim syntax file
" Language:     Calc
" Maintainer:   Mark Geisert <mark@maxrnd.com>
" Last Change:  2017 Oct 2
" License:      VIM license (:help license, replace vim by calc.vim)

" Syntax highlighting for Calc, the C-style arbitrary precision calculator.
" Calc is available from http://www.isthe.com/chongo/tech/comp/calc/

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" Read the C syntax file to start with, but stick to primitive C
let c_no_ansi = 1
let c_no_bsd  = 1
let c_no_c99  = 1
let c_no_gnu  = 1
let c_no_utf  = 1
runtime! syntax/c.vim

" Add Calc-specific keywords
syn keyword calcCommand      cd define undefine show help print
syn keyword calcCommand      read write abort quit exit
syn keyword calcStatement    if else while continue break goto return
syn keyword calcStatement    do for switch case default
syn keyword calcStorageClass local global static
syn keyword calcStructure    assoc list mat obj

" Add Calc's assortment of builtin functions
" TODO Names overridable so match only when followed by 0..N spaces and "("
syn keyword calcBuiltin abs access acos acosh acot acoth acsc acsch agd append
syn keyword calcBuiltin appr arg argv asec asech asin asinh assign atan atan2
syn keyword calcBuiltin atanh avg base base2 bernoulli bit blk blkcpy blkfree
syn keyword calcBuiltin blocks bround btrunc calc_tty calclevel calcpath
syn keyword calcBuiltin catalan ceil cfappr cfsim char cmdbuf cmp comb config
syn keyword calcBuiltin conj copy cos cosh cot coth count cp csc csch ctime
syn keyword calcBuiltin custom delete den det digit digits display dp epsilon
syn keyword calcBuiltin errcount errmax errno error estr euler eval exp fact
syn keyword calcBuiltin factor fclose fcnt feof ferror fflush fgetc fgetfield
syn keyword calcBuiltin fgetfile fgetline fgets fgetstr fib files floor fopen
syn keyword calcBuiltin forall fpathopen fprintf fputc fputs fputstr frac free
syn keyword calcBuiltin freebernoulli freeeuler freeglobals freeredc
syn keyword calcBuiltin freestatics frem freopen fscan fscanf fseek fsize
syn keyword calcBuiltin ftell gcd gcdrem gd getenv hash head highbit hmean
syn keyword calcBuiltin hnrmod hypot ilog ilog10 ilog2 im indices inputlevel
syn keyword calcBuiltin insert int inverse iroot isalnum isalpha isassoc
syn keyword calcBuiltin isatty isblk iscntrl isconfig isdefined isdigit
syn keyword calcBuiltin iserror iseven isfile isgraph ishash isident isint
syn keyword calcBuiltin islist islower ismat ismult isnull isnum isobj
syn keyword calcBuiltin isobjtype isoctet isodd isprime isprint isptr ispunct
syn keyword calcBuiltin isqrt isrand israndom isreal isrel issimple isspace
syn keyword calcBuiltin issq isstr istype isupper isxdigit jacobi join lcm
syn keyword calcBuiltin lcmfact lfactor links ln log lowbit ltol makelist
syn keyword calcBuiltin matdim matfill matmax matmin matsum mattrace mattrans
syn keyword calcBuiltin max memsize meq min minv mmin mne mod modify name near
syn keyword calcBuiltin newerror nextcand nextprime norm null num ord param
syn keyword calcBuiltin perm pfact pi pix places pmod polar poly pop popcnt
syn keyword calcBuiltin power prevcand prevprime printf prompt protect ptest
syn keyword calcBuiltin push putenv quo quomod rand randbit random randombit
syn keyword calcBuiltin randperm rcin rcmul rcout rcpow rcsq re remove reverse
syn keyword calcBuiltin rewind rm root round rsearch runtime saveval scale
syn keyword calcBuiltin scan scanf search sec sech seed segment select setbit
syn keyword calcBuiltin sgn sha1 sin sinh size sizeof sleep sort sqrt srand
syn keyword calcBuiltin srandom ssq stoponerror str strcasecmp strcat strcmp
syn keyword calcBuiltin strcpy strerror strlen strncasecmp strncmp strncpy
syn keyword calcBuiltin strpos strprintf strscan strscanf strtolower
syn keyword calcBuiltin strtoupper substr sum swap system systime tail tan
syn keyword calcBuiltin tanh test time trunc ungetc usertime version xor

" Calc defines "//" as an operator, not a C++-style comment introducer
syn match calcSkip	"//"
" TODO Disable other features of C syntax file that are not part of Calc

" Error highlight any define/if/while/do/etc with trailing "{" on next lines
syn match calcError	")[ \ta-zA-Z_0-9]*\n[ \n\t\a-zA-Z_0-9]*{"

" Add Calc comment syles "##" or "#!" to end of line
syn region calcComment2 start="##" skip="\\$" end="$" keepend contains=@cCommentGroup,cSpaceError,@Spell
syn region calcComment3 start="#!" skip="\\$" end="$" keepend contains=@cCommentGroup,cSpaceError,@Spell

" Link Calc's syntax elements into the standard hierarchy
hi def link calcCommand		Statement
hi def link calcStatement	Statement
hi def link calcStorageClass	StorageClass
hi def link calcStructure	Structure
hi def link calcBuiltin		Function
hi def link calcSkip		Skip
hi def link calcComment2	calcComment
hi def link calcComment3	calcComment
hi def link calcComment		Comment
hi def link calcError		Error

" Set this to avoid being overridden by another polite syntax file
let b:current_syntax = "calc"
