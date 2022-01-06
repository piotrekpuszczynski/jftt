%{
int d = 0;
%}

%x instring
%x ininclude
%x singlecomment
%x multicomment
%x dsinglecomment
%x dmulticomment

%%

\"                          { ECHO; BEGIN(instring); }
<instring>\"                { ECHO; BEGIN(INITIAL); }
<instring>.                 { ECHO; }        

\<                          { ECHO; BEGIN(ininclude); }
<ininclude>>                { ECHO; BEGIN(INITIAL); }
<ininclude>.|\n             { ECHO; }

\/(\\\n)*\/(\\\n)*(\/|!)    { if (d == 1) ECHO; BEGIN(dsinglecomment); }
<dsinglecomment>.*\\\n      { if (d == 1) ECHO; }
<dsinglecomment>.           { if (d == 1) ECHO; }
<dsinglecomment>[^\\]\n     { if (d == 1) ECHO; else printf("\n"); BEGIN(INITIAL); }

\/(\\\n)*\/                 { BEGIN(singlecomment); }
<singlecomment>.*\\\n       { }
<singlecomment>.            { }
<singlecomment>[^\\]\n      { printf("\n"); BEGIN(INITIAL); }

\/(\\\n)*\*(\\\n)*(\*|!)    { if (d == 1) ECHO; BEGIN(dmulticomment); }
<dmulticomment>.|\n         { if (d == 1) ECHO; }
<dmulticomment>\*(\\\n)*\/  { if (d == 1) ECHO; else printf("\n"); BEGIN(INITIAL); }

\/(\\\n)*\*                 { BEGIN(multicomment); }
<multicomment>.|\n          { }
<multicomment>\*(\\\n)*\/   { printf("\n"); BEGIN(INITIAL); }

%%

int yywrap(){}
int main(int argc, char **argv) {
    if (argv[1][0] == '1') d = 1;
    yylex();
	return 0;
}