
--UDF

--Function for counting the number of emplpyees in a department, based off supplied department id
GO
CREATE FUNCTION udf_EmployeesInDepartment(@DNumber INT)
	RETURNS INT
	AS
	BEGIN
	    DECLARE @returnvalue INT;

		SELECT @returnvalue = COUNT(*) 
		FROM dbo.Employee
		WHERE
			Dno = @DNumber

		RETURN(@returnvalue);
	END

GO

--Function for checking if a department with a given name already exists in the database
CREATE FUNCTION udf_DepartmentNameExists(@DName VARCHAR(50))
	RETURNS BIT
	AS
	BEGIN
		IF EXISTS(SELECT * FROM [dbo].[Department] WHERE DName = @DName)
			RETURN 1;
		ELSE
			RETURN 0;
		
		RETURN 0;
	END

-- STORED PROCEDURES
GO
CREATE PROCEDURE usp_CreateDepartment(
	@DName VARCHAR(50),
	@MgrSSN NUMERIC(9,0),
	@DNumber INT OUTPUT
)
AS
BEGIN
	BEGIN TRANSACTION
	DECLARE @err_message nvarchar(255)
	
	IF (dbo.udf_DepartmentNameExists(@DName) = 1)
	BEGIN
		SET @err_message = 'A department with the name already exists';
		THROW 50000, @err_message , 1	
	END

	IF (SELECT COUNT(DNumber) FROM dbo.Department WHERE MgrSSN = @MgrSSN ) != 0
	BEGIN
		SET @err_message = 'Supplied manager SSN is already reigstred on another department';
		THROW 50000, @err_message , 1
	END
	
	SELECT @DNumber = coalesce((SELECT max(DNumber) + 1 FROM dbo.Department), 1)
    
	COMMIT      
	INSERT INTO [dbo].[Department]
		([DName],[DNumber],[MgrSSN],[MgrStartDate])
		VALUES
			(@DName, @DNumber, @MgrSSN, GETDATE())
	
END

GO
CREATE PROCEDURE usp_UpdateDepartmentName(
	@DNumber INT,
	@DName VARCHAR(50)
)
AS
BEGIN
	BEGIN TRANSACTION
	DECLARE @err_message nvarchar(255)
	
	IF (dbo.udf_DepartmentNameExists(@DName) = 1)
	BEGIN
		SET @err_message = 'A department with the name already exists';
		THROW 50000, @err_message , 1	
	END

	UPDATE [dbo].[Department]
	SET 
		[DName] = @DName
	WHERE
		DNumber = @DNumber
END

GO
CREATE PROCEDURE usp_UpdateDepartmentManager(
	@DNumber INT,
	@MgrSSN NUMERIC(9,0)
)
AS
BEGIN
	IF(SELECT COUNT(DNumber) FROM dbo.Department WHERE MgrSSN = @MgrSSN) = 0
	BEGIN
		UPDATE [dbo].[Department]
		SET 
			MgrSSN = @MgrSSN, 
			MgrStartDate = GETDATE()
		WHERE
			DNumber = @DNumber

		UPDATE [dbo].[Employee]
		SET
			SuperSSN = @MgrSSN
		WHERE
			SSN !=  @MgrSSN
			AND Dno = @DNumber
	END
END

GO
CREATE PROCEDURE usp_DeleteDepartment(
	@Dnumber INT
)
AS
BEGIN
	IF(SELECT COUNT(Dnumber) FROM [dbo].[Department] WHERE DNumber = @Dnumber) > 0
	BEGIN
		BEGIN TRANSACTION
			COMMIT
			UPDATE [dbo].[Employee]
			SET
				Dno = NULL
			WHERE
				Dno = @Dnumber
		
			DELETE FROM [dbo].[Works_on]
			WHERE
				Pno IN (SELECT PNumber FROM [dbo].[Project]
					WHERE
						DNum = @Dnumber)

			DELETE FROM [dbo].[Project]
			WHERE
				DNum = @Dnumber
			
			DELETE FROM [dbo].[Dept_Locations]
			WHERE
				DNUmber = @Dnumber

			DELETE FROM [dbo].[Department]
			WHERE
				DNumber = @Dnumber
	END
END

GO
CREATE PROCEDURE usp_GetDepartment(
	@Dnumber INT
)
AS 
BEGIN
	SELECT *, dbo.udf_EmployeesInDepartment(@Dnumber) AS NumberOfEmployees 
	FROM [dbo].[Department]
	WHERE
		DNumber = @Dnumber
END

GO
CREATE PROCEDURE usp_GetAllDepartments
AS
BEGIN
	SELECT *, dbo.udf_EmployeesInDepartment(DNumber) AS NumberOfEmployees 
	FROM [dbo].[Department]
END