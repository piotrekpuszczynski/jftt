%{
int lines = 0;
int words = 0;
%}

%%
^[[:blank:]]+\n? 	{}
[[:blank:]]+\n?$ 	{}
[[:blank:]]+ 		{ printf(" "); }
\n 					{ ECHO; lines++; }
[^[:blank:]\n]+  	{ ECHO; words++; }
%%

int yywrap(){}
int main(int argc, char **argv) {
	yylex();
	printf("\nlines: %d, words: %d", lines, words);
	return 0;
}