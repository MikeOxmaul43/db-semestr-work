package db

import "shop/internal/models"

func FetchPayments() ([]models.PaymentRow, error) {
	rows, err := DB.Query(`
		SELECT id, date::text, amount, COALESCE(payment_method,''), order_id
		FROM payments
		ORDER BY id DESC LIMIT 100`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []models.PaymentRow
	for rows.Next() {
		var r models.PaymentRow
		if err := rows.Scan(&r.ID, &r.Date, &r.Amount, &r.Method, &r.OrderID); err != nil {
			return nil, err
		}
		list = append(list, r)
	}
	return list, nil
}

func AddPayment(p models.Payment) error {
	_, err := DB.Exec(
		`INSERT INTO payments (date, amount, payment_method, order_id) VALUES (CURRENT_DATE, $1, $2, $3)`,
		p.Amount, p.Method, p.OrderID)
	return err
}
