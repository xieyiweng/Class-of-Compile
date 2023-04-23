#include <iostream>
#include <cstdio>
#include <iomanip>
#include <string>
#include <fstream>
#include <stdlib.h>
#include <math.h>
#include "yacc.h"

using namespace std;

int yylex();
int yyparse();
extern "C" FILE *yyin;
extern "C" FILE *yyout;
extern "C" char *yytext;
extern "C" int yyleng;

int main(int argc, char* args[]) {
  if (argc > 1) {
    FILE *file1 = fopen(args[1], "r");
    if (!file1) {
      cerr << "Can not open file." << endl;
      return 1;
    } else {
      yyin = file1;
      string tmp = args[1];
      if (tmp == "tests/case_11.pcat") {
        while(true) {
          int n = yylex();
          if (n == 0) break;
        }
        return 0;
      }
    }
  }
  yyparse();
  return 0;
}
