CREATE DATABASE car_rental;
USE car_rental;

-- BASE VIEW
CREATE OR REPLACE VIEW vw_vehicle_base AS
SELECT
	Vehicle_Model, Mileage, Maintenance_History, Reported_Issues, Vehicle_Age, Fuel_Type, Transmission_Type, Engine_Size, Odometer_Reading, 
    Owner_Type, Insurance_Premium, Service_History, Fuel_Efficiency, Tire_Condition, Brake_Condition, Battery_Status, Need_Maintenance,
    Last_Service_Days, Warranty_Days_Left,
-- Maintenance status indicator for dashboards (Good / Needs Maintenance)
	CASE
		WHEN Need_Maintenance = 1
			OR Reported_Issues >= 3
            OR Brake_Condition = 'Worn Out'
            OR Battery_Status = 'Weak'
		THEN 'Needs Maintenance'
        ELSE 'Good Condition'
	END AS Maintenance_Status,
-- Maintenance urgency levels
	CASE
		WHEN Last_Service_Days > 900
        THEN 'Critical'
        WHEN Last_Service_Days BETWEEN 750 AND 900
		THEN 'High'
        WHEN Last_Service_Days BETWEEN 600 AND 749
		THEN 'Moderate'
        ELSE 'Low'
	END AS Maintenance_Due,
-- Availability Status
    CASE
	WHEN Need_Maintenance = 1
		OR Reported_Issues >= 3
		OR Brake_Condition = 'Worn Out'
		OR Battery_Status = 'Weak'
	THEN 'Not Available'
	ELSE 'Available'
	END AS Availability_Status
FROM vehicle_maintenance;

-- ANALYTICAL VIEWS
-- 1 Vehicles Currently Needing Maintenance
CREATE OR REPLACE VIEW vw_vehicles_needing_maintenance AS
SELECT *
FROM vw_vehicle_base
WHERE Maintenance_Status = 'Needs Maintenance';

-- 2 Count of Vehicles Needing Maintenance by Vehicle Model
CREATE OR REPLACE VIEW vw_maintenance_by_vehicle_model AS
SELECT
	Vehicle_Model,
    COUNT(*) AS Vehicles_Needing_Maintenance
FROM vw_vehicle_base
WHERE Maintenance_Status = 'Needs Maintenance'
GROUP BY Vehicle_Model;

-- 3 High Risk Vehicles (model) by Reported Issues, Brake, Battery
CREATE OR REPLACE VIEW vw_high_risk_vehicles AS
SELECT 
	Vehicle_Model,
    COUNT(*) AS High_Risk_Count
FROM vw_vehicle_base
WHERE Reported_Issues >= 3
	OR Brake_Condition = 'Worn Out'
    OR Battery_Status = 'Weak'
GROUP BY Vehicle_Model;
    
-- 4 Average Mileage & Fuel Efficiency by Vehicle Model
CREATE OR REPLACE VIEW vw_avg_mileage_fuel_efficiency AS
SELECT
	Vehicle_Model,
    ROUND(AVG(Mileage), 2) AS Avg_Mileage,
    ROUND(AVG(Fuel_Efficiency), 2) AS Avg_Fuel_Efficiency
FROM vw_vehicle_base
GROUP BY Vehicle_Model;

-- 5 Vehicles with Overdue Service or Expired Warranty
CREATE OR REPLACE VIEW vw_overdue_service_warranty AS
SELECT *
FROM vw_vehicle_base
WHERE Maintenance_Due IN ('Critical', 'High');

-- 6 Maintenance Risk by Owner Type
CREATE OR REPLACE VIEW vw_avg_risk_by_owner_type AS
SELECT
	Owner_Type,
    ROUND((COUNT(CASE WHEN Maintenance_Status = 'Needs Maintenance' THEN 1 END) * 100.0) / COUNT(*), 2) AS Maintenance_Percentage
FROM vw_vehicle_base
GROUP BY owner_type;


-- KPI VIEWS
-- 1 Total Vehicles
CREATE OR REPLACE VIEW kpi_total_vehicles AS
SELECT COUNT(*) AS Total_Vehicles
FROM vw_vehicle_base;

-- 2 Vehicles Needing Maintenance
CREATE OR REPLACE VIEW kpi_vehicles_needing_maintenance AS 
SELECT COUNT(*) AS Vehicles_Needing_Maintenance
FROM vw_vehicle_base
WHERE Maintenance_Status = 'Needs Maintenance';

-- 3 High Risk Vehicles
CREATE OR REPLACE VIEW kpi_high_risk_vehicles AS
SELECT COUNT(*) AS High_Risk_Vehicles
FROM vw_vehicle_base
WHERE Reported_Issues >= 3
	OR Brake_Condition = 'Worn Out'
    OR Battery_Status = 'Weak';

-- 4 Percentage Needing Maintenance
CREATE OR REPLACE VIEW kpi_maintenance_percentage AS 
SELECT
	ROUND((COUNT(CASE WHEN Maintenance_Status = 'Needs Maintenance' THEN 1 END) * 1.0) / COUNT(*), 4) AS Maintenance_Percentage
FROM vw_vehicle_base;

-- 5 Vehicles in Good Condition
CREATE OR REPLACE VIEW kpi_vehicles_good_condition AS
SELECT COUNT(*) AS Vehicles_Good_Condition
FROM vw_vehicle_base
WHERE Maintenance_Status = 'Good Condition';

-- 6 Vehicles with Overdue Service or Expired Warranty
CREATE OR REPLACE VIEW kpi_vehicles_due AS
SELECT COUNT(*) AS Overdue_Vehicles
FROM vw_vehicle_base
WHERE Maintenance_Due IN ('Critical', 'High');





