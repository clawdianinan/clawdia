/**
 * Financial Reporting Utility for PRDForge
 * 
 * Automated revenue reporting, transaction audit trail, and financial statement generation
 * 
 * @author Ngozi - Financial Operations & Compliance Specialist
 * @date March 18, 2026
 * @version 1.0
 */

// Financial transaction interface
export interface FinancialTransaction {
  id: string;
  type: 'payment' | 'refund' | 'adjustment' | 'fee' | 'payout';
  status: 'pending' | 'completed' | 'failed' | 'reversed';
  amount: number;
  currency: string;
  description: string;
  customerId?: string;
  customerEmail?: string;
  invoiceId?: string;
  subscriptionId?: string;
  paymentMethod: 'stripe' | 'paypal' | 'paystack' | 'nowpayments' | 'bank_transfer';
  paymentGatewayId?: string;
  taxAmount?: number;
  feeAmount?: number;
  netAmount: number;
  metadata?: Record<string, any>;
  createdAt: Date;
  processedAt?: Date;
  reconciledAt?: Date;
}

// Revenue report interface
export interface RevenueReport {
  period: {
    start: Date;
    end: Date;
    timezone: string;
  };
  summary: {
    totalRevenue: number;
    totalTransactions: number;
    averageTransactionValue: number;
    refundRate: number;
    netRevenue: number;
  };
  byPaymentMethod: Array<{
    method: string;
    count: number;
    amount: number;
    percentage: number;
  }>;
  byPlan: Array<{
    plan: string;
    count: number;
    amount: number;
    percentage: number;
  }>;
  byCountry: Array<{
    country: string;
    count: number;
    amount: number;
    percentage: number;
  }>;
  dailyBreakdown: Array<{
    date: string;
    transactions: number;
    revenue: number;
    refunds: number;
    netRevenue: number;
  }>;
  currencyBreakdown: Array<{
    currency: string;
    count: number;
    amount: number;
    percentage: number;
  }>;
}

// Financial statement interface
export interface FinancialStatement {
  period: {
    start: Date;
    end: Date;
  };
  incomeStatement: {
    revenue: {
      subscriptions: number;
      oneTimePurchases: number;
      services: number;
      total: number;
    };
    costOfRevenue: {
      paymentProcessing: number;
      hosting: number;
      support: number;
      total: number;
    };
    grossProfit: number;
    operatingExpenses: {
      marketing: number;
      salaries: number;
      software: number;
      professionalFees: number;
      total: number;
    };
    operatingIncome: number;
    taxes: number;
    netIncome: number;
  };
  balanceSheet: {
    assets: {
      current: {
        cash: number;
        accountsReceivable: number;
        total: number;
      };
      fixed: {
        equipment: number;
        software: number;
        total: number;
      };
      total: number;
    };
    liabilities: {
      current: {
        accountsPayable: number;
        deferredRevenue: number;
        total: number;
      };
      longTerm: {
        loans: number;
        total: number;
      };
      total: number;
    };
    equity: {
      retainedEarnings: number;
      total: number;
    };
  };
  cashFlow: {
    operating: {
      netIncome: number;
      adjustments: number;
      changesInWorkingCapital: number;
      total: number;
    };
    investing: {
      capitalExpenditures: number;
      investments: number;
      total: number;
    };
    financing: {
      debtIssued: number;
      equityIssued: number;
      dividends: number;
      total: number;
    };
    netChange: number;
  };
}

// Audit trail entry interface
export interface AuditTrailEntry {
  id: string;
  timestamp: Date;
  userId?: string;
  userType: 'system' | 'admin' | 'customer' | 'gateway';
  action: string;
  entityType: 'transaction' | 'invoice' | 'customer' | 'subscription';
  entityId: string;
  changes: Array<{
    field: string;
    oldValue: any;
    newValue: any;
  }>;
  ipAddress?: string;
  userAgent?: string;
  metadata?: Record<string, any>;
}

/**
 * Financial Reporting Class
 */
export class FinancialReporting {
  private transactions: FinancialTransaction[] = [];
  private auditTrail: AuditTrailEntry[] = [];

  constructor() {
    this.initializeAuditTrail();
  }

