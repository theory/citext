--
--  PostgreSQL code for CITEXT.
--
-- Most I/O functions, and a few others, piggyback on the "text" type
-- functions via the implicit cast to text.
--

--
-- Shell type to keep things a bit quieter.
--

CREATE TYPE citext;

--
--  Input and output functions.
--
SET client_min_messages = warning; /* Delete for 8.4 */

CREATE OR REPLACE FUNCTION citextin(cstring)
RETURNS citext
AS 'textin'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citextout(citext)
RETURNS cstring
AS 'textout'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citextrecv(internal)
RETURNS citext
AS 'textrecv'
LANGUAGE internal STABLE STRICT;

CREATE OR REPLACE FUNCTION citextsend(citext)
RETURNS bytea
AS 'textsend'
LANGUAGE internal STABLE STRICT;

RESET client_min_messages; /* Delete for 8.4 */

--
--  The type itself.
--

CREATE TYPE citext (
    INPUT          = citextin,
    OUTPUT         = citextout,
    RECEIVE        = citextrecv,
    SEND           = citextsend,
    INTERNALLENGTH = VARIABLE,
    STORAGE        = extended
/* Uncomment me and add a comma above for 8.4.
    -- make it a non-preferred member of string type category
    CATEGORY       = 'S',
    PREFERRED      = false
*/
);

--
-- Type casting functions for those situations where the I/O casts don't
-- automatically kick in.
--

CREATE OR REPLACE FUNCTION citext(bpchar)
RETURNS citext
AS 'rtrim1'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(boolean)
RETURNS citext
AS 'booltext'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(inet)
RETURNS citext
AS 'network_show'
LANGUAGE internal IMMUTABLE STRICT;

/* Delete me for 8.4 -- */
CREATE OR REPLACE FUNCTION inet(citext)
RETURNS inet
AS 'SELECT inet( $1::text )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bool(citext)
RETURNS boolean
AS 'SELECT bool( $1::text )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION "char"(citext)
RETURNS "char"
AS 'text_char'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext("char")
RETURNS citext
AS 'char_text'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION int8(citext)
RETURNS int8
AS 'SELECT int8( $1::text )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(int8)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION int4(citext)
RETURNS int4
AS 'SELECT int4( $1::text )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(int4)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION int2(citext)
RETURNS int2
AS 'SELECT int2( $1::text )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(int2)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION float4(citext)
RETURNS float4
AS 'SELECT float4( $1::text )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(float4)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION float8(citext)
RETURNS float8
AS 'SELECT float8( $1::text )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(float8)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION numerik(citext)
RETURNS numeric
AS 'SELECT CAST( $1::text AS numeric)'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(numeric)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION name(citext)
RETURNS name
AS 'text_name'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(name)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION cidr(citext)
RETURNS cidr
AS 'SELECT cidr( $1::text )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(cidr)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION macaddr(citext)
RETURNS macaddr
AS 'SELECT macaddr( $1::text )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(macaddr)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION xml(citext)
RETURNS xml
AS 'texttoxml'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(xml)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION money(citext)
RETURNS money
AS 'SELECT money( $1::text )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(money)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION tstamp(citext)
RETURNS timestamp
AS 'SELECT cast( $1::text as timestamp )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(timestamp)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION timestamptz(citext)
RETURNS timestamptz
AS 'SELECT cast( $1::text as timestamptz )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(timestamptz)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION ival(citext)
RETURNS interval
AS 'SELECT cast( $1::text as interval )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(interval)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION date(citext)
RETURNS date
AS 'SELECT cast( $1::text as date )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(date)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION tme(citext)
RETURNS time
AS 'SELECT cast( $1::text as time )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(time)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION timetz(citext)
RETURNS timetz
AS 'SELECT cast( $1::text as timetz )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(timetz)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

-- XXX TODO Hrm, how to cast enums? Too much magic.

