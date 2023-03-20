#Trigger invoke-sqlcmd
Invoke-Sqlcmd -ServerInstance
Write-Output "Please ignore the error above!"

#Navigate to the SQL ServerWindows PowerShell provider path for an instance of the SQL Database Engine.
#Set-Location "SQLSERVER:\SQL\$MyComputer\$MainInstance"
$db_Path = Read-Host -Prompt "Input your SQL ServerWindows PowerShell provider path for an instance of the SQL Database Engine (For example: 'LAPTOP-CJKK3IJV\TEST')"
Set-Location "SQLSERVER:\SQL\$db_Path"

#Define DB IP
$db_Ip = Read-Host -Prompt "Input your database IP"

#Define DB name
$db_Name = Read-Host -Prompt "Input your database name to run audit"

#Define path variable to export audit result
$result_Path = "C:\DB_Audit_$db_Ip.txt"

Write-Output "----------Audit Process is Starting---------------"
Write-Output "1.1 Ensure Latest SQL Server Service Packs and Hotfixes are Installed (Automated)" > $result_Path
Invoke-Sqlcmd -Query "SELECT SERVERPROPERTY('ProductLevel') as SP_installed, SERVERPROPERTY('ProductVersion') as Version;" >> $result_Path

Write-Output "1.2 Ensure Single-Function Member Servers are Used (Manual)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'clr enabled';" >> $result_Path

Write-Output "2.1 Ensure 'Ad Hoc Distributed Queries' Server Configuration Option is set to '0' (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'Ad Hoc Distributed Queries';" >> $result_Path

Write-Output "2.2 Ensure 'CLR Enabled' Server Configuration Option is set to '0' (Automated" >> $result_Path
Invoke-Sqlcmd -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'clr enabled';" >> $result_Path

Write-Output "2.3 Ensure 'Cross DB Ownership Chaining' Server Configuration Option is set to '0' (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'cross db ownership chaining';" >> $result_Path

Write-Output "2.4 Ensure 'Database Mail XPs' Server Configuration Option is set to '0' (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'Database Mail XPs';" >> $result_Path

Write-Output "2.5 Ensure 'Ole Automation Procedures' Server Configuration Option is set to '0' (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'Ole Automation Procedures';" >> $result_Path

Write-Output "2.6 Ensure 'Remote Access' Server Configuration Option is set to '0' (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'remote access';" >> $result_Path

Write-Output "2.7 Ensure 'Remote Admin Connections' Server Configuration Option is set to '0' (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "USE master; SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'remote admin connections' AND SERVERPROPERTY('IsClustered') = 0;" >> $result_Path

Write-Output "2.8 Ensure 'Scan For Startup Procs' Server Configuration Option is set to '0' (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'scan for startup procs';" >> $result_Path

Write-Output "2.9 Ensure 'Trustworthy' Database Property is set to 'Off' (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT name FROM sys.databases WHERE is_trustworthy_on = 1 AND name != 'msdb'" >> $result_Path

Write-Output "2.10 Ensure Unnecessary SQL Server Protocols are set to 'Disabled' (Manual)" >> $result_Path
#Invoke-Sqlcmd -Query "" >> $result_Path

Write-Output "2.11 Ensure SQL Server is configured to use non-standard ports (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "DECLARE @value nvarchar(256); EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\IPAll', N'TcpPort', @value OUTPUT, N'no_output'; SELECT @value AS TCP_Port WHERE @value = '1433';" >> $result_Path

Write-Output "2.12 Ensure 'Hide Instance' option is set to 'Yes' for Production SQL Server instances (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "DECLARE @getValue INT; EXEC master.sys.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib', @value_name = N'HideInstance', @value = @getValue OUTPUT; SELECT @getValue;" >> $result_Path

Write-Output "2.13 Ensure 'sa' Login Account is set to 'Disabled' (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT name, is_disabled FROM sys.server_principals WHERE sid = 0x01 AND is_disabled = 0;" >> $result_Path

Write-Output "2.14 Ensure 'sa' Login Account has been renamed (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT name FROM sys.server_principals WHERE sid = 0x01;" >> $result_Path

Write-Output "2.15 Ensure 'xp_cmdshell' Server Configuration Option is set to '0' (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'xp_cmdshell';" >> $result_Path

Write-Output "2.16 Ensure 'AUTO_CLOSE' is set to 'OFF' on contained databases (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT name, containment, containment_desc, is_auto_close_on FROM sys.databases WHERE containment <> 0 and is_auto_close_on = 1;" >> $result_Path

