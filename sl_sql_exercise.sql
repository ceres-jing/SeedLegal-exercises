/*
    INFO: This exercise is not timed, and you may use any available resources.
        https://extendsclass.com/postgresql-online.html# is a PostgreSQL 11.x sandbox if you need it.

    TODO: Please resolve the comments in the code below.
    TODO: Please refactor the code to make it more maintainable.
        - Add any new comments that you think would help.
*/


-- create a function to find the median value of a given numeric array 
create or replace function sl_sql_exercise(numeric[])
   returns numeric as
$$  
   select avg(val)
       from (
            select val
            from unnest($1) val
            where val.val is not null
            order by 1
            limit  2 - mod(array_upper($1, 1), 2) 
            offset ceil(array_upper($1, 1) / 2.0) - 1
       ) sub;
$$
language 'sql' immutable;

drop aggregate if exists sl_sql_exercise(numeric);

--create an aggregated function for numeric_median function,
-- then this could be used with "group by" to find find the median value of each group.
create aggregate sl_sql_exercise(numeric) (
  sfunc=array_append,
  stype=numeric[],
  finalfunc=sl_sql_exercise,
  initcond='{}'
);
/*
reference of some usages in this function:
        array upper: return the upper dimension of an array 
        MOD():  get the remainder from a division.
        order by 1: order by the first column 
        $1: refers to the first argument referenced in the function body.
        unnest: expand an array to a set of rows.
*/




-- create a function to find the median value of a given text array 
create or replace function sl_sql_exercise(text[]) 
    returns text as
$$
    with q as 
    (select 
        val, index 
        from unnest($1) with ordinality input(val, index) 
        where val is not null)

    select
        array_agg(val)::text as val
        from q, (select max(index) as max_idx from q) as idx
        where index between floor((max_idx+1)/2.0) and ceil((max_idx+1)/2.0)
$$ language sql immutable;

--create an aggregated function based for text_median function
drop aggregate if exists sl_sql_exercise(text);
create aggregate sl_sql_exercise(text) (
  sfunc=array_append,
  stype=text[],
  finalfunc=sl_sql_exercise,
  initcond='{}'
);

/*
reference of some usages in this function:

with ordinality: 
                When a function in the FROM clause is suffixed by WITH ORDINALITY, 
                a bigint column is appended to the output which starts from 1 and increments by 1 for the function's output. 
                This is most useful in the case of set returning functions such as unnest().

array_agg:      input values, including nulls, concatenated into an array
::text   :      cast to a text type

*/



comment on function sl_sql_exercise(numeric[]) is $$ Return the median of a numerical array $$;
comment on function sl_sql_exercise(text[]) is $$ Return the median value/Values of the text array$$;


/*
Usage cases:

Find the median temperature of each month in the database of weather.

SELECT 
    month, sl_sql_exercise(temperature) AS median_temperature
    FROM weather 
    group by month 
    order by month;

*/



-- print the function, args, and docstring within this file in the user interface.

select
    p.proname as function,
    pg_get_function_arguments(p.oid) as args,
    obj_description(p.oid) as docstring

    from pg_proc p
    left join pg_namespace n on p.pronamespace = n.oid
    left join pg_language l on p.prolang = l.oid
    left join pg_type t on t.oid = p.prorettype

    where p.proname = 'sl_sql_exercise'
    and obj_description(p.oid) is not null;




/* 

Reflection of these two SQL functions:

Figure out how these two functions work is more challenging than the python class. 
Because Some functions/usages within the created function  are not familiar to me,
but also because there is no concrete example/table for me to work through.

I approached this question by first figuring out those unfamiliar usages while also imagining a table and an array 
to see how it is transformed through these operations.  As you can see above, I have listed some usages within the created function 
that I need to check online. I think the most tricky one is “unnest".  After thinking and going through the code back and forth,
I realized the data might be stored as JSON format.  eg. 'column':[1,2,3,4,5]. then it makes sense to unnest it from array to rows.

With an example in my mind, I then went through the function from beginning to end.  I realized it was about finding the 
median value.  After that, I created a table and inserted the values.  Run two functions to verify my finding. It tunred out 
to be right.

Finally, I read through the code to make it more structured and added comments and one usage case.

*/



