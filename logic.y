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
    char *operand1_name;
    char *operand2_name;
    int result;
    int line;
    struct Operation *next;
} Operation;

typedef struct Variable {
    char *name;
    int value;
    char *source;
    struct Variable *next;
} Variable;

Operation *head = NULL;
Variable *var_head = NULL;

void add_operation(const char *op, const char *operand1_name, const char *operand2_name, int result, int line) {
    Operation *new_op = (Operation *)malloc(sizeof(Operation));
    new_op->op = strdup(op);
    new_op->operand1_name = strdup(operand1_name);
    new_op->operand2_name = strdup(operand2_name);
    new_op->result = result;
    new_op->line = line;
    new_op->next = head;
    head = new_op;
}

void print_operations() {
    Operation *current = head;
    while (current != NULL) {
        printf("Operation: %s, Operand1: %s, Operand2: %s, Result: %d, Line: %d\n",
               current->op, current->operand1_name, current->operand2_name, current->result, current->line);
        current = current->next;
    }
}

void add_variable(char *name, int value, const char *source) {
    Variable *var = (Variable *)malloc(sizeof(Variable));
    var->name = strdup(name);
    var->value = value;
    var->source = strdup(source);
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

char* get_variable_source(char *name) {
    Variable *current = var_head;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current->source;
        }
        current = current->next;
    }
    return "undefined";
}

char* get_or_create_intermediate_name() {
    static int counter = 0;
    char *name = (char *)malloc(20 * sizeof(char));
    sprintf(name, "intermediate_%d", counter++);
    return name;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

%}

%union {
    int boolean;
    char *text;
    struct {
        int value;
        char *name;
    } expr_info;
}

%token <boolean> BOOL
%token <text> IDENTIFIER
%token AND OR NOT LPAREN RPAREN

%type <expr_info> expr term factor

%locations

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
        add_variable($1, $3.value, "defined");
        printf("Assigned %s = %d\n", $1, $3.value);
    }
    | expr ';' { printf("Final result: %d\n", $1.value); }
;

expr:
    expr OR term {
        char *name1 = $1.name ? $1.name : get_or_create_intermediate_name();
        char *name2 = $3.name ? $3.name : get_or_create_intermediate_name();
        printf("Performing OR: %s (%d, %s) || %s (%d, %s) at line %d\n",
               name1, $1.value, get_variable_source(name1), name2, $3.value, get_variable_source(name2), @$.first_line);
        $$.value = $1.value || $3.value;
        add_operation("OR", name1, name2, $$.value, @$.first_line);
        printf("Result after OR: %d\n", $$.value);
        $$.name = get_or_create_intermediate_name();
    }
    | term {
        $$.value = $1.value;
        $$.name = $1.name;
    }
;

term:
    term AND factor {
        char *name1 = $1.name ? $1.name : get_or_create_intermediate_name();
        char *name2 = $3.name ? $3.name : get_or_create_intermediate_name();
        printf("Performing AND: %s (%d, %s) && %s (%d, %s) at line %d\n",
               name1, $1.value, get_variable_source(name1), name2, $3.value, get_variable_source(name2), @$.first_line);
        $$.value = $1.value && $3.value;
        add_operation("AND", name1, name2, $$.value, @$.first_line);
        printf("Result after AND: %d\n", $$.value);
        $$.name = get_or_create_intermediate_name();
    }
    | factor {
        $$.value = $1.value;
        $$.name = $1.name;
    }
;

factor:
    NOT factor {
        printf("Performing NOT: !%d\n", $2.value);
        $$.value = !$2.value;
        printf("Result after NOT: %d\n", $$.value);
        $$.name = get_or_create_intermediate_name();
    }
    | BOOL {
        $$.value = $1;
        $$.name = NULL;
    }
    | IDENTIFIER {
        $$.value = get_variable($1);
        $$.name = $1;
    }
    | LPAREN expr RPAREN {
        $$.value = $2.value;
        $$.name = $2.name;
    }
;