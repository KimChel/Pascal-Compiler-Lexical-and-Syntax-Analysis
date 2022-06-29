%{
     #include   <stdio.h>
     #include   <stdlib.h>
     #include   "hash/hashtbl.h"

     extern     FILE* yyin;
     extern     int yylex();
     extern     void yyerror(const char* err);

     HASHTBL *hashtbl;
     int scopecntr = 0;
%}

%define parse.error verbose
%union{
    int intval;
    float floatval;
    char charval;
    char* strval;
    int boolval;
    
}

 //Main pascal keywords
%token <strval>     P_PROGRAM           "program"
%token <strval>     P_CONST             "constant"
%token <strval>     P_TYPE              "type"
%token <strval>     P_ARRAY             "array"
%token <strval>     P_SET               "set"
%token <strval>     P_OF                "of"
%token <strval>     P_RECORD            "record"
%token <strval>     P_VAR               "var"
%token <strval>     P_FORWARD           "forward"
%token <strval>     P_FUNCTION          "function"
%token <strval>     P_PROCEDURE         "procedure"
%token <strval>     P_INTEGER           "integer"
%token <strval>     P_REAL              "real"
%token <strval>     P_BOOLEAN           "boolean"
%token <strval>     P_CHAR              "char"
%token <strval>     P_BEGIN             "begin"
%token <strval>     P_END               "end"
%token <strval>     P_IF                "if"
%token <strval>     P_THEN              "then"
%token <strval>     P_ELSE              "else"
%token <strval>     P_WHILE             "while"
%token <strval>     P_DO                "do"
%token <strval>     P_FOR               "for"
%token <strval>     P_DOWNTO            "downto"
%token <strval>     P_TO                "to"
%token <strval>     P_WITH              "with"
%token <strval>     P_READ              "read"
%token <strval>     P_WRITE             "write"


 //Other Pascal keywords

 //Operators
%token <strval>     P_RELOP             "> or >= or < or <= or <>"
%token <strval>     P_ADDOP             "+ or -"
%token <strval>     P_OROP              "||"
%token <strval>     P_MULDIVANDOP       "* or / or DIV or MOD or AND"
%token <strval>     P_NOTOP             "not"
%token <strval>     P_INOP              "inop"

 //Other ASCII tokens
%token <strval>     P_LPAREN            "("   
%token <strval>     P_RPAREN            ")"
%token <strval>     P_SEMI              ";"
%token <strval>     P_DOT               "."
%token <strval>     P_COMMA             ","  
%token <strval>     P_EQU               "="  
%token <strval>     P_COLON             ":"
%token <strval>     P_LBRACK            "["
%token <strval>     P_RBRACK            "]"
%token <strval>     P_ASSIGN            ":="
%token <strval>     P_DOTDOT            "::"

 //Variables
%token <strval>     P_ID                "ID"

 //Arithmetic and Character Constants
%token <intval>     P_ICONST            "iconst"
%token <floatval>   P_RCONST            "rconst"
%token <boolval>    P_BCONST            "bconst"
%token <charval>    P_CCONST            "cconst"

 //strings and Comments
%token <strval>     P_SCONST            "string"


%token <strval>     P_EOF               0 "eof"

%type <strval>  program header declarations constdefs constant_defs expression variable expressions constant setexpression elexpressions elexpression typedefs type_defs type_def dims limits limit typename standard_type fields field identifiers vardefs variable_defs subprograms subprogram sub_header formal_parameters parameter_list pass comp_statement statements statement assignment if_statement if_tail while_statement for_statement iter_space with_statement subprogram_call io_statement read_list read_item write_list write_item

%left P_COMMA
%right P_ASSIGN 
%left P_INOP
%left P_RELOP P_EQU
%left P_OROP
%left P_ADDOP
%left P_MULDIVANDOP
%left P_NOTOP

%nonassoc LOWER_THAN_ELSE
%nonassoc P_ELSE

%start program

%%

program:            header declarations subprograms comp_statement P_DOT
                    ;
header:             P_PROGRAM P_ID P_SEMI                                   {hashtbl_insert(hashtbl, $2, NULL, scopecntr);}
                    ;
declarations:       constdefs typedefs vardefs
                    ;
constdefs:          P_CONST constant_defs P_SEMI
                    | %empty
                    ;
constant_defs:      constant_defs P_SEMI P_ID P_EQU expression              {hashtbl_insert(hashtbl, $3, NULL, scopecntr);}
                    ;
                    | P_ID P_EQU expression                                 {hashtbl_insert(hashtbl, $1, NULL, scopecntr);}
                    ;
expression:         expression P_RELOP expression
                    | expression P_EQU expression
                    | expression P_INOP expression
                    | expression P_OROP expression
                    | expression P_ADDOP expression
                    | expression P_MULDIVANDOP expression
                    //| expression error expression       {yyerror("No use of operator between the expressions."); yyerrok;}
                    | P_ADDOP expression
                    | P_NOTOP expression
                    | variable
                    | P_ID P_LPAREN expressions P_RPAREN                    {hashtbl_insert(hashtbl, $1, NULL, scopecntr);}
                    | constant
                    | P_LPAREN expression P_RPAREN
                    | setexpression
                    ;
variable:           P_ID                                                    {hashtbl_insert(hashtbl, $1, NULL, scopecntr);}
                    | variable P_DOT P_ID                                   {hashtbl_insert(hashtbl, $3, NULL, scopecntr);}
                    | variable P_LBRACK expressions P_RBRACK
                    ;
expressions:        expressions P_COMMA expression
                    | expression
                    ;
constant:           P_ICONST
                    | P_RCONST
                    | P_BCONST
                    | P_CCONST
                    ;
