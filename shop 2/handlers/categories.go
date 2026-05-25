package handlers

import (
	"net/http"
	"shop/db"
	"shop/models"
)

func CategoriesPage(w http.ResponseWriter, r *http.Request) {
	cats, err := db.FetchCategories()
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	renderTemplate(w, "categories.html", map[string]interface{}{
		"Categories": cats,
		"Active":     "categories",
	})
}

func AddCategory(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/categories", http.StatusSeeOther)
		return
	}
	db.AddCategory(models.Category{Name: r.FormValue("name"), Description: r.FormValue("description")})
	http.Redirect(w, r, "/categories", http.StatusSeeOther)
}

func UpdateCategory(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/categories", http.StatusSeeOther)
		return
	}
	db.UpdateCategory(models.Category{ID: formInt(r, "id"), Name: r.FormValue("name"), Description: r.FormValue("description")})
	http.Redirect(w, r, "/categories", http.StatusSeeOther)
}

func DeleteCategory(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/categories", http.StatusSeeOther)
		return
	}
	db.DeleteCategory(formInt(r, "id"))
	http.Redirect(w, r, "/categories", http.StatusSeeOther)
}
