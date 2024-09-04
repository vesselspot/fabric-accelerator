ALTER TABLE [ELT].[L2TransformDefinition]
	ADD CONSTRAINT [DC_L2TransformDefinition_CreatedTimestamp]
	DEFAULT CONVERT(datetime2,CONVERT(datetimeoffset, getdate()) at time zone 'AUS Eastern Standard Time')
	FOR [CreatedTimestamp]
