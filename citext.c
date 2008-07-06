/*
 * PostgreSQL type definitions for CITEXT 2.0.
 *
 */

#include "postgres.h"
#include "fmgr.h"
#include "utils/builtins.h"
#include "access/hash.h"

/* PostgreSQL 8.2 Magic. */
#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

/*
 *      ====================
 *      FORWARD DECLARATIONS
 *      ====================
 */

extern char  *wstring_lower  (char *str); /* In oracle_compat.c */
static char  *cilower        (text *arg);
static int    citextcmp      (text *left, text *right);
extern Datum  citext_cmp     (PG_FUNCTION_ARGS);
extern Datum  citext_hash    (PG_FUNCTION_ARGS);
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

char *
cilower(text *arg)
{
    char *str;

    /* Get a the nul-terminated string from the text struct. */
    str  = DatumGetCString(
        DirectFunctionCall1(textout, PointerGetDatum(arg))
    );

#ifdef USE_WIDE_UPPER_LOWER
    /* Have wstring_lower() do the work. */
    return wstring_lower(str);
# else
    /* Copy the string and process it. */
    int   index, len;
    char *result;

    index  = 0;
    len    = VARSIZE(arg) - VARHDRSZ;
    result = (char *) palloc(strlen(str) + 1);

    for (index = 0; index <= len; index++) {
        result[index] = tolower((unsigned char) str[index] );
    }
    return result;
#endif /* USE_WIDE_UPPER_LOWER */
}


/* citextcmp()
 * Internal comparison function for citext strings.
 * Returns int32 negative, zero, or positive.
 */

static int32
citextcmp (text *left, text *right)
{
    char *lcstr, *rcstr;
    int   result;

    lcstr = cilower(left);
    rcstr = cilower(right);

    result = varstr_cmp(
        lcstr,
        VARSIZE_ANY_EXHDR(left),
        rcstr,
        VARSIZE_ANY_EXHDR(right)
    );

    pfree(lcstr);
    pfree(rcstr);
    return result;
}

/*
 *      ==================
 *      INDEXING FUNCTIONS
 *      ==================
 */

PG_FUNCTION_INFO_V1(citext_cmp);

Datum
citext_cmp(PG_FUNCTION_ARGS)
{
    text *left  = PG_GETARG_TEXT_PP(0);
    text *right = PG_GETARG_TEXT_PP(1);
    int32 result;

    result = citextcmp(left, right);

    PG_FREE_IF_COPY(left, 0);
    PG_FREE_IF_COPY(right, 1);

    PG_RETURN_INT32(result);
}

PG_FUNCTION_INFO_V1(citext_hash);

Datum
citext_hash(PG_FUNCTION_ARGS)
{
    char       *txt;
    char       *str;
    Datum       result;

    txt = cilower(PG_GETARG_TEXT_PP(0));
    str = VARDATA_ANY(txt);

    result = hash_any((unsigned char *) str, VARSIZE_ANY_EXHDR(txt));

    /* Avoid leaking memory for toasted inputs */
    PG_FREE_IF_COPY(txt, 0);
    pfree(str);

    return result;
}

/*
 *      ==================
 *      OPERATOR FUNCTIONS
 *      ==================
 */

PG_FUNCTION_INFO_V1(citext_eq);

Datum
citext_eq(PG_FUNCTION_ARGS)
{
    text *left  = PG_GETARG_TEXT_PP(0);
    text *right = PG_GETARG_TEXT_PP(1);
    bool  result;
    
    /*
     * We can't do the length-comparison optimization here, as is done for the
     * text type in varlena.c, because sometimes the lengths can be different.
     * The canonical example is the turkish dotted i: the lowercase version is
     * the standard ASCII i, but the uppercase version is multibyte.
     */
    result = citextcmp(left, right) == 0;

    PG_FREE_IF_COPY(left, 0);
    PG_FREE_IF_COPY(right, 1);

    PG_RETURN_BOOL(result);
}

PG_FUNCTION_INFO_V1(citext_ne);

Datum
citext_ne(PG_FUNCTION_ARGS)
{
    text *left  = PG_GETARG_TEXT_PP(0);
    text *right = PG_GETARG_TEXT_PP(1);
    bool  result;
    
    /*
     * We can't do the length-comparison optimization here, as is done for the
     * text type in varlena.c, because sometimes the lengths can be different.
     * The canonical example is the turkish dotted i: the lowercase version is
     * the standard ASCII i, but the uppercase version is multibyte.
     */
    result = citextcmp(left, right) != 0;

    PG_FREE_IF_COPY(left, 0);
    PG_FREE_IF_COPY(right, 1);

    PG_RETURN_BOOL(result);
}

PG_FUNCTION_INFO_V1(citext_lt);

Datum
citext_lt(PG_FUNCTION_ARGS)
{
    text *left  = PG_GETARG_TEXT_PP(0);
    text *right = PG_GETARG_TEXT_PP(1);
    bool  result;
    
    result = citextcmp(left, right) < 0;

    PG_FREE_IF_COPY(left, 0);
    PG_FREE_IF_COPY(right, 1);

    PG_RETURN_BOOL(result);
}

PG_FUNCTION_INFO_V1(citext_le);

Datum
citext_le(PG_FUNCTION_ARGS)
{
    text *left  = PG_GETARG_TEXT_PP(0);
    text *right = PG_GETARG_TEXT_PP(1);
    bool  result;
    
    result = citextcmp(left, right) <= 0;

    PG_FREE_IF_COPY(left, 0);
    PG_FREE_IF_COPY(right, 1);

    PG_RETURN_BOOL(result);
}

PG_FUNCTION_INFO_V1(citext_gt);

Datum
citext_gt(PG_FUNCTION_ARGS)
{
    text *left  = PG_GETARG_TEXT_PP(0);
    text *right = PG_GETARG_TEXT_PP(1);
    bool  result;
    
    result = citextcmp(left, right) > 0;

    PG_FREE_IF_COPY(left, 0);
    PG_FREE_IF_COPY(right, 1);

    PG_RETURN_BOOL(result);
}

PG_FUNCTION_INFO_V1(citext_ge);

Datum
citext_ge(PG_FUNCTION_ARGS)
{
    text *left  = PG_GETARG_TEXT_PP(0);
    text *right = PG_GETARG_TEXT_PP(1);
    bool  result;
    
    result = citextcmp(left, right) >= 0;

    PG_FREE_IF_COPY(left, 0);
    PG_FREE_IF_COPY(right, 1);

    PG_RETURN_BOOL(result);
}

/*
 *      ===================
 *      AGGREGATE FUNCTIONS
 *      ===================
 */

PG_FUNCTION_INFO_V1(citext_smaller);

Datum
citext_smaller(PG_FUNCTION_ARGS)
{
    text *left  = PG_GETARG_TEXT_PP(0);
    text *right = PG_GETARG_TEXT_PP(1);
    text *result;

    result = citextcmp(left, right) < 0 ? left : right;
    PG_RETURN_TEXT_P(result);
}

PG_FUNCTION_INFO_V1(citext_larger);

Datum
citext_larger(PG_FUNCTION_ARGS)
{
    text *left  = PG_GETARG_TEXT_PP(0);
    text *right = PG_GETARG_TEXT_PP(1);
    text *result;

    result = citextcmp(left, right) > 0 ? left : right;
    PG_RETURN_TEXT_P(result);
}

