USE MSN_TexWeave_DB;
GO

-- ============================================================================
-- SECTION 1: ENTERPRISE ANALYTICAL VIEWS
-- ============================================================================

-- VIEW 1: Production Quality, Yield, and Scrap Analysis
CREATE OR ALTER VIEW dbo.vw_ProductionQualityAndYield
AS
SELECT 
    po.ProductionOrderID,
    po.OrderNumber AS ProductionOrderNumber,
    po.BatchNumber,
    po.ProductID,
    p.ProductSKU,
    p.ProductName,
    po.Status AS ProductionStatus,
    po.StartDate,
    po.EndDate,
    po.DurationDays,
    po.TargetQuantity,
    po.ProducedQuantity,
    po.ProductionEfficiency,
    ISNULL(qc_agg.TotalInspectedQuantity, 0) AS TotalInspectedQuantity,
    ISNULL(qc_agg.TotalDefectQuantity, 0) AS TotalDefectQuantity,
    CAST(
        (ISNULL(qc_agg.TotalDefectQuantity, 0) * 100.0) / 
        NULLIF(ISNULL(qc_agg.TotalInspectedQuantity, 0), 0) 
        AS DECIMAL(5, 2)
    ) AS BatchDefectRatePct,
    ISNULL(qc_agg.PassedChecksCount, 0) AS PassedChecksCount,
    ISNULL(qc_agg.FailedChecksCount, 0) AS FailedChecksCount,
    ISNULL(qc_agg.ReworkChecksCount, 0) AS ReworkChecksCount,
    CASE 
        WHEN po.ProducedQuantity >= po.TargetQuantity AND ISNULL(qc_agg.FailedChecksCount, 0) = 0 THEN 'Optimal Yield'
        WHEN po.ProducedQuantity < po.TargetQuantity THEN 'Under-Produced'
        WHEN ISNULL(qc_agg.FailedChecksCount, 0) > 0 THEN 'High Quality Risk'
        ELSE 'In Progress'
    END AS BatchHealthStatus
FROM dbo.ProductionOrders po
INNER JOIN dbo.Products p 
    ON po.ProductID = p.ProductID
LEFT JOIN (
    SELECT 
        qc.ProductionOrderID,
        SUM(qc.InspectedQuantity) AS TotalInspectedQuantity,
        SUM(qc.DefectQuantity) AS TotalDefectQuantity,
        SUM(CASE WHEN qc.CheckResult = 'Passed' THEN 1 ELSE 0 END) AS PassedChecksCount,
        SUM(CASE WHEN qc.CheckResult = 'Failed' THEN 1 ELSE 0 END) AS FailedChecksCount,
        SUM(CASE WHEN qc.CheckResult = 'Rework' THEN 1 ELSE 0 END) AS ReworkChecksCount
    FROM dbo.QualityChecks qc
    GROUP BY qc.ProductionOrderID
) qc_agg 
    ON po.ProductionOrderID = qc_agg.ProductionOrderID;
GO


-- VIEW 2: Finished Goods Inventory Health & Capital Valuation
CREATE OR ALTER VIEW dbo.vw_InventoryStockHealthAndValuation
AS
SELECT 
    fgi.FGInventoryID,
    fgi.WarehouseID,
    fgi.BatchNumber,
    p.ProductID,
    p.ProductSKU,
    p.ProductName,
    p.UnitOfMeasure,
    p.CostPrice,
    p.BasePrice,
    fgi.QuantityOnHand,
    fgi.ReservedQuantity,
    (fgi.QuantityOnHand - fgi.ReservedQuantity) AS AvailableStock,
    CAST(
        (fgi.ReservedQuantity * 100.0) / NULLIF(fgi.QuantityOnHand, 0) 
        AS DECIMAL(5, 2)
    ) AS AllocationPct,
    CAST((fgi.QuantityOnHand * p.CostPrice) AS DECIMAL(18, 2)) AS InventoryValueAtCost,
    CAST((fgi.QuantityOnHand * p.BasePrice) AS DECIMAL(18, 2)) AS ProjectedRevenuePotential,
    CAST(((fgi.QuantityOnHand * p.BasePrice) - (fgi.QuantityOnHand * p.CostPrice)) AS DECIMAL(18, 2)) AS ProjectedGrossMargin,
    CASE 
        WHEN fgi.QuantityOnHand = 0 THEN 'Out of Stock'
        WHEN (fgi.QuantityOnHand - fgi.ReservedQuantity) = 0 THEN '100% Reserved (Commitment Alert)'
        WHEN (fgi.QuantityOnHand - fgi.ReservedQuantity) < 100 THEN 'Low Available Stock'
        ELSE 'Healthy Stock'
    END AS StockRiskCategory,
    fgi.LastUpdated
