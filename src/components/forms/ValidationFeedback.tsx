/**
 * Validation Feedback Component
 * 
 * Implements form validation animations, confirmation dialogs with micro-interactions,
 * and undo/redo feedback with spatial awareness.
 */

import React, { useState, useRef, useEffect, useCallback } from 'react';
import { MotionClasses, applyMotionClasses, removeMotionClasses } from '../../styles/motion-utils';

/**
 * Validation type
 */
export type ValidationType = 'success' | 'error' | 'warning' | 'info' | 'loading';

/**
 * Validation rule
 */
export interface ValidationRule {
  id: string;
  type: ValidationType;
  message: string;
  condition: (value: string) => boolean;
  priority?: number; // Higher priority shows first
}

/**
 * Field configuration
 */
export interface FieldConfig {
  id: string;
  label: string;
  type?: 'text' | 'email' | 'password' | 'number' | 'textarea';
  placeholder?: string;
  required?: boolean;
  minLength?: number;
  maxLength?: number;
  pattern?: RegExp;
  validationRules?: ValidationRule[];
  autoValidate?: boolean; // Validate on change
  showCharacterCount?: boolean;
  showValidationIcons?: boolean;
  undoRedoEnabled?: boolean; // Enable undo/redo for this field
}

/**
 * Validation state
 */
interface ValidationState {
  isValid: boolean;
  isTouched: boolean;
  isFocused: boolean;
  isDirty: boolean;
  validationResults: ValidationRule[];
  characterCount: number;
  lastValidValue: string;
  valueHistory: string[];
  historyIndex: number;
}

/**
 * ValidationFeedback props
 */
export interface ValidationFeedbackProps {
  fields: FieldConfig[];
  onSubmit?: (values: Record<string, string>) => void;
  onValidationChange?: (fieldId: string, isValid: boolean) => void;
  showLiveValidation?: boolean;
  confirmOnSubmit?: boolean;
  confirmMessage?: string;
  undoRedoEnabled?: boolean;
  maxHistorySteps?: number;
  className?: string;
}

/**
 * ValidationFeedback Component
 */
