using FilePathsBase, FilePaths

#=
`pwd()` prints the directory you are currently in. 
    It does nothing else.pwd does not take any arguments.

`cd()` without arguments changes your working directory to your home directory. 
    It does not print anything by default.

`cd(target_directory)` with an argument will change your working directory
    to whatever directory you supplied as an argument.

answered Apr 9, 2017 at 5:50 by user91656
https://unix.stackexchange.com/questions/357893/is-there-a-difference-between-pwd-and-cd
=#

"""
    cwd()

filepath for the current working directory
    - like `Path(pwd())`
"""
cwd() = canonicalize(Path(abspath(pwd())))

"""
   currentdrive()
"""
currentdrive() = cwd().drive

"""
   currentroot()
"""
function currentroot()
    current_path = cwd()
    current_drive = currentpath.drive
    current_sep = currentpath.separator
    current_root = currentpath.root

    curdrive = currentdrive()
    (curdrive * curdrive.separator),     Path(curdrive * curdrive.separator)

end

