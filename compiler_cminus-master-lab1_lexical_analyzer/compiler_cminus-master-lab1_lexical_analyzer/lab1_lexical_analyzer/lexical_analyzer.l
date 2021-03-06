%option noyywrap
%{
/*****************声明和选项设置  begin*****************/
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include "lab1_lexical_analyzer/lexical_analyzer.h"
#include "common/common.h"

#ifndef LAB1_ONLY
#include "syntax_analyzer.h"
#endif
int files_count=0;
int lines=1;
int pos_start=1;
int pos_end=1;
/*****************声明和选项设置  end*****************/

%}

commentPattern "/*"([^\*]|(\*)*[^\*/])*(\*)*"*/"
identifierPattern [a-zA-Z][a-zA-Z]*

%%

 /******************TODO*********************/
 /****请在此补全所有flex的模式与动作  start******/   
[\t\r]+   {pos_start = pos_end;
	pos_end  += strlen(yytext);//return BLANK;
 }
[ ]+ { pos_start = pos_end;
	pos_end  += strlen(yytext);//return BLANK;
 }
[\n]+      {lines+=strlen(yytext);
	pos_start = 1;
	pos_end = 1;}
[/][*]       { 
	pos_start = pos_end;
	pos_end  += strlen(yytext);
	char c;
        char prev = '\0';
        do{ 
         	c = input();
                pos_end += 1;
                if (c == EOF) break;//return ERROR;
                if (c == '\n') {lines++;pos_start = 1;pos_end = 1;}
                if (prev == '*' && c == '/')break;//return COMMENT;
                prev = c;
          } while (1);
	
 }
int         {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return INT;}
else        {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return ELSE;}
if          {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return IF;}
return      {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return RETURN;}
void        {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return VOID;}
while       {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return WHILE;}
[(]         {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return LPARENTHESE;}
[)]           {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return RPARENTHESE;}
[{]           {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return LBRACE;}
[}]           {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return RBRACE;}
[+]         {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return ADD;}
[-]         {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return SUB;}
[*]         {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return MUL;}
[/]         {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return DIV;}
[<]         {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return LT;}
[>]         {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return GT;}
[=]         {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return ASSIN;}
[=][=]      {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return EQ;}
[>][=]      {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return GTE;}
[<][=]      {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return LTE;}
[;]         {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return SEMICOLON;}
[,]         {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return COMMA;}
[!][=]      {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return NEQ;}
[[][]]      {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return ARRAY;}
\[         {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return LBRACKET;}
[]]         {pos_start=pos_end;pos_end=pos_start+strlen(yytext);return RBRACKET; }
[a-zA-Z]+        {
pos_start=pos_end;
pos_end=pos_start+strlen(yytext);
#ifndef LAB1_ONLY 
yylval.str=strdup(yytext);
#endif 
return IDENTIFIER;
}
[0-9]+   {
pos_start=pos_end;
pos_end=pos_start+strlen(yytext);
#ifndef LAB1_ONLY 
yylval.num=atoi(yytext);
#endif 
return NUMBER;
}
.         { pos_start=pos_end;pos_end=pos_start+strlen(yytext);return ERROR;}




 /****请在此补全所有flex的模式与动作  end******/
%%
/****************C代码 start*************/

/// \brief analysize a *.cminus file
///
///	\param input_file_name
/// \param output_file_name
void analyzer(char* input_file_name, char* output_file_name){
	lines = 1;
	pos_start = 1;
	pos_end = 1;
	char input_path[256] = "./testcase/";
	strcat(input_path, input_file_name);
	char output_path[256] = "./tokens/";
	strcat(output_path, output_file_name);

	if(!(yyin = fopen(input_path,"r"))){
		printf("[ERR] No input file\n");
		exit(1);
	}
	printf("[START]: Read from: %s\n", input_file_name);

	FILE *fp = fopen(output_path,"w+");

	int token;
	while(token = yylex()){
		pos_start = pos_end;
		pos_end += strlen(yytext);
		switch(token){
			case ERROR:
				fprintf(fp, "[ERR]: unable to analysize %s at %d line, from %d to %d\n", yytext, lines, pos_start, pos_end);
				break;
			case COMMENT:
			case BLANK:
				break;
			case EOL:
				pos_start = 1,pos_end = 1;
				break;
			case NUMBER:
				fprintf(fp, "%d\t%d\t%d\t%d\t%d\n",atoi(yytext), token, lines, pos_start, pos_end);
				break;
			default :
				fprintf(fp, "%s\t%d\t%d\t%d\t%d\n",yytext, token, lines, pos_start, pos_end);
		}
	}
	fclose(fp);
	printf("[END]: Analysis completed.\n");
}

/// \brief process all *.cminus file
///
/// note that: use relative path for all i/o operations
int lex_main(int argc, char **argv){
	char filename[10][256];
	char output_file_name[256];
	char suffix[] = ".tokens";
	int j=0;
	for(;j<256;j++)
		output_file_name[j]='\0';

	files_count = getAllTestcase(filename);
	for(int i = 0; i < files_count; i++){
			int name_len = strstr(filename[i], ".cminus")-filename[i];
			strncpy(output_file_name, filename[i], name_len);
			strcpy(output_file_name+name_len, suffix);
			analyzer(filename[i],output_file_name);
			j=0;
	        for(;j<256;j++)
				output_file_name[j]='\0';
	}
	return 0;
}
/****************C代码 end*************/
