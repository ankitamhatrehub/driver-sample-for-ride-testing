# Torkk Driver Support APIs

API reference for the driver support-ticket functionality.

## Base URL and authentication

Set the backend URL and a valid driver JWT before running the examples.

```powershell
$BASE_URL = "http://localhost:8080"
$TOKEN = "DRIVER_TOKEN"
```

All endpoints require a valid driver access token:

```http
Authorization: Bearer DRIVER_TOKEN
```

Replace `DRIVER_TOKEN` with the actual token. Replace example IDs with values returned by the API.

---

## 1. Get support categories

**Method:** `GET`  
**Endpoint:** `/api/driver/support/categories`

Returns the configured support categories.

### cURL

```powershell
curl.exe --location "$BASE_URL/api/driver/support/categories" `
  --header "Authorization: Bearer $TOKEN"
```

### Example response

```json
{
  "status": "success",
  "data": [
    {
      "id": "ride",
      "name": "Ride Related"
    },
    {
      "id": "payment",
      "name": "Payment & Earnings"
    },
    {
      "id": "account",
      "name": "Account Related"
    },
    {
      "id": "technical",
      "name": "App & Technical Issues"
    }
  ]
}
```

> The category IDs and names above are illustrative. The actual values come from the `supportCategories` configuration in the backend.

---

## 2. Get problems for a category

**Method:** `GET`  
**Endpoint:** `/api/driver/support/categories/{category_id}/problems`

Returns the configured problems for the specified category.

### cURL

```powershell
curl.exe --location "$BASE_URL/api/driver/support/categories/ride/problems" `
  --header "Authorization: Bearer $TOKEN"
```

### Example response

```json
{
  "status": "success",
  "data": [
    {
      "id": "wrong_fare",
      "name": "Incorrect fare"
    },
    {
      "id": "pickup_issue",
      "name": "Pickup location issue"
    },
    {
      "id": "customer_issue",
      "name": "Customer related issue"
    }
  ]
}
```

> The category and problem IDs/names are examples. Use the values returned by the categories and problems APIs.

---

## 3. Create a support ticket

**Method:** `POST`  
**Endpoint:** `/api/driver/support/tickets`  
**Content-Type:** `multipart/form-data`

Creates a ticket for the authenticated driver. Photos are optional and are uploaded to Cloudinary.

### Form fields

| Field | Required | Description |
|---|---:|---|
| `category_id` | Yes | ID returned by the categories API |
| `problem_id` | Yes | Problem ID returned for the selected category |
| `description` | Yes | Details of the issue |
| `quick_note` | No | Short additional note |
| `ride_id` | No | Related ride ID, if applicable |
| `photos` | No | Attachment file; can be supplied more than once if multiple files are supported by the client |

### cURL

```powershell
curl.exe --location --request POST "$BASE_URL/api/driver/support/tickets" `
  --header "Authorization: Bearer $TOKEN" `
  --form "category_id=ride" `
  --form "problem_id=wrong_fare" `
  --form "description=The fare calculated for my completed ride is incorrect." `
  --form "quick_note=Please check my ride fare." `
  --form "ride_id=12345" `
  --form "photos=@C:/Users/YourName/Pictures/receipt.jpg"
```

To create a ticket without an attachment, omit the `photos` field. Omit optional fields when they are not applicable.

### Example response

```json
{
  "status": "success",
  "message": "Support ticket created successfully",
  "data": {
    "ticket_id": "uuid-generated-id",
    "ticket_number": "TKT-A1B2C3D4",
    "status": "submitted",
    "created_at": "2026-11-03T10:30:00Z"
  }
}
```

Save the returned `ticket_id`; it is used by the ticket details, follow-up, and reopen APIs.

---

## 4. Get the driver's support tickets

**Method:** `GET`  
**Endpoint:** `/api/driver/support/tickets`

Returns the authenticated driver's tickets. Pagination and status filtering can be supplied as query parameters.

### Query parameters

| Parameter | Required | Description |
|---|---:|---|
| `page` | No | Page number |
| `limit` | No | Number of records per page |
| `status` | No | Filter by ticket status |

### cURL — all tickets

```powershell
curl.exe --location "$BASE_URL/api/driver/support/tickets?page=1&limit=10" `
  --header "Authorization: Bearer $TOKEN"
```

### cURL — filter by status

```powershell
curl.exe --location "$BASE_URL/api/driver/support/tickets?status=submitted&page=1&limit=10" `
  --header "Authorization: Bearer $TOKEN"
