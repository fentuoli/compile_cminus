%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common/common.h"
#include "syntax_tree/SyntaxTree.h"

#include "lab1_lexical_analyzer/lexical_analyzer.h"

// external functions from lex
extern int yylex();
extern int yyparse();
extern int yyrestart();
extern FILE * yyin;

// external variables from lexical_analyzer module
extern int lines;
extern int pos_start;
extern int pos_end;
extern char * yytext;

// Global syntax tree.
SyntaxTree * gt;

void yyerror(const char * s);
%}

%union {
int num;
struct _SyntaxTreeNode * node;
char* str;
/********** TODO: Fill in this union structure *********/
};

/********** TODO: Your token definition here ***********/
%token ERROR
%token ADD 
%token SUB 
%token MUL 
%token DIV 
%token LT 
%token LTE 
%token GT 
%token GTE 
%token EQ 
%token NEQ 
%token ASSIN 
%token SEMICOLON 
%token COMMA 
%token LPARENTHESE 
%token RPARENTHESE 
%token LBRACKET 
%token RBRACKET 
%token LBRACE 
%token RBRACE 
%token ELSE 
%token IF 
%token INT 
%token RETURN 
%token VOID 
%token WHILE 
%token<str>  IDENTIFIER 
%token<num> NUMBER 
%token ARRAY 
%token LETTER 
%token EOL 
%token COMMENT 
%token BLANK 
%type<node> program 
%type<node> declaration_list
%type<node> declaration
%type<node> var_declaration
%type<node> fun_declaration
%type<node> type_specifier
%type<node> params
%type<node> compound_stmt
%type<node> param_list
%type<node> param
%type<node> local_declarations
%type<node> statement_list 
%type<node> statement
%type<node> expression_stmt 
%type<node> selection_stmt
%type<node> iteration_stmt 
%type<node> return_stmt
%type<node> expression
%type<node> var
%type<node> simple_expression
%type<node> additive_expression 
%type<node> relop
%type<node> addop 
%type<node> term
%type<node> mulop 
%type<node> factor
%type<node> call
%type<node> args
%type<node> arg_list
/* compulsory starting symbol */
%start program

