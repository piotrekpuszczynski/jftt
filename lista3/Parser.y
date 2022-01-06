%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
int yylex();
void yyerror(char *s);
void cats(char **str, const char *str2);
void dels(char **str);
int mul(int a, int b);
int reci(int a);
int NWD(int a, int b);
int power(int a, int b);

int n = 1234577;
char* notation = "";
bool error = false;
%}

%token NUM
%token LB
%token RB
%token END
%token ERROR

%left SUB ADD
%left MUL DIV
%nonassoc POW
%right NEG

%%

input:
| input line
;


line:
  END
| exp END {
	if (!error)
		printf("%s\nresult: %d\n", notation, $1);
	error = false;
  	notation = "";
}
| error END {
  	error = false;
  	notation = "";
}
;


exp:
NUM                   	{
							char* temp;
							asprintf(&temp, "%d ", $1 % n);
							cats(&notation, temp);
							free(temp);
							$$ = $1 % n;
  						}
| exp POW power1		{
							cats(&notation, "^ ");
							if ($3 == 0)
								$$ = 1;
							else 
								$$ = power($1, $3);
						}
| SUB exp %prec NEG     {
							char* temp;
							asprintf(&temp, "%d ", n - $2);
							dels(&notation);
							cats(&notation, temp);
							free(temp);
							$$ = n - $2;
						}
| exp ADD exp           {
							cats(&notation, "+ ");
							$$ = ($1 + $3) % n;
						}
| exp SUB exp           {
							cats(&notation, "- ");
							int number = $1 - $3;
							if (number < 0)
								number += n;
							$$ = number;
						}
| exp MUL exp           {
							cats(&notation, "* ");
							$$ = mul($1, $3);
						}
| exp DIV exp           {
                          	cats(&notation, "/ ");
                          	if ($3 != 0) {
								int x = reci($3);
								int result = mul($1, x);
								$$ = result;
							} else
                            	yyerror("cannot divide by zero");
                        }
| LB exp RB             { $$ = $2; }
;

power1:
SUB power1 %prec NEG	{
							if ($2 != 0) {
								int result = (n - 1) - $2 ;

								char* temp;
								asprintf(&temp, "%d ", result);
								dels(&notation);
								cats(&notation, temp);
								free(temp);
								$$ = result;
							} else {
                            	$$ = 1;
							}
						}
| LB power2 RB			{ $$ = $2; }
| NUM                   {
							char* temp;
							asprintf(&temp, "%d ", $1 % (n - 1));
							cats(&notation, temp);
							free(temp);
							$$ = $1;
  						}
;

power2:
NUM	{
	char* temp;
	asprintf(&temp, "%d ", $1 % (n - 1));
	cats(&notation, temp);
	free(temp);
	$$ = $1;
}
| power2 DIV power2 {
	if ($3 != 0) {
		if (NWD($3, n - 1) == 1) {
			n--;
			int x = reci($3);
			int result = mul($1, x);
			n++;
			// int result = reci(n - mul($1, reci($3)));
								
			char* temp;
			asprintf(&temp, "%d ", result);
			dels(&notation);
			cats(&notation, temp);
			free(temp);
			$$ = result;
		} else 
			yyerror("incorrect number in cyclic group");
								
	} else 
		yyerror("cannot divide by zero");
							
	cats(&notation, "/ ");
}
| power2 ADD power2	{
	int result = ($1 + $3) % (n - 1);
	char* temp;
	asprintf(&temp, "%d ", result);
	dels(&notation);
	cats(&notation, temp);
	free(temp);
	$$ = result;
	cats(&notation, "+ ");
}
| power2 SUB power2  {
	int result = $1 - $3 - 1;
	if (result < 0)
		result += n;
								
	char* temp;
	asprintf(&temp, "%d ", result);
	dels(&notation);
	cats(&notation, temp);
	free(temp);
	$$ = result;

	cats(&notation, "- ");
}
| power2 MUL power2	{
	n--;
	int result = mul($1, $3);
	n++;
								
	char* temp;
	asprintf(&temp, "%d ", result);
	dels(&notation);
	cats(&notation, temp);
	free(temp);
	$$ = result;

	cats(&notation, "* ");
}
;
%%

int power(int a, int b) {
	int result = a;
	for (int i = 1; i < b; i++)
		result = mul(result, a);
	return result;
}

int NWD(int a, int b) {
    while (a != b)
       if (a > b)
           a -= b;
       else
           b -= a;
    return a;
}

int mul(int a, int b) {
    int result = 0;
    while (b > 0)
    {
        if (b % 2 == 1)
            result = (result + a) % n;
 
        a = (a * 2) % n;
 
        b /= 2;
    }
	if (result < 0)
		result += n;
    return result % n;
}

int reci(int a) {
	int u, w, x, z, q;

	u = 1;
	w = a;
	x = 0;
	z = n;
	while (w != 0) {
		if (w < z) {
			q = u;
			u = x;
			x = q;
			q = w;
			w = z;
			z = q;
		}
		q = w / z;
		u -= q * x;
		w -= q * z;
	}
	
	if (x < 0)
		x += n;
	return x;
}

void dels(char **str) {
	char* tempStr = calloc(strlen(*str) + 1, sizeof(char));
	memcpy(tempStr, *str, strlen(*str) + 1);
	char* ptr = strtok(tempStr, " ");
	int len;
	while (ptr != NULL) {
		len = strlen(ptr);
		ptr = strtok(NULL, " ");
	}
	ptr = strtok(NULL, " ");
	free(ptr);
	free(tempStr);

	char* tmp = NULL;

	tmp = calloc(strlen(*str) - len - 1, sizeof(char));
    memcpy(tmp, *str, strlen(*str) - len - 1);
    *str = calloc(strlen(*str) - len - 2, sizeof(char));
    memcpy(*str, tmp, strlen(tmp));
    free(tmp);
}

void cats(char **str, const char *str2) {
  	char* tmp = NULL;

    if (*str != NULL && str2 == NULL) {
        free(*str);
        *str = NULL;
        return;
    }

    if (*str == NULL) {
        *str = calloc(strlen(str2) + 1, sizeof(char));
        memcpy(*str, str2, strlen(str2));
    } else {
        tmp = calloc(strlen(*str) + 1, sizeof(char));
        memcpy(tmp, *str, strlen(*str));
        *str = calloc(strlen(*str) + strlen(str2) + 1, sizeof(char));
        memcpy(*str, tmp, strlen(tmp));
        memcpy(*str + strlen(*str), str2, strlen(str2));
        free(tmp);
    }
}

void yyerror(char *s) {
	error = true;
  	printf("%s\n",s);
}

int main() {
  	yyparse();
}
