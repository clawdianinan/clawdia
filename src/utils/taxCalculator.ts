/**
 * Tax Calculator Utility for PRDForge
 * 
 * Handles VAT, sales tax, and other tax calculations for global payments
 * Supports tax jurisdiction detection and invoice generation
 * 
 * @author Ngozi - Financial Operations & Compliance Specialist
 * @date March 18, 2026
 * @version 1.0
 */

// Tax jurisdiction interface
export interface TaxJurisdiction {
  countryCode: string;
  countryName: string;
  regionCode?: string;
  regionName?: string;
  taxType: 'VAT' | 'GST' | 'SalesTax' | 'None';
  taxRate: number;
  taxName: string;
  requiresTaxId?: boolean;
  taxIdFormat?: RegExp;
  isReverseChargeApplicable?: boolean;
  taxInclusivePricing?: boolean;
}

// Tax calculation result interface
export interface TaxCalculationResult {
  subtotal: number;
  taxAmount: number;
  total: number;
  taxRate: number;
  taxType: string;
  taxName: string;
  jurisdiction: TaxJurisdiction;
  taxIdRequired: boolean;
  isTaxInclusive: boolean;
  breakdown: {
    subtotal: number;
    tax: number;
    total: number;
  };
}

// Invoice tax details interface
export interface InvoiceTaxDetails {
  invoiceNumber: string;
  invoiceDate: Date;
  customerTaxId?: string;
  companyTaxId?: string;
  taxCalculation: TaxCalculationResult;
  lineItems: Array<{
    description: string;
    quantity: number;
    unitPrice: number;
    subtotal: number;
    taxAmount: number;
    total: number;
  }>;
  taxSummary: Array<{
    taxType: string;
    taxRate: number;
    taxableAmount: number;
    taxAmount: number;
  }>;
}

// Common tax jurisdictions (simplified for demonstration)
export const TAX_JURISDICTIONS: TaxJurisdiction[] = [
  // European Union (VAT)
  {
    countryCode: 'DE',
    countryName: 'Germany',
    taxType: 'VAT',
    taxRate: 0.19,
    taxName: 'German VAT',
    requiresTaxId: true,
    taxIdFormat: /^DE\d{9}$/,
    isReverseChargeApplicable: true,
    taxInclusivePricing: true,
  },
  {
    countryCode: 'FR',
    countryName: 'France',
    taxType: 'VAT',
    taxRate: 0.20,
    taxName: 'French VAT',
    requiresTaxId: true,
    taxIdFormat: /^FR[A-Z0-9]{11}$/,
    isReverseChargeApplicable: true,
    taxInclusivePricing: true,
  },
  {
    countryCode: 'GB',
    countryName: 'United Kingdom',
    taxType: 'VAT',
    taxRate: 0.20,
    taxName: 'UK VAT',
    requiresTaxId: true,
    taxIdFormat: /^GB\d{9}$/,
    isReverseChargeApplicable: true,
    taxInclusivePricing: true,
  },
  
  // United States (Sales Tax)
  {
    countryCode: 'US',
    countryName: 'United States',
    regionCode: 'CA',
    regionName: 'California',
    taxType: 'SalesTax',
    taxRate: 0.0725,
    taxName: 'California Sales Tax',
    requiresTaxId: false,
    isReverseChargeApplicable: false,
    taxInclusivePricing: false,
  },
  {
    countryCode: 'US',
    countryName: 'United States',
    regionCode: 'NY',
    regionName: 'New York',
    taxType: 'SalesTax',
    taxRate: 0.04,
    taxName: 'New York State Tax',
    requiresTaxId: false,
    isReverseChargeApplicable: false,
    taxInclusivePricing: false,
  },
  {
    countryCode: 'US',
    countryName: 'United States',
    regionCode: 'TX',
    regionName: 'Texas',
    taxType: 'SalesTax',
    taxRate: 0.0625,
    taxName: 'Texas Sales Tax',
    requiresTaxId: false,
    isReverseChargeApplicable: false,
    taxInclusivePricing: false,
  },
  
  // Canada (GST/HST)
  {
    countryCode: 'CA',
    countryName: 'Canada',
    regionCode: 'ON',
    regionName: 'Ontario',
    taxType: 'GST',
    taxRate: 0.13,
    taxName: 'Ontario HST',
    requiresTaxId: true,
    taxIdFormat: /^[0-9]{9}$/,
    isReverseChargeApplicable: true,
    taxInclusivePricing: true,
  },
  
  // Nigeria (VAT)
  {
    countryCode: 'NG',
    countryName: 'Nigeria',
    taxType: 'VAT',
    taxRate: 0.075,
    taxName: 'Nigerian VAT',
    requiresTaxId: true,
    taxIdFormat: /^NG\d{9}$/,
    isReverseChargeApplicable: false,
    taxInclusivePricing: false,
  },
  
  // Tax-exempt jurisdictions
  {
    countryCode: 'AE',
    countryName: 'United Arab Emirates',
    taxType: 'None',
    taxRate: 0,
    taxName: 'No VAT',
    requiresTaxId: false,
    isReverseChargeApplicable: false,
    taxInclusivePricing: false,
  },
  {
    countryCode: 'HK',
    countryName: 'Hong Kong',
    taxType: 'None',
    taxRate: 0,
    taxName: 'No Sales Tax',
    requiresTaxId: false,
    isReverseChargeApplicable: false,
    taxInclusivePricing: false,
  },
];

