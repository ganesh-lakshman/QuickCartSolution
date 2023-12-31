﻿-- create tables
CREATE TABLE CardDetails (
	CardNumber NUMERIC(16) PRIMARY KEY NOT NULL,
	NameOnCard VARCHAR(40) NOT NULL,
	CardType CHAR(6) NOT NULL CHECK (CardType IN ('V', 'M','A')),
	CVVNumber NUMERIC(3) NOT NULL,
	ExpiryDate DATE NOT NULL CHECK (ExpiryDate>=GETDATE()),
	Balance DECIMAL(10,2) CHECK (Balance>=0)
);

INSERT INTO CardDetails (CardNumber, NameOnCard, CardType, CVVNumber, ExpiryDate, Balance) 
VALUES (1146665296881890,'Manuel','M',137,'2025-03-18',7282.00), (1164283045453550,'Renate Messner','V ',133,'2028-01-08',14538.0);



CREATE TABLE Categories (
	CategoryId TINYINT IDENTITY PRIMARY KEY,
	CategoryName VARCHAR(20) UNIQUE NOT NULL
);


INSERT INTO Categories VALUES ('Motors')
INSERT INTO Categories VALUES ('Fashion')
SELECT * FROM Categories


CREATE TABLE Products
(
    ProductID CHAR(4) NOT NULL PRIMARY KEY,
    ProductName VARCHAR(20) NOT NULL UNIQUE,
    CategoryId TINYINT,
    Price NUMERIC(8) NOT NULL,
    QuantityAvailable INT NOT NULL,
    CONSTRAINT chk_ProductId CHECK (ProductId LIKE 'P%'),
    CONSTRAINT chk_Price CHECK (Price > 0),
    CONSTRAINT chk_QuantityAvailable CHECK (QuantityAvailable >= 0),
	CONSTRAINT fk_products_categories FOREIGN KEY(CategoryId) REFERENCES Categories(CategoryId)
);

CREATE TABLE Roles(
	RoleId TINYINT IDENTITY NOT NULL PRIMARY KEY,
	RoleName VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE Users(
	EmailId VARCHAR(50) NOT NULL PRIMARY KEY,
	UserPassword VARCHAR(15) NOT NULL,
	RoleId TINYINT,
	Gender CHAR(1) NOT NULL,
	DateOfBirth DATE NOT NULL,
	[Address] VARCHAR(200) NOT NULL,
	CONSTRAINT chk_Gender CHECK (Gender in ('M', 'F')),
	CONSTRAINT chk_DateOfBirth CHECK (DateOfBirth<GETDATE()),
	CONSTRAINT fk_RoleId FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)
);

create table PurchaseDetails(
	PurchaseId bigint identity(1000,1) primary key not null,
	EmailId varchar(50),
	ProductId char(4),
	QuantityPurchased smallint not null,
	DateOfPurchase smalldatetime not null,

	constraint fk_purchasedetails_users foreign key(EmailId) references Users(EmailId),
	constraint fk_purchasedetails_products foreign key(ProductId) references Products(ProductId),
	constraint chk_quantitypurchase check(QuantityPurchased>0),
	constraint chk_dateofpurchase check(DateOfPurchase<=GETDATE()),
);



-- proc 1
go
create or alter proc usp_RegisterUser
(
@UserPassword varchar(15),
@Gender char(1),
@EmailId varchar(50),
@DateOfBirth date,
@Address varchar(200)
)
as
begin
	begin try
		if(len(@EmailId) < 4 or len(@EmailId) > 50 or @EmailId is null)
		begin
			return -1
		end
		if(len(@UserPassword) < 8 or len(@UserPassword) > 15 or @UserPassword is null)
		begin
			return -2
		end
		if(@Gender not in ('M', 'F') or @Gender is null)
		begin
			return -3
		end
		if(@DateOfBirth is null or @DateOfBirth >= GETDATE())
		begin
			return -4
		end
		if(@Address is null)
		begin
			return -6
		end
		
		insert into Users values(@EmailId,@UserPassword,null,@Gender,@DateOfBirth,@Address);
		return 1
	end try
	begin catch
		select ERROR_MESSAGE()
		return -99
	end catch
end

-- proc 2
go 
create or alter PROCEDURE [dbo].[usp_AddCategory]

(

@CategoryName VARCHAR(20),

@CategoryId TINYINT OUT

)

AS

BEGIN

DECLARE @ReturnValue INT

BEGIN TRY

IF (@CategoryName IS NULL)

BEGIN

SET @ReturnValue = -1

RETURN @ReturnValue

END

IF EXISTS(SELECT CategoryName FROM Categories WHERE CategoryName=@CategoryName)

BEGIN

SET @ReturnValue = -2

RETURN @ReturnValue

END

INSERT INTO Categories VALUES (@CategoryName)

SET @CategoryId = IDENT_CURRENT('Categories')

SET @ReturnValue = 1

RETURN @ReturnValue

END TRY

BEGIN CATCH

SET @ReturnValue = -99

RETURN @ReturnValue

END CATCH

END

-- proc 3
GO

