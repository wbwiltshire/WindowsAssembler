# Use nmake /N to debug nmake
# Link: https://docs.microsoft.com/en-us/cpp/c-runtime-library/crt-library-features
#AS=ml.exe
AS=ml64.exe
#For assembler listing use Fl
#AFLAGS=/c /Zi /W3 /Fl$*.lst
AFLAGS=/c /Zi /W3
LINK=link.exe
#LDFLAGS=/DEBUG /SUBSYSTEM:CONSOLE /MACHINE:X86 
#Need MainCRTStartup entrypoint for c runtime library initialization
LDFLAGS=/DEBUG /SUBSYSTEM:CONSOLE /MACHINE:X64 /ENTRY:mainCRTStartup
LDLIBS=KERNEL32.LIB USER32.LIB SHELL32.LIB LIBUCRT.LIB LIBCMT.LIB LIBCPMT.LIB
SOURCES=main.asm dynamicmem.asm print.asm elapsedtime.asm
EXECUTABLE=dm.exe
OBJECTS=$(SOURCES:.asm=.obj)

all: $(EXECUTABLE)

.asm.obj:
	$(AS) $(AFLAGS) /Fo $@ $< 

$(EXECUTABLE): $(OBJECTS)
	$(LINK) /out:$(EXECUTABLE) $(LDFLAGS) $(LDLIBS) $** 

clean:
	@IF EXIST *.pdb (del *.pdb)
	@IF EXIST *.ilk (del *.ilk)
	@IF EXIST $(EXECUTABLE) (del $(EXECUTABLE))
	@IF EXIST *.obj (del *.obj)
	@IF EXIST *.lst (del *.lst)
	
run:
	$(EXECUTABLE)