FROM dbo.FinishedGoodsInventory fgi
INNER JOIN dbo.Products p 
    ON fgi.ProductID = p.ProductID;
GO


-- VIEW 3: Procurement Spend & Vendor Fulfillment Pipeline
CREATE OR ALTER VIEW dbo.vw_ProcurementSupplierFulfillment
AS
SELECT 
    po.POID,
    po.PONumber,
    po.SupplierID,
    po.OrderDate,
    po.ExpectedDeliveryDate,
    po.Status AS POStatus,
    po.TotalAmount AS HeaderTotalAmount,
    COUNT(pod.PODetailID) AS TotalLineItems,
    SUM(pod.QuantityOrdered) AS TotalOrderedQuantity,
    SUM(pod.ReceivedQuantity) AS TotalReceivedQuantity,
    (SUM(pod.QuantityOrdered) - SUM(pod.ReceivedQuantity)) AS OutstandingQuantityToReceive,
    CAST(
        (SUM(pod.ReceivedQuantity) * 100.0) / NULLIF(SUM(pod.QuantityOrdered), 0) 
        AS DECIMAL(5, 2)
    ) AS FulfillmentRatePct,
    CAST(
        SUM(pod.QuantityOrdered * pod.UnitPrice) 
        AS DECIMAL(18, 2)
    ) AS CalculatedLineTotalValue,
    CASE 
        WHEN po.Status = 'Received' THEN 'Fulfilled'
        WHEN po.Status = 'Cancelled' THEN 'Cancelled'
        WHEN GETDATE() > po.ExpectedDeliveryDate AND po.Status <> 'Received' THEN 'Overdue Delivery'
        ELSE 'Active Procurement'
    END AS DeliveryComplianceStatus
FROM dbo.PurchaseOrders po
LEFT JOIN dbo.PurchaseOrderDetails pod 
    ON po.POID = pod.POID
GROUP BY 
    po.POID, 
    po.PONumber, 
    po.SupplierID, 
    po.OrderDate, 
    po.ExpectedDeliveryDate, 
    po.Status, 
    po.TotalAmount;
GO


-- VIEW 4: Sales Order Fulfillment & Logistics OTIF (On-Time In-Full)
CREATE OR ALTER VIEW dbo.vw_SalesFulfillmentAndLogisticsOTIF
AS
SELECT 
    so.SalesOrderID,
    so.OrderNumber AS SalesOrderNumber,
    so.CustomerID,
    so.Channel,
    so.OrderDate,
    so.ExpectedShipDate,
    so.Status AS SalesOrderStatus,
    so.SubTotal,
    so.TaxAmount,
    so.TotalAmount,
    s.ShipmentID,
    s.CarrierID,
    s.TrackingNumber,
    s.ContainerNumber,
    s.PortOfOrigin,
    s.PortOfDestination,
    s.ShipmentStatus,
    s.DispatchDate,
    s.ExpectedDeliveryDate AS LogisticsExpectedDeliveryDate,
    s.ActualDeliveryDate,
    s.TransitDays,
    DATEDIFF(DAY, so.OrderDate, s.DispatchDate) AS OrderToDispatchLeadDays,
    DATEDIFF(DAY, s.ExpectedDeliveryDate, s.ActualDeliveryDate) AS DeliveryVarianceDays,
    CASE 
        WHEN s.ActualDeliveryDate IS NOT NULL AND s.ActualDeliveryDate <= s.ExpectedDeliveryDate THEN 1 
        ELSE 0 
    END AS IsDeliveredOnTime,
    CASE 
        WHEN so.Status = 'Delivered' AND s.ShipmentStatus = 'Delivered' AND s.ActualDeliveryDate <= s.ExpectedDeliveryDate THEN 'OTIF Met'
        WHEN so.Status = 'Delivered' AND s.ActualDeliveryDate > s.ExpectedDeliveryDate THEN 'Delivered Late'
        WHEN s.ShipmentStatus = 'InTransit' AND GETDATE() > s.ExpectedDeliveryDate THEN 'Delayed In Transit'
        WHEN s.ShipmentStatus = 'InTransit' THEN 'On Schedule'
        WHEN s.ShipmentID IS NULL THEN 'Unfulfilled Backlog'
        ELSE 'Processing'
    END AS OTIFClassification
FROM dbo.SalesOrders so
LEFT JOIN dbo.Shipments s 
    ON so.SalesOrderID = s.SalesOrderID;
GO


-- ============================================================================
-- SECTION 2: EXECUTIVE KPI REPORTING QUERIES
-- ============================================================================

