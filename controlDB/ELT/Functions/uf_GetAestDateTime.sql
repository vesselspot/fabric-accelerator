CREATE FUNCTION ELT.[uf_GetAestDateTime]()
RETURNS datetime2
WITH EXECUTE AS CALLER
AS
 BEGIN
    RETURN CONVERT(datetime2,CONVERT(datetimeoffset, getdate()) AT TIME ZONE 'AUS Eastern Standard Time')
END
GO