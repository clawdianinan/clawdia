# API Reference

PRDForge provides a comprehensive REST API that allows you to programmatically create, manage, and export PRDs. This document covers all available endpoints, authentication methods, rate limits, and error handling.

## Base URL

All API requests should be made to:
```
https://api.prdforge.com/v1
```

## Authentication

PRDForge API uses API keys for authentication. Include your API key in all requests.

### Getting Your API Key
1. Log into your PRDForge account
2. Go to Settings → API Keys
3. Click "Generate New API Key"
4. Copy the key (it will only be shown once)

### Authentication Methods

#### 1. Bearer Token (Recommended)
```http
Authorization: Bearer YOUR_API_KEY
```

#### 2. Query Parameter
```
https://api.prdforge.com/v1/projects?api_key=YOUR_API_KEY
```

#### 3. Header
```http
X-API-Key: YOUR_API_KEY
```

### Security Best Practices
1. **Never expose API keys** in client-side code
2. **Rotate keys regularly** (every 90 days recommended)
3. **Use different keys** for different environments
4. **Revoke compromised keys** immediately

## Rate Limits

### Default Limits
| Plan | Requests per Minute | Requests per Day | Concurrent Requests |
|------|---------------------|------------------|---------------------|
| Free | 60 | 1,000 | 5 |
| Starter | 120 | 10,000 | 10 |
| Pro | 300 | 50,000 | 25 |
| Enterprise | Custom | Custom | Custom |

### Rate Limit Headers
All responses include rate limit headers:

```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 59
X-RateLimit-Reset: 1617235200
```

### Handling Rate Limits
When you exceed rate limits:
1. **429 Too Many Requests** status code
2. **Retry-After** header indicates wait time
3. Implement exponential backoff in your code

## Webhook Setup and Verification

### Webhook Events
PRDForge can send webhooks for the following events:

| Event | Description | Payload |
|-------|-------------|---------|
| `project.created` | New project created | Project object |
| `project.updated` | Project updated | Project object |
| `project.deleted` | Project deleted | Project ID |
| `export.completed` | Export completed | Export object |
| `credit.low` | Credits below threshold | Credit balance |
| `payment.succeeded` | Payment successful | Payment object |
| `payment.failed` | Payment failed | Payment object |

### Setting Up Webhooks

#### 1. Create Webhook Endpoint
```bash
curl -X POST https://api.prdforge.com/v1/webhooks \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://your-domain.com/webhooks/prdforge",
    "events": ["project.created", "export.completed"],
    "secret": "your-webhook-secret"
  }'
```

#### 2. Webhook Verification
PRDForge sends a verification request:
```http
POST /webhooks/prdforge
Content-Type: application/json
X-PRDForge-Signature: t=1617235200,v1=signature

{
  "type": "webhook_verification",
  "challenge": "random-string"
}
```

Your endpoint must respond with the challenge:
```json
{
  "challenge": "random-string"
}
```

#### 3. Signature Verification
Verify webhook signatures:
```javascript
const crypto = require('crypto');

function verifySignature(payload, signature, secret) {
  const [timestamp, signatureV1] = signature.split(',');
  const time = timestamp.split('=')[1];
  const sig = signatureV1.split('=')[1];
  
  const signedPayload = `${time}.${payload}`;
  const expectedSignature = crypto
    .createHmac('sha256', secret)
    .update(signedPayload)
    .digest('hex');
    
  return crypto.timingSafeEqual(
    Buffer.from(sig),
    Buffer.from(expectedSignature)
  );
}
```

### Webhook Retry Policy
- **3 retries** with exponential backoff
- **5-second** initial delay
- **Maximum delay** of 1 hour
- **Dead letter queue** after final failure

## Error Handling and Status Codes

### HTTP Status Codes

| Code | Description | Typical Use Case |
|------|-------------|------------------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Invalid parameters |
| 401 | Unauthorized | Missing/invalid authentication |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Resource conflict |
| 422 | Unprocessable Entity | Validation errors |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |
| 502 | Bad Gateway | Upstream service error |
| 503 | Service Unavailable | Maintenance or overload |

### Error Response Format
All error responses follow this format:
```json
{
  "error": {
    "code": "validation_error",
    "message": "Invalid input parameters",
    "details": {
      "field": "name",
      "reason": "required"
    },
    "request_id": "req_123456789",
    "documentation_url": "https://docs.prdforge.com/errors/validation_error"
  }
}
```

### Common Error Codes