CREATE OR REPLACE FUNCTION point(citext)
RETURNS point
AS 'SELECT cast( $1::text as point )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(point)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION lseg(citext)
RETURNS lseg
AS 'SELECT cast( $1::text as lseg )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(lseg)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION box(citext)
RETURNS box
AS 'SELECT cast( $1::text as box )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(box)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION path(citext)
RETURNS path
AS 'SELECT cast( $1::text as path )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(path)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION polygon(citext)
RETURNS polygon
AS 'SELECT cast( $1::text as polygon )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(polygon)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION circle(citext)
RETURNS circle
AS 'SELECT cast( $1::text as circle )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(circle)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bitt(citext)
RETURNS bit
AS 'SELECT cast( $1::text as bit )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(bit)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bitv(citext)
RETURNS bit varying
AS 'SELECT cast( $1::text as bit varying )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(bit varying)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION tsvector(citext)
RETURNS tsvector
AS 'SELECT cast( $1::text as tsvector )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(tsvector)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION tsquery(citext)
RETURNS tsquery
AS 'SELECT cast( $1::text as tsquery )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(tsquery)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION uuid(citext)
RETURNS uuid
AS 'SELECT cast( $1::text as uuid )'
LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext(uuid)
RETURNS citext
AS 'SELECT text( $1 )::citext'
LANGUAGE SQL IMMUTABLE STRICT;
/* --Delete me for 8.4 */

--
--  Implicit and assignment type casts.
--

CREATE CAST (citext AS text)    WITHOUT FUNCTION AS IMPLICIT;
CREATE CAST (citext AS varchar) WITHOUT FUNCTION AS IMPLICIT;
CREATE CAST (citext AS bpchar)  WITHOUT FUNCTION AS ASSIGNMENT;
CREATE CAST (text AS citext)    WITHOUT FUNCTION AS ASSIGNMENT;
CREATE CAST (varchar AS citext) WITHOUT FUNCTION AS ASSIGNMENT;
CREATE CAST (bpchar AS citext)  WITH FUNCTION citext(bpchar)  AS ASSIGNMENT;
CREATE CAST (boolean AS citext) WITH FUNCTION citext(boolean) AS ASSIGNMENT;
CREATE CAST (inet AS citext)    WITH FUNCTION citext(inet)    AS ASSIGNMENT;
/* Delete me for 8.4 -- */
CREATE CAST (bytea       AS citext)      WITHOUT FUNCTION                     AS ASSIGNMENT;
CREATE CAST (citext      AS bytea)       WITHOUT FUNCTION;

CREATE CAST (citext      AS boolean)     WITH    FUNCTION bool(citext);
CREATE CAST ("char"        AS citext)    WITH    FUNCTION citext("char")      AS ASSIGNMENT;
CREATE CAST (citext      AS "char")      WITH    FUNCTION "char"(citext)      AS ASSIGNMENT;
CREATE CAST (float4      AS citext)      WITH    FUNCTION citext(float4)      AS ASSIGNMENT;
CREATE CAST (citext      AS float4)      WITH    FUNCTION float4(citext);
CREATE CAST (float8      AS citext)      WITH    FUNCTION citext(float8)      AS ASSIGNMENT;
CREATE CAST (citext      AS float8)      WITH    FUNCTION float8(citext);
CREATE CAST (numeric     AS citext)      WITH    FUNCTION citext(numeric)     AS ASSIGNMENT;
CREATE CAST (citext      AS numeric)     WITH    FUNCTION numerik(citext);
CREATE CAST (int8        AS citext)      WITH    FUNCTION citext(int8)        AS ASSIGNMENT;
CREATE CAST (citext      AS int8)        WITH    FUNCTION int8(citext);
CREATE CAST (int4        AS citext)      WITH    FUNCTION citext(int4)        AS ASSIGNMENT;
CREATE CAST (citext      AS int4)        WITH    FUNCTION int4(citext);
CREATE CAST (int2        AS citext)      WITH    FUNCTION citext(int2)        AS ASSIGNMENT;
CREATE CAST (citext      AS int2)        WITH    FUNCTION int2(citext);
CREATE CAST (name        AS citext)      WITH    FUNCTION citext(name)        AS ASSIGNMENT;
CREATE CAST (citext      AS name)        WITH    FUNCTION name(citext)        AS ASSIGNMENT;
CREATE CAST (cidr        AS citext)      WITH    FUNCTION citext(cidr)        AS ASSIGNMENT;
CREATE CAST (citext      AS cidr)        WITH    FUNCTION cidr(citext);
CREATE CAST (citext      AS inet)        WITH    FUNCTION inet(citext);
CREATE CAST (macaddr     AS citext)      WITH    FUNCTION citext(macaddr)     AS ASSIGNMENT;
CREATE CAST (citext      AS macaddr)     WITH    FUNCTION macaddr(citext);
CREATE CAST (xml         AS citext)      WITH    FUNCTION citext(xml)         AS ASSIGNMENT;
CREATE CAST (citext      AS xml)         WITH    FUNCTION xml(citext);
CREATE CAST (money       AS citext)      WITH    FUNCTION citext(money)       AS ASSIGNMENT;
CREATE CAST (citext      AS money)       WITH    FUNCTION money(citext);

