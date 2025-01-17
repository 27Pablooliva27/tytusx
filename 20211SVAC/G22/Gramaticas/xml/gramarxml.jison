/**
 * Ejemplo mi primer proyecto con Jison utilizando Nodejs en Ubuntu
 */

%{	
    const {ObjetoNodo} = require("./Scripts/clasesXML/ObjetoNodo.js");
	const {Atributo} = require("./Scripts/clasesXML/Atributo.js");
	const Error = require('./Scripts/Errores/Error.js');
	var erroresLexicos = [];
	var variables=[];
	var erroresSintacticos = [];
%}
/* DefINIción Léxica */
%lex

%options case-insensitive

%%


";"                 return 'ptcoma';
"("                 return 'parizq';
")"                 return 'parder';
"["                 return 'corizq';
"]"                 return 'corder';
"<"                 return 'menosque';
">"                 return 'masque';
"="                 return 'igual';
"\""			return 'comilla';
"'"				return 'apostrofe';
"!"				return 'inicoment';
"?"				return 'c_interroga';
"xml" 			return 'xml';
"version"		return 'version';
"encoding"		return 'encoding';
"UTF-8"			return 'UTF'
"ASCII"			return 'ASCII';
"ISO859-1"		return 'ISO';
"&lt;"			return 'lessthan';
"&gt;"			return 'graterthan';
"&amp;"			return 'ampersand';
"&apos;"		return 'simplequote';
"&quot;"		return 'doublequote';
":"				return 'colon';
"_"				return 'underscore';

"+"                 return 'mas';
"-"                 return 'menos';
"*"                 return 'por';
"/"                 return 'div';

/* Espacios en blanco */
[ \r\t]+            {}
\n                  {}

[0-9]+("."[0-9]+)?\b    return 'decimal';
[0-9]+\b                return 'entero';
([a-zA-Z0-9])[a-zA-Z0-9_nÑ]* return 'identificador'; 

<<EOF>>                 return 'EOF';

.                       { console.error('Este es un error léxico: ' + yytext + ', en la linea: ' + yylloc.first_line + ', en la columna: ' + yylloc.first_column); }
/lex

/* Asociación de operadores y precedencia */

%left 'mas' 'menos'
%left 'por' 'div'
%left Umenos

%start S

%% /* Definición de la gramática */

S : XML_GRAMAR EOF 	{ $$ = $1; return $$; }
;

XML_GRAMAR :  
	ENCABEZADO ABRIR_ELEMENTO CONTENIDO_ELEMENTO 	{ $$ = new ObjetoNodo($2,'', null,$3,@1.first_line, @1.first_column); }
;

/*    <?xml version="1.0" encoding="UTF-8"?>    */
ENCABEZADO : 
	menosque c_interroga xml version igual QUOTES TIPO_DATO QUOTES encoding igual QUOTES FORMAT QUOTES c_interroga masque  
	{ $$ = new ObjetoNodo($4,'', null,$2,@1.first_line, @1.first_column); }
;

FORMAT 
	: UTF 				
	| ASCII 			
	| ISO 				
;	

ELEMENTOS :   
	ELEMENTOS  ELEMENTO 	{ $1.push($2); $$ = $1;}
	| ELEMENTO				{ $$ = [$1]; } 
	| error { console.error('Este es un error sintáctico: ' + yytext + ', en la linea: ' + this._$.first_line + ', en la columna: ' + this._$.first_column); }
;

ELEMENTO :  
	ABRIR_ELEMENTO 	CONTENIDO_ELEMENTO  { $$ = new ObjetoNodo($1,'', null,$2,@1.first_line, @1.first_column); }
;


ABRIR_ELEMENTO : 
	menosque identificador  			{ $$ = $2 }
	| menosque inicoment menos menos 	{ $$ = 'comentario' } // COMENTARIO
; 

CONTENIDO_ELEMENTO: ETIQUETA 	{ $$ = $1 }
	| COMENTARIO 				{ $$ = null } // COMENTARIO
;

ETIQUETA : 
	ATRIBUTOS  CIERRE_ELEMENTO      { $$ = new ObjetoNodo('','',$1 ,$2,@1.first_line, @1.first_column); }
	| CIERRE_ELEMENTO				{ $$ = $1 }
;

