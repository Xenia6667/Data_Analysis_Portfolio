drop table if exists food_raw_df;

SET search_path TO fast_food_sales_data;
create table food_raw_df(	
	col1 text,
	col2 text,
	col3 text,
	col4 text,
	col5 text,
	col6 text,
	col7 text,
	col8 text,
	col9 text,
	col10 text
);

