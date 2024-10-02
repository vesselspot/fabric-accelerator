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

%run /DeltaLakeFunctions

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ### Iterate through all tables in lakehouse and run OPTIMIZE and VACCUM commands

# CELL ********************

df = spark.sql("show tables from ba_wwi_lakehouse")
tableList = df.select("tableName").rdd.flatMap(lambda x:x).collect()
# print (tables)
for table in tableList:
    optimizeDelta(table)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
