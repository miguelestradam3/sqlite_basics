-- =============================================================================
-- Query 1: Vehicle Profitability & Margin Breakdown by Make & Model
-- Description: Calculates revenue, costs, net profit, and profit margins.
-- =============================================================================
SELECT 
    s.Make,
    s.Model,
    COUNT(il.InvoiceLineID) AS TotalUnitsSold,
    SUM(il.SalePrice) AS TotalRevenue,
    SUM(s.CostPrice + s.SpareParts + s.LaborCost) AS TotalCost,
    SUM(il.SalePrice - (s.CostPrice + s.SpareParts + s.LaborCost)) AS TotalProfit,
    ROUND(AVG(il.SalePrice - (s.CostPrice + s.SpareParts + s.LaborCost)) * 100.0 / AVG(il.SalePrice), 2) AS AverageProfitMarginPct
FROM Stock s
JOIN InvoiceLines il ON s.StockID = il.StockID
GROUP BY s.Make, s.Model
ORDER BY TotalProfit DESC;

-- =============================================================================
-- Query 2: Client Segmentation & Regional Performance Analysis
-- Description: Aggregates performance by client demographics and regions.
-- =============================================================================
SELECT 
    c.ClientType,
    c.ClientSize,
    co.CountryName,
    COUNT(DISTINCT c.ClientID) AS UniqueClients,
    COUNT(i.InvoiceID) AS TotalInvoices,
    SUM(il.SalePrice) AS GrossSales,
    ROUND(AVG(i.TotalDiscount), 2) AS AvgDiscountGiven,
    ROUND(AVG(i.DeliveryCharge), 2) AS AvgDeliveryCharge
FROM Clients c
JOIN Countries co ON c.CountryID = co.CountryID
LEFT JOIN Invoices i ON c.ClientID = i.ClientID
LEFT JOIN InvoiceLines il ON i.InvoiceID = il.InvoiceID
GROUP BY c.ClientType, c.ClientSize, co.CountryName
ORDER BY GrossSales DESC;

-- =============================================================================
-- Query 3: Quarterly Revenue Trends & Seasonality Analytics
-- Description: Tracks revenue growth, sales volume, and discounting by quarter.
-- =============================================================================
SELECT 
    d.Year,
    d.QuarterFull,
    COUNT(DISTINCT i.InvoiceID) AS InvoiceCount,
    SUM(il.SalePrice) AS QuarterlyRevenue,
    ROUND(AVG(il.SalePrice), 2) AS AverageLineSalePrice,
    SUM(i.TotalDiscount) AS TotalQuarterlyDiscounts
FROM Invoices i
JOIN DateDimension d ON i.InvoiceDateKey = d.DateKey
JOIN InvoiceLines il ON i.InvoiceID = il.InvoiceID
GROUP BY d.Year, d.QuarterFull, d.YearAndQuarterNum
ORDER BY d.YearAndQuarterNum ASC;

-- =============================================================================
-- Query 4: Inventory Efficiency: Vehicle Age & Mileage Impact on Profitability
-- Description: Analyzes margins based on vehicle age brackets and mileage tiers.
-- =============================================================================
SELECT 
    CASE 
        WHEN s.VehicleAgeInYears < 3 THEN 'Under 3 Years'
        WHEN s.VehicleAgeInYears BETWEEN 3 AND 6 THEN '3-6 Years'
        ELSE 'Over 6 Years'
    END AS AgeGroup,
    CASE 
        WHEN s.Mileage < 30000 THEN 'Low Mileage (<30k)'
        WHEN s.Mileage BETWEEN 30000 AND 70000 THEN 'Medium Mileage (30k-70k)'
        ELSE 'High Mileage (>70k)'
    END AS MileageGroup,
    COUNT(il.InvoiceLineID) AS UnitsSold,
    ROUND(AVG(il.SalePrice), 2) AS AvgSalePrice,
    ROUND(AVG(s.CostPrice + s.SpareParts + s.LaborCost), 2) AS AvgTotalCost,
    ROUND(AVG(il.SalePrice - (s.CostPrice + s.SpareParts + s.LaborCost)), 2) AS AvgProfitPerUnit
FROM Stock s
JOIN InvoiceLines il ON s.StockID = il.StockID
GROUP BY AgeGroup, MileageGroup
ORDER BY AvgProfitPerUnit DESC;