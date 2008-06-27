\set ECHO none
\encoding UTF-8

/*
 *  ===============================
 *  Tests for the CITEXT data type.
 *  ===============================
 */

-- Format the output for nice TAP.
\pset format unaligned
\pset tuples_only true
\pset pager

-- Just ignore errors from the next few commands.
SET client_min_messages = fatal;

-- Create plpgsql if it's not already there.
CREATE LANGUAGE plpgsql;

-- Load the TAP functions and the data type.
BEGIN;
\i pgtap.sql
\i citext.sql

-- Keep things quiet.
SET client_min_messages = warning;

-- Revert all changes on failure.
\set ON_ERROR_ROLBACK true
\set ON_ERROR_STOP true

-- Plan the tests.
SELECT plan(372);
--SELECT * FROM no_plan();

-- Output a diagnostic message if the collation is not en_US.UTF-8.
SELECT diag(
    E'These tests expect LC_COLLATE to be en_US.UTF-8,\n'
  || 'but yours is set to ' || setting || E'.\n'
  || 'As a result, some tests may fail. YMMV.'
)
  FROM pg_settings
 WHERE name = 'lc_collate'
   AND setting <> 'en_US.UTF-8';

/*
 *  ==========================================
 *  Test the operators and indexing functions.
 *  ==========================================
 */

-- Test = and <>.
SELECT is(   'a'::citext,  'a'::citext,  'citext "a" should  eq   citext "a"' );
SELECT is(   'a'::citext,  'A'::citext,  'citext "a" should  eq   citext "A"' );
SELECT isnt( 'a'::citext,  'b'::citext,  'citext "a" should  ne   citext "b"' );
SELECT is(   'À'::citext,  'À'::citext,  'citext "À" should  eq   citext "À"' );
SELECT is(   'À'::text,    'À'::text,    'text   "À" should  ne   text   "À"' );
SELECT is(   'À'::citext,  'à'::citext,  'citext "À" should  eq   citext "à"' );
SELECT isnt( 'À'::text,    'à'::text,    'text   "À" should  ne   text   "à"' );
SELECT isnt( 'À'::citext,  'B'::citext,  'citext "À" should  ne   text   "B"' );

-- Test > and >=
SELECT ok(   'B'::text   <  'a'::text,   'text   "B" should be lt text   "a"' );
SELECT ok(   'B'::text   <= 'a'::text,   'text   "B" should be le text   "a"' );
SELECT ok(   'B'::citext >  'a'::citext, 'citext "B" should be gt citext "a"' );
SELECT ok(   'B'::citext >= 'a'::citext, 'citext "B" should be ge citext "a"' );
SELECT ok(   'Á'::text   <  'à'::text,   'text   "Á" should be lt text   "à"' );
SELECT ok(   'Á'::text   <= 'à'::text,   'text   "Á" should be le text   "à"' );
SELECT ok(   'Á'::citext >  'à'::citext, 'citext "Á" should be gt citext "à"' );
SELECT ok(   'Á'::citext >= 'à'::citext, 'citext "Á" should be ge citext "à"' );

-- Test < and <=
SELECT ok(   'a'::text   >  'B'::text,   'text   "a" should be gt text   "B"' );
SELECT ok(   'a'::text   >= 'B'::text,   'text   "a" should be ge text   "B"' );
SELECT ok(   'a'::citext <  'B'::citext, 'citext "a" should be lt citext "B"' );
SELECT ok(   'a'::citext <= 'B'::citext, 'citext "B" should be le citext "B"' );
SELECT ok(   'à'::text   >  'Á'::text,   'text   "à" should be gt text   "Á"' );
SELECT ok(   'à'::text   >= 'Á'::text,   'text   "à" should be ge text   "Á"' );
SELECT ok(   'à'::citext <  'Á'::citext, 'citext "à" should be lt citext "Á"' );
SELECT ok(   'à'::citext <= 'Á'::citext, 'citext "à" should be le citext "Á"' );

-- Test = and <> to text.
SELECT is(   'a'::citext, 'a', 'citext "a" should eq text "a"' );
SELECT is(   'A'::citext, 'a', 'citext "A" should eq text "a"' );
SELECT is(   'À'::citext, 'À', 'citext "À" should eq text "À"' );
SELECT is(   'À'::citext, 'à', 'citext "À" should eq text "à"' );
SELECT isnt( 'a'::citext, 'b', 'citext "a" should ne text "b"' );
SELECT isnt( 'À'::citext, 'B', 'citext "À" should ne text "B"' );

-- Explicitly use the operators, ust to be safe.
SELECT ok( 'a'::citext =  'a', 'citext "a" should = text "a"' );
SELECT ok( 'A'::citext =  'a', 'citext "A" should = text "a"' );
SELECT ok( 'À'::citext =  'À', 'citext "À" should = text "À"' );
SELECT ok( 'À'::citext =  'à', 'citext "À" should = text "à"' );
SELECT ok( 'a'::citext <> 'b', 'citext "a" should <> text "b"' );
SELECT ok( 'À'::citext <> 'B', 'citext "À" should <> text "B"' );

-- Flip text and citext.
SELECT is(   'a', 'a'::citext, 'text "a" should eq citext "a"' );
SELECT is(   'A', 'a'::citext, 'text "A" should eq citext "a"' );
SELECT is(   'À', 'À'::citext, 'text "À" should eq citext "À"' );
SELECT is(   'À', 'à'::citext, 'text "À" should eq citext "à"' );
SELECT isnt( 'a', 'b'::citext, 'text "a" should ne citext "b"' );
SELECT isnt( 'À', 'B'::citext, 'text "À" should ne citext "B"' );

