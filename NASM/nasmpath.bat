cd "\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build"
call vcvarsall.bat x64
@set path=C:\Program Files\NASM;%path%
cd \Source\ASM\WindowsAssembler\NASM
@%comspec%