/**
 * Detect tax jurisdiction based on country and region
 */
export function detectTaxJurisdiction(
  countryCode: string,
  regionCode?: string
): TaxJurisdiction {
  const countryCodeUpper = countryCode.toUpperCase();
  const regionCodeUpper = regionCode?.toUpperCase();
  
  // First, try to find exact match with region
  if (regionCodeUpper) {
    const exactMatch = TAX_JURISDICTIONS.find(
      jurisdiction => 
        jurisdiction.countryCode === countryCodeUpper && 
        jurisdiction.regionCode === regionCodeUpper
    );
    
    if (exactMatch) {
      return exactMatch;
    }
  }
  
  // Try to find country match without region
  const countryMatch = TAX_JURISDICTIONS.find(
    jurisdiction => 
      jurisdiction.countryCode === countryCodeUpper && 
      !jurisdiction.regionCode
  );
  
  if (countryMatch) {
    return countryMatch;
  }
  
  // Default to tax-exempt if no match found
  return {
    countryCode: countryCodeUpper,
    countryName: 'Unknown',
    taxType: 'None',
    taxRate: 0,
    taxName: 'No Tax Applied',
    requiresTaxId: false,
    isReverseChargeApplicable: false,
    taxInclusivePricing: false,
  };
}

/**
 * Validate tax ID format
 */
export function validateTaxId(taxId: string, jurisdiction: TaxJurisdiction): boolean {
  if (!jurisdiction.requiresTaxId || !jurisdiction.taxIdFormat) {
    return true; // No validation required
  }
  
  return jurisdiction.taxIdFormat.test(taxId);
}

/**
 * Calculate tax for a given amount and jurisdiction
 */
export function calculateTax(
  amount: number,
  jurisdiction: TaxJurisdiction,
  isBusinessCustomer: boolean = false,
  customerTaxId?: string
): TaxCalculationResult {
  const taxRate = jurisdiction.taxRate;
  let taxAmount = 0;
  let subtotal = amount;
  let total = amount;
  
  // Check for reverse charge mechanism (B2B within EU)
  const isReverseCharge = 
    isBusinessCustomer && 
    jurisdiction.isReverseChargeApplicable && 
    customerTaxId && 
    validateTaxId(customerTaxId, jurisdiction);
  
  if (isReverseCharge) {
    // Reverse charge applies, customer pays tax to their own tax authority
    taxAmount = 0;
  } else if (jurisdiction.taxInclusivePricing) {
    // Tax is already included in the price (common in EU)
    subtotal = amount / (1 + taxRate);
    taxAmount = amount - subtotal;
  } else {
    // Tax is added to the price (common in US)
    taxAmount = amount * taxRate;
    total = amount + taxAmount;
  }
  
  return {
    subtotal,
    taxAmount,
    total: jurisdiction.taxInclusivePricing ? amount : total,
    taxRate,
    taxType: jurisdiction.taxType,
    taxName: jurisdiction.taxName,
    jurisdiction,
    taxIdRequired: jurisdiction.requiresTaxId || false,
    isTaxInclusive: jurisdiction.taxInclusivePricing || false,
    breakdown: {
      subtotal,
      tax: taxAmount,
      total: jurisdiction.taxInclusivePricing ? amount : total,
    },
  };
}

/**
 * Generate invoice tax details
 */
