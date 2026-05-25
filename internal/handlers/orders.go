package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"shop/internal/db"
	"shop/internal/models"
)

func OrdersPage(w http.ResponseWriter, r *http.Request) {
	orders, err := db.FetchOrders()
	if err != nil {
		http.Error(w, "Ошибка загрузки заказов: "+err.Error(), 500)
		return
	}
	customers, err := db.FetchCustomers()
	if err != nil {
		http.Error(w, "Ошибка загрузки клиентов: "+err.Error(), 500)
		return
	}
	products, err := db.FetchProductsSimple()
	if err != nil {
		http.Error(w, "Ошибка загрузки товаров: "+err.Error(), 500)
		return
	}
	employees, err := db.FetchEmployees()
	if err != nil {
		http.Error(w, "Ошибка загрузки сотрудников: "+err.Error(), 500)
		return
	}
	renderTemplate(w, "orders.html", map[string]interface{}{
		"Orders":    orders,
		"Customers": customers,
		"Products":  products,
		"Employees": employees,
		"Active":    "orders",
	})
}

func AddOrder(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/orders", http.StatusSeeOther)
		return
	}
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Ошибка парсинга формы: "+err.Error(), 400)
		return
	}

	customerID := formInt(r, "customer_id")
	employeeID := formInt(r, "employee_id")
	itemsJSON := r.FormValue("items")

	log.Printf("[AddOrder] customer_id=%d employee_id=%d items=%s", customerID, employeeID, itemsJSON)

	var items []models.OrderItem
	if err := json.Unmarshal([]byte(itemsJSON), &items); err != nil || len(items) == 0 {
		http.Error(w, "Не выбраны товары или ошибка данных: "+itemsJSON, 400)
		return
	}

	if err := db.AddOrder(customerID, employeeID, items); err != nil {
		log.Printf("[AddOrder] DB error: %v", err)
		http.Error(w, "Ошибка создания заказа: "+err.Error(), 500)
		return
	}

	http.Redirect(w, r, "/orders", http.StatusSeeOther)
}

func UpdateOrderStatus(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/orders", http.StatusSeeOther)
		return
	}
	if err := db.UpdateOrderStatus(formInt(r, "id"), r.FormValue("status")); err != nil {
		http.Error(w, "Ошибка обновления статуса: "+err.Error(), 500)
		return
	}
	http.Redirect(w, r, "/orders", http.StatusSeeOther)
}

func DeleteOrder(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/orders", http.StatusSeeOther)
		return
	}
	if err := db.DeleteOrder(formInt(r, "id")); err != nil {
		http.Error(w, "Ошибка удаления заказа: "+err.Error(), 500)
		return
	}
	http.Redirect(w, r, "/orders", http.StatusSeeOther)
}

func OrderDetails(w http.ResponseWriter, r *http.Request) {
	orderID := formInt(r, "id")
	details, err := db.FetchOrderDetails(orderID)
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(details)
}
