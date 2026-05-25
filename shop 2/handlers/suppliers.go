package handlers

import (
	"net/http"
	"shop/db"
	"shop/models"
)

func SuppliersPage(w http.ResponseWriter, r *http.Request) {
	suppliers, err := db.FetchSuppliers()
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	renderTemplate(w, "suppliers.html", map[string]interface{}{
		"Suppliers": suppliers,
		"Active":    "suppliers",
	})
}

func AddSupplier(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/suppliers", http.StatusSeeOther)
		return
	}
	s := models.Supplier{
		CompanyName:   r.FormValue("company_name"),
		ContactPerson: r.FormValue("contact_person"),
		Email:         r.FormValue("email"),
		Phone:         r.FormValue("phone"),
		Address:       r.FormValue("address"),
	}
	db.AddSupplier(s)
	http.Redirect(w, r, "/suppliers", http.StatusSeeOther)
}

func UpdateSupplier(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/suppliers", http.StatusSeeOther)
		return
	}
	s := models.Supplier{
		ID:            formInt(r, "id"),
		CompanyName:   r.FormValue("company_name"),
		ContactPerson: r.FormValue("contact_person"),
		Email:         r.FormValue("email"),
		Phone:         r.FormValue("phone"),
		Address:       r.FormValue("address"),
	}
	db.UpdateSupplier(s)
	http.Redirect(w, r, "/suppliers", http.StatusSeeOther)
}

func DeleteSupplier(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/suppliers", http.StatusSeeOther)
		return
	}
	db.DeleteSupplier(formInt(r, "id"))
	http.Redirect(w, r, "/suppliers", http.StatusSeeOther)
}
