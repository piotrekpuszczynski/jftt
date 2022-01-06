%{

char* error = "";

struct stack {
    int maxSize;
    int top;
    int* items;
};

struct stack* newStack(int capacity) {
    struct stack *pt = (struct stack*)malloc(sizeof(struct stack));
 
    pt->maxSize = capacity;
    pt->top = -1;
    pt->items = (int*)malloc(sizeof(int) * capacity);
 
    return pt;
}

int size(struct stack *pt) {
    return pt->top + 1;
}

int isEmpty(struct stack *pt) {
    return pt->top == -1;
}

int isFull(struct stack *pt) {
    return pt->top == pt->maxSize - 1;
}

void push(struct stack *pt, int x) {

    if (isFull(pt)) {
        error = "stack overflow";
        return;
    }
  
    pt->items[++pt->top] = x;
}

int pop(struct stack *pt) {
    if (isEmpty(pt)) {
        error = "too few numbers";
        return 0;
    }
 
    return pt->items[pt->top--];
}

struct stack* stack;

void add() { 
    int b = pop(stack);
    int a = pop(stack);
    push(stack, a + b); 
}
void sub() {
    int b = pop(stack);
    int a = pop(stack);
    push(stack, a - b); 
}
void mul() {
    int b = pop(stack);
    int a = pop(stack);
    push(stack, a * b); 
}
void mod() {
    int b = pop(stack);
    int a = pop(stack);
    if (b == 0) {
        error = "can't divide by zero";
        return;
    } else {
        push(stack, a % b); 
    }
}
void power() {
    int b = pop(stack);
    int a = pop(stack);
    if (b == 0) {
        push(stack, 1);
        return;
    } else if (b < 0) {
        error = "can't divide by number lower than zero";
        return;
    }
    int result = a;
    for (int i = 1; i < b; i++) {
        result = result * result;
    }
    push(stack, result); 
}
void divide() {
    int b = pop(stack);
    int a = pop(stack);
    if (b == 0) {
        error = "can't divide by zero";
        return;
    } else {
        push(stack, a / b); 
    }
}

int getResult() {
    if (size(stack) > 1) {
        error = "too few operands";
        return 0;
    } else if (isEmpty(stack)) {
        error = "not given numbers";
        return 0;
    }
    return pop(stack);
}

int checkError() {
    if (strcmp(error, "")) return 1;
    else return 0;
}

%}

%x E

%%
\-?[0-9]+   { push(stack, atoi(yytext)); if (checkError() == 1) BEGIN(E); }
\+          { add(); if (checkError() == 1) BEGIN(E); }
\-          { sub(); if (checkError() == 1) BEGIN(E); }
\*          { mul(); if (checkError() == 1) BEGIN(E); }
\/          { divide(); if (checkError() == 1) BEGIN(E); }
\%          { mod(); if (checkError() == 1) BEGIN(E); }
\^          { power(); if (checkError() == 1) BEGIN(E); }
\n          { i = getResult(); if (checkError() == 1) printf("%s\n", error); else printf("%d\n", i); stack = newStack(100); error = ""; }
" "         {}
q           { return 0; }
.           { printf("incorrect character"); BEGIN(E); }

<E>.        {}
<E>\n       { printf("%s\n", error); stack = newStack(100); error = ""; BEGIN(INITIAL); }
%%

int yywrap(){}
int main(int argc, char **argv) {
    stack = newStack(100);
    yylex();
	return 0;
}