package main

import (
	"fmt"
	"log"
	"net/http"
	"shop/internal/config"
	"shop/internal/db"
	"shop/internal/handlers"
)

func main() {
	cfg, err := config.LoadConfig("./config.yaml")
	if err != nil {
		log.Fatalf("Ошибка конфига: %v", err)
	}

	if err := db.Init(cfg.DSN()); err != nil {
		log.Fatalf("Ошибка подключения к БД: %v", err)
	}
	log.Println(" Подключение к БД успешно")

	mux := http.NewServeMux()

	// Root redirect
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, "/customers", http.StatusSeeOther)
	})

	// Customers
	mux.HandleFunc("/customers", handlers.CustomersPage)
	mux.HandleFunc("/customers/add", handlers.AddCustomer)
	mux.HandleFunc("/customers/update", handlers.UpdateCustomer)
	mux.HandleFunc("/customers/delete", handlers.DeleteCustomer)

	// Categories
	mux.HandleFunc("/categories", handlers.CategoriesPage)
	mux.HandleFunc("/categories/add", handlers.AddCategory)
	mux.HandleFunc("/categories/update", handlers.UpdateCategory)
	mux.HandleFunc("/categories/delete", handlers.DeleteCategory)

	// Suppliers
	mux.HandleFunc("/suppliers", handlers.SuppliersPage)
	mux.HandleFunc("/suppliers/add", handlers.AddSupplier)
	mux.HandleFunc("/suppliers/update", handlers.UpdateSupplier)
	mux.HandleFunc("/suppliers/delete", handlers.DeleteSupplier)

	// Products
	mux.HandleFunc("/products", handlers.ProductsPage)
	mux.HandleFunc("/products/add", handlers.AddProduct)
	mux.HandleFunc("/products/update", handlers.UpdateProduct)
	mux.HandleFunc("/products/delete", handlers.DeleteProduct)
	mux.HandleFunc("/products/stock", handlers.UpdateStock)

	// Orders
	mux.HandleFunc("/orders", handlers.OrdersPage)
	mux.HandleFunc("/orders/add", handlers.AddOrder)
	mux.HandleFunc("/orders/status", handlers.UpdateOrderStatus)
	mux.HandleFunc("/orders/delete", handlers.DeleteOrder)

	// Payments
	mux.HandleFunc("/payments", handlers.PaymentsPage)
	mux.HandleFunc("/payments/add", handlers.AddPayment)

	// Analytics
	mux.HandleFunc("/analytics", handlers.AnalyticsPage)

	addr := fmt.Sprintf(":%d", cfg.Server.Port)
	log.Printf(" Сервер запущен на http://localhost%s", addr)
	log.Fatal(http.ListenAndServe(addr, mux))
}
