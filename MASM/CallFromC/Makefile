# Use nmake /N to debug nmake
CC=cl
#CFLAGS=/c 
#Compile with debug info
CFLAGS=/c /Zi
#AS=ml.exe
AS=ml64.exe
AFLAGS=/c /Zi /W3
LINK=link.exe
#LDFLAGS=/DEBUG /SUBSYSTEM:CONSOLE /MACHINE:X86 
LDFLAGS=/DEBUG
#LDLIBS=KERNEL32.LIB USER32.LIB SHELL32.LIB
SOURCES=PrintString.asm Add.asm main.c
EXECUTABLE=CallFromC.exe
OBJECTS=PrintString.obj main.obj Add.obj

all: $(EXECUTABLE)

.asm.obj:
	$(AS) $< $(AFLAGS) /Fo $@

.c.obj: 
	$(CC) $(CFLAGS) $** /Fo$@

$(EXECUTABLE): $(OBJECTS)
	$(LINK) /out:$(EXECUTABLE) $(LDFLAGS) $(LDLIBS) $** 

clean:
	@IF EXIST *.pdb (del *.pdb)
	@IF EXIST *.ilk (del *.ilk)
	@IF EXIST $(EXECUTABLE) (del $(EXECUTABLE))
	@IF EXIST *.obj (del *.obj)