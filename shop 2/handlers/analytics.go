package handlers

import (
	"net/http"
	"shop/db"
)

func AnalyticsPage(w http.ResponseWriter, r *http.Request) {
	outOfStock, _ := db.CountOutOfStock()
	monthTotal, _ := db.OrdersTotalCurrentMonth()
	topProducts, _ := db.TopProducts()

	// 1. Фильтр по категории
	categories, _ := db.FetchCategories()
	categoryID := formInt(r, "category_id")
	var catName string
	var catCount int
	if categoryID != 0 {
		catName, catCount, _ = db.CountProductsInCategory(categoryID)
	}

	// 3. Продажи за период
	from := r.URL.Query().Get("from")
	to := r.URL.Query().Get("to")
	if from == "" { from = "2000-01-01" }
	if to == "" { to = "2099-12-31" }
	sales, _ := db.SalesByPeriod(from, to)

	// 5. Поставки от конкретного поставщика
	suppliers, _ := db.FetchSuppliers()
	supplierID := formInt(r, "supplier_id")
	var supplierName string
	var supplierDeliveries int
	if supplierID != 0 {
		supplierName, supplierDeliveries, _ = db.DeliveriesBySupplierID(supplierID)
	}

	renderTemplate(w, "analytics.html", map[string]interface{}{
		"Active":             "analytics",
		"OutOfStock":         outOfStock,
		"MonthTotal":         monthTotal,
		"TopProducts":        topProducts,
		"Categories":         categories,
		"CategoryID":         categoryID,
		"CatName":            catName,
		"CatCount":           catCount,
		"Sales":              sales,
		"From":               from,
		"To":                 to,
		"Suppliers":          suppliers,
		"SupplierID":         supplierID,
		"SupplierName":       supplierName,
		"SupplierDeliveries": supplierDeliveries,
	})
}
