package db

import "shop/internal/models"

func FetchCustomers() ([]models.Customer, error) {
	rows, err := DB.Query(`
		SELECT id, first_name, last_name,
		       COALESCE(address,''), COALESCE(email,''), COALESCE(phone_number,'')
		FROM customers ORDER BY id DESC LIMIT 100`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []models.Customer
	for rows.Next() {
		var c models.Customer
		if err := rows.Scan(&c.ID, &c.FirstName, &c.LastName, &c.Address, &c.Email, &c.Phone); err != nil {
			return nil, err
		}
		list = append(list, c)
	}
	return list, nil
}

func AddCustomer(c models.Customer) error {
	_, err := DB.Exec(
		`INSERT INTO customers (first_name, last_name, address, email, phone_number) VALUES ($1,$2,$3,$4,$5)`,
		c.FirstName, c.LastName, c.Address, c.Email, c.Phone)
	return err
}

func UpdateCustomer(c models.Customer) error {
	_, err := DB.Exec(
		`UPDATE customers SET first_name=$1, last_name=$2, address=$3, email=$4, phone_number=$5 WHERE id=$6`,
		c.FirstName, c.LastName, c.Address, c.Email, c.Phone, c.ID)
	return err
}

func DeleteCustomer(id int) error {
	if _, err := DB.Exec(`UPDATE orders SET customer_id=NULL WHERE customer_id=$1`, id); err != nil {
		return err
	}
	if _, err := DB.Exec(`DELETE FROM reviews WHERE customer_id=$1`, id); err != nil {
		return err
	}
	_, err := DB.Exec(`DELETE FROM customers WHERE id=$1`, id)
	return err
}
