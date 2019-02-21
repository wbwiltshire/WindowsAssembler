all: 
#	cd MASM\Add_64 && nmake
#	cd MASM\AddTwo_64 && nmake
	cd MASM\AllocateMemoryDynamically && nmake
	cd MASM\Array_Sum && nmake
	cd MASM\BinarySearch && nmake
	cd MASM\BubbleSort && nmake
	cd MASM\CallFromC && nmake
#	cd MASM\ElapsedTime && nmake
#	cd MASM\CallFromC && nmake
	cd MASM\HelloWorld && nmake
	cd MASM\HelloWorld64 && nmake
	cd MASM\Hola && nmake
	cd MASM\HolaMessageBox && nmake
	cd MASM\MessageBox && nmake
	cd MASM\ReadFile && nmake
	cd MASM\SieveOfEratoshenes && nmake
	cd MASM\Threading && nmake
	cd NASM\BasicWindow64 && nmake
	cd NASM\HelloWorld && nmake
	cd NASM\Hola && nmake

clean:
#	cd MASM\Add_64 && nmake clean
#	cd MASM\AddTwo_64 && nmake clean
	cd MASM\AllocateMemoryDynamically && nmake clean
	cd MASM\Array_Sum && nmake clean
	cd MASM\BinarySearch && nmake clean
	cd MASM\BubbleSort && nmake clean
	cd MASM\CallFromC && nmake clean
#	cd MASM\ElapsedTime && nmake
#	cd MASM\CallFromC && nmake clean
	cd MASM\HelloWorld && nmake clean
	cd MASM\HelloWorld64 && nmake clean
	cd MASM\Hola && nmake clean
	cd MASM\HolaMessageBox && nmake clean
	cd MASM\MessageBox && nmake clean
	cd MASM\ReadFile && nmake clean
	cd MASM\SieveOfEratoshenes && nmake clean
	cd MASM\Threading && nmake clean	
	cd NASM\BasicWindow64 && nmake clean
	cd NASM\HelloWorld && nmake clean
	cd NASM\Hola && nmake clean		