| Code | Description | Resolution |
|------|-------------|------------|
| `invalid_api_key` | API key is invalid | Check API key |
| `missing_parameter` | Required parameter missing | Include all required params |
| `invalid_parameter` | Parameter value invalid | Check parameter format |
| `resource_not_found` | Requested resource doesn't exist | Verify resource ID |
| `rate_limit_exceeded` | Too many requests | Wait and retry |
| `insufficient_credits` | Not enough credits | Purchase more credits |
| `export_in_progress` | Export already in progress | Wait for completion |

## Endpoints

### Projects

#### List Projects
```http
GET /projects
```

**Query Parameters:**
- `limit` (number, default: 20, max: 100)
- `offset` (number, default: 0)
- `status` (string: draft, in_progress, completed)
- `sort` (string: created_at, updated_at, name)
- `order` (string: asc, desc)

**Response:**
```json
{
  "data": [
    {
      "id": "proj_123456789",
      "name": "My Product",
      "description": "Product description",
      "status": "draft",
      "created_at": "2026-03-18T10:30:00Z",
      "updated_at": "2026-03-18T10:30:00Z",
      "credits_used": 5
    }
  ],
  "pagination": {
    "total": 45,
    "limit": 20,
    "offset": 0,
    "has_more": true
  }
}
```

#### Get Project
```http
GET /projects/{project_id}
```

**Response:**
```json
{
  "id": "proj_123456789",
  "name": "My Product",
  "description": "Product description",
  "status": "draft",
  "template_id": "temp_987654321",
  "content": {
    "sections": [
      {
        "id": "sec_1",
        "title": "Executive Summary",
        "content": "Summary content...",
        "type": "text"
      }
    ]
  },
  "metadata": {
    "word_count": 1500,
    "section_count": 8,
    "last_exported": "2026-03-18T10:30:00Z"
  },
  "created_at": "2026-03-18T10:30:00Z",
  "updated_at": "2026-03-18T10:30:00Z",
  "credits_used": 5
}
```

#### Create Project
```http
POST /projects
```

**Request Body:**
```json
{
  "name": "New Product",
  "description": "Product description",
  "template_id": "temp_987654321",
  "content": {
    "sections": [
      {
        "title": "Executive Summary",
        "type": "text",
        "content": "Initial content"
      }
    ]
  }
}
```

**Response:** 201 Created with project object

#### Update Project
```http
PATCH /projects/{project_id}
```

**Request Body:** Partial project object

**Response:** Updated project object

#### Delete Project
```http
DELETE /projects/{project_id}
```

**Response:** 204 No Content

### Exports

#### Create Export
```http
POST /projects/{project_id}/exports
```

**Request Body:**
```json
{
  "format": "pdf",
  "options": {
    "include_toc": true,
    "include_cover": true,
    "watermark": false,
    "quality": "high"
  }
}
```

**Formats:** `pdf`, `docx`, `md`, `json`, `csv`, `google_sheets`

**Response:**
```json
{
  "id": "exp_123456789",
  "project_id": "proj_123456789",
  "format": "pdf",
  "status": "processing",
  "url": null,
  "size_bytes": null,
  "created_at": "2026-03-18T10:30:00Z",
  "estimated_completion": "2026-03-18T10:35:00Z"
}
```

#### Get Export Status
```http
GET /exports/{export_id}
```

**Response:**
```json
{
  "id": "exp_123456789",
  "project_id": "proj_123456789",
  "format": "pdf",
  "status": "completed",
  "url": "https://exports.prdforge.com/exp_123456789.pdf",
  "size_bytes": 1048576,
  "created_at": "2026-03-18T10:30:00Z",
  "completed_at": "2026-03-18T10:32:00Z",
  "download_url": "https://api.prdforge.com/v1/exports/exp_123456789/download"
}
```

#### Download Export
```http
GET /exports/{export_id}/download
```

**Response:** File download with appropriate Content-Type header

### Templates

#### List Templates
```http
GET /templates
```

**Query Parameters:**
- `category` (string: business, technical, agile, custom)
- `public` (boolean: true for public templates)

**Response:** List of template objects

#### Get Template
```http
GET /templates/{template_id}
```

**Response:** Template object with structure

### Credits

#### Get Credit Balance
```http
GET /credits
```

**Response:**
```json
{
  "balance": 95,
  "total_used": 305,
  "plan": "starter",
  "renews_at": "2026-04-18T00:00:00Z",
  "usage_history": [
    {
      "date": "2026-03-18",
      "credits_used": 5,
      "project_count": 2
    }
  ]
}
```

#### Purchase Credits
```http
POST /credits/purchase
```

**Request Body:**
```json
{
  "pack_size": 100,
  "payment_method_id": "pm_123456789"
}
```

