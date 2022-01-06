%{
%}

%x comment
%x instring
%x cdata

%%
\<!--.*--.*-->    { ECHO; }

\<!--             { BEGIN(comment); }
<comment>-->      { BEGIN(INITIAL); }
<comment>.|\n     {}

\"                { ECHO; BEGIN(instring); }
<instring>\"      { ECHO; BEGIN(INITIAL); }
<instring>.|\n    { ECHO; }

\<!\[CDATA\[      { ECHO; BEGIN(cdata); }
<cdata>.|\n       { ECHO; }
<cdata>]]>        { ECHO; BEGIN(INITIAL); }

%%

int yywrap(){}
int main(int argc, char **argv) {
    yylex();
	return 0;
}