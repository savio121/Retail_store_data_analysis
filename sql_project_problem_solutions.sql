
 /*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms), 
 both first name and last name are in upper case, customer_email,  customer_creation_year 
 and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C */
 
## Answer 1.
use orders;
SELECT 
    CUSTOMER_ID,
    CONCAT(
        CASE 
            WHEN LEFT(CUSTOMER_gender, 1) = 'M' THEN 'Mr. '
            WHEN LEFT(CUSTOMER_gender, 1) = 'F' THEN 'Ms. '
            
        END,
        UPPER(CUSTOMER_FNAME),
        ' ',
        UPPER(CUSTOMER_LNAME)
    ) AS CUSTOMER_FULL_NAME,
    CUSTOMER_EMAIL,
    YEAR(CUSTOMER_CREATION_DATE) AS CUSTOMER_CREATION_YEAR,
    CASE 
        WHEN YEAR(CUSTOMER_CREATION_DATE) < 2005 THEN 'Category A'
        WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2005 AND YEAR(CUSTOMER_CREATION_DATE) < 2011 THEN 'Category B'
        WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2011 THEN 'Category C'
    END AS CUSTOMER_CATEGORY
FROM ONLINE_CUSTOMER;


/* Q2. Write a query to display the following information for the products which
 have not been sold: product_id, product_desc, product_quantity_avail, product_price,
 inventory values (product_quantity_avail * product_price), New_Price after applying discount
 as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 20,000 then apply 20% discount 
ii) If Product Price > 10,000 then apply 15% discount 
iii) if Product Price =< 10,000 then apply 10% discount 
*/
## Answer 2.

SELECT 
    P.PRODUCT_ID,
    P.PRODUCT_DESC,
    P.PRODUCT_QUANTITY_AVAIL,
    P.PRODUCT_PRICE,
    (P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) AS INVENTORY_VALUE,
    CASE
        WHEN P.PRODUCT_PRICE > 20000 THEN (P.PRODUCT_PRICE * 0.8) -- 20% discount
        WHEN P.PRODUCT_PRICE > 10000 THEN (P.PRODUCT_PRICE * 0.85) -- 15% discount
        ELSE (P.PRODUCT_PRICE * 0.9) -- 10% discount
    END AS NEW_PRICE
FROM PRODUCT P
WHERE P.PRODUCT_ID NOT IN (
    SELECT DISTINCT OI.PRODUCT_ID
    FROM ORDER_ITEMS OI
);

/*Q3. Write a query to display Product_class_code, Product_class_desc, Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price). Information should be displayed for only those
 product_class_code which have more than 1,00,000 Inventory Value. Sort the output with respect to decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
Hint: 'count of product type in each product class' is the count of product_id based on product_class_code.
*/

## Answer 3.
SELECT 
    PC.PRODUCT_CLASS_CODE,
    PC.PRODUCT_CLASS_DESC,
    COUNT(P.PRODUCT_id) AS COUNT_OF_PRODUCT_TYPE,
    SUM(P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) AS INVENTORY_VALUE
FROM PRODUCT P
INNER JOIN PRODUCT_CLASS PC ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE
GROUP BY PC.PRODUCT_CLASS_CODE, PC.PRODUCT_CLASS_DESC
HAVING SUM(P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) > 100000
ORDER BY INVENTORY_VALUE DESC;




/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER]
Hint: USE SUBQUERY
*/
 
## Answer 4.
SELECT
    OC.customer_id,
    CONCAT(OC.customer_fname, ' ', OC.customer_lname) AS full_name,
    OC.customer_email,
    OC.customer_phone,
    A.country
FROM
    ONLINE_CUSTOMER OC
inner JOIN
    ADDRESS A
ON
    OC.address_id = A.address_id
WHERE
    OC.customer_id IN (
        SELECT OH.customer_id
        FROM ORDER_HEADER OH
        WHERE OH.order_status = 'Cancelled'
        GROUP BY OH.customer_id
        HAVING COUNT(*) = (SELECT COUNT(*) FROM ORDER_HEADER WHERE customer_id = OH.customer_id)
);



/*Q5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the shipper in the city ,
 number of consignment delivered to that city for Shipper DHL 
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
Hint: The answer should only be based on Shipper_Name -- DHL. The main intent is to find the number
 of customers and the consignments catered by DHL in each city.
 */

## Answer 5.  
SELECT
    'DHL' AS Shipper_Name,
    A.CITY AS Catering_City,
    COUNT(DISTINCT OC.CUSTOMER_ID) AS Num_Customers_Catered,
    COUNT(DISTINCT OH.ORDER_ID) AS Num_Consignments_Delivered
FROM
    ADDRESS A
INNER JOIN
    ONLINE_CUSTOMER OC ON A.address_id = OC.address_id
INNER JOIN
    ORDER_HEADER OH ON OC.CUSTOMER_ID = OH.CUSTOMER_ID
WHERE
    OH.SHIPPER_ID = (SELECT SHIPPER_ID FROM SHIPPER WHERE SHIPPER_NAME = 'DHL')
GROUP BY
    A.CITY;





/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and 
show inventory Status of products as per below condition: 

a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
Hint:  quantity sold here is product_quantity in order_items table. 
You may use multiple case statements to show inventory status (Low stock, In stock, and Enough stock)
 that meets both the conditions i.e. on products as well as on quantity.
