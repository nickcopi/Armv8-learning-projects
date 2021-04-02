all: genlib.o
	ld -o genlib genlib.o

genlib.o: genlib.s
	as -o genlib.o genlib.s
clean:
	rm genlib genlib.o
