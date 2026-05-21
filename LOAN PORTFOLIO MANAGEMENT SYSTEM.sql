CREATE TABLE borrowers_info1 (
     borrower_id INT PRIMARY KEY AUTO_INCREMENT,
     first_name VARCHAR(50) NOT NULL,
     last_name VARCHAR(50) NOT NULL,
     email VARCHAR(100) UNIQUE NOT NULL,
     phone VARCHAR(20),
     date_of_birth DATE NOT NULL,
     national_id VARCHAR(50) UNIQUE NOT NULL,
     employment_status ENUM('employed', 'self_employed', 'unemployed', 'retired') NOT NULL,
     monthly_income DECIMAL(12,2) NOT NULL,
     credit_score INT CHECK (credit_score BETWEEN 300 AND 850),
     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
     );
    INSERT INTO borrowers_info1
         (first_name, last_name, email, phone, date_of_birth, national_id, employment_status, monthly_income, credit_score)
    VALUES
         ('Miracle', 'Agoha', 'miracle.agoha@gmail.com', '080-2341-7658', '1990-03-15', 'NID-001-AGOHA', 'employed',  5500.00, 720),
         ('Alex', 'Jared', 'alex.jared@gmail.com', '080-7869-3425', '1986-05-22', 'NID-002-JARED', 'self_employed', 8200.00, 680),
         ('Navabi', 'Haru', 'navabi.haru@gmail.com', '080-5645-1233', '1995-11-09', 'NID-003-HARU', 'employed', 4100.00, 755);
		
        
 SELECT
	 borrower_id,
     CONCAT(first_name, ' ', last_name) AS full_name,
     employment_status,
     monthly_income,
     credit_score
 FROM borrowers_info;    
 
 CREATE TABLE loan_officers (
      officer_id       INT PRIMARY KEY AUTO_INCREMENT,
      first_name       VARCHAR(50) NOT NULL,
      last_name        VARCHAR(50) NOT NULL,
      email            VARCHAR(100) UNIQUE NOT NULL,
      phone            VARCHAR(20),
      branch           VARCHAR(100) NOT NULL,
      hired_date       DATE         NOT NULL,
      created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
 );
 
 INSERT INTO loan_officers 
      (first_name, last_name, email, phone, branch, hired_date)
 VALUES
      ('John', 'Doe', 'john.doe@bank.com', '080-1432-7642', 'Lagos Main Branch', '2019-04-10'),
      ('Sarah', 'Eze', 'Sarah.eze@bank.com', '090-3246-2314', 'Port-hacourt Branch', '2021-08-04');
    
   
SELECT
	officer_id,
    CONCAT(first_name, ' ', last_name)
    branch,
    hired_date