ATRIBUTOS : ATRIBUTOS ATRIBUTO 		{ $1.push($2); $$ = $1;}
	| ATRIBUTO 						{ $$ = [$1]; } 
;

ATRIBUTO : identificador igual QUOTES C_ATRIBUTO QUOTES  { $$ = new Atributo($1,$4,@1.first_line, @1.first_column); }
;

C_ATRIBUTO : C_ATRIBUTO TIPOCONTENIDO		{ $1.push($2); $$ = $1;}
	| TIPOCONTENIDO							{ $$ = [$1]; } 
;

CIERRE_ELEMENTO : 
	masque CONTENIDO_ETIQUETA menosque div identificador masque  	{ $$ = new ObjetoNodo($5,'', null,$2,@1.first_line, @1.first_column); }
	| masque menosque div identificador masque						{ $$ = new ObjetoNodo($4,'', null,null,@1.first_line, @1.first_column); }
	| div masque 													//{ $$ = new ObjetoNodo('','',null,null,@1.first_line, @1.first_column); }
;

COMENTARIO : C_TEXTO menos menos masque  
	| menos menos masque
;

C_TEXTO: C_TEXTO TIPO_DATO		
	| TIPO_DATO					
;

CONTENIDO_ETIQUETA : CONTENIDO_ETIQUETA TIPO		{ $1.push($2); $$ = $1;}
	| TIPO 											{ $$ = [$1]; } 
;
TIPO
	:TIPOCONTENIDO 	{ $$ = $1 }
	| ELEMENTO 		{ $$ = $1 }
;	

TIPOCONTENIDO 
	:TIPO_DATO 			{ $$ = $1 }
	| SIGNOS 			{ $$ = $1 }
	| SPECIALCHARS		{ $$ = $1 }
;		

SPECIALCHARS 
	:lessthan		{ $$ = new ObjetoNodo($1,'<',null,null,@1.first_line, @1.first_column); }
	|graterthan		{ $$ = new ObjetoNodo($1,'>',null,null,@1.first_line, @1.first_column); }
	|ampersand		{ $$ = new ObjetoNodo($1,'&',null,null,@1.first_line, @1.first_column); }
	|simplequote	{ $$ = new ObjetoNodo($1,'\'',null,null,@1.first_line, @1.first_column); }
	|doublequote	{ $$ = new ObjetoNodo($1,'"',null,null,@1.first_line, @1.first_column); }	
	|colon			{ $$ = new ObjetoNodo($1,':',null,null,@1.first_line, @1.first_column); }	
	|underscore		{ $$ = new ObjetoNodo($1,'_',null,null,@1.first_line, @1.first_column); }
	|corder			{ $$ = new ObjetoNodo($1,'{',null,null,@1.first_line, @1.first_column); }
	|corizq			{ $$ = new ObjetoNodo($1,'}',null,null,@1.first_line, @1.first_column); }
	|parder			{ $$ = new ObjetoNodo($1,'(',null,null,@1.first_line, @1.first_column); }
	|parizq			{ $$ = new ObjetoNodo($1,')',null,null,@1.first_line, @1.first_column); }
	|ptcoma			{ $$ = new ObjetoNodo($1,';',null,null,@1.first_line, @1.first_column); }
;		

TIPO_DATO 
	: identificador		{ $$ = new ObjetoNodo($1,$1,null,null,@1.first_line, @1.first_column); }
	|decimal			{ $$ = new ObjetoNodo(Number($1),Number($1),null,null,@1.first_line, @1.first_column); }
	|entero				{ $$ = new ObjetoNodo(Number($1),Number($1),null,null,@1.first_line, @1.first_column); }
;

SIGNOS 
	: mas  				{ $$ = new ObjetoNodo($1,$1,null,null,@1.first_line, @1.first_column); }	
	| menos 			{ $$ = new ObjetoNodo($1,$1,null,null,@1.first_line, @1.first_column); }
	| por 				{ $$ = new ObjetoNodo($1,$1,null,null,@1.first_line, @1.first_column); }
	| div 				{ $$ = new ObjetoNodo($1,$1,null,null,@1.first_line, @1.first_column); }
;

QUOTES 
	: comilla 			{ $$ = new ObjetoNodo($1,$1,null,null,@1.first_line, @1.first_column); }
	| apostrofe			{ $$ = new ObjetoNodo($1,$1,null,null,@1.first_line, @1.first_column); }
;