CREATE CAST (timestamp   AS citext)      WITH    FUNCTION citext(timestamp)   AS ASSIGNMENT;
CREATE CAST (citext      AS timestamp)   WITH    FUNCTION tstamp(citext);
CREATE CAST (timestamptz AS citext)      WITH    FUNCTION citext(timestamptz) AS ASSIGNMENT;
CREATE CAST (citext      AS timestamptz) WITH    FUNCTION timestamptz(citext);

CREATE CAST (interval    AS citext)      WITH    FUNCTION citext(interval)    AS ASSIGNMENT;
CREATE CAST (citext      AS interval)    WITH    FUNCTION ival(citext);

CREATE CAST (date        AS citext)      WITH    FUNCTION citext(date)        AS ASSIGNMENT;
CREATE CAST (citext      AS date)        WITH    FUNCTION date(citext);
CREATE CAST (time        AS citext)      WITH    FUNCTION citext(time)        AS ASSIGNMENT;
CREATE CAST (citext      AS time)        WITH    FUNCTION tme(citext);
CREATE CAST (timetz      AS citext)      WITH    FUNCTION citext(timetz)      AS ASSIGNMENT;
CREATE CAST (citext      AS timetz)      WITH    FUNCTION timetz(citext);

CREATE CAST (point       AS citext)      WITH    FUNCTION citext(point)       AS ASSIGNMENT;
CREATE CAST (citext      AS point)       WITH    FUNCTION point(citext);
CREATE CAST (lseg        AS citext)      WITH    FUNCTION citext(lseg)        AS ASSIGNMENT;
CREATE CAST (citext      AS lseg)        WITH    FUNCTION lseg(citext);
CREATE CAST (box         AS citext)      WITH    FUNCTION citext(box)         AS ASSIGNMENT;
CREATE CAST (citext      AS box)         WITH    FUNCTION box(citext);
CREATE CAST (path        AS citext)      WITH    FUNCTION citext(path)        AS ASSIGNMENT;
CREATE CAST (citext      AS path)        WITH    FUNCTION path(citext);
CREATE CAST (polygon     AS citext)      WITH    FUNCTION citext(polygon)     AS ASSIGNMENT;
CREATE CAST (citext      AS polygon)     WITH    FUNCTION polygon(citext);
CREATE CAST (circle      AS citext)      WITH    FUNCTION citext(circle)      AS ASSIGNMENT;
CREATE CAST (citext      AS circle)      WITH    FUNCTION circle(citext);

CREATE CAST (bit         AS citext)      WITH    FUNCTION citext(bit)         AS ASSIGNMENT;
CREATE CAST (citext      AS bit)         WITH    FUNCTION bitt(citext);
CREATE CAST (bit varying AS citext)      WITH    FUNCTION citext(bit varying) AS ASSIGNMENT;
CREATE CAST (citext      AS bit varying) WITH    FUNCTION bitv(citext);

CREATE CAST (tsvector    AS citext)      WITH    FUNCTION citext(tsvector)    AS ASSIGNMENT;
CREATE CAST (citext      AS tsvector)    WITH    FUNCTION tsvector(citext);
CREATE CAST (tsquery     AS citext)      WITH    FUNCTION citext(tsquery)     AS ASSIGNMENT;
CREATE CAST (citext      AS tsquery)     WITH    FUNCTION tsquery(citext);

CREATE CAST (uuid        AS citext)      WITH    FUNCTION citext(uuid)        AS ASSIGNMENT;
CREATE CAST (citext      AS uuid)        WITH    FUNCTION uuid(citext);
/* --Delete me for 8.4 */

--
-- Operator Functions.
--

CREATE OR REPLACE FUNCTION citext_eq( citext, citext )
RETURNS bool
AS 'citext'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext_ne( citext, citext )
RETURNS bool
AS 'citext'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext_lt( citext, citext )
RETURNS bool
AS 'citext'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext_le( citext, citext )
RETURNS bool
AS 'citext'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext_gt( citext, citext )
RETURNS bool
AS 'citext'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext_ge( citext, citext )
RETURNS bool
AS 'citext'
LANGUAGE C IMMUTABLE STRICT;

