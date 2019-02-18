

DECLARE @DATASET VARCHAR(8000)
SELECT @DATASET = '18.93,20.25,17.05,16.59,21.09,16.22,21.43,27.13,18.62,21.31,23.96,25.52,19.64,23.49,15.28,22.77,23.1,26.58,27.03,23.75,27.39,15.93,17.83,18.82,21.56,25.33,25,19.33,22.08,24.03'

/*
USE THIS ONLY IF THE STRING_SPLIT() FUNCTION DOESN'T WORK 
ALTER DATABASE [<DATABASENAME>]
SET COMPATIBILITY_LEVEL = 130 -- FOR SQL SERVER 2016
GO
*/

DROP TABLE IF EXISTS  #BUY_SELL_PROFIT
SELECT  ROW_NUMBER() OVER ( ORDER BY ( SELECT 0 ) ) AS [DAYOFTHEMONTH],VALUE AS STOCKPRICES
INTO #BUY_SELL_PROFIT
FROM 
STRING_SPLIT(@DATASET, ',');

------***************** PROGRAM SECTION ********************------------------------
---DECLARE SECTION
DECLARE @i INT ,@j INT, @ITERATION INT , @MIN_PRICE DECIMAL(5,2) , @VARIABLE_PRICE DECIMAL(5,2) 
DECLARE @DIFF DECIMAL(5,2) , @MAX_DIFF DECIMAL(5,2) 
DECLARE @BUYPRICE DECIMAL(5,2) , @SELLPRICE DECIMAL(5,2) 
DECLARE @BUYDAYOFTHEMONTH INT ,@SELLDAYOFTHEMONTH INT

SELECT @i = 1 --while loop counter
SELECT @MAX_DIFF = 0.00 ---assuming default gain/difference value as 0
SELECT @ITERATION = MAX(DAYOFTHEMONTH) FROM #BUY_SELL_PROFIT ---while loop iterations
SELECT @MIN_PRICE = STOCKPRICES FROM #BUY_SELL_PROFIT WHERE DAYOFTHEMONTH = @i  ---assuming the first day Stock price to be the minimum price 

WHILE @i<= @ITERATION --** start of loop **--

BEGIN
	SELECT @j=@i+1
	SELECT @VARIABLE_PRICE = STOCKPRICES FROM #BUY_SELL_PROFIT WHERE DAYOFTHEMONTH = @j
	SELECT @DIFF = @VARIABLE_PRICE-@MIN_PRICE 

		IF @DIFF> @MAX_DIFF  /* FIND THE MAXIMUM DIFFERENCE SO FAR */
		BEGIN
			SELECT @MAX_DIFF = @DIFF
			SELECT @BUYPRICE = @MIN_PRICE
			SELECT @SELLPRICE = @VARIABLE_PRICE
			SELECT @BUYDAYOFTHEMONTH = DAYOFTHEMONTH FROM #BUY_SELL_PROFIT WHERE STOCKPRICES = @BUYPRICE
			SELECT @SELLDAYOFTHEMONTH = DAYOFTHEMONTH FROM #BUY_SELL_PROFIT WHERE STOCKPRICES = @SELLPRICE
		END

		IF @VARIABLE_PRICE < @MIN_PRICE /* FIND THE MINIMUM PRICE SO FAR */
		BEGIN
			SELECT @MIN_PRICE = @VARIABLE_PRICE
		END

	SELECT @i=@i + 1 -- incrementing the counter
END					--** End of loop **--

IF @MAX_DIFF > 0
BEGIN
	SELECT CONCAT(@BUYDAYOFTHEMONTH,' (', @BUYPRICE,') , ', @SELLDAYOFTHEMONTH,' (',@SELLPRICE,') ') as [OUTPUT]
END
ELSE
BEGIN
	SELECT 'NO POSSIBILITY FOR GAIN' as [OUTPUT]
END
