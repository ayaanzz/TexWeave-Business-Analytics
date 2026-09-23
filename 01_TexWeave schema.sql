-- ============================================================================
-- MSN ACADEMY - VIRTUAL INTERNSHIP PROGRAM 2.0
-- Project: MSN TexWeave (Textile Industry Analytics)
-- Phase 1: Production 3NF Database DDL Script (31 Entities | Enhanced Business KPIs)
-- Database Engine: Microsoft SQL Server (T-SQL)
-- ============================================================================

USE master;
GO

-- Drop database if it exists to ensure a clean build
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'MSN_TexWeave_DB')
BEGIN
    ALTER DATABASE MSN_TexWeave_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE MSN_TexWeave_DB;
END
GO

CREATE DATABASE MSN_TexWeave_DB;
GO

USE MSN_TexWeave_DB;
GO

-- ============================================================================
-- MODULE 1: LOOKUP & REFERENCE TABLES (Zero FK Dependencies)
-- ============================================================================

-- Table 1: MaterialCategories (4 cols)
CREATE TABLE MaterialCategories (
    CategoryID INT IDENTITY(1,1) NOT NULL,
    CategoryName VARCHAR(100) NOT NULL,
    Description VARCHAR(255) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_MatCat_IsActive DEFAULT 1,
    CONSTRAINT PK_MaterialCategories PRIMARY KEY CLUSTERED (CategoryID),
    CONSTRAINT UQ_MatCat_CategoryName UNIQUE (CategoryName)
);
GO

-- Table 2: ProductionStages (5 cols)
CREATE TABLE ProductionStages (
    StageID INT IDENTITY(1,1) NOT NULL,
    StageName VARCHAR(100) NOT NULL,
    SequenceOrder INT NOT NULL,
    StandardDurationHours DECIMAL(6,2) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_ProdStage_IsActive DEFAULT 1,
    CONSTRAINT PK_ProductionStages PRIMARY KEY CLUSTERED (StageID),
    CONSTRAINT UQ_ProdStage_StageName UNIQUE (StageName),
    CONSTRAINT UQ_ProdStage_Sequence UNIQUE (SequenceOrder),
    CONSTRAINT CHK_ProdStage_Duration CHECK (StandardDurationHours > 0)
);
GO

-- Table 3: Shifts (5 cols)
CREATE TABLE Shifts (
    ShiftID INT IDENTITY(1,1) NOT NULL,
    ShiftName VARCHAR(50) NOT NULL,
    StartTime TIME(0) NOT NULL,
    EndTime TIME(0) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Shifts_IsActive DEFAULT 1,
    CONSTRAINT PK_Shifts PRIMARY KEY CLUSTERED (ShiftID),
    CONSTRAINT UQ_Shifts_ShiftName UNIQUE (ShiftName)
);
GO

-- Table 4: ProductCategories (4 cols)
CREATE TABLE ProductCategories (
    CategoryID INT IDENTITY(1,1) NOT NULL,
    CategoryName VARCHAR(100) NOT NULL,
    Description VARCHAR(255) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_ProdCat_IsActive DEFAULT 1,
    CONSTRAINT PK_ProductCategories PRIMARY KEY CLUSTERED (CategoryID),
    CONSTRAINT UQ_ProdCat_CategoryName UNIQUE (CategoryName)
);
GO

-- Table 5: FabricTypes (5 cols)
CREATE TABLE FabricTypes (
    FabricTypeID INT IDENTITY(1,1) NOT NULL,
    FabricName VARCHAR(100) NOT NULL,
    Composition VARCHAR(150) NOT NULL,
    WeaveType VARCHAR(100) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_FabricTypes_IsActive DEFAULT 1,
    CONSTRAINT PK_FabricTypes PRIMARY KEY CLUSTERED (FabricTypeID),
    CONSTRAINT UQ_FabricTypes_FabricName UNIQUE (FabricName)
);
GO

-- Table 6: Departments (4 cols)
CREATE TABLE Departments (
    DepartmentID INT IDENTITY(1,1) NOT NULL,
    DepartmentName VARCHAR(100) NOT NULL,
    DepartmentCode VARCHAR(50) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Departments_IsActive DEFAULT 1,
    CONSTRAINT PK_Departments PRIMARY KEY CLUSTERED (DepartmentID),
    CONSTRAINT UQ_Departments_Name UNIQUE (DepartmentName),
    CONSTRAINT UQ_Departments_Code UNIQUE (DepartmentCode)
);
GO

