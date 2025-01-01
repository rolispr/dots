vim9script

# Function to list files in a directory
def ListFilesInDir(dir: string): list<string>
    var files: list<string> = []
    try
        files = systemlist('ls -p ' .. dir)
    catch
        echo 'Error listing files in ' .. dir
    endtry
    return files
enddef

# Function to populate buffer with files
def PopulateBufferWithFiles(files: list<string>, dir: string)
    if !bufexists('Dired')
        enew
        file 'Dired'
        setlocal buftype=nofile
        setlocal bufhidden=wipe
        setlocal noswapfile
        setlocal nowrap
        setlocal nonumber
    else
        execute 'buffer Dired'
    endif

    var lines: list<string> = ['Directory: ' .. dir]
    lines->extend(files)

    setlocal modifiable
    call setline(1, lines)
    setlocal nomodifiable

    b:current_dir = dir
enddef

# Function to open an item (file or directory)
def OpenItem()
    var line: string = getline('.')
    var dir: string = getbufvar(bufnr('%'), 'current_dir', getcwd())
    if line ==# '' || line =~# '^Directory:'
        return
    endif

    var item: string = substitute(line, '\s\+$', '', '')
    var full_path: string = dir .. '/' .. item

    if isdirectory(full_path)
        PopulateBufferWithFiles(ListFilesInDir(full_path), full_path)
    else
        execute 'edit ' .. full_path
    endif
enddef

# Function to go up to the parent directory
def GoUp()
    var dir: string = getbufvar(bufnr('%'), 'current_dir', getcwd())
    var parent_dir: string = fnamemodify(dir, ':h')
    PopulateBufferWithFiles(ListFilesInDir(parent_dir), parent_dir)
enddef

# Function to initialize the directory explorer
def InitDired()
    var dir: string = getcwd()
    var files: list<string> = ListFilesInDir(dir)
    PopulateBufferWithFiles(files, dir)
    SetupMappings()
enddef

# Key mappings for navigation within the Dired buffer
def SetupMappings()
    nnoremap <buffer> <CR> :call OpenItem()<CR>
    nnoremap <buffer> - :call GoUp()<CR>
enddef

# Initialize Dired and setup mappings
InitDired()

