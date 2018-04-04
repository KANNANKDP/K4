
/*yacc for k4*/

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(char *s) ; //standard error function 

int symbols[1000]; //symbol table
int symbolVal(char symbol); //function to return the value of a variable from the symbol table
void updateSymbolVal(char symbol, int val); //funtion used to update the value of a variable from the symbol table

char i_term[6][10]={"t1","t2","t3","t4","t5","t6"};

extern FILE *yyin;
extern FILE *yyout;

extern char *yytext;
extern char yylineno;

%}

%union {int num; char id; char s[100];}         /* Yacc definitions */
%start sstart
%token print
%token charstream
%token exit_command
%token <num> number
%token IF
%token ELSE
%token WHILE
%token FOR
%token GTE GT
%token LTE
%token LT
%token EQ
%token NEQ
%token <id> identifier
%type <num> sstart exp term 
%type <id> assignment
%type <num> condition 
%type <s> charstream
%type <num> loopstat


%%

sstart  	: assignment ';'										{++yylineno;;}
		| exit_command ';'										{++yylineno;exit(EXIT_SUCCESS); }
		| print '(' exp ')' ';'										{++yylineno;printf("%d\n", $3); fprintf(yyout,"%s := %d;\nprint %s;\n\n",i_term[0],$3,i_term[0]); ;}
		| print '{' charstream '}' ';'									{++yylineno;printf("%s\n", $3); fprintf(yyout,"%s := %s;\nprint %s;\n\n",i_term[0],$3,i_term[0]); ;}
		| condstat ';'											{++yylineno;;}
		| loopstat ';'											{++yylineno;;}
		| sstart assignment ';'										{++yylineno;;}
		| sstart print '(' exp ')' ';'									{++yylineno;printf("%d\n", $4); fprintf(yyout,"%s := %d;\nprint %s;\n\n",i_term[0],$4,i_term[0]); ;}
		| sstart exit_command ';'									{++yylineno;exit(EXIT_SUCCESS); }
		| sstart condstat ';'										{++yylineno;;}
		| sstart loopstat ';'										{++yylineno;;}
        	| sstart print '{' charstream '}' ';'								{++yylineno;printf("%s\n",$4); fprintf(yyout,"%s := %s;\nprint %s;\n\n",i_term[0],$4,i_term[0]); ;}
        	;


condstat	: IF '(' condition ')' '{' identifier '=' exp  ';' '}'						
		  {if( $3 == 1 ) { updateSymbolVal($6,$8); }  fprintf(yyout,"if nz %s;\n%s := %d;\n%c := %s;\n\n",i_term[0],i_term[1],$8,$6,i_term[1]); ;}
        	
        	
        	| IF '(' condition ')' '{' identifier '=' exp  ';' '}' ELSE '{'	identifier '=' exp  ';' '}' 	
        	  {if( $3 == 1 ) { updateSymbolVal($6,$8); } else{ updateSymbolVal($13,$15);} fprintf(yyout,"if z %s goto _L0;\n%s := %d;\n%c := %s;\n_LO : else;\n%s := %d;\n%c := %s;\n\n",i_term[0],i_term[1],$8,$6,i_term[1],i_term[2],$15,$13,i_term[2]); ;}
		;
		
