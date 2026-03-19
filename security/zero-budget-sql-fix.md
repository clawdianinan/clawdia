# Zero-Budget SQL Injection Fix

## Executive Summary
This document outlines a comprehensive, zero-budget approach to identifying and fixing SQL injection vulnerabilities in legacy systems. The methodology focuses on manual code review, implementation of parameterized queries, free testing tools, and input validation middleware.

## 1. Manual Code Review Methodology

### 1.1 Identifying Vulnerable Code Patterns
Search for these high-risk patterns in your codebase:

```bash
# PHP patterns
grep -r "mysql_query\|mysqli_query" . --include="*.php"
grep -r "\$_GET\|\$_POST\|\$_REQUEST" . --include="*.php" | grep -i "query\|sql"

# JavaScript/Node.js patterns
grep -r "query(" . --include="*.js" --include="*.ts"
grep -r "exec(" . --include="*.js" --include="*.ts"

# Python patterns
grep -r "execute(" . --include="*.py" | grep -v "cursor.execute"
grep -r "%s\|%d\|%f" . --include="*.py" | grep -i "sql\|query"
```

### 1.2 High-Risk Code Examples to Flag

**PHP (Vulnerable):**
```php
// BAD: Direct variable interpolation
$query = "SELECT * FROM users WHERE id = " . $_GET['id'];
$result = mysql_query($query);

// BAD: String concatenation
$username = $_POST['username'];
$query = "SELECT * FROM users WHERE username = '$username'";
```

**PHP (Fixed):**
```php
// GOOD: Prepared statements
$stmt = $mysqli->prepare("SELECT * FROM users WHERE id = ?");
$stmt->bind_param("i", $_GET['id']);
$stmt->execute();
```

**Node.js (Vulnerable):**
```javascript
// BAD: Template literals
const query = `SELECT * FROM users WHERE email = '${email}'`;
db.query(query);

// BAD: String concatenation
const query = "SELECT * FROM products WHERE id = " + req.params.id;
```

**Node.js (Fixed):**
```javascript
// GOOD: Parameterized queries
const query = "SELECT * FROM users WHERE email = ?";
db.query(query, [email]);

// GOOD: Named parameters (if supported)
const query = "SELECT * FROM products WHERE id = $1";
db.query(query, [req.params.id]);
```

## 2. Implementing Parameterized Queries

### 2.1 PHP Migration Guide

**Step 1: Replace mysql_* functions with mysqli**
```php
// OLD (vulnerable)
$conn = mysql_connect($host, $user, $pass);
mysql_select_db($database);
$result = mysql_query("SELECT * FROM table WHERE id = " . $_GET['id']);

// NEW (secure)
$conn = new mysqli($host, $user, $pass, $database);
$stmt = $conn->prepare("SELECT * FROM table WHERE id = ?");
$stmt->bind_param("i", $_GET['id']);
$stmt->execute();
$result = $stmt->get_result();
```

**Step 2: PDO Migration (Recommended)**
```php
$pdo = new PDO("mysql:host=$host;dbname=$database", $user, $pass);
$stmt = $pdo->prepare("SELECT * FROM users WHERE username = :username");
$stmt->execute([':username' => $_POST['username']]);
$user = $stmt->fetch();
```

### 2.2 Node.js/Express Implementation

```javascript
// Using mysql2 (supports promises and prepared statements)
const mysql = require('mysql2/promise');

async function getUser(id) {
  const connection = await mysql.createConnection({
    host: 'localhost',
    user: 'root',
    database: 'test'
  });
  
  const [rows] = await connection.execute(
    'SELECT * FROM users WHERE id = ?',
    [id]
  );
  
  return rows[0];
}

// Express middleware for parameterized queries
app.get('/user/:id', async (req, res) => {
  try {
    const user = await getUser(req.params.id);
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: 'Database error' });
  }
});
```

### 2.3 Python (Flask/Django)

**Flask with SQLAlchemy:**
```python
from flask import Flask, request
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
db = SQLAlchemy(app)

# BAD: String formatting (vulnerable)
@app.route('/user/<user_id>')
def get_user_bad(user_id):
    query = f"SELECT * FROM users WHERE id = {user_id}"
    result = db.engine.execute(query)  # VULNERABLE
    
# GOOD: Parameterized query
@app.route('/user/<user_id>')
def get_user_good(user_id):
    query = "SELECT * FROM users WHERE id = :user_id"
    result = db.engine.execute(query, user_id=user_id)  # SECURE
```

