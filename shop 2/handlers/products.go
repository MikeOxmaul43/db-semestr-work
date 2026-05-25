package handlers

import (
	"net/http"
	"shop/db"
	"shop/models"
)

func ProductsPage(w http.ResponseWriter, r *http.Request) {
	products, err := db.FetchProducts()
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	categories, _ := db.FetchCategories()
	suppliers, _ := db.FetchSuppliers()
	renderTemplate(w, "products.html", map[string]interface{}{
		"Products":   products,
		"Categories": categories,
		"Suppliers":  suppliers,
		"Active":     "products",
	})
}

func AddProduct(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/products", http.StatusSeeOther)
		return
	}
	p := models.Product{
		Name:        r.FormValue("name"),
		Unit:        r.FormValue("unit"),
		Description: r.FormValue("description"),
		Price:       formFloat(r, "price"),
		CategoryID:  formInt(r, "category_id"),
		SupplierID:  formInt(r, "supplier_id"),
	}
	db.AddProduct(p)
	http.Redirect(w, r, "/products", http.StatusSeeOther)
}

func UpdateProduct(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/products", http.StatusSeeOther)
		return
	}
	p := models.Product{
		ID:          formInt(r, "id"),
		Name:        r.FormValue("name"),
		Unit:        r.FormValue("unit"),
		Description: r.FormValue("description"),
		Price:       formFloat(r, "price"),
		CategoryID:  formInt(r, "category_id"),
		SupplierID:  formInt(r, "supplier_id"),
	}
	db.UpdateProduct(p)
	http.Redirect(w, r, "/products", http.StatusSeeOther)
}

func DeleteProduct(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/products", http.StatusSeeOther)
		return
	}
	db.DeleteProduct(formInt(r, "id"))
	http.Redirect(w, r, "/products", http.StatusSeeOther)
}

func UpdateStock(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/products", http.StatusSeeOther)
		return
	}
	db.UpdateStock(formInt(r, "product_id"), formInt(r, "quantity"))
	http.Redirect(w, r, "/products", http.StatusSeeOther)
}
