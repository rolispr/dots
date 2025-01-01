vim9script

def ExecuteCodeBlock()
  if mode() == 'v'
    if len(getline("'<", "'>")) == 0
      echo "No code block selected."
      return
    endif
    var code_block = join(getline("'<", "'>"), "\n")
  else
    var code_block = getline('.')
  endif
  try
    execute code_block
  catch
    echoerr "Error executing code block."
  endtry
enddef

def OpenScratchBuffer()
  new
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal filetype=vim9script
  file Scratch.vim
enddef

command Scratch OpenScratchBuffer()

nnoremap <Leader>e ExecuteCodeBlock()
vnoremap <silent> <Leader>e ExecuteCodeBlock()

