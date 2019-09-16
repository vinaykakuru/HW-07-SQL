-- How can you isolate (or group) the transactions of each cardholder?
Select ch.name as "Card_Holder", sum(txn.amount) as "Total_Amt.", count(txn.amount) as "Count_of_Txns"
From card_holder ch, transactions txn, credit_card cc
Where ch.id = cc.card_holder_id and cc.card = txn.card
Group by ch.name


-- Consider the time period 7:00 a.m. to 9:00 a.m.
-- What are the top 100 highest transactions during this time period?
Select * from transactions
Where date::time >= '07:00:00'
And date::time <= '09:00:00'
Order by amount Desc
Limit 100; 
-- Do you see any fraudulent or anomalous transactions?
	-- Not sure if there are any fraudulent transactions
-- If you answered yes to the previous question, explain why you think there might be fraudulent transactions during this time frame.


-- Some fraudsters hack a credit card by making several small payments (generally less than $2.00), which are typically ignored by cardholders. 
-- Count the transactions that are less than $2.00 per cardholder. 
Select ch.name as "Card_Holder", count(txn.amount) as "Cnt_Txn_Less_Than_2"
From card_holder ch, transactions txn, credit_card cc
Where ch.id = cc.card_holder_id and cc.card = txn.card and txn.amount < 2
Group by ch.name
Order by "Cnt_Txn_Less_Than_2" Desc;

--	Is there any evidence to suggest that a credit card has been hacked? Explain your rationale.
-- Megan Price	26
-- Stephanie Dalton	22
-- Peter Mckay	22
-- All the above values are over P90
Select
	avg(Cnt_Txn_Less_Than_2) as Avg_Txn_Below_$2,
	stddev(Cnt_Txn_Less_Than_2)::NUMERIC(5,2) as Std_Dev_Txn_Below_$2,
	percentile_cont(0.9) within group ( order by Cnt_Txn_Less_Than_2 ) as P90
from 
	(
		Select ch.name, count(txn.amount) as Cnt_Txn_Less_Than_2
		From card_holder ch, transactions txn, credit_card cc
		Where ch.id = cc.card_holder_id and cc.card = txn.card and txn.amount < 2
		Group by ch.name
		Order by Cnt_Txn_Less_Than_2 Desc
	) a;
	




-- What are the top 5 merchants prone to being hacked using small transactions?
Select m.name as "Merchant", count(txn.amount) as "Cnt_Txn_Less_Than_2"
From merchant m, transactions txn
Where m.id = txn.id_merchant and txn.amount < 2
Group by m.name
Order by "Cnt_Txn_Less_Than_2" Desc
Limit 5;

-- Once you have a query that can be reused, create a view for each of the previous queries.
Create View Card_Holder_Summary as
	Select ch.name as "Card_Holder", sum(txn.amount) as "Total_Amt.", count(txn.amount) as "Count_of_Txns"
	From card_holder ch, transactions txn, credit_card cc
	Where ch.id = cc.card_holder_id and cc.card = txn.card
	Group by ch.name;

Create View Count_of_Txns_Below_2_by_Card_Holder as
	Select ch.name as "Card_Holder", count(txn.amount) as "Cnt_Txn_Less_Than_2"
	From card_holder ch, transactions txn, credit_card cc
	Where ch.id = cc.card_holder_id and cc.card = txn.card and txn.amount < 2
	Group by ch.name
	Order by "Cnt_Txn_Less_Than_2" Desc;

Create View Top_100_Txn_Between_7AM_9AM as
	Select * from transactions
	Where date::time >= '07:00:00'
	And date::time <= '09:00:00'
	Order by amount Desc
	Limit 100; 

Create View Top_5_Merchants_Prone_To_Hack AS
	Select m.name as "Merchant", count(txn.amount) as "Cnt_Txn_Less_Than_2"
	From merchant m, transactions txn
	Where m.id = txn.id_merchant and txn.amount < 2
	Group by m.name
	Order by "Cnt_Txn_Less_Than_2" Desc
	Limit 5;


/*
	Create a report for fraudulent transactions of some top customers of the firm. 
	To achieve this task, perform a visual data analysis of fraudulent transactions using Pandas, Plotly Express, hvPlot, and SQLAlchemy to create the visualizations.
*/

/*
	Verify if there are any fraudulent transactions in the history of two of the most important customers of the firm. 
	For privacy reasons, you only know that their cardholders' IDs are 18 and 2.
*/	
Create View Card_Holder_ID18_ID2_Details as
Select ch.id, ch.name, cc.card, EXTRACT(Month From txn.date) as Month, txn.date, txn.amount, m.name as Merchant, mc.name as Category from card_holder ch, transactions txn, credit_card cc, merchant m, merchant_category mc
where cc.card_holder_id in(2, 18) and txn.card = cc.card and ch.id = cc.card_holder_id and txn.id_merchant = m.id and m.id_merchant_category = mc.id
Order BY txn.card, date;


/*
	Using hvPlot, create a line plot representing the time series of transactions over the course of the year for each cardholder. 
	In order to compare the patterns of both cardholders, create a line plot containing both lines.
	What difference do you observe between the consumption patterns? Does the difference suggest a fraudulent transaction? Explain your rationale.
*/


-- The CEO of the biggest customer of the firm suspects that someone has used her corporate credit card without authorization in the first quarter of 2018 
-- to pay quite expensive restaurant bills. You are asked to find any anomalous transactions during that period.
Create View Card_Holder_ID25_Details as
Select ch.id, ch.name, cc.card, txn.date, txn.amount from card_holder ch, transactions txn, credit_card cc
where cc.card_holder_id = 25 and txn.card = cc.card and ch.id = cc.card_holder_id
Order BY txn.card, date
;


/*
	Using Plotly Express, create a series of six box plots, one for each month, in order to identify how many outliers per month for cardholder ID 25.
	Do you notice any anomalies? Describe your observations and conclusions.
*/	