%%
/*************** TODO: Your rules here *****************/
program : declaration_list    {
$$=newSyntaxTreeNode("program");
gt->root=$$;
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
}
;
declaration_list : declaration_list declaration   {
$$=newSyntaxTreeNode("declaration-list");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
$$->children_num=SyntaxTreeNode_AddChild($$,$2);
}
| declaration    {
$$=newSyntaxTreeNode("declaration-list");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
}
;
declaration : var_declaration    {
$$=newSyntaxTreeNode("declaration");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
}
| fun_declaration    {
$$=newSyntaxTreeNode("declaration");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
}
;
var_declaration : type_specifier IDENTIFIER  SEMICOLON{
$$=newSyntaxTreeNode("var-declaration");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode($2));
free($2);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(";"));
}
| type_specifier IDENTIFIER LBRACKET  NUMBER RBRACKET  SEMICOLON{
$$=newSyntaxTreeNode("var-declaration");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode($2));
free($2);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("["));
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNodeFromNum($4));
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("]"));
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(";"));
}
; 
type_specifier : INT   {
$$=newSyntaxTreeNode("type-specifier");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("int"));
}
| VOID   {
$$=newSyntaxTreeNode("type-specifier");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("void"));
}
;
fun_declaration : type_specifier IDENTIFIER LPARENTHESE  params RPARENTHESE compound_stmt   {
$$=newSyntaxTreeNode("fun-declaration");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode($2));
free($2);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("("));
$$->children_num=SyntaxTreeNode_AddChild($$,$4);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(")"));
$$->children_num=SyntaxTreeNode_AddChild($$,$6);
}
;
params : param_list  {
$$=newSyntaxTreeNode("params");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
}
| VOID  {
$$=newSyntaxTreeNode("params");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("void"));
}
;
param_list : param_list COMMA param {
$$=newSyntaxTreeNode("param-list");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(","));
$$->children_num=SyntaxTreeNode_AddChild($$,$3);
}
| param    {
$$=newSyntaxTreeNode("param-list");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
}
;
param : type_specifier IDENTIFIER     {
$$=newSyntaxTreeNode("param");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode($2));
}
| type_specifier IDENTIFIER ARRAY     {
$$=newSyntaxTreeNode("param");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode($2));
free($2);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("[]"));
}
;
compound_stmt : LBRACE  local_declarations statement_list RBRACE   {
$$=newSyntaxTreeNode("compound-stmt");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("{"));
$$->children_num=SyntaxTreeNode_AddChild($$,$2);
$$->children_num=SyntaxTreeNode_AddChild($$,$3);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("}"));
}
;
local_declarations : local_declarations var_declaration {
$$=newSyntaxTreeNode("local-declarations");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
$$->children_num=SyntaxTreeNode_AddChild($$,$2);
}
|  %empty {
$$=newSyntaxTreeNode("local-declarations");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("epsilon"));
}
;
statement_list : statement_list statement   {
$$=newSyntaxTreeNode("statement-list");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
$$->children_num=SyntaxTreeNode_AddChild($$,$2);
}
|  %empty {
$$=newSyntaxTreeNode("statement-list");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("epsilon"));
}
;
statement : expression_stmt  {$$=newSyntaxTreeNode("statement");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);}
| compound_stmt  {$$=newSyntaxTreeNode("statement");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);}
| selection_stmt    {$$=newSyntaxTreeNode("statement");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);}
| iteration_stmt     {$$=newSyntaxTreeNode("statement");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);}
| return_stmt        {$$=newSyntaxTreeNode("statement");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);}
;
expression_stmt : expression SEMICOLON   {
$$=newSyntaxTreeNode("expression-stmt");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(";"));
}
| SEMICOLON   {
$$=newSyntaxTreeNode("expression-stmt");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(";"));
}
;
selection_stmt : IF LPARENTHESE  expression RPARENTHESE statement   {
$$=newSyntaxTreeNode("selection-stmt");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("if"));
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("("));
$$->children_num=SyntaxTreeNode_AddChild($$,$3);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(")"));
$$->children_num=SyntaxTreeNode_AddChild($$,$5);
}
| IF LPARENTHESE expression RPARENTHESE statement ELSE statement   {
$$=newSyntaxTreeNode("selection-stmt");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("if"));
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("("));
$$->children_num=SyntaxTreeNode_AddChild($$,$3);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(")"));
$$->children_num=SyntaxTreeNode_AddChild($$,$5);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("else"));
$$->children_num=SyntaxTreeNode_AddChild($$,$7);
}
;
iteration_stmt : WHILE LPARENTHESE expression RPARENTHESE statement   {
$$=newSyntaxTreeNode("iteration-stmt");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("while"));
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("("));
$$->children_num=SyntaxTreeNode_AddChild($$,$3);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(")"));
$$->children_num=SyntaxTreeNode_AddChild($$,$5);
}
;
return_stmt : RETURN SEMICOLON     {
$$=newSyntaxTreeNode("return-stmt");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("return"));
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(";"));
}
| RETURN expression SEMICOLON    {
$$=newSyntaxTreeNode("return-stmt");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("return"));
$$->children_num=SyntaxTreeNode_AddChild($$,$2);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(";"));
}
;
expression : var ASSIN expression    {
$$=newSyntaxTreeNode("expression");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("="));
$$->children_num=SyntaxTreeNode_AddChild($$,$3);
}
| simple_expression     {
$$=newSyntaxTreeNode("expression");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
}
;
var : IDENTIFIER    {
$$=newSyntaxTreeNode("var");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode($1));
free($1);
}
| IDENTIFIER LBRACKET expression RBRACKET    {
$$=newSyntaxTreeNode("var");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode($1));
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("["));
$$->children_num=SyntaxTreeNode_AddChild($$,$3);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("]"));
}
;
simple_expression : additive_expression relop additive_expression     {
$$=newSyntaxTreeNode("simple-expression");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
$$->children_num=SyntaxTreeNode_AddChild($$,$2);
$$->children_num=SyntaxTreeNode_AddChild($$,$3);
}
| additive_expression    {
$$=newSyntaxTreeNode("simple-expression");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
}
;
relop : LTE    {
$$=newSyntaxTreeNode("relop");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("<="));
}
|  LT     {
$$=newSyntaxTreeNode("relop");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("<"));
}
|  GT    {
$$=newSyntaxTreeNode("relop");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(">"));
}
|  GTE  {
$$=newSyntaxTreeNode("relop");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(">="));
}
|  EQ    {
$$=newSyntaxTreeNode("relop");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("=="));
}
| NEQ   {
$$=newSyntaxTreeNode("relop");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("!="));
}
;
additive_expression : additive_expression addop term    {
$$=newSyntaxTreeNode("additive-expression");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
$$->children_num=SyntaxTreeNode_AddChild($$,$2);
$$->children_num=SyntaxTreeNode_AddChild($$,$3);
}
| term     {
$$=newSyntaxTreeNode("additive-expression");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
}
;
addop : ADD    {
$$=newSyntaxTreeNode("addop");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("+"));
}
| SUB     {
$$=newSyntaxTreeNode("addop");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("-"));
}
;
term : term mulop factor     {
$$=newSyntaxTreeNode("term");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
$$->children_num=SyntaxTreeNode_AddChild($$,$2);
$$->children_num=SyntaxTreeNode_AddChild($$,$3);
}
| factor      {
$$=newSyntaxTreeNode("term");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
}
;
mulop : MUL   {
$$=newSyntaxTreeNode("mulop");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("*"));
}
| DIV    {
$$=newSyntaxTreeNode("mulop");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("/"));
}
;
factor : LPARENTHESE expression RPARENTHESE    {
$$=newSyntaxTreeNode("factor");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("("));
$$->children_num=SyntaxTreeNode_AddChild($$,$2);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(")"));
}
| var      {
$$=newSyntaxTreeNode("factor");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
}
| call     {
$$=newSyntaxTreeNode("factor");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
}
| NUMBER    {
$$=newSyntaxTreeNode("factor");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNodeFromNum($1));
}
;
call : IDENTIFIER LPARENTHESE args RPARENTHESE     {
$$=newSyntaxTreeNode("call");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode($1));
free($1);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("("));
$$->children_num=SyntaxTreeNode_AddChild($$,$3);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(")"));
}
; 
args : arg_list      {
$$=newSyntaxTreeNode("args");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
}
|   %empty   {
$$=newSyntaxTreeNode("args");
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode("epsilon"));
}
;
arg_list : arg_list COMMA expression     {
$$=newSyntaxTreeNode("arg-list");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
$$->children_num=SyntaxTreeNode_AddChild($$,newSyntaxTreeNode(","));
$$->children_num=SyntaxTreeNode_AddChild($$,$3);
}
| expression     {
$$=newSyntaxTreeNode("arg-list");
$$->children_num=SyntaxTreeNode_AddChild($$,$1);
}
;