**Pack Sizes:** 25, 60, 150, 500

**Response:** Updated credit balance

### Webhooks

#### List Webhooks
```http
GET /webhooks
```

**Response:** List of webhook configurations

#### Create Webhook
```http
POST /webhooks
```

**Request Body:**
```json
{
  "url": "https://your-domain.com/webhooks",
  "events": ["project.created", "export.completed"],
  "secret": "your-secret-key",
  "enabled": true
}
```

#### Update Webhook
```http
PATCH /webhooks/{webhook_id}
```

#### Delete Webhook
```http
DELETE /webhooks/{webhook_id}
```

#### Test Webhook
```http
POST /webhooks/{webhook_id}/test
```

Sends a test event to verify webhook configuration.

## SDKs and Libraries

### Official SDKs
- **JavaScript/Node.js**: `npm install prdforge`
- **Python**: `pip install prdforge`
- **Ruby**: `gem install prdforge`
- **Go**: `go get github.com/prdforge/prdforge-go`

### Community SDKs
- **PHP**: `composer require prdforge/php-sdk`
- **Java**: Maven Central
- **C#**: NuGet package
- **Swift**: Swift Package Manager

### JavaScript SDK Example
```javascript
const PRDForge = require('prdforge');

const client = new PRDForge({
  apiKey: 'your_api_key',
  timeout: 30000
});

// Create a project
const project = await client.projects.create({
  name: 'My New Product',
  template_id: 'temp_business'
});

// Generate content
const content = await client.ai.generate({
  project_id: project.id,
  section: 'features',
  prompt: 'List key features for an e-commerce platform'
});

// Export to PDF
const export = await client.exports.create({
  project_id: project.id,
  format: 'pdf'
});
```

## Pagination

All list endpoints support pagination:

### Request
```
GET /projects?limit=20&offset=40
```

### Response
```json
{
  "data": [...],
  "pagination": {
    "total": 145,
    "limit": 20,
    "offset": 40,
    "has_more": true
  }
}
```

### Best Practices
1. **Limit parameter**: Always specify a limit (default: 20, max: 100)
2. **Offset-based**: Use offset for pagination
3. **Total count**: Included in pagination object
4. **Has more**: Boolean indicating more results

## Filtering and Sorting

### Filtering
Most list endpoints support filtering:
```
GET /projects?status=completed&created_after=2026-01-01
```

### Sorting
```
GET /projects?sort=created_at&order=desc
```

## WebSocket API (Real-time)

For real-time updates, use the WebSocket API:

```javascript
const ws = new WebSocket('wss://api.prdforge.com/v1/ws');

ws.onopen = () => {
  ws.send(JSON.stringify({
    type: 'auth',
    api_key: 'your_api_key'
  }));
  
  ws.send(JSON.stringify({
    type: 'subscribe',
    channel: 'project:proj_123456789'
  }));
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Update:', data);
};
```

### WebSocket Events
- `project.updated`: Project content changed
- `export.completed`: Export finished
- `collaborator.joined`: New collaborator added
- `comment.added`: New comment on project

## Best Practices

### 1. Error Handling
```javascript
try {
  const project = await client.projects.create(data);
} catch (error) {
  if (error.code === 'rate_limit_exceeded') {
    // Implement exponential backoff
    await sleep(error.retry_after * 1000);
    return retry();
  }
  throw error;
}
```

### 2. Idempotency
For POST requests, include idempotency key:
```http
POST /projects
Idempotency-Key: unique_request_id_123
```

### 3. Webhook Security
- Verify signatures
- Use HTTPS endpoints
- Implement replay protection
- Log all webhook events

### 4. Rate Limiting
- Monitor rate limit headers
- Implement exponential backoff
- Cache responses when appropriate
- Use bulk endpoints for multiple operations

## Support

### API Status
- **Status Page**: [status.prdforge.com](https://status.prdforge.com)
- **Uptime**: 99.9% SLA for paid plans
- **Incident History**: Public incident reports

### Getting Help
- **Documentation**: [docs.prdforge.com/api](https://docs.prdforge.com/api)
- **Support**: api-support@prdforge.com
- **Community**: [GitHub Discussions](https://github.com/prdforge/discussions)
- **Stack Overflow**: Tag questions with `prdforge-api`

### API Versioning
- Current version: `v1`
- Version in URL: `https://api.prdforge.com/v1`
- Deprecation policy: 6 months notice
- Breaking changes: New major version

---

**Note**: This API reference is continuously updated. Always check [docs.prdforge.com/api](https://docs.prdforge.com/api) for the latest information.

Last Updated: March 2026  
API Version: 1.5.0