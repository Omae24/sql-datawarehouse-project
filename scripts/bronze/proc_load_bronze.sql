/* 
**************************************************************************
Script purpose:
This script defines the stored procedure of the bronze layer.
It loads data from external CSV files. It truncates and bulk inserts the data into the tables.
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS

BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME,  @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT ' ====================================================================';
        PRINT ' Truncating and inserting data from sources crm and erp';
        PRINT ' ====================================================================';

        PRINT ' Truncating and inserting data from source crm...';
        PRINT ' -------------------------------------------------------------------';
        PRINT ' Truncating and inserting data into TABLE bronze.stagingcrm_cust_info';
        
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.stagingcrm_cust_info;
        BULK INSERT bronze.stagingcrm_cust_info
        FROM 'C:\Users\Admin\Documents\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
    
        );
        SET @end_time = GETDATE();
        PRINT ' >> load duration:' + CAST (DATEDIFF( second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
       
        PRINT ' -----------------------------------------------------------------------------------';
        PRINT ' Inserting data into Table bronze.crm_cust_info .......';
        
      
        INSERT INTO bronze.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
        SELECT cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, CONVERT(DATE, cst_create_date, 103)
        FROM bronze.stagingcrm_cust_info;

        PRINT ' -----------------------------------------------------------------------------------';
        PRINT ' Truncating and inserting data into TABLE bronze.stagingcrm_prd_info....';
        
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.stagingcrm_prd_info;
        BULK INSERT bronze.stagingcrm_prd_info
        FROM 'C:\Users\Admin\Documents\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
    
        );
        SET @end_time = GETDATE();
        PRINT ' >> load duration:' + CAST (DATEDIFF( second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT ' -----------------------------------------------------------------------------------';
        
        PRINT ' Inseting data into Table bronze.crm_prd_info...............';
        INSERT INTO bronze.crm_prd_info (prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
        SELECT prd_id, prd_key, prd_nm, prd_cost, prd_line, CONVERT(DATETIME, prd_start_dt, 103), CONVERT(DATETIME, prd_end_dt, 103)
        FROM bronze.stagingcrm_prd_info;
    
        PRINT ' -----------------------------------------------------------------------------------';
        PRINT ' Truncating and inserting data into TABLE bronze.crm_sales_details.......';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_sales_details;
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\Admin\Documents\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
    
        );
        SET @end_time = GETDATE();
        PRINT ' >> load duration:' + CAST (DATEDIFF( second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT ' -----------------------------------------------------------------------------------';
        
        PRINT ' Truncating and inserting data into TABLE bronze.stagingerp_cust_az12.............';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.stagingerp_cust_az12;
        BULK INSERT bronze.stagingerp_cust_az12
        FROM 'C:\Users\Admin\Documents\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
    
        );
        SET @end_time = GETDATE();
        PRINT ' >> load duration:' + CAST (DATEDIFF( second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT ' -----------------------------------------------------------------------------------';
        
        PRINT ' Inserting data into Table bronze.erp_cust_az12............... '
        INSERT INTO bronze.erp_cust_az12 (cid, bdate, gen)
        SELECT cid, CONVERT(DATE, bdate, 103), gen
        FROM bronze.stagingerp_cust_az12;

        PRINT ' -----------------------------------------------------------------------------------';
        PRINT ' Truncating and inserting data into TABLE bronze.erp_loc_a101.....'
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_loc_a101;
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\Admin\Documents\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
    
        );
        SET @end_time = GETDATE();
        PRINT ' >> load duration:' + CAST (DATEDIFF( second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT ' -----------------------------------------------------------------------------------';
        PRINT ' Truncating and inserting data into TABLE bronze.erp_px_cat_g1v2...................';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\Admin\Documents\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
    
        );
        SET @end_time = GETDATE();
        PRINT ' >> load duration:' + CAST (DATEDIFF( second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        SET @batch_end_time = GETDATE();
        PRINT ' -----------------------------------------------------------------------------------';
        PRINT ' loading bronze layer is completed';
        PRINT ' >> load duration for the whole bronze layer:' + CAST (DATEDIFF( second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';

    END TRY
    BEGIN CATCH
        PRINT '===================================================================';
        PRINT 'Error occured when loaading the bronze layer';
        PRINT '===================================================================';

    END CATCH
END
GO