FROM loan_officers;    
   
   
CREATE TABLE loans (
     load_id        INT PRIMARY KEY AUTO_INCREMENT,
     officer_id     INT NOT NULL,
     loan_type      ENUM('personal', 'mortgage', 'business', 'auto', 'education') NOT NULL,
     principal      DECIMAL(15, 2) NOT NULL,
     interest_rate  DECIMAL(5, 2) NOT NULL,
     term_months    INT           NOT NULL,
     start_date     DATE          NOT NULL,
     sta_tus         ENUM('active', 'closed', 'defaulted', 'pending') DEFAULT 'pending',
     created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     
     FOREIGN KEY (officer_id)  REFERENCES loan_officers(officer_id)
);     
   
    DROP TABLE loans;
  
  
   CREATE TABLE loans (
     loan_id        INT PRIMARY KEY AUTO_INCREMENT,
     borrower_id    INT NOT NULL,
     officer_id     INT NOT NULL,
     loan_type      ENUM('personal', 'mortgage', 'business', 'auto', 'education') NOT NULL,
     principal      DECIMAL(15, 2) NOT NULL,
     interest_rate  DECIMAL(5, 2) NOT NULL,
     term_months    INT           NOT NULL,
     start_date     DATE          NOT NULL,
     end_date       DATE          NOT NULL,
     loan_status         ENUM('active', 'closed', 'defaulted', 'pending') DEFAULT 'pending',
     created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     FOREIGN KEY (borrower_id) REFERENCES borrowers_info1(borrower_id), 
     FOREIGN KEY (officer_id)  REFERENCES loan_officers(officer_id)
);     
   
   INSERT INTO loans
       (borrower_id, officer_id, loan_type, principal, interest_rate, term_months, start_date, end_date, loan_status)
  VALUES
       (1, 1, 'personal', 10000.00, 12.50, 24, '2024-01-10', '2026-01-10', 'active'),
       (2, 1, 'business', 25000.00, 10.00, 36, '2024-03-01', '2027-03-01', 'active'),
       (3, 2, 'education', 8000.00, 8.75,  18,  '2024-06-01', '2025-12-01', 'active');
   

   
	SELECT
		loan_id,
        borrower_id,
        officer_id,
        loan_type,
		principal,
        interest_rate,
        term_months,
        loan_status,
        start_date,
        end_date
   FROM  loans;    
         
   ALTER TABLE loans
   RENAME COLUMN load_id TO loan_id;
        
        
    CREATE TABLE repayment_schedule (
         schedule_id      INT PRIMARY KEY AUTO_INCREMENT,
         loan_id          INT NOT NULL,
         due_date         DATE           NOT NULL,
         amount_due       DECIMAL(15, 2) NOT NULL,
         loan_status      ENUM('pending', 'paid', 'overdue') DEFAULT 'pending',
         created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
         
         FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
      );   
        
        
         CREATE TABLE payments (
           payment_id         INT PRIMARY KEY AUTO_INCREMENT,
           loan_id            INT NOT NULL,
           schedule_id        INT NOT NULL,
           payment_date       DATE           NOT NULL,
           amount_paid        DECIMAL(15, 2) NOT NULL,
           payment_method     ENUM('bank_transfer', 'cash', 'card', 'mobile_money') NOT NULL,
           created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
           
           FOREIGN KEY (loan_id)     REFERENCES loans(loan_id),
           FOREIGN KEY (schedule_id) REFERENCES repayment_schedule(schedule_id)
    );       
        
         CREATE TABLE risk_flags (
              flag_id         INT PRIMARY KEY AUTO_INCREMENT,
              loan_id         INT NOT NULL,
              borrower_id     INT NOT NULL,
              flag_type       ENUM('late_payment', 'missed_payment', 'default_risk', 'suspicious_activity') NOT NULL,
              severity        ENUM('low', 'medium', 'high') NOT NULL,
              description     TEXT,
              flagged_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
              resolved        TINYINT(1) DEFAULT 0,
              resolved_at     TIMESTAMP NULL,
              
              FOREIGN KEY (loan_id)     REFERENCES loans(loan_id),
              FOREIGN KEY (borrower_id) REFERENCES borrowers_info1(borrower_id)
         );     
        
SHOW TABLES;
        
DELIMITER $$
CREATE PROCEDURE generate_repayment_schedule(IN p_loan_id INT)
BEGIN
    DECLARE v_principal    DECIMAL(15, 2);
    DECLARE v_annual_rate  DECIMAL(5, 2);
    DECLARE v_term_months  INT;
    DECLARE v_start_date   DATE;
    DECLARE v_monthly_rate DECIMAL(10, 6);
    DECLARE v_monthly_pay  DECIMAL(15, 2);
    DECLARE v_counter      INT DEFAULT 1;
    
    SELECT principal, interest_rate, term_months, start_date
    INTO v_principal, v_annual_rate, v_term_months, v_start_date
    FROM loans
    WHERE loan_id = p_loan_id;
    
    SET v_monthly_rate = v_annual_rate / 100 / 12;
    
    