%%

void yyerror(const char * s)
{
	// TODO: variables in Lab1 updates only in analyze() function in lexical_analyzer.l
	//       You need to move position updates to show error output below
	fprintf(stderr, "%s:line %d, from %d to %d syntax error for %s\n", s, lines, pos_start, pos_end,yytext);
	deleteSyntaxTree(gt);
	newSyntaxTree(gt);
}

/// \brief Syntax analysis from input file to output file
///
/// \param input basename of input file
/// \param output basename of output file
void syntax(const char * input, const char * output)
{
	gt = newSyntaxTree();
    lines=1;
    pos_start=1;
	pos_end=1;
	char inputpath[256] = "./testcase/";
	char outputpath[256] = "./syntree/";
	strcat(inputpath, input);
	strcat(outputpath, output);

	if (!(yyin = fopen(inputpath, "r"))) {
		fprintf(stderr, "[ERR] Open input file %s failed.", inputpath);
		exit(1);
	}
	yyrestart(yyin);
	printf("[START]: Syntax analysis start for %s\n", input);
	FILE * fp = fopen(outputpath, "w+");
	if (!fp)	return;

	// yyerror() is invoked when yyparse fail. If you still want to check the return value, it's OK.
	// `while (!feof(yyin))` is not needed here. We only analyze once.
	yyparse();

	printf("[OUTPUT] Printing tree to output file %s\n", outputpath);
	printSyntaxTree(fp, gt);
	deleteSyntaxTree(gt);
	gt = 0;

	fclose(fp);
	printf("[END] Syntax analysis end for %s\n", input);
}

/// \brief starting function for testing syntax module.
///
/// Invoked in test_syntax.c
int syntax_main(int argc, char ** argv)
{
	char filename[50][256];
	char output_file_name[256];
	const char * suffix = ".syntax_tree";
	int fn = getAllTestcase(filename);
	for (int i = 0; i < fn; i++) {
			int name_len = strstr(filename[i], ".cminus") - filename[i];
			strncpy(output_file_name, filename[i], name_len);
			strcpy(output_file_name+name_len, suffix);
			syntax(filename[i], output_file_name);
	}
	return 0;
}
