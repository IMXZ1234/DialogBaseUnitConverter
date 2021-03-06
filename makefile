EXE = dialogbaseunitconverter.exe
OBJS = dialogbaseunitconverter.obj
RES = dialogbaseunitconverter.res

LINK_FLAG = /subsystem:windows
ML_FLAG = /c /coff

$(EXE): $(OBJS) $(RES)
	link $(LINK_FLAG) /out:$(EXE) $(OBJS) $(RES)

.asm.obj:
	ml $(ML_FLAG) $<

.rc.res:
	rc $<

clean:
	del *.obj