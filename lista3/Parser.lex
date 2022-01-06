%{
#include "Parser.h"
%}

%option noyywrap

%%

#(.|\\\n)*\n    {}
\\\n            {}
[[:blank:]]+ 	{}
[0-9]+          { yylval = atoi(yytext); return NUM; }
"+"             { return ADD; }
"-"             { return SUB; }
"*"             { return MUL; }
"/"             { return DIV; }
"^"             { return POW; }
\(              { return LB; }
\)              { return RB; }
\n              { return END; }
EOF             { return 0; }
.               { return ERROR; }

%%