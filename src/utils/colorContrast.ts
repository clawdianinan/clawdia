/**
 * Color Contrast Utility
 * 
 * WCAG 2.1 AA compliance verification and dynamic contrast adjustment
 * for dark mode accessibility.
 */

/**
 * RGB color interface
 */
export interface RGBColor {
  r: number;
  g: number;
  b: number;
}

/**
 * HSL color interface
 */
export interface HSLColor {
  h: number;
  s: number;
  l: number;
}

/**
 * Contrast ratio result
 */
export interface ContrastResult {
  ratio: number;
  meetsAA: boolean;
  meetsAAA: boolean;
  score: 'fail' | 'AA' | 'AAA';
  suggestions: string[];
}

/**
 * Convert hex color to RGB
 */
export function hexToRgb(hex: string): RGBColor {
  hex = hex.replace(/^#/, '');
  
  if (hex.length === 3) {
    hex = hex.split('').map(c => c + c).join('');
  }
  
  const num = parseInt(hex, 16);
  return {
    r: (num >> 16) & 255,
    g: (num >> 8) & 255,
    b: num & 255,
  };
}

/**
 * Convert RGB to hex
 */
export function rgbToHex(rgb: RGBColor): string {
  return `#${((1 << 24) + (rgb.r << 16) + (rgb.g << 8) + rgb.b).toString(16).slice(1)}`;
}

/**
 * Convert RGB to HSL
 */
export function rgbToHsl(rgb: RGBColor): HSLColor {
  const r = rgb.r / 255;
  const g = rgb.g / 255;
  const b = rgb.b / 255;
  
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  let h = 0;
  let s = 0;
  const l = (max + min) / 2;
  
  if (max !== min) {
    const d = max - min;
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
    
    switch (max) {
      case r: h = (g - b) / d + (g < b ? 6 : 0); break;
      case g: h = (b - r) / d + 2; break;
      case b: h = (r - g) / d + 4; break;
    }
    
    h /= 6;
  }
  
  return {
    h: Math.round(h * 360),
    s: Math.round(s * 100),
    l: Math.round(l * 100),
  };
}

/**
 * Convert HSL to RGB
 */
export function hslToRgb(hsl: HSLColor): RGBColor {
  const h = hsl.h / 360;
  const s = hsl.s / 100;
  const l = hsl.l / 100;
  
  let r, g, b;
  
  if (s === 0) {
    r = g = b = l;
  } else {
    const hue2rgb = (p: number, q: number, t: number) => {
      if (t < 0) t += 1;
      if (t > 1) t -= 1;
      if (t < 1/6) return p + (q - p) * 6 * t;
      if (t < 1/2) return q;
      if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
      return p;
    };
    
    const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    const p = 2 * l - q;
    
    r = hue2rgb(p, q, h + 1/3);
    g = hue2rgb(p, q, h);
    b = hue2rgb(p, q, h - 1/3);
  }
  
  return {
    r: Math.round(r * 255),
    g: Math.round(g * 255),
    b: Math.round(b * 255),
  };
}

/**
 * Calculate relative luminance (WCAG 2.0 formula)
 */
export function calculateLuminance(rgb: RGBColor): number {
  const [r, g, b] = [rgb.r, rgb.g, rgb.b].map(c => {
    c /= 255;
    return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
  });
  
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/**
 * Calculate contrast ratio between two colors
 */
export function calculateContrast(color1: RGBColor, color2: RGBColor): number {
  const l1 = calculateLuminance(color1);
  const l2 = calculateLuminance(color2);
  
  const lighter = Math.max(l1, l2);
  const darker = Math.min(l1, l2);
  
  return (lighter + 0.05) / (darker + 0.05);
}

/**
 * Check if contrast meets WCAG 2.1 standards
 */
export function checkContrast(
  foreground: string | RGBColor,
  background: string | RGBColor
): ContrastResult {
  const fgRgb = typeof foreground === 'string' ? hexToRgb(foreground) : foreground;
  const bgRgb = typeof background === 'string' ? hexToRgb(background) : background;
  
  const ratio = calculateContrast(fgRgb, bgRgb);
  const meetsAA = ratio >= 4.5;
  const meetsAAA = ratio >= 7;
  
  const suggestions: string[] = [];
  
  if (!meetsAA) {
    suggestions.push(
      'Increase contrast by adjusting colors',
      'Consider using a darker background or lighter text',
      'Add text shadow or background overlay for better readability'
    );
  } else if (!meetsAAA) {
    suggestions.push(
      'Contrast meets AA but could be improved for AAA',
      'Consider slight adjustments for better accessibility'
    );
  }
  
  return {
    ratio: Math.round(ratio * 100) / 100,
    meetsAA,
    meetsAAA,
    score: meetsAAA ? 'AAA' : meetsAA ? 'AA' : 'fail',
    suggestions,
  };
}

/**
 * Adjust color for better contrast in dark mode
 */
export function adjustForDarkMode(
  color: string | RGBColor,
  targetContrast: number = 4.5,
  background: string | RGBColor = { r: 18, g: 20, b: 26 } // Default dark background
): string {
  const colorRgb = typeof color === 'string' ? hexToRgb(color) : color;
  const bgRgb = typeof background === 'string' ? hexToRgb(background) : background;
  
  const hsl = rgbToHsl(colorRgb);
  const bgLuminance = calculateLuminance(bgRgb);
  const colorLuminance = calculateLuminance(colorRgb);
  
  // Determine if we need to lighten or darken
  const needsLightening = colorLuminance < bgLuminance;
  
  // Adjust lightness until we reach target contrast
  let adjustedHsl = { ...hsl };
  let currentRatio = calculateContrast(colorRgb, bgRgb);
  let iterations = 0;
  const maxIterations = 20;
  
  while (Math.abs(currentRatio - targetContrast) > 0.1 && iterations < maxIterations) {
    if (currentRatio < targetContrast) {
      // Increase contrast
      if (needsLightening) {
        adjustedHsl.l = Math.min(100, adjustedHsl.l + 5);
      } else {
        adjustedHsl.l = Math.max(0, adjustedHsl.l - 5);
      }
    } else {
      // We have enough contrast, but let's not overdo it
      break;
    }
    
    const adjustedRgb = hslToRgb(adjustedHsl);
    currentRatio = calculateContrast(adjustedRgb, bgRgb);
    iterations++;
  }
  
  return rgbToHex(hslToRgb(adjustedHsl));
}

/**
 * Generate accessible color palette for dark theme
 */
export function generateDarkModePalette(baseColor: string): Record<string, string> {
  const baseRgb = hexToRgb(baseColor);
  const baseHsl = rgbToHsl(baseRgb);
  
  return {
    '50': rgbToHex(hslToRgb({ ...baseHsl, l: 95, s: Math.max(20, baseHsl.s - 30) })),
    '100': rgbToHex(hslToRgb({ ...baseHsl, l: 90, s: Math.max(25, baseHsl.s - 25) })),
    '200': rgbToHex(hslToRgb({ ...baseHsl, l: 80, s: Math.max(30, baseHsl.s - 20) })),
    '300': rgbToHex(hslToRgb({ ...baseHsl, l: 70, s: Math.max(35, baseHsl.s - 15) })),
    '400': rgbToHex(hslToRgb({ ...baseHsl, l: 60, s: Math.max(40, baseHsl.s - 10) })),
    '500': rgbToHex(hslToRgb(baseHsl)),
    '600': rgbToHex(hslToRgb({ ...baseHsl, l: 40, s: Math.min(100, baseHsl.s + 10) })),
    '700': rgbToHex(hslToRgb({ ...baseHsl, l: 30, s: Math.min(100, baseHsl.s + 15) })),
    '800': rgbToHex(hslToRgb({ ...baseHsl, l: 20, s: Math.min(100, baseHsl.s + 20) })),
    '900': rgbToHex(hslToRgb({ ...baseHsl, l: 10, s: Math.min(100, baseHsl.s + 25) })),
  };
}

/**
 * Validate entire theme for WCAG compliance
 */
export function validateThemeContrast(theme: Record<string, string>): Record<string, ContrastResult> {
  const results: Record<string, ContrastResult> = {};
  const background = theme.background || '#12141a';
  
  // Check text colors against background
  const textColors = ['foreground', 'card-foreground', 'muted-foreground', 'primary-foreground'];
  
  textColors.forEach(colorKey => {
    if (theme[colorKey]) {
      results[`${colorKey}-on-background`] = checkContrast(theme[colorKey], background);
    }
  });
  
  // Check primary color against background
  if (theme.primary) {
    results['primary-on-background'] = checkContrast(theme.primary, background);
  }
  
  // Check border colors
  if (theme.border) {
    results['border-on-background'] = checkContrast(theme.border, background);
  }
  
  return results;
}

/**
 * Dynamic contrast adjustment based on ambient light
 */
export class DynamicContrastAdjuster {
  private prefersDarkScheme: boolean;
  private prefersContrast: 'no-preference' | 'more' | 'less' | 'custom';
  private currentContrastLevel: number = 1.0;
  
  constructor() {
    this.prefersDarkScheme = window.matchMedia('(prefers-color-scheme: dark)').matches;
    this.prefersContrast = this.detectContrastPreference();
    this.initialize();
  }
  
  private detectContrastPreference(): 'no-preference' | 'more' | 'less' | 'custom' {
    if (window.matchMedia('(prefers-contrast: more)').matches) return 'more';
    if (window.matchMedia('(prefers-contrast: less)').matches) return 'less';
    if (window.matchMedia('(prefers-contrast: custom)').matches) return 'custom';
    return 'no-preference';
  }
  
  private initialize(): void {
    // Listen for preference changes
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
      this.prefersDarkScheme = e.matches;
      this.adjustContrast();
    });
    
    window.matchMedia('(prefers-contrast: more)').addEventListener('change', (e) => {
      if (e.matches) this.prefersContrast = 'more';
      this.adjustContrast();
    });
    
    window.matchMedia('(prefers-contrast: less)').addEventListener('change', (e) => {
      if (e.matches) this.prefersContrast = 'less';
      this.adjustContrast();
    });
    
    // Initial adjustment
    this.adjustContrast();
  }
  
  private adjustContrast(): void {
    let targetRatio = 4.5; // WCAG AA minimum
    
    // Adjust based on preferences
    if (this.prefersContrast === 'more') {
      targetRatio = 7.0; // WCAG AAA
    } else if (this.prefersContrast === 'less') {
      targetRatio = 3.0; // Reduced contrast
    }
    
    // Further adjustment for dark mode
    if (this.prefersDarkScheme) {
      targetRatio = Math.max(targetRatio, 4.5); // Ensure minimum for dark mode
    }
    
    this.currentContrastLevel = targetRatio / 4.5;
    this.applyContrastAdjustments();
  }
  
  private applyContrastAdjustments(): void {
    const root = document.documentElement;
    
    // Adjust CSS variables based on contrast level
    if (this.currentContrastLevel > 1) {
      root.style.setProperty('--text-contrast-boost', `${this.currentContrastLevel}`);
      root.style.setProperty('--border-contrast', 'calc(var(--border) * 1.2)');
    } else if (this.currentContrastLevel < 1) {
      root.style.setProperty('--text-contrast-boost', `${this.currentContrastLevel}`);
      root.style.setProperty('--border-contrast', 'calc(var(--border) * 0.8)');
    } else {
      root.style.removeProperty('--text-contrast-boost');
      root.style.removeProperty('--border-contrast');
    }
  }
  
  public getContrastLevel(): number {
    return this.currentContrastLevel;
  }
  
  public setManualContrast(level: number): void {
    this.currentContrastLevel = Math.max(0.5, Math.min(2.0, level));
    this.applyContrastAdjustments();
  }
}

/**
 * Initialize dynamic contrast adjustment
 */
export function initializeDynamicContrast(): DynamicContrastAdjuster {
  return new DynamicContrastAdjuster();
}

// Export utility functions
export default {
  hexToRgb,
  rgbToHex,
  rgbToHsl,
  hslToRgb,
  calculateLuminance,
  calculateContrast,
  checkContrast,
  adjustForDarkMode,
  generateDarkModePalette,
  validateThemeContrast,
  initializeDynamicContrast,
};