-- Reverse the lhs and rhs.
SELECT is(   'a', 'a'::citext, 'text "a" should eq citext "a"' );
SELECT is(   'a', 'A'::citext, 'text "a" should eq citext "a"' );
SELECT is(   'À', 'À'::citext, 'text "À" should eq citext "À"' );
SELECT is(   'à', 'À'::citext, 'text "à" should eq citext "À"' );
SELECT isnt( 'b', 'a'::citext, 'text "b" should ne citext "a"' );
SELECT isnt( 'B', 'À'::citext, 'text "B" should ne citext "À"' );

-- Test > and >= to text
SELECT ok(   'B'::citext >  'a', 'citext "B" should be gt text "a"' );
SELECT ok(   'B'::citext >= 'a', 'citext "B" should be ge text "a"' );
SELECT ok(   'Á'::citext >  'à', 'citext "Á" should be gt text "à"' );
SELECT ok(   'Á'::citext >= 'à', 'citext "Á" should be ge text "à"' );

-- Flip text and citext.
SELECT ok(   'B' >  'a'::citext, 'text "B" should be gt citext "a"' );
SELECT ok(   'B' >= 'a'::citext, 'text "B" should be ge citext "a"' );
SELECT ok(   'Á' >  'à'::citext, 'text "Á" should be gt citext "à"' );
SELECT ok(   'Á' >= 'à'::citext, 'text "Á" should be ge citext "à"' );

-- Test < and <= to text
SELECT ok(   'a'::citext <  'B', 'citext "a" should be lt text "B"' );
SELECT ok(   'a'::citext <= 'B', 'citext "B" should be le text "B"' );
SELECT ok(   'à'::citext <  'Á', 'citext "à" should be lt text "Á"' );
SELECT ok(   'à'::citext <= 'Á', 'citext "à" should be le text "Á"' );

-- Flip text and citext.
SELECT ok(   'a' <  'B'::citext, 'text "a" should be lt citext "B"' );
SELECT ok(   'a' <= 'B'::citext, 'text "B" should be le citext "B"' );
SELECT ok(   'à' <  'Á'::citext, 'text "à" should be lt citext "Á"' );
SELECT ok(   'à' <= 'Á'::citext, 'text "à" should be le citext "Á"' );

-- Test combining characters making up canonically equivalent strings.
SELECT isnt( 'Ä'::text,   'Ä'::text,   'Combining text characters are not equivalent' );
SELECT isnt( 'Ä'::citext, 'Ä'::citext, 'Combining citext characters are not equivalent' );

-- Test the Turkish dotted I. The lowercase is a single byte while the
-- uppercase is multibyte. This is why the comparison code can't be optimized
-- to compare string lenghts.
SELECT ok( 'i'::citext = 'İ'::citext, 'Turkish dotted "i" should be the same' );

-- Test implicit casting. citext casts to text, but not vice-versa.
SELECT ok( 'a'::citext =  'a'::text, 'citext "a" should =  text "a"' );
SELECT ok( 'A'::citext <> 'a'::text, 'citext "A" should <> text "a"' );
SELECT ok( 'À'::citext =  'À'::text, 'citext "À" should =  text "À"' );
SELECT ok( 'À'::citext <> 'à'::text, 'citext "À" should <  text "à"' );
SELECT ok( 'a'::citext <> 'b'::text, 'citext "a" should <> text "b"' );
SELECT ok( 'À'::citext <> 'B'::text, 'citext "À" should <> text "B"' );

-- Reverse the casts.
SELECT ok( 'a'::text =  'a'::citext, 'text "a" should =  citext "a"' );
SELECT ok( 'A'::text <> 'a'::citext, 'text "A" should <> citext "a"' );
SELECT ok( 'À'::text =  'À'::citext, 'text "À" should =  citext "À"' );
SELECT ok( 'À'::text <> 'à'::citext, 'text "À" should <  citext "à"' );
SELECT ok( 'a'::text <> 'b'::citext, 'text "a" should <> citext "b"' );
SELECT ok( 'À'::text <> 'B'::citext, 'text "À" should <> citext "B"' );

-- Some longer comparisons.
SELECT is(
    'aardvark'::citext,
    'aardvark'::citext,
    'citext "aardvark" should  eq   citext "aardvark"'
);

SELECT is(
    'AARDVARK'::citext,
    'AARDVARK'::citext,
    'citext "AARDVARK" should  eq   citext "AARDVARK"'
);
SELECT is(
    'aardvark'::citext,
    'AARDVARK'::citext,
    'citext "aardvark" should  eq   citext "AARDVARK"'
);

SELECT is(
    'Ask Bjørn Hansen'::citext,
    'Ask Bjørn Hansen'::citext,
    '"Ask Bjørn Hansen" should eq "Ask Bjørn Hansen"'
);

SELECT is(
    'Ask Bjørn Hansen'::citext,
    'ASK BJØRN HANSEN'::citext,
    '"Ask Bjørn Hansen" should eq "ASK BJØRN HANSEN"'
);

SELECT is(
    'ask bjørn hansen'::citext,
    'ASK BJØRN HANSEN'::citext,
    '"ask bjørn hansen" should eq "ASK BJØRN HANSEN"'
);

SELECT isnt(
    'Ask Bjørn Hansen'::citext,
    'Ask Bjorn Hansen'::citext,
    '"Ask Bjørn Hansen" should ne "Ask Bjorn Hansen"'
);

