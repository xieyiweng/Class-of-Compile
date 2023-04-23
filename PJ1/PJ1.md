

# **PJ1实验报告**

### Flex

一种可以使用正则表达式完成文本词法分析的工具，将正则表达式描述转化成c语言解析程序。

这里的关键是书写相应的正则表达式。Flex的正则表达式是标准正则的扩展，为实现词法分析具体的正则表达如下。

```c
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
```

WS为空格和tab，需要忽略并计算列数。

LETTER为大小写字母，DIGIT为数字，LETTER_OR_DIGIT为大小写字母和数字，为后续做准备。

UNPRINTABLE识别不可打印字符，将报错。

COMMENT为注释，需要忽略。该正则分为三部分，前面`"(*"`为注释开始符号。`[^\*]*`为非*的字符，为注释的主体，`[\*]+`是\*字符，为结束注释的识别标志，`([^\)][^\*]*[\*]+)*`为可能出现的 **\*之后再次出现注释内容** 而准备。最后为")"作为评论的结尾。

BADCOMMENT为需要报错的注释，即有注释开始符号`"(*"`却没有结尾的注释`")"`。

INTEGER根据手册为`{DIGIT}+`，并没有考虑0开头的情况。

REAL根据手册为`{DIGIT}+"."{DIGIT}*`，其中`6.`也符合要求。

STRING为`"\""[^\"\n]*"\""`，前后为两个`“`，中间为非`“`和非换行的0到多个符号。

BADSTRING为没有后`“`的STRING。

RESERVED_KEYWORD，DELIMITER，OPERATOR根据手册输入即可。

IDENTIFIER `{LETTER}{LETTER_OR_DIGIT}*`为字母开头，后面是字母或者数字。



后续实现定义，返回进主函数即可。

```c
#define WS                 -2
#define T_EOF              -1
#define ENTER               0
#define INTERGER            1
#define REAL                2
#define STRING              3
#define RESERVED_KEYWORD    4
#define DELIMITER           5
#define OPERATOR            6
#define IDENTIFIER          7
#define COMMENT             8
#define BADSTRING           9
#define BADCOMMENT         10
#define UNPRINTABLE        11
```

```c
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
```



### Main

后续需要在主函数里面实现对识别的词语的打印，和对行列的计算。

```c++
int row = 1; // 行数
int col = 1; // 列数
int token_count = 0; // token计数
int error_count = 0; // error计数
ofstream outfile; // 文件输出
```

正常情况下，token数量+1，输出结果，列数+=长度。

```c++
token_count++;
outfile << setw(5)<< row << setw(5) << col << setw(18) << decoder(n) << setw(18) << yytext << endl;
col += yyleng;
```

其余情况下需要单独讨论。内容在注释中

对于报错，要么在正则表达式中进行识别，要么在main函数中单独讨论。

```c++
if (n == T_EOF){ // 文件结束，break
    break;
} 
else if (n == WS) { // 讨论空格和tab情况，列数更新，无打印操作
    col += yyleng;
    continue;
}
else if (n == ENTER) { // 换行，行数+1，列数更新为1，无打印操作
    row++;
    col = 1;
    continue;
}
else if (n == COMMENT) { // 注释，因为可能有换行，所以需要额外讨论行数，列数的更新
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
else if (n == STRING) { // 字符串，需要实现报错：长度超255（不含引号） / 不能有tab
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
else if (n == INTERGER) { // 整型，需要实现报错： 不能超过2^31-1
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
else if (n == IDENTIFIER) { // 标识符，需要实现报错：不能超过255个字符
    if (yyleng > 255) {
        outfile << setw(5)<< row << setw(5) << col << setw(18) << decoder(n) << setw(18) << "ERROR: an overly long identifier" << endl;
      	error_count++;
        col += yyleng;
        continue;
    }
}
else if (n == BADSTRING) { // 报错字符，没有结束
    outfile << setw(5)<< row << setw(5) << col << setw(18) << decoder(n) << setw(18) << "ERROR: an unterminated string" << endl;
  	error_count++;
    row++;
    col += yyleng;
    continue;
}
else if (n == BADCOMMENT) { // 报错注释，没有结束
    outfile << setw(5)<< row << setw(5) << col << setw(18) << decoder(n) << setw(18) << "ERROR: an unterminated comment" << endl;
  	error_count++;
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
else if (n == UNPRINTABLE) { // 不可打印字符
    outfile << setw(5)<< row << setw(5) << col << setw(18) << decoder(n) << setw(18) << "ERROR: a bad character (bell)" << endl;
  	error_count++;
    col += yyleng;
    continue;
}
```

```c++
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
```

decoder输入n返回字符串用于输入。