Write-Output "2.17 Ensure no login exists with the name 'sa' (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT principal_id, name FROM sys.server_principals WHERE name = 'sa';" >> $result_Path

Write-Output "3.1 Ensure 'Server Authentication' Property is set to 'Windows Authentication Mode' (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT SERVERPROPERTY('IsIntegratedSecurityOnly') as [login_mode];" >> $result_Path

Write-Output "3.2 Ensure CONNECT permissions on the 'guest user' is Revoked within all SQL Server databases excluding the master, msdb and tempdb (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "USE $db_Name; SELECT DB_NAME() AS DatabaseName, 'guest' AS Database_User, [permission_name], [state_desc] FROM sys.database_permissions WHERE [grantee_principal_id] = DATABASE_PRINCIPAL_ID('guest') AND [state_desc] LIKE 'GRANT%' AND [permission_name] = 'CONNECT' AND DB_NAME() NOT IN ('master','tempdb','msdb');" >> $result_Path

Write-Output "3.3 Ensure 'Orphaned Users' are Dropped From SQL Server Databases (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "USE $db_Name; EXEC sp_change_users_login @Action='Report';" >> $result_Path

Write-Output "3.4 Ensure SQL Authentication is not used in contained databases (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT name AS DBUser FROM sys.database_principals WHERE name NOT IN ('dbo','Information_Schema','sys','guest') AND type IN ('U','S','G') AND authentication_type = 2;" >> $result_Path

Write-Output "3.5 Ensure the SQL Server's MSSQL Service Account is Not an Administrator (Manual)" >> $result_Path
#Invoke-Sqlcmd -Query "" >> $result_Path

Write-Output "3.6 Ensure the SQL Server’s SQLAgent Service Account is Not an Administrator (Manual)" >> $result_Path
#Invoke-Sqlcmd -Query "" >> $result_Path

Write-Output "3.7 Ensure the SQL Server’s Full-Text Service Account is Not an Administrator (Manual)" >> $result_Path
#Invoke-Sqlcmd -Query "" >> $result_Path

Write-Output "3.8 Ensure only the default permissions specified by Microsoft are granted to the public server role (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT * FROM master.sys.server_permissions WHERE (grantee_principal_id = SUSER_SID(N'public') and state_desc LIKE 'GRANT%') AND NOT (state_desc = 'GRANT' and [permission_name] = 'VIEW ANY DATABASE' and class_desc = 'SERVER') AND NOT (state_desc = 'GRANT' and [permission_name] = 'CONNECT' and class_desc = 'ENDPOINT' and major_id = 2) AND NOT (state_desc = 'GRANT' and [permission_name] = 'CONNECT' and class_desc = 'ENDPOINT' and major_id = 3) AND NOT (state_desc = 'GRANT' and [permission_name] = 'CONNECT' and class_desc = 'ENDPOINT' and major_id = 4) AND NOT (state_desc = 'GRANT' and [permission_name] = 'CONNECT' and class_desc = 'ENDPOINT' and major_id = 5);" >> $result_Path

Write-Output "3.9 Ensure Windows BUILTIN groups are not SQL Logins (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT pr.[name], pe.[permission_name], pe.[state_desc] FROM sys.server_principals pr JOIN sys.server_permissions pe ON pr.principal_id = pe.grantee_principal_id WHERE pr.name like 'BUILTIN%';" >> $result_Path

Write-Output "3.10 Ensure Windows local groups are not SQL Logins (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "USE [master]; SELECT pr.[name] AS LocalGroupName, pe.[permission_name], pe.[state_desc] FROM sys.server_principals pr JOIN sys.server_permissions pe ON pr.[principal_id] = pe.[grantee_principal_id] WHERE pr.[type_desc] = 'WINDOWS_GROUP' AND pr.[name] like CAST(SERVERPROPERTY('MachineName') AS nvarchar) + '%';" >> $result_Path

Write-Output "3.11 Ensure the public role in the msdb database is not granted access to SQL Agent proxies (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "USE [msdb]; SELECT sp.name AS proxyname FROM dbo.sysproxylogin spl JOIN sys.database_principals dp ON dp.sid = spl.sid JOIN sysproxies sp ON sp.proxy_id = spl.proxy_id WHERE principal_id = USER_ID('public');" >> $result_Path

