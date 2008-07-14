/*
* PostgreSQL type definitions for CITEXT 2.0.
*/

#include "postgres.h"

#include "access/hash.h"
#include "fmgr.h"
#include "utils/builtins.h"
/* #include "utils/formatting.h" Uncomment me for 8.4. */

/* Delete me for 8.4 -- */
#include "mb/pg_wchar.h"
#include "utils/pg_locale.h"
#include "mb/pg_wchar.h"
#include "tsearch/ts_locale.h"
#include "tsearch/ts_public.h"
/* --Delete me for 8.4 */

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

/*
*      ====================
*      FORWARD DECLARATIONS
*      ====================
*/

extern char  *str_tolower(const char *buff, size_t nbytes);
static int32  citextcmp      (text *left, text *right);
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


/* Delete me -- Copied from CVS HEAD for 8.4. */
char *
str_tolower(const char *buff, size_t nbytes)
{
	char		*result;

	if (!buff)
		return NULL;

#if defined(HAVE_WCSTOMBS) && defined(HAVE_TOWLOWER)
	if (pg_database_encoding_max_length() > 1 && !lc_ctype_is_c())
	{
		wchar_t		*workspace;
		int			curr_char = 0;

		/* Output workspace cannot have more codes than input bytes */
		workspace = (wchar_t *) palloc((nbytes + 1) * sizeof(wchar_t));

		char2wchar(workspace, nbytes + 1, buff, nbytes);

		for (curr_char = 0; workspace[curr_char] != 0; curr_char++)
			workspace[curr_char] = towlower(workspace[curr_char]);

		/* Make result large enough; case change might change number of bytes */
		result = palloc(curr_char * MB_CUR_MAX + 1);

		wchar2char(result, workspace, curr_char * MB_CUR_MAX + 1);
		pfree(workspace);
	}
	else
#endif		/* defined(HAVE_WCSTOMBS) && defined(HAVE_TOWLOWER) */
	{
		char *p;

		result = pnstrdup(buff, nbytes);

		for (p = result; *p; p++)
			*p = pg_tolower((unsigned char) *p);
	}

	return result;
}

/* --Delete me for 8.4 */

/* citextcmp()
* Internal comparison function for citext strings.
* Returns int32 negative, zero, or positive.
*/

static int32
citextcmp (text *left, text *right)
{
   char   *lcstr, *rcstr;
   int32	result;

   lcstr = str_tolower(VARDATA_ANY(left), VARSIZE_ANY_EXHDR(left));
   rcstr = str_tolower(VARDATA_ANY(right), VARSIZE_ANY_EXHDR(right));

   result = varstr_cmp(lcstr, strlen(lcstr),
						rcstr, strlen(rcstr));

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
   text       *txt = PG_GETARG_TEXT_PP(0);
   char       *str;
   Datum       result;

   str    = str_tolower(VARDATA_ANY(txt), VARSIZE_ANY_EXHDR(txt));
   result = hash_any((unsigned char *) str, strlen(str));
   pfree(str);

   /* Avoid leaking memory for toasted inputs */
   PG_FREE_IF_COPY(txt, 0);

   PG_RETURN_DATUM(result);
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
   char *lcstr, *rcstr;
   bool  result;

   lcstr = str_tolower(VARDATA_ANY(left), VARSIZE_ANY_EXHDR(left));
   rcstr = str_tolower(VARDATA_ANY(right), VARSIZE_ANY_EXHDR(right));

   /*
    * We can't do the length-comparison optimization here, as is done for the
    * text type in varlena.c, because sometimes the lengths can be different.
    * The canonical example is the turkish dotted i: the lowercase version is
    * the standard ASCII i, but the uppercase version is multibyte.
    * Otherwise, since we only care about equality or not-equality, we can
    * avoid all the expense of strcoll() here, and just do bitwise
    * comparison.
    */
   result = (strcmp(lcstr, rcstr) == 0);

   pfree(lcstr);
   pfree(rcstr);
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
   char *lcstr, *rcstr;
   bool  result;

   lcstr = str_tolower(VARDATA_ANY(left), VARSIZE_ANY_EXHDR(left));
   rcstr = str_tolower(VARDATA_ANY(right), VARSIZE_ANY_EXHDR(right));

   /*
    * We can't do the length-comparison optimization here, as is done for the
    * text type in varlena.c, because sometimes the lengths can be different.
    * The canonical example is the turkish dotted i: the lowercase version is
    * the standard ASCII i, but the uppercase version is multibyte.
    * Otherwise, since we only care about equality or not-equality, we can
    * avoid all the expense of strcoll() here, and just do bitwise
    * comparison.
    */
   result = (strcmp(lcstr, rcstr) != 0);

   pfree(lcstr);
   pfree(rcstr);
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
