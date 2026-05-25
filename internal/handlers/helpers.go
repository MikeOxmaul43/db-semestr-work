package handlers

import (
	"html/template"
	"net/http"
	"path/filepath"
	"strconv"
)

var tmplDir = "templates"

var funcMap = template.FuncMap{
	"inc": func(i int) int { return i + 1 },
}

func renderTemplate(w http.ResponseWriter, name string, data interface{}) {
	base := filepath.Join(tmplDir, "base.html")
	page := filepath.Join(tmplDir, name)
	tmpl, err := template.New("").Funcs(funcMap).ParseFiles(base, page)
	if err != nil {
		http.Error(w, "Template error: "+err.Error(), 500)
		return
	}
	if err := tmpl.ExecuteTemplate(w, "base", data); err != nil {
		http.Error(w, "Render error: "+err.Error(), 500)
	}
}

func formInt(r *http.Request, key string) int {
	v, _ := strconv.Atoi(r.FormValue(key))
	return v
}

func formFloat(r *http.Request, key string) float64 {
	v, _ := strconv.ParseFloat(r.FormValue(key), 64)
	return v
}