SELECT isnt(
    'Ask Bjørn Hansen'::citext,
    'ASK BJORN HANSEN'::citext,
    '"Ask Bjørn Hansen" should ne "ASK BJORN HANSEN"'
);

SELECT isnt(
    'ask bjørn hansen'::citext,
    'ASK BJORN HANSEN'::citext,
    '"ask bjørn hansen" should ne "ASK BJORN HANSEN"'
);

-- Check the citext_cmp() function explicitly.
SELECT is(
    citext_cmp ( 'aardvark'::citext, 'aardvark'::citext ),
    0,
    'citext_cmp( citext "aardvark", citext "aardvark") should be 0'
);

SELECT is(
    citext_cmp ( 'aardvark'::citext, 'AARDVARK'::citext ),
    0,
    'citext_cmp( citext "aardvark", citext "AARDVARK") should be 0'
);

SELECT is(
    citext_cmp ( 'AARDVARK'::citext, 'AARDVARK'::citext ),
    0,
    'citext_cmp( citext "AARDVARK", citext "AARDVARK") should be 0'
);

SELECT is(
    citext_cmp( 'Ask Bjørn Hansen', 'Ask Bjørn Hansen' ),
    0,
    'citext_cmp( "Ask Bjørn Hansen", "Ask Bjørn Hansen") should be 0'
);

SELECT is(
    citext_cmp( 'Ask Bjørn Hansen', 'ask bjørn hansen' ),
    0,
    'citext_cmp( "Ask Bjørn Hansen", "ask bjørn hansen") should be 0'
);

SELECT is(
    citext_cmp( 'Ask Bjørn Hansen', 'ASK BJØRN HANSEN' ),
    0,
    'citext_cmp( "Ask Bjørn Hansen", "ASK BJØRN HANSEN") should be 0'
);

SELECT is(
    citext_cmp( 'Ask Bjørn Hansen', 'Ask Bjorn Hansen' ),
    137,
    'citext_cmp( "Ask Bjørn Hansen", "Ask Bjorn Hansen") should be -1'
);

SELECT is(
    citext_cmp( 'Ask Bjorn Hansen', 'Ask Bjørn Hansen' ),
    -137,
    'citext_cmp( "Ask Bjorn Hansen", "Ask Bjørn Hansen") should be 1'
);

/*
 *  ============================
 *  Do some tests using a table.
 *  ============================
 */

-- Now try writing to a table.
CREATE TEMP TABLE try (
    name citext PRIMARY KEY
);

INSERT INTO try (name)
VALUES ('a'), ('ab'), ('â'), ('aba'), ('b'), ('ba'), ('bab'), ('AZ');


SELECT ok( 'a' = name, 'We should be able to select the value' )
  FROM try
 WHERE name = 'a';
SELECT ok( 'a' = name, 'We should be able to select the value in uppercase' )
  FROM try
 WHERE name = 'A';

-- Try an accented character.
SELECT ok( 'â' = name, 'We should be able to select an accented value' )
  FROM try
 WHERE name = 'â';
SELECT ok( 'â' = name, 'We should be able to select an accented value in uppercase' )
  FROM try
 WHERE name = 'Â';

-- Make sure we can an exception trying to insert an invalid foreign key.
SELECT throws_ok(
    'INSERT INTO try (name) VALUES (''a'')',
    '23505',
    'We should get an error inserting a lowercase letter'
);

SELECT throws_ok(
    'INSERT INTO try (name) VALUES (''A'')',
    '23505',
    'We should get an error inserting an uppercase letter'
);

SELECT throws_ok(
    'INSERT INTO try (name) VALUES (''â'')',
    '23505',
    'We should get an error inserting a lowercase accented letter'
);

SELECT throws_ok(
    'INSERT INTO try (name) VALUES (''Â'')',
    '23505',
    'We should get an error inserting an uppercase accented letter'
);

-- Make sure that citext_smaller() and citext_lager() work properly.
SELECT is( citext_smaller( 'aa'::citext, 'ab'::citext ), 'aa', '"aa" should be smaller' );
SELECT is( citext_smaller( 'Â'::citext, 'ç'::citext ), 'Â', '"Â" should be smaller' );
SELECT is( citext_smaller( 'AAAA'::citext, 'bbbb'::citext ), 'AAAA', '"AAAA" should be smaller' );
SELECT is( citext_smaller( 'aardvark'::citext, 'Aaba'::citext ), 'Aaba', '"Aaba" should be smaller' );
SELECT is( citext_smaller( 'aardvark'::citext, 'AARDVARK'::citext ), 'AARDVARK', '"AARDVARK" should be smaller' );

SELECT is( citext_larger( 'aa'::citext, 'ab'::citext ), 'ab', '"ab" should be larger' );
SELECT is( citext_larger( 'Â'::citext, 'ç'::citext ), 'ç', '"ç" should be larger' );
SELECT is( citext_larger( 'AAAA'::citext, 'bbbb'::citext ), 'bbbb', '"bbbb" should be larger' );
SELECT is( citext_larger( 'aardvark'::citext, 'Aaba'::citext ), 'aardvark', '"aardvark" should be smaller' );

/*
 *  ===========================================
 *  Test aggregate functions and sort ordering.
 *  ===========================================
 */

-- Create another table with some records with which to do some testing.
CREATE TEMP TABLE srt (
    name CITEXT
);

INSERT INTO srt (name)
VALUES ('aardvark'),
       ('AAA'),
       ('aba'),
       ('ABC'),
       ('abc'::citext),
       ('ç'::text),
       ('â');

-- Check the min() and max() aggregates.
SELECT is( MIN(name)::text, 'AAA'::text, 'The min::text value should be "AAA"' )
  FROM srt;