  /**
   * Initialize audit trail with system events
   */
  private initializeAuditTrail(): void {
    this.addAuditTrailEntry({
      timestamp: new Date(),
      userType: 'system',
      action: 'system_initialized',
      entityType: 'system',
      entityId: 'financial_reporting',
      changes: [],
      metadata: { version: '1.0' },
    });
  }

  /**
   * Add a transaction to the system
   */
  addTransaction(transaction: Omit<FinancialTransaction, 'id' | 'createdAt'>): FinancialTransaction {
    const newTransaction: FinancialTransaction = {
      ...transaction,
      id: this.generateTransactionId(),
      createdAt: new Date(),
    };

    this.transactions.push(newTransaction);

    // Add to audit trail
    this.addAuditTrailEntry({
      timestamp: new Date(),
      userType: 'system',
      action: 'transaction_created',
      entityType: 'transaction',
      entityId: newTransaction.id,
      changes: [
        {
          field: 'status',
          oldValue: null,
          newValue: newTransaction.status,
        },
        {
          field: 'amount',
          oldValue: null,
          newValue: newTransaction.amount,
        },
      ],
      metadata: {
        type: newTransaction.type,
        paymentMethod: newTransaction.paymentMethod,
      },
    });

    return newTransaction;
  }

  /**
   * Update transaction status
   */
  updateTransactionStatus(
    transactionId: string,
    newStatus: FinancialTransaction['status'],
    userId?: string
  ): boolean {
    const transaction = this.transactions.find(t => t.id === transactionId);
    
    if (!transaction) {
      return false;
    }

    const oldStatus = transaction.status;
    transaction.status = newStatus;
    transaction.processedAt = new Date();

    // Add to audit trail
    this.addAuditTrailEntry({
      timestamp: new Date(),
      userId,
      userType: userId ? 'admin' : 'system',
      action: 'transaction_status_updated',
      entityType: 'transaction',
      entityId: transactionId,
      changes: [
        {
          field: 'status',
          oldValue: oldStatus,
          newValue: newStatus,
        },
      ],
      metadata: {
        processedAt: transaction.processedAt,
      },
    });

    return true;
  }

  /**
   * Generate revenue report for a period
   */
  generateRevenueReport(startDate: Date, endDate: Date): RevenueReport {
    const periodTransactions = this.transactions.filter(
      t => t.createdAt >= startDate && t.createdAt <= endDate && t.type === 'payment'
    );

    const refundTransactions = this.transactions.filter(
      t => t.createdAt >= startDate && t.createdAt <= endDate && t.type === 'refund'
    );

    const totalRevenue = periodTransactions.reduce((sum, t) => sum + t.amount, 0);
    const totalRefunds = refundTransactions.reduce((sum, t) => sum + t.amount, 0);
    const netRevenue = totalRevenue - totalRefunds;
    const refundRate = totalRevenue > 0 ? (totalRefunds / totalRevenue) * 100 : 0;

    // Group by payment method
    const paymentMethodMap = new Map<string, { count: number; amount: number }>();
    periodTransactions.forEach(t => {
      const current = paymentMethodMap.get(t.paymentMethod) || { count: 0, amount: 0 };
      paymentMethodMap.set(t.paymentMethod, {
        count: current.count + 1,
        amount: current.amount + t.amount,
      });
    });

    const byPaymentMethod = Array.from(paymentMethodMap.entries()).map(([method, data]) => ({
      method,
      count: data.count,
      amount: data.amount,
      percentage: totalRevenue > 0 ? (data.amount / totalRevenue) * 100 : 0,
    }));

    // Group by country (simplified - would need customer data)
    const byCountry: RevenueReport['byCountry'] = [];

    // Daily breakdown
    const dailyBreakdownMap = new Map<string, { transactions: number; revenue: number; refunds: number }>();
    
    periodTransactions.forEach(t => {
      const dateStr = t.createdAt.toISOString().split('T')[0];
      const current = dailyBreakdownMap.get(dateStr) || { transactions: 0, revenue: 0, refunds: 0 };
      dailyBreakdownMap.set(dateStr, {
        transactions: current.transactions + 1,
        revenue: current.revenue + t.amount,
        refunds: current.refunds,
      });
    });

    refundTransactions.forEach(t => {
      const dateStr = t.createdAt.toISOString().split('T')[0];
      const current = dailyBreakdownMap.get(dateStr) || { transactions: 0, revenue: 0, refunds: 0 };
      dailyBreakdownMap.set(dateStr, {
        ...current,
        refunds: current.refunds + t.amount,
      });
    });

    const dailyBreakdown = Array.from(dailyBreakdownMap.entries()).map(([date, data]) => ({
      date,
      transactions: data.transactions,
      revenue: data.revenue,
      refunds: data.refunds,
      netRevenue: data.revenue - data.refunds,
    })).sort((a, b) => a.date.localeCompare(b.date));

    // Currency breakdown
    const currencyMap = new Map<string, { count: number; amount: number }>();
    periodTransactions.forEach(t => {
      const current = currencyMap.get(t.currency) || { count: 0, amount: 0 };
      currencyMap.set(t.currency, {
        count: current.count + 1,
        amount: current.amount + t.amount,
      });
    });

    const currencyBreakdown = Array.from(currencyMap.entries()).map(([currency, data]) => ({
      currency,
      count: data.count,
      amount: data.amount,
      percentage: totalRevenue > 0 ? (data.amount / totalRevenue) * 100 : 0,
    }));

    return {
      period: {
        start: startDate,
        end: endDate,
        timezone: 'UTC',
      },
      summary: {
        totalRevenue,
        totalTransactions: periodTransactions.length,
        averageTransactionValue: periodTransactions.length > 0 ? totalRevenue / periodTransactions.length : 0,
        refundRate,
        netRevenue,
      },
      byPaymentMethod,
      byPlan: [], // Would need subscription plan data
      byCountry,
      dailyBreakdown,
      currencyBreakdown,
    };
  }

