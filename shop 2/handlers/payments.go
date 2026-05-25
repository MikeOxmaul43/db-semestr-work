package handlers

import (
	"net/http"
	"shop/db"
	"shop/models"
)

func PaymentsPage(w http.ResponseWriter, r *http.Request) {
	payments, err := db.FetchPayments()
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	orders, _ := db.FetchOrders()
	renderTemplate(w, "payments.html", map[string]interface{}{
		"Payments": payments,
		"Orders":   orders,
		"Active":   "payments",
	})
}

func AddPayment(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/payments", http.StatusSeeOther)
		return
	}
	p := models.Payment{
		Amount:  formFloat(r, "amount"),
		Method:  r.FormValue("method"),
		OrderID: formInt(r, "order_id"),
	}
	db.AddPayment(p)
	http.Redirect(w, r, "/payments", http.StatusSeeOther)
}
