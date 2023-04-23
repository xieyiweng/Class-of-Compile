%{
#include <iostream>
using namespace std;

#include "lex.c"

struct Node *cldArray[10];
int cldN;
string nTag;
int yylex();
void yyerror(const char* msg) {
  printf("%s! : (%d, %d) [ %s ]\n", msg, row, col, yytext);
  return;
}

%}

%union {
    struct Node* node;
}

%token <node> AND ARRAY BEGIN BY DIV DO ELSE ELSIF END EXIT FOR IF IN IS LOOP MOD NOT OF OR OUT PROCEDURE PROGRAM READ RECORD RETURN THEN TO TYPE VAR WHILE WRITE
%token <node> STRING INTEGER REAL ID
%token <node> WS T_EOF BADCOMMENT UNPRINTABLE ENTER COMMENT BADSTRING

%token <node> M_D F_X D_F D_D X_D S_B

%type <node> program 
%type <node> body 
%type <node> declaration
%type <node> statement
%type <node> var_decl
%type <node> type_decl
%type <node> procedure_decl
%type <node> write_expr
%type <node> expression
%type <node> type
%type <node> formal_params
%type <node> component
%type <node> fp_section
%type <node> actual_params
%type <node> write_params
%type <node> number
%type <node> l_value
%type <node> unary_op
%type <node> binary_op
%type <node> array_values
%type <node> array_value
%type <node> comp_values

%type <node> declaration_s
%type <node> statement_s
%type <node> D_ID_s
%type <node> M_type_c
%type <node> component_s
%type <node> F_fp_section_s
%type <node> D_l_value_s
%type <node> ELSIF_expression_THEN_statement_s_s
%type <node> ELSE_statement_s_c
%type <node> BY_expression_c
%type <node> expression_c
%type <node> D_write_expr_s
%type <node> D_expression_s
%type <node> F_ID_M_D_expression_s
%type <node> D_array_value_s
%type <node> expression_OF_c
%type <node> var_decl_s
%type <node> type_decl_s
%type <node> procedure_decl_s

%%
program: {}
  | PROGRAM IS body ';' {nTag="program"; cldN=1; cldArray[0]=$3; $$=createNode(nTag, cldN, cldArray); treePrint($$);}
  ;
body: declaration_s BEGIN statement_s END {nTag="body"; cldN=2; cldArray[0]=$1; cldArray[1]=$3; $$=createNode(nTag, cldN, cldArray);}
  ;
declaration_s: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | declaration declaration_s {nTag="epsilon"; cldN=2; cldArray[0]=$1; cldArray[1]=$2; $$=createNode(nTag, cldN, cldArray);}
  ;
statement_s: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | statement statement_s {nTag="epsilon"; cldN=2; cldArray[0]=$1; cldArray[1]=$2; $$=createNode(nTag, cldN, cldArray);}
  ;
declaration: VAR var_decl_s {nTag="delaration"; cldN=1; cldArray[0]=$2; $$=createNode(nTag, cldN, cldArray);}
  | TYPE type_decl_s {nTag="delaration"; cldN=1; cldArray[0]=$2; $$=createNode(nTag, cldN, cldArray);}
  | PROCEDURE procedure_decl_s {nTag="delaration"; cldN=1; cldArray[0]=$2; $$=createNode(nTag, cldN, cldArray);}
  ;
var_decl_s: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | var_decl var_decl_s {nTag="epsilon"; cldN=2; cldArray[0]=$1; cldArray[1]=$2; $$=createNode(nTag, cldN, cldArray);}
  ;
type_decl_s: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | type_decl type_decl_s {nTag="epsilon"; cldN=2; cldArray[0]=$1; cldArray[1]=$2; $$=createNode(nTag, cldN, cldArray);}
  ;
procedure_decl_s: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | procedure_decl procedure_decl_s {nTag="epsilon"; cldN=2; cldArray[0]=$1; cldArray[1]=$2; $$=createNode(nTag, cldN, cldArray);}
  ;
var_decl: ID D_ID_s M_type_c M_D expression ';' {nTag="var_decl"; cldN=4; cldArray[0]=$1; cldArray[1]=$2; cldArray[2]=$3; cldArray[3]=$5; $$=createNode(nTag, cldN, cldArray);}
  ;
D_ID_s: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | ',' ID D_ID_s {nTag="epsilon"; cldN=2; cldArray[0]=$2; cldArray[1]=$3; $$=createNode(nTag, cldN, cldArray);}
  ;
M_type_c: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | ':' type {nTag="epsilon"; cldN=1; cldArray[0]=$2; $$=createNode(nTag, cldN, cldArray);}
  ;
type_decl: ID IS type ';' {nTag="type_decl"; cldN=2; cldArray[0]=$1; cldArray[1]=$3; $$=createNode(nTag, cldN, cldArray);}
  ;
procedure_decl: ID formal_params M_type_c IS body ';' {nTag="procedure_decl"; cldN=4; cldArray[0]=$1; cldArray[1]=$2; cldArray[2]=$3; cldArray[3]=$5; $$=createNode(nTag, cldN, cldArray);}
  ;
