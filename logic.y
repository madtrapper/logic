%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE *yyin;

void yyerror(const char *s);
%}

%union {
    int boolean;
    int origin_value;
}

%token <boolean> BOOL
%token AND OR NOT LPAREN RPAREN

%type <boolean> expr term factor

%%
input:
    expr { printf("Final result: %d\n", $1); }
;

expr:
    expr OR term { 
        printf("Performing OR: %d || %d\n", $<origin_value>1, $<origin_value>3);
        $$ = $1 || $3; 
        printf("Result after OR: %d\n", $$); 
    }
    | term
;

term:
    term AND factor { 
        printf("Performing AND: %d && %d\n", $<origin_value>1, $<origin_value>3);
        $$ = $1 && $3; 
        printf("Result after AND: %d\n", $$);
    }
    | factor
;

factor:
   NOT factor {
        printf("Performing NOT: !%d\n", $<origin_value>2);
        $$ = !$2;
        printf("Result after NOT: %d\n", $$);
    }
    | BOOL {
        $$ = $1;
    }
    | LPAREN expr RPAREN {
        $$ = $2;
    }
;

%%
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

