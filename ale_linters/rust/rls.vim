" Author: w0rp <devw0rp@gmail.com>
" Description: A language server for Rust

call ale#Set('rust_rls_executable', 'rls')
call ale#Set('rust_rls_toolchain', 'nightly')

function! ale_linters#rust#rls#GetCommand(buffer) abort
    let l:toolchain = ale#Var(a:buffer, 'rust_rls_toolchain')

    return '%e' . (!empty(l:toolchain) ? ' +' . ale#Escape(l:toolchain) : '')
endfunction

function! ale_linters#rust#rls#GetProjectRoot(buffer) abort
    let l:cargo_metadata = system("cargo metadata --format-version 1")
    if !v:shell_error
        return json_decode(l:cargo_metadata)['workspace_root']
    else
        let l:nearest_toml = ale#path#FindNearestFile(a:buffer, 'Cargo.toml')
        return !empty(l:nearest_toml) ? fnamemodify(l:nearest_toml, ':h') : ''
    endif
endfunction

call ale#linter#Define('rust', {
\   'name': 'rls',
\   'lsp': 'stdio',
\   'executable_callback': ale#VarFunc('rust_rls_executable'),
\   'command_callback': 'ale_linters#rust#rls#GetCommand',
\   'project_root_callback': 'ale_linters#rust#rls#GetProjectRoot',
\})
