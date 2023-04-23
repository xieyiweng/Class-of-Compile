#include <iostream>
#include <cstdio>
#include "lexer.h"
#include <iomanip>
#include <string>
#include <fstream>
#include <stdlib.h>
#include <math.h>

using namespace std;

int yylex();
extern "C" FILE *yyin;
extern "C" char *yytext;
extern "C" int yyleng;

string decoder (int x) {
    switch (x) {
        case 1:     return "interger";
        case 2:     return "real";
        case 3:     return "string";
        case 4:     return "reserved keyword";
        case 5:     return "delimiter";
        case 6:     return "operator";
        case 7:     return "identifier";
        case 8:     return "comment";
        case 9:     return "string";
        case 10:    return "comment";
        case 11:    return "unprintable";
        default:    return ""; 
    }
}

int main(int argc, char **argv)
{
    if (argc > 1){
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    int row = 1;
    int col = 1;
    int token_count = 0;
    int error_count = 0;
    ofstream outfile;
    outfile.open("case.txt", ofstream::app);
    fstream file("case.txt", ios::out);
    outfile.setf(ios::left);
    outfile << setw(5)<< "ROW" << setw(5) << "COL" << setw(18) << "TYPE" << setw(18) << "TOKEN/ERROR MESSAGE" << endl;
    while (true){
        int n = yylex();
        if (n == T_EOF){
            break;
        } 
        else if (n == WS) {
            col += yyleng;
            continue;
        }
        else if (n == ENTER) {
            row++;
            col = 1;
            continue;
        }
        else if (n == COMMENT) {
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
            continue;
        }
        else if (n == STRING) {
            int tab_num = 0;
            if (yyleng > 257) {
                outfile << setw(5)<< row << setw(5) << col << setw(18) << decoder(n) << setw(18) << "ERROR: an overly long string" << endl;
                error_count++;
                col += yyleng;
                continue;
            }
            for (int i = 0; i != yyleng; i++) 
                if (yytext[i] == '\t') tab_num++;
            if (tab_num == 1) {
                outfile << setw(5)<< row << setw(5) << col << setw(18) << decoder(n) << setw(18) << "ERROR: an invalid string with tab in it" << endl;
                error_count++;
                col += yyleng;
                continue;
            } else if (tab_num > 1) {
                outfile << setw(5)<< row << setw(5) << col << setw(18) << decoder(n) << setw(18) << "ERROR: an invalid string with many tabs in it" << endl;
                error_count++;
                col += yyleng;
                continue;
            }
        }
        else if (n == INTERGER) {
            if (yyleng > 9) {
                outfile << setw(5)<< row << setw(5) << col << setw(18) << decoder(n) << setw(18) << "ERROR: an out of range integer" << endl;
                error_count++;
                col += yyleng;
                continue;
            }
            double tmp = 0;
            for (int i = 0; i != yyleng; i++) {
                tmp *= 10;
                tmp += (int(yytext[i]) - 48);
            }
            if (tmp > (pow(2, 31) - 1)) {
                outfile << setw(5)<< row << setw(5) << col << setw(18) << decoder(n) << setw(18) << "ERROR: an out of range integer" << endl;
                error_count++;
                col += yyleng;
                continue;
            }
        }
        else if (n == IDENTIFIER) {
            if (yyleng > 255) {
                outfile << setw(5)<< row << setw(5) << col << setw(18) << decoder(n) << setw(18) << "ERROR: an overly long identifier" << endl;
                error_count++;
                col += yyleng;
                continue;
            }
        }
        else if (n == BADSTRING) {
            outfile << setw(5)<< row << setw(5) << col << setw(18) << decoder(n) << setw(18) << "ERROR: an unterminated string" << endl;
            error_count++;
            row++;
            col += yyleng;
            continue;
        }
        else if (n == BADCOMMENT) {
            outfile << setw(5)<< row << setw(5) << col << setw(18) << decoder(n) << setw(18) << "ERROR: an unterminated comment" << endl;
            error_count++;
            col += yyleng;
            continue;
        }
        else if (n == UNPRINTABLE) {
            outfile << setw(5)<< row << setw(5) << col << setw(18) << decoder(n) << setw(18) << "ERROR: a bad character (bell)" << endl;
            error_count++;
            col += yyleng;
            continue;
        }
        token_count++;
        outfile << setw(5)<< row << setw(5) << col << setw(18) << decoder(n) << setw(18) << yytext << endl;
        col += yyleng;
    }
    outfile << "The number of tokens are " << token_count << endl;
    outfile << "The number of errors are " << error_count << endl;
    outfile.close();
    return 0;
}