```

### Example response

```json
{
  "status": "success",
  "data": [
    {
      "ticket_id": "uuid-generated-id",
      "ticket_number": "TKT-A1B2C3D4",
      "category": "Ride Related",
      "problem": "Incorrect fare",
      "status": "submitted",
      "created_at": "2026-11-03T10:30:00Z",
      "updated_at": "2026-11-03T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 1
  }
}
```

---

## 5. Get support ticket details

**Method:** `GET`  
**Endpoint:** `/api/driver/support/tickets/{ticket_id}`

Returns the details, attachments, timeline, and responses for a ticket owned by the authenticated driver.

### cURL

```powershell
$TICKET_ID = "uuid-generated-id"

curl.exe --location "$BASE_URL/api/driver/support/tickets/$TICKET_ID" `
  --header "Authorization: Bearer $TOKEN"
```

### Example response

```json
{
  "status": "success",
  "data": {
    "ticket_id": "uuid-generated-id",
    "ticket_number": "TKT-A1B2C3D4",
    "category": "Ride Related",
    "problem": "Incorrect fare",
    "description": "The fare calculated for my completed ride is incorrect.",
    "priority": "medium",
    "status": "submitted",
    "ride_id": "12345",
    "attachments": [
      "https://res.cloudinary.com/example/image/upload/receipt.jpg"
    ],
    "timeline": [
      {
        "status": "submitted",
        "created_at": "2026-11-03T10:30:00Z"
      }
    ],
    "responses": [
      {
        "id": "response-uuid",
        "sender_type": "driver",
        "sender_id": "101",
        "message": "The fare calculated for my completed ride is incorrect.",
        "attachments": [],
        "created_at": "2026-11-03T10:30:00Z"
      }
    ],
    "can_follow_up": true,
    "can_reopen": false,
    "created_at": "2026-11-03T10:30:00Z",
    "updated_at": "2026-11-03T10:30:00Z"
  }
}
```

---

## 6. Add a follow-up to a ticket

**Method:** `POST`  
**Endpoint:** `/api/driver/support/tickets/{ticket_id}/follow-up`  
**Content-Type:** `multipart/form-data`

Adds a message to an existing ticket. Photos are optional.

### Form fields

| Field | Required | Description |
|---|---:|---|
| `message` | Yes | Follow-up message |
| `photos` | No | Attachment file |

### cURL

```powershell
curl.exe --location --request POST "$BASE_URL/api/driver/support/tickets/$TICKET_ID/follow-up" `
  --header "Authorization: Bearer $TOKEN" `
  --form "message=I am sharing the additional ride details for verification." `
  --form "photos=@C:/Users/YourName/Pictures/ride-details.jpg"
```

### Example response

```json
{
  "status": "success",
  "message": "Follow-up added successfully"
}
```

---

## 7. Reopen a resolved ticket

**Method:** `POST`  
**Endpoint:** `/api/driver/support/tickets/{ticket_id}/reopen`  
**Content-Type:** `application/json`

Reopens an eligible resolved ticket. The request must include a reason.

### JSON request body

```json
{
  "reason": "The issue is still not resolved. Please review it again."
}
```

### cURL

```powershell
curl.exe --location --request POST "$BASE_URL/api/driver/support/tickets/$TICKET_ID/reopen" `
  --header "Authorization: Bearer $TOKEN" `
  --header "Content-Type: application/json" `
  --data-raw '{
    "reason": "The issue is still not resolved. Please review it again."
  }'
```

### Example response

```json
{
  "status": "success",
  "message": "Support ticket reopened successfully",
  "data": {
    "ticket_id": "uuid-generated-id",
    "ticket_number": "TKT-A1B2C3D4",
    "status": "reopened"
  }
}
```

---

## Ticket statuses

The support-ticket implementation discussed uses these statuses:

| Status | Meaning |
|---|---|
| `submitted` | Ticket has been submitted |
| `under_review` | Support team is reviewing the ticket |
| `waiting_for_confirmation` | Waiting for confirmation |
| `resolved` | Ticket has been resolved |
| `reopened` | Driver has reopened the ticket |
| `closed` | Ticket is closed |

The backend controls which statuses allow follow-up or reopening. The ticket details response exposes `can_follow_up` and `can_reopen` for the client.

---

## Common error examples

The following are illustrative error responses; verify the exact messages returned by the running backend.

### Unauthorized

```json
{
  "status": "error",
  "message": "unauthorized"
}
```

### Ticket not found or not owned by the authenticated driver

```json
{
  "status": "error",
  "message": "ticket not found"
}
```

### Ticket cannot be reopened

```json
{
  "status": "error",
  "message": "ticket cannot be reopened"
}
```

---

## Integration notes

- All endpoints are intended for authenticated drivers.
- Ticket access is restricted to the authenticated driver.
- Use the category and problem IDs returned by the APIs rather than hardcoding the illustrative IDs in this document.
- Ticket creation and follow-up use `multipart/form-data` to support optional photo attachments.
- Reopen uses a JSON request body.
- Attachments are uploaded to Cloudinary; the ticket stores the resulting URLs.
- Use the `ticket_id` from the create-ticket response for subsequent ticket operations.

> **Important:** This document contains example cURL commands and sample responses based on the API design discussed. The sample values and response messages have not been verified against a live server. Confirm the configured categories, validation rules, exact response JSON, and accepted status filters against the current implementation before distributing this document as a final client contract.