-- Table 7: Designations (4 cols)
CREATE TABLE Designations (
    DesignationID INT IDENTITY(1,1) NOT NULL,
    DesignationTitle VARCHAR(100) NOT NULL,
    PayGrade VARCHAR(50) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Designations_IsActive DEFAULT 1,
    CONSTRAINT PK_Designations PRIMARY KEY CLUSTERED (DesignationID),
    CONSTRAINT UQ_Designations_Title UNIQUE (DesignationTitle)
);
GO

-- Table 8: DefectTypes (5 cols)
CREATE TABLE DefectTypes (
    DefectTypeID INT IDENTITY(1,1) NOT NULL,
    DefectCode VARCHAR(50) NOT NULL,
    DefectName VARCHAR(100) NOT NULL,
    SeverityLevel VARCHAR(30) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_DefectTypes_IsActive DEFAULT 1,
    CONSTRAINT PK_DefectTypes PRIMARY KEY CLUSTERED (DefectTypeID),
    CONSTRAINT UQ_DefectTypes_DefectCode UNIQUE (DefectCode),
    CONSTRAINT CHK_DefectTypes_Severity CHECK (SeverityLevel IN ('Critical', 'Major', 'Minor'))
);
GO

-- ============================================================================
-- MODULE 2: MASTER ENTITIES
-- ============================================================================

-- Table 9: Suppliers (8 cols)
CREATE TABLE Suppliers (
    SupplierID INT IDENTITY(1,1) NOT NULL,
    SupplierCode VARCHAR(50) NOT NULL,
    SupplierName VARCHAR(150) NOT NULL,
    ContactName VARCHAR(100) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Address VARCHAR(255) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Suppliers_IsActive DEFAULT 1,
    CONSTRAINT PK_Suppliers PRIMARY KEY CLUSTERED (SupplierID),
    CONSTRAINT UQ_Suppliers_SupplierCode UNIQUE (SupplierCode),
    CONSTRAINT UQ_Suppliers_Email UNIQUE (Email)
);
GO

-- Table 10: Warehouses (6 cols)
CREATE TABLE Warehouses (
    WarehouseID INT IDENTITY(1,1) NOT NULL,
    WarehouseCode VARCHAR(50) NOT NULL,
    WarehouseName VARCHAR(100) NOT NULL,
    Location VARCHAR(255) NOT NULL,
    Capacity DECIMAL(18,2) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Warehouses_IsActive DEFAULT 1,
    CONSTRAINT PK_Warehouses PRIMARY KEY CLUSTERED (WarehouseID),
    CONSTRAINT UQ_Warehouses_WarehouseCode UNIQUE (WarehouseCode),
    CONSTRAINT CHK_Warehouses_Capacity CHECK (Capacity > 0)
);
GO

-- Table 11: DesignPatterns (6 cols)
CREATE TABLE DesignPatterns (
    PatternID INT IDENTITY(1,1) NOT NULL,
    PatternCode VARCHAR(50) NOT NULL,
    PatternName VARCHAR(100) NOT NULL,
    Colorway VARCHAR(100) NOT NULL,
    IsObsolete BIT NOT NULL CONSTRAINT DF_DesignPatterns_IsObsolete DEFAULT 0,
    IsActive BIT NOT NULL CONSTRAINT DF_DesignPatterns_IsActive DEFAULT 1,
    CONSTRAINT PK_DesignPatterns PRIMARY KEY CLUSTERED (PatternID),
    CONSTRAINT UQ_DesignPatterns_PatternCode UNIQUE (PatternCode)
);
GO

-- Table 12: Carriers (5 cols)
CREATE TABLE Carriers (
    CarrierID INT IDENTITY(1,1) NOT NULL,
    CarrierName VARCHAR(150) NOT NULL,
    ContactPhone VARCHAR(20) NOT NULL,
    ServiceType VARCHAR(50) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Carriers_IsActive DEFAULT 1,
    CONSTRAINT PK_Carriers PRIMARY KEY CLUSTERED (CarrierID),
    CONSTRAINT UQ_Carriers_CarrierName UNIQUE (CarrierName),
    CONSTRAINT CHK_Carriers_ServiceType CHECK (ServiceType IN ('Ocean Freight', 'Air Cargo', 'Road Freight', 'Express'))
);
GO

