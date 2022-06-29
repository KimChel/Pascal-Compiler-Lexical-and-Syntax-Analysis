output: flex.o parser.o
	gcc compiler.tab.c lex.yy.c hash/hashtbl.o -lm -o main

parser.o: compiler.l
	bison -v -d compiler.y

flex.o:
	flex compiler.l

clean:
	rm a.out compiler.tab.c compiler.tab.h lex.yy.c main