export const ValidationFeedback: React.FC<ValidationFeedbackProps> = ({
  fields,
  onSubmit,
  onValidationChange,
  showLiveValidation = true,
  confirmOnSubmit = false,
  confirmMessage = 'Are you sure you want to submit?',
  undoRedoEnabled = true,
  maxHistorySteps = 10,
  className = '',
}) => {
  const [values, setValues] = useState<Record<string, string>>({});
  const [validationStates, setValidationStates] = useState<Record<string, ValidationState>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showConfirmDialog, setShowConfirmDialog] = useState(false);
  const [globalMessage, setGlobalMessage] = useState<{ type: ValidationType; message: string } | null>(null);
  
  const fieldRefs = useRef<Record<string, HTMLInputElement | HTMLTextAreaElement | null>>({});
  const messageTimeout = useRef<NodeJS.Timeout | null>(null);
  const undoRedoStack = useRef<Record<string, { undo: () => void; redo: () => void }[]>>({});

  /**
   * Initialize validation states
   */
  useEffect(() => {
    const initialStates: Record<string, ValidationState> = {};
    
    fields.forEach(field => {
      initialStates[field.id] = {
        isValid: true,
        isTouched: false,
        isFocused: false,
        isDirty: false,
        validationResults: [],
        characterCount: 0,
        lastValidValue: '',
        valueHistory: [''],
        historyIndex: 0,
      };
      
      undoRedoStack.current[field.id] = [];
    });
    
    setValidationStates(initialStates);
  }, [fields]);

  /**
   * Validate a field
   */
  const validateField = useCallback((fieldId: string, value: string): ValidationRule[] => {
    const field = fields.find(f => f.id === fieldId);
    if (!field) return [];

    const results: ValidationRule[] = [];

    // Required validation
    if (field.required && !value.trim()) {
      results.push({
        id: 'required',
        type: 'error',
        message: `${field.label} is required`,
        condition: () => false,
        priority: 100,
      });
    }

    // Min length validation
    if (field.minLength && value.length < field.minLength) {
      results.push({
        id: 'minLength',
        type: 'error',
        message: `Must be at least ${field.minLength} characters`,
        condition: () => false,
        priority: 90,
      });
    }

    // Max length validation
    if (field.maxLength && value.length > field.maxLength) {
      results.push({
        id: 'maxLength',
        type: 'error',
        message: `Must be at most ${field.maxLength} characters`,
        condition: () => false,
        priority: 80,
      });
    }

    // Pattern validation
    if (field.pattern && value && !field.pattern.test(value)) {
      results.push({
        id: 'pattern',
        type: 'error',
        message: 'Invalid format',
        condition: () => false,
        priority: 70,
      });
    }

    // Custom validation rules
    if (field.validationRules) {
      field.validationRules.forEach(rule => {
        if (!rule.condition(value)) {
          results.push({ ...rule, priority: rule.priority || 60 });
        }
      });
    }

    // Success validation (only if no errors and value is not empty)
    if (results.length === 0 && value.trim()) {
      results.push({
        id: 'success',
        type: 'success',
        message: `${field.label} looks good!`,
        condition: () => true,
        priority: 50,
      });
    }

    // Sort by priority (higher first)
    results.sort((a, b) => (b.priority || 0) - (a.priority || 0));

    return results;
  }, [fields]);

  /**
   * Update validation state
   */
  const updateValidationState = useCallback((fieldId: string, updates: Partial<ValidationState>) => {
    setValidationStates(prev => ({
      ...prev,
      [fieldId]: {
        ...prev[fieldId],
        ...updates,
      },
    }));
  }, []);

  /**
   * Handle field change
   */
  const handleFieldChange = useCallback((fieldId: string, value: string) => {
    const field = fields.find(f => f.id === fieldId);
    if (!field) return;

    // Update value
    setValues(prev => ({ ...prev, [fieldId]: value }));

    // Update character count
    updateValidationState(fieldId, {
      characterCount: value.length,
      isDirty: true,
    });

    // Add to history if undo/redo enabled
    if (field.undoRedoEnabled !== false && undoRedoEnabled) {
      const currentState = validationStates[fieldId];
      if (currentState) {
        const newHistory = [...currentState.valueHistory.slice(0, currentState.historyIndex + 1), value];
        const trimmedHistory = newHistory.slice(-maxHistorySteps);
        
        updateValidationState(fieldId, {
          valueHistory: trimmedHistory,
          historyIndex: trimmedHistory.length - 1,
        });
      }
    }

    // Auto-validate if enabled
    if (field.autoValidate !== false && showLiveValidation) {
      const validationResults = validateField(fieldId, value);
      const isValid = validationResults.every(result => result.type !== 'error');
      
      updateValidationState(fieldId, {
        validationResults,
        isValid,
        lastValidValue: isValid ? value : currentState.lastValidValue,
      });

      onValidationChange?.(fieldId, isValid);

      // Show validation feedback
      const fieldElement = fieldRefs.current[fieldId];
      if (fieldElement) {
        if (isValid && value.trim()) {
          applyMotionClasses(fieldElement, 'SUCCESS_CHECKMARK');
          setTimeout(() => removeMotionClasses(fieldElement, 'SUCCESS_CHECKMARK'), 1000);
        } else if (!isValid) {
          applyMotionClasses(fieldElement, 'ERROR_SHAKE');
          setTimeout(() => removeMotionClasses(fieldElement, 'ERROR_SHAKE'), 600);
        }
      }
    }
  }, [fields, validationStates, updateValidationState, validateField, showLiveValidation, onValidationChange, undoRedoEnabled, maxHistorySteps]);

  /**
   * Handle field focus
   */
  const handleFieldFocus = useCallback((fieldId: string) => {
    const fieldElement = fieldRefs.current[fieldId];
    if (fieldElement) {
      applyMotionClasses(fieldElement, 'INPUT_FOCUS_LIFT');
    }

    updateValidationState(fieldId, {
      isFocused: true,
      isTouched: true,
    });
  }, [updateValidationState]);

  /**
   * Handle field blur
   */
  const handleFieldBlur = useCallback((fieldId: string, value: string) => {
    const fieldElement = fieldRefs.current[fieldId];
    if (fieldElement) {
      removeMotionClasses(fieldElement, 'INPUT_FOCUS_LIFT');
    }

    updateValidationState(fieldId, {
      isFocused: false,
    });

    // Validate on blur
    const validationResults = validateField(fieldId, value);
    const isValid = validationResults.every(result => result.type !== 'error');
    
    updateValidationState(fieldId, {
      validationResults,
      isValid,
      lastValidValue: isValid ? value : validationStates[fieldId]?.lastValidValue || '',
    });

    onValidationChange?.(fieldId, isValid);
  }, [validationStates, updateValidationState, validateField, onValidationChange]);

  /**
   * Undo last change for a field
   */
  const handleUndo = useCallback((fieldId: string) => {
    const state = validationStates[fieldId];
    if (!state || state.historyIndex <= 0) return;

    const newIndex = state.historyIndex - 1;
    const previousValue = state.valueHistory[newIndex];

    updateValidationState(fieldId, {
      historyIndex: newIndex,
    });

    setValues(prev => ({ ...prev, [fieldId]: previousValue }));

    // Show undo feedback
    const fieldElement = fieldRefs.current[fieldId];
    if (fieldElement) {
      applyMotionClasses(fieldElement, 'ROTATE_OUT');
      setTimeout(() => {
        removeMotionClasses(fieldElement, 'ROTATE_OUT');
        applyMotionClasses(fieldElement, 'ROTATE_IN');
        setTimeout(() => removeMotionClasses(fieldElement, 'ROTATE_IN'), 300);
      }, 150);
    }

    showGlobalMessage('info', 'Undo performed');
  }, [validationStates, updateValidationState]);

  /**
   * Redo last change for a field
   */
  const handleRedo = useCallback((fieldId: string) => {
    const state = validationStates[fieldId];
    if (!state || state.historyIndex >= state.valueHistory.length - 1) return;

    const newIndex = state.historyIndex + 1;
    const nextValue = state.valueHistory[newIndex];

    updateValidationState(fieldId, {
      historyIndex: newIndex,
    });

    setValues(prev => ({ ...prev, [fieldId]: nextValue }));

    // Show redo feedback
    const fieldElement = fieldRefs.current[fieldId];
    if (fieldElement) {
      applyMotionClasses(fieldElement, 'ROTATE_IN');
      setTimeout(() => removeMotionClasses(fieldElement, 'ROTATE_IN'), 300);
    }

    showGlobalMessage('info', 'Redo performed');
  }, [validationStates, updateValidationState]);

  /**
   * Show global message
   */
  const showGlobalMessage = useCallback((type: ValidationType, message: string) => {
    if (messageTimeout.current) {
      clearTimeout(messageTimeout.current);
    }

    setGlobalMessage({ type, message });

    messageTimeout.current = setTimeout(() => {
      setGlobalMessage(null);
    }, 3000);
  }, []);

  /**
   * Validate all fields
   */
  const validateAllFields = useCallback((): boolean => {
    let allValid = true;
    const newValidationStates = { ...validationStates };

    fields.forEach(field => {
      const value = values[field.id] || '';
      const validationResults = validateField(field.id, value);
      const isValid = validationResults.every(result => result.type !== 'error');

      newValidationStates[field.id] = {
        ...newValidationStates[field.id],
        validationResults,
        isValid,
        isTouched: true,
        lastValidValue: isValid ? value : newValidationStates[field.id]?.lastValidValue || '',
      };

      if (!isValid) {
        allValid = false;
        
        // Show error feedback
        const fieldElement = fieldRefs.current[field.id];
        if (fieldElement) {
          applyMotionClasses(fieldElement, 'ERROR_SHAKE');
          setTimeout(() => removeMotionClasses(fieldElement, 'ERROR_SHAKE'), 600);
        }
      }

      onValidationChange?.(field.id, isValid);
    });

    setValidationStates(newValidationStates);
    return allValid;
  }, [fields, values, validationStates, validateField, onValidationChange]);

  /**
   * Handle form submit
   */
  const handleSubmit = useCallback(async (e: React.FormEvent) => {
    e.preventDefault();

    // Validate all fields
    const isValid = validateAllFields();
    if (!isValid) {
      showGlobalMessage('error', 'Please fix the errors before submitting');
      return;
    }

    if (confirmOnSubmit) {
      setShowConfirmDialog(true);
    } else {
      await performSubmit();
    }
  }, [validateAllFields, confirmOnSubmit, showGlobalMessage]);

  /**
   * Perform actual submission
   */
  const performSubmit = useCallback(async () => {
    setIsSubmitting(true);

    try {
      // Show loading feedback
      showGlobalMessage('loading', 'Submitting...');

      // Call onSubmit callback
      await onSubmit?.(values);

      // Show success feedback
      showGlobalMessage('success', 'Form submitted successfully!');
      
      // Celebration animation
      const formElement = document.querySelector('form');
      if (formElement) {
        applyMotionClasses(formElement, 'CELEBRATION_CONFETTI');
        setTimeout(() => removeMotionClasses(formElement, 'CELEBRATION_CONFETTI'), 1500);
      }

      // Reset form after successful submission
      setTimeout(() => {
        setValues({});
        fields.forEach(field => {
          updateValidationState(field.id, {
            isValid: true,
            isTouched: false,
            isDirty: false,
            validationResults: [],
            characterCount: 0,
            lastValidValue: '',
            valueHistory: [''],
            historyIndex: 0,
          });
        });
      }, 2000);

    } catch (error) {
      showGlobalMessage('error', 'Submission failed. Please try again.');
      console.error('Form submission error:', error);
    } finally {
      setIsSubmitting(false);
    }
  }, [values, onSubmit, fields, updateValidationState, showGlobalMessage]);

  /**
   * Render field validation messages
   */
  const renderValidationMessages = (fieldId: string) => {
    const state = validationStates[fieldId];
    if (!state || state.validationResults.length === 0) return null;

    const highestPriorityResult = state.validationResults[0];

    return (
      <div
        className={`validation-message validation-${highestPriorityResult.type}`}
        style={{
          marginTop: '4px',
          fontSize: '12px',
          display: 'flex',
          alignItems: 'center',
          gap: '6px',
          opacity: state.isTouched ? 1 : 0,
          transform: state.isTouched ? 'translateY(0)' : 'translateY(-10px)',
          transition: 'all 300ms var(--motion-easing-standard)',
          color: `var(--color-${highestPriorityResult.type})`,
        }}
      >
        <span className="validation-icon" style={{ fontSize: '14px' }}>
          {highestPriorityResult.type === 'success' && '✓'}
          {highestPriorityResult.type === 'error' && '✗'}
          {highestPriorityResult.type === 'warning' && '⚠'}
          {highestPriorityResult.type === 'info' && 'ⓘ'}
          {highestPriorityResult.type === 'loading' && '⟳'}
        </span>
        <span className="validation-text">{highestPriorityResult.message}</span>
      </div>
    );
  };

  /**
   * Render character count
   */
  const renderCharacterCount = (field: FieldConfig) => {
    const state = validationStates[field.id];
    if (!field.showCharacterCount || !state) return null;

    const maxLength = field.maxLength || Infinity;
    const percentage = maxLength !== Infinity ? (state.characterCount / maxLength) * 100 : 0;
    const isNearLimit = percentage > 80;
    const isOverLimit = state.characterCount > maxLength;

    return (
      <div
        className="character-count"
        style={{
          marginTop: '4px',
          fontSize: '11px',
          textAlign: 'right',
          color: isOverLimit ? 'var(--color-error)' : 
                 isNearLimit ? 'var(--color-warning)' : 'var(--color-text-tertiary)',
          transition: 'color 200ms var(--motion-easing-standard)',
        }}
      >
        <span className="count">{state.characterCount}</span>
        {maxLength !== Infinity && (
          <>
            <span className="separator">/</span>
            <span className="max">{maxLength}</span>
          </>
        )}
        {isNearLimit && !isOverLimit && (
          <span className="warning" style={{ marginLeft: '4px' }}>
            {percentage >= 90 ? 'Almost full!' : 'Getting full'}
          </span>
        )}
      </div>
    );
  };

  /**
   * Render undo/redo buttons
   */
  const renderUndoRedoButtons = (fieldId: string) => {
    const field = fields.find(f => f.id === fieldId);
    const state = validationStates[field