/*
 * PostgreSQL type definitions for CITEXT.
 *
 */

#include "postgres.h"
#include "fmgr.h"

#include "utils/builtins.h"

// PostgreSQL 8.2 Magic.
#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

/*
 *      ==================
 *      MACRO DECLARATIONS
 *      ==================
 */

#define PG_ARGS fcinfo // Might need to change if fmgr changes its name

/*
 *      ====================
 *      FORWARD DECLARATIONS
 *      ====================
 */

extern char * wstring_lower  (char *str); // In oracle_compat.c
static char * cilower        (text * arg);
int           citextcmp      (PG_FUNCTION_ARGS);
extern Datum  citext_cmp     (PG_FUNCTION_ARGS);
extern Datum  citext_eq      (PG_FUNCTION_ARGS);
extern Datum  citext_ne      (PG_FUNCTION_ARGS);
extern Datum  citext_gt      (PG_FUNCTION_ARGS);
extern Datum  citext_ge      (PG_FUNCTION_ARGS);
extern Datum  citext_lt      (PG_FUNCTION_ARGS);
extern Datum  citext_le      (PG_FUNCTION_ARGS);
extern Datum  citext_smaller (PG_FUNCTION_ARGS);
extern Datum  citext_larger  (PG_FUNCTION_ARGS);

/*
 *      =================
 *      UTILITY FUNCTIONS
 *      =================
 */


#if defined(HAVE_WCSTOMBS) && defined(HAVE_TOWLOWER)
#define USE_WIDE_UPPER_LOWER
#endif

char * cilower(text * arg) {
    // Do I need to free anything here?
    char * str = VARDATA_ANY( arg );
#ifdef USE_WIDE_UPPER_LOWER
    // Have wstring_lower() do the work.
    return wstring_lower( str );
# else
    // Copy the string and process it.
    int    inex, len;
    char * result;

    index  = 0;
    len    = VARSIZE(arg) - VARHDRSZ;
    result = (char *) palloc( strlen( str ) + 1 );

    for (index = 0; index <= len; index++) {
        result[index] = tolower((unsigned char) str[index] );
    }
    return result;
#endif   /* USE_WIDE_UPPER_LOWER */
}

int citextcmp (PG_FUNCTION_ARGS) {
    // Could we do away with the varlena struct here?
    text * left  = PG_GETARG_TEXT_P(0);
    text * right = PG_GETARG_TEXT_P(1);
    char * lstr  = cilower( left );
    char * rstr  = cilower( right );
    int    llen  = VARSIZE_ANY_EXHDR(left);
    int    rlen  = VARSIZE_ANY_EXHDR(right);
    return varstr_cmp(lstr, llen, rstr, rlen);
}

/*
 *      ==================
 *      OPERATOR FUNCTIONS
 *      ==================
 */

PG_FUNCTION_INFO_V1(citext_cmp);

Datum citext_cmp (PG_FUNCTION_ARGS) {
    PG_RETURN_INT32( citextcmp( PG_ARGS ) );
}
PG_FUNCTION_INFO_V1(citext_eq);

Datum citext_eq (PG_FUNCTION_ARGS) {
    PG_RETURN_BOOL( citextcmp( PG_ARGS ) == 0 );
}

PG_FUNCTION_INFO_V1(citext_ne);

Datum citext_ne (PG_FUNCTION_ARGS) {
    PG_RETURN_BOOL( citextcmp( PG_ARGS ) != 0 );
}

PG_FUNCTION_INFO_V1(citext_lt);

Datum citext_lt (PG_FUNCTION_ARGS) {
    PG_RETURN_BOOL( citextcmp( PG_ARGS ) < 0 );
}

PG_FUNCTION_INFO_V1(citext_le);

Datum citext_le (PG_FUNCTION_ARGS) {
    PG_RETURN_BOOL( citextcmp( PG_ARGS ) <= 0 );
}

PG_FUNCTION_INFO_V1(citext_gt);

Datum citext_gt (PG_FUNCTION_ARGS) {
    PG_RETURN_BOOL( citextcmp( PG_ARGS ) > 0 );
}

PG_FUNCTION_INFO_V1(citext_ge);

Datum citext_ge (PG_FUNCTION_ARGS) {
    PG_RETURN_BOOL( citextcmp( PG_ARGS ) >= 0 );
}

/*
 *      ===============
 *      OTHER FUNCTIONS
 *      ===============
 */

PG_FUNCTION_INFO_V1(citext_smaller);

Datum citext_smaller (PG_FUNCTION_ARGS) {
    text * left  = PG_GETARG_TEXT_P(0);
    text * right = PG_GETARG_TEXT_P(1);
    PG_RETURN_TEXT_P( citextcmp( PG_ARGS ) < 0 ? left : right );
}

PG_FUNCTION_INFO_V1(citext_larger);

Datum citext_larger (PG_FUNCTION_ARGS) {
    text * left  = PG_GETARG_TEXT_P(0);
    text * right = PG_GETARG_TEXT_P(1);
    PG_RETURN_TEXT_P( citextcmp( PG_ARGS ) > 0 ? left : right );
  //    PG_RETURN_TEXT_P( citextcmp( PG_ARGS ) > 0 ? PG_GETARG_TEXT_P(0) : PG_GETARG_TEXT_P(1) );
}
