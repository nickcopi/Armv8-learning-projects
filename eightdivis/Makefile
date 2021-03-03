all: eightdivis.o
	ld -o eightdivis eightdivis.o

eightdivis.o: eightdivis.s
	as -o eightdivis.o eightdivis.s
clean:
	rm eightdivis eightdivis.o
