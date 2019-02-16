# Use nmake /N to debug nmake
AS=ml.exe
#AS=ml64.exe
AFLAGS=/c /Zi /W3
LINK=link.exe
LDFLAGS=/DEBUG /SUBSYSTEM:CONSOLE /MACHINE:X86 
#LDFLAGS=/DEBUG /SUBSYSTEM:CONSOLE /MACHINE:X64 
LDLIBS=KERNEL32.LIB USER32.LIB SHELL32.LIB Irvine32.Lib /LIBPATH:c:\Irvine
SOURCES=main.asm
EXECUTABLE=Sieve.exe
OBJECTS=$(SOURCES:.asm=.obj)

all: $(EXECUTABLE)

.asm.obj:
	$(AS) $< $(AFLAGS) /Fo $@

$(EXECUTABLE): $(OBJECTS)
	$(LINK) /out:$(EXECUTABLE) $(LDFLAGS) $(LDLIBS) $** 

clean:
	@IF EXIST *.pdb (del *.pdb)
	@IF EXIST *.ilk (del *.ilk)
	@IF EXIST $(EXECUTABLE) (del $(EXECUTABLE))
	@IF EXIST *.obj (del *.obj)