/* Delete me for 8.4 -- */
-- We overload || just to preserve "citext-ness" of the result.
CREATE OR REPLACE FUNCTION textcat(citext, citext)
RETURNS citext
AS 'textcat'
LANGUAGE internal IMMUTABLE STRICT;
/* --Delete me for 8.4 */

--
-- Operators.
--

CREATE OPERATOR = (
    LEFTARG    = CITEXT,
    RIGHTARG   = CITEXT,
    COMMUTATOR = =,
    NEGATOR    = <>,
    PROCEDURE  = citext_eq,
    RESTRICT   = eqsel,
    JOIN       = eqjoinsel,
    HASHES,
    MERGES
);

CREATE OPERATOR <> (
    LEFTARG    = CITEXT,
    RIGHTARG   = CITEXT,
    NEGATOR    = =,
    COMMUTATOR = <>,
    PROCEDURE  = citext_ne,
    RESTRICT   = neqsel,
    JOIN       = neqjoinsel
);

CREATE OPERATOR < (
    LEFTARG    = CITEXT,
    RIGHTARG   = CITEXT,
    NEGATOR    = >=,
    COMMUTATOR = >,
    PROCEDURE  = citext_lt,
    RESTRICT   = scalarltsel,
    JOIN       = scalarltjoinsel
);

CREATE OPERATOR <= (
    LEFTARG    = CITEXT,
    RIGHTARG   = CITEXT,
    NEGATOR    = >,
    COMMUTATOR = >=,
    PROCEDURE  = citext_le,
    RESTRICT   = scalarltsel,
    JOIN       = scalarltjoinsel
);

CREATE OPERATOR >= (
    LEFTARG    = CITEXT,
    RIGHTARG   = CITEXT,
    NEGATOR    = <,
    COMMUTATOR = <=,
    PROCEDURE  = citext_ge,
    RESTRICT   = scalargtsel,
    JOIN       = scalargtjoinsel
);

CREATE OPERATOR > (
    LEFTARG    = CITEXT,
    RIGHTARG   = CITEXT,
    NEGATOR    = <=,
    COMMUTATOR = <,
    PROCEDURE  = citext_gt,
    RESTRICT   = scalargtsel,
    JOIN       = scalargtjoinsel
);

/* Delete me for 8.4 -- */
CREATE OPERATOR || (
    LEFTARG   = CITEXT,
    RIGHTARG  = CITEXT,
    PROCEDURE = textcat
);
/* -- Delete me for 8.4 */

--
-- Support functions for indexing.
--

CREATE OR REPLACE FUNCTION citext_cmp(citext, citext)
RETURNS int4
AS 'citext'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION citext_hash(citext)
RETURNS int4
AS 'citext'
LANGUAGE C STRICT IMMUTABLE;

--
-- The btree indexing operator class.
--

CREATE OPERATOR CLASS citext_ops
DEFAULT FOR TYPE CITEXT USING btree AS
    OPERATOR    1   <  (citext, citext),
    OPERATOR    2   <= (citext, citext),
    OPERATOR    3   =  (citext, citext),
    OPERATOR    4   >= (citext, citext),
    OPERATOR    5   >  (citext, citext),
    FUNCTION    1   citext_cmp(citext, citext);

--
-- The hash indexing operator class.
--

CREATE OPERATOR CLASS citext_ops
DEFAULT FOR TYPE citext USING hash AS
    OPERATOR    1   =  (citext, citext),
    FUNCTION    1   citext_hash(citext);

--
-- Aggregates.
--

CREATE OR REPLACE FUNCTION citext_smaller(citext, citext)
RETURNS citext
AS 'citext'
LANGUAGE 'C' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION citext_larger(citext, citext)
RETURNS citext
AS 'citext'
LANGUAGE 'C' IMMUTABLE STRICT;

CREATE AGGREGATE min(citext)  (
    SFUNC = citext_smaller,
    STYPE = citext,
    SORTOP = <
);

CREATE AGGREGATE max(citext)  (
    SFUNC = citext_larger,
    STYPE = citext,
    SORTOP = >
);

/* Delete me for 8.4 -- */
--
-- Miscellaneous functions
-- These exist to preserve the "citext-ness" of the input.
--

CREATE OR REPLACE FUNCTION lower(citext)
RETURNS citext AS 'lower'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION upper(citext)
RETURNS citext AS 'upper'
LANGUAGE internal IMMUTABLE STRICT;

