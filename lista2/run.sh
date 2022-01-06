flex $1/$1.lex
gcc lex.yy.c
./a.out $3 < $2.txt > rewritten$2.txt
rm a.out
rm lex.yy.c