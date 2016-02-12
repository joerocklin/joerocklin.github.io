---
layout:     post
title:      When Unique Indexes Aren't
date:       2016-02-12
summary:    Sometimes indexes don't do what you expect
categories: databases tips
---

I'm in the process of developing a new API to lay down on an existing application. I won't go into too many details about the existing application, but let's just say that the requirement to add an API meant developing a new API application. The way the interactive application was written did not allow for adding another interface layer. So: interactive app written in perl/CGI, new app is Rails (4.x). Both have to work with the same database, and the long-term goal is to transition the interactive app to something which leverages the API and doesn't do direct database access.

The database design is _old_ but that's not to say that it's necessarily bad, just that the assumptions on some of the design were based in a time when 1GB of disk space was 'big' and table partitioning was not common in MySQL. So the developers went the route of doing some in-app data partitioning and went with a 'fully normalized' tables. The result is that if you want to look up information you may need to look in up 4 tables. If your query crosses a calendar year boundary, you may need to look at those 4 tables for each year.

I'm a firm believer in designing data tables in a way that reflects the data access patterns and not just using the normalization models. There is a time when practice trumps theory, after all. When working through some of the data modeling exercises for the new API project, I realized that the data layout for the above was going to pose ongoing maintenance and performance problems going forward. The challenge was how to walk the database layer forward without impacting existing code (which doesn't have a clear persistence-layer abstraction, so there's SQL in lots of places).

My first task was to pull together the myriad tables into a single table, and that was rather straightforward. I built a rails migration to create the new table to hold the aggregate information from the set of tables. I included indexes based on various queries I knew about, and a unique index to ensure the same level of data integrity of the previous tables. The last step piece of the puzzle was to create views to map the 'legacy' tables into the new table. Nothing new, nothing novel, just basic DBA stuff. Or so I thought.

The migration script walked through each of the tables performing an `INSERT INTO ... SELECT ...` to copy the table, move the old table out of the way (keeping it around for data verification purposes), and creating the view with the old table name. Ignoring the fact that ActiveRecord doesn't seem to be able to differentiate between Tables and Views, this all went rather well. All of the query testing I could think of resulted in matched results between the old tables and the views.

Then we tried some inserts and updates to the views, and they all succeeded - even when they shouldn't have! We were able to add rows which violated the uniqueness constraints! Thinking that it may have been something weird with the views I went about trying the inserts into the underlying table directly: same problem. Something weird is going on here.

After some Googling, it turns out that this is the expected behavior *when you allow columns in the unique constraint to be NULL*. The [MySQL documentation](https://dev.mysql.com/doc/refman/5.7/en/create-table.html) says this:

> A UNIQUE index creates a constraint such that all values in the index must be distinct. An error occurs if you try to add a new row with a key value that matches an existing row. For all engines, a UNIQUE index permits multiple NULL values for columns that can contain NULL.

And the [MariaDB Documentation](https://mariadb.com/kb/en/mariadb/create-table/) says it this way:

> The UNIQUE keyword means that the index will not accept duplicated values, except for NULLs. An error will raise if you try to insert duplicate values in a UNIQUE index.

Neither of those seem to say what they should say:

> If you allow a column in a unique key to be `NULL`, then you can have duplicate rows with identical keys.

Our solution to this ~~problem~~ design challenge was to change the tables to default to a 'zero' value for the columns instead of `NULL`. We still have a way to detect a `NULL`ish value, and the DB will maintain the integrity of the unique constraint.