-- needed to avoid "function is not unique" errors
-- XXX find a better way to deal with this...
CREATE FUNCTION quote_literal(citext)
RETURNS text AS 'quote_literal'
LANGUAGE internal IMMUTABLE STRICT;
/* -- Delete me for 8.4 */

--
-- CITEXT pattern matching.
--

CREATE OR REPLACE FUNCTION texticlike(citext, citext)
RETURNS bool AS 'texticlike'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION texticnlike(citext, citext)
RETURNS bool AS 'texticnlike'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION texticregexeq(citext, citext)
RETURNS bool AS 'texticregexeq'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION texticregexne(citext, citext)
RETURNS bool AS 'texticregexne'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OPERATOR ~ (
    PROCEDURE = texticregexeq,
    LEFTARG   = citext,
    RIGHTARG  = citext,
    NEGATOR   = !~,
    RESTRICT  = icregexeqsel,
    JOIN      = icregexeqjoinsel
);

CREATE OPERATOR ~* (
    PROCEDURE = texticregexeq,
    LEFTARG   = citext,
    RIGHTARG  = citext,
    NEGATOR   = !~*,
    RESTRICT  = icregexeqsel,
    JOIN      = icregexeqjoinsel
);

CREATE OPERATOR !~ (
    PROCEDURE = texticregexne,
    LEFTARG   = citext,
    RIGHTARG  = citext,
    NEGATOR   = ~,
    RESTRICT  = icregexnesel,
    JOIN      = icregexnejoinsel
);

CREATE OPERATOR !~* (
    PROCEDURE = texticregexne,
    LEFTARG   = citext,
    RIGHTARG  = citext,
    NEGATOR   = ~*,
    RESTRICT  = icregexnesel,
    JOIN      = icregexnejoinsel
);

CREATE OPERATOR ~~ (
    PROCEDURE = texticlike,
    LEFTARG   = citext,
    RIGHTARG  = citext,
    NEGATOR   = !~~,
    RESTRICT  = iclikesel,
    JOIN      = iclikejoinsel
);

CREATE OPERATOR ~~* (
    PROCEDURE = texticlike,
    LEFTARG   = citext,
    RIGHTARG  = citext,
    NEGATOR   = !~~*,
    RESTRICT  = iclikesel,
    JOIN      = iclikejoinsel
);

CREATE OPERATOR !~~ (
    PROCEDURE = texticnlike,
    LEFTARG   = citext,
    RIGHTARG  = citext,
    NEGATOR   = ~~,
    RESTRICT  = icnlikesel,
    JOIN      = icnlikejoinsel
);

CREATE OPERATOR !~~* (
    PROCEDURE = texticnlike,
    LEFTARG   = citext,
    RIGHTARG  = citext,
    NEGATOR   = ~~*,
    RESTRICT  = icnlikesel,
    JOIN      = icnlikejoinsel
);

--
-- Matching citext to text. 
--

CREATE OR REPLACE FUNCTION texticlike(citext, text)
RETURNS bool AS 'texticlike'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION texticnlike(citext, text)
RETURNS bool AS 'texticnlike'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION texticregexeq(citext, text)
RETURNS bool AS 'texticregexeq'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION texticregexne(citext, text)
RETURNS bool AS 'texticregexne'
LANGUAGE internal IMMUTABLE STRICT;

CREATE OPERATOR ~ (
    PROCEDURE = texticregexeq,
    LEFTARG   = citext,
    RIGHTARG  = text,
    NEGATOR   = !~,
    RESTRICT  = icregexeqsel,
    JOIN      = icregexeqjoinsel
);

CREATE OPERATOR ~* (
    PROCEDURE = texticregexeq,
    LEFTARG   = citext,
    RIGHTARG  = text,
    NEGATOR   = !~*,
    RESTRICT  = icregexeqsel,
    JOIN      = icregexeqjoinsel
);

CREATE OPERATOR !~ (
    PROCEDURE = texticregexne,
    LEFTARG   = citext,
    RIGHTARG  = text,
    NEGATOR   = ~,
    RESTRICT  = icregexnesel,
    JOIN      = icregexnejoinsel
);

CREATE OPERATOR !~* (
    PROCEDURE = texticregexne,
    LEFTARG   = citext,
    RIGHTARG  = text,
    NEGATOR   = ~*,
    RESTRICT  = icregexnesel,
    JOIN      = icregexnejoinsel
);

CREATE OPERATOR ~~ (
    PROCEDURE = texticlike,
    LEFTARG   = citext,
    RIGHTARG  = text,
    NEGATOR   = !~~,
    RESTRICT  = iclikesel,
    JOIN      = iclikejoinsel
);

