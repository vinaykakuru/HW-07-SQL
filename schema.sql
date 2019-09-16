/* CREATE DATABASE "hw_07_Fraud_db"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;
*/

-- Create card_holder
CREATE TABLE card_holder (
  id INTEGER NOT NULL PRIMARY KEY,
  name VARCHAR NOT NULL
);

-- Create credit_card
CREATE TABLE credit_card (
  	card VARCHAR NOT NULL PRIMARY KEY,
  	card_holder_id INT NOT NULL,
	FOREIGN KEY (card_holder_id) REFERENCES card_holder(id)
);

-- Create merchant_category
CREATE TABLE merchant_category (
  	id INTEGER NOT NULL PRIMARY KEY,
  	name VARCHAR NOT NULL
);

-- Create merchant
CREATE TABLE merchant (
  	id INTEGER NOT NULL PRIMARY KEY,
  	name VARCHAR NOT NULL,
  	id_merchant_category INT NOT NULL,
	FOREIGN KEY (id_merchant_category) REFERENCES merchant_category(id)
);

-- Create Transaction Table
CREATE TABLE transactions (
  	id INTEGER NOT NULL PRIMARY KEY,
  	date TIMESTAMP NOT NULL,
  	amount FLOAT NOT NULL,
	card VARCHAR NOT NULL,
	FOREIGN KEY (card) REFERENCES credit_card(card),
	id_merchant INTEGER NOT NULL,
	FOREIGN KEY (id_merchant) REFERENCES merchant(id)
);