## 3. Free Testing with SQLMap

### 3.1 Installation
```bash
# Install SQLMap (requires Python)
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
cd sqlmap-dev
python sqlmap.py --version
```

### 3.2 Basic Testing Commands

**Test a single URL:**
```bash
python sqlmap.py -u "http://example.com/page.php?id=1" --batch
```

**Test with authentication:**
```bash
python sqlmap.py -u "http://example.com/admin.php" \
  --data="username=admin&password=admin" \
  --cookie="PHPSESSID=abc123" \
  --batch
```

**Test POST requests:**
```bash
python sqlmap.py -u "http://example.com/login.php" \
  --data="username=test&password=test" \
  --method=POST \
  --batch
```

### 3.3 Safe Testing Guidelines

1. **Only test your own systems** or systems you have explicit permission to test
2. **Use the `--batch` flag** for automated responses
3. **Limit risk with `--level` and `--risk`**:
   ```bash
   python sqlmap.py -u "http://example.com/page.php?id=1" \
     --level=1 --risk=1 --batch
   ```
4. **Use `--threads=1`** to avoid overwhelming the server
5. **Test on staging/development** environments first

### 3.4 Interpreting Results

SQLMap will report:
- **Injectable parameters** (GET, POST, Cookie, User-Agent, etc.)
- **Database type** (MySQL, PostgreSQL, SQL Server, etc.)
- **Payloads that worked**
- **Recommended fixes**

## 4. Input Validation Middleware

### 4.1 PHP Input Validation Functions

```php
<?php
// Input validation and sanitization functions
function validateInteger($input) {
    return filter_var($input, FILTER_VALIDATE_INT) !== false;
}

function validateEmail($input) {
    return filter_var($input, FILTER_VALIDATE_EMAIL) !== false;
}

function sanitizeString($input) {
    return htmlspecialchars(strip_tags(trim($input)), ENT_QUOTES, 'UTF-8');
}

function validateInput($rules) {
    $errors = [];
    foreach ($rules as $field => $rule) {
        $value = $_POST[$field] ?? $_GET[$field] ?? null;
        
        switch ($rule) {
            case 'int':
                if (!validateInteger($value)) {
                    $errors[$field] = "Must be a valid integer";
                }
                break;
            case 'email':
                if (!validateEmail($value)) {
                    $errors[$field] = "Must be a valid email";
                }
                break;
            case 'string':
                $_POST[$field] = sanitizeString($value);
                break;
        }
    }
    return $errors;
}

// Usage
$rules = [
    'user_id' => 'int',
    'email' => 'email',
    'name' => 'string'
];

$errors = validateInput($rules);
if (empty($errors)) {
    // Proceed with database operations
}
?>
```

### 4.2 Node.js/Express Validation Middleware

```javascript
// validationMiddleware.js
const { body, param, query, validationResult } = require('express-validator');

const sqlInjectionPattern = /(\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|EXEC|ALTER)\b)|(--)|(\/\*)|(\*\/)/i;

const validateInput = (field, location = 'body') => {
  const validator = location === 'body' ? body : 
                   location === 'param' ? param : query;
  
  return validator(field)
    .trim()
    .notEmpty()
    .custom(value => {
      if (sqlInjectionPattern.test(value)) {
        throw new Error('Potential SQL injection detected');
      }
      return true;
    });
};

const validateInteger = (field, location = 'body') => {
  const validator = location === 'body' ? body : 
                   location === 'param' ? param : query;
  
  return validator(field)
    .isInt()
    .toInt();
};

const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  next();
};

// Usage in routes
app.post('/api/users',
  [
    validateInput('username'),
    validateInput('email'),
    validateInteger('age'),
    handleValidationErrors
  ],
  async (req, res) => {
    // Safe to use req.body values
    const { username, email, age } = req.body;
    // Database operations...
  }
);
```

### 4.3 Python (Flask) Validation

