package db

import "shop/internal/models"

func FetchCategories() ([]models.Category, error) {
	rows, err := DB.Query(`SELECT id, name, COALESCE(description,'') FROM categories ORDER BY id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []models.Category
	for rows.Next() {
		var c models.Category
		if err := rows.Scan(&c.ID, &c.Name, &c.Description); err != nil {
			return nil, err
		}
		list = append(list, c)
	}
	return list, nil
}

func AddCategory(c models.Category) error {
	_, err := DB.Exec(`INSERT INTO categories (name, description) VALUES ($1,$2)`, c.Name, c.Description)
	return err
}

func UpdateCategory(c models.Category) error {
	_, err := DB.Exec(`UPDATE categories SET name=$1, description=$2 WHERE id=$3`, c.Name, c.Description, c.ID)
	return err
}

func DeleteCategory(id int) error {
	if _, err := DB.Exec(`UPDATE products SET category_id=NULL WHERE category_id=$1`, id); err != nil {
		return err
	}
	_, err := DB.Exec(`DELETE FROM categories WHERE id=$1`, id)
	return err
}
