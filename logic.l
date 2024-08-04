%{
#include "logic.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%option noyywrap

%%
[ \t\n]               ;  // ignore tab space
"&&"                  { return AND; }
"||"                  { return OR; }
"!"                   { return NOT; }
"("                   { return LPAREN; }
")"                   { return RPAREN; }
[0-9]+                {
                        //printf("Found number: %s\n", yytext);
                        yylval.boolean = atoi(yytext);
                        yylval.origin_value = atoi(yytext);
                        return BOOL;
                      }
.                     { printf("Unexpected character: %s\n", yytext); return 0; }
%%