The meaning of the rest of the categories, means products apart from electronics, computers, mobiles, and watches.
*/

## Answer 6.
SELECT
    P.PRODUCT_ID,
    P.PRODUCT_DESC,
    P.PRODUCT_QUANTITY_AVAIL,
    SUM(OI.PRODUCT_QUANTITY) AS QUANTITY_SOLD,
    CASE
        WHEN PC.PRODUCT_CLASS_DESC IN ('Electronics', 'Computer') THEN
            CASE
                WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.1 * SUM(OI.PRODUCT_QUANTITY) THEN 'Low inventory, need to add inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.5 * SUM(OI.PRODUCT_QUANTITY) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
        WHEN PC.PRODUCT_CLASS_DESC IN ('Mobiles', 'Watches') THEN
            CASE
                WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.2 * SUM(OI.PRODUCT_QUANTITY) THEN 'Low inventory, need to add inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.6 * SUM(OI.PRODUCT_QUANTITY) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
        ELSE
            CASE
                WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.3 * SUM(OI.PRODUCT_QUANTITY) THEN 'Low inventory, need to add inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.7 * SUM(OI.PRODUCT_QUANTITY) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
    END AS INVENTORY_STATUS
FROM
    PRODUCT P
INNER JOIN
    PRODUCT_CLASS PC ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE
LEFT JOIN
    ORDER_ITEMS OI ON P.PRODUCT_ID = OI.PRODUCT_ID
GROUP BY
    P.PRODUCT_ID, P.PRODUCT_DESC, P.PRODUCT_QUANTITY_AVAIL, PC.PRODUCT_CLASS_DESC;




/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
Hint: First find the volume of carton id 10 and then find the order id with products having total volume less than the volume of carton id 10
 */

## Answer 7.
SELECT
    OI.order_id,
    SUM(P.product_quantity_avail) AS total_order_volume
FROM
    CARTON C
JOIN
    ORDER_ITEMS OI ON C.carton_id = 10
JOIN
    PRODUCT P ON OI.product_id = P.product_id
GROUP BY
    OI.order_id
HAVING
    total_order_volume <= (SELECT len*height*width FROM CARTON WHERE carton_id = 10)
ORDER BY
    total_order_volume DESC
   limit 1 ;






/*Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) 
shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
*/

## Answer 8.
SELECT
    OC.CUSTOMER_ID,
    CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS CUSTOMER_FULL_NAME,
    SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY,
    SUM(OI.PRODUCT_QUANTITY * P.PRODUCT_PRICE) AS TOTAL_VALUE
FROM
    ONLINE_CUSTOMER OC
JOIN
    ORDER_HEADER OH ON OC.CUSTOMER_ID = OH.CUSTOMER_ID
JOIN
    ORDER_ITEMS OI ON OH.ORDER_ID = OI.ORDER_ID
JOIN
    PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID
WHERE
    OH.PAYMENT_MODE = 'Cash'
    AND OC.CUSTOMER_LNAME LIKE 'G%'
GROUP BY
    OC.CUSTOMER_ID, OC.CUSTOMER_FNAME, OC.CUSTOMER_LNAME;



/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold together 
with product id 201 and are not shipped to city Bangalore and New Delhi. 
Expected 5 rows in final output
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
Hint: Display the output in descending order with respect to the sum of product_quantity. 
(USE SUB-QUERY) In final output show only those products , 
 product_id’s which are sold with 201 product_id (201 should not be there in output) and are shipped except Bangalore and New Delhi
 */

## Answer 9.

    SELECT
    P.PRODUCT_ID,
    P.PRODUCT_DESC,
    SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
FROM
    PRODUCT P
JOIN
    ORDER_ITEMS OI ON P.PRODUCT_ID = OI.PRODUCT_ID
WHERE
    P.PRODUCT_ID != 201
    AND OI.ORDER_ID IN (
        SELECT OH.ORDER_ID
        FROM ORDER_HEADER OH
        JOIN ONLINE_CUSTOMER OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
        JOIN ADDRESS A ON OC.ADDRESS_ID = A.ADDRESS_ID
        WHERE OC.CUSTOMER_ID != 201
          AND A.CITY NOT IN ('Bangalore', 'New Delhi')
    )
GROUP BY
    P.PRODUCT_ID, P.PRODUCT_DESC
ORDER BY
    TOTAL_QUANTITY DESC
LIMIT 5;




/* Q10. Write a query to display the order_id, customer_id and customer fullname, 
total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS]	
 */

## Answer 10.
SELECT
    OH.ORDER_ID,
    OH.CUSTOMER_ID,
    CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS CUSTOMER_FULLNAME,
    SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
FROM
    ORDER_HEADER OH
JOIN
    ONLINE_CUSTOMER OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
JOIN
    ADDRESS A ON OC.ADDRESS_ID = A.ADDRESS_ID
JOIN
    ORDER_ITEMS OI ON OH.ORDER_ID = OI.ORDER_ID
WHERE
    OH.ORDER_ID % 2 = 0
    AND LEFT(A.PINCODE, 1) != '5'
GROUP BY
    OH.ORDER_ID, OH.CUSTOMER_ID, CUSTOMER_FULLNAME
    limit 15; 
    
 