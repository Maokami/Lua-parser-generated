/*
 * Lua 5.1 grammar
 * 
 * Nicolai Mainiero
 * May 2007
 * 
 * This is a Lua (http://www.lua.org) grammar for the version 5.1 for ANTLR 3.
 * I tested it with basic and extended examples and it worked fine. It is also used
 * for LunarEclipse (http://lunareclipse.sf.net) a Lua editor based on Eclipse.
 * 
 * Thanks to Johannes Luber and Gavin Lambert who helped me with some mutually left recursion.
 *  
 */

grammar Lua;

options {
  backtrack=true;
  language=C;
  ASTLabelType=pANTLR3_BASE_TREE;
  output  = AST;
}


program : (statement (';')?)* (laststatement (';')?)?;

block : program;

statement :  varlist1 '=' exprlist1 | 
	functioncall | 
	'do' block 'end' | 
	'while' expr 'do' block 'end' | 
	'repeat' block 'until' expr | 
	'if' expr 'then' block ('elseif' expr 'then' block)* ('else' block)? 'end' | 
	'for' NAME '=' expr ',' expr (',' expr)? 'do' block 'end' | 
	'for' namelist 'in' exprlist1 'do' block 'end' | 
	'function' funcname funcbody | 
	'local' 'function' NAME funcbody | 
	'local' namelist ('=' exprlist1)? ;

laststatement : 'return' (exprlist1)? | 'break';

funcname : NAME ('.' NAME)* (':' NAME)? ;

varlist1 : var (',' var)*;


namelist : NAME (',' NAME)*;

exprlist1 : (expr ',')* expr;

expr :  ('nil' | 'false' | 'true' | number | string | '...' | function | prefixexpr | tableconstructor | unop expr) (binop expr)* ;

var: (NAME | '(' expr ')' varSuffix) varSuffix*;

prefixexpr: varOrexpr nameAndArgs*;

functioncall: varOrexpr nameAndArgs+;

/*
var :  NAME | prefixexpr '[' expr ']' | prefixexpr '.' NAME; 

prefixexpr : var | functioncall | '(' expr ')';

functioncall :  prefixexpr args | prefixexpr ':' NAME args ;
*/

varOrexpr: var | '(' expr ')';

nameAndArgs: (':' NAME)? args;

varSuffix: nameAndArgs* ('[' expr ']' | '.' NAME);

args :  '(' (exprlist1)? ')' | tableconstructor | string ;

function : 'function' funcbody;

funcbody : '(' (parlist1)? ')' block 'end';

parlist1 : namelist (',' '...')? | '...';

tableconstructor : '{' (fieldlist)? '}';

fieldlist : field (fieldsep field)* (fieldsep)?;

field : '[' expr ']' '=' expr | NAME '=' expr | expr;

fieldsep : ',' | ';';

binop : '+' | '-' | '*' | '/' | '^' | '%' | '..' | 
		 '<' | '<=' | '>' | '>=' | '==' | '~=' | 
		 'and' | 'or';

unop : '-' | 'not' | '#';

number : INT | FLOAT | EXPO | HEX;

string	: NORMALSTRING | CHARSTRING | LONGSTRING;


// LEXER

NAME	:('a'..'z'|'A'..'Z'|'_')(options{greedy=true;}:	'a'..'z'|'A'..'Z'|'_'|'0'..'9')*
	;

INT	: ('0'..'9')+;

FLOAT 	:INT '.' INT ;

EXPO	: (INT| FLOAT) ('E'|'e') ('-')? INT;

HEX	:'0x' ('0'..'9'| 'a'..'f')+ ;

	

NORMALSTRING
    :  '"' ( EscapeSequence | ~('\\'|'"') )* '"' 
    ;

CHARSTRING
   :	'\'' ( EscapeSequence | ~('\''|'\\') )* '\''
   ;

LONGSTRING
	:	'['('=')*'[' ( EscapeSequence | ~('\\'|']') )* ']'('=')*']'
	;

fragment
EscapeSequence
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    |   UnicodeEscape
    |   OctalEscape
    ;
    
fragment
OctalEscape
    :   '\\' ('0'..'3') ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7')
    ;
    
fragment
UnicodeEscape
    :   '\\' 'u' HexDigit HexDigit HexDigit HexDigit
    ;
    
fragment
HexDigit : ('0'..'9'|'a'..'f'|'A'..'F') ;


COMMENT
    :   '--[[' ( options {greedy=false;} : . )* ']]'
    ;
    
LINE_COMMENT
    : '--' ~('\n'|'\r')* '\r'? '\n'
    ;
    
    
WS  :  (' '|'\t'|'\u000C')
    ;
    
NEWLINE	: ('\r')? '\n'
	;
