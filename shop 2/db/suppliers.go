package db

import "shop/models"

func FetchSuppliers() ([]models.Supplier, error) {
	rows, err := DB.Query(`
		SELECT id, company_name,
		       COALESCE(contact_person,''), COALESCE(email,''),
		       COALESCE(phone_number,''), COALESCE(address,'')
		FROM suppliers ORDER BY id DESC LIMIT 100`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []models.Supplier
	for rows.Next() {
		var s models.Supplier
		if err := rows.Scan(&s.ID, &s.CompanyName, &s.ContactPerson, &s.Email, &s.Phone, &s.Address); err != nil {
			return nil, err
		}
		list = append(list, s)
	}
	return list, nil
}

func AddSupplier(s models.Supplier) error {
	_, err := DB.Exec(
		`INSERT INTO suppliers (company_name, contact_person, email, phone_number, address) VALUES ($1,$2,$3,$4,$5)`,
		s.CompanyName, s.ContactPerson, s.Email, s.Phone, s.Address)
	return err
}

func UpdateSupplier(s models.Supplier) error {
	_, err := DB.Exec(
		`UPDATE suppliers SET company_name=$1, contact_person=$2, email=$3, phone_number=$4, address=$5 WHERE id=$6`,
		s.CompanyName, s.ContactPerson, s.Email, s.Phone, s.Address, s.ID)
	return err
}

func DeleteSupplier(id int) error {
	// supplier_id UNIQUE — обнуляем ссылку перед удалением
	if _, err := DB.Exec(`UPDATE products SET supplier_id=NULL WHERE supplier_id=$1`, id); err != nil {
		return err
	}
	_, err := DB.Exec(`DELETE FROM suppliers WHERE id=$1`, id)
	return err
}
