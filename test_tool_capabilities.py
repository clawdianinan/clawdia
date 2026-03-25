#!/usr/bin/env python3
"""
Standardized test to evaluate development tool capabilities.
Task: Create a Python function that validates email addresses with regex.
"""

import re

def validate_email(email: str) -> bool:
    """
    Validate an email address using regex.
    
    Args:
        email (str): Email address to validate
        
    Returns:
        bool: True if valid, False otherwise
    """
    # Basic email regex pattern
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    
    # Check if email matches pattern
    if re.match(pattern, email):
        return True
    return False

# Test cases
test_emails = [
    ("test@example.com", True),
    ("user.name@domain.co.uk", True),
    ("invalid-email", False),
    ("missing@tld.", False),
    ("@domain.com", False),
    ("test@sub.domain.com", True),
]

def run_tests():
    """Run all test cases and report results."""
    print("Email Validation Test Results:")
    print("=" * 40)
    
    all_passed = True
    for email, expected in test_emails:
        result = validate_email(email)
        passed = result == expected
        
        if passed:
            print(f"✓ {email:30} -> {result} (expected: {expected})")
        else:
            print(f"✗ {email:30} -> {result} (expected: {expected})")
            all_passed = False
    
    print("=" * 40)
    if all_passed:
        print("All tests passed! ✅")
    else:
        print("Some tests failed! ❌")
    
    return all_passed

if __name__ == "__main__":
    run_tests()