-- Table 13: Customers (8 cols)
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) NOT NULL,
    CustomerCode VARCHAR(50) NOT NULL,
    CustomerName VARCHAR(150) NOT NULL,
    CustomerType VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Country VARCHAR(100) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Customers_IsActive DEFAULT 1,
    CONSTRAINT PK_Customers PRIMARY KEY CLUSTERED (CustomerID),
    CONSTRAINT UQ_Customers_CustomerCode UNIQUE (CustomerCode),
    CONSTRAINT UQ_Customers_Email UNIQUE (Email),
    CONSTRAINT CHK_Customers_Type CHECK (CustomerType IN ('Domestic Wholesale', 'Export Retail', 'Domestic Retail', 'Distributor'))
);
GO

-- Table 14: Employees (10 cols - Clean Master without trivial computed columns)
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) NOT NULL,
    EmployeeCode VARCHAR(50) NOT NULL,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    DepartmentID INT NOT NULL,
    DesignationID INT NOT NULL,
    HireDate DATE NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Employees_IsActive DEFAULT 1,
    CONSTRAINT PK_Employees PRIMARY KEY CLUSTERED (EmployeeID),
    CONSTRAINT UQ_Employees_EmployeeCode UNIQUE (EmployeeCode),
    CONSTRAINT UQ_Employees_Email UNIQUE (Email),
    CONSTRAINT CHK_Employees_HireDate CHECK (HireDate <= GETDATE()),
    CONSTRAINT FK_Employees_Departments FOREIGN KEY (DepartmentID)
        REFERENCES Departments (DepartmentID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_Employees_Designations FOREIGN KEY (DesignationID)
        REFERENCES Designations (DesignationID) ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Table 15: Machines (8 cols)
CREATE TABLE Machines (
    MachineID INT IDENTITY(1,1) NOT NULL,
    MachineCode VARCHAR(50) NOT NULL,
    MachineName VARCHAR(100) NOT NULL,
    StageID INT NOT NULL,
    CapacityPerHour DECIMAL(12,2) NOT NULL,
    MaintenanceDueDate DATE NOT NULL,
    Status VARCHAR(30) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Machines_IsActive DEFAULT 1,
    CONSTRAINT PK_Machines PRIMARY KEY CLUSTERED (MachineID),
    CONSTRAINT UQ_Machines_MachineCode UNIQUE (MachineCode),
    CONSTRAINT CHK_Machines_Capacity CHECK (CapacityPerHour > 0),
    CONSTRAINT CHK_Machines_Status CHECK (Status IN ('Running', 'Maintenance', 'Offline', 'Idle')),
    CONSTRAINT FK_Machines_ProductionStages FOREIGN KEY (StageID)
        REFERENCES ProductionStages (StageID) ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Table 16: RawMaterials (9 cols)
CREATE TABLE RawMaterials (
    MaterialID INT IDENTITY(1,1) NOT NULL,
    MaterialCode VARCHAR(50) NOT NULL,
    MaterialName VARCHAR(150) NOT NULL,
    CategoryID INT NOT NULL,
    PrimarySupplierID INT NOT NULL,
    UnitOfMeasure VARCHAR(20) NOT NULL,
    ReorderLevel DECIMAL(18,2) NOT NULL,
    UnitCost DECIMAL(18,2) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_RawMaterials_IsActive DEFAULT 1,
    CONSTRAINT PK_RawMaterials PRIMARY KEY CLUSTERED (MaterialID),
    CONSTRAINT UQ_RawMaterials_MaterialCode UNIQUE (MaterialCode),
    CONSTRAINT CHK_RawMaterials_Reorder CHECK (ReorderLevel >= 0),
    CONSTRAINT CHK_RawMaterials_Cost CHECK (UnitCost >= 0),
    CONSTRAINT FK_RawMaterials_MaterialCategories FOREIGN KEY (CategoryID)
        REFERENCES MaterialCategories (CategoryID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_RawMaterials_Suppliers FOREIGN KEY (PrimarySupplierID)
        REFERENCES Suppliers (SupplierID) ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Table 17: Products (11 cols)
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) NOT NULL,
    ProductSKU VARCHAR(50) NOT NULL,
    ProductName VARCHAR(150) NOT NULL,
    CategoryID INT NOT NULL,
    FabricTypeID INT NOT NULL,
    PatternID INT NOT NULL,
    BasePrice DECIMAL(18,2) NOT NULL,
    CostPrice DECIMAL(18,2) NOT NULL,
    UnitOfMeasure VARCHAR(20) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Products_IsActive DEFAULT 1,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_Products_CreatedAt DEFAULT GETDATE(),
    CONSTRAINT PK_Products PRIMARY KEY CLUSTERED (ProductID),
    CONSTRAINT UQ_Products_ProductSKU UNIQUE (ProductSKU),
    CONSTRAINT CHK_Products_Price CHECK (BasePrice >= 0 AND CostPrice >= 0),
    CONSTRAINT FK_Products_ProductCategories FOREIGN KEY (CategoryID)
        REFERENCES ProductCategories (CategoryID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_Products_FabricTypes FOREIGN KEY (FabricTypeID)
        REFERENCES FabricTypes (FabricTypeID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_Products_DesignPatterns FOREIGN KEY (PatternID)
        REFERENCES DesignPatterns (PatternID) ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- ============================================================================
-- MODULE 3: OPERATIONAL & TRANSACTIONAL MODULES
-- ============================================================================

-- Table 18: BillOfMaterials (6 cols)
CREATE TABLE BillOfMaterials (
    BOMID INT IDENTITY(1,1) NOT NULL,
    ProductID INT NOT NULL,
    MaterialID INT NOT NULL,
    QuantityRequired DECIMAL(18,4) NOT NULL,
    UnitOfMeasure VARCHAR(20) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_BOM_IsActive DEFAULT 1,
    CONSTRAINT PK_BillOfMaterials PRIMARY KEY CLUSTERED (BOMID),
    CONSTRAINT UQ_BOM_Product_Material UNIQUE (ProductID, MaterialID),
    CONSTRAINT CHK_BOM_Quantity CHECK (QuantityRequired > 0),
    CONSTRAINT FK_BOM_Products FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID) ON UPDATE NO ACTION ON DELETE NO ACTION,    
    CONSTRAINT FK_BOM_RawMaterials FOREIGN KEY (MaterialID)
        REFERENCES RawMaterials (MaterialID) ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Table 19: RawMaterialStock (6 cols)
CREATE TABLE RawMaterialStock (
    StockID INT IDENTITY(1,1) NOT NULL,
    MaterialID INT NOT NULL,
    WarehouseID INT NOT NULL,
    QuantityOnHand DECIMAL(18,2) NOT NULL,
    MinimumStockLevel DECIMAL(18,2) NOT NULL,
    LastUpdated DATETIME NOT NULL CONSTRAINT DF_RawStock_LastUpdated DEFAULT GETDATE(),
    CONSTRAINT PK_RawMaterialStock PRIMARY KEY CLUSTERED (StockID),
    CONSTRAINT UQ_RawStock_Material_Warehouse UNIQUE (MaterialID, WarehouseID),
    CONSTRAINT CHK_RawStock_Qty CHECK (QuantityOnHand >= 0),
    CONSTRAINT CHK_RawStock_Min CHECK (MinimumStockLevel >= 0),
    CONSTRAINT FK_RawStock_RawMaterials FOREIGN KEY (MaterialID)
        REFERENCES RawMaterials (MaterialID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_RawStock_Warehouses FOREIGN KEY (WarehouseID)
        REFERENCES Warehouses (WarehouseID) ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Table 20: PurchaseOrders (9 cols)
CREATE TABLE PurchaseOrders (
    POID INT IDENTITY(1,1) NOT NULL,
    PONumber VARCHAR(50) NOT NULL,
    SupplierID INT NOT NULL,
    OrderDate DATE NOT NULL,
    ExpectedDeliveryDate DATE NOT NULL,
    TotalAmount DECIMAL(18,2) NOT NULL,
    Status VARCHAR(30) NOT NULL,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_PO_CreatedAt DEFAULT GETDATE(),
    IsActive BIT NOT NULL CONSTRAINT DF_PO_IsActive DEFAULT 1,
    CONSTRAINT PK_PurchaseOrders PRIMARY KEY CLUSTERED (POID),
    CONSTRAINT UQ_PurchaseOrders_PONumber UNIQUE (PONumber),
    CONSTRAINT CHK_PO_OrderDate CHECK (OrderDate <= GETDATE()),
    CONSTRAINT CHK_PO_TotalAmount CHECK (TotalAmount >= 0),
    CONSTRAINT CHK_PO_Status CHECK (Status IN ('Pending', 'Approved', 'Received', 'Cancelled')),
    CONSTRAINT FK_PurchaseOrders_Suppliers FOREIGN KEY (SupplierID)
        REFERENCES Suppliers (SupplierID) ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Table 21: PurchaseOrderDetails (7 cols | COMPUTED COL 1: LineTotal)
CREATE TABLE PurchaseOrderDetails (
    PODetailID INT IDENTITY(1,1) NOT NULL,
    POID INT NOT NULL,
    MaterialID INT NOT NULL,
    QuantityOrdered DECIMAL(18,2) NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,
    ReceivedQuantity DECIMAL(18,2) NOT NULL CONSTRAINT DF_PODetail_ReceivedQty DEFAULT 0,
    LineTotal AS (CAST(QuantityOrdered * UnitPrice AS DECIMAL(18,2))),
    CONSTRAINT PK_PurchaseOrderDetails PRIMARY KEY CLUSTERED (PODetailID),
    CONSTRAINT CHK_PODetail_Qty CHECK (QuantityOrdered > 0),
    CONSTRAINT CHK_PODetail_Price CHECK (UnitPrice > 0),
    CONSTRAINT CHK_PODetail_Received CHECK (ReceivedQuantity >= 0),
    CONSTRAINT FK_PODetail_PurchaseOrders FOREIGN KEY (POID)
        REFERENCES PurchaseOrders(POID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_PODetail_RawMaterials FOREIGN KEY (MaterialID)
        REFERENCES RawMaterials (MaterialID) ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Table 22: ProductionOrders (14 cols | COMPUTED COL 2: ProductionEfficiency, COMPUTED COL 3: DurationDays)
CREATE TABLE ProductionOrders (
    ProductionOrderID INT IDENTITY(1,1) NOT NULL,
    OrderNumber VARCHAR(50) NOT NULL,
    ProductID INT NOT NULL,
    TargetQuantity INT NOT NULL,
    ProducedQuantity INT NOT NULL CONSTRAINT DF_ProdOrder_ProducedQty DEFAULT 0,
    BatchNumber VARCHAR(50) NOT NULL,
    StartDate DATETIME NOT NULL,
    EndDate DATETIME NULL,
    ProductionEfficiency AS (CAST((ProducedQuantity * 100.0) / NULLIF(TargetQuantity, 0) AS DECIMAL(5,2))),
    DurationDays AS (DATEDIFF(DAY, StartDate, EndDate)),
    StageID INT NOT NULL,
    MachineID INT NOT NULL,
    Status VARCHAR(30) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_ProdOrder_IsActive DEFAULT 1,
    CONSTRAINT PK_ProductionOrders PRIMARY KEY CLUSTERED (ProductionOrderID),
    CONSTRAINT UQ_ProductionOrders_OrderNumber UNIQUE (OrderNumber),
    CONSTRAINT UQ_ProductionOrders_BatchNumber UNIQUE (BatchNumber),
    CONSTRAINT CHK_ProdOrder_TargetQty CHECK (TargetQuantity > 0),
    CONSTRAINT CHK_ProdOrder_ProducedQty CHECK (ProducedQuantity >= 0),
    CONSTRAINT CHK_ProdOrder_Status CHECK (Status IN ('Scheduled', 'InProgress', 'Completed', 'Cancelled')),
    CONSTRAINT FK_ProdOrder_Products FOREIGN KEY (ProductID)
        REFERENCES Products (ProductID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_ProdOrder_Stages FOREIGN KEY (StageID)
        REFERENCES ProductionStages (StageID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_ProdOrder_Machines FOREIGN KEY (MachineID)
        REFERENCES Machines (MachineID) ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Table 23: MachineAllocation (7 cols)
CREATE TABLE MachineAllocation (
    AllocationID INT IDENTITY(1,1) NOT NULL,
    MachineID INT NOT NULL,
    ProductionOrderID INT NOT NULL,
    ShiftID INT NOT NULL,
    AllocatedDate DATE NOT NULL,
    OperatingHours DECIMAL(6,2) NOT NULL,
    Status VARCHAR(30) NOT NULL,
    CONSTRAINT PK_MachineAllocation PRIMARY KEY CLUSTERED (AllocationID),
    CONSTRAINT CHK_MachAlloc_Hours CHECK (OperatingHours >= 0),
    CONSTRAINT CHK_MachAlloc_Status CHECK (Status IN ('Planned', 'InUse', 'Completed')),
    CONSTRAINT FK_MachAlloc_Machines FOREIGN KEY (MachineID)
        REFERENCES Machines (MachineID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_MachAlloc_ProdOrders FOREIGN KEY (ProductionOrderID)
        REFERENCES ProductionOrders (ProductionOrderID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_MachAlloc_Shifts FOREIGN KEY (ShiftID)
        REFERENCES Shifts (ShiftID) ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Table 24: QualityChecks (10 cols | COMPUTED COL 4: DefectRate)
CREATE TABLE QualityChecks (
    CheckID INT IDENTITY(1,1) NOT NULL,
    ProductionOrderID INT NOT NULL,
    StageID INT NOT NULL,
    InspectedQuantity INT NOT NULL,
    DefectQuantity INT NOT NULL CONSTRAINT DF_QC_DefectQty DEFAULT 0,
    DefectRate AS (CAST((DefectQuantity * 100.0) / NULLIF(InspectedQuantity, 0) AS DECIMAL(5,2))),
    CheckResult VARCHAR(30) NOT NULL,
    InspectedBy INT NOT NULL,
    CheckDate DATETIME NOT NULL CONSTRAINT DF_QC_CheckDate DEFAULT GETDATE(),
    Comments VARCHAR(255) NULL,
    CONSTRAINT PK_QualityChecks PRIMARY KEY CLUSTERED (CheckID),
    CONSTRAINT CHK_QC_Quantities CHECK (InspectedQuantity >= 0 AND DefectQuantity >= 0 AND DefectQuantity <= InspectedQuantity),
    CONSTRAINT CHK_QC_Result CHECK (CheckResult IN ('Pending', 'Passed', 'Failed', 'Rework')),
    CONSTRAINT FK_QC_ProductionOrders FOREIGN KEY (ProductionOrderID)
        REFERENCES ProductionOrders (ProductionOrderID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_QC_Stages FOREIGN KEY (StageID)
        REFERENCES ProductionStages (StageID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_QC_Employees FOREIGN KEY (InspectedBy)
        REFERENCES Employees (EmployeeID) ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Table 25: WastageRecords (8 cols)
CREATE TABLE WastageRecords (
    WastageID INT IDENTITY(1,1) NOT NULL,
    ProductionOrderID INT NOT NULL,
    StageID INT NOT NULL,
    MaterialID INT NOT NULL,
    WastageQuantity DECIMAL(18,2) NOT NULL,
    WastagePercentage DECIMAL(5,2) NOT NULL,
    Reason VARCHAR(255) NOT NULL,
    LoggedDate DATETIME NOT NULL CONSTRAINT DF_Wastage_LoggedDate DEFAULT GETDATE(),
    CONSTRAINT PK_WastageRecords PRIMARY KEY CLUSTERED (WastageID),
    CONSTRAINT CHK_Wastage_Qty CHECK (WastageQuantity >= 0),
    CONSTRAINT CHK_Wastage_Pct CHECK (WastagePercentage BETWEEN 0.00 AND 100.00),
    CONSTRAINT FK_Wastage_ProdOrders FOREIGN KEY (ProductionOrderID)
        REFERENCES ProductionOrders (ProductionOrderID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_Wastage_Stages FOREIGN KEY (StageID)
        REFERENCES ProductionStages (StageID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_Wastage_RawMaterials FOREIGN KEY (MaterialID)
        REFERENCES RawMaterials (MaterialID) ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Table 26: FinishedGoodsInventory (7 cols)
CREATE TABLE FinishedGoodsInventory (
    FGInventoryID INT IDENTITY(1,1) NOT NULL,
    ProductID INT NOT NULL,
    WarehouseID INT NOT NULL,
    BatchNumber VARCHAR(50) NOT NULL,
    QuantityOnHand INT NOT NULL,
    ReservedQuantity INT NOT NULL CONSTRAINT DF_FG_ReservedQty DEFAULT 0,
    LastUpdated DATETIME NOT NULL CONSTRAINT DF_FG_LastUpdated DEFAULT GETDATE(),
    CONSTRAINT PK_FinishedGoodsInventory PRIMARY KEY CLUSTERED (FGInventoryID),
    CONSTRAINT UQ_FG_Product_Warehouse_Batch UNIQUE (ProductID, WarehouseID, BatchNumber),
    CONSTRAINT CHK_FG_OnHand CHECK (QuantityOnHand >= 0),
    CONSTRAINT CHK_FG_Reserved CHECK (ReservedQuantity >= 0 AND ReservedQuantity <= QuantityOnHand),
    CONSTRAINT FK_FG_Products FOREIGN KEY (ProductID)
        REFERENCES Products (ProductID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_FG_Warehouses FOREIGN KEY (WarehouseID)
        REFERENCES Warehouses (WarehouseID) ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Table 27: StockMovements (8 cols)
CREATE TABLE StockMovements (
    MovementID INT IDENTITY(1,1) NOT NULL,
    MovementType VARCHAR(50) NOT NULL,
    MaterialID INT NULL,
    ProductID INT NULL,
    FromWarehouseID INT NOT NULL,
    ToWarehouseID INT NOT NULL,
    Quantity DECIMAL(18,2) NOT NULL,
    MovementDate DATETIME NOT NULL CONSTRAINT DF_StockMovements_Date DEFAULT GETDATE(),
    CONSTRAINT PK_StockMovements PRIMARY KEY CLUSTERED (MovementID),
    CONSTRAINT CHK_StockMovements_Qty CHECK (Quantity > 0),
    CONSTRAINT CHK_StockMovements_Type CHECK (MovementType IN ('Inbound', 'Outbound', 'Transfer', 'Adjustment')),
    CONSTRAINT FK_StockMovements_RawMaterials FOREIGN KEY (MaterialID)
        REFERENCES RawMaterials (MaterialID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_StockMovements_Products FOREIGN KEY (ProductID)
        REFERENCES Products (ProductID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_StockMovements_FromWH FOREIGN KEY (FromWarehouseID)
        REFERENCES Warehouses (WarehouseID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_StockMovements_ToWH FOREIGN KEY (ToWarehouseID)
        REFERENCES Warehouses (WarehouseID) ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Table 28: SalesOrders (10 cols | COMPUTED COL 5: TotalAmount)
CREATE TABLE SalesOrders (
    SalesOrderID INT IDENTITY(1,1) NOT NULL,
    OrderNumber VARCHAR(50) NOT NULL,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    ExpectedShipDate DATE NOT NULL,
    Channel VARCHAR(50) NOT NULL,
    SubTotal DECIMAL(18,2) NOT NULL,
    TaxAmount DECIMAL(18,2) NOT NULL,
    TotalAmount AS (CAST(SubTotal + TaxAmount AS DECIMAL(18,2))),
    Status VARCHAR(30) NOT NULL,
    CONSTRAINT PK_SalesOrders PRIMARY KEY CLUSTERED (SalesOrderID),
    CONSTRAINT UQ_SalesOrders_OrderNumber UNIQUE (OrderNumber),
    CONSTRAINT CHK_SalesOrders_Date CHECK (OrderDate <= GETDATE()),
    CONSTRAINT CHK_SalesOrders_SubTotal CHECK (SubTotal >= 0),
    CONSTRAINT CHK_SalesOrders_Tax CHECK (TaxAmount >= 0),
    CONSTRAINT CHK_SalesOrders_Channel CHECK (Channel IN ('Domestic', 'Export')),
    CONSTRAINT CHK_SalesOrders_Status CHECK (Status IN ('Pending', 'Confirmed', 'Shipped', 'Delivered', 'Cancelled')),
    CONSTRAINT FK_SalesOrders_Customers FOREIGN KEY (CustomerID)
        REFERENCES Customers (CustomerID) ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Table 29: SalesOrderDetails (7 cols | COMPUTED COL 6: LineTotal)
CREATE TABLE SalesOrderDetails (
    SODetailID INT IDENTITY(1,1) NOT NULL,
    SalesOrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,
    DiscountAmount DECIMAL(18,2) NOT NULL CONSTRAINT DF_SODetail_Discount DEFAULT 0,
    LineTotal AS (CAST((Quantity * UnitPrice) - DiscountAmount AS DECIMAL(18,2))),
    CONSTRAINT PK_SalesOrderDetails PRIMARY KEY CLUSTERED (SODetailID),
    CONSTRAINT CHK_SODetail_Qty CHECK (Quantity > 0),
    CONSTRAINT CHK_SODetail_UnitPrice CHECK (UnitPrice > 0),
    CONSTRAINT CHK_SODetail_Discount CHECK (DiscountAmount >= 0),
    CONSTRAINT FK_SODetail_SalesOrders FOREIGN KEY (SalesOrderID)
        REFERENCES SalesOrders(SalesOrderID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_SODetail_Products FOREIGN KEY (ProductID)
        REFERENCES Products (ProductID) ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Table 30: Shipments (12 cols | COMPUTED COL 7: TransitDays)
CREATE TABLE Shipments (
    ShipmentID INT IDENTITY(1,1) NOT NULL,
    SalesOrderID INT NOT NULL,
    CarrierID INT NOT NULL,
    TrackingNumber VARCHAR(100) NOT NULL,
    ContainerNumber VARCHAR(50) NOT NULL,
    PortOfOrigin VARCHAR(100) NOT NULL,
    PortOfDestination VARCHAR(100) NOT NULL,
    DispatchDate DATETIME NOT NULL,
    ExpectedDeliveryDate DATETIME NOT NULL,
    ActualDeliveryDate DATETIME NULL,
    TransitDays AS (DATEDIFF(DAY, DispatchDate, ActualDeliveryDate)),
    ShipmentStatus VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Shipments PRIMARY KEY CLUSTERED (ShipmentID),
    CONSTRAINT UQ_Shipments_TrackingNumber UNIQUE (TrackingNumber),
    CONSTRAINT CHK_Shipments_Status CHECK (ShipmentStatus IN ('InTransit', 'CustomsHold', 'Delivered', 'Delayed', 'Cancelled')),
    CONSTRAINT FK_Shipments_SalesOrders FOREIGN KEY (SalesOrderID)
        REFERENCES SalesOrders (SalesOrderID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_Shipments_Carriers FOREIGN KEY (CarrierID)
        REFERENCES Carriers (CarrierID) ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- ============================================================================
-- MODULE 4: AUDIT & GOVERNANCE
-- ============================================================================

-- Table 31: AuditLog (8 cols)
CREATE TABLE AuditLog (
    AuditID BIGINT IDENTITY(1,1) NOT NULL,
    TableName VARCHAR(100) NOT NULL,
    OperationType VARCHAR(20) NOT NULL,
    RecordID INT NOT NULL,
    ColumnName VARCHAR(100) NULL,
    OldValue NVARCHAR(MAX) NULL,
    NewValue NVARCHAR(MAX) NULL,
    ChangedAt DATETIME NOT NULL CONSTRAINT DF_AuditLog_ChangedAt DEFAULT GETDATE(),
    CONSTRAINT PK_AuditLog PRIMARY KEY CLUSTERED (AuditID),
    CONSTRAINT CHK_AuditLog_OpType CHECK (OperationType IN ('INSERT', 'UPDATE', 'DELETE'))
);
GO

-- ============================================================================
-- SCHEMA VERIFICATION: RETURN TOTAL ENTITY & ATTRIBUTE COUNT
-- ============================================================================
SELECT 
    COUNT(DISTINCT t.object_id) AS TotalEntitiesCreated,
    COUNT(c.column_id) AS TotalAttributesCreated
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id;
GO