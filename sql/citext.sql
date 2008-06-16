\set ECHO none
\encoding UTF-8

--
-- Tests for the CITEXT data type.
--
--

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
--\i citext.sql

-- Keep things quiet.
SET client_min_messages = warning;

-- Revert all changes on failure.
\set ON_ERROR_ROLBACK true
\set ON_ERROR_STOP true

-- Plan the tests.
--SELECT plan(86);
SELECT * FROM no_plan();

-- Output a diagnostic message if the collation is not en_US.UTF-8.
SELECT diag(
    E'These tests expect LC_COLLATE to be en_US.UTF-8,\n'
  || 'but yours is set to ' || setting || E'.\n'
  || 'As a result, some tests may fail. YMMV.'
)
  FROM pg_settings
 WHERE name = 'lc_collate'
   AND setting <> 'en_US.UTF-8';

CREATE TEMP TABLE try (
    name citext PRIMARY KEY
);

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

-- Some longerr comparisons.
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
    '"Ask Bjørn Hansen" shoulde eq "Ask Bjørn Hansen"'
);

SELECT is(
    'Ask Bjørn Hansen'::citext,
    'ASK BJØRN HANSEN'::citext,
    '"Ask Bjørn Hansen" shoulde eq "ASK BJØRN HANSEN"'
);

SELECT is(
    'ask bjørn hansen'::citext,
    'ASK BJØRN HANSEN'::citext,
    '"ask bjørn hansen" shoulde eq "ASK BJØRN HANSEN"'
);

SELECT isnt(
    'Ask Bjørn Hansen'::citext,
    'Ask Bjorn Hansen'::citext,
    '"Ask Bjørn Hansen" shoulde ne "Ask Bjorn Hansen"'
);

SELECT isnt(
    'Ask Bjørn Hansen'::citext,
    'ASK BJORN HANSEN'::citext,
    '"Ask Bjørn Hansen" shoulde ne "ASK BJORN HANSEN"'
);

SELECT isnt(
    'ask bjørn hansen'::citext,
    'ASK BJORN HANSEN'::citext,
    '"ask bjørn hansen" shoulde ne "ASK BJORN HANSEN"'
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


-- Now try writing to a table.
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

-- Create a table with some records with which to do some testing.
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
CREATE AGGREGATE array_accum (anyelement) (
    sfunc = array_append,
    stype = anyarray,
    initcond = '{}'
);

SELECT is(
    array_accum(b)::text,
    ARRAY['AAA', 'aardvark', 'aba', 'ABC', 'abc', 'â', 'ç']::text,
    'The words should be case-insensitively sorted'
) FROM ( SELECT name FROM srt ORDER BY name ) AS a(b);

SELECT is(
    array_accum(b),
    ARRAY['AAA'::citext, 'aardvark'::citext, 'aba'::citext, 'ABC'::citext, 'abc'::citext, 'â'::citext, 'ç'],
    'The words should be case-insensitively sorted (citext array)'
) FROM ( SELECT name FROM srt ORDER BY name ) AS a(b);

SELECT is(
    array_accum(UPPER(b))::text,
    ARRAY['AAA', 'AARDVARK', 'ABA', 'ABC', 'ABC', 'Â', 'Ç']::text,
    'The UPPER(words) should be case-insensitively sorted'
) FROM ( SELECT name FROM srt ORDER BY name ) AS a(b);

SELECT is(
    array_accum(UPPER(b))::text,
    ARRAY['AAA'::citext, 'AARDVARK'::citext, 'ABA'::citext, 'ABC'::citext, 'ABC'::citext, 'Â'::citext, 'Ç']::text,
    'The UPPER(words) should be case-insensitively sorted (citext array_'
) FROM ( SELECT name FROM srt ORDER BY name ) AS a(b);

SELECT is(
    array_accum(UPPER(b)),
    ARRAY['aaa'::citext, 'aardvark'::citext, 'aba'::citext, 'abc'::citext, 'abc'::citext, 'â'::citext, 'ç'],
    'The UPPER(words) should case-insensitively compare'
) FROM ( SELECT name FROM srt ORDER BY name ) AS a(b);

SELECT is(
    array_accum(LOWER(b))::text,
    ARRAY['aaa', 'aardvark', 'aba', 'abc', 'abc', 'â', 'ç']::text,
    'The UPPER(words) should be case-insensitively sorted'
) FROM ( SELECT name FROM srt ORDER BY name ) AS a(b);

SELECT is(
    array_accum(LOWER(b))::text,
    ARRAY['aaa'::citext, 'aardvark'::citext, 'aba'::citext, 'abc'::citext, 'abc'::citext, 'â'::citext, 'ç']::text,
    'The UPPER(words) should be case-insensitively sorted (citext array)'
) FROM ( SELECT name FROM srt ORDER BY name ) AS a(b);

SELECT is(
    array_accum(LOWER(b)),
    ARRAY['AAA'::citext, 'AARDVARK'::citext, 'ABA'::citext, 'ABC'::citext, 'ABC'::citext, 'Â'::citext, 'Ç'],
    'The LOWER(words) should case-insensitively compare'
) FROM ( SELECT name FROM srt ORDER BY name ) AS a(b);

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

-- Check text length.
SELECT is( textlen( name ), textlen(name::text), 'textlen("' || name || '") should be correct' )
  FROM srt;

SELECT is( length( name ), length(name::text), 'length("' || name || '") should be correct' )
  FROM srt;

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
    array_accum(b),
    ARRAY['â'::citext, 'ç'::citext ],
    'NOT LIKE should work properly'
) FROM ( SELECT name FROM srt WHERE name NOT LIKE '%a%' ORDER BY name ) AS a(b);