loopstat	: WHILE '(' identifier GT term ')' '{' print '(' exp ')' ';' identifier '=' identifier '-' number ';' '}'           
		  {if( symbolVal($3) > $5 ) {$$=$5;} while( symbolVal($3) > $$  ){ printf("%d\n",$10); updateSymbolVal($3,symbolVal($3)-1);} 
		  
		  fprintf(yyout,"%s := %d;\n_LO : %s := %c > %s;\nif nz %s;\n%s := %d;\nprint %s;\n%s := 1;\n%s := %c - %s;\ngoto _LO;\n\n",i_term[0],$5,i_term[1],$3,i_term[0],i_term[1],i_term[2],$10,i_term[2],i_term[3],i_term[4],$3,i_term[3]) ; ;}
		
		
		| WHILE '(' identifier LT term ')' '{' print '(' exp ')' ';' identifier '=' identifier '+' number ';' '}'
		  {if( symbolVal($3) < $5 ) {$$=$5;} while( symbolVal($3) < $$  ){ printf("%d\n",$10); updateSymbolVal($3,symbolVal($3)+1);} 
		  
		  fprintf(yyout,"%s := %d;\n_LO : %s := %c < %s;\nif nz %s;\n%s := %d;\nprint %s;\n%s := 1;\n%s := %c + %s;\ngoto _LO;\n\n",i_term[0],$5,i_term[1],$3,i_term[0],i_term[1],i_term[2],$10,i_term[2],i_term[3],i_term[4],$3,i_term[3]) ; ;}
		
		
		| WHILE '(' identifier GTE term ')' '{' print '(' exp ')' ';'	 identifier '=' identifier '-' number ';' '}'
		  {if( symbolVal($3) >= $5 ) {$$=$5;} while( symbolVal($3) >= $$  ){ printf("%d\n",$10); updateSymbolVal($3,symbolVal($3)-1);}   
		  
		  
		  fprintf(yyout,"%s := %d;\n_LO : %s := %c >= %s;\nif nz %s;\n%s := %d;\nprint %s;\n%s := 1;\n%s := %c - %s;\ngoto _LO;\n\n",i_term[0],$5,i_term[1],$3,i_term[0],i_term[1],i_term[2],$10,i_term[2],i_term[3],i_term[4],$3,i_term[3]) ; ;}
		
		
		
		| WHILE '(' identifier LTE term ')' '{' print '(' exp ')' ';' identifier '=' identifier '+' number ';' '}'
		  {if( symbolVal($3) <= $5 ) {$$=$5;} while( symbolVal($3) <= $$  ){ printf("%d\n",$10); updateSymbolVal($3,symbolVal($3)+1);}
		  
		    fprintf(yyout,"%s := %d;\n_LO : %s := %c <= %s;\nif nz %s;\n%s := %d;\nprint %s;\n%s := 1;\n%s := %c + %s;\ngoto _LO;\n\n",i_term[0],$5,i_term[1],$3,i_term[0],i_term[1],i_term[2],$10,i_term[2],i_term[3],i_term[4],$3,i_term[3]) ; ;}
		
		
		
		| WHILE '(' identifier GT term ')' '{' identifier '=' identifier '-' number ';'print '(' exp ')' ';' '}'           
		  {if( symbolVal($3) > $5 ) {$$=$5;} while( symbolVal($3) > $$  ){ updateSymbolVal($8,symbolVal($8)-1); printf("%d\n",$16);} 
		  
		    fprintf(yyout,"%s := %d;\n_LO : %s := %c > %s;\nif nz %s;\n%s := 1;\n%s := %c - %s;\ngoto _LO;%s := %d;\nprint %s;\n\n",i_term[0],$5,i_term[1],$3,i_term[0],i_term[1],i_term[3],i_term[4],$3,i_term[3],i_term[2],$16,i_term[2]) ; ;}
		
		
		
		| WHILE '(' identifier LT term ')' '{' identifier '=' identifier '+' number ';' print '(' exp ')' ';' '}'
		  {if( symbolVal($3) < $5 ) {$$=$5;} while( symbolVal($3) < $$  ){ updateSymbolVal($8,symbolVal($8)+1); printf("%d\n",$16);} 
		  
				  
		    fprintf(yyout,"%s := %d;\n_LO : %s := %c < %s;\nif nz %s;\n%s := 1;\n%s := %c + %s;\ngoto _LO;%s := %d;\nprint %s;\n\n",i_term[0],$5,i_term[1],$3,i_term[0],i_term[1],i_term[3],i_term[4],$3,i_term[3],i_term[2],$16,i_term[2]) ; ;}
		
		
		
		| WHILE '(' identifier GTE term ')' '{' identifier '=' identifier '-' number ';' print '(' exp ')' ';' '}'
		  {if( symbolVal($3) >= $5 ) {$$=$5;} while( symbolVal($3) >= $$  ){ updateSymbolVal($8,symbolVal($8)-1); printf("%d\n",$16);} 
				  
		    fprintf(yyout,"%s := %d;\n_LO : %s := %c >= %s;\nif nz %s;\n%s := 1;\n%s := %c - %s;\ngoto _LO;%s := %d;\nprint %s;\n\n",i_term[0],$5,i_term[1],$3,i_term[0],i_term[1],i_term[3],i_term[4],$3,i_term[3],i_term[2],$16,i_term[2]) ; ;}
		
		
		
		
		| WHILE '(' identifier LTE term ')' '{' identifier '=' identifier '+' number ';' print '(' exp ')' ';' '}'
		  {if( symbolVal($3) <= $5 ) {$$=$5;} while( symbolVal($3) <= $$  ){ updateSymbolVal($8,symbolVal($8)+1); printf("%d\n",$16);} 
				  
		    fprintf(yyout,"%s := %d;\n_LO : %s := %c <= %s;\nif nz %s;\n%s := 1;\n%s := %c + %s;\ngoto _LO;%s := %d;\nprint %s;\n\n",i_term[0],$5,i_term[1],$3,i_term[0],i_term[1],i_term[3],i_term[4],$3,i_term[3],i_term[2],$16,i_term[2]) ; ;}
		
		

	

	
		| WHILE '(' identifier GT term ')' '{' print '{' charstream '}' ';' identifier '=' identifier '-' number ';' '}'           
		  {if( symbolVal($3) > $5 ) {$$=$5;} while( symbolVal($3) > $$  ){ printf("%s\n",$10); updateSymbolVal($3,symbolVal($3)-1);} 
		  
		    fprintf(yyout,"%s := %d;\n_LO : %s := %c > %s;\nif nz %s;\n%s := %s;\nprint %s;\n%s := 1;\n%s := %c - %s;\ngoto _LO;\n\n",i_term[0],$5,i_term[1],$3,i_term[0],i_term[1],i_term[2],$10,i_term[2],i_term[3],i_term[4],$3,i_term[3]) ; ;}
		
		
		
		| WHILE '(' identifier LT term ')' '{'  print '{' charstream '}' ';'identifier '=' identifier '+' number';' '}'
		  {if( symbolVal($3) < $5 ) {$$=$5;} while( symbolVal($3) < $$  ){ printf("%s\n",$10); updateSymbolVal($3,symbolVal($3)+1);} 
		  
		    fprintf(yyout,"%s := %d;\n_LO : %s := %c < %s;\nif nz %s;\n%s := %s;\nprint %s;\n%s := 1;\n%s := %c + %s;\ngoto _LO;\n\n",i_term[0],$5,i_term[1],$3,i_term[0],i_term[1],i_term[2],$10,i_term[2],i_term[3],i_term[4],$3,i_term[3]) ; ;}

		
		| WHILE '(' identifier GTE term ')' '{'  print '{' charstream '}' ';'identifier '=' identifier '-' number ';' '}'
		  {if( symbolVal($3) >= $5 ) {$$=$5;} while( symbolVal($3) >= $$  ){ printf("%s\n",$10); updateSymbolVal($3,symbolVal($3)-1);} 
		  
		    fprintf(yyout,"%s := %d;\n_LO : %s := %c >= %s;\nif nz %s;\n%s := %s;\nprint %s;\n%s := 1;\n%s := %c - %s;\ngoto _LO;\n\n",i_term[0],$5,i_term[1],$3,i_term[0],i_term[1],i_term[2],$10,i_term[2],i_term[3],i_term[4],$3,i_term[3]) ; ;}
		
		
		| WHILE '(' identifier LTE term ')' '{'  print '{' charstream '}' ';' identifier '=' identifier '+' number ';' '}'
		  {if( symbolVal($3) <= $5 ) {$$=$5;} while( symbolVal($3) <= $$  ){ printf("%s\n",$10); updateSymbolVal($3,symbolVal($3)+1);} 
		  
		    fprintf(yyout,"%s := %d;\n_LO : %s := %c <= %s;\nif nz %s;\n%s := %s;\nprint %s;\n%s := 1;\n%s := %c + %s;\ngoto _LO;\n\n",i_term[0],$5,i_term[1],$3,i_term[0],i_term[1],i_term[2],$10,i_term[2],i_term[3],i_term[4],$3,i_term[3]) ; ;}
		
		
		
		| WHILE '(' identifier GT term ')' '{' identifier '=' identifier '-' number ';'  print '{' charstream '}' ';' '}'          
		  {if( symbolVal($3) > $5 ) {$$=$5;} while( symbolVal($3) > $$  ){ updateSymbolVal($8,symbolVal($8)-1); printf("%s\n",$16);} 
		 		  
		    fprintf(yyout,"%s := %d;\n_LO : %s := %c > %s;\nif nz %s;\n%s := 1;\n%s := %c - %s;\ngoto _LO;%s := %s;\nprint %s;\n\n",i_term[0],$5,i_term[1],$3,i_term[0],i_term[1],i_term[3],i_term[4],$3,i_term[3],i_term[2],$16,i_term[2]) ; ;}
		
	
		
		| WHILE '(' identifier LT term ')' '{' identifier '=' identifier '+' number ';'  print '{' charstream '}' ';' '}'
		  {if( symbolVal($3) < $5 ) {$$=$5;} while( symbolVal($3) < $$  ){ updateSymbolVal($8,symbolVal($8)+1); printf("%s\n",$16);} 
				  
		    fprintf(yyout,"%s := %d;\n_LO : %s := %c < %s;\nif nz %s;\n%s := 1;\n%s := %c + %s;\ngoto _LO;%s := %s;\nprint %s;\n\n",i_term[0],$5,i_term[1],$3,i_term[0],i_term[1],i_term[3],i_term[4],$3,i_term[3],i_term[2],$16,i_term[2]) ; ;}
		
		
		
		| WHILE '(' identifier GTE term ')' '{' identifier '=' identifier '-' number ';'  print '{' charstream '}' ';'   '}'
		  {if( symbolVal($3) >= $5 ) {$$=$5;} while( symbolVal($3) >= $$  ){ updateSymbolVal($8,symbolVal($8)-1); printf("%s\n",$16);} 
				  
		    fprintf(yyout,"%s := %d;\n_LO : %s := %c >= %s;\nif nz %s;\n%s := 1;\n%s := %c - %s;\ngoto _LO;%s := %s;\nprint %s;\n\n",i_term[0],$5,i_term[1],$3,i_term[0],i_term[1],i_term[3],i_term[4],$3,i_term[3],i_term[2],$16,i_term[2]) ; ;}
		
		
		
		| WHILE '(' identifier LTE term ')' '{' identifier '=' identifier '+' number ';'  print '{' charstream '}' ';' '}'
		  {if( symbolVal($3) <= $5 ) {$$=$5;} while( symbolVal($3) <= $$  ){ updateSymbolVal($8,symbolVal($8)+1); printf("%s\n",$16);} 
				  
		    fprintf(yyout,"%s := %d;\n_LO : %s := %c <= %s;\nif nz %s;\n%s := 1;\n%s := %c + %s;\ngoto _LO;%s := %s;\nprint %s;\n\n",i_term[0],$5,i_term[1],$3,i_term[0],i_term[1],i_term[3],i_term[4],$3,i_term[3],i_term[2],$16,i_term[2]); ;}
		
		
		  
		/* Till here no errors */

		| FOR '(' identifier '=' exp ';' identifier GT exp ';' identifier '=' identifier '-' number ')' '{' print '(' exp ')' ';' '}'
		  { if( symbolVal($3) > $9 ) {$$=$9;} for( updateSymbolVal($3,$5); symbolVal($3) > $$ ;  updateSymbolVal($3,symbolVal($3)-1 )){ printf("%d\n",$20); } ;}
		;		  

