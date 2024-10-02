# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "b62f993f-3750-4dfe-94c7-fa742bf96481",
# META       "default_lakehouse_name": "ba_wwi_lakehouse",
# META       "default_lakehouse_workspace_id": "7c4738e4-9ef8-4a07-87f2-9edc35a45584",
# META       "known_lakehouses": [
# META         {
# META           "id": "b62f993f-3750-4dfe-94c7-fa742bf96481"
# META         }
# META       ]
# META     }
# META   }
# META }

# CELL ********************

%run /commonTransforms

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

%run /DeltaLakeFunctions

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

import json

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# # Notebook Parameters

# PARAMETERS CELL ********************

L1TransformInstanceID = None
L1TransformID = None
IngestID = None
CustomParameters = None
InputRawFileSystem = None
InputRawFileFolder = None
InputRawFile = None
InputRawFileDelimiter = None
InputFileHeaderFlag = None
OutputL1CurateFileSystem = None
OutputL1CuratedFolder = None
OutputL1CuratedFile = None
OutputL1CuratedFileDelimiter = None
OutputL1CuratedFileFormat = None
OutputL1CuratedFileWriteMode = None
OutputDWStagingTable = None
LookupColumns = None
OutputDWTable = None
OutputDWTableWriteMode = None
ReRunL1TransformFlag = None
DeltaName = None

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# # Parameters for Testing only, should be commented off
# L1TransformInstanceID = 1
# L1TransformID = 3
# IngestID = 3
# CustomParameters = None
# InputRawFileSystem = 'Files'
# InputRawFileFolder = 'raw-bronze/wwi/Sales/Orders/2013-01'
# InputRawFile = 'Sales_Orders_2013-01-01_000000.parquet'
# InputRawFileDelimiter = None
# InputFileHeaderFlag = 1
# OutputL1CurateFileSystem = None
# OutputL1CuratedFolder = None
# OutputL1CuratedFile = None
# OutputL1CuratedFileDelimiter = None
# OutputL1CuratedFileFormat = 'delta'
# OutputL1CuratedFileWriteMode = 'append'
# OutputDWStagingTable = None
# LookupColumns = 'OrderID'
# OutputDWTable = 'sales_orders'
# OutputDWTableWriteMode = 'append'
# ReRunL1TransformFlag = None
# DeltaName = "LastEditedWhen"

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## Read, cleanse and enrich raw/bronze data

# CELL ********************

df = readFile(InputRawFileSystem,InputRawFileFolder,InputRawFile)
ingestCount = df.count()

ct=CommonTransforms(df)

# Remove duplicates
if LookupColumns is not None:
    df=ct.deDuplicate(LookupColumns.split('|'))
else:
    df=ct.deDuplicate()

# Remove leading and trailing spaces from all string columns
df=ct.trim()

# # Replace Null Value with generic values
df = ct.replaceNull(0)
df = ct.replaceNull("NA")
df = ct.replaceNull("2020-01-01")

# # Add literal value columns for e.g SparkJobId
# audit={"WorkspaceName": mssparkutils.env.getWorkspaceName(), "SparkJobId":mssparkutils.env.getJobId(), "SparkPool" : mssparkutils.env.getPoolName(), "SparkClusterId" :mssparkutils.env.getClusterId()}
# df = ct.addLitCols(audit)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

display(df)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# # Load standardized/silver data

# CELL ********************

if OutputDWTableWriteMode == 'append' and LookupColumns is not None:
    output = upsertDelta(df,OutputDWTable,LookupColumns,DeltaName)
    numSourceRows = output["numSourceRows"]
    numTargetRowsInserted = output["numTargetRowsInserted"]
    numTargetRowsUpdated = output["numTargetRowsUpdated"]

else:
    output = insertDelta (df, OutputDWTable, OutputDWTableWriteMode)
    numSourceRows = ingestCount
    numTargetRowsInserted = output["numOutputRows"]
    numTargetRowsUpdated ="0"

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# # Return Values (to pipeline)

# CELL ********************

import json
mssparkutils.notebook.exit(json.dumps({
  "numSourceRows": numSourceRows,
  "numTargetRowsInserted": numTargetRowsInserted,
  "numTargetRowsUpdated": numTargetRowsUpdated
}))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
