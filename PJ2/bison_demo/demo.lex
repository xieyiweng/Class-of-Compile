%{
#include "yacc.h"
#include <string.h>
#include <iostream>
#include <cstdio>
#include <iomanip>
#include <fstream>
#include <stdlib.h>
#include <math.h>

using namespace std;

int row = 1;
int col = 1;

struct Node {
    string tag;
    char* value;
    struct Node *cld[10];
    int ncld;
	int row;
	int col;
};
struct Node *createLeaf(string tag, char *text) {
	struct Node *nd = (struct Node*)malloc(sizeof(struct Node));
	nd->ncld = 0;
	nd->tag = tag;
	nd->row = row;
	nd->col = col;
	if(tag == "integer" || tag == "real" || tag == "string" || tag == "identifier") //补充
	{
		nd->value=(char*)malloc(sizeof(char)*strlen(text));
		strcpy(nd->value,text);
	}
	else
		nd->value=NULL;
	return nd;
}
struct Node *createNode(string tag, int ncld, struct Node *a[]) {
	struct Node *nd = (struct Node*)malloc(sizeof(struct Node));
	nd->ncld = ncld;
	nd->tag = tag;
	nd->value = NULL;
	nd->row = row;
	nd->col = col;
	for(int i = 0; i < nd->ncld; i++)
		(nd->cld)[i] = a[i];
	return nd;
}
struct Node *createEmpty() {
	struct Node *nd=(struct Node*)malloc(sizeof(struct Node));
	nd->ncld = 0;
	nd->tag = "epsilon";
	nd->value = NULL;
	nd->row = row;
	nd->col = col;
	return nd;
}
void treePrintLevel(struct Node *nd, int lvl) {
	if(nd!=NULL)
	{
        if (nd->tag != "epsilon") {
		    for(int i=0; i<lvl; i++)
			    printf( "|  ");
		
		    if(nd->value==NULL)
			    printf("○ - < %s > (%d, %d)\n", nd->tag.c_str(), nd->row, nd->col);
		    else 
			    printf("● - < %s > : [ %s ] (%d, %d)\n", nd->tag.c_str(), nd->value, nd->row, nd->col);
        }
		for (int i = 0; i < nd->ncld; i++) { 
            if (nd->tag == "epsilon") {
                treePrintLevel((nd->cld)[i], lvl);
            } else {
                treePrintLevel((nd->cld)[i], lvl+1);
            }
		}
	}
	return;
}
void treePrint(struct Node *nd) {
	treePrintLevel(nd, 0);
}

%}
%option     nounput
%option     noyywrap

