use [Company]
go

-- Alter the Department table to include a calculated column based on the existing function.
Alter table dbo.Department ADD EmpCount AS ([dbo].[udf_EmployeesInDepartment](DNumber))

GO

IF OBJECT_ID ( 'dbo.usp_GetDepartment', 'P' ) IS NOT NULL   
    DROP PROCEDURE dbo.usp_GetDepartment;  
	GO
CREATE PROCEDURE usp_GetDepartment(
	@Dnumber INT
)
AS 
BEGIN
	SELECT *
	FROM [dbo].[Department]
	WHERE
		DNumber = @Dnumber
END
GO

IF OBJECT_ID ( 'dbo.usp_GetAllDepartments', 'P' ) IS NOT NULL   
    DROP PROCEDURE dbo.usp_GetAllDepartments;  
	GO

CREATE PROCEDURE usp_GetAllDepartments
AS
BEGIN
	SELECT *
	FROM [dbo].[Department]
END