SELECT is( MAX(name)::text, 'ç'::text, 'The max::text value should be "ç"' )
  FROM srt;
SELECT is( MIN(name), 'AAA', 'The min value should be "AAA"' )
  FROM srt;
SELECT is( MAX(name), 'ç', 'The max value should be "ç"' )
  FROM srt;

-- Now check the sort order of things.
SELECT is(
    ARRAY( SELECT name FROM srt ORDER BY name )::text,
    ARRAY['AAA', 'aardvark', 'aba', 'ABC', 'abc', 'â', 'ç']::text,
    'The words should be case-insensitively sorted'
);

SELECT is(
    ARRAY( SELECT name FROM srt ORDER BY name ),
    ARRAY['AAA'::citext, 'aardvark'::citext, 'aba'::citext, 'ABC'::citext, 'abc'::citext, 'â'::citext, 'ç'],
    'The words should be case-insensitively sorted (citext array)'
);

SELECT is(
    ARRAY( SELECT UPPER(name) FROM srt ORDER BY name )::text,
    ARRAY['AAA', 'AARDVARK', 'ABA', 'ABC', 'ABC', 'Â', 'Ç']::text,
    'The UPPER(words) should be case-insensitively sorted'
);

SELECT is(
    ARRAY( SELECT UPPER(name) FROM srt ORDER BY name )::text,
    ARRAY['AAA'::citext, 'AARDVARK'::citext, 'ABA'::citext, 'ABC'::citext, 'ABC'::citext, 'Â'::citext, 'Ç']::text,
    'The UPPER(words) should be case-insensitively sorted (citext array)');

SELECT is(
    ARRAY( SELECT UPPER(name) FROM srt ORDER BY name ),
    ARRAY['aaa'::citext, 'aardvark'::citext, 'aba'::citext, 'abc'::citext, 'abc'::citext, 'â'::citext, 'ç'],
    'The UPPER(words) should case-insensitively compare'
);

SELECT is(
    ARRAY( SELECT LOWER(name) FROM srt ORDER BY name )::text,
    ARRAY['aaa', 'aardvark', 'aba', 'abc', 'abc', 'â', 'ç']::text,
    'The UPPER(words) should be case-insensitively sorted'
);

SELECT is(
    ARRAY( SELECT LOWER(name) FROM srt ORDER BY name )::text,
    ARRAY['aaa'::citext, 'aardvark'::citext, 'aba'::citext, 'abc'::citext, 'abc'::citext, 'â'::citext, 'ç']::text,
    'The UPPER(words) should be case-insensitively sorted (citext array)'
);

SELECT is(
    ARRAY( SELECT LOWER(name) FROM srt ORDER BY name ),
    ARRAY['AAA'::citext, 'AARDVARK'::citext, 'ABA'::citext, 'ABC'::citext, 'ABC'::citext, 'Â'::citext, 'Ç'],
    'The LOWER(words) should case-insensitively compare'
);

/*
 *  ===================================
 *  Test implicit and assignment casts.
 *  ===================================
 */

-- Check explicit comparison to text.
SELECT is( LOWER(name), 'aaa', 'LOWER("AAA") should return "aaa"' )
  FROM srt
 WHERE name = 'AAA'::text;

SELECT is( UPPER(name), 'Â', 'UPPER("â") should return "Â"' )
  FROM srt
 WHERE name = 'â'::text;

-- Check explicit comparison to citext.
SELECT is( LOWER(name), 'aaa', 'LOWER("AAA") should return "aaa"' )
  FROM srt
 WHERE name = 'AAA'::citext;

SELECT is( UPPER(name), 'Â', 'UPPER("â") should return "Â"' )
  FROM srt
 WHERE name = 'â'::citext;

-- Check implicit assignment casts.
SELECT is( LOWER(name), 'aaa', 'LOWER("AAA") should return "aaa"' )
  FROM srt
 WHERE name = 'AAA';

SELECT is( UPPER(name), 'Â', 'UPPER("â") should return "Â"' )
  FROM srt
 WHERE name = 'â';

/*
 *  =====================
 *  9.7. Pattern Matching
 *  =====================
 */

-- Check LIKE, ILIKE, NOT LIKE, and NOT ILIKE.
SELECT is( name, 'ç', 'LIKE should work properly' )
  FROM srt
 WHERE name LIKE 'ç%';

SELECT is( name, 'ç', 'LIKE should work case-insensitively' )
  FROM srt
 WHERE name LIKE 'Ç%';

SELECT is( name, 'ç', 'ILIKE should work properly' )
  FROM srt
 WHERE name ILIKE 'Ç%';

SELECT is(
    ARRAY( SELECT name FROM srt WHERE name NOT LIKE '%a%' ORDER BY name ),
    ARRAY['â'::citext, 'ç'::citext ],
    'NOT LIKE should work properly'
);

SELECT is(
    ARRAY( SELECT name FROM srt WHERE name NOT LIKE '%A%' ORDER BY name ),
    ARRAY['â'::citext, 'ç'::citext ],
    'NOT LIKE should work properly and case-insensitively'
);

SELECT is(
    ARRAY( SELECT name FROM srt WHERE name NOT LIKE '%a%' ORDER BY name ),
    ARRAY['â'::citext, 'ç'::citext ],
    'NOT ILIKE should work properly'
);

-- Check ~~, ~~*, !~~, and !~~*
SELECT is( name, 'ç', '~~ should work properly' )
  FROM srt
 WHERE name ~~ 'ç%';

SELECT is( name, 'ç', '~~ should work case-insensitively' )
  FROM srt
 WHERE name ~~ 'Ç%';

