package db

import "shop/internal/models"

func FetchEmployees() ([]models.Employee, error) {
	rows, err := DB.Query(`SELECT id, first_name, last_name FROM employees ORDER BY id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []models.Employee
	for rows.Next() {
		var e models.Employee
		if err := rows.Scan(&e.ID, &e.FirstName, &e.LastName); err != nil {
			return nil, err
		}
		list = append(list, e)
	}
	return list, nil
}