  /**
   * Generate financial statement
   */
  generateFinancialStatement(startDate: Date, endDate: Date): FinancialStatement {
    const revenueReport = this.generateRevenueReport(startDate, endDate);

    // Simplified financial statement - in production, this would integrate with accounting system
    const incomeStatement = {
      revenue: {
        subscriptions: revenueReport.netRevenue * 0.8, // Estimate 80% from subscriptions
        oneTimePurchases: revenueReport.netRevenue * 0.15, // Estimate 15% from one-time
        services: revenueReport.netRevenue * 0.05, // Estimate 5% from services
        total: revenueReport.netRevenue,
      },
      costOfRevenue: {
        paymentProcessing: revenueReport.netRevenue * 0.029 + 0.30, // 2.9% + $0.30 per transaction average
        hosting: 500, // Monthly hosting estimate
        support: 1000, // Monthly support costs
        total: 0, // Calculated below
      },
      grossProfit: 0,
      operatingExpenses: {
        marketing: 2000,
        salaries: 8000,
        software: 500,
        professionalFees: 1000,
        total: 0, // Calculated below
      },
      operatingIncome: 0,
      taxes: 0,
      netIncome: 0,
    };

    // Calculate totals
    incomeStatement.costOfRevenue.total = 
      incomeStatement.costOfRevenue.paymentProcessing +
      incomeStatement.costOfRevenue.hosting +
      incomeStatement.costOfRevenue.support;

    incomeStatement.grossProfit = incomeStatement.revenue.total - incomeStatement.costOfRevenue.total;

    incomeStatement.operatingExpenses.total = 
      incomeStatement.operatingExpenses.marketing +
      incomeStatement.operatingExpenses.salaries +
      incomeStatement.operatingExpenses.software +
      incomeStatement.operatingExpenses.professionalFees;

    incomeStatement.operatingIncome = incomeStatement.grossProfit - incomeStatement.operatingExpenses.total;
    
    // Estimate taxes (simplified)
    incomeStatement.taxes = Math.max(0, incomeStatement.operatingIncome * 0.25);
    incomeStatement.netIncome = incomeStatement.operatingIncome - incomeStatement.taxes;

    // Simplified balance sheet (static for demo)
    const balanceSheet = {
      assets: {
        current: {
          cash: 50000,
          accountsReceivable: revenueReport.netRevenue * 0.1, // 10% of monthly revenue as AR
          total: 0,
        },
        fixed: {
          equipment: 10000,
          software: 20000,
          total: 0,
        },
        total: 0,
      },
      liabilities: {
        current: {
          accountsPayable: 5000,
          deferredRevenue: revenueReport.netRevenue * 0.2, // 20% as deferred (annual subscriptions)
          total: 0,
        },
        longTerm: {
          loans: 0,
          total: 0,
        },
        total: 0,
      },
      equity: {
        retainedEarnings: 30000,
        total: 0,
      },
    };

    // Calculate balance sheet totals
    balanceSheet.assets.current.total = 
      balanceSheet.assets.current.cash + 
      balanceSheet.assets.current.accountsReceivable;
    
    balanceSheet.assets.fixed.total = 
      balanceSheet.assets.fixed.equipment + 
      balanceSheet.assets.fixed.software;
    
    balanceSheet.assets.total = 
      balanceSheet.assets.current.total + 
      balanceSheet.assets.fixed.total;

    balanceSheet.liabilities.current.total = 
      balanceSheet.liabilities.current.accountsPayable + 
      balanceSheet.liabilities.current.deferredRevenue;
    
    balanceSheet.liabilities.total = 
      balanceSheet.liabilities.current.total + 
      balanceSheet.liabilities.longTerm.total;

    balanceSheet.equity.total = balanceSheet.equity.retainedEarnings + incomeStatement.netIncome;

    // Cash flow statement (simplified)
    const cashFlow = {
      operating: {
        netIncome: incomeStatement.netIncome,
        adjustments: 2000, // Depreciation, etc.
        changesInWorkingCapital: -1000,
        total: 0,
      },
      investing: {
        capitalExpenditures: -500,
        investments: 0,
        total: 0,
      },
      financing: {
        debtIssued: 0,
        equityIssued: 0,
        dividends: 0,
        total: 0,
      },
      netChange: 0,
    };

    // Calculate cash flow totals
    cashFlow.operating.total = 
      cashFlow.operating.netIncome + 
      cashFlow.operating.adjustments + 
      cashFlow.operating.changesInWorkingCapital;
    
    cashFlow.investing.total = 
      cashFlow.investing.capitalExpenditures + 
      cashFlow.investing.investments;
    
    cashFlow.financing.total = 
      cashFlow.financing.debtIssued + 
      cashFlow.financing.equityIssued + 
      cashFlow.financing.dividends;
    
    cashFlow.netChange = 
      cashFlow.operating.total + 
      cashFlow.investing.total + 
      cashFlow.financing.total;

    return {
      period: { start: startDate, end: endDate },
      incomeStatement,
      balanceSheet,
      cashFlow,
    };
  }

