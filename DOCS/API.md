# API Documentation

## Base URL

```
https://your-directus-instance.com
```

## Authentication

All requests require a Bearer token in the Authorization header:

```http
Authorization: Bearer YOUR_ACCESS_TOKEN
```

## Endpoints

### Products

#### List Products
```http
GET /items/products
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Organic Eggs",
      "description": "Fresh, free-range eggs",
      "price": 6.99,
      "image_url": "https://example.com/eggs.jpg"
    }
  ]
}
```

#### Get Product
```http
GET /items/products/:id
```

**Response:**
```json
{
  "data": {
    "id": 1,
    "name": "Organic Eggs",
    "description": "Fresh, free-range eggs",
    "price": 6.99,
    "image_url": "https://example.com/eggs.jpg"
  }
}
```

### Users

#### Find User by Email
```http
GET /items/app_users?filter[email][_eq]=user@example.com
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Collins Koech",
      "email": "user@example.com"
    }
  ]
}
```

#### Create User
```http
POST /items/app_users
Content-Type: application/json

{
  "name": "Collins Koech",
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "data": {
    "id": 1,
    "name": "Collins Koech",
    "email": "user@example.com"
  }
}
```

### Cart

#### Get User Cart
```http
GET /items/cart_items?filter[user][_eq]=1
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "user": 1,
      "product": 1,
      "quantity": 2
    }
  ]
}
```

#### Add to Cart
```http
POST /items/cart_items
Content-Type: application/json

{
  "user": 1,
  "product": 1,
  "quantity": 2
}
```

#### Update Cart Item
```http
PATCH /items/cart_items/:id
Content-Type: application/json

{
  "quantity": 3
}
```

#### Remove from Cart
```http
DELETE /items/cart_items/:id
```

#### Clear Cart
```http
DELETE /items/cart_items?filter[user][_eq]=1
```

### Orders

#### Create Order
```http
POST /items/orders
Content-Type: application/json

{
  "user": 1,
  "total": 25.99,
  "status": "pending"
}
```

**Response:**
```json
{
  "data": {
    "id": 1,
    "user": 1,
    "total": 25.99,
    "status": "pending",
    "created_at": "2025-11-20T23:00:00Z"
  }
}
```

#### Create Order Items
```http
POST /items/order_items
Content-Type: application/json

{
  "order": 1,
  "product": 1,
  "quantity": 2,
  "price": 6.99
}
```

#### Get User Orders
```http
GET /items/orders?filter[user][_eq]=1&sort=-created_at
```

### Scan Records

#### Upload Scan Record
```http
POST /items/scan_records
Content-Type: application/json

{
  "user": 1,
  "product_name": "Organic Eggs",
  "confidence": 0.95,
  "quantity": 1,
  "recorded_at": "2025-11-20T23:00:00Z"
}
```

#### Get User Scan History
```http
GET /items/scan_records?filter[user][_eq]=1&sort=-recorded_at&limit=50
```

## Error Responses

### 400 Bad Request
```json
{
  "errors": [
    {
      "message": "Invalid request body",
      "extensions": {
        "code": "INVALID_PAYLOAD"
      }
    }
  ]
}
```

### 401 Unauthorized
```json
{
  "errors": [
    {
      "message": "Invalid token",
      "extensions": {
        "code": "INVALID_TOKEN"
      }
    }
  ]
}
```

### 404 Not Found
```json
{
  "errors": [
    {
      "message": "Item not found",
      "extensions": {
        "code": "NOT_FOUND"
      }
    }
  ]
}
```

## Rate Limiting

- 100 requests per minute per IP
- 1000 requests per hour per user

## Pagination

Use `limit` and `offset` query parameters:

```http
GET /items/products?limit=20&offset=0
```

## Filtering

Directus supports advanced filtering:

```http
# Equals
GET /items/products?filter[price][_eq]=6.99

# Greater than
GET /items/products?filter[price][_gt]=5.00

# Less than
GET /items/products?filter[price][_lt]=10.00

# Contains
GET /items/products?filter[name][_contains]=Organic

# In array
GET /items/products?filter[id][_in]=1,2,3
```

## Sorting

```http
# Ascending
GET /items/products?sort=price

# Descending
GET /items/products?sort=-price

# Multiple fields
GET /items/products?sort=category,-price
```

## Field Selection

Request specific fields only:

```http
GET /items/products?fields=id,name,price
```

## Deep Queries

Fetch related data:

```http
GET /items/cart_items?fields=*,product.*,user.name
```
