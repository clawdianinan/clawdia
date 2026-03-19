/**
 * Real-time Test Monitoring Dashboard
 * 
 * Dashboard showing test status for all ongoing work:
 * - Test failures by agent/feature
 * - Immediate notification of test failures
 * - Performance metrics visualization
 * - Cross-browser compatibility status
 */

import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import {
  LineChart,
  Line,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer
} from 'recharts';

// Types
interface TestResult {
  id: string;
  name: string;
  agent: string;
  feature: string;
  status: 'passed' | 'failed' | 'running' | 'pending';
  duration: number;
  timestamp: Date;
  failureReason?: string;
}

interface PerformanceMetric {
  name: string;
  value: number;
  target: number;
  unit: string;
}

interface BrowserCompatibility {
  browser: string;
  version: string;
  passed: number;
  failed: number;
  total: number;
}

interface AgentStatus {
  name: string;
  activeTests: number;
  passedTests: number;
  failedTests: number;
  successRate: number;
}

export const TestDashboard: React.FC = () => {
  const [testResults, setTestResults] = useState<TestResult[]>([]);
  const [performanceMetrics, setPerformanceMetrics] = useState<PerformanceMetric[]>([]);
  const [browserCompatibility, setBrowserCompatibility] = useState<BrowserCompatibility[]>([]);
  const [agentStatus, setAgentStatus] = useState<AgentStatus[]>([]);
  const [alerts, setAlerts] = useState<string[]>([]);
  const [autoRefresh, setAutoRefresh] = useState(true);

  // Mock data - in real implementation, this would come from API
  useEffect(() => {
    loadMockData();
    
    if (autoRefresh) {
      const interval = setInterval(loadMockData, 5000);
      return () => clearInterval(interval);
    }
  }, [autoRefresh]);

  const loadMockData = () => {
    // Mock test results
    const mockTestResults: TestResult[] = [
      {
        id: '1',
        name: 'Accessibility Info Buttons',
        agent: 'Trinity',
        feature: 'Accessibility',
        status: 'passed',
        duration: 245,
        timestamp: new Date()
      },
      {
        id: '2',
        name: 'Motion Design System',
        agent: 'Fela',
        feature: 'Motion',
        status: 'passed',
        duration: 312,
        timestamp: new Date()
      },
      {
        id: '3',
        name: 'Drag-Drop Animations',
        agent: 'Fela',
        feature: 'Micro-interactions',
        status: 'failed',
        duration: 189,
        timestamp: new Date(),
        failureReason: 'Animation jank on mobile Safari'
      },
      {
        id: '4',
        name: 'GDPR Compliance',
        agent: 'Shuri',
        feature: 'Security',
        status: 'running',
        duration: 0,
        timestamp: new Date()
      },
      {
        id: '5',
        name: 'Payment Security',
        agent: 'Shuri',
        feature: 'Security',
        status: 'pending',
        duration: 0,
        timestamp: new Date()
      },
      {
        id: '6',
        name: 'Intro Tour',
        agent: 'Fela',
        feature: 'Onboarding',
        status: 'passed',
        duration: 278,
        timestamp: new Date()
      },
      {
        id: '7',
        name: 'Cross-Browser Compatibility',
        agent: 'Morpheus',
        feature: 'Compatibility',
        status: 'running',
        duration: 0,
        timestamp: new Date()
      }
    ];

    // Mock performance metrics
    const mockPerformanceMetrics: PerformanceMetric[] = [
      { name: 'Load Time', value: 145, target: 200, unit: 'ms' },
      { name: 'FPS', value: 58, target: 55, unit: 'fps' },
      { name: 'Memory Usage', value: 45, target: 50, unit: 'MB' },
      { name: 'CPU Usage', value: 12, target: 20, unit: '%' },
      { name: 'Bundle Size', value: 280, target: 300, unit: 'KB' }
    ];

    // Mock browser compatibility
    const mockBrowserCompatibility: BrowserCompatibility[] = [
      { browser: 'Chrome', version: '120', passed: 42, failed: 1, total: 43 },
      { browser: 'Firefox', version: '115', passed: 41, failed: 2, total: 43 },
      { browser: 'Safari', version: '17', passed: 40, failed: 3, total: 43 },
      { browser: 'Edge', version: '120', passed: 42, failed: 1, total: 43 },
      { browser: 'Mobile Safari', version: '17', passed: 39, failed: 4, total: 43 },
      { browser: 'Chrome Android', version: '120', passed: 41, failed: 2, total: 43 }
    ];

    // Mock agent status
    const mockAgentStatus: AgentStatus[] = [
      { name: 'Trinity', activeTests: 3, passedTests: 12, failedTests: 1, successRate: 92.3 },
      { name: 'Fela', activeTests: 5, passedTests: 18, failedTests: 2, successRate: 90.0 },
      { name: 'Shuri', activeTests: 2, passedTests: 8, failedTests: 0, successRate: 100.0 },
      { name: 'Morpheus', activeTests: 4, passedTests: 15, failedTests: 1, successRate: 93.8 }
    ];

    // Check for new alerts
    const newAlerts: string[] = [];
    const failedTests = mockTestResults.filter(t => t.status === 'failed');
    failedTests.forEach(test => {
      const alert = `🚨 ${test.feature} test failed: ${test.name} - ${test.failureReason}`;
      if (!alerts.includes(alert)) {
        newAlerts.push(alert);
      }
    });

    // Update state
    setTestResults(mockTestResults);
    setPerformanceMetrics(mockPerformanceMetrics);
    setBrowserCompatibility(mockBrowserCompatibility);
    setAgentStatus(mockAgentStatus);
    if (newAlerts.length > 0) {
      setAlerts(prev => [...newAlerts, ...prev].slice(0, 10)); // Keep last 10 alerts
    }
  };

  const getStatusColor = (status: TestResult['status']) => {
    switch (status) {
      case 'passed': return '#10b981';
      case 'failed': return '#ef4444';
      case 'running': return '#3b82f6';
      case 'pending': return '#6b7280';
    }
  };

  const getAgentColor = (agent: string) => {
    switch (agent) {
      case 'Trinity': return '#8b5cf6';
      case 'Fela': return '#ec4899';
      case 'Shuri': return '#06b6d4';
      case 'Morpheus': return '#f59e0b';
      default: return '#6b7280';
    }
  };

  const clearAlerts = () => {
    setAlerts([]);
  };

  const runAllTests = () => {
    // In real implementation, this would trigger test execution
    alert('Running all tests...');
  };

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="max-w-7xl mx-auto"
      >
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Test Monitoring Dashboard</h1>
          <p className="text-gray-600 mt-2">
            Real-time monitoring of continuous testing for PRDForge improvements
          </p>
          
          <div className="flex items-center gap-4 mt-4">
            <button
              onClick={runAllTests}
              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
            >
              Run All Tests
            </button>
            
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={autoRefresh}
                onChange={(e) => setAutoRefresh(e.target.checked)}
                className="rounded"
              />
              <span className="text-sm text-gray-700">Auto-refresh (5s)</span>
            </label>
            
            <div className="ml-auto text-sm text-gray-600">
              Last updated: {new Date().toLocaleTimeString()}
            </div>
          </div>
        </div>

        {/* Alerts Section */}
        {alerts.length > 0 && (
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            className="mb-6"
          >
            <div className="bg-red-50 border border-red-200 rounded-lg p-4">
              <div className="flex justify-between items-center mb-2">
                <h2 className="text-lg font-semibold text-red-800">Test Failures</h2>
                <button
                  onClick={clearAlerts}
                  className="text-sm text-red-600 hover:text-red-800"
                >
                  Clear All
                </button>
              </div>
              <div className="space-y-2">
                {alerts.map((alert, index) => (
                  <div
                    key={index}
                    className="flex items-start gap-2 p-2 bg-white rounded"
                  >
                    <div className="text-red-500 mt-0.5">⚠️</div>
                    <div className="text-sm text-gray-800">{alert}</div>
                  </div>
                ))}
              </div>
            </div>
          </motion.div>
        )}

        {/* Stats Overview */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-xl shadow p-6">
            <h3 className="text-sm font-medium text-gray-500">Total Tests</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">
              {testResults.length}
            </p>
            <div className="flex items-center gap-2 mt-2">
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div 
                  className="bg-green-500 h-2 rounded-full"
                  style={{ width: `${(testResults.filter(t => t.status === 'passed').length / testResults.length) * 100}%` }}
                />
              </div>
              <span className="text-sm text-gray-600">
                {Math.round((testResults.filter(t => t.status === 'passed').length / testResults.length) * 100)}% passed
              </span>
            </div>
          </div>

          <div className="bg-white rounded-xl shadow p-6">
            <h3 className="text-sm font-medium text-gray-500">Active Agents</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">
              {agentStatus.length}
            </p>
            <div className="flex gap-2 mt-2">
              {agentStatus.map(agent => (
                <div
                  key={agent.name}
                  className="w-3 h-3 rounded-full"
                  style={{ backgroundColor: getAgentColor(agent.name) }}
                  title={agent.name}
                />
              ))}
            </div>
          </div>

          <div className="bg-white rounded-xl shadow p-6">
            <h3 className="text-sm font-medium text-gray-500">Avg Test Duration</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">
              {Math.round(testResults.reduce((acc, t) => acc + t.duration, 0) / testResults.length)}ms
            </p>
            <div className="text-sm text-gray-600 mt-2">
              {testResults.filter(t => t.status === 'running').length} tests running
            </div>
          </div>

          <div className="bg-white rounded-xl shadow p-6">
            <h3 className="text-sm font-medium text-gray-500">Browser Coverage</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">
              {browserCompatibility.length}
            </p>
            <div className="text-sm text-gray-600 mt-2">
              {browserCompatibility.reduce((acc, b) => acc + b.passed, 0)}/{browserCompatibility.reduce((acc, b) => acc + b.total, 0)} tests passed
            </div>
          </div>
        </div>

        {/* Main Content Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Test Results Table */}
          <div className="bg-white rounded-xl shadow p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Recent Test Results</h2>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b">
                    <th className="text-left py-2 text-sm font-medium text-gray-500">Test</th>
                    <th className="text-left py-2 text-sm font-medium text-gray-500">Agent</th>
                    <th className="text-left py-2 text-sm font-medium text-gray-500">Status</th>
                    <th className="text-left py-2 text-sm font-medium text-gray-500">Duration</th>
                  </tr>
                </thead>
                <tbody>
                  {testResults.map((test) => (
                    <tr key={test.id} className="border-b hover:bg-gray-50">
                      <td className="py-3">
                        <div className="font-medium text-gray-900">{test.name}</div>
                        <div className="text-sm text-gray-500">{test.feature}</div>
                      </td>
                      <td className="py-3">
                        <div className="flex items-center gap-2">
                          <div
                            className="w-2 h-2 rounded-full"
                            style={{ backgroundColor: getAgentColor(test.agent) }}
                          />
                          <span className="text-sm">{test.agent}</span>
                        </div>
                      </td>
                      <td className="py-3">
                        <div className="flex items-center gap-2">
                          <div
                            className="w-2 h-2 rounded-full"
                            style={{ backgroundColor: getStatusColor(test.status) }}
                          />
                          <span className={`text-sm font-medium ${
                            test.status === 'passed' ? 'text-green-600' :
                            test.status === 'failed' ? 'text-red-600' :
                            test.status === 'running' ? 'text-blue-600' : 'text-gray-600'
                          }`}>
                            {test.status.charAt(0).toUpperCase() + test.status.slice(1)}
                          </span>
                        </div>
                        {test.failureReason && (
                          <div className="text-xs text-red-600 mt-1">{test.failureReason}</div>
                        )}
                      </td>
                      <td className="py-3 text-sm text-gray-600">
                        {test.duration > 0 ? `${test.duration}ms` : '—'}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          {/* Performance Metrics */}
          <div className="bg-white rounded-xl shadow p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Performance Metrics</h2>
            <div className="h-64">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={performanceMetrics}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Bar dataKey="value" name="Current Value" fill="#3b82f6" />
                  <Bar dataKey="target" name="Target" fill="#6b7280" opacity={0.5} />
                </BarChart>
              </ResponsiveContainer>
            </div>
            <div className="grid grid-cols-2 gap-4 mt-4">
              {performanceMetrics.map((metric) => (
                <div key={metric.name} className="p-3 bg-gray-50 rounded-lg">
                  <div className="flex justify-between items-center">
                    <span className="text-sm font-medium text-gray-700">{metric.name}</span>
                    <span className={`text-sm font-bold ${
                      metric.value <= metric.target ? 'text-green-600' : 'text-red-600'
                    }`}>
                      {metric.value}{metric.unit}
                    </span>
                  </div>
                  <div className="text-xs text-gray-500 mt-1">
                    Target: {metric.target}{metric.unit}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Browser Compatibility */}
          <div className="bg-white rounded-xl shadow p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Browser Compatibility</h2>
            <div className="h-64">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={browserCompatibility}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={(entry) => `${entry.browser}`}
                    outerRadius={