package db

import "shop/models"

func FetchProducts() ([]models.ProductRow, error) {
	rows, err := DB.Query(`
		SELECT p.id, p.name, COALESCE(p.unit,''), COALESCE(p.description,''), p.price,
		       COALESCE(c.name,'—'), COALESCE(s.company_name,'—'),
		       COALESCE(st.quantity, 0)
		FROM products p
		LEFT JOIN categories c  ON c.id  = p.category_id
		LEFT JOIN suppliers  s  ON s.id  = p.supplier_id
		LEFT JOIN storages   st ON st.product_id = p.id
		ORDER BY p.id DESC LIMIT 100`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []models.ProductRow
	for rows.Next() {
		var r models.ProductRow
		if err := rows.Scan(&r.ID, &r.Name, &r.Unit, &r.Description, &r.Price,
			&r.CategoryName, &r.SupplierName, &r.Quantity); err != nil {
			return nil, err
		}
		list = append(list, r)
	}
	return list, nil
}

// FetchProductsSimple — для селекта в форме заказа
func FetchProductsSimple() ([]models.ProductRow, error) {
	rows, err := DB.Query(`
		SELECT p.id, p.name, COALESCE(p.unit,''), '', p.price, '', '', COALESCE(st.quantity,0)
		FROM products p
		LEFT JOIN storages st ON st.product_id = p.id
		ORDER BY p.name`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []models.ProductRow
	for rows.Next() {
		var r models.ProductRow
		if err := rows.Scan(&r.ID, &r.Name, &r.Unit, &r.Description, &r.Price,
			&r.CategoryName, &r.SupplierName, &r.Quantity); err != nil {
			return nil, err
		}
		list = append(list, r)
	}
	return list, nil
}

func AddProduct(p models.Product) error {
	var productID int
	err := DB.QueryRow(
		`INSERT INTO products (name, unit, description, price, category_id, supplier_id)
		 VALUES ($1,$2,$3,$4,$5,$6) RETURNING id`,
		p.Name, p.Unit, p.Description, p.Price,
		nullableInt(p.CategoryID), nullableInt(p.SupplierID),
	).Scan(&productID)
	if err != nil {
		return err
	}
	// создаём запись на складе сразу
	_, err = DB.Exec(`INSERT INTO storages (product_id, quantity) VALUES ($1, 0)`, productID)
	return err
}

func UpdateProduct(p models.Product) error {
	_, err := DB.Exec(
		`UPDATE products SET name=$1, unit=$2, description=$3, price=$4, category_id=$5, supplier_id=$6 WHERE id=$7`,
		p.Name, p.Unit, p.Description, p.Price,
		nullableInt(p.CategoryID), nullableInt(p.SupplierID), p.ID)
	return err
}

func DeleteProduct(id int) error {
	// сначала убираем зависимые строки
	if _, err := DB.Exec(`DELETE FROM order_details WHERE product_id=$1`, id); err != nil {
		return err
	}
	if _, err := DB.Exec(`DELETE FROM reviews WHERE product_id=$1`, id); err != nil {
		return err
	}
	// storages удалится каскадно (ON DELETE CASCADE по схеме)
	_, err := DB.Exec(`DELETE FROM products WHERE id=$1`, id)
	return err
}

func UpdateStock(productID, quantity int) error {
	_, err := DB.Exec(
		`UPDATE storages SET quantity=$1, updated_at=NOW() WHERE product_id=$2`,
		quantity, productID)
	return err
}

func nullableInt(v int) interface{} {
	if v == 0 {
		return nil
	}
	return v
}
