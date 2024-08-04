* compile

```
flex logic.l                            
bison -d logic.y                        
gcc lex.yy.c logic.tab.c main.c -o logic
```