CREATE OPERATOR ~~* (
    PROCEDURE = texticlike,
    LEFTARG   = citext,
    RIGHTARG  = text,
    NEGATOR   = !~~*,
    RESTRICT  = iclikesel,
    JOIN      = iclikejoinsel
);

CREATE OPERATOR !~~ (
    PROCEDURE = texticnlike,
    LEFTARG   = citext,
    RIGHTARG  = text,
    NEGATOR   = ~~,
    RESTRICT  = icnlikesel,
    JOIN      = icnlikejoinsel
);

CREATE OPERATOR !~~* (
    PROCEDURE = texticnlike,
    LEFTARG   = citext,
    RIGHTARG  = text,
    NEGATOR   = ~~*,
    RESTRICT  = icnlikesel,
    JOIN      = icnlikejoinsel
);

--
-- Matching citext in string comparison functions.
-- XXX TODO Ideally these would be implemented in C.
--

CREATE OR REPLACE FUNCTION regexp_matches( citext, citext ) RETURNS SETOF TEXT[] AS $$
    SELECT pg_catalog.regexp_matches( $1::pg_catalog.text, $2::pg_catalog.text, 'i' );
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION regexp_matches( citext, citext, text ) RETURNS SETOF TEXT[] AS $$
    SELECT pg_catalog.regexp_matches( $1::pg_catalog.text, $2::pg_catalog.text, CASE WHEN pg_catalog.strpos($3, 'c') = 0 THEN  $3 || 'i' ELSE $3 END );
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION regexp_replace( citext, citext, text ) returns TEXT AS $$
    SELECT pg_catalog.regexp_replace( $1::pg_catalog.text, $2::pg_catalog.text, $3, 'i');
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION regexp_replace( citext, citext, text, text ) returns TEXT AS $$
    SELECT pg_catalog.regexp_replace( $1::pg_catalog.text, $2::pg_catalog.text, $3, CASE WHEN pg_catalog.strpos($4, 'c') = 0 THEN  $4 || 'i' ELSE $4 END);
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION regexp_split_to_array( citext, citext ) RETURNS TEXT[] AS $$
    SELECT pg_catalog.regexp_split_to_array( $1::pg_catalog.text, $2::pg_catalog.text, 'i' );
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION regexp_split_to_array( citext, citext, text ) RETURNS TEXT[] AS $$
    SELECT pg_catalog.regexp_split_to_array( $1::pg_catalog.text, $2::pg_catalog.text, CASE WHEN pg_catalog.strpos($3, 'c') = 0 THEN  $3 || 'i' ELSE $3 END );
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION regexp_split_to_table( citext, citext ) RETURNS SETOF TEXT AS $$
    SELECT pg_catalog.regexp_split_to_table( $1::pg_catalog.text, $2::pg_catalog.text, 'i' );
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION regexp_split_to_table( citext, citext, text ) RETURNS SETOF TEXT AS $$
    SELECT pg_catalog.regexp_split_to_table( $1::pg_catalog.text, $2::pg_catalog.text, CASE WHEN pg_catalog.strpos($3, 'c') = 0 THEN  $3 || 'i' ELSE $3 END );
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION strpos( citext, citext ) RETURNS INT AS $$
    SELECT pg_catalog.strpos( pg_catalog.lower( $1::pg_catalog.text ), pg_catalog.lower( $2::pg_catalog.text ) );
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION replace( citext, citext, citext ) RETURNS TEXT AS $$
    SELECT pg_catalog.regexp_replace( $1::pg_catalog.text, pg_catalog.regexp_replace($2::pg_catalog.text, '([^a-zA-Z_0-9])', E'\\\\\\1', 'g'), $3::pg_catalog.text, 'gi' );
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION split_part( citext, citext, int ) RETURNS TEXT AS $$
    SELECT (pg_catalog.regexp_split_to_array( $1::pg_catalog.text, pg_catalog.regexp_replace($2::pg_catalog.text, '([^a-zA-Z_0-9])', E'\\\\\\1', 'g'), 'i'))[$3];
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION translate( citext, citext, text ) RETURNS TEXT AS $$
    SELECT pg_catalog.translate( pg_catalog.translate( $1::pg_catalog.text, pg_catalog.lower($2::pg_catalog.text), $3), pg_catalog.upper($2::pg_catalog.text), $3);
$$ LANGUAGE SQL IMMUTABLE STRICT;
