citext 2.0.1
============

This distribution creates a custom PostgreSQL data type, CITEXT, a locale-
aware, case-insensitve TEXT type for PostgreSQL 8.3. Essentially, it
internally calls `LOWER()` when comparing values. Otherwise, it behaves
exactly like TEXT.

If you're running PostgreSQL 8.4 or higher, don't use this
extension. Use the core [citext
module](http://www.postgresql.org/docs/current/static/citext.html) instead.

If you're using PostgreSQL 8.2 or lower, this extension will not work. You
might be interested in [citext 1.0](http://pgfoundry.org/projects/citext/),
though be aware that it is not locale-aware and case-insensitively compares
only ASCII characters.

If, on the other hand, you're running PostgreSQL 8.3, this is the extension
for you

Installation
------------

To build citext, just do this:

    make
    make installcheck
    make install

If you encounter an error such as:

    "Makefile", line 8: Need an operator

You need to use GNU make, which may well be installed on your system as
`gmake`:

    gmake
    gmake install
    gmake installcheck

If you encounter an error such as:

    make: pg_config: Command not found

Be sure that you have `pg_config` installed and in your path. If you used a
package management system such as RPM to install PostgreSQL, be sure that the
`-devel` package is also installed. If necessary tell the build process where
to find it:

    env PG_CONFIG=/path/to/pg_config make && make installcheck && make install

If you encounter an error such as:

    ERROR:  must be owner of database regression

You need to run the test suite using a super user, such as the default
"postgres" super user:

    make installcheck PGUSER=postgres

Once citext is installed, you can add it to a database by running the
installation script:

    psql -d mydb -f /path/to/pgsql/share/contrib/citext.sql

If you want to install citext and all of its supporting objects into a
specific schema, use the `PGOPTIONS` environment variable to specify the
schema, like so:

    PGOPTIONS=--search_path=contrib psql -d mydb -f citext.sql

Dependencies
------------
The `citext` data type has no dependencies other than PostgreSQL 8.3.

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