Write-Output "4.1 Ensure 'MUST_CHANGE' Option is set to 'ON' for All SQL Authenticated Logins (Manual)" >> $result_Path
#Invoke-Sqlcmd -Query "" >> $result_Path

Write-Output "4.2 Ensure 'CHECK_EXPIRATION' Option is set to 'ON' for All SQL Authenticated Logins Within the Sysadmin Role (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT l.[name], 'sysadmin membership' AS 'Access_Method' FROM sys.sql_logins AS l WHERE IS_SRVROLEMEMBER('sysadmin',name) = 1 AND l.is_expiration_checked <> 1 UNION ALL SELECT l.[name], 'CONTROL SERVER' AS 'Access_Method' FROM sys.sql_logins AS l JOIN sys.server_permissions AS p ON l.principal_id = p.grantee_principal_id WHERE p.type = 'CL' AND p.state IN ('G', 'W') AND l.is_expiration_checked <> 1;" >> $result_Path

Write-Output "4.3 Ensure 'CHECK_POLICY' Option is set to 'ON' for All SQL Authenticated Logins (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT name, is_disabled FROM sys.sql_logins WHERE is_policy_checked = 0;" >> $result_Path

Write-Output "5.1 Ensure 'Maximum number of error log files' is set to greater than or equal to '12' (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "DECLARE @NumErrorLogs int; EXEC master.sys.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'NumErrorLogs', @NumErrorLogs OUTPUT; SELECT ISNULL(@NumErrorLogs, -1) AS [NumberOfLogFiles];" >> $result_Path

Write-Output "5.2 Ensure 'Default Trace Enabled' Server Configuration Option is set to '1' (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'default trace enabled';" >> $result_Path

Write-Output "5.3 Ensure 'Login Auditing' is set to 'failed logins' (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "EXEC xp_loginconfig 'audit level';" >> $result_Path

Write-Output "5.4 Ensure 'SQL Server Audit' is set to capture both 'failed' and 'successful logins' (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT S.name AS 'Audit Name' , CASE S.is_state_enabled WHEN 1 THEN 'Y' WHEN 0 THEN 'N' END AS 'Audit Enabled' , S.type_desc AS 'Write Location' , SA.name AS 'Audit Specification Name' , CASE SA.is_state_enabled WHEN 1 THEN 'Y' WHEN 0 THEN 'N' END AS 'Audit Specification Enabled' , SAD.audit_action_name , SAD.audited_result FROM sys.server_audit_specification_details AS SAD JOIN sys.server_audit_specifications AS SA ON SAD.server_specification_id = SA.server_specification_id JOIN sys.server_audits AS S ON SA.audit_guid = S.audit_guid WHERE SAD.audit_action_id IN ('CNAU', 'LGFL', 'LGSD');" >> $result_Path

Write-Output "6.1 Ensure Database and Application User Input is Sanitized (Manual)" >> $result_Path
#Invoke-Sqlcmd -Query "" >> $result_Path

Write-Output "6.2 Ensure 'CLR Assembly Permission Set' is set to 'SAFE_ACCESS' for All CLR Assemblies (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "SELECT name, permission_set_desc FROM sys.assemblies WHERE is_user_defined = 1;" >> $result_Path

Write-Output "7.1 Ensure 'Symmetric Key encryption algorithm' is set to 'AES_128' or higher in non-system databases (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "USE $db_Name; SELECT db_name() AS Database_Name, name AS Key_Name FROM sys.symmetric_keys WHERE algorithm_desc NOT IN ('AES_128','AES_192','AES_256') AND db_id() > 4;" >> $result_Path

Write-Output "7.2 Ensure Asymmetric Key Size is set to 'greater than or equal to 2048' in non-system databases (Automated)" >> $result_Path
Invoke-Sqlcmd -Query "USE $db_Name; SELECT db_name() AS Database_Name, name AS Key_Name FROM sys.asymmetric_keys WHERE key_length < 2048 AND db_id() > 4;" >> $result_Path

Write-Output "8.1 Ensure 'SQL Server Browser Service' is configured correctly (Manual)" >> $result_Path
#Invoke-Sqlcmd -Query "" >> $result_Path

#Write-Output "" >> $result_Path
#Invoke-Sqlcmd -Query "" >> $result_Path

Write-Output "----------Audit Process is Finished---------------"

Write-Output "The audit result is exported to the following path: 'C:\DB_Audit_$db_Ip.txt'"