create proc usp_InsertPurchaseDetails(
@EmailID varchar(50),
@CardNumber numeric(16),
@ProductID char(4),
@QuantityPurchased int,
@PurchaseId bigint out
)
as
begin
	declare @price numeric(8), @amount numeric(8), @balance numeric(8)
	begin try
		if not exists(select * from Products where ProductID=@ProductID)
		begin
			return -1
		end

		if not exists(select * from Users where EmailId=@EmailID)
			begin
				return -2
			end
		if(@QuantityPurchased <= 0)
			begin
				return -3
			end
		if not exists(select * from CardDetails where CardNumber=@CardNumber)
			begin
				return -4
			end
		select @price=price from Products where ProductID=@ProductID
		select @balance=@balance from CardDetails where CardNumber=@CardNumber
		select @amount=@price*@QuantityPurchased
		if(@balance>=@amount)
			begin
				update CardDetails set Balance=Balance-@amount where CardNumber=@CardNumber
				insert into PurchaseDetails values (@EmailID, @ProductID, @QuantityPurchased, '2023-06-10')
				update Products set QuantityAvailable=QuantityAvailable-@QuantityPurchased where ProductID=@ProductID

				set @PurchaseId=IDENT_CURRENT('PurchaseDetails')
				return 1
			end
		else
			begin
				return -5
			end

	end try
	begin catch
		select ERROR_MESSAGE()
		return -99
	end catch
end

select * from Products
declare @purchaseId int, @result int

exec usp_InsertPurchaseDetails 'Albert@gmail.com', 1146665296881890, 'P157', 2, @ProductId out
select @result as result, @PurchaseId as OutputParameter

--proc 4
go
create or alter proc usp_AddProduct
(
@ProductID CHAR(4),
@ProductName VARCHAR(20),
@CategoryID TINYINT,
@Price NUMERIC(8),
@QuantityAvailable INT
)
as
begin
	begin try
		if(@ProductID = null)
			begin
				return -1
			end
		if(len(@ProductID) < 4 or not (@ProductID like 'P%'))
			begin
				return -2
			end
		if(@ProductName = null)
			begin
				return -3
			end
		if(@CategoryID = null)
			begin
				return -4
			end
		if(not exists(select * from Categories where CategoryID=@CategoryID))
			begin
				return -5
			end
		if(@Price <= 0 or @Price = null)
			begin
				return -6
			end
		if(@QuantityAvailable <= 0 or @QuantityAvailable = null)
			begin
				return -7
			end
		begin
			INSERT INTO Products VALUES (@ProductId, @ProductName, @CategoryId, @Price, @QuantityAvailable);
			return 1
		end
	end try
	begin catch
		return -99
	end catch
end

go

 

declare @result int, @ProductId char(4), @ProductName varchar(20), @CategoryId tinyint, @Price Numeric(8), @QuantityAvailable int
set @ProductId = 'P103'
set @ProductName = 'Product 3'
set @CategoryId = 1
set @Price = 800
set @QuantityAvailable = 6

 

exec @result = usp_AddProduct @ProductId, @ProductName, @CategoryId, @Price, @QuantityAvailable
select @result

--select * from Products;

--select * from Categories;

--proc 5

go
create or alter proc usp_InsertPurchaseDetails(
@EmailID varchar(50),
@ProductID char(4),
@QuantityPurchased int,
@PurchaseId bigint out
)
as
begin
	
	begin try
		if(@EmailID is null)
			begin
				return -1
			end
		if(not exists(select * from Users where EmailId = @EmailId))
			begin
				return -2
			end
		if(@ProductID is null)
			begin
				return -3
			end
		if not exists(select * from Products where ProductID=@ProductID)
			begin
				return -4
			end
		if(@QuantityPurchased > (select QuantityAvailable from Products where ProductID = @ProductID) or @QuantityPurchased = null or @QuantityPurchased = 0)
			begin
				return -5
			end
		
		insert into PurchaseDetails values (@EmailID, @ProductID, @QuantityPurchased, '2023-06-1')
		update Products set QuantityAvailable=QuantityAvailable-@QuantityPurchased where ProductID=@ProductID

		set @PurchaseId=IDENT_CURRENT('PurchaseDetails')
		return 1
	end try
	begin catch
		select ERROR_MESSAGE()
		return -99
	end catch
end
select * from Products
select * from PurchaseDetails
declare @PurchaseId bigint, @result int

exec @result = usp_InsertPurchaseDetails 'Albert@gmail.com', 'P157', 10, @PurchaseId out
select @result as result, @PurchaseId as OutputParameter



--proc 6
go
create proc usp_UpdatePrice
(
@ProductId char(4),
@Price numeric(8),
@UpdatedPrice int out
)
as
begin
	declare @prevPrice int;
	begin try
		if(@ProductId = null or not exists(select * from Products where ProductID=@ProductId) or @Price <= 0)
			begin
				return -1
			end
		BEGIN TRANSACTION
			set @prevPrice = (select Price from Products where ProductID=@ProductId);
			update Products set Price = @Price where ProductID=@ProductId;
			if((select Price from Products where ProductID=@ProductId) = @prevPrice)
				begin
					set @UpdatedPrice = 0;
					rollback;
				end
		COMMIT

	end try
	begin catch
		
		set @UpdatedPrice = 0;
		rollback;
	end catch
end

go
-- ufn1
create or alter function ufn_CheckEmailId(@EmailId VARCHAR(50))
returns BIT
as
begin
	if not exists(select * from Users where EmailId=@EmailId)
		begin
			return 0;
		end
	return 1;
end
go
select * from Users;

select [dbo].ufn_CheckEmailId('Anzio_Don@infosys.com');




--ufn 2
go
create function ufn_ValidateUserCredentials(@EmailId varchar(50), @UserPassword VARCHAR(15))
returns INT
as
begin
	declare @RoleId int;
	if (not exists(select * from Users where EmailId=@EmailId and UserPassword=@UserPassword))
		return -1;
	else
		set @RoleId = (select RoleId from Users where EmailId=@EmailId and UserPassword=@UserPassword);
	return @RoleId;
end
go
select * from Users;
select dbo.ufn_ValidateUserCredentials('Albert@gmail.com', 'LILAS@1234');






