package handlers

import (
	"net/http"
	"shop/internal/db"
	"shop/internal/models"
)

func CustomersPage(w http.ResponseWriter, r *http.Request) {
	customers, err := db.FetchCustomers()
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	renderTemplate(w, "customers.html", map[string]interface{}{
		"Customers": customers,
		"Active":    "customers",
	})
}

func AddCustomer(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/customers", http.StatusSeeOther)
		return
	}
	c := models.Customer{
		FirstName: r.FormValue("first_name"),
		LastName:  r.FormValue("last_name"),
		Address:   r.FormValue("address"),
		Email:     r.FormValue("email"),
		Phone:     r.FormValue("phone"),
	}
	db.AddCustomer(c)
	http.Redirect(w, r, "/customers", http.StatusSeeOther)
}

func UpdateCustomer(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/customers", http.StatusSeeOther)
		return
	}
	c := models.Customer{
		ID:        formInt(r, "id"),
		FirstName: r.FormValue("first_name"),
		LastName:  r.FormValue("last_name"),
		Address:   r.FormValue("address"),
		Email:     r.FormValue("email"),
		Phone:     r.FormValue("phone"),
	}
	db.UpdateCustomer(c)
	http.Redirect(w, r, "/customers", http.StatusSeeOther)
}

func DeleteCustomer(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/customers", http.StatusSeeOther)
		return
	}
	id := formInt(r, "id")
	db.DeleteCustomer(id)
	http.Redirect(w, r, "/customers", http.StatusSeeOther)
}
