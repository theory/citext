DROP OPERATOR CLASS citext_ops USING btree CASCADE;
DROP OPERATOR CLASS citext_ops USING hash CASCADE;

DROP AGGREGATE min(citext);
DROP AGGREGATE max(citext);

DROP OPERATOR = (citext, citext);
DROP OPERATOR <> (citext, citext);
DROP OPERATOR < (citext, citext);
DROP OPERATOR <= (citext, citext);
DROP OPERATOR >= (citext, citext);
DROP OPERATOR > (citext, citext);
DROP OPERATOR || (citext, citext);

DROP OPERATOR ~ (citext, citext);
DROP OPERATOR ~* (citext, citext);
DROP OPERATOR !~ (citext, citext);
DROP OPERATOR !~* (citext, citext);
DROP OPERATOR ~~ (citext, citext);
DROP OPERATOR ~~* (citext, citext);
DROP OPERATOR !~~ (citext, citext);
DROP OPERATOR !~~* (citext, citext);

DROP OPERATOR ~ (citext, text);
DROP OPERATOR ~* (citext, text);
DROP OPERATOR !~ (citext, text);
DROP OPERATOR !~* (citext, text);
DROP OPERATOR ~~ (citext, text);
DROP OPERATOR ~~* (citext, text);
DROP OPERATOR !~~ (citext, text);
DROP OPERATOR !~~* (citext, text);

DROP CAST (citext      AS text);
DROP CAST (text        AS citext);
DROP CAST (citext      AS varchar);
DROP CAST (varchar     AS citext);
DROP CAST (citext      AS bpchar);
DROP CAST (bpchar      AS citext);
DROP CAST (bytea       AS citext);
DROP CAST (citext      AS bytea);
DROP CAST (boolean     AS citext);
DROP CAST (citext      AS boolean);
DROP CAST ("char"      AS citext);
DROP CAST (citext      AS "char");
DROP CAST (float4      AS citext);
DROP CAST (citext      AS float4);
DROP CAST (float8      AS citext);
DROP CAST (citext      AS float8);
DROP CAST (numeric     AS citext);
DROP CAST (citext      AS numeric);
DROP CAST (int8        AS citext);
DROP CAST (citext      AS int8);
DROP CAST (int4        AS citext);
DROP CAST (citext      AS int4);
DROP CAST (int2        AS citext);
DROP CAST (citext      AS int2);
DROP CAST (name        AS citext);
DROP CAST (citext      AS name);
DROP CAST (cidr        AS citext);
DROP CAST (citext      AS cidr);
DROP CAST (inet        AS citext);
DROP CAST (citext      AS inet);
DROP CAST (macaddr     AS citext);
DROP CAST (citext      AS macaddr);
DROP CAST (xml         AS citext);
DROP CAST (citext      AS xml);
DROP CAST (money       AS citext);
DROP CAST (citext      AS money);
DROP CAST (timestamp   AS citext);
DROP CAST (citext      AS timestamp);
DROP CAST (timestamptz AS citext);
DROP CAST (citext      AS timestamptz);
DROP CAST (interval    AS citext);
DROP CAST (citext      AS interval);
DROP CAST (date        AS citext);
DROP CAST (citext      AS date);
DROP CAST (time        AS citext);
DROP CAST (citext      AS time);
DROP CAST (timetz      AS citext);
DROP CAST (citext      AS timetz);
DROP CAST (point       AS citext);
DROP CAST (citext      AS point);
DROP CAST (lseg        AS citext);
DROP CAST (citext      AS lseg);
DROP CAST (box         AS citext);
DROP CAST (citext      AS box);
DROP CAST (path        AS citext);
DROP CAST (citext      AS path);
DROP CAST (polygon     AS citext);
DROP CAST (citext      AS polygon);
DROP CAST (circle      AS citext);
DROP CAST (citext      AS circle);
DROP CAST (bit         AS citext);
DROP CAST (citext      AS bit);
DROP CAST (bit varying AS citext);
DROP CAST (citext      AS bit varying);
DROP CAST (tsvector    AS citext);
DROP CAST (citext      AS tsvector);
DROP CAST (tsquery     AS citext);
DROP CAST (citext      AS tsquery);
DROP CAST (uuid        AS citext);
DROP CAST (citext      AS uuid);

