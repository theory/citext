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

-- Now check the sort order of things.
CREATE TEMP TABLE srt (
    name CITEXT
);

INSERT INTO srt (name)
VALUES ('aardvark'),
       ('AAA'),
       ('aba'),
       ('ABC'),
       ('abc'),
       ('AAAA'),
       ('â');

CREATE AGGREGATE array_accum (anyelement) (
    sfunc = array_append,
    stype = anyarray,
    initcond = '{}'
);

-- citext_smaller() seems to be segfaulting.
--SELECT is( MIN(name), 'AAA', 'The first value should be "AAA"' )
--  FROM srt;

SELECT is(
           array_accum(name)::text,
           ARRAY['aardvark','AAA','aba','ABC','abc','AAAA','â']::text,
           'The words should be case-insensitively sorted'
) FROM srt; 

SELECT is(
           array_accum(LOWER(name))::text,
           ARRAY['aardvark','aaa','aba','abc','abc','aaaa','â']::text,
           'The words should be case-insensitively sorted'
) FROM srt; 

SELECT is( LOWER(name), 'aaa', 'LOWER("AAA") should return "aaa"' )
  FROM srt
 WHERE name = 'AAA'::text;

SELECT is( UPPER(name), 'Â', 'UPPER("â") should return "Â"' )
  FROM srt
 WHERE name = 'â'::text;

-- I think that i need to add the assignment cast operators to get this to work.
-- SELECT is( LOWER(name), 'aaa', 'LOWER("AAA") should return "aaa"' )
--   FROM srt
--  WHERE name = 'AAA'::citext;

-- SELECT is( UPPER(name), 'Â', 'UPPER("â") should return "Â"' )
--   FROM srt
--  WHERE name = 'â'::citext;

SELECT * FROM finish();

-- Clean up.
ROLLBACK;