SELECT is( name, 'ç', '~~* should work properly' )
  FROM srt
 WHERE name ~~* 'Ç%';

SELECT is(
    ARRAY( SELECT name FROM srt WHERE name !~~ '%a%' ORDER BY name ),
    ARRAY['â'::citext, 'ç'::citext ],
    '!~~ should work properly'
);

SELECT is(
    ARRAY( SELECT name FROM srt WHERE name !~~ '%A%' ORDER BY name ),
    ARRAY['â'::citext, 'ç'::citext ],
    '!~~ should work properly and case-insensitively'
);

SELECT is(
    ARRAY( SELECT name FROM srt WHERE name !~~* '%A%' ORDER BY name ),
    ARRAY['â'::citext, 'ç'::citext ],
    '!~~* should work properly and case-insensitively'
);

-- Check ~, ~*, !~, and !~*
SELECT is( name, 'ç', '~ should work properly' )
  FROM srt
 WHERE name ~ 'ç+';

SELECT is( name, 'ç', '~ should work case-insensitively' )
  FROM srt
 WHERE name ~ 'Ç+';

SELECT is( name, 'ç', '~* should work properly' )
  FROM srt
 WHERE name ~* 'Ç+';

SELECT is(
    ARRAY( SELECT name FROM srt WHERE name !~ 'a+' ORDER BY name ),
    ARRAY['â'::citext, 'ç'::citext ],
    '!~ should work properly'
);

SELECT is(
    ARRAY( SELECT name FROM srt WHERE name !~ 'A+' ORDER BY name ),
    ARRAY['â'::citext, 'ç'::citext ],
    '!~ should work properly and case-insensitively'
);

SELECT is(
    ARRAY( SELECT name FROM srt WHERE name !~* 'A+' ORDER BY name ),
    ARRAY['â'::citext, 'ç'::citext ],
    '!~* should work properly and case-insensitively'
);

-- Check cast to to varchar and text for LIKE and ILIKE.
SELECT is( name::varchar, 'ç', 'varchar LIKE should work properly' )
  FROM srt
 WHERE name LIKE 'ç%';

SELECT is( name::varchar, 'ç', 'varchar ILIKE should work properly' )
  FROM srt
 WHERE name ILIKE 'Ç%';

SELECT is(
    ARRAY( SELECT name::varchar FROM srt WHERE name NOT LIKE '%a%' ORDER BY name ),
    ARRAY['â'::varchar, 'ç'::varchar ],
    'varchar NOT LIKE should work properly'
);

SELECT is( name::text, 'ç', 'text LIKE should work properly' )
  FROM srt
 WHERE name LIKE 'ç%';

SELECT is( name::text, 'ç', 'text ILIKE should work properly' )
  FROM srt
 WHERE name ILIKE 'Ç%';

SELECT is(
    ARRAY( SELECT name::text FROM srt WHERE name NOT LIKE '%a%' ORDER BY name ),
    ARRAY['â'::text, 'ç'::text ],
    'text NOT LIKE should work properly'
);

-- Check LIKE and ILIKE text, varchar, and name.
SELECT is( name, 'ç', 'text LIKE should work properly' )
  FROM srt
 WHERE name LIKE 'ç%'::text;

SELECT is( name, 'ç', 'text ILIKE should work properly' )
  FROM srt
 WHERE name ILIKE 'Ç%'::text;

SELECT is(
    ARRAY( SELECT name FROM srt WHERE name NOT LIKE '%a%'::text ORDER BY name ),
    ARRAY['â'::citext, 'ç'::citext ],
    'text NOT LIKE should work properly'
);

SELECT is( name, 'ç', 'varchar LIKE should work properly' )
  FROM srt
 WHERE name LIKE 'ç%'::varchar;

SELECT is( name, 'ç', 'varchar ILIKE should work properly' )
  FROM srt
 WHERE name ILIKE 'Ç%'::varchar;

SELECT is(
    ARRAY( SELECT name FROM srt WHERE name NOT LIKE '%a%'::varchar ORDER BY name ),
    ARRAY['â'::citext, 'ç'::citext ],
    'varchar NOT LIKE should work properly'
);

SELECT is( name, 'ç', 'name LIKE should work properly' )
  FROM srt
 WHERE name LIKE 'ç%'::name;

SELECT is( name, 'ç', 'name ILIKE should work properly' )
  FROM srt
 WHERE name ILIKE 'Ç%'::name;

SELECT is(
    ARRAY( SELECT name FROM srt WHERE name NOT LIKE '%a%'::name ORDER BY name ),
    ARRAY['â'::citext, 'ç'::citext ],
    'name NOT LIKE should work properly'
);

SELECT is( name, 'ç', 'bpchar LIKE should work properly' )
  FROM srt
 WHERE name LIKE 'ç%'::bpchar;

SELECT is( name, 'ç', 'bpchar ILIKE should work properly' )
  FROM srt
 WHERE name ILIKE 'Ç%'::bpchar;

SELECT is(
    ARRAY( SELECT name FROM srt WHERE name NOT LIKE '%a%'::bpchar ORDER BY name ),
    ARRAY['â'::citext, 'ç'::citext ],
    'bpchar NOT LIKE should work properly'
);

SELECT is( name, 'ç', 'char LIKE should work properly' )
  FROM srt
 WHERE name LIKE 'ç'::char;

SELECT is( name, 'ç', 'char ILIKE should work properly' )
  FROM srt
 WHERE name ILIKE 'Ç'::char;

