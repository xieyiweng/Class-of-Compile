# 编译PJ2 实验报告

### 项目文件结构 & 执行

```
文件结构：
bison_demo
|  answer （输出结果）
|  |  case_1.txt
|  |  case_2.txt
|  |  ......
|  tests （测试样例）
|  |  case_1.pact
|  |  case_2.pact
|  |  ......
|  demo.cpp （主程序）
|  demo.lex （词法分析）
|  demo.y （语法分析）
|  do_case.sh （测试执行程序）
|  Makefile
```

```
执行：
./do_case.sh
```



### 项目代码分析

#### `demo.cpp`

作为 **词法分析** 和 **语法分析** 的调用主程序，进行测试文件的输入和结果文件的输出。对于特殊的case_11调用词法分析，其余都采用词法分析+语法分析。



#### `demo.lex`

包含了构建语法树的函数和词法分析。

```c++
struct Node {
    string tag;
    char* value;
    struct Node *cld[10];
    int ncld;
		int row;
		int col;
};
```

结构体`Node`是语法树的节点，`tag`是节点的标签，`value`是节点的值，`cld`是节点的子节点指针数组，`ncld`是子节点的个数，`row`、 `col`是所在行、所在列。



```c++
struct Node *createLeaf(string tag, char *text)
struct Node *createNode(string tag, int ncld, struct Node *a[])
struct Node *createEmpty()
void treePrintLevel(struct Node *nd, int lvl)
void treePrint(struct Node *nd)
```

构建语法树的函数都很简单，`createLeaf` 创建叶子节点，`createNode`创建中间节点，`createEmpty`创建空节点，`treePrintLevel` `treePrint`用于语法树的打印。

空节点的`tag`是`epsilon`，`value`是`NULL`，叶节点根据`tag`确定是否存在`value`，中间节点`tag`由节点确定，`value`是`NULL`。



这里代码比较简单，只展示`treePrintLevel`的代码：

```c++
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
```

这里如果`tag`是`epsilon`的话有两种可能，一种是叶节点下面的空节点，一种是中间节点但是用来实现闭包的，都无需打印。

`for`循环里遍历子节点，这里需要注意子节点`tag`为`epsilon`表示为实现闭包的无用节点，故层次应该与父节点相同。



词法分析与PJ1的几乎相同，不再过多介绍，少有值得注意的地方是：

```c++
...
"RETURN" 				{col += yyleng; return RETURN;}
"THEN" 					{col += yyleng; return THEN;}
"TO" 						{col += yyleng; return TO;}
"TYPE" 					{col += yyleng; return TYPE;}
"VAR" 					{col += yyleng; return VAR;}
"WHILE" 				{col += yyleng; return WHILE;}
"WRITE" 				{col += yyleng; return WRITE;}
":"							{col += yyleng; return ':';}
";"							{col += yyleng; return ';';}
","							{col += yyleng; return ',';}							
"."							{col += yyleng; return '.';}
"[<"						{col += yyleng; return F_X;}
">]"						{col += yyleng; return D_F;}
...
```

将`PRESERVED_WORD`拆散，返回每一个单独的`token`，`comment`不返回`token`，双目符号不能同时返回于是采用英文代替。



#### `demo.y`

语法分析器，声明了需要用到的中间变量`cldArray` `cldN` `nTag`，报错函数等

```c++
struct Node *cldArray[10];
int cldN;
string nTag;
int yylex();
void yyerror(const char* msg) {
  printf("%s! : (%d, %d) [ %s ]\n", msg, row, col, yytext);
  return;
}
```

这里报错函数`yyerror`直接返回语法错误，并返回错误的位置，发生错误的符号。



声明终结符和非终结符

```c++
%token <node> AND ARRAY BEGIN BY DIV ...
...
%type <node> program 
%type <node> body 
...
```

需要注意的是，一下为添加的非终结符，命名为`xxx_s`是`{xxx}`，`xxx_c`是`[xxx]`

```python
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
```



以下为语法解析的示例：

```shell
declaration: VAR var_decl_s {nTag="delaration"; cldN=1; cldArray[0]=$2; $$=createNode(nTag, cldN, cldArray);}
  | TYPE type_decl_s {nTag="delaration"; cldN=1; cldArray[0]=$2; $$=createNode(nTag, cldN, cldArray);}
  | PROCEDURE procedure_decl_s {nTag="delaration"; cldN=1; cldArray[0]=$2; $$=createNode(nTag, cldN, cldArray);}
  ;
  
var_decl_s: {nTag="epsilon"; cldN=1; cldArray[0]=createEmpty(); $$=createNode(nTag, cldN, cldArray);}
  | var_decl var_decl_s {nTag="epsilon"; cldN=2; cldArray[0]=$1; cldArray[1]=$2; $$=createNode(nTag, cldN, cldArray);}
  ;
```

对于`{xxx}`类型的非终结符，推导可为空或者自身 自身的闭包，其中推导为空则需要构建空节点，调用`createEmpty`，其余需要调用`createNode`构造中间节点。上图为推导和构建节点的过程。



#### `do_case.sh`

```bash
make
if [ -e answer ]
then
rm -rf answer
mkdir answer
chmod 777 answer
else
mkdir answer
chmod 777 answer
fi
DIR=$(dirname $(readlink -f $0))
for ((i=1;i<=14;i++))
do
    ./demo tests/case_$i.pcat > ./answer/case_$i.txt
done
```

用于测试的脚本文件，执行Makefile进行编译，构建answer文件夹，运行demo完成测试。



### 分工

个人完成。

语法树建立参考了https://blog.csdn.net/hello_tomorrow_111/article/details/78745868