-- Insertion scripts for Roles
SET IDENTITY_INSERT Roles ON
INSERT INTO Roles (RoleId, RoleName) VALUES (1, 'Admin')
INSERT INTO Roles (RoleId, RoleName) VALUES (2, 'Customer')
SET IDENTITY_INSERT Roles OFF
GO

--insertion scripts for Users
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Franken@gmail.com','BSBEV@1234',2,'F','1976-08-26','Fauntleroy Circus')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Henriot@gmail.com','CACTU@1234',2,'F','1971-09-04','Cerrito 333')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Hernadez@gmail.com','CHOPS@1234',2,'M','1981-09-18','Hauptstr. 29')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Jablonski@gmail.com','COMMI@1234',2,'M','1989-07-21','Av. dos LusÃ­adas, 23')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Josephs@gmail.com','CONSH@1234',2,'F','1963-11-09','Berkeley Gardens 12  Brewery')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Anzio_Don@infosys.com','don@123',1,'M','1991-02-24','Surya Bakery, Mysore;Surya Bakery, Mysore-570001')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Karttunen@gmail.com','DRACD@1234',2,'M','1963-06-27','Walserweg 21')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Koskitalo@gmail.com','DUMON@1234',2,'F','1966-01-28','67, rue des Cinquante Otages')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Labrune@gmail.com','EASTC@1234',2,'F','1980-02-09','35 King George')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Mathew_Edmar@infosys.com','Divine@456',2,'M','1989-09-12','Saibaba colony, Coimbatore')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Larsson@gmail.com','ERNSH@1234',2,'M','1988-04-08','Kirchgasse 6')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Latimer@gmail.com','FAMIA@1234',2,'M','1964-10-08','Rua OrÃ³s, 92')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Lebihan@gmail.com','FISSA@1234',2,'M','1968-03-22','C/ Moralzarzal, 86')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Lincoln@gmail.com','FOLIG@1234',2,'M','1971-01-27','184, chaussÃ©e de Tournai')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('McKenna@gmail.com','FOLKO@1234',2,'F','1979-08-30','Ã…kergatan 24')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Mendel@gmail.com','FRANK@1234',2,'M','1964-07-08','Berliner Platz 43')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Muller@gmail.com','FRANR@1234',2,'F','1965-05-22','54, rue Royale')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Nagy@gmail.com','FRANS@1234',2,'F','1978-02-05','Via Monte Bianco 34')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Rourke@gmail.com','FURIB@1234',2,'F','1967-10-24','Jardim das rosas n. 32')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Ottlieb@gmail.com','GALED@1234',2,'F','1960-05-26','Rambla de CataluÃ±a, 23')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Paolino@gmail.com','GODOS@1234',2,'M','1961-08-29','C/ Romero, 33')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Parente@gmail.com','GOURL@1234',2,'F','1963-04-25','Av. Brasil, 442')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Pontes@gmail.com','GROSR@1234',2,'M','1962-09-29','5Âª Ave. Los Palos Grandes')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Rance@gmail.com','HANAR@1234',2,'M','1986-04-30','Rua do PaÃ§o, 67')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Roel@gmail.com','HILAA@1234',2,'M','1983-12-28','Carrera 22 con Ave. Carlos Soublette #8-35')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Roulet@gmail.com','HUNGC@1234',2,'M','1981-04-14','City Center Plaza 516 Main St.')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Saveley@gmail.com','HUNGO@1234',2,'F','1970-11-07','8 Johnstown Road')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Schmitt@gmail.com','ISLAT@1234',2,'F','1974-09-19','Garden House Crowther Way')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Rine_Jamwal@infosys.com','spacejet',2,'F','1991-07-20','R S Puram, Coimbatore')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Smith@gmail.com','KOENE@1234',2,'M','1985-05-08','Maubelstr. 90')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Snyder@gmail.com','LACOR@1234',2,'M','1985-11-03','67, avenue de l Europe')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Sommer@gmail.com','LAMAI@1234',2,'F','1968-09-08','1 rue Alsace-Lorraine')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Thomas@gmail.com','LAUGB@1234',2,'M','1986-11-15','1900 Oak St.')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Tonini@gmail.com','LAZYK@1234',2,'M','1988-11-11','12 Orchestra Terrace')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Mess@gmail.com','LEHMS@1234',2,'F','1964-07-30','Magazinweg 7')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Jai@gmail.com','LETSS@1234',2,'F','1971-01-21','87 Polk St. Suite 5')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Albert@gmail.com','LILAS@1234',2,'M','1963-12-23','Carrera 52 con Ave. BolÃ­var #65-98 Llano Largo')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Paolo@gmail.com','LINOD@1234',2,'M','1985-09-18','Ave. 5 de Mayo Porlamar')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Pedro@gmail.com','LONEP@1234',2,'F','1981-03-18','89 Chiaroscuro Rd.')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Victoria@gmail.com','MAGAA@1234',2,'M','1987-01-09','Via Ludovico il Moro 22')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Helen@gmail.com','MAISD@1234',2,'F','1968-06-28','Rue Joseph-Bens 532')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Lesley@gmail.com','MEREP@1234',2,'F','1982-12-23','43 rue St. Laurent')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Francisco@gmail.com','MORGK@1234',2,'M','1963-02-23','Heerstr. 22')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Sanio_Neeba@infosys.com','AllIsGood',2,'F','1990-06-13','Ramnagar, Coimbatore')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Philip@gmail.com','NORTS@1234',2,'M','1987-03-04','South House 300 Queensbridge')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Aria@gmail.com','OCEAN@1234',2,'M','1965-06-27','Ing. Gustavo Moncada 8585 Piso 20-A')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Ann@gmail.com','OLDWO@1234',2,'F','1981-03-21','2743 Bering St.')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Anabela@gmail.com','OTTIK@1234',2,'F','1985-11-23','Mehrheimerstr. 369')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Peter@gmail.com','PARIS@1234',2,'F','1981-11-13','265, boulevard Charonne')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Paul@gmail.com','PERIC@1234',2,'M','1987-05-17','Calle Dr. Jorge Cash 321')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Carlos@gmail.com','PICCO@1234',2,'M','1969-02-08','Geislweg 14')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Palle@gmail.com','PRINI@1234',2,'F','1961-03-29','Estrada da saÃºde n. 58')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Karla@gmail.com','QUEDE@1234',2,'M','1968-04-28','Rua da Panificadora, 12')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Karin@gmail.com','QUEEN@1234',2,'F','1989-12-18','Alameda dos CanÃ rios, 891')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Matti@gmail.com','QUICK@1234',2,'M','1982-09-18','TaucherstraÃŸe 10')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Pirkko@gmail.com','RANCH@1234',2,'M','1983-09-24','Av. del Libertador 900')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Janine@gmail.com','RATTC@1234',2,'F','1964-12-12','2817 Milton Dr.')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Maria@gmail.com','REGGC@1234',2,'M','1980-04-11','Strada Provinciale 124')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Yoshi@gmail.com','RICAR@1234',2,'F','1961-08-28','Av. Copacabana, 267')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Laurence@gmail.com','RICSU@1234',2,'M','1985-05-26','Grenzacherweg 237')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('MeetRoda@yahoo.co.in','ChristaRocks',1,'M','1990-04-20','Choultry Circle, Mysore')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Elizabeth@gmail.com','ROMEY@1234',2,'F','1975-04-26','Gran VÃ­a, 1')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Patricia@gmail.com','SANTG@1234',2,'F','1968-10-16','Erling Skakkes gate 78')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Roland@gmail.com','SAVEA@1234',2,'F','1980-01-04','187 Suffolk Ln.')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Rita@gmail.com','SEVES@1234',2,'M','1972-06-15','90 Wadhurst Rd.')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Helvetius@gmail.com','SIMOB@1234',2,'F','1978-03-09','VinbÃ¦ltet 34')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Timothy@gmail.com','SPECD@1234',2,'M','1964-09-28','25, rue Lauriston')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Sven@gmail.com','SPLIR@1234',2,'F','1967-12-12','P.O. Box 555')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('SamRocks@gmail.com','samsuji123!',2,'M','1991-06-15','Shankranti Circle, Mysore')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Miguel@gmail.com','SUPRD@1234',2,'F','1971-10-09','Boulevard Tirou, 255')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Paula@gmail.com','THEBI@1234',2,'M','1980-08-05','89 Jefferson Way Suite 2')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Manuel@gmail.com','THECR@1234',2,'M','1988-10-15','55 Grizzly Peak Rd.')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Mariaa@gmail.com','TOMSP@1234',2,'F','1987-11-29','Luisenstr. 48')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Martine@gmail.com','TORTU@1234',2,'M','1985-05-08','Avda. Azteca 123')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Diego@gmail.com','TRADH@1234',2,'F','1983-02-16','Av. InÃªs de Castro, 414')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Annette@gmail.com','TRAIH@1234',2,'M','1981-05-03','722 DaVinci Blvd.')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Mary@gmail.com','VAFFE@1234',2,'F','1977-10-09','Smagsloget 45')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Carine@gmail.com','VICTE@1234',2,'F','1982-12-27','2, rue du Commerce')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Margaret@gmail.com','VINET@1234',2,'M','1979-08-16','59 rue de l Abbaye')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Howard@gmail.com','WANDK@1234',2,'F','1982-06-02','Adenauerallee 900')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Martin@gmail.com','WARTH@1234',2,'M','1989-12-15','Torikatu 38')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Gary@gmail.com','WELLI@1234',2,'F','1968-12-27','Rua do Mercado, 12')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Daniel@gmail.com','WHITC@1234',2,'M','1978-05-22','305 - 14th Ave. S. Suite 3B')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('mat@gmail.com','WILMK@1234',2,'M','1977-01-13','Keskuskatu 45')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Davis@gmail.com','WOLZA@1234',2,'M','1982-01-09','ul. Filtrowa 68')