SELECT is(
    array_accum(b),
    ARRAY['â'::citext, 'ç'::citext ],
    'NOT LIKE should work properly and case-insensitively'
) FROM ( SELECT name FROM srt WHERE name NOT LIKE '%A%' ORDER BY name ) AS a(b);

SELECT is(
    array_accum(b),
    ARRAY['â'::citext, 'ç'::citext ],
    'NOT ILIKE should work properly'
) FROM ( SELECT name FROM srt WHERE name NOT LIKE '%a%' ORDER BY name ) AS a(b);

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
    array_accum(b),
    ARRAY['â'::citext, 'ç'::citext ],
    '!~~ should work properly'
) FROM ( SELECT name FROM srt WHERE name !~~ '%a%' ORDER BY name ) AS a(b);

SELECT is(
    array_accum(b),
    ARRAY['â'::citext, 'ç'::citext ],
    '!~~ should work properly and case-insensitively'
) FROM ( SELECT name FROM srt WHERE name !~~ '%A%' ORDER BY name ) AS a(b);

SELECT is(
    array_accum(b),
    ARRAY['â'::citext, 'ç'::citext ],
    '!~~* should work properly and case-insensitively'
) FROM ( SELECT name FROM srt WHERE name !~~* '%A%' ORDER BY name ) AS a(b);

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
    array_accum(b),
    ARRAY['â'::citext, 'ç'::citext ],
    '!~ should work properly'
) FROM ( SELECT name FROM srt WHERE name !~ 'a+' ORDER BY name ) AS a(b);

SELECT is(
    array_accum(b),
    ARRAY['â'::citext, 'ç'::citext ],
    '!~ should work properly and case-insensitively'
) FROM ( SELECT name FROM srt WHERE name !~ 'A+' ORDER BY name ) AS a(b);

SELECT is(
    array_accum(b),
    ARRAY['â'::citext, 'ç'::citext ],
    '!~* should work properly and case-insensitively'
) FROM ( SELECT name FROM srt WHERE name !~* 'A+' ORDER BY name ) AS a(b);

-- Check cast to to varchar and text for LIKE and ILIKE.
SELECT is( name::varchar, 'ç', 'varchar LIKE should work properly' )
  FROM srt
 WHERE name LIKE 'ç%';

SELECT is( name::varchar, 'ç', 'varchar ILIKE should work properly' )
  FROM srt
 WHERE name ILIKE 'Ç%';

SELECT is(
    array_accum(b::varchar),
    ARRAY['â'::varchar, 'ç'::varchar ],
    'varchar NOT LIKE should work properly'
) FROM ( SELECT name FROM srt WHERE name NOT LIKE '%a%' ORDER BY name ) AS a(b);

