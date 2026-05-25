package db

import "shop/models"

// 1. Количество товаров в указанной категории
func CountProductsInCategory(categoryID int) (string, int, error) {
	var catName string
	var count int
	err := DB.QueryRow(`
		SELECT c.name, COUNT(p.id)
		FROM categories c
		LEFT JOIN products p ON p.category_id = c.id
		WHERE c.id = $1
		GROUP BY c.id, c.name`, categoryID).Scan(&catName, &count)
	return catName, count, err
}

// 2. Количество товаров, отсутствующих на складе
func CountOutOfStock() (int, error) {
	var count int
	err := DB.QueryRow(`SELECT COUNT(*) FROM storages WHERE quantity = 0`).Scan(&count)
	return count, err
}

// 3. Объём продаж за период
func SalesByPeriod(from, to string) ([]models.SalesRow, error) {
	rows, err := DB.Query(`
		SELECT p.name, SUM(od.quantity) AS sold, SUM(od.quantity * p.price) AS revenue
		FROM order_details od
		JOIN products p ON p.id = od.product_id
		JOIN orders   o ON o.id = od.order_id
		WHERE o.date BETWEEN $1 AND $2
		GROUP BY p.id, p.name
		ORDER BY revenue DESC`, from, to)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []models.SalesRow
	for rows.Next() {
		var r models.SalesRow
		if err := rows.Scan(&r.ProductName, &r.Sold, &r.Revenue); err != nil {
			return nil, err
		}
		list = append(list, r)
	}
	return list, nil
}

// 4. Общая сумма заказов за текущий месяц
func OrdersTotalCurrentMonth() (float64, error) {
	var total float64
	err := DB.QueryRow(`
		SELECT COALESCE(SUM(od.quantity * p.price), 0)
		FROM order_details od
		JOIN products p ON p.id = od.product_id
		JOIN orders   o ON o.id = od.order_id
		WHERE date_trunc('month', o.date) = date_trunc('month', CURRENT_DATE)`).Scan(&total)
	return total, err
}

// 5. Количество поставок от конкретного поставщика
func DeliveriesBySupplierID(supplierID int) (string, int, error) {
	var supplierName string
	var count int
	err := DB.QueryRow(`
		SELECT s.company_name, COUNT(DISTINCT d.id)
		FROM suppliers s
		LEFT JOIN products      p  ON p.supplier_id  = s.id
		LEFT JOIN order_details od ON od.product_id  = p.id
		LEFT JOIN deliveries    d  ON d.order_id     = od.order_id
		WHERE s.id = $1
		GROUP BY s.id, s.company_name`, supplierID).Scan(&supplierName, &count)
	return supplierName, count, err
}

// 6. Топ-10 наиболее продаваемых товаров
func TopProducts() ([]models.TopProduct, error) {
	rows, err := DB.Query(`
		SELECT p.name, SUM(od.quantity) AS total_sold
		FROM order_details od
		JOIN products p ON p.id = od.product_id
		GROUP BY p.id, p.name
		ORDER BY total_sold DESC
		LIMIT 10`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []models.TopProduct
	for rows.Next() {
		var r models.TopProduct
		if err := rows.Scan(&r.ProductName, &r.TotalSold); err != nil {
			return nil, err
		}
		list = append(list, r)
	}
	return list, nil
}
