
/*lex for k4*/

%{
#include "y.tab.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

%}


%%

"printf"			{return print;}
"bye"				{return exit_command;}
"if"				{return IF;}
"else" 	   			{return ELSE;}
"while"				{return WHILE;}
"for"				{return FOR;}
[a-zA-Z]{1}			{yylval.id = yytext[0]; return identifier;}
("a"|"b"|"c"|"d"|"e"|"f"|"g"|"h"|"i"|"j"|"k"|"l"|"m"|"n"|"o"|"p"|"q"|"r"|"s"|"t"|"u"|"v"|"w"|"x"|"y"|"z"|"A"|"B"|"C"|"D"|"E"|"F"|"G"|"H"|"I"|"J"|"K"|"L"|"M"|"N"|"O"|"P"|"Q"|"R"|"S"|"T"|"U"|"V"|"W"|"X"|"Y")+				{sprintf(yylval.s,"%s",yytext); return charstream;}
[0-9]+                 	   	{yylval.num = atoi(yytext); return number;}
[ \t\n]                		;
">"				{return GT;}
"<"				{return LT;}
">="				{return GTE;}
"<="				{return LTE;}
"=="				{return EQ;}
"!=" 	   			{return NEQ;}
[-+=;*/]           		{return yytext[0];}
"\("|"\)"|"\{"|"\}"		{return yytext[0];}
.                      		{ECHO; yyerror("unexpected character");}

%%

int yywrap (void) {return 1;}
