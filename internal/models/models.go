package models

type Customer struct {
	ID        int
	FirstName string
	LastName  string
	Address   string
	Email     string
	Phone     string
}

type Category struct {
	ID          int
	Name        string
	Description string
}

type Supplier struct {
	ID            int
	CompanyName   string
	ContactPerson string
	Email         string
	Phone         string
	Address       string
}

type Product struct {
	ID          int
	Name        string
	Unit        string
	Description string
	Price       float64
	CategoryID  int
	SupplierID  int
}

type ProductRow struct {
	ID           int
	Name         string
	Unit         string
	Description  string
	Price        float64
	CategoryName string
	SupplierName string
	Quantity     int
}

type OrderRow struct {
	ID           int
	Status       string
	Date         string
	CustomerName string
	EmployeeName string
}

type OrderDetailRow struct {
	ProductName string
	Quantity    int
	Price       float64
	Total       float64
}

type OrderItem struct {
	ProductID int `json:"product_id"`
	Quantity  int `json:"quantity"`
}

type Payment struct {
	Amount  float64
	Method  string
	OrderID int
}

type PaymentRow struct {
	ID      int
	Date    string
	Amount  float64
	Method  string
	OrderID int
}

type CategoryCount struct {
	CategoryName string
	Count        int
}

type SalesRow struct {
	ProductName string
	Sold        int
	Revenue     float64
}

type SupplierDeliveries struct {
	SupplierName string
	Count        int
}

type TopProduct struct {
	ProductName string
	TotalSold   int
}

type Employee struct {
	ID        int
	FirstName string
	LastName  string
}