-- insertion script for Categories
SET IDENTITY_INSERT Categories ON
INSERT INTO Categories (CategoryId, CategoryName) VALUES (1, 'Motors')
INSERT INTO Categories (CategoryId, CategoryName) VALUES (2, 'Fashion')
INSERT INTO Categories (CategoryId, CategoryName) VALUES (3, 'Electronics')
INSERT INTO Categories (CategoryId, CategoryName) VALUES (4, 'Arts')
INSERT INTO Categories (CategoryId, CategoryName) VALUES (5, 'Home')
INSERT INTO Categories (CategoryId, CategoryName) VALUES (6, 'Sporting Goods')
INSERT INTO Categories (CategoryId, CategoryName) VALUES (7, 'Toys')
SET IDENTITY_INSERT Categories OFF

GO
-- insertion script for Productss
-- insertion script for Categories

select * from Categories
delete from Categories
SET IDENTITY_INSERT Categories ON
INSERT INTO Categories (CategoryId, CategoryName) VALUES (1, 'Motors')
INSERT INTO Categories (CategoryId, CategoryName) VALUES (2, 'Fashion')
INSERT INTO Categories (CategoryId, CategoryName) VALUES (3, 'Electronics')
INSERT INTO Categories (CategoryId, CategoryName) VALUES (4, 'Arts')
INSERT INTO Categories (CategoryId, CategoryName) VALUES (5, 'Home')
INSERT INTO Categories (CategoryId, CategoryName) VALUES (6, 'Sporting Goods')
INSERT INTO Categories (CategoryId, CategoryName) VALUES (7, 'Toys')
SET IDENTITY_INSERT Categories OFF