SELECT is(
    ARRAY( SELECT name FROM srt WHERE name NOT LIKE 'a'::char ORDER BY name ),
    ARRAY['AAA'::citext, 'aardvark'::citext, 'aba'::citext, 'ABC'::citext, 'abc'::citext, 'â'::citext, 'ç'::citext],
    'char NOT LIKE should work properly'
);

--- Check SIMILAR TO.
SELECT is( name, 'ç', 'SIMILAR TO should work properly' )
  FROM srt
 WHERE name SIMILAR TO '%ç.*';

/*
 *  =============================================
 *  Table 9-5. SQL String Functions and Operators
 *  =============================================
 */

-- Test concatenation.
SELECT is(
    'D'::citext || 'avid'::citext,
    'David'::citext,
    'citext || citext should work'
);

SELECT is(
    'Value: '::citext || 42,
    'Value: 42',
    'citext || int should work'
);

SELECT is(
     42 || ': value'::citext,
    '42: value',
    'citext || int should work'
);

-- Check bit length.
SELECT is( bit_length('jose'::citext), 32, 'bit_length(citext) should work' );

SELECT is( bit_length( name ), bit_length(name::text), 'bit_length("' || name || '") should be correct' )
  FROM srt;

-- Check text length.
SELECT is( textlen( name ), textlen(name::text), 'textlen("' || name || '") should be correct' )
  FROM srt;

-- Check character length.
SELECT is( char_length( name ), char_length(name::text), 'char_length("' || name || '") should be correct' )
  FROM srt;

SELECT is( character_length( name ), character_length(name::text), 'character_length("' || name || '") should be correct' )
  FROM srt;

-- Check lower.
SELECT is( LOWER( name )::text, LOWER(name::text), 'LOWER("' || name || '") should be correct' )
  FROM srt;

-- Check octet length.
SELECT is( octet_length('jose'::citext), 4, 'octet_length(citext) should work' );

SELECT is( octet_length( name ), octet_length(name::text), 'octet_length("' || name || '") should be correct' )
  FROM srt;

-- Check overlay().
SELECT is(
    overlay( name placing 'hom' from 2 for 4),
    overlay( name::text placing 'hom' from 2 for 4),
    'overlay() should work'
) FROM srt;

-- Check position().
SELECT is(
    position( 'a' IN name ),
    position( 'a' IN name::text ),
    'position() should work'
) FROM srt;

-- Test substr() and substring().
SELECT is(
    substr('alphabet'::citext, 3),
    'phabet',
    'subtr(citext, int) should work'
);

SELECT is(
    substr('alphabet'::citext, 3),
    'phabet',
    'subtr(citext, int) should work'
);

SELECT is(
    substring('alphabet'::citext, 3),
    'phabet',
    'subtr(citext, int) should work'
);

SELECT is(
    substring('alphabet'::citext, 3, 2),
    'ph',
    'subtr(citext, int, int) should work'
);

SELECT is(
    substring('Thomas'::citext from 2 for 3),
    'hom',
    'subtr(citext from int for int) should work'
);

SELECT is(
    substring('Thomas'::citext from 2),
    'homas',
    'subtr(citext from int) should work'
);

SELECT is(
    substring('Thomas'::citext from '...$'),
    'mas',
    'subtr(citext from regex) should work'
);

SELECT is(
    substring('Thomas'::citext from '%#"o_a#"_' for '#'),
    'oma',
    'subtr(citext from regex for escape) should work'
);

-- Check trim.
SELECT is(
    trim('    trim    '::citext),
    'trim',
    'trim(citext) should work'
);

SELECT is(
    trim('xxxxxtrimxxxx'::citext, 'x'::citext),
    'trim',
    'trim(citext, citext) should work'
);

SELECT is(
    trim('xxxxxxtrimxxxx'::text, 'x'::citext),
    'trim',
    'trim(text, citext) should work'
);

SELECT is(
    trim('xxxxxtrimxxxx'::text, 'x'::citext),
    'trim',
    'trim(citext, text) should work'
);

-- Check upper.
SELECT is( UPPER( name )::text, UPPER(name::text), 'UPPER("' || name || '") should be correct' )
  FROM srt;

/*
 *  =================================
 *  Table 9-6. Other String Functions
 *  =================================
 */

-- Check ascii().
SELECT is(
    ascii(name),
    ascii( name::text ),
    'ascii(' || name || ') should work properly'
) FROM srt;

-- Check btrim.
SELECT is(
    btrim('    trim'::citext),
    'trim',
    'btrim(citext) should work'
);

SELECT is(
    btrim('xyxtrimyyx'::citext, 'xy'::citext),
    'trim',
    'btrim(citext, citext) should work'
);

SELECT is(
    btrim('xyxtrimyyx'::text, 'xy'::citext),
    'trim',
    'btrim(text, citext) should work'
);

SELECT is(
    btrim('xyxtrimyyx'::citext, 'xy'::text),
    'trim',
    'btrim(citext, text) should work'
);

-- chr() takes an int and returns text.
-- convert() and convert_from take bytea and return text.

-- Check conert_to().
SELECT is(
    convert_to( name, 'ISO-8859-1' ),
    convert_to( name::text, 'ISO-8859-1' ),
    'convert_to() should work the same as for text'
) FROM srt;

-- Check decode()
SELECT is(
    decode('MTIzAAE='::citext, 'base64'),
    decode('MTIzAAE='::text, 'base64'),
    'decode() should work the same as for text'
);

-- encode() takes bytea and returns text.

