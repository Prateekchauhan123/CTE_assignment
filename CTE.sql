-- Q1 First  Normal Form (1NF)> Identify a table in the Sakila database that violates 1NF,Explain how you would normalize it to achieve 1NF.
-- Identifying a 1NF Violation in the Sakila Database

-- Table: film_actor
-- Violation: The film_id column is likely stored as a comma-separated list of film IDs associated with each actor. This violates 1NF because a single cell contains multiple values, making the data non-atomic.
-- Normalization to 1NF:
-- To normalize the film_actor table to 1NF, we need to create a new table to store the relationship between films and actors. This new table will have the following columns:
-- 1.	film_actor_id: A unique identifier for each film-actor relationship.
-- 2.	film_id: A foreign key referencing the film table.
-- 3.	actor_id: A foreign key referencing the actor table.
-- New Table Structure:
 CREATE TABLE film_actor_junction (
   film_actor_id INT PRIMARY KEY AUTO_INCREMENT,
     film_id INT,
     actor_id INT,
    FOREIGN KEY (film_id) REFERENCES film(film_id),
   FOREIGN KEY (actor_id) REFERENCES actor(actor_id)
 );
-- Normalization Process:
-- 1.	Create the new table: Execute the SQL statement above to create the film_actor_junction table.
-- 2.	Populate the new table: Insert rows into the new table, extracting the individual film IDs from the comma-separated list in the original film_actor table.
-- 3.	Update the original table: Remove the film_id column from the original film_actor table, leaving only the actor_id.
-- Benefits of Normalization:
-- •	Data Integrity: Ensures that each cell contains only a single value, preventing data inconsistencies and anomalies.
-- •	Data Redundancy: Reduces data redundancy by eliminating the need to store the same film ID multiple times for a given actor.
-- •	Query Performance: Improves query performance by allowing for efficient indexing and retrieval of data.
-- •	Data Flexibility: Makes it easier to add, modify, or delete data without affecting other parts of the database.

-- Q2   Choose a table in Sakila and describe how you would determine whether it is in  2NF. If it violates 2NF,explain the steps to normalize it
-- Analyzing the rental Table for 2NF

-- Table: rental
-- Columns:
-- •	rental_id
-- •	rental_date
-- •	return_date
-- •	customer_id
-- •	staff_id
-- •	inventory_id
-- 2NF Violation:
-- The rental table violates 2NF because it contains a transitive dependency:
-- •	rental_id (primary key) is functionally dependent on rental_date.
-- •	rental_date is functionally dependent on customer_id (through the rental and customer tables).
-- •	Therefore, rental_id is transitively dependent on customer_id.
-- This transitive dependency indicates that the table is not in 2NF.
-- Normalization to 2NF
-- To normalize the rental table to 2NF, we need to decompose it into two new tables:
-- 1.	rental_details: This table will contain the details of each rental, including the rental ID, rental date, return date, and inventory ID.
-- 2.	rental_customer: This table will store the relationship between rentals and customers, including the rental ID and customer ID.

CREATE TABLE rental_details (
     rental_id INT PRIMARY KEY,
     rental_date DATE,
     return_date DATE,
    inventory_id INT,
    FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id)
 );

