#include <stdio.h>
#include "logic.tab.h"

extern int yyparse();
extern FILE *yyin;

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror(argv[1]);
            return 1;
        }
        yyin = file;
    }
    yyparse();
    return 0;
}