GO
-- insertion script for Products
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P101','Lamborghini Gallardo Spyder',1,18000000.00,10)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P102','BMW X1',1,3390000.00,10)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P103','BMW Z4',1,6890000.00,10)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P104','Harley Davidson Iron 883 ',1,700000.00,10)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P105','Ducati Multistrada',1,2256000.00,10)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P106','Honda CBR 250R',1,193000.00,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P107','Kenneth Cole Black & White Leather Reversible Belt',2,2500.00,50)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P108','Classic Brooks Brothers 346 Wool Black Sport Coat',2,3078.63,10)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P109','Ben Sherman Mens Necktie Silk Tie',2,1847.18,20)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P110','BRIONI Shirt Cotton NWT Medium',2,2050.00,25)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P111','Patagonia NWT mens XL Nine Trails Vest',2,2299.99,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P112','Blue Aster Blue Ivory Rugby Pack Shoes',2,6772.37,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P113','Ann Taylor 100% Cashmere Turtleneck Sweater',2,3045.44,80)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P114','Fashion New Slim Ladies Womens Suit Coat',2,2159.59,65)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P115','Apple IPhone 5s 16GB',3,52750.00,70)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P116','Samsung Galaxy S4',3,38799.99,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P117','Nokia Lumia 1320',3,42199.00,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P118','LG Nexus 5',3,32649.54,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P119','Moto DroidX',3,32156.45,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P120','Apple MAcbook Pro',3,56800.00,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P121','Dell Inspiron',3,36789.00,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P122','IPad Air',3,28000.00,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P123','Xbox 360 with kinect',3,25000.00,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P124','Abstract Hand painted Oil Painting on Canvas',4,2056.00,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P125','Mysore Painting of Lord Shiva',4,5000.00,10)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P126','Tanjore Painting of Ganesha',4,8000.00,20)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P127','Marble Elephants statue',4,9056.00,50)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P128','Wooden photo frame',4,150.00,200)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P129','Gold plated dancing peacock',4,350.00,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P130','Kundan jewellery set',4,2000.00,30)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P131','Marble chess board','4','3000.00','20')
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P132','German Folk Art Wood Carvings Shy Boy and Girl',4,6122.20,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P133','Modern Abstract Metal Art Wall Sculpture',5,5494.55,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P134','Bean Bag Chair Love Seat',5,5754.55,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P135','Scented rose candles',5,200.00,50)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P136','Digital bell chime',5,800.00,10)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P137','Curtains',5,600.00,20)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P138','Wall stickers',5,200.00,30)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P139','Shades of Blue Line-by-Line Quilt',5,691.24,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P140','Tahoe Gear Prescott 10 Person Family Cabin Tent',6,9844.33,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P141','Turner Sultan 29er Large',6,147612.60,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P142','BAMBOO BACKED HICKORY LONGBOW ',6,5291.66,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P143','Adidas Shoes',6,700.00,150)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P144','Tennis racket',6,200.00,150)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P145','Baseball glove',6,150.00,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P146','Door gym',6,700.00,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P147','Cricket bowling machine',6,3000.00,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P148','ROLLER DERBY SKATES',6,3079.99,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P149','Metal 3.5-Channel RC Helicopter',7,2458.20,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P150','Ned Butterfly Style Yo Yo',7,553.23,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P151','Baby Einstein Hand Puppets',7,1229.41,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P152','fire godzilla toy',7,614.09,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P153','Remote car',7,1000.00,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P154','Barbie doll set',7,500.00,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P155','Teddy bear',7,300.00,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P156','Clever sticks',7,400.00,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P157','See and Say',7,200.00,50)

GO

