/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_MGK_TAB_H_INCLUDED
# define YY_YY_MGK_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    tok_summon = 258,              /* tok_summon  */
    tok_colon = 259,               /* tok_colon  */
    tok_whirl = 260,               /* tok_whirl  */
    tok_from = 261,                /* tok_from  */
    tok_to = 262,                  /* tok_to  */
    tok_cast = 263,                /* tok_cast  */
    tok_when = 264,                /* tok_when  */
    tok_otherwise = 265,           /* tok_otherwise  */
    tok_and = 266,                 /* tok_and  */
    tok_or = 267,                  /* tok_or  */
    tok_not = 268,                 /* tok_not  */
    tok_relop = 269,               /* tok_relop  */
    tok_reveal_var = 270,          /* tok_reveal_var  */
    tok_reveal_str = 271,          /* tok_reveal_str  */
    tok_identifier = 272,          /* tok_identifier  */
    tok_double_literal = 273,      /* tok_double_literal  */
    tok_string_literal = 274       /* tok_string_literal  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 20 "mgk.y"

    char *identifier;
    double double_literal;
    char *string_literal;
    char *op;
    llvm::Value* value; 

#line 91 "mgk.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_MGK_TAB_H_INCLUDED  */
