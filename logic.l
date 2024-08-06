%{
#include "logic.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void add_variable(char *name, int value);
int get_variable(char *name);
char* get_variable_source(char *name);
char* get_or_create_intermediate_name();
%}

%option noyywrap
%option yylineno

%%
[ \t\n]+                ;  // 忽略空白符
"&&"                    { return AND; }
"||"                    { return OR; }
"!"                     { return NOT; }
"="                     { return '='; }
";"                     { return ';'; }
"("                     { return LPAREN; }
")"                     { return RPAREN; }
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.text = strdup(yytext); return IDENTIFIER; }
[0-9]+                  {
                          yylval.boolean = atoi(yytext);
                          return BOOL;
                        }
.                       { printf("Unexpected character: %s\n", yytext); return 0; }
%%