setexpression:      P_LBRACK elexpressions P_RBRACK
                    | P_LBRACK P_RBRACK
                    //| P_LBRACK error        {yyerror("No closing bracket"); yyerrok;}
                    ;
elexpressions:      elexpressions P_COMMA elexpression
                    | elexpression
                    ;
elexpression:       expression P_DOTDOT expression
                    | expression
                    ;
typedefs:           P_TYPE type_defs P_SEMI
                    | %empty
                    ;
type_defs:          type_defs P_SEMI P_ID P_EQU type_def                    {hashtbl_insert(hashtbl, $3, NULL, scopecntr);}
                    | P_ID P_EQU type_def                                   {hashtbl_insert(hashtbl, $1, NULL, scopecntr);}
                    ;
type_def:           P_ARRAY P_LBRACK dims P_RBRACK P_OF typename
                    | P_SET P_OF typename
                    | P_RECORD fields P_END
                    | P_LPAREN identifiers P_RPAREN
                    | limit P_DOTDOT limit
                    ;
dims:               dims P_COMMA limits
                    | limits
                    ;
limits:             limit P_DOTDOT limit
                    | P_ID                                                  {hashtbl_insert(hashtbl, $1, NULL, scopecntr);}
                    ;
limit:              P_ADDOP P_ICONST
                    | P_ADDOP P_ID                                          {hashtbl_insert(hashtbl, $2, NULL, scopecntr);}
                    | P_ICONST
                    | P_CCONST
                    | P_BCONST
                    | P_ID                                                  {hashtbl_insert(hashtbl, $1, NULL, scopecntr);}
                    ;
typename:           standard_type
                    | P_ID
                    ;
standard_type:      P_INTEGER | P_REAL | P_BOOLEAN | P_CHAR
                    ;
fields:             fields P_SEMI field
                    | field
                    ;
field:              identifiers P_COLON typename
                    ;
identifiers:        identifiers P_COMMA P_ID                                {hashtbl_insert(hashtbl, $3, NULL, scopecntr);}
                    | P_ID                                                  {hashtbl_insert(hashtbl, $1, NULL, scopecntr);}
                    ;
vardefs:            P_VAR variable_defs P_SEMI
                    | %empty
                    ;
variable_defs:      variable_defs P_SEMI identifiers P_COLON typename
                    | identifiers P_COLON typename
                    ;
subprograms:        subprograms subprogram P_SEMI
                    | %empty
                    ;
subprogram:         sub_header P_SEMI P_FORWARD
                    | sub_header P_SEMI declarations subprograms comp_statement
                    ;
sub_header:         P_FUNCTION P_ID formal_parameters P_COLON standard_type {hashtbl_insert(hashtbl, $2, NULL, scopecntr);}
                    | P_PROCEDURE P_ID formal_parameters                    {hashtbl_insert(hashtbl, $2, NULL, scopecntr);}
                    | P_FUNCTION P_ID                                       {hashtbl_insert(hashtbl, $2, NULL, scopecntr);}
                    ;
formal_parameters:  P_LPAREN parameter_list P_RPAREN
                    | %empty
                    ;
parameter_list :    parameter_list P_SEMI pass identifiers P_COLON typename
                    | pass identifiers P_COLON typename
pass:               P_VAR 
                    | %empty
                    ;
comp_statement:     P_BEGIN statements P_END
                    //| P_BEGIN statements error      {yyerror("No 'end' found to terminate the function."); yyerrok;}
                    //| error statements P_END        {yyerror("No 'begin' found to begin the function."); yyerrok;}
                    ;
statements:         statements P_SEMI statement
                    | statement
                    ;
statement:          assignment
                    | if_statement
                    | while_statement
                    | for_statement
                    | with_statement
                    | subprogram_call
                    | io_statement
                    | comp_statement
                    | %empty
                    ;
assignment:         variable P_ASSIGN expression
                    | variable P_ASSIGN P_SCONST
                    ;
if_statement:       P_IF expression P_THEN statement if_tail
                    ;
if_tail:            P_ELSE statement
                    | %empty %prec LOWER_THAN_ELSE
                    ;
while_statement:    P_WHILE expression P_DO statement
                    ;
for_statement:      P_FOR P_ID P_ASSIGN iter_space P_DO statement   {hashtbl_insert(hashtbl, $2, NULL, scopecntr);}
                    ;
iter_space:         expression P_TO expression
                    | expression P_DOWNTO expression
                    ;
with_statement:     P_WITH variable P_DO statement
                    ;
subprogram_call:    P_ID                                            {hashtbl_insert(hashtbl, $1, NULL, scopecntr);}
                    | P_ID P_LPAREN expressions P_RPAREN            {hashtbl_insert(hashtbl, $1, NULL, scopecntr);}
                    ;
io_statement:       P_READ P_LPAREN read_list P_RPAREN
                    | P_WRITE P_LPAREN write_list P_RPAREN
                    ;
read_list:          read_list P_COMMA read_item
                    | read_item
                    ;
read_item:          variable
                    ;
write_list:         write_list P_COMMA write_item
                    | write_item
                    ;
write_item:         expression
                    | P_SCONST
                    ;


%%

int main(int argc, char *argv[]){
    int token;
    
    if (!(hashtbl = hashtbl_create(10, NULL))){
        puts("Error, failed to initialize hashtable");
        exit(EXIT_FAILURE);
    }
    
    
    if(argc > 1){
        yyin = fopen(argv[1], "r");
        if (yyin == NULL){
            perror ("Error");
            return -1;
        }
    }

    yyparse();
    fclose(yyin);
    hashtbl_destroy(hashtbl);
    return 0;
}