%{
#include "lexer.h"
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
RESERVED_KEYWORD    AND|ARRAY|BEGIN|BY|DIV|DO|ELSE|ELSIF|END|EXIT|FOR|IF|IN|IS|LOOP|MOD|NOT|OF|OR|OUT|PROCEDURE|PROGRAM|READ|RECORD|RETURN|THEN|TO|TYPE|VAR|WHILE|WRITE
DELIMITER           ":"|";"|","|"."|"("|")"|"["|"]"|"{"|"}"|"[<"|">]"|"\\"
OPERATOR            ":="|"\+"|"-"|"\*"|"/"|"<"|"<="|">"|">="|"="|"<>"
IDENTIFIER          {LETTER}{LETTER_OR_DIGIT}*

%%
{WS}                            return WS;
<<EOF>>                         return T_EOF;
"\n"                            return ENTER;
{INTEGER}                       return INTERGER;
{REAL}                          return REAL;
{STRING}                        return STRING;
{RESERVED_KEYWORD}              return RESERVED_KEYWORD;
{DELIMITER}                     return DELIMITER;
{OPERATOR}                      return OPERATOR;
{IDENTIFIER}                    return IDENTIFIER;
{COMMENT}                       return COMMENT;
{BADSTRING}                     return BADSTRING;
{BADCOMMENT}                    return BADCOMMENT;
{UNPRINTABLE}                   return UNPRINTABLE;

%%