-- Check initcap().
SELECT is(
    initcap('hi THOMAS'::citext),
    initcap('hi THOMAS'::text),
    'initcap() whould work as for text'
);
SELECT is(
    initcap(name),
    initcap(name::text),
    'initcap() whould work as for text on all rows'
) FROM srt;

-- Check length.
SELECT is( length( name ), length(name::text), 'length("' || name || '") should be correct' )
  FROM srt;

-- Test lpad.
SELECT is(
    lpad('hi'::citext, 5),
    '   hi',
    'lpad(citext, int) should work'
);

SELECT is(
    lpad('hi'::citext, 5, 'xy'::citext),
    'xyxhi',
    'lpad(citext, int, citext) should work'
);

SELECT is(
    lpad('hi'::text, 5, 'xy'::citext),
    'xyxhi',
    'lpad(text, int, citext) should work'
);

SELECT is(
    lpad('hi'::citext, 5, 'xy'::text),
    'xyxhi',
    'lpad(citext, int, text) should work'
);

-- Check ltrim.
SELECT is(
    ltrim('    trim'::citext),
    'trim',
    'ltrim(citext) should work'
);

SELECT is(
    ltrim('zzzytrim'::citext, 'xyz'::citext),
    'trim',
    'ltrim(citext, citext) should work'
);

SELECT is(
    ltrim('zzzytrim'::text, 'xyz'::citext),
    'trim',
    'ltrim(text, citext) should work'
);

SELECT is(
    ltrim('zzzytrim'::citext, 'xyz'::text),
    'trim',
    'ltrim(citext, text) should work'
);

-- Check md5().
SELECT is(
    md5(name),
    md5(name::text),
    'md5() should work as for text'
) FROM srt;

-- pg_client_encoding() takes no args and returns a name.

-- Check quote_ident().
SELECT is(
    quote_ident(name),
    quote_ident(name::text),
    'quote_ident() should work as for text'
) FROM srt;

-- Check quote_literal().
SELECT is(
    quote_literal(name),
    quote_literal(name::text),
    'quote_literal() should work as for text'
) FROM srt;

-- Check regexp_matches().
SELECT is(
    regexp_matches('foobarbequebaz'::citext, '(bar)(beque)'),
    ARRAY[ 'bar', 'beque' ],
    'regexp_matches() should work'
);

SELECT is(
    regexp_matches('foobarbequebaz'::citext, '(BAR)(BEQUE)'),
    ARRAY[ 'bar', 'beque' ],
    'regexp_matches() should work case-insensitively'
);

-- Check regexp_replace('Thomas', '.[mN]a.', 'M')
SELECT is(
   regexp_replace('Thomas'::citext, '.[mN]a.', 'M'),
   'ThM',
   'regexp_replace() should work'
);

SELECT * FROM todo( 'XXX Case-insensitive support missing', 1);
SELECT is(
   regexp_replace('Thomas'::citext, '.[MN]A.', 'M'),
   'ThM',
   'regexp_replace() should work case-insensitively'
);

-- Check regexp_split_to_array().
SELECT is(
    regexp_split_to_array('hello world'::citext, E'\\s+'),
    ARRAY[ 'hello', 'world' ],
    'regexp_split_to_array() should work'
);

SELECT * FROM todo( 'XXX Case-insensitive support missing', 1);
SELECT is(
    regexp_split_to_array('helloTworld'::citext, 't'),
    ARRAY[ 'hello', 'world' ],
    'regexp_split_to_array() should work case-insensitively'
);

-- Check regexp_split_to_table('hello world', E'\\s+')
SELECT is(
    ARRAY( SELECT regexp_split_to_table('hello world'::citext, E'\\s+') ),
    ARRAY[ 'hello', 'world' ],
    'regexp_split_to_table() should work'
);

SELECT * FROM todo( 'XXX Case-insensitive support missing', 1);
SELECT is(
    ARRAY( SELECT regexp_split_to_table('helloTworld'::citext, 't') ),
    ARRAY[ 'hello', 'world' ],
    'regexp_split_to_table() should work case-insensitively'
);

-- Check repeat().
SELECT is(
    repeat('Pg'::citext, 4),
    'PgPgPgPg',
    'repeat(citext, int) should work'
);

-- Check replace().
SELECT is(
    replace('abcdefabcdef'::citext, 'cd', 'XX'),
    'abXXefabXXef',
    'replace() should work'
);

SELECT * FROM todo( 'XXX Case-insensitive support missing', 1);
SELECT is(
    replace('abcdefabcdef'::citext, 'CD', 'XX'),
    'abXXefabXXef',
    'replace() should work case-insensitvely'
);

-- Test rpad.
SELECT is(
    rpad('hi'::citext, 5),
    'hi   ',
    'rpad(citext, int) should work'
);

SELECT is(
    rpad('hi'::citext, 5, 'xy'::citext),
    'hixyx',
    'rpad(citext, int, citext) should work'
);

SELECT is(
    rpad('hi'::text, 5, 'xy'::citext),
    'hixyx',
    'rpad(text, int, citext) should work'
);

SELECT is(
    rpad('hi'::citext, 5, 'xy'::text),
    'hixyx',
    'rpad(citext, int, text) should work'
);

-- Check rtrim.
SELECT is(
    rtrim('trim    '::citext),
    'trim',
    'rtrim(citext) should work'
);

SELECT is(
    rtrim('trimxxxx'::citext, 'x'::citext),
    'trim',
    'rtrim(citext, citext) should work'
);

SELECT is(
    rtrim('trimxxxx'::text, 'x'::citext),
    'trim',
    'rtrim(text, citext) should work'
);

