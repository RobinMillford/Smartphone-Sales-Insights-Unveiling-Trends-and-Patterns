use projects;

select * from dataset;

-- 1. Retrieve the distinct brand names
SELECT DISTINCT Brand
FROM dataset;

-- 2. the average selling price of all OPPO mobile phones.
SELECT AVG(Selling_Price) AS Avg_Selling_Price
FROM dataset
WHERE Brand = 'OPPO';

-- 3. the top 5 mobile phones with the highest original price
SELECT DISTINCT Brand, Mobile, Original_Price
FROM dataset
ORDER BY Original_Price DESC
LIMIT 5;

-- 4. the brand and model of mobile phones with a selling price higher than the average selling price
SELECT DISTINCT Brand, Mobile
FROM dataset
WHERE Selling_Price > (SELECT AVG(Selling_Price) FROM dataset);

-- 5. the brands and the average rating they have received
SELECT Brand, ROUND(AVG(Rating), 2) AS Average_Rating
FROM dataset
GROUP BY Brand;

-- 6. the brand, memory, and storage for mobiles with a discount percentage greater than 20%
SELECT DISTINCT Brand, Memory, Storage
FROM dataset
WHERE discount_percentage > 20;

-- 7. the brand with the maximum number of distinct models 
SELECT Brand, COUNT(DISTINCT Mobile) AS Num_Models
FROM dataset
GROUP BY Brand
ORDER BY Num_Models DESC
LIMIT 1;

-- 8. the top 3 brands with the highest average discount percentage
SELECT Brand, ROUND(AVG(discount_percentage), 2) AS Avg_Discount
FROM dataset
GROUP BY Brand
ORDER BY Avg_Discount DESC
LIMIT 3;

-- 9. the total number of mobiles available for each memory-storage combination
SELECT Memory, Storage, COUNT(*) AS Total_Mobiles
FROM dataset
GROUP BY Memory, Storage;

-- 10. the average selling price for each brand and storage combination. Display the brand, storage, and the average selling price
SELECT Brand, Storage, ROUND(AVG(Selling_Price)) AS Avg_Selling_Price
FROM dataset
GROUP BY Brand, Storage;

-- 11. the ratio of the sum of original prices to the sum of selling prices for each brand. Display the brand and the calculated ratio
SELECT Brand, ROUND(SUM(Original_Price) / SUM(Selling_Price), 2) AS Price_Ratio
FROM dataset
GROUP BY Brand;

-- 12. the brands based on the total count of models they have, and for each brand, show the top 2 models with the highest selling prices
WITH RankedBrands AS (
    SELECT Brand, Mobile, Selling_Price,
           RANK() OVER (PARTITION BY Brand ORDER BY Selling_Price DESC) AS Selling_Price_Rank
    FROM dataset
)
SELECT Brand, Mobile, Selling_Price
FROM RankedBrands
WHERE Selling_Price_Rank <= 2
ORDER BY Brand, Selling_Price_Rank;

-- 13. the models with the highest selling price for each brand that has at least one model with a rating above 4.4
SELECT DISTINCT cd1.Brand, cd1.Mobile, cd1.`Selling_Price`
FROM dataset cd1
WHERE cd1.Brand IN (
    SELECT Brand
    FROM dataset
    WHERE Rating > 4.4
)
AND cd1.`Selling_Price` = (
    SELECT MAX(`Selling_Price`)
    FROM dataset cd2
    WHERE cd1.Brand = cd2.Brand
)
ORDER BY cd1.Brand, cd1.Mobile;

-- 14. the average rating for each brand, and categorize the brands as 'Excellent', 'Good', or 'Average' based on their average ratings (≥ 4.5, ≥ 4.0 and < 4.5, < 4.0)
SELECT Brand,
       AVG(Rating) AS AvgRating,
       CASE
           WHEN AVG(Rating) >= 4.5 THEN 'Excellent'
           WHEN AVG(Rating) >= 4.0 THEN 'Good'
           ELSE 'Average'
       END AS RatingCategory
FROM dataset
GROUP BY Brand;

-- 15. Top-selling brands by revenue
SELECT Brand, SUM(`Selling_Price`) AS TotalRevenue
FROM dataset
GROUP BY Brand
ORDER BY TotalRevenue DESC
LIMIT 5;

-- 16. Price distribution analysis
SELECT Brand, 
       ROUND(AVG(`Selling_Price`), 2) AS AvgPrice, 
       ROUND(MAX(`Selling_Price`), 2) AS MaxPrice, 
       ROUND(MIN(`Selling_Price`), 2) AS MinPrice, 
       COUNT(*) AS TotalModels
FROM dataset
GROUP BY Brand;

-- 17. Customer preferences by brand and memory size
SELECT Brand, Memory, COUNT(*) AS TotalModels
FROM dataset
GROUP BY Brand, Memory
ORDER BY Brand, TotalModels DESC;

-- 18. Market share analysis
SELECT Brand, 
       COUNT(*) AS TotalModels, 
       (COUNT(*) / (SELECT COUNT(*) FROM dataset)) * 100 AS MarketShare
FROM dataset
GROUP BY Brand
ORDER BY MarketShare DESC;

-- 19. Price-performance ratio analysis
SELECT Brand, 
       AVG(`Rating`) AS AvgRating, 
       AVG(`Selling_Price` / `Original_Price`) AS PricePerformanceRatio
FROM dataset
GROUP BY Brand
ORDER BY PricePerformanceRatio DESC;

-- 20. Feature popularity analysis
SELECT Feature, 
       COUNT(*) AS TotalModels,
       (COUNT(*) / (SELECT COUNT(*) FROM dataset)) * 100 AS FeaturePercentage
FROM (
    SELECT DISTINCT Brand, 
                    CASE 
                        WHEN Memory = '12 GB' AND Storage = '512 GB' THEN 'Highest Memory, Highest Storage'
                        WHEN Memory = '8 GB' AND (Storage BETWEEN '128 GB' AND '256 GB') THEN 'High Memory, High Storage'
                        WHEN (Memory BETWEEN '4 GB' AND '6 GB') AND (Storage BETWEEN '32 GB' AND '64 GB') THEN 'Medium Memory, Medium Storage'
                        ELSE 'Other'
                    END AS Feature
    FROM dataset
) AS BrandFeatures
GROUP BY Feature
ORDER BY TotalModels DESC;