# API Documentation - Finance Verse

## Authentication
All endpoints require authentication using the following headers:
```
access-token: your-access-token
client: your-client-id
uid: your-email
```

## Dashboard Endpoint

### Get Dashboard Data
Returns an overview of financial data including totals, expenses by category, and historical data.

```http
GET /api/dashboard
```

#### Query Parameters
| Parameter | Type   | Required | Description                          |
|-----------|--------|----------|--------------------------------------|
| year      | string | No       | Filter by year (e.g., "2025")       |
| month     | string | No       | Filter by month number (1-12)       |

#### Response Format
```json
{
  "data": {
    "balance": 5000.00,           // Total balance (income - expenses)
    "income": 10000.00,          // Total income
    "expenses": 5000.00,         // Total expenses
    "expensesByCategory": [      // Expenses grouped by category
      {
        "id": "Food",
        "value": 1500.00,
        "label": "Food"
      }
    ],
    "lastMonths": [              // Last 3 months of data
      {
        "month": "June/2025",
        "income": 8000.00,
        "expenses": 4000.00
      }
    ]
  }
}
```

#### Example Requests

1. Get current year's dashboard:
```http
GET /api/dashboard
```

2. Get specific year's dashboard:
```http
GET /api/dashboard?year=2025
```

3. Get specific month in a year:
```http
GET /api/dashboard?year=2025&month=8
```

## Movements Endpoint

### List Movements
Returns a paginated list of financial movements with optional filters.

```http
GET /api/movements
```

#### Query Parameters
| Parameter                    | Type   | Description                                    |
|-----------------------------|--------|------------------------------------------------|
| filter[movement_type]       | string | Filter by type ("income" or "expense")        |
| filter[is_business]         | boolean| Filter by business-related movements           |
| filter[activity_kind]       | integer| Filter by MEI activity type (8,16,32)         |
| q[description_cont]         | string | Search in description (contains)              |
| q[date_year_eq]            | number | Filter by year                                |
| q[date_month_eq]           | number | Filter by month (1-12)                        |
| page[number]               | number | Page number for pagination                    |
| page[size]                 | number | Items per page                                |

#### Available Ransack Filters
- Date filters:
  - `q[date_year_eq]`: Equal to year
  - `q[date_month_eq]`: Equal to month
  - `q[date_gteq]`: Greater than or equal to date
  - `q[date_lteq]`: Less than or equal to date

- Amount filters:
  - `q[amount_gteq]`: Amount greater than or equal
  - `q[amount_lteq]`: Amount less than or equal

- Text search:
  - `q[description_cont]`: Contains in description
  - `q[title_cont]`: Contains in title
  - `q[category_eq]`: Exact category match

#### Example Requests

1. List all expenses for March 2025:
```http
GET /api/movements?filter[movement_type]=expense&q[date_year_eq]=2025&q[date_month_eq]=3&page[number]=1&page[size]=10
```

2. Search movements by description:
```http
GET /api/movements?q[description_cont]=salary&page[number]=1&page[size]=10
```

3. Get movements within an amount range:
```http
GET /api/movements?q[amount_gteq]=1000&q[amount_lteq]=5000
```

4. Get business-related movements for IRPF:
```http
GET /api/movements?filter[is_business]=true&filter[activity_kind]=8&q[date_year_eq]=2025
```

### Create Movement
Creates a new financial movement.

```http
POST /api/movements
```

#### Request Body
```json
{
  "movement": {
    "title": "Salary",
    "description": "Monthly salary",
    "amount": 5000.00,
    "movement_type": "income",
    "category": "Salary",
    "date": "2025-08-23",
    "is_business": false,
    "activity_kind": 8,
    "tax_exemption_percentage": 0.0,
    "supporting_doc_url": "https://example.com/comprovante.pdf"
  }
}
```

#### IRPF Fields (Optional)
- `is_business`: Boolean - Indicates if the movement is related to MEI business activity
- `activity_kind`: Integer - MEI activity type (8=comercio, 16=transporte, 32=servicos)
- `tax_exemption_percentage`: Decimal - Tax exemption percentage at the time of registration
- `supporting_doc_url`: String - URL to supporting document (PDF/JPG)

#### Required Fields
- `title`: String
- `amount`: Decimal (greater than 0)
- `movement_type`: String ("income" or "expense")
- `date`: Date (YYYY-MM-DD format)

### Update Movement
Updates an existing movement.

```http
PUT /api/movements/:id
```

### Delete Movement
Deletes a movement.

```http
DELETE /api/movements/:id
```

### Import Movements from Excel
Import multiple movements from an Excel file.

```http
POST /api/movements/import
```

#### Request
- Method: POST
- Content-Type: multipart/form-data
- Body: file (Excel file)

#### Excel File Format
The Excel file must have the following columns in the first row:

| Column     | Description                               | Format     |
|------------|-------------------------------------------|------------|
| Data       | Date of the movement                      | DD/MM/YYYY |
| Valor      | Amount (positive number)                  | Number     |
| Descrição  | Description of the movement               | Text       |
| Categoria  | Category of the movement                  | Text       |
| Tipo       | Type of movement (Receita/Despesa)       | Text       |

#### Response Format
```json
{
  "message": "Successfully imported 5 movements",
  "movements": [
    {
      "id": 1,
      "title": "Grocery Shopping",
      "description": "Monthly groceries",
      "amount": 500.00,
      "movement_type": "expense",
      "category": "Food",
      "date": "2025-08-23"
    }
  ]
}
```

#### Error Response
```json
{
  "errors": [
    {
      "row": 2,
      "errors": ["Amount can't be blank", "Date is invalid"]
    }
  ]
}
```

## IRPF (Imposto de Renda Pessoa Física) Integration

The Movements API includes fields specifically designed for IRPF declaration purposes for MEI (Microempreendedor Individual):

### Business-Related Movements
- `is_business`: Boolean flag to mark movements related to MEI business activities
- `activity_kind`: Enum for MEI activity type:
  - `8` - Comércio (Commerce)
  - `16` - Transporte (Transportation)
  - `32` - Serviços (Services)

### Tax Information
- `tax_exemption_percentage`: Stores the tax exemption percentage at the time of registration
- `supporting_doc_url`: URL to supporting documents (PDF/JPG) for tax purposes

### Calculated Fields
The API automatically calculates:
- `taxable_amount`: Amount subject to taxation (considering exemptions)
- `deductible_amount`: Amount that can be deducted from taxable income

### Example IRPF Movement
```json
{
  "id": "uuid-123",
  "title": "Compra de material",
  "amount": 1000.00,
  "movement_type": "expense",
  "is_business": true,
  "activity_kind": 8,
  "activity_kind_text": "Comércio",
  "tax_exemption_percentage": 8.0,
  "supporting_doc_url": "https://example.com/nf-123.pdf",
  "taxable_amount": 920.00,
  "deductible_amount": 80.00
}
```

## Response Status Codes

| Code | Description                                          |
|------|------------------------------------------------------|
| 200  | Success                                               |
| 201  | Created successfully                                  |
| 401  | Unauthorized - Invalid or missing authentication      |
| 404  | Not found                                            |
| 422  | Unprocessable Entity - Validation errors             |
| 500  | Internal Server Error                                |
