CITEXT Data Type 2.0.2
======================

This distribution creates a custom PostgreSQL data type, CITEXT, a locale-
aware, case-insensitve TEXT type for PostgreSQL 8.3. Essentially, it
internally calls `LOWER()` when comparing values. Otherwise, it behaves
exactly like TEXT.

The standard approach to doing case-insensitive matches in PostgreSQL has been
to use the `LOWER()` function in your queries, something like this:

    SELECT *
    FROM tab
    WHERE lower(col) = LOWER(?);

This works reasonably well, but has a number of drawbacks:

* It makes your SQL statements verbose, and you always have to remember to use
  `LOWER()` on both the column and on the query value (so that both use the
  same collations).
* It won't use an index, unless you create a functional index using `LOWER()`.
* You can't have a case-insensitive primary key without creating two unique
  indexes, one for the primary key (implicitly created) and a functional index
  using `LOWER()`.

The CITEXT data type allows you to replace all the calls to `LOWER()` in
client code that wants to perform case-insensitive queries, while also
allowing a primary key to be case-insensitive. CITEXT is multibyte aware, just
like TEXT, which means that the comparison of uppercase and lowercase
characters is dependent on the rules in the `LC_COLLATE` locale setting.
Again, this behavior is identical to the use of `LOWER()` in queries. But
because it's done in C and is transparent, you don't have to remember to do
anything special in your queries.

Usage
-----

Once you've installed the CITEXT data type, you can start using it in your
database.

    CREATE TABLE users (
        nick CITEXT,
        pass TEXT
    );

    INSERT INTO users VALUES ( 'larry',  md5(random()::text) );
    INSERT INTO users VALUES ( 'Tom',    md5(random()::text) );
    INSERT INTO users VALUES ( 'Damian', md5(random()::text) );
    INSERT INTO users VALUES ( 'NEAL',   md5(random()::text) );
    INSERT INTO users VALUES ( 'Bjørn',  md5(random()::text) );
    INSERT INTO users VALUES ( '☺唐鳳☻', md5(random()::text) );

If you ever need to install the data type into another database, you'll find
`citext.sql` in the `share/contrib` subdirectory of your PostgreSQL server
directory. This file, `citext.md`, will be in the `doc/contrib` subdirectory.

Author
------
David E. Wheeler <david@justatheory.com>

Inspired by CITEXT 1.0 by Donald Fraser.

Copyright and License
---------------------

Copyright (c) 2008-2011 David E. Wheeler.

This module is free software; you can redistribute it and/or modify it under
the [PostgreSQL License](http://www.opensource.org/licenses/postgresql).

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose, without fee, and without a written agreement is
hereby granted, provided that the above copyright notice and this paragraph
and the following two paragraphs appear in all copies.

In no event shall David E. Wheeler be liable to any party for direct,
indirect, special, incidental, or consequential damages, including lost
profits, arising out of the use of this software and its documentation, even
if David E. Wheeler has been advised of the possibility of such damage.

David E. Wheeler specifically disclaim any warranties, including, but not
limited to, the implied warranties of merchantability and fitness for a
particular purpose. The software provided hereunder is on an "as is" basis,
and David E. Wheeler have no obligations to provide maintenance, support,
updates, enhancements, or modifications.