DROP FUNCTION citextin(cstring)
DROP FUNCTION citextout(citext)
DROP FUNCTION citextrecv(internal)
DROP FUNCTION citextsend(citext)
DROP FUNCTION citext(bpchar)
DROP FUNCTION citext(boolean)
DROP FUNCTION bool(citext)
DROP FUNCTION "char"(citext)
DROP FUNCTION citext("char")
DROP FUNCTION int8(citext)
DROP FUNCTION citext(int8)
DROP FUNCTION int4(citext)
DROP FUNCTION citext(int4)
DROP FUNCTION int2(citext)
DROP FUNCTION citext(int2)
DROP FUNCTION float4(citext)
DROP FUNCTION citext(float4)
DROP FUNCTION float8(citext)
DROP FUNCTION citext(float8)
DROP FUNCTION numerik(citext)
DROP FUNCTION citext(numeric)
DROP FUNCTION name(citext)
DROP FUNCTION citext(name)
DROP FUNCTION cidr(citext)
DROP FUNCTION citext(cidr)
DROP FUNCTION inet(citext)
DROP FUNCTION citext(inet)
DROP FUNCTION macaddr(citext)
DROP FUNCTION citext(macaddr)
DROP FUNCTION xml(citext)
DROP FUNCTION citext(xml)
DROP FUNCTION money(citext)
DROP FUNCTION citext(money)
DROP FUNCTION tstamp(citext)
DROP FUNCTION citext(timestamp)
DROP FUNCTION timestamptz(citext)
DROP FUNCTION citext(timestamptz)
DROP FUNCTION ival(citext)
DROP FUNCTION citext(interval)
DROP FUNCTION date(citext)
DROP FUNCTION citext(date)
DROP FUNCTION tme(citext)
DROP FUNCTION citext(time)
DROP FUNCTION timetz(citext)
DROP FUNCTION citext(timetz)
DROP FUNCTION point(citext)
DROP FUNCTION citext(point)
DROP FUNCTION lseg(citext)
DROP FUNCTION citext(lseg)
DROP FUNCTION box(citext)
DROP FUNCTION citext(box)
DROP FUNCTION path(citext)
DROP FUNCTION citext(path)
DROP FUNCTION polygon(citext)
DROP FUNCTION citext(polygon)
DROP FUNCTION circle(citext)
DROP FUNCTION citext(circle)
DROP FUNCTION bitt(citext)
DROP FUNCTION citext(bit)
DROP FUNCTION bitv(citext)
DROP FUNCTION citext(bit varying)
DROP FUNCTION tsvector(citext)
DROP FUNCTION citext(tsvector)
DROP FUNCTION tsquery(citext)
DROP FUNCTION citext(tsquery)
DROP FUNCTION uuid(citext)
DROP FUNCTION citext(uuid)
DROP FUNCTION citext_eq( citext, citext )
DROP FUNCTION citext_ne( citext, citext )
DROP FUNCTION citext_lt( citext, citext )
DROP FUNCTION citext_le( citext, citext )
DROP FUNCTION citext_gt( citext, citext )
DROP FUNCTION citext_ge( citext, citext )
DROP FUNCTION textcat(citext, citext)
DROP FUNCTION citext_cmp(citext, citext)
DROP FUNCTION citext_hash(citext)
DROP FUNCTION citext_smaller(citext, citext)
DROP FUNCTION citext_larger(citext, citext)
DROP FUNCTION lower(citext)
DROP FUNCTION upper(citext)
DROP FUNCTION texticlike(citext, citext)
DROP FUNCTION texticnlike(citext, citext)
DROP FUNCTION texticregexeq(citext, citext)
DROP FUNCTION texticregexne(citext, citext)
DROP FUNCTION texticlike(citext, text)
DROP FUNCTION texticnlike(citext, text)
DROP FUNCTION texticregexeq(citext, text)
DROP FUNCTION texticregexne(citext, text)
DROP FUNCTION regexp_matches( citext, citext );
DROP FUNCTION regexp_matches( citext, citext, text );
DROP FUNCTION regexp_replace( citext, citext, text );
DROP FUNCTION regexp_replace( citext, citext, text, text );
DROP FUNCTION regexp_split_to_array( citext, citext );
DROP FUNCTION regexp_split_to_array( citext, citext, text );
DROP FUNCTION regexp_split_to_table( citext, citext );
DROP FUNCTION regexp_split_to_table( citext, citext, text );
DROP FUNCTION strpos( citext, citext );
DROP FUNCTION replace( citext, citext, citext );
DROP FUNCTION split_part( citext, citext, int );
DROP FUNCTION translate( citext, citext, text );
