# Use nmake /N to debug nmake
AS=ml64.exe
AFLAGS=/c /Zi /W3
LINK=link.exe
LDFLAGS=/DEBUG /SUBSYSTEM:CONSOLE /ENTRY:main /MACHINE:X64 
LDLIBS=KERNEL32.LIB USER32.LIB SHELL32.LIB
SOURCES=main.asm
EXECUTABLE=HelloWorld.exe
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