-- KPI 1: Executive C-Suite Operational Scorecard (Single-Row KPI Metric Summary)
SELECT 
    -- 1. Financial Performance
    (SELECT ISNULL(SUM(TotalAmount), 0) FROM dbo.SalesOrders WHERE Status IN ('Confirmed', 'Shipped', 'Delivered')) AS TotalRecognizedRevenue,
    (SELECT ISNULL(SUM(TotalAmount), 0) FROM dbo.PurchaseOrders WHERE Status IN ('Approved', 'Received')) AS TotalProcurementSpend,
    
    -- 2. Inventory Health & Capital
    (SELECT ISNULL(SUM(InventoryValueAtCost), 0) FROM dbo.vw_InventoryStockHealthAndValuation) AS TotalCapitalTiedInStock,
    (SELECT CAST(AVG(AllocationPct) AS DECIMAL(5, 2)) FROM dbo.vw_InventoryStockHealthAndValuation) AS AvgWarehouseAllocationPct,
    
    -- 3. Production & Quality Yield
    (SELECT CAST((SUM(TotalDefectQuantity) * 100.0) / NULLIF(SUM(TotalInspectedQuantity), 0) AS DECIMAL(5, 2)) FROM dbo.vw_ProductionQualityAndYield) AS GlobalScrapDefectRatePct,
    (SELECT CAST((SUM(PassedChecksCount) * 100.0) / NULLIF(SUM(PassedChecksCount + FailedChecksCount + ReworkChecksCount), 0) AS DECIMAL(5, 2)) FROM dbo.vw_ProductionQualityAndYield) AS OverallFirstPassYieldRatePct,
    
    -- 4. Logistics On-Time Performance (OTIF)
    (SELECT CAST((SUM(IsDeliveredOnTime) * 100.0) / NULLIF(COUNT(ShipmentID), 0) AS DECIMAL(5, 2)) FROM dbo.vw_SalesFulfillmentAndLogisticsOTIF WHERE ActualDeliveryDate IS NOT NULL) AS GlobalOnTimeDeliveryRatePct;
GO

-- KPI 2: Channel Profitability & Fulfillment Turnaround (Domestic vs. Export)
SELECT 
    Channel,
    COUNT(SalesOrderID) AS TotalOrdersCount,
    SUM(TotalAmount) AS TotalRevenue,
    AVG(OrderToDispatchLeadDays) AS AvgDispatchLeadDays,
    SUM(IsDeliveredOnTime) AS OnTimeDeliveries,
    CAST((SUM(IsDeliveredOnTime) * 100.0) / NULLIF(COUNT(ShipmentID), 0) AS DECIMAL(5, 2)) AS ChannelOTIFRatePct
FROM dbo.vw_SalesFulfillmentAndLogisticsOTIF
GROUP BY Channel;
GO

-- KPI 3: Inventory Exposure & Risk Summary (Items Needing Production Reorder)
SELECT 
    StockRiskCategory,
    COUNT(ProductID) AS SKUCount,
    SUM(QuantityOnHand) AS TotalQuantityOnHand,
    SUM(ReservedQuantity) AS TotalReservedQuantity,
    SUM(AvailableStock) AS TotalAvailableStock,
    SUM(InventoryValueAtCost) AS TotalValuationAtCost
FROM dbo.vw_InventoryStockHealthAndValuation
GROUP BY StockRiskCategory
ORDER BY TotalValuationAtCost DESC;
GO

-- KPI 4: Vendor Delivery Performance & Fulfillment Ranking
SELECT 
    SupplierID,
    COUNT(POID) AS TotalPOsPlaced,
    SUM(HeaderTotalAmount) AS TotalCommittedSpend,
    SUM(TotalOrderedQuantity) AS TotalUnitsOrdered,
    SUM(TotalReceivedQuantity) AS TotalUnitsReceived,
    CAST((SUM(TotalReceivedQuantity) * 100.0) / NULLIF(SUM(TotalOrderedQuantity), 0) AS DECIMAL(5, 2)) AS SourcingFulfillmentPct,
    SUM(CASE WHEN DeliveryComplianceStatus = 'Overdue Delivery' THEN 1 ELSE 0 END) AS OverdueShipmentsCount
FROM dbo.vw_ProcurementSupplierFulfillment
GROUP BY SupplierID
ORDER BY TotalCommittedSpend DESC;
GO


-- ============================================================================
-- SECTION 3: VALIDATION AND SANITY CHECKS (NX-27 PROOF)
-- ============================================================================

-- View Validation 1: Production Quality View
SELECT TOP 5 * FROM dbo.vw_ProductionQualityAndYield;

-- View Validation 2: Inventory Valuation View
SELECT TOP 5 * FROM dbo.vw_InventoryStockHealthAndValuation;

-- View Validation 3: Supplier Fulfillment View
SELECT TOP 5 * FROM dbo.vw_ProcurementSupplierFulfillment;

-- View Validation 4: Sales OTIF View
SELECT TOP 5 * FROM dbo.vw_SalesFulfillmentAndLogisticsOTIF;
GO