```python
from flask import Flask, request, jsonify
import re

app = Flask(__name__)

# SQL injection pattern
SQL_INJECTION_PATTERN = re.compile(
    r'(\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|EXEC|ALTER)\b)|(--)|(\/\*)|(\*\/)',
    re.IGNORECASE
)

def validate_input(data, rules):
    errors = {}
    
    for field, rule in rules.items():
        value = data.get(field, '')
        
        if rule == 'int':
            try:
                int(value)
            except ValueError:
                errors[field] = f"{field} must be an integer"
                
        elif rule == 'email':
            if '@' not in value or '.' not in value:
                errors[field] = f"{field} must be a valid email"
                
        elif rule == 'string':
            if SQL_INJECTION_PATTERN.search(value):
                errors[field] = f"Potential SQL injection detected in {field}"
            # Sanitize
            data[field] = value.strip()
    
    return errors, data

@app.route('/api/user', methods=['POST'])
def create_user():
    rules = {
        'username': 'string',
        'email': 'email',
        'age': 'int'
    }
    
    errors, cleaned_data = validate_input(request.json, rules)
    
    if errors:
        return jsonify({'errors': errors}), 400
    
    # Safe to use cleaned_data for database operations
    # ...
    
    return jsonify({'message': 'User created successfully'}), 201
```

## 5. Emergency Quick Fixes

### 5.1 Immediate Mitigation (If You Can't Rewrite Code)

**PHP Quick Fix:**
```php
// Add this at the top of vulnerable files
function emergency_sanitize($input) {
    if (is_numeric($input)) {
        return (int)$input;
    }
    return addslashes(htmlspecialchars($input, ENT_QUOTES, 'UTF-8'));
}

// Apply to all user inputs
$_GET = array_map('emergency_sanitize', $_GET);
$_POST = array_map('emergency_sanitize', $_POST);
```

**Node.js Quick Fix:**
```javascript
// Add this middleware before routes
app.use((req, res, next) => {
  const sqlInjectionPattern = /(\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|EXEC|ALTER)\b)|(--)|(\/\*)|(\*\/)/i;
  
  const sanitize = (obj) => {
    for (const key in obj) {
      if (typeof obj[key] === 'string' && sqlInjectionPattern.test(obj[key])) {
        throw new Error('Potential SQL injection detected');
      }
    }
  };
  
  sanitize(req.query);
  sanitize(req.body);
  sanitize(req.params);
  
  next();
});
```

## 6. Monitoring and Maintenance

### 6.1 Logging Suspicious Activity

**PHP Logging:**
```php
// Log potential SQL injection attempts
function log_sql_attempt($input, $source) {
    $pattern = '/(\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|EXEC|ALTER)\b)|(--)|(\/\*)|(\*\/)/i';
    
    if (preg_match($pattern, $input)) {
        $log_entry = date('Y-m-d H:i:s') . " | Potential SQL injection from $source: " . 
                     substr($input, 0, 100) . "\n";
        file_put_contents('/var/log/sql_injection.log', $log_entry, FILE_APPEND);
        return true;
    }
    return false;
}

// Usage
log_sql_attempt($_GET['search'], 'GET parameter');
```

### 6.2 Regular Code Review Checklist

Perform monthly reviews:
- [ ] Scan for new SQL queries added to codebase
- [ ] Verify all database interactions use parameterized queries
- [ ] Test critical endpoints with SQLMap
- [ ] Review access logs for suspicious patterns
- [ ] Update input validation rules as needed

## 7. Success Metrics

Track these metrics monthly:
1. **Number of vulnerable endpoints found**: Should trend to 0
2. **SQL injection attempts blocked**: From logs
3. **Code coverage of parameterized queries**: Percentage of database interactions using safe methods
4. **Time to fix new vulnerabilities**: Should decrease over time

## 8. Next Steps

1. **Immediate (Day 1-2)**: Apply emergency quick fixes to production
2. **Short-term (Week 1)**: Implement input validation middleware
3. **Medium-term (Month 1)**: Migrate all queries to parameterized versions
4. **Long-term (Ongoing)**: Regular testing and code reviews

---

**Last Updated**: 2026-03-18  
**Review Schedule**: Monthly  
**Responsible Team**: Development & Security