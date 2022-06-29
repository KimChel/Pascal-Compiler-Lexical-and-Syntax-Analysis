%{  
    // #include "token.h"  The previous tokens used for the execution of Flex
    #include "compiler.tab.h"
    #include <stdio.h>
    #include <stdlib.h>
    #include <math.h>
    #include <string.h>
    #include <unistd.h>

    int errorCnt = 0;
    int lineno = 1;
    char str_buf[256];

    void PRINT_TOK(int token_id);
    int BINHEX_TO_INT(char *str);
    float FBINHEX_TO_FLOAT(char *str);
%}

%option noyywrap
%option case-insensitive
%option yylineno

%x PSTRING
%x COMMENTS



/*Assigning Regular Expressions*/
LETTER                  [a-zA-Z]
LETTER_                 [a-zA-Z_]
DIGIT                   [0-9]
ALPHANUM                [a-zA-Z0-9]
ALPHANUM_               [a-zA-Z0-9_]
DIGITNOZERO             [1-9][0-9]
BINARY                  [01]
HEXADECIMAL             [0-9A-F]
ASCII                   [ !#$"%&'()*+,-./:;<=>?@\[\\\]^_`{|}~]
ID                      {LETTER_}+{ALPHANUM_}*
ICONST                  {DIGIT}|{DIGITNOZERO}*|0H[1-9A-F]{HEXADECIMAL}*|0B1{BINARY}*|0
RCONST                  {DIGIT}*\.{DIGIT}+[1-9]*|\.?[1-9][0-9]*[Ee][+-]?[0-9]+|0H[0-9A-F\.]+|0B1?\.{BINARY}*|0
ALPHANUMINAPOS          \'{ALPHANUM}\'
ASCIIAPOSTROPHE         \'{ASCII}\'





%%
"PROGRAM"               {PRINT_TOK(P_PROGRAM); return P_PROGRAM;}
"CONST"                 {PRINT_TOK(P_CONST); return P_CONST;}
"TYPE"                  {PRINT_TOK(P_TYPE); return P_TYPE;}
"ARRAY"                 {PRINT_TOK(P_SET); return P_SET;}
"SET"                   {PRINT_TOK(P_OF); return P_OF;}
"OF"                    {PRINT_TOK(P_RECORD); return P_RECORD;}
"VAR"                   {PRINT_TOK(P_VAR); return P_VAR;}
"FORWARD"               {PRINT_TOK(P_FORWARD); return P_FORWARD;}
"FUNCTION"              {PRINT_TOK(P_FUNCTION); return P_FUNCTION;}
"PROCEDURE"             {PRINT_TOK(P_PROCEDURE); return P_PROCEDURE;}
"INTEGER"               {PRINT_TOK(P_INTEGER); return P_INTEGER;}
"REAL"                  {PRINT_TOK(P_REAL); return P_REAL;}
"BOOLEAN"               {PRINT_TOK(P_BOOLEAN); return P_BOOLEAN;}
"CHAR"                  {PRINT_TOK(P_CHAR); return P_CHAR;}                  
"BEGIN"                 {PRINT_TOK(P_BEGIN); return P_BEGIN;}
"END"                   {PRINT_TOK(P_END); return P_END;}
"IF"                    {PRINT_TOK(P_IF); return P_IF;}
"THEN"                  {PRINT_TOK(P_THEN); return P_THEN;}
"ELSE"                  {PRINT_TOK(P_ELSE); return P_ELSE;}
"WHILE"                 {PRINT_TOK(P_WHILE); return P_WHILE;}
"DO"                    {PRINT_TOK(P_DO); return P_DO;}
"FOR"                   {PRINT_TOK(P_FOR); return P_FOR;}
"DOWNTO"                {PRINT_TOK(P_DOWNTO); return P_DOWNTO;}
"TO"                    {PRINT_TOK(P_TO); return P_TO;}
"WITH"                  {PRINT_TOK(P_WITH); return P_WITH;}
"READ"                  {PRINT_TOK(P_READ); return P_READ;}
"WRITE"                 {PRINT_TOK(P_WRITE); return P_WRITE;}
"TRUE"                  {PRINT_TOK(P_BCONST); return P_BCONST;}
"FALSE"                 {PRINT_TOK(P_BCONST); return P_BCONST;}

{ALPHANUMINAPOS}        {PRINT_TOK(P_CCONST); return P_CCONST;}
{ASCIIAPOSTROPHE}       {PRINT_TOK(P_CCONST); return P_CCONST;}

\'\\n\'                 {PRINT_TOK(P_CCONST); return P_CCONST;}
\'\\f\'                 {PRINT_TOK(P_CCONST); return P_CCONST;}
\'\\t\'                 {PRINT_TOK(P_CCONST); return P_CCONST;}
\'\\r\'                 {PRINT_TOK(P_CCONST); return P_CCONST;}
\'\\b\'                 {PRINT_TOK(P_CCONST); return P_CCONST;}
\'\\v\'                 {PRINT_TOK(P_CCONST); return P_CCONST;}

 /*TELESTES*/
">"|">="|"<"|"<="|"<>"  {PRINT_TOK(P_RELOP); return P_RELOP;}

"+"|"-"                 {PRINT_TOK(P_ADDOP); return P_ADDOP;}

"or"                    {PRINT_TOK(P_OROP); return P_OROP;}

"*"|"/"|"DIV"|"MOD"|"AND" {PRINT_TOK(P_MULDIVANDOP); return P_MULDIVANDOP;}

"not"                   {PRINT_TOK(P_NOTOP); return P_NOTOP;}

"in"                    {PRINT_TOK(P_INOP); return P_INOP;}


{ID}                    {PRINT_TOK(P_ID); return P_ID;}
{ICONST}                {PRINT_TOK(P_ICONST); return P_ICONST;}
{RCONST}                {PRINT_TOK(P_RCONST); return P_RCONST;}


 /*ALLES LEKTIKES MONADES*/

"("                     {PRINT_TOK(P_LPAREN); return P_LPAREN;}
")"                     {PRINT_TOK(P_RPAREN); return P_RPAREN;}
";"                     {PRINT_TOK(P_SEMI); return P_SEMI;}
"."                     {PRINT_TOK(P_DOT); return P_DOT;} 
","                     {PRINT_TOK(P_COMMA); return P_COMMA;}
"="                     {PRINT_TOK(P_EQU); return P_EQU;}
":"                     {PRINT_TOK(P_COLON); return P_COLON;}
"["                     {PRINT_TOK(P_LBRACK); return P_LBRACK;}
"]"                     {PRINT_TOK(P_RBRACK); return P_RBRACK;}
":="                    {PRINT_TOK(P_ASSIGN); return P_ASSIGN;}
".."                    {PRINT_TOK(P_DOTDOT); return P_DOTDOT;}
[ \t]                   {   }
\n                      {printf("Line: %d\n", yylineno);}
\r\n                    {   }




\{                      {BEGIN(COMMENTS);}
<COMMENTS>\}             {BEGIN(INITIAL); printf(" Found comment returning: %d\n", P_COMM); return P_COMM;}
<COMMENTS>(\n|\r\n)     {   }
<COMMENTS><<EOF>>       {printf("Unfinished Comment\n");}






\"                      {BEGIN(PSTRING);}
<PSTRING>\"             {BEGIN(INITIAL); printf(" Found string returning: %d\n", P_SCONST); return P_SCONST;}
<PSTRING>(\\\n|\\\r\n)  {printf("string new line\n");}
<PSTRING>(\\.|[^"\\])   {   if (strlen(yytext) == 2){
                                if(strcmp(yytext, "\\n") == 0){
                                    strcat(str_buf, "\n");
                                }else if(strcmp(yytext, "\\t") == 0){
                                    strcat(str_buf, "\t");
                                }else if(strcmp(yytext, "\\f") == 0){
                                    strcat(str_buf, "\f");
                                }else if(strcmp(yytext, "\\r") == 0){
                                    strcat(str_buf, "\r");
                                }else if(strcmp(yytext, "\\b") == 0){
                                    strcat(str_buf, "\b");
                                }else if(strcmp(yytext, "\\v") == 0){
                                    strcat(str_buf, "\v");
                                }else{
                                    strcat(str_buf, &yytext[1]);
                                }

                            }else{
                                strcat(str_buf, yytext);
                            }
                        }
<PSTRING>(\n|\r\n)      {printf("found new line\n");}
<PSTRING>.              {printf("unknown\n");}
<PSTRING><<EOF>>        {printf("end of string without exiting it\n");}

.                       {printf("unknown\n");}
<<EOF>>                 {printf("Found End Of File returning: %d\nFile compiled successfully.\n", P_EOF); return P_EOF;}



%%

int main(int argc, char *argv[]){
    int token;
    if(argc > 1){
        yyin = fopen(argv[1], "r");
        if (yyin == NULL){
            perror ("Error");
            return -1;
        }
    }

    do{
        token = yylex();

    }while(token != 0);

    fclose(yyin);
    yyterminate();
}


void PRINT_TOK(int token_id){
    
    if(token_id == P_ICONST){
        printf("Found integer token '%s' with base 10: %d returning: %d at line %d\n", yytext, BINHEX_TO_INT(yytext), token_id, yylineno);
    }
    else if(token_id == P_RCONST){
        printf("Found float token '%s' with base 10: %.2f returning: %d at line %d\n", yytext, FBINHEX_TO_FLOAT(yytext), token_id, yylineno);

    }
    else{
        printf("Found token '%s' returning: %d at line: %d\n", yytext, token_id, yylineno);

    }
}

int BINHEX_TO_INT(char *str){
    if(strncmp(str, "0B", 2) == 0){
        return (int) strtoll(&str[2], NULL, 2);
    }
    else if(strncmp(str, "0H", 2) == 0){
        return (int) strtoll(&str[2], NULL, 16);
    }
    else{
        return (int) strtoll(str, NULL, 10);
    }

}

float FBINHEX_TO_FLOAT(char *str){
    if(strncmp(str, "0B", 2) == 0){
        float number = 0.0;
        int i,length_real;
        char *character;
        character = strchr(str,'.');
        length_real = strlen(character)-1;
        number = (int)strtol(&str[2],&character,2);
        for(i=1;i<=length_real;i++){
            number += (character[i] - '0') * (1/pow(2,i));
    }
        return number;    
    }
    else if(strncmp(str, "0H", 2) == 0){
        float number = 0.0;
        int i,length_real;
        char *character;
        character = strchr(str,'.');
        length_real = strlen(character)-1;
        number = (int)strtol(&str[2],&character,16);
        for(i=1;i<=length_real;i++){
            if(character[i] <= '9')
    			number += (character[i] - '0') * (1/pow(16,i));
    		else
    			number += (character[i] + 10 - 'A') * (1/pow(16,i));
    	}
        return number;
     }else{
        float number = atof(yytext);
        return number;
    } 
}

void yyerror(const char* err){
    errorCnt++;
    printf("[error - line: %d] %s\n", yylineno, err);

    if(errorCnt == 5){
        printf("Errors found max\n");
        exit(EXIT_FAILURE);
    }
    yyless(1);
}

    