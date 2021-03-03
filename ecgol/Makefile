all: ecgol.o
	ld -o ecgol ecgol.o

ecgol.o: ecgol.s
	as -o ecgol.o ecgol.s
clean:
	rm ecgol ecgol.o