WS                  [ \t]+
LETTER              [a-zA-Z]
DIGIT               [0-9]
LETTER_OR_DIGIT     [a-zA-Z0-9]
UNPRINTABLE         .
COMMENT             "(*"[^\*]*[\*]+([^\)][^\*]*[\*]+)*")"
BADCOMMENT          "(*"[^\*]*[\*]+([^\)][^\*]*[\*]+)*
INTEGER             {DIGIT}+
REAL                {DIGIT}+"."{DIGIT}*
BADSTRING           "\""[^\"\n]*\n
STRING              "\""[^\"\n]*"\""
IDENTIFIER          {LETTER}{LETTER_OR_DIGIT}*

%%
{WS}        				{col += yyleng;}
<<EOF>>                     {return 0;}
"\n"						{row++; col = 1;}
"AND" 						{col += yyleng; return AND;}
"ARRAY" 					{col += yyleng; return ARRAY;}
"BEGIN" 					{col += yyleng; return BEGIN;}
"BY" 						{col += yyleng; return BY;}
"DIV" 						{col += yyleng; return DIV;}
"DO" 						{col += yyleng; return DO;}
"ELSE" 						{col += yyleng; return ELSE;}
"ELSIF" 					{col += yyleng; return ELSIF;}
"END" 						{col += yyleng; return END;}
"EXIT" 						{col += yyleng; return EXIT;}
"FOR" 						{col += yyleng; return FOR;}
"IF" 						{col += yyleng; return IF;}
"IN" 						{col += yyleng; return IN;}
"IS" 						{col += yyleng; return IS;}
"LOOP" 						{col += yyleng; return LOOP;}
"MOD" 						{col += yyleng; return MOD;}
"NOT" 						{col += yyleng; return NOT;}
"OF" 						{col += yyleng; return OF;}
"OR" 						{col += yyleng; return OR;}
"OUT" 						{col += yyleng; return OUT;}
"PROCEDURE" 				{col += yyleng; return PROCEDURE;}
"PROGRAM" 					{col += yyleng; return PROGRAM;}
"READ" 						{col += yyleng; return READ;}
"RECORD" 					{col += yyleng; return RECORD;}
"RETURN" 					{col += yyleng; return RETURN;}
"THEN" 						{col += yyleng; return THEN;}
"TO" 						{col += yyleng; return TO;}
"TYPE" 						{col += yyleng; return TYPE;}
"VAR" 						{col += yyleng; return VAR;}
"WHILE" 					{col += yyleng; return WHILE;}
"WRITE" 					{col += yyleng; return WRITE;}
":"							{col += yyleng; return ':';}
";"							{col += yyleng; return ';';}
","							{col += yyleng; return ',';}							
"."							{col += yyleng; return '.';}
"("							{col += yyleng; return '(';}
")"							{col += yyleng; return ')';}
"["							{col += yyleng; return '[';}
"]"							{col += yyleng; return ']';}
"{"							{col += yyleng; return '{';}
"}"							{col += yyleng; return '}';}
"[<"						{col += yyleng; return F_X;}
">]"						{col += yyleng; return D_F;}
"\\"						{col += yyleng; return '\\';}
":="						{col += yyleng; return M_D;}
"+"							{col += yyleng; return '+';}
"-"							{col += yyleng; return '-';}
"*"							{col += yyleng; return '*';}
"/"							{col += yyleng; return '/';}
"<"							{col += yyleng; return '<';}
"<="						{col += yyleng; return X_D;}
">"							{col += yyleng; return '>';}
">="						{col += yyleng; return D_D;}
"="							{col += yyleng; return '=';}
"<>"						{col += yyleng; return S_B;}

{INTEGER}   				{
								if (yyleng > 9) {
									printf("(%d, %d) [ %s ] ERROR: an out of range integer\n", row, col, yytext);
								}
								double tmp = 0;
								for (int i = 0; i != yyleng; i++) {
									tmp *= 10;
									tmp += (int(yytext[i]) - 48);
								}
								if (tmp > (pow(2,31) - 1)) {
									printf("(%d, %d) [ %s ] ERROR: an out of range integer\n", row, col, yytext);
								}
								col += yyleng; 
								yylval.node = createLeaf("integer", yytext); 
								return INTEGER;
							}
{REAL}  					{col += yyleng; yylval.node = createLeaf("real", yytext); return REAL;}
{STRING}    				{
								int tab_num = 0;
								if (yyleng > 257) {
									printf("(%d, %d) [ %s ] ERROR: an overly long string\n", row, col, yytext);
								}
								for (int i = 0; i != yyleng; i++)
									if (yytext[i] == '\t') tab_num++;
								if (tab_num == 1) {
									printf("(%d, %d) [ %s ] ERROR: an invalid string with tab in it\n", row, col, yytext);
								} else if (tab_num > 1) {
									printf("(%d, %d) [ %s ] ERROR: an invalid string with many tabs in it\n", row, col, yytext);
								}
								col += yyleng; 
								yylval.node = createLeaf("string", yytext);
								return STRING;
							}
{IDENTIFIER}    			{
								if (yyleng > 255) {
									printf("(%d, %d) [ %s ] ERROR: an overly long identifier\n", row, col, yytext);
								}
								col += yyleng;
								yylval.node = createLeaf("identifier", yytext);
								return ID;}

{COMMENT}    				{
								int length = 1;
            					for (int i = 0; i != yyleng; i++) {
                					if (yytext[i] == '\n') {
                    					row++;
                    					col = 1;
                    					length = 0;
                					} else {
                    					length++;
                					}
            					}
            					col += length; 
							}
{BADSTRING}                 {
								printf("(%d, %d) [ %s ] ERROR: an unterminated string\n", row, col, yytext);
								return BADSTRING;
							}
{BADCOMMENT}                {
								printf("(%d, %d) [ %s ] ERROR: an unterminated comment\n", row, col, yytext);
								return BADCOMMENT;
							}
{UNPRINTABLE}               {
								printf("(%d, %d) [ %s ] ERROR: a bad character (bell)\n", row, col, yytext);
								return UNPRINTABLE;
							}

%%
