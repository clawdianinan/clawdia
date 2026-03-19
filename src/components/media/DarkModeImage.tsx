/**
 * DarkModeImage Component
 * 
 * Optimizes images for dark mode with:
 * - Automatic brightness/contrast adjustment
 * - Lazy loading with intersection observer
 * - Adaptive filtering based on theme
 * - Accessibility features
 */

import React, { useState, useEffect, useRef, useCallback } from 'react';
import { useDarkMode } from '../../hooks/useDarkMode';

/**
 * DarkModeImage component props
 */
export interface DarkModeImageProps extends React.ImgHTMLAttributes<HTMLImageElement> {
  /** Source URL for the image */
  src: string;
  /** Alternative text for accessibility */
  alt: string;
  /** Whether to apply dark mode filters (default: true) */
  applyDarkFilter?: boolean;
  /** Custom filter string for dark mode */
  darkFilter?: string;
  /** Filter intensity (0-1, default: 0.9) */
  filterIntensity?: number;
  /** Whether to lazy load the image (default: true) */
  lazyLoad?: boolean;
  /** Placeholder color while loading */
  placeholderColor?: string;
  /** Whether to show loading skeleton */
  showSkeleton?: boolean;
  /** Callback when image loads */
  onLoad?: () => void;
  /** Callback when image fails to load */
  onError?: () => void;
  /** Whether to enable hover effects (default: true) */
  enableHover?: boolean;
  /** Transition duration in milliseconds (default: 300) */
  transitionDuration?: number;
}

/**
 * DarkModeImage Component
 */
export const DarkModeImage: React.FC<DarkModeImageProps> = ({
  src,
  alt,
  applyDarkFilter = true,
  darkFilter,
  filterIntensity = 0.9,
  lazyLoad = true,
  placeholderColor = 'var(--muted)',
  showSkeleton = true,
  onLoad,
  onError,
  enableHover = true,
  transitionDuration = 300,
  className = '',
  style,
  ...props
}) => {
  const { isDarkMode } = useDarkMode();
  const [isLoaded, setIsLoaded] = useState(false);
  const [hasError, setHasError] = useState(false);
  const [isInView, setIsInView] = useState(!lazyLoad);
  const imageRef = useRef<HTMLImageElement>(null);
  const observerRef = useRef<IntersectionObserver | null>(null);

  /**
   * Calculate filter string based on dark mode and intensity
   */
  const getFilterString = useCallback(() => {
    if (!applyDarkFilter || !isDarkMode) return 'none';
    
    if (darkFilter) return darkFilter;
    
    const brightness = filterIntensity;
    const contrast = 1 + (1 - filterIntensity) * 0.2; // Slightly increase contrast as brightness decreases
    
    return `brightness(${brightness}) contrast(${contrast}) saturate(1.1)`;
  }, [applyDarkFilter, isDarkMode, darkFilter, filterIntensity]);

  /**
   * Initialize intersection observer for lazy loading
   */
  useEffect(() => {
    if (!lazyLoad || !imageRef.current) return;

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setIsInView(true);
            observer.unobserve(entry.target);
          }
        });
      },
      {
        root: null,
        rootMargin: '50px',
        threshold: 0.1,
      }
    );

    observer.observe(imageRef.current);
    observerRef.current = observer;

    return () => {
      if (observerRef.current) {
        observerRef.current.disconnect();
      }
    };
  }, [lazyLoad]);

  /**
   * Handle image load
   */
  const handleLoad = useCallback(() => {
    setIsLoaded(true);
    setHasError(false);
    onLoad?.();
  }, [onLoad]);

  /**
   * Handle image error
   */
  const handleError = useCallback(() => {
    setIsLoaded(true);
    setHasError(true);
    onError?.();
  }, [onError]);

  /**
   * Get image source based on lazy loading
   */
  const getImageSrc = () => {
    if (!isInView) return '';
    return src;
  };

  /**
   * Get container styles
   */
  const getContainerStyles = (): React.CSSProperties => ({
    position: 'relative',
    overflow: 'hidden',
    backgroundColor: placeholderColor,
    ...style,
  });

  /**
   * Get image styles
   */
  const getImageStyles = (): React.CSSProperties => ({
    width: '100%',
    height: '100%',
    objectFit: 'cover',
    filter: getFilterString(),
    transition: `filter ${transitionDuration}ms ease, opacity ${transitionDuration}ms ease`,
    opacity: isLoaded ? 1 : 0,
    cursor: enableHover ? 'pointer' : 'default',
    ...(enableHover && {
      ':hover': {
        filter: isDarkMode && applyDarkFilter 
          ? 'brightness(1) contrast(1) saturate(1)' 
          : 'brightness(1.05)',
      },
    }),
  });

  /**
   * Get skeleton styles
   */
  const getSkeletonStyles = (): React.CSSProperties => ({
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    background: `linear-gradient(90deg, ${placeholderColor} 25%, var(--muted) 50%, ${placeholderColor} 75%)`,
    backgroundSize: '200% 100%',
    animation: 'skeleton-loading 1.5s infinite',
    opacity: isLoaded ? 0 : 1,
    transition: `opacity ${transitionDuration}ms ease`,
  });

  /**
   * Get error overlay styles
   */
  const getErrorOverlayStyles = (): React.CSSProperties => ({
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'var(--destructive-subtle)',
    color: 'var(--destructive)',
    fontSize: '14px',
    fontWeight: '500',
    opacity: hasError ? 1 : 0,
    transition: `opacity ${transitionDuration}ms ease`,
  });

  return (
    <div
      className={`dark-mode-image-container ${className}`}
      style={getContainerStyles()}
      data-dark-mode={isDarkMode}
      data-loaded={isLoaded}
      data-error={hasError}
    >
      {/* Skeleton loading */}
      {showSkeleton && !isLoaded && (
        <div className="dark-mode-image-skeleton" style={getSkeletonStyles()} />
      )}

      {/* Image */}
      <img
        ref={imageRef}
        src={getImageSrc()}
        alt={alt}
        loading={lazyLoad ? 'lazy' : 'eager'}
        onLoad={handleLoad}
        onError={handleError}
        style={getImageStyles()}
        className="dark-mode-image"
        {...props}
      />

      {/* Error overlay */}
      {hasError && (
        <div className="dark-mode-image-error" style={getErrorOverlayStyles()}>
          Failed to load image
        </div>
      )}

      {/* CSS for animations */}
      <style jsx>{`
        @keyframes skeleton-loading {
          0% {
            background-position: 200% 0;
          }
          100% {
            background-position: -200% 0;
          }
        }

        .dark-mode-image:hover {
          filter: ${isDarkMode && applyDarkFilter 
            ? 'brightness(1) contrast(1) saturate(1)' 
            : 'brightness(1.05)'} !important;
        }

        @media (prefers-reduced-motion: reduce) {
          .dark-mode-image {
            transition: none !important;
          }
          
          .dark-mode-image-skeleton {
            animation: none !important;
          }
        }

        @media (prefers-contrast: high) {
          .dark-mode-image {
            filter: ${isDarkMode && applyDarkFilter 
              ? 'brightness(0.85) contrast(1.3)' 
              : 'none'} !important;
          }
        }
      `}</style>
    </div>
  );
};

