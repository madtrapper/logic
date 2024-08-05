%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yyparse();
extern FILE *yyin;

void yyerror(const char *s);

typedef struct Operation {
    char *op;
    int operand1;
    int operand2;
    int result;
    char *operand1_name;
    char *operand2_name;
    struct Operation *next;
} Operation;

typedef struct Variable {
    char *name;
    int value;
    struct Variable *next;
} Variable;

Operation *head = NULL;
Variable *var_head = NULL;

void add_operation(const char *op, int operand1, int operand2, int result, const char *operand1_name, const char *operand2_name) {
    Operation *new_op = (Operation *)malloc(sizeof(Operation));
    new_op->op = strdup(op);
    new_op->operand1 = operand1;
    new_op->operand2 = operand2;
    new_op->result = result;
    new_op->operand1_name = strdup(operand1_name);
    new_op->operand2_name = strdup(operand2_name);
    new_op->next = head;
    head = new_op;
}

void print_operations() {
    Operation *current = head;
    while (current != NULL) {
        printf("Operation: %s, Operand1: %s (%d), Operand2: %s (%d), Result: %d\n",
               current->op, current->operand1_name, current->operand1, current->operand2_name, current->operand2, current->result);
        current = current->next;
    }
}

void add_variable(char *name, int value) {
    Variable *var = (Variable *)malloc(sizeof(Variable));
    var->name = strdup(name);
    var->value = value;
    var->next = var_head;
    var_head = var;
}

int get_variable(char *name) {
    Variable *current = var_head;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current->value;
        }
        current = current->next;
    }
    yyerror("Undefined variable");
    return 0;
}

char* get_variable_name(int value) {
    Variable *current = var_head;
    while (current != NULL) {
        if (current->value == value) {
            return current->name;
        }
        current = current->next;
    }
    return NULL;
}
%}

%union {
    int boolean;
    char *text;
}

%token <boolean> BOOL
%token <text> IDENTIFIER
%token AND OR NOT LPAREN RPAREN

%type <boolean> expr term factor

%%
input:
    statements { print_operations(); }
;

statements:
    statements statement
    | statement
;

statement:
    IDENTIFIER '=' expr ';' {
        add_variable($1, $3);
        printf("Assigned %s = %d\n", $1, $3);
    }
    | expr ';' { 
        //char *name1 = get_variable_name($1);
        //char *name2 = get_variable_name($3);
        printf("Final result: %d\n", $1); 
    }
;

expr:
    expr OR term {
        char *name1 = get_variable_name($1);
        char *name2 = get_variable_name($3);
        printf("Performing OR: %s (%d) || %s (%d)\n", name1 ? name1 : "temp", $1, name2 ? name2 : "temp", $3);
        $$ = $1 || $3;
        add_operation("OR", $1, $3, $$, name1 ? name1 : "temp", name2 ? name2 : "temp");
        printf("Result after OR: %d\n", $$);
    }
    | term
;

term:
    term AND factor {
        char *name1 = get_variable_name($1);
        char *name2 = get_variable_name($3);
        printf("Performing AND: %s (%d) && %s (%d)\n", name1 ? name1 : "temp", $1, name2 ? name2 : "temp", $3);
        $$ = $1 && $3;
        add_operation("AND", $1, $3, $$, name1 ? name1 : "temp", name2 ? name2 : "temp");
        printf("Result after AND: %d\n", $$);
    }
    | factor
;

factor:
    NOT factor {
        printf("Performing NOT: !%d\n", $2);
        $$ = !$2;
        printf("Result after NOT: %d\n", $$);
    }
    | BOOL {
        $$ = $1;
    }
    | IDENTIFIER {
        $$ = get_variable($1);
    }
    | LPAREN expr RPAREN {
        $$ = $2;
    }
;

%%
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

