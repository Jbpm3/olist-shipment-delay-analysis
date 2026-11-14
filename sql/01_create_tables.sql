CREATE TABLE customers(
    customer_id varchar(32) PRIMARY KEY,
    customer_unique_id varchar(32) NOT NULL,
    customer_zip_code_prefix VARCHAR(5) NOT NULL,
    customer_city TEXT NOT NULL,
    customer_state TEXT
);

CREATE TABLE orders (
    order_id varchar(32) PRIMARY KEY,
    customer_id varchar(32) NOT NULL REFERENCES customers(customer_id),
    order_status TEXT NOT NULL,
    order_purchase_timestamp TIMESTAMP NOT NULL,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP NOT NULL
);


