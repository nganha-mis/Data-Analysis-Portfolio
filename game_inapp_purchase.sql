SELECT COUNT(*) AS TotalRows FROM mobile_game_inapp_purchases;
SELECT MIN(InAppPurchaseAmount) AS MinSpend, 
       MAX(InAppPurchaseAmount) AS MaxSpend, 
       AVG(InAppPurchaseAmount) AS AvgSpend 
FROM mobile_game_inapp_purchases;
CREATE VIEW View_Game_Analytics_Final AS
SELECT 
    *,
    -- Biến NULL thành 0 để tính toán không bị lỗi
    ISNULL(InAppPurchaseAmount, 0) AS Clean_Purchase_Amount,

    -- Thêm cột phân loại để so sánh các nhóm người dùng
    CASE 
        WHEN InAppPurchaseAmount IS NULL OR InAppPurchaseAmount = 0 THEN 'Non-Payer'
        ELSE 'Payer'
    END AS User_Status
FROM mobile_game_inapp_purchases;
SELECT TOP 10 * FROM View_Game_Analytics_Final;
ALTER VIEW View_Game_Analytics_Final AS
SELECT 
    UserID,
    Age,
    Gender,
    Country,
    Device,
    GameGenre,
    SessionCount,
    AverageSessionLength,
    SpendingSegment,
    
    -- 1. Xử lý cột Tiền: NULL thành 0
    ISNULL(InAppPurchaseAmount, 0) AS Clean_Purchase_Amount,
    
    -- 2. Xử lý Phương thức thanh toán: NULL thành 'None'
    ISNULL(PaymentMethod, 'None') AS Clean_Payment_Method,
    
    -- 3. Giữ nguyên Date và Days để Tableau phân tích logic NULL
    FirstPurchaseDaysAfterInstall,
    LastPurchaseDate,
    
    -- 4. Thêm cột Phân loại (Trọng tâm để so sánh Payer vs Non-Payer)
    CASE 
        WHEN InAppPurchaseAmount > 0 THEN 'Payer'
        ELSE 'Non-Payer'
    END AS User_Status
FROM mobile_game_inapp_purchases;
-- Kiểm tra xem có giá trị nào lạ trong các cột phân loại không
SELECT DISTINCT Country FROM View_Game_Analytics_Final;
SELECT DISTINCT Gender FROM View_Game_Analytics_Final;
SELECT DISTINCT Device FROM View_Game_Analytics_Final;
SELECT 
    MIN(Age) AS MinAge, MAX(Age) AS MaxAge,
    MIN(SessionCount) AS MinSession, MAX(SessionCount) AS MaxSession,
    MIN(AverageSessionLength) AS MinDuration, MAX(AverageSessionLength) AS MaxDuration
FROM View_Game_Analytics_Final;
ALTER VIEW View_Game_Analytics_Final AS
SELECT 
    UserID,
    Age,
    -- 1. Xử lý Gender: NULL thành 'Unknown'
    ISNULL(Gender, 'Unknown') AS Gender,
    
    -- 2. Xử lý Country: NULL thành 'Unknown'
    ISNULL(Country, 'Unknown') AS Country,
    
    -- 3. Xử lý Device: NULL thành 'Unknown'
    ISNULL(Device, 'Unknown') AS Device,
    
    SessionCount,
    AverageSessionLength,
    GameGenre,
    SpendingSegment,
    
    -- Xử lý tiền và trạng thái (giữ nguyên logic cũ)
    ISNULL(InAppPurchaseAmount, 0) AS Purchase_Amount,
    CASE 
        WHEN InAppPurchaseAmount > 0 THEN 'Payer'
        ELSE 'Non-Payer' 
    END AS User_Status,
    
    -- Các trường khác
    ISNULL(PaymentMethod, 'None') AS Payment_Method,
    FirstPurchaseDaysAfterInstall,
    LastPurchaseDate
FROM mobile_game_inapp_purchases;