/**
 * DarkModeImageGallery component for multiple images
 */
export interface DarkModeImageGalleryProps {
  images: Array<{
    src: string;
    alt: string;
    caption?: string;
  }>;
  columns?: number;
  gap?: number;
  applyDarkFilter?: boolean;
}

export const DarkModeImageGallery: React.FC<DarkModeImageGalleryProps> = ({
  images,
  columns = 3,
  gap = 16,
  applyDarkFilter = true,
}) => {
  return (
    <div
      className="dark-mode-image-gallery"
      style={{
        display: 'grid',
        gridTemplateColumns: `repeat(${columns}, 1fr)`,
        gap: `${gap}px`,
        margin: `${gap}px 0`,
      }}
    >
      {images.map((image, index) => (
        <div key={index} className="dark-mode-image-gallery-item">
          <DarkModeImage
            src={image.src}
            alt={image.alt}
            applyDarkFilter={applyDarkFilter}
            style={{ borderRadius: '8px' }}
          />
          {image.caption && (
            <div
              className="dark-mode-image-caption"
              style={{
                marginTop: '8px',
                fontSize: '14px',
                color: 'var(--muted-foreground)',
                textAlign: 'center',
              }}
            >
              {image.caption}
            </div>
          )}
        </div>
      ))}
    </div>
  );
};

/**
 * CSS styles for DarkModeImage component
 */
export const darkModeImageStyles = `
.dark-mode-image-container {
  position: relative;
  overflow: hidden;
  background-color: var(--muted);
}

.dark-mode-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: filter 300ms ease, opacity 300ms ease;
}

.dark-mode-image-skeleton {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(90deg, var(--muted) 25%, var(--muted-strong) 50%, var(--muted) 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s infinite;
}

.dark-mode-image-error {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--destructive-subtle);
  color: var(--destructive);
  font-size: 14px;
  font-weight: 500;
}

.dark-mode-image-gallery {
  display: grid;
  gap: 16px;
  margin: 16px 0;
}

.dark-mode-image-caption {
  margin-top: 8px;
  font-size: 14px;
  color: var(--muted-foreground);
  text-align: center;
}

@keyframes skeleton-loading {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: -200% 0;
  }
}

/* Reduced motion support */
@media (prefers-reduced-motion: reduce) {
  .dark-mode-image {
    transition: none !important;
  }
  
  .dark-mode-image-skeleton {
    animation: none !important;
  }
}

/* High contrast mode */
@media (prefers-contrast: high) {
  .dark-mode-image {
    border: 1px solid var(--border-strong) !important;
  }
}

/* Print styles */
@media print {
  .dark-mode-image {
    filter: none !important;
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }
  
  .dark-mode-image-skeleton,
  .dark-mode-image-error {
    display: none !important;
  }
}
`;

/**
 * Initialize DarkModeImage styles
 */
export function initializeDarkModeImageStyles(): void {
  if (typeof document === 'undefined') return;

  if (!document.querySelector('#dark-mode-image-styles')) {
    const style = document.createElement('style');
    style.id = 'dark-mode-image-styles';
    style.textContent = darkModeImageStyles;
    document.head.appendChild(style);
  }
}

export default DarkModeImage;