type: ID {nTag="type"; cldN=1; cldArray[0]=$1; $$=createNode(nTag, cldN, cldArray);}
  | ARRAY OF type {nTag="type"; cldN=1; cldArray[0]=$3; $$=createNode(nTag, cldN, cldArray);}
  | RECORD component component_s END {nTag="type"; cldN=2; cldArray[0]=$2; cldArray[1]=$3; $$=createNode(nTag, cldN, cldArray);}
  ;
component: ID ':' type ';' {nTag="component"; cldN=2; cldArray[0]=$1; cldArray[1]=$3; $$=createNode(nTag, cldN, cldArray);}
  ;
component_s: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | component component_s {nTag="epsilon"; cldN=2; cldArray[0]=$1; cldArray[1]=$2; $$=createNode(nTag, cldN, cldArray);}
  ;
formal_params: '(' fp_section F_fp_section_s ')' {nTag="formal_params"; cldN=2; cldArray[0]=$2; cldArray[1]=$3; $$=createNode(nTag, cldN, cldArray);}
  | '('')' {nTag="formal_params"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  ;
F_fp_section_s: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | ';' fp_section F_fp_section_s {nTag="epsilon"; cldN=2; cldArray[0]=$2; cldArray[1]=$3; $$=createNode(nTag, cldN, cldArray);}
  ;
fp_section: ID D_ID_s ':' type {nTag="fp_section"; cldN=3; cldArray[0]=$1; cldArray[1]=$2; cldArray[2]=$4; $$=createNode(nTag, cldN, cldArray);}
  ;
statement: l_value M_D expression ';' {nTag="statement"; cldN=2; cldArray[0]=$1; cldArray[1]=$3; $$=createNode(nTag, cldN, cldArray);}
  | ID actual_params ';' {nTag="statement"; cldN=2; cldArray[0]=$1; cldArray[1]=$2; $$=createNode(nTag, cldN, cldArray);}
  | READ '(' l_value D_l_value_s ')' ';' {nTag="statement"; cldN=2; cldArray[0]=$3; cldArray[1]=$4; $$=createNode(nTag, cldN, cldArray);}
  | WRITE write_params ';' {nTag="statement"; cldN=1; cldArray[0]=$2; $$=createNode(nTag, cldN, cldArray);}
  | IF expression THEN statement_s ELSIF_expression_THEN_statement_s_s ELSE_statement_s_c END ';' {nTag="statement"; cldN=4; cldArray[0]=$2; cldArray[1]=$4; cldArray[2]=$5; cldArray[3]=$6; $$=createNode(nTag, cldN, cldArray);}
  | WHILE expression DO statement_s END ';' {nTag="statement"; cldN=2; cldArray[0]=$2; cldArray[1]=$4; $$=createNode(nTag, cldN, cldArray);}
  | LOOP statement_s END ';' {nTag="statement"; cldN=1; cldArray[0]=$2; $$=createNode(nTag, cldN, cldArray);}
  | FOR ID M_D expression TO expression BY_expression_c DO statement_s END ';' {nTag="statement"; cldN=5; cldArray[0]=$2; cldArray[1]=$4; cldArray[2]=$6; cldArray[3]=$7; cldArray[4]=$9; $$=createNode(nTag, cldN, cldArray);}
  | EXIT ';' {nTag="statement"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  | RETURN expression_c ';' {nTag="statement"; cldN=1; cldArray[0]=$2; $$=createNode(nTag, cldN, cldArray);}
  ;
D_l_value_s: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | ',' l_value D_l_value_s {nTag="epsilon"; cldN=2; cldArray[0]=$2; cldArray[1]=$3; $$=createNode(nTag, cldN, cldArray);}
  ;
ELSIF_expression_THEN_statement_s_s: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | ELSIF expression THEN statement_s ELSIF_expression_THEN_statement_s_s {nTag="epsilon"; cldN=3; cldArray[0]=$2; cldArray[1]=$4; cldArray[2]=$5; $$=createNode(nTag, cldN, cldArray);}
  ;
ELSE_statement_s_c: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | ELSE statement_s {nTag="epsilon"; cldN=1; cldArray[0]=$2; $$=createNode(nTag, cldN, cldArray);}
  ;
BY_expression_c: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | BY expression {nTag="epsilon"; cldN=1; cldArray[0]=$2; $$=createNode(nTag, cldN, cldArray);}
  ;
expression_c: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | expression {nTag="epsilon"; cldN=1; cldArray[0]=$1; $$=createNode(nTag, cldN, cldArray);}
  ;
write_params: '(' write_expr D_write_expr_s ')' {nTag="write_params"; cldN=2; cldArray[0]=$2; cldArray[1]=$3; $$=createNode(nTag, cldN, cldArray);}
  | '('')' {nTag="write_params"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  ;
D_write_expr_s: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | ',' write_expr D_write_expr_s {nTag="epsilon"; cldN=2; cldArray[0]=$2; cldArray[1]=$3; $$=createNode(nTag, cldN, cldArray);}
  ;
write_expr: STRING {nTag="write_expr"; cldN=1; cldArray[0]=$1; $$=createNode(nTag, cldN, cldArray);}
  | expression {nTag="write_expr"; cldN=1; cldArray[0]=$1; $$=createNode(nTag, cldN, cldArray);}
  ;
expression: number {nTag="expression"; cldN=1; cldArray[0]=$1; $$=createNode(nTag, cldN, cldArray);}
  | l_value {nTag="expression"; cldN=1; cldArray[0]=$1; $$=createNode(nTag, cldN, cldArray);}
  | '(' expression ')' {nTag="expression"; cldN=1; cldArray[0]=$2; $$=createNode(nTag, cldN, cldArray);}
  | unary_op expression {nTag="expression"; cldN=2; cldArray[0]=$1; cldArray[1]=$2; $$=createNode(nTag, cldN, cldArray);}
  | expression binary_op expression {nTag="expression"; cldN=3; cldArray[0]=$1; cldArray[1]=$2; cldArray[2]=$3; $$=createNode(nTag, cldN, cldArray);}
  | ID actual_params {nTag="expression"; cldN=2; cldArray[0]=$1; cldArray[1]=$2; $$=createNode(nTag, cldN, cldArray);}
  | ID comp_values {nTag="expression"; cldN=2; cldArray[0]=$1; cldArray[1]=$2; $$=createNode(nTag, cldN, cldArray);}
  | ID array_values {nTag="expression"; cldN=2; cldArray[0]=$1; cldArray[1]=$2; $$=createNode(nTag, cldN, cldArray);}
  ;
l_value: ID {nTag="l_value"; cldN=1; cldArray[0]=$1; $$=createNode(nTag, cldN, cldArray);}
  | l_value '[' expression ']' {nTag="l_value"; cldN=2; cldArray[0]=$1; cldArray[1]=$3; $$=createNode(nTag, cldN, cldArray);}
  | l_value '.' ID {nTag="l_value"; cldN=2; cldArray[0]=$1; cldArray[1]=$3; $$=createNode(nTag, cldN, cldArray);}
  ;
actual_params: '(' expression D_expression_s ')' {nTag="actual_params"; cldN=2; cldArray[0]=$2; cldArray[1]=$3; $$=createNode(nTag, cldN, cldArray);}
  | '('')' {nTag="actual_params"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  ;
D_expression_s: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | ',' expression D_expression_s {nTag="epsilon"; cldN=2; cldArray[0]=$2; cldArray[1]=$3; $$=createNode(nTag, cldN, cldArray);}
  ;
comp_values: '{' ID M_D expression F_ID_M_D_expression_s '}' {nTag="comp_values"; cldN=3; cldArray[0]=$2; cldArray[1]=$4; cldArray[2]=$5; $$=createNode(nTag, cldN, cldArray);}
  ;
F_ID_M_D_expression_s: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | ';' ID M_D expression F_ID_M_D_expression_s {nTag="epsilon"; cldN=3; cldArray[0]=$2; cldArray[1]=$4; cldArray[2]=$5; $$=createNode(nTag, cldN, cldArray);}
  ;
array_values: F_X array_value D_array_value_s D_F {nTag="array_values"; cldN=2; cldArray[0]=$2; cldArray[1]=$3; $$=createNode(nTag, cldN, cldArray);}
  ;
D_array_value_s: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | ',' array_value D_array_value_s {nTag="epsiolon"; cldN=2; cldArray[0]=$2; cldArray[1]=$3; $$=createNode(nTag, cldN, cldArray);}
  ;
array_value: expression_OF_c expression {nTag="array_value"; cldN=2; cldArray[0]=$1; cldArray[1]=$2; $$=createNode(nTag, cldN, cldArray);}
  ;
expression_OF_c: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | expression OF {nTag="epsilon"; cldN=1; cldArray[0]=$1; $$=createNode(nTag, cldN, cldArray);}
  ;
number: INTEGER {nTag="number"; cldN=1; cldArray[0]=$1; $$=createNode(nTag, cldN, cldArray);}
  | REAL {nTag="number"; cldN=1; cldArray[0]=$1; $$=createNode(nTag, cldN, cldArray);}
  ;
unary_op: '+' {nTag="unary_op"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  | '-' {nTag="unary_op"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  | NOT {nTag="unary_op"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  ;
binary_op: '+' {nTag="binary_op"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  | '-' {nTag="binary_op"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  | '*' {nTag="binary_op"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  | '/' {nTag="binary_op"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  | DIV {nTag="binary_op"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  | MOD {nTag="binary_op"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  | OR {nTag="binary_op"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  | AND {nTag="binary_op"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  | '>' {nTag="binary_op"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  | '<' {nTag="binary_op"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  | '=' {nTag="binary_op"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  | D_D {nTag="binary_op"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  | X_D {nTag="binary_op"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  | S_B {nTag="binary_op"; cldN=0; $$=createNode(nTag, cldN, cldArray);}
  ;
%%