SELECT is( name::text, 'ç', 'text LIKE should work properly' )
  FROM srt
 WHERE name LIKE 'ç%';

SELECT is( name::text, 'ç', 'text ILIKE should work properly' )
  FROM srt
 WHERE name ILIKE 'Ç%';

SELECT is(
    array_accum(b::text),
    ARRAY['â'::text, 'ç'::text ],
    'text NOT LIKE should work properly'
) FROM ( SELECT name FROM srt WHERE name NOT LIKE '%a%' ORDER BY name ) AS a(b);

-- Check LIKE and ILIKE text, varchar, and name.
SELECT is( name, 'ç', 'text LIKE should work properly' )
  FROM srt
 WHERE name LIKE 'ç%'::text;

SELECT is( name, 'ç', 'text ILIKE should work properly' )
  FROM srt
 WHERE name ILIKE 'Ç%'::text;

SELECT is(
    array_accum(b),
    ARRAY['â'::citext, 'ç'::citext ],
    'text NOT LIKE should work properly'
) FROM ( SELECT name FROM srt WHERE name NOT LIKE '%a%'::text ORDER BY name ) AS a(b);

SELECT is( name, 'ç', 'varchar LIKE should work properly' )
  FROM srt
 WHERE name LIKE 'ç%'::varchar;

SELECT is( name, 'ç', 'varchar ILIKE should work properly' )
  FROM srt
 WHERE name ILIKE 'Ç%'::varchar;

SELECT is(
    array_accum(b),
    ARRAY['â'::citext, 'ç'::citext ],
    'varchar NOT LIKE should work properly'
) FROM ( SELECT name FROM srt WHERE name NOT LIKE '%a%'::varchar ORDER BY name ) AS a(b);

SELECT is( name, 'ç', 'name LIKE should work properly' )
  FROM srt
 WHERE name LIKE 'ç%'::name;

SELECT is( name, 'ç', 'name ILIKE should work properly' )
  FROM srt
 WHERE name ILIKE 'Ç%'::name;

SELECT is(
    array_accum(b),
    ARRAY['â'::citext, 'ç'::citext ],
    'name NOT LIKE should work properly'
) FROM ( SELECT name FROM srt WHERE name NOT LIKE '%a%'::name ORDER BY name ) AS a(b);

SELECT is( name, 'ç', 'bpchar LIKE should work properly' )
  FROM srt
 WHERE name LIKE 'ç%'::bpchar;

SELECT is( name, 'ç', 'bpchar ILIKE should work properly' )
  FROM srt
 WHERE name ILIKE 'Ç%'::bpchar;

SELECT is(
    array_accum(b),
    ARRAY['â'::citext, 'ç'::citext ],
    'bpchar NOT LIKE should work properly'
) FROM ( SELECT name FROM srt WHERE name NOT LIKE '%a%'::bpchar ORDER BY name ) AS a(b);

SELECT is( name, 'ç', 'char LIKE should work properly' )
  FROM srt
 WHERE name LIKE 'ç'::char;

SELECT is( name, 'ç', 'char ILIKE should work properly' )
  FROM srt
 WHERE name ILIKE 'Ç'::char;

SELECT is(
    array_accum(b),
    ARRAY['AAA'::citext, 'aardvark'::citext, 'aba'::citext, 'ABC'::citext, 'abc'::citext, 'â'::citext, 'ç'::citext],
    'char NOT LIKE should work properly'
) FROM ( SELECT name FROM srt WHERE name NOT LIKE 'a'::char ORDER BY name ) AS a(b);


-- Check SIMILAR TO.
--SELECT is( name, 'ç', 'SIMILAR TO should work properly' )
--  FROM srt
-- WHERE name SIMILAR TO '%ç*';

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

-- Test repeat()
SELECT is( 	repeat('Pg'::citext, 4), 'PgPgPgPg', 'repeat(citext, int) should work' );

-- Test substr() and substring().
SELECT is(
    substr('alphabet'::citext, 3),
    'phabet',
    'subtr(citext, int) should work'
);

SELECT is(
    substr('alphabet'::citext, 3, 2),
    'ph',
    'subtr(citext, int, int) should work'
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

-- Clean up.
SELECT * FROM finish();
ROLLBACK;