export function generateInvoiceTaxDetails(
  invoiceNumber: string,
  lineItems: Array<{
    description: string;
    quantity: number;
    unitPrice: number;
  }>,
  jurisdiction: TaxJurisdiction,
  customerTaxId?: string,
  companyTaxId?: string,
  isBusinessCustomer: boolean = false
): InvoiceTaxDetails {
  const invoiceDate = new Date();
  
  // Calculate line items with tax
  const calculatedLineItems = lineItems.map(item => {
    const subtotal = item.quantity * item.unitPrice;
    const taxCalculation = calculateTax(
      subtotal,
      jurisdiction,
      isBusinessCustomer,
      customerTaxId
    );
    
    return {
      description: item.description,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      subtotal: taxCalculation.subtotal,
      taxAmount: taxCalculation.taxAmount,
      total: taxCalculation.total,
    };
  });
  
  // Calculate totals
  const totalSubtotal = calculatedLineItems.reduce((sum, item) => sum + item.subtotal, 0);
  const totalTax = calculatedLineItems.reduce((sum, item) => sum + item.taxAmount, 0);
  const totalAmount = calculatedLineItems.reduce((sum, item) => sum + item.total, 0);
  
  // Create tax summary
  const taxSummary = [{
    taxType: jurisdiction.taxType,
    taxRate: jurisdiction.taxRate,
    taxableAmount: totalSubtotal,
    taxAmount: totalTax,
  }];
  
  // Overall tax calculation
  const overallTaxCalculation = calculateTax(
    totalSubtotal,
    jurisdiction,
    isBusinessCustomer,
    customerTaxId
  );
  
  return {
    invoiceNumber,
    invoiceDate,
    customerTaxId,
    companyTaxId,
    taxCalculation: overallTaxCalculation,
    lineItems: calculatedLineItems,
    taxSummary,
  };
}

/**
 * Format tax amount for display
 */
export function formatTaxAmount(amount: number, currency: string = 'USD'): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(amount);
}

/**
 * Format tax rate for display
 */
export function formatTaxRate(rate: number): string {
  return `${(rate * 100).toFixed(2)}%`;
}

/**
 * Generate tax compliance statement for invoice
 */
export function generateTaxComplianceStatement(
  jurisdiction: TaxJurisdiction,
  companyTaxId?: string
): string {
  const statements: string[] = [];
  
  if (jurisdiction.taxType === 'VAT') {
    statements.push(`VAT ${formatTaxRate(jurisdiction.taxRate)} applied`);
    if (companyTaxId) {
      statements.push(`Company VAT ID: ${companyTaxId}`);
    }
  } else if (jurisdiction.taxType === 'GST') {
    statements.push(`GST/HST ${formatTaxRate(jurisdiction.taxRate)} applied`);
    if (companyTaxId) {
      statements.push(`Company GST/HST ID: ${companyTaxId}`);
    }
  } else if (jurisdiction.taxType === 'SalesTax') {
    statements.push(`Sales Tax ${formatTaxRate(jurisdiction.taxRate)} applied`);
  } else {
    statements.push('No tax applied');
  }
  
  if (jurisdiction.taxInclusivePricing) {
    statements.push('Prices include applicable taxes');
  } else {
    statements.push('Tax calculated on subtotal');
  }
  
  return statements.join('. ');
}

/**
 * Check if tax ID is required for jurisdiction
 */
export function isTaxIdRequired(countryCode: string, regionCode?: string): boolean {
  const jurisdiction = detectTaxJurisdiction(countryCode, regionCode);
  return jurisdiction.requiresTaxId || false;
}

/**
 * Get all supported countries
 */
export function getSupportedCountries(): Array<{
  countryCode: string;
  countryName: string;
  taxType: string;
  taxRate: number;
}> {
  const countries = new Map();
  
  TAX_JURISDICTIONS.forEach(jurisdiction => {
    if (!countries.has(jurisdiction.countryCode)) {
      countries.set(jurisdiction.countryCode, {
        countryCode: jurisdiction.countryCode,
        countryName: jurisdiction.countryName,
        taxType: jurisdiction.taxType,
        taxRate: jurisdiction.taxRate,
      });
    }
  });
  
  return Array.from(countries.values());
}

// Example usage
/*
// Example 1: Calculate tax for a customer in Germany
const germanJurisdiction = detectTaxJurisdiction('DE');
const germanTax = calculateTax(100, germanJurisdiction, true, 'DE123456789');
console.log('German VAT Calculation:', germanTax);

// Example 2: Calculate tax for a customer in California
const californiaJurisdiction = detectTaxJurisdiction('US', 'CA');
const californiaTax = calculateTax(100, californiaJurisdiction);
console.log('California Sales Tax Calculation:', californiaTax);

// Example 3: Generate invoice for a business customer
const invoiceDetails = generateInvoiceTaxDetails(
  'INV-2026-001',
  [
    { description: 'PRDForge Pro Plan', quantity: 1, unitPrice: 99 },
    { description: 'Additional Users', quantity: 5, unitPrice: 20 },
  ],
  germanJurisdiction,
  'DE123456789',
  'GB987654321',
  true
);
console.log('Invoice Tax Details:', invoiceDetails);
*/