CITEXT Data Type 2.00
=====================

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

Installation
------------

To install the CITEXT data type, make sure that pg_xs is in your path, and
then type these commands:

  export USE_PGXS=1
  make
  make install
  make installcheck

If you encounter an error such as:

  "Makefile", line 8: Need an operator

You need to use GNU make, which may well be installed on your system as
'gmake':

  gmake
  gmake install
  gmake installcheck

If you encounter an error such as:

  make: pg_config: Command not found

Be sure that you have pg_config installed and in your path. If you used a
package management system such as RPM to install PostgreSQL, be sure that the
-devel package is also installed. If necessary, add the path to pg_config to
your $PATH environment variable:

  export PATH=$PATH:/path/to/pgsql/bin
  make
  make install
  make installcheck

And finally, if all that fails, copy the entire distribution directory to the
'contrib' subdirectory of the PostgreSQL source code and try it there using
these commands:

  make
  make install
  make installcheck

Note that the tests run by the `installcheck` target expect the locale to be
en_US.UTF-8, so there could potentially be some failures if you're using a
different locale.

Once everything is installed, go ahead and add the citext data type to your
database:

  psql -f citext.sql [db_name]

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
'citext.sql' in the 'share/contrib' subdirectory of your PostgreSQL server
directory. This 'README.citext' file will be in the 'doc/contrib'
subdirectory.

Suported Platforms
------------------

This package uses PostgreSQL's build tools for easy cross-platform build
suport. It is therefore designed to build and install on any platform that
supports PostgreSQL. It is known to work on the following platforms and
operating systems.

* Darwin 9.3.0 i386

If you know of others, please submit them! Use `uname -mrs` to get the formal
OS and hardware names.

Author
------
David E. Wheeler <david@kineticode.com>

Inspired by CITEXT 1.0 by Donald Fraser.

Copyright and License
---------------------

Copyright (c) 2008-2011 David E. Wheeler. Some rights reserved.

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose, without fee, and without a written agreement is
hereby granted, provided that the above copyright notice and this paragraph
and the following two paragraphs appear in all copies.

IN NO EVENT SHALL KINETICODE BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,
SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING
OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF KINETICODE HAS
BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

KINETICODE SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND
KINETICODE HAS NO OBLIGATIONS TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
ENHANCEMENTS, OR MODIFICATIONS.