  /**
   * Get audit trail for a specific entity
   */
  getAuditTrail(
    entityType?: AuditTrailEntry['entityType'],
    entityId?: string,
    startDate?: Date,
    endDate?: Date
  ): AuditTrailEntry[] {
    let filtered = this.auditTrail;

    if (entityType) {
      filtered = filtered.filter(entry => entry.entityType === entityType);
    }

    if (entityId) {
      filtered = filtered.filter(entry => entry.entityId === entityId);
    }

    if (startDate) {
      filtered = filtered.filter(entry => entry.timestamp >= startDate);
    }

    if (endDate) {
      filtered = filtered.filter(entry => entry.timestamp <= endDate);
    }

    return filtered.sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime());
  }

  /**
   * Export financial data for accounting systems
   */
  exportToAccountingFormat(
    startDate: Date,
    endDate: Date,
    format: 'quickbooks' | 'xero' | 'csv'
  ): string {
    const transactions = this.transactions.filter(
      t => t.createdAt >= startDate && t.createdAt <= endDate
    );

    switch (format) {
      case 'csv':
        return this.exportToCSV(transactions);
      case 'quickbooks':
        return this.exportToQuickBooks(transactions);
      case 'xero':
        return this.exportToXero(transactions);
      default:
        return this.exportToCSV(transactions);
    }
  }

  /**
   * Generate transaction reconciliation report
   */
  generateReconciliationReport(startDate: Date, endDate: Date): {
    period: { start: Date; end: Date };
    gatewayTransactions: number;
    systemTransactions: number;
    matched: number;
    unmatched: number;
    discrepancies: Array<{
      transactionId: string;
      gatewayId?: string;
      systemAmount: number;
      gatewayAmount?: number;
      difference: number;
      status: 'matched' | 'unmatched' | 'missing';
    }>;
  } {
    // This would integrate with payment gateway APIs in production
    // For demo, we'll simulate some data
    const systemTransactions = this.transactions.filter(
      t => t.createdAt >= startDate && t.createdAt <= endDate
    );

    // Simulate gateway data (in production, fetch from Stripe/PayPal APIs)
    const simulatedGatewayData = systemTransactions.map(t => ({
      gatewayId: `gateway_${t.id}`,
      amount: t.amount,
      currency: t.currency,
      status: t.status,
    }));

    const discrepancies = systemTransactions.map(t => {
      const gatewayMatch = simulatedGatewayData.find(g => g.gatewayId === `gateway_${t.id}`);
      
      if (!gatewayMatch) {
        return {
          transactionId: t.id,
          systemAmount: t.amount,
          difference: t.amount,
          status: 'missing' as const,
        };
      }

      const difference = Math.abs(t.amount - gatewayMatch.amount);
      
      return {
        transactionId: t.id,
        gatewayId: gatewayMatch.gatewayId,
        systemAmount: t.amount,
        gatewayAmount: gatewayMatch.amount,
        difference,
        status: difference < 0.01 ? 'matched' : 'unmatched',
      };
    });

    const matched = discrepancies.filter(d => d.status === 'matched').length;
    const unmatched = discrepancies.filter(d => d.status !== 'matched').length;

    return {
      period: { start: startDate, end: endDate },
      gatewayTransactions: simulatedGatewayData.length,
      systemTransactions: systemTransactions.length,
      matched,
      unmatched,
      discrepancies,
    };
  }

  /**
   * Generate financial metrics dashboard
   */
  generateFinancialMetrics(startDate: Date, endDate: Date): {
    mrr: number; // Monthly Recurring Revenue
    arr: number; // Annual Recurring Revenue
    churnRate: number;
    customerLifetimeValue: number;
    customerAcquisitionCost: number;
    ltvCacRatio: number;
    grossMargin: number;
    netMargin: number;
  } {
    const revenueReport = this.generateRevenueReport(startDate, endDate);
    const financialStatement = this.generateFinancialStatement(startDate, endDate);

    // Simplified metrics calculation
    const mrr = revenueReport.netRevenue;
    const arr = mrr * 12;
    const churnRate = 0.05; // 5% monthly churn (would need subscription data)
    const customerLifetimeValue = mrr / churnRate;
    const customerAcquisitionCost = 100; // Estimated CAC
    const ltvCacRatio = customerLifetimeValue / customerAcquisitionCost;
    const grossMargin = (financialStatement.incomeStatement.grossProfit / financialStatement.incomeStatement.revenue.total) * 100;
    const netMargin = (financialStatement.incomeStatement.netIncome / financialStatement.incomeStatement.revenue.total) * 100;

    return {
      mrr,
      arr,
      churnRate: churnRate * 100, // Convert to percentage
      customerLifetimeValue,
      customerAcquisitionCost,
      ltvCacRatio,
      grossMargin,
      netMargin,
    };
  }

  /**
   * Private helper methods
   */
  private generateTransactionId(): string {
    return `txn_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  private addAuditTrailEntry(entry: Omit<AuditTrailEntry, 'id'>): void {
    const newEntry: AuditTrailEntry = {
      ...entry,
      id: `audit_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
    };
    this.auditTrail.push(newEntry);
  }

  private exportToCSV(transactions: FinancialTransaction[]): string {
    const headers = [
      'ID',
      'Date',
      'Type',
      'Status',
      'Amount',
      'Currency',
      'Description',
      'Customer Email',
      'Payment Method',
      'Tax Amount',
      'Fee Amount',
      'Net Amount',
    ];

    const rows = transactions.map(t => [
      t.id,
      t.createdAt.toISOString(),
      t.type,
      t.status,
      t.amount.toString(),
      t.currency,
      t.description,
      t.customerEmail || '',
      t.paymentMethod,
      (t.taxAmount || 0).toString(),
      (t.feeAmount || 0).toString(),
      t.netAmount.toString(),
    ]);

    return [headers, ...rows].map(row => row.join(',')).join('\n');
  }

  private exportToQuickBooks(transactions: FinancialTransaction[]): string {
    // Simplified QuickBooks format
    const qbRows = transactions.map(t => ({
      'Date': t.createdAt.toISOString().split('T')[0],
      'Transaction Type': t.type === 'refund' ? 'Refund' : 'Sale',
      'Account': 'Accounts Receivable',
      'Name': t.customerEmail || 'Unknown',
      'Amount': t.netAmount,
      'Description': t.description,
      'Payment Method': this.mapPaymentMethodToQB(t.paymentMethod),
    }));

    return JSON.stringify(qbRows, null, 2);
  }

  private exportToXero(transactions: FinancialTransaction[]): string {
    // Simplified Xero format
    const xeroRows = transactions.map(t => ({
      'ContactName': t.customerEmail || 'Unknown',
      'EmailAddress': t.customerEmail || '',
      'POAddressLine1': '',
      'POCity': '',
      'POCountry': '',
      'InvoiceNumber': t.invoiceId || t.id,
      'Reference': t.description,
      'InvoiceDate': t.createdAt.toISOString().split('T')[0],
      'DueDate': new Date(t.createdAt.getTime() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
      'InventoryItemCode': 'SERVICE',
      'Description': t.description,
      'Quantity': 1,
      'UnitAmount': t.netAmount,
      'AccountCode': 200,
      'TaxType': 'OUTPUT',
    }));

    return JSON.stringify(xeroRows, null, 2);
  }

  private mapPaymentMethodToQB(method: FinancialTransaction['paymentMethod']): string {
    const map: Record<FinancialTransaction['paymentMethod'], string> = {
      stripe: 'Credit Card',
      paypal: 'PayPal',
      paystack: 'Credit Card',
      nowpayments: 'Cryptocurrency',
      bank_transfer: 'Bank Transfer',
    };
    return map[method] || 'Other';
  }

  /**
   * Get all transactions (for testing/demo)
   */
  getAllTransactions(): FinancialTransaction[] {
    return [...this.transactions];
  }

  /**
   * Get all audit trail entries (for testing/demo)
   */
  getAllAuditTrail(): AuditTrailEntry[] {
    return [...this.auditTrail];
  }
}

