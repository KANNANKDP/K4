

%{
	#include <stdio.h>
	#include <stdlib.h>
	
	

%}

letter [a-zA-Z]
digit [0-9]

%option noyywrap

%%

{digit}+ {printf("%s is a number\n",yytext);}

(auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while)   {printf("%s is a keyword\n",yytext);}

{letter}+ {printf("%s is an identifier\n",yytext);}


%%

void main(){

	yylex();
}
