CREATE PROC [gold].[create_customertransactions_monthly_snapshot]
AS
BEGIN
    IF EXISTS (select 1 from [INFORMATION_SCHEMA].[TABLES] WHERE TABLE_TYPE ='BASE TABLE' AND TABLE_SCHEMA ='gold' AND TABLE_NAME ='customertransactions_monthly_snapshot')
        DROP TABLE gold.customertransactions_monthly_snapshot

    create table gold.customertransactions_monthly_snapshot
    as 
    SELECT t.[TransactionTypeID]
        , ttype.[TransactionTypeName]
        ,t.[PaymentMethodID]
        ,ptype.[PaymentMethodName]
        ,EOMONTH(t.[TransactionDate]) AS TransactionMonth
        ,SUM(t.[AmountExcludingTax]) AS [AmountExcludingTax]
        ,SUM(t.[TaxAmount]) AS [TaxAmount]
        ,SUM(t.[TransactionAmount]) AS [TransactionAmount]
        ,SUM(t.[OutstandingBalance]) AS [OutstandingBalance]
    FROM [lh_silver].[dbo].[silver_sales_customertransactions]  as t
    LEFT JOIN [lh_silver].[dbo].[silver_application_transactiontypes] as ttype
    on ttype.TransactionTypeID = t.TransactionTypeID
    LEFT JOIN [lh_silver].[dbo].[silver_application_paymentmethods] as ptype
        on ptype.[PaymentMethodID] = t.[PaymentMethodID]
    WHERE t.[IsFinalized]=1
    GROUP BY t.[TransactionTypeID]
        , ttype.[TransactionTypeName]
        ,t.[PaymentMethodID]
        ,ptype.[PaymentMethodName]
        ,EOMONTH(t.[TransactionDate]) 
END