--insertion scripts for PurchaseDetails
SET IDENTITY_INSERT PurchaseDetails ON
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1001,'Franken@gmail.com','P101',2,'Jan 12 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1002,'Franken@gmail.com','P143',1,'Jan 13 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1003,'Franken@gmail.com','P112',3,'Jan 14 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1004,'Franken@gmail.com','P148',2,'Jan 15 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1005,'Franken@gmail.com','P150',1,'Jan 16 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1006,'Franken@gmail.com','P134',3,'Jan 16 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1007,'SamRocks@gmail.com','P120',4,'Nov 17 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1008,'SamRocks@gmail.com','P110',4,'Nov 19 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1009,'SamRocks@gmail.com','P112',3,'Nov 20 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1010,'SamRocks@gmail.com','P148',1,'Nov 21 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1011,'SamRocks@gmail.com','P150',5,'Dec 22 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1012,'Davis@gmail.com','P134',1,'Jan 12 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1013,'Davis@gmail.com','P101',3,'Jan 13 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1014,'Davis@gmail.com','P143',3,'Jan 14 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1015,'Davis@gmail.com','P112',3,'Jan 15 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1016,'Davis@gmail.com','P148',3,'Jan 16 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1017,'Henriot@gmail.com','P150',5,'Jan 17 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1018,'Henriot@gmail.com','P134',1,'Nov 22 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1019,'Henriot@gmail.com','P111',2,'Dec 25 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1020,'Henriot@gmail.com','P121',1,'Nov 21 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1021,'Henriot@gmail.com','P122',5,'Nov 28 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1022,'Pirkko@gmail.com','P109',4,'Nov 29 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1023,'Pirkko@gmail.com','P123',5,'Dec 21 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1024,'Pirkko@gmail.com','P115',2,'Jan 21 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1025,'Pirkko@gmail.com','P113',5,'Dec 21 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1026,'Pirkko@gmail.com','P145',3,'Nov 28 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1027,'Pirkko@gmail.com','P132',5,'Nov 29 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1028,'Pirkko@gmail.com','P101',3,'Nov 30 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1029,'Elizabeth@gmail.com','P143',5,'Jan  1 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1030,'Elizabeth@gmail.com','P112',5,'Jan  2 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1031,'Elizabeth@gmail.com','P148',1,'Jan  3 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1032,'Elizabeth@gmail.com','P150',5,'Jan  4 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1033,'Elizabeth@gmail.com','P134',2,'Jan  5 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1034,'Elizabeth@gmail.com','P135',3,'Jan  6 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1035,'Paula@gmail.com','P136',3,'Jan  7 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1036,'Paula@gmail.com','P137',3,'Jan 18 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1037,'Paula@gmail.com','P148',5,'Jan 19 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1038,'Paula@gmail.com','P150',2,'Jan 16 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1039,'Paula@gmail.com','P134',2,'Jan 12 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1040,'Paula@gmail.com','P120',2,'Jan 11 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1041,'Paula@gmail.com','P110',5,'Jan 12 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1042,'Howard@gmail.com','P112',2,'Jan 17 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1043,'Howard@gmail.com','P114',3,'Jan 19 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1044,'Howard@gmail.com','P101',1,'Jan 21 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1045,'Howard@gmail.com','P143',5,'Jan 22 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1046,'Howard@gmail.com','P112',2,'Jan 23 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1047,'Howard@gmail.com','P148',5,'Jan 14 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1048,'Howard@gmail.com','P150',4,'Jan 15 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1049,'Howard@gmail.com','P134',5,'Jan 17 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1066,'Franken@gmail.com','P101',2,'Jan 12 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1067,'Franken@gmail.com','P143',1,'Jan 13 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1068,'Franken@gmail.com','P112',3,'Jan 14 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1069,'Franken@gmail.com','P148',2,'Jan 15 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1070,'Franken@gmail.com','P150',1,'Jan 16 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1071,'Franken@gmail.com','P134',3,'Jan 17 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1072,'Pedro@gmail.com','P101',1,'Jan 18 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1073,'Pedro@gmail.com','P143',1,'Jan 12 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1074,'Pedro@gmail.com','P112',5,'Jan 13 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1075,'Pedro@gmail.com','P148',1,'Jan 14 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1076,'Pedro@gmail.com','P150',2,'Jan 15 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1077,'Pedro@gmail.com','P134',4,'Jan 16 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1078,'Pedro@gmail.com','P101',2,'Jan 12 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1079,'Roland@gmail.com','P143',1,'Jan 13 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1080,'Roland@gmail.com','P112',3,'Jan 14 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1081,'Roland@gmail.com','P148',2,'Jan 15 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1082,'Roland@gmail.com','P150',1,'Jan 16 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1083,'Roland@gmail.com','P134',3,'Jan 17 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1085,'Roland@gmail.com','P101',2,'Jan 12 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1086,'Roland@gmail.com','P143',1,'Jan 13 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1087,'Roland@gmail.com','P112',3,'Jan 14 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1088,'Roland@gmail.com','P148',2,'Jan 15 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1089,'Roland@gmail.com','P150',1,'Jan 16 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1090,'Roland@gmail.com','P134',3,'Jan 16 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1108,'Timothy@gmail.com','P120',4,'Nov 17 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1110,'Timothy@gmail.com','P110',4,'Nov 19 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1111,'Timothy@gmail.com','P112',3,'Nov 20 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1112,'Timothy@gmail.com','P148',1,'Nov 21 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1114,'Timothy@gmail.com','P150',5,'Dec 22 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1115,'Timothy@gmail.com','P134',1,'Jan 12 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1116,'Timothy@gmail.com','P101',3,'Jan 13 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1117,'Timothy@gmail.com','P143',3,'Jan 14 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1118,'Timothy@gmail.com','P112',3,'Jan 15 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1119,'Timothy@gmail.com','P148',3,'Jan 16 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1120,'Timothy@gmail.com','P150',5,'Jan 17 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1121,'Timothy@gmail.com','P134',1,'Nov 22 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1122,'Matti@gmail.com','P111',2,'Dec 25 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1123,'Matti@gmail.com','P121',1,'Nov 21 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1124,'Matti@gmail.com','P122',5,'Nov 28 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1125,'Matti@gmail.com','P109',4,'Nov 29 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1126,'Matti@gmail.com','P123',5,'Dec 21 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1127,'Matti@gmail.com','P115',2,'Jan 21 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1128,'Matti@gmail.com','P113',5,'Dec 21 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1129,'Matti@gmail.com','P145',3,'Nov 28 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1130,'Matti@gmail.com','P132',5,'Nov 29 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1131,'Matti@gmail.com','P101',3,'Nov 30 2013 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1132,'Matti@gmail.com','P143',5,'Jan  1 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1133,'Matti@gmail.com','P112',5,'Jan  2 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1134,'Helvetius@gmail.com','P148',1,'Jan  3 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1135,'Helvetius@gmail.com','P150',5,'Jan  4 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1136,'Helvetius@gmail.com','P134',2,'Jan  5 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1137,'Helvetius@gmail.com','P135',3,'Jan  6 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1138,'Helvetius@gmail.com','P136',3,'Jan  7 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1139,'Helvetius@gmail.com','P137',3,'Jan 18 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1140,'Helvetius@gmail.com','P148',5,'Jan 19 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1141,'Helvetius@gmail.com','P150',2,'Jan 16 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1142,'Helvetius@gmail.com','P134',2,'Jan 12 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1143,'Helvetius@gmail.com','P120',2,'Jan 11 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1144,'Helvetius@gmail.com','P110',5,'Jan 12 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1145,'Helvetius@gmail.com','P112',2,'Jan 17 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1146,'Mathew_Edmar@infosys.com','P114',3,'Jan 19 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1147,'Mathew_Edmar@infosys.com','P101',1,'Jan 21 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1148,'Mathew_Edmar@infosys.com','P143',5,'Jan 22 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1149,'Mathew_Edmar@infosys.com','P112',2,'Jan 23 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1150,'Mathew_Edmar@infosys.com','P148',5,'Jan 14 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1151,'Mathew_Edmar@infosys.com','P150',4,'Jan 15 2014 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1152,'Mathew_Edmar@infosys.com','P134',5,'Jan 17 2014 12:00AM')
SET IDENTITY_INSERT PurchaseDetails OFF