CREATE TABLE rental_customer (
     rental_id INT,
    customer_id INT,
     PRIMARY KEY (rental_id, customer_id),
     FOREIGN KEY (rental_id) REFERENCES rental_details(rental_id),
     FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- Q3 Identify a table in Sakila that violates 3NF. Describe the transitive dependencies present and outline the steps to normalize the table to 3NF.
-- 3NF Violation:
-- The film table violates 3NF due to the following transitive dependencies:
-- 1.	rental_duration is functionally dependent on rental_rate.
-- 2.	rental_rate is functionally dependent on film_id (primary key).
-- 3.	Therefore, rental_duration is transitively dependent on film_id.
-- This transitive dependency indicates that the table is not in 3NF.
-- Normalization to 3NF
-- To normalize the film table to 3NF, we need to decompose it into two new tables:
-- 1.	film_details: This table will contain the details of each film, including the film ID, title, description, release year, language ID, length, replacement cost, rating, and last update.
-- 2.	film_rental_info: This table will store the rental information for each film, including the film ID, rental duration, and rental rate.
CREATE TABLE film_details (
    film_id INT PRIMARY KEY,
    title VARCHAR(255),
    description TEXT,
    release_year YEAR,
    language_id INT,
    length SMALLINT,
    replacement_cost DECIMAL(10,2),
    rating VARCHAR(5),
    last_update TIMESTAMP,
    FOREIGN KEY (language_id) REFERENCES language(language_id)
);

CREATE TABLE film_rental_info (
    film_id INT,
    rental_duration TINYINT,
    rental_rate DECIMAL(4,2),
    PRIMARY KEY (film_id),
    FOREIGN KEY (film_id) REFERENCES film_details(film_id)
);
-- Q4 Take a specific table in Sakila and guide through the process of normalizing it from the initial unnormalized form up to at least 2NF.
-- Initial Unnormalized Form
-- The actor table in Sakila is already in 1NF because it contains only atomic values. However, it can be further normalized to 2NF.
-- Initial actor table structure:
-- SQL
CREATE TABLE actor (
    actor_id INT PRIMARY KEY,
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    last_update TIMESTAMP
);
-- Identifying 2NF Violations
-- While the actor table is already in 1NF, it doesn't have any transitive dependencies. Therefore, it is already in 2NF.
-- Normalization to 2NF
-- As there are no 2NF violations, the actor table remains unchanged.
-- Normalized actor table structure:
-- SQL
CREATE TABLE actor (
    actor_id INT PRIMARY KEY,
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    last_update TIMESTAMP
);
-- Conclusion:
-- The actor table in Sakila is already in 2NF and does not require further normalization. Its structure is efficient and adheres to database normalization principles.

-- Q5 Write a query using a CTE to retrieve the distinct list of actor names and the number of films they have acted in from the and tables.

WITH ActorFilmCounts AS (
    SELECT
        a.first_name,
        a.last_name,
        COUNT(fa.film_id) AS num_films
    FROM
        actor a
    INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
    GROUP BY
        a.first_name,
        a.last_name
)
SELECT
    first_name,
    last_name,
    num_films
FROM
    ActorFilmCounts;

-- Q6 Use a recursive CTE to generate a hierarchical list of categories and their subcategories from the table in Sakila.
WITH RECURSIVE CategoryHierarchy AS (
    SELECT
        category_id,
        name AS category_name,
        NULL AS parent_id
    FROM
        category
    WHERE
        parent_id IS NULL
    UNION ALL
    SELECT
        c.category_id,
        c.name AS category_name,
        ch.category_id AS parent_id
    FROM
        category c
    INNER JOIN CategoryHierarchy ch ON c.parent_id = ch.category_id
)
SELECT
    category_name,
    parent_id
FROM
    CategoryHierarchy;
-- Q7 Create a CTE that combines information from the and tables to display the film title, language name, and rental rate.

WITH FilmLanguageRental AS (
    SELECT
        f.title,
        l.name AS language_name,
        f.rental_rate
    FROM
        film f
    INNER JOIN language l ON f.language_id = l.language_id
)
SELECT
    *
FROM
    FilmLanguageRental;

-- Q8 Write a query using a CTE to find the total revenue generated by each customer (sum of payments) from the and tables.
WITH CustomerPayments AS (
    SELECT
        p.customer_id,
        SUM(p.amount) AS total_payments
    FROM
        payment p
    GROUP BY
        p.customer_id
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    cp.total_payments
FROM
    customer c
INNER JOIN CustomerPayments cp ON c.customer_id = cp.customer_id;

-- Q9 Utilize a CTE with a window function to rank films based on their rental duration from the table.

WITH FilmRentalDuration AS (
    SELECT
        film_id,
        rental_duration,
        RANK() OVER (ORDER BY rental_duration DESC) AS rental_duration_rank
    FROM
        film
)
SELECT
    f.film_id,
    f.title,
    frd.rental_duration_rank
FROM
    film f
INNER JOIN FilmRentalDuration frd ON f.film_id = frd.film_id;

-- Q10 Create a CTE to list customers who have made more than two rentals, and then join this CTE with the customer table to retrieve additional customer details.

WITH CustomersWithMultipleRentals AS (
    SELECT
        customer_id
    FROM
        rental
    GROUP BY
        customer_id
    HAVING
        COUNT(*) > 2
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email
FROM
    customer c
INNER JOIN CustomersWithMultipleRentals cmr ON c.customer_id = cmr.customer_id;

-- Q11 Write a query using a CTE to find the total number of rentals made each month, considering the rental date from rental the table.
WITH MonthlyRentalCounts AS (
    SELECT
        DATE_TRUNC('month', rental_date) AS rental_month,
        COUNT(*) AS num_rentals
    FROM
        rental
    GROUP BY
        rental_month
)
SELECT
    rental_month,
    num_rentals
FROM
    MonthlyRentalCounts;

-- Q12 Implement a recursive CTE to find all employees in the staff table who report to a specific manager, considering report to the column.
WITH RECURSIVE EmployeeHierarchy AS (
    SELECT
        staff_id,
        first_name,
        last_name,
        reports_to
    FROM
        staff
    WHERE
        reports_to = <manager_id>
    UNION ALL
    SELECT
        s.staff_id,
        s.first_name,
        s.last_name,
        s.reports_to
    FROM
        staff
    INNER JOIN EmployeeHierarchy eh ON s.reports_to = eh.staff_id
);
SELECT
    staff_id,
    first_name,
    last_name
FROM
    EmployeeHierarchy;