SET v_monthly_pay = v_principal *
 (
   v_monthly_rate * POW(1 + v_monthly_rate, v_term_months)
   ) /
   (
        POW(1 + v_monthly_rate, v_term_months) - 1
   );
   
   WHILE v_counter <= v_term_months DO
        INSERT INTO repayment_schedule (loan_id, due_date, amount_due, loan_status)
        VALUES (
             p_loan_id,
             DATE_ADD(v_start_date, INTERVAL v_counter MONTH),
             v_monthly_pay,
             'pending'
         );
         SET v_counter = v_counter + 1;
       END WHILE;
       
  END$$
  
  DELIMITER ;
    
     CALL generate_repayment_schedule(1);   
	 CALL generate_repayment_schedule(2); 
	 CALL generate_repayment_schedule(3);   
     
     
     
    SELECT * FROM  repayment_schedule;
     
     
	SHOW TABLES;
	SELECT * FROM borrowers_info1;
	SELECT * FROM loans;
    SELECT * FROM repayment_schedule;
         
           SELECT * FROM payments;
           SELECT * FROM risk_flags;
         
 INSERT INTO risk_flags
      (loan_id, borrower_id, flag_type, severity, description)
VALUES
  (2, 2, 'late_payment', 'medium', 'Borrower has consistently paid after due date for 3 consecutive months'),
  
  (;
         
        SELECT * FROM risk_flags; 
         
         SELECT
			l.loan_id,
            CONCAT(b.first_name, ' ', b.last_name) AS borrower_name,
            rs.due_date,
            rs.amount_due,
            rs.loan_status,
            DATEDIFF(CURDATE(), rs.due_date)       AS days_overdue,
            CASE
                WHEN DATEDIFF(CURDATE(), rs.due_date) BETWEEN 1 AND 30  THEN '30 days'
                WHEN DATEDIFF(CURDATE(), rs.due_date) BETWEEN 31 AND 60 THEN '60 days'
				WHEN DATEDIFF(CURDATE(), rs.due_date) BETWEEN 61 AND 90 THEN '90 days'
			    WHEN DATEDIFF(CURDATE(), rs.due_date) > 90              THEN '90+ days'
                ELSE 'Not Overdue'
            END                                              AS delinquency_bucket
         FROM repayment_schedule rs
         JOIN loans l ON rs.loan_id = l.loan_id
         JOIN borrowers_info1 b ON l.borrower_id = b.borrower_id
         WHERE rs.loan_status = 'pending'
         AND rs.due_date < CURDATE()
         ORDER BY days_overdue DESC;
         
         WITH payment_summary AS (
             SELECT 
                  l.loan_id,
                  l.borrower_id,
                  CONCAT(b.first_name, ' ', b.last_name) AS borrower_name,
                  COUNT(rs.schedule_id)                  AS total_installments,
                  SUM(CASE WHEN p.payment_id IS NOT NULL
					  THEN 1 ELSE 0 END)                 AS payments_made,
				  SUM(CASE WHEN p.payment_date > rs.due_date
					  THEN 1 ELSE 0 END)                 AS late_payments
				 FROM repayment_schedule rs
                 JOIN loans l ON rs.loan_id = l.loan_id
                 JOIN borrowers_info1 b ON l.borrower_id = b.borrower_id
                 LEFT JOIN payments p ON rs.schedule_id = p.schedule_id
                 GROUP BY l.loan_id, l.borrower_id, borrower_name
		)
        SELECT 
			loan_id,
            borrower_name,
            total_installments,
            payments_made,
            late_payments,
            ROUND((payments_made / total_installments) * 100, 2) AS health_score_pct,
            CASE
               WHEN (payments_made / total_installments) * 100 >= 80 THEN 'Good'
               WHEN (payments_made / total_installments) * 100 >= 50 THEN 'Fair'
               ELSE 'poor'
            END AS health_status
          FROM payment_summary
          ORDER BY  health_score_pct DESC;
          
          SELECT
               l.loan_type,
               COUNT(l.loan_id)                            AS total_loans,
               SUM(l.principal)                            AS total_principal,
               SUM(l.principal - COALESCE(
                   (SELECT SUM(p.amount_paid)
                    FROM payments p
                    WHERE p.loan_id = l.loan_id), 0)) AS outstanding_balance,
               CASE
                  WHEN AVG(b.credit_score) >= 740 THEN 'Low Risk'
                  WHEN AVG(b.credit_score) >= 670 THEN 'Medium Risk'
                  ELSE 'High risk'
               END                                          AS risk_tier
             FROM loans l
             JOIN borrowers_info1 b ON l.borrower_id = b.borrower_id
             GROUP BY l.loan_type
             ORDER BY outstanding_balance DESC;
          
                            
          
          
          SELECT
          CONCAT(lo.first_name, ' ', lo.last_name) AS officer_name,
                  lo.branch,
                  COUNT(l.loan_id)                         AS total_loans_managed,
                  SUM(CASE WHEN l.loan_status = 'defaulted'
					  THEN 1 ELSE 0 END)                   AS total_defaults,
				 COUNT(rf.flag_id)               AS total_risk_flags,
                 SUM(l.principal)                          AS portolio_value,
                 CASE
                    WHEN SUM(CASE WHEN l.loan_status = 'defaulted'
                          THEN 1 ELSE 0 END) = 0
                     AND COUNT(rf.flag_id) = 0 THEN 'Excellent'
					WHEN COUNT(rf.flag_id) <= 2 THEN 'Good'
                    WHEN COUNT(rf.flag_id) <= 5 THEN 'Fair'
                    ELSE 'Poor'
            END AS performance_rating
           FROM loan_officers lo
          JOIN loans l ON lo.officer_id = l.officer_id
          LEFT JOIN risk_flags rf ON l.loan_id = rf.loan_id
          GROUP BY lo.officer_id, officer_name, lo.branch
          ORDER BY total_risk_flags DESC;
          
          
           SELECT 
                  l.loan_id,
                  CONCAT(b.first_name, ' ', b.last_name) AS borrower_name,
                  p.payment_date,
                  p.amount_paid,
                  l.principal,
                  SUM(p.amount_paid) OVER (
                      PARTITION BY l.loan_id
                      ORDER BY p.payment_date
                      )                                         AS cummulative_paid,
                       l.principal - SUM(p.amount_paid) OVER (
                      PARTITION BY l.loan_id
                      ORDER BY p.payment_date
                      )                                         AS remaining_balance
                  FROM payments p
                  JOIN loans l ON p.loan_id = l.loan_id
                  JOIN borrowers_info1 b ON l.borrower_id = b.borrower_id
                  ORDER BY l.loan_id, p.payment_date;
                  
                  
                  
                  
                  #BORROWER LOAN SUMMARY
                  
                  CREATE VIEW borrower_loan_summary AS 
                  SELECT
                       l.loan_id,
                       CONCAT(b.first_name, ' ', b.last_name) AS borrower_name,
                       b.credit_score,
                       l.loan_type,
                       l.principal,
                       l.interest_rate,
                       l.term_months,
                       l.loan_status,
                       l.start_date,
                       l.end_date
                FROM loans l
                JOIN borrowers_info1 b ON l.borrower_id = b.borrower_id;
          
          
          #Loan risk dashboard
          
          CREATE VIEW loan_risk_dashboard AS
          SELECT
               CONCAT(b.first_name, ' ', b.last_name) AS borrower_name,
               l.loan_type,
               l.principal,
               rf.flag_type,
               rf.severity,
               rf.description,
               rf.resolved
           FROM risk_flags rf
           JOIN loans l ON rf.loan_id = l.loan_id
           JOIN borrowers_info1 b ON rf.borrower_id = b.borrower_id;
          
          
          SELECT* FROM borrower_loan_summary;
          SELECT* FROM loan_risk_dashboard;
          
          
          

          
          
          
          
          
          
          
          
          
          
          
          
          
         
         
         
         
         
         
         
         
                
                
            
     
     
     
     
     
        
        