// Example usage
/*
// Initialize financial reporting
const financialReporting = new FinancialReporting();

// Add some sample transactions
financialReporting.addTransaction({
  type: 'payment',
  status: 'completed',
  amount: 99.00,
  currency: 'USD',
  description: 'PRDForge Pro Plan - Monthly',
  customerEmail: 'customer@example.com',
  paymentMethod: 'stripe',
  netAmount: 95.00,
  taxAmount: 4.00,
  feeAmount: 0.30,
});

financialReporting.addTransaction({
  type: 'payment',
  status: 'completed',
  amount: 299.00,
  currency: 'USD',
  description: 'PRDForge Business Plan - Annual',
  customerEmail: 'business@example.com',
  paymentMethod: 'paypal',
  netAmount: 290.00,
  taxAmount: 9.00,
  feeAmount: 8.70,
});

// Generate revenue report for current month
const startOfMonth = new Date(new Date().getFullYear(), new Date().getMonth(), 1);
const endOfMonth = new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0);
const revenueReport = financialReporting.generateRevenueReport(startOfMonth, endOfMonth);
console.log('Revenue Report:', revenueReport);

// Generate financial statement
const financialStatement = financialReporting.generateFinancialStatement(startOfMonth, endOfMonth);
console.log('Financial Statement:', financialStatement);

// Get audit trail
const auditTrail = financialReporting.getAuditTrail('transaction');
console.log('Audit Trail:', auditTrail);

// Export to CSV
const csvExport = financialReporting.exportToAccountingFormat(startOfMonth, endOfMonth, 'csv');
console.log('CSV Export:', csvExport);
*/