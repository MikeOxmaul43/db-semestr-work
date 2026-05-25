package db

import (
	"fmt"
	"log"
	"shop/internal/models"
)

func FetchOrders() ([]models.OrderRow, error) {
	rows, err := DB.Query(`
		SELECT o.id,
		       COALESCE(o.status,''),
		       o.date::text,
		       COALESCE(c.first_name||' '||c.last_name, '—'),
		       COALESCE(e.first_name||' '||e.last_name, '—')
		FROM orders o
		LEFT JOIN customers c ON c.id = o.customer_id
		LEFT JOIN employees e ON e.id = o.employee_id
		ORDER BY o.id DESC LIMIT 100`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []models.OrderRow
	for rows.Next() {
		var r models.OrderRow
		if err := rows.Scan(&r.ID, &r.Status, &r.Date, &r.CustomerName, &r.EmployeeName); err != nil {
			return nil, err
		}
		list = append(list, r)
	}
	return list, nil
}

func FetchOrderDetails(orderID int) ([]models.OrderDetailRow, error) {
	rows, err := DB.Query(`
		SELECT p.name, od.quantity, p.price, (od.quantity * p.price) AS total
		FROM order_details od
		JOIN products p ON p.id = od.product_id
		WHERE od.order_id = $1`, orderID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []models.OrderDetailRow
	for rows.Next() {
		var r models.OrderDetailRow
		if err := rows.Scan(&r.ProductName, &r.Quantity, &r.Price, &r.Total); err != nil {
			return nil, err
		}
		list = append(list, r)
	}
	return list, nil
}

func AddOrder(customerID, employeeID int, items []models.OrderItem) error {
	tx, err := DB.Begin()
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback()

	var cid, eid interface{}
	if customerID != 0 {
		cid = customerID
	}
	if employeeID != 0 {
		eid = employeeID
	}

	var orderID int
	err = tx.QueryRow(
		`INSERT INTO orders (status, customer_id, employee_id) VALUES ('pending', $1, $2) RETURNING id`,
		cid, eid,
	).Scan(&orderID)
	if err != nil {
		return fmt.Errorf("insert order: %w", err)
	}
	log.Printf("[AddOrder] created order id=%d", orderID)

	for _, item := range items {
		log.Printf("[AddOrder] inserting order_detail order_id=%d product_id=%d quantity=%d", orderID, item.ProductID, item.Quantity)
		_, err = tx.Exec(
			`INSERT INTO order_details (order_id, product_id, quantity) VALUES ($1, $2, $3)`,
			orderID, item.ProductID, item.Quantity,
		)
		if err != nil {
			return fmt.Errorf("insert order_detail product_id=%d: %w", item.ProductID, err)
		}

		_, err = tx.Exec(
			`UPDATE storages SET quantity = quantity - $1, updated_at = NOW() WHERE product_id = $2`,
			item.Quantity, item.ProductID,
		)
		if err != nil {
			return fmt.Errorf("update storages product_id=%d: %w", item.ProductID, err)
		}
	}

	return tx.Commit()
}

func UpdateOrderStatus(orderID int, status string) error {
	_, err := DB.Exec(`UPDATE orders SET status=$1 WHERE id=$2`, status, orderID)
	return err
}

func DeleteOrder(id int) error {
	_, err := DB.Exec(`DELETE FROM orders WHERE id=$1`, id)
	return err
}