GO

--insertion scripts for CardDetails 
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1146665296881890,'Manuel','M',137,DATEADD(YEAR, 10, '2025-03-18'),7282.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1164283045453550,'Renate Messner','V',133,DATEADD(YEAR, 10,'2028-01-08'),14538.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1164916976389880,'Rita','M',588,DATEADD(YEAR, 10,'2025-07-28'),18570.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1172583365804160,'McKenna','V',777,DATEADD(YEAR, 10,'2028-04-05'),7972.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1190676541467400,'Brown','V',390,DATEADD(YEAR, 10,'2029-09-10'),9049.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1201253053391160,'Patricia','M',501,DATEADD(YEAR, 10,'2029-06-24'),19092.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1209611246778470,'Cruz','V',879,DATEADD(YEAR, 10,'2026-12-25'),13645.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1224920265219560,'Pirkko','M',771,DATEADD(YEAR, 10,'2027-09-18'),14620.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1229664582982800,'Helen','M',402,DATEADD(YEAR, 10,'2021-06-28'),16932.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1245674190696670,'Mary','M',828,DATEADD(YEAR, 10,'2020-10-04'),14078.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1258975792010020,'Annette','M',606,DATEADD(YEAR, 10,'2022-10-24'),15889.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1299352607468300,'Saveley','V',161,DATEADD(YEAR, 10,'2023-08-05'),14120.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1307313341777150,'Anne','M',684,DATEADD(YEAR, 10,'2020-08-28'),16611.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1307984461363180,'Philip','M',663,DATEADD(YEAR, 10,'2021-08-19'),9663.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1323958003776600,'Parente','V',517,DATEADD(YEAR, 10,'2021-07-22'),7532.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1333123521082050,'Laurence','M',401,DATEADD(YEAR, 10,'2029-01-08'),16257.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1344543094137310,'Chang','V',602,DATEADD(YEAR, 10,'2023-10-16'),10822.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1353631465427820,'Paolino','V',435,DATEADD(YEAR, 10,'2022-08-14'),5400.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1360271842709590,'Karin','M',878,DATEADD(YEAR, 10,'2024-03-07'),12912.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1372132080189220,'Sommer','V',524,DATEADD(YEAR, 10,'2021-04-12'),14556.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1375307422567340,'Yoshi','M',461,DATEADD(YEAR, 10,'2028-10-10'),12344.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1386564526403300,'Carlos','M',468,DATEADD(YEAR, 10,'2025-01-25'),6810.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1408191938746240,'Ibsen','V',246,DATEADD(YEAR, 10,'2022-09-09'),7022.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1420510667654400,'Bennett','V',324,DATEADD(YEAR, 10,'2029-02-17'),5724.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1422216593359170,'Aria','M',565,DATEADD(YEAR, 10,'2030-04-11'),16016.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1429133847340950,'Martin','M',421,DATEADD(YEAR, 10,'2022-03-26'),9567.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1431181049383360,'Matti Karttunen','M',851,DATEADD(YEAR, 10,'2026-05-14'),6334.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1438819177663050,'Roel','V',641,DATEADD(YEAR, 10,'2024-09-15'),13577.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1462257648213080,'Larsson','V',749,DATEADD(YEAR, 10,'2027-04-02'),14693.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1482320853851460,'Peter','M',522,DATEADD(YEAR, 10,'2028-12-08'),9433.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1492397474220820,'Maria','M',340,DATEADD(YEAR, 10,'2020-11-18'),13098.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1514516790088230,'Pedro','V',820,DATEADD(YEAR, 10,'2028-09-04'),6451.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1537796149367160,'Pontes','V',310,DATEADD(YEAR, 10,'2028-05-23'),8675.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1555631662463540,'Henriot','V',779,DATEADD(YEAR, 10,'2020-08-20'),9786.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1563901313189020,'Jaime Yorres','V',240,DATEADD(YEAR, 10,'2020-10-22'),11605.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1572423633450130,'Matti','M',775,DATEADD(YEAR, 10,'2028-02-02'),5972.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1574371302243230,'Hernadez','V',551,DATEADD(YEAR, 10,'2022-11-07'),3998.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1580998908832260,'Muller','V',645,DATEADD(YEAR, 10,'2029-03-09'),10031.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1589603911737880,'Lincoln','V',386,DATEADD(YEAR, 10,'2022-10-04'),18947.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1598628594155670,'Karla','M',632,DATEADD(YEAR, 10,'2030-07-17'),13292.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1608547117331400,'Rourke','V',494,DATEADD(YEAR, 10,'2026-11-10'),8083.0)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1625578520990590,'Mendel','V',668,DATEADD(YEAR, 10,'2019-06-16'),8736.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1644808785340540,'Lebihan','V',803,DATEADD(YEAR, 10,'2020-11-19'),11121.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1656858554325890,'Paolo','V',480,DATEADD(YEAR, 10,'2027-11-26'),11965.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1666406702985340,'Lesley','M',275,DATEADD(YEAR, 10,'2025-09-27'),6934.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1670872362066270,'Ottlieb','V',664,DATEADD(YEAR, 10,'2027-10-30'),3257.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1706709681608450,'Martine','M',461,DATEADD(YEAR, 10,'2020-12-16'),6688.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1753456075904120,'Cramer','V',156,DATEADD(YEAR, 10,'2021-12-22'),17721.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1762181841319160,'Victoria','V',846,DATEADD(YEAR, 10,'2027-08-20'),5927.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1769660540375220,'Smith','V',603,DATEADD(YEAR, 10,'2027-10-05'),3011.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1770791472481120,'Accorti','V',855,DATEADD(YEAR, 10,'2025-08-16'),17423.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1770826010361760,'Koskitalo','V',874,DATEADD(YEAR, 10,'2029-09-11'),15892.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1774070025907600,'Miguel','M',444,DATEADD(YEAR, 10,'2020-06-18'),10058.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1780797319715350,'Helvetius','M',869,DATEADD(YEAR, 10,'2027-05-03'),12015.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1787045046296090,'Domingues','V',335,DATEADD(YEAR, 10,'2028-11-03'),6683.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1803781319458280,'Diego','M',744,DATEADD(YEAR, 10,'2026-01-14'),15762.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1825594516343200,'Nagy','V',705,DATEADD(YEAR, 10,'2023-04-11'),7712.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1869448663438790,'Snyder','V',310,DATEADD(YEAR, 10,'2023-04-06'),15081.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1896069342213410,'Thomas','V',833,DATEADD(YEAR, 10,'2028-04-16'),11755.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1905318731514900,'Sven','M',657,DATEADD(YEAR, 10,'2020-11-11'),5759.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1930722559801600,'Pereira','V',556,DATEADD(YEAR, 10,'2026-04-12'),5996.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1938972100708320,'Tonini','V',513,DATEADD(YEAR, 10,'2021-04-23'),3565.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1974246182398960,'Anabela','M',204,DATEADD(YEAR, 10,'2023-12-03'),13083.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1987863279307720,'Howard','M',331,DATEADD(YEAR, 10,'2026-02-10'),2708.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1996173177447140,'Davis','M',501,DATEADD(YEAR, 10,'2023-03-28'),18212.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2017070736071510,'Franken','V',439,DATEADD(YEAR, 10,'2023-06-05'),3590.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2020707634380970,'Karttunen','V',865,DATEADD(YEAR, 10,'2027-10-20'),17928.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2038135301855300,'Janine','M',680,DATEADD(YEAR, 10,'2024-11-09'),4077.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2040807464727850,'Paula','M',286,DATEADD(YEAR, 10,'2028-07-08'),8052.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2054485375031050,'Elizabeth','M',183,DATEADD(YEAR, 10,'2024-09-12'),6145.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2079696512053250,'Maria','M',465,DATEADD(YEAR, 10,'2025-07-18'),6170.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2082327655038300,'Jablonski','V',622,DATEADD(YEAR, 10,'2020-02-29'),14280.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2099162707660160,'Timothy','M',568,DATEADD(YEAR, 10,'2023-08-08'),8408.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2099299687852320,'Carlos GonzÃ¡lez','V',244,DATEADD(YEAR, 10,'2026-01-07'),7330.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2102109985058560,'Ashworth','V',634,DATEADD(YEAR, 10,'2027-05-24'),10204.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2102480159544330,'Roulet','V',764,DATEADD(YEAR, 10,'2026-08-20'),2883.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2107089108224360,'Latimer','V',720,DATEADD(YEAR, 10,'2029-09-16'),11387.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2112369521723620,'Carine','M',490,DATEADD(YEAR, 10,'2022-12-06'),18773.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2119125701641590,'Schmitt','V',331,DATEADD(YEAR, 10,'2030-05-01'),6182.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2121785955299770,'Palle','M',261,DATEADD(YEAR, 10,'2027-07-05'),3655.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2122490035590690,'Margaret','M',875,DATEADD(YEAR, 10,'2022-01-16'),18000.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2127803726103060,'Afonso','V',858,DATEADD(YEAR, 10,'2029-10-09'),11726.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2136141552371090,'Rance','V',434,DATEADD(YEAR, 10,'2025-10-05'),17813.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2139581656416670,'Francisco','M',727,DATEADD(YEAR, 10,'2029-01-30'),15845.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2155938900697450,'Labrune','V',400,DATEADD(YEAR, 10,'2028-02-10'),2455.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2157326961005880,'Daniel','M',827,DATEADD(YEAR, 10,'2029-03-07'),2145.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2175932867933100,'Gary','M',635,DATEADD(YEAR, 10,'2028-05-31'),14526.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2175974386401880,'Devon','V',270,DATEADD(YEAR, 10,'2021-11-20'),3463.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2208687402112480,'Josephs','V',640,DATEADD(YEAR, 10,'2023-12-29'),15794.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2210444662985580,'Paul','M',710,DATEADD(YEAR, 10,'2025-04-29'),16523.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2219617013139190,'Roland','M',719,DATEADD(YEAR, 10,'2025-08-31'),2537.00)
GO