SELECT is(
    rtrim('trimxxxx'::text, 'x'::citext),
    'trim',
    'rtrim(citext, text) should work'
);

-- Check split_part().
SELECT is(
    split_part('abc~@~def~@~ghi'::citext, '~@~', 2),
    'def',
    'split_part() should work'
);

SELECT * FROM todo( 'XXX Case-insensitive support missing', 1);
SELECT is(
    split_part('abcTdefTghi'::citext, 't', 2),
    'def',
    'split_part() should work case-insensitively'
);

-- Check strpos().
SELECT is(
    strpos('high'::citext, 'ig'),
    2,
    'strpos(citext, text) should work'
);

SELECT is(
    strpos('high'::citext,'ig'::citext),
    2,
    'strpos(citext, citext) should work'
);

SELECT * FROM todo( 'XXX Case-insensitive support missing', 1);
SELECT is(
    strpos('high'::citext, 'IG'::citext),
    2,
    'strpos(citext, citext) should work case-insensitively'
);

-- to_ascii() does not support UTF-8.
-- to_hex() takes a numeric argument.
    

-- check substr().
SELECT is(
    substr('alphabet', 3, 2),
    'ph',
    'substr() should work'
);

-- Check translate().
SELECT is(
    translate('abcdefabcdef'::citext, 'cd', 'XX'),
    'abXXefabXXef',
    'translate() should work'
);

SELECT * FROM todo( 'XXX Case-insensitive support missing', 1);
SELECT is(
    translate('abcdefabcdef'::citext, 'CD', 'XX'),
    'abXXefabXXef',
    'translate() should work case-insensitvely'
);

/*
 *  ================================
 *  Table 9-20. Formatting Functions
 *  ================================
 */

-- Check to_date().
SELECT is(
    to_date('05 Dec 2000'::citext, 'DD Mon YYYY'::citext),
    to_date('05 Dec 2000', 'DD Mon YYYY'),
    'todate(citext, citext) should work'
);

SELECT is(
    to_date('05 Dec 2000'::citext, 'DD Mon YYYY'),
    to_date('05 Dec 2000', 'DD Mon YYYY'),
    'todate(citext, text) should work'
);

SELECT is(
    to_date('05 Dec 2000', 'DD Mon YYYY'::citext),
    to_date('05 Dec 2000', 'DD Mon YYYY'),
    'todate(text, citext) should work'
);

-- Check to_number().
SELECT is(
    to_number('12,454.8-'::citext, '99G999D9S'::citext),
    to_number('12,454.8-', '99G999D9S'),
    'to_number(citext, citext) should work'
);

SELECT is(
    to_number('12,454.8-'::citext, '99G999D9S'),
    to_number('12,454.8-', '99G999D9S'),
    'to_number(citext, text) should work'
);

SELECT is(
    to_number('12,454.8-', '99G999D9S'::citext),
    to_number('12,454.8-', '99G999D9S'),
    'to_number(text, citext) should work'
);

-- Check to_timestamp().
SELECT is(
    to_timestamp('05 Dec 2000'::citext, 'DD Mon YYYY'::citext),
    to_timestamp('05 Dec 2000', 'DD Mon YYYY'),
    'to_timestamp(citext, citext) should work'
);

SELECT is(
    to_timestamp('05 Dec 2000'::citext, 'DD Mon YYYY'),
    to_timestamp('05 Dec 2000', 'DD Mon YYYY'),
    'to_timestamp(citext, text) should work'
);

SELECT is(
    to_timestamp('05 Dec 2000', 'DD Mon YYYY'::citext),
    to_timestamp('05 Dec 2000', 'DD Mon YYYY'),
    'to_timestamp(text, citext) should work'
);

-- Try assigning function results to a column.
SELECT is( COUNT(*), 8::bigint, 'Should have 7 rows before to_char() inserts' )
  FROM try;

INSERT INTO try
VALUES ( to_char(  now()::timestamp,          'HH12:MI:SS') ),
       ( to_char(  now() + '1 sec'::interval, 'HH12:MI:SS') ), -- timetamptz
       ( to_char(  '15h 2m 12s'::interval,    'HH24:MI:SS') ),
       ( to_char(  current_date,              '999') ),
       ( to_char(  125::int,                  '999') ),
       ( to_char(  127::int4,                 '999') ),
       ( to_char(  126::int8,                 '999') ),
       ( to_char(  128.8::real,               '999D9') ),
       ( to_char(  125.7::float4,             '999D9') ),
       ( to_char(  125.9::float8,             '999D9') ),
       ( to_char( -125.8::numeric,            '999D99S') );

SELECT is( COUNT(*), 19::bigint, 'Should now have 19 rows' )
  FROM try;


-- Check like_escape().
SELECT is(
    like_escape( name, '' ),
    like_escape( name::text, '' ),
    'like_escape("' || name || '", text) should work'
) FROM srt;

SELECT is(
    like_escape( name, ''::citext ),
    like_escape( name::text, '' ),
    'like_escape("' || name || '", citext) should work'
) FROM srt;

SELECT is(
    like_escape( name::text, ''::citext ),
    like_escape( name::text, '' ),
    'like_escape("' || name || '"::text, citext) should work'
) FROM srt;

/*
-- Check cidr().
SELECT is(
    cidr( '192.168.1.2'::citext ), 
    cidr( '192.168.1.2'::text ), 
    'cidr(citext) should work'
);

-- Check cast functions.
SELECT is(
    '192.168.1.2'::cidr::citext,
    '192.168.1.2'::cidr::text,
    'Cast from cidr should work'
);
*/


-- Clean up.
SELECT * FROM finish();
ROLLBACK;