assignment 	: identifier '=' exp  					{updateSymbolVal($1,$3); fprintf(yyout,"%s := %d;\n %c := %s;\n\n",i_term[0],$3,$1,i_term[0]); ;}
		;
			
exp    		: term               				   	{$$ = $1;}	
       		| exp '+' term                               		{$$ = $1 + $3;}
       		| exp '-' term          				{$$ = $1 - $3;}
       		| exp '*' term						{$$ = $1 * $3;}
       		| exp '/' term						{$$ = $1 / $3;}
       		;        
       		
       		
condition 	: identifier GT term					{if( symbolVal($1) > $3 ) {$$=1;} else {$$=0;} fprintf(yyout,"%s := %c > %d;\n ",i_term[0],$1,$3); ;}
		| identifier LT term					{if( symbolVal($1) < $3 ) {$$=1;} else {$$=0;} fprintf(yyout,"%s := %c < %d;\n ",i_term[0],$1,$3); ;}
		| identifier LTE term					{if( symbolVal($1) <= $3 ) {$$=1;} else {$$=0;} fprintf(yyout,"%s := %c <= %d;\n ",i_term[0],$1,$3); ;}
		| identifier GTE term					{if( symbolVal($1) >= $3 ) {$$=1;} else {$$=0;} fprintf(yyout,"%s := %c >= %d;\n ",i_term[0],$1,$3); ;}
		| identifier EQ term					{if( symbolVal($1) == $3 ) {$$=1;} else {$$=0;} fprintf(yyout,"%s := %c == %d;\n ",i_term[0],$1,$3); ;}
		| identifier NEQ term					{if( symbolVal($1) != $3 ) {$$=1;} else {$$=0;} fprintf(yyout,"%s := %c != %d;\n ",i_term[0],$1,$3); ;}
		;
	
       	
term   		: number               					{$$ = $1;}
		| identifier						{$$ = symbolVal($1);} 
        	;




%%                     /* C code */



int computeSymbolIndex(char token)
{
	int idx = -1;
	if(islower(token)) {
		idx = token - 'a' + 26;
	} else if(isupper(token)) {
		idx = token - 'A';
	}
	return idx;
} 

/* returns the value of a given symbol */
int symbolVal(char symbol)
{
	int bucket = computeSymbolIndex(symbol);
	return symbols[bucket];
}

/* updates the value of a given symbol */
void updateSymbolVal(char symbol, int val)
{
	int bucket = computeSymbolIndex(symbol);
	symbols[bucket] = val;
}

int main (int argc, char * argv[]) {
	/* init symbol table */
	int i;
	
	yyin=fopen(argv[1],"r+");
	yyout=fopen("threeadress.txt","w");

	

	for(i=0; i<52; i++) {
		symbols[i] = 0;
	}
	if(yyin==NULL){
		printf("Error in reading the file...");
	}
	else{
		return yyparse();
	}	
}

void yyerror (char *s) {fprintf (stderr, "%s at position %d , unexpected character %s\n", s,yylineno,yytext);} 



