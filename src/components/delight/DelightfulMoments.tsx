/**
 * Delightful Moments Component
 * 
 * Implements achievement unlock animations, milestone celebrations,
 * and subtle Easter eggs with brand personality.
 */

import React, { useState, useEffect, useRef, useCallback } from 'react';
import { MotionClasses, applyMotionClasses, removeMotionClasses } from '../../styles/motion-utils';

/**
 * Achievement type
 */
export type AchievementType = 'milestone' | 'streak' | 'completion' | 'discovery' | 'special';

/**
 * Achievement configuration
 */
export interface Achievement {
  id: string;
  title: string;
  description: string;
  type: AchievementType;
  icon: string;
  color: string;
  backgroundColor: string;
  unlockCondition: () => boolean;
  points?: number;
  secret?: boolean; // Hidden until unlocked
  animation?: 'confetti' | 'fireworks' | 'stars' | 'sparkle' | 'glow';
  soundEffect?: string; // URL to sound effect
}

/**
 * Milestone configuration
 */
export interface Milestone {
  id: string;
  title: string;
  description: string;
  target: number;
  current: number;
  unit?: string;
  celebrationLevel: 'subtle' | 'moderate' | 'grand';
  animation?: 'progress' | 'unlock' | 'reveal';
}

/**
 * Easter egg configuration
 */
export interface EasterEgg {
  id: string;
  name: string;
  description: string;
  trigger: 'click' | 'hover' | 'scroll' | 'sequence' | 'time';
  triggerDetails: any;
  animation: string;
  message?: string;
  secret?: boolean;
  cooldown?: number; // ms before it can trigger again
}

/**
 * DelightfulMoments props
 */
export interface DelightfulMomentsProps {
  achievements?: Achievement[];
  milestones?: Milestone[];
  easterEggs?: EasterEgg[];
  onAchievementUnlock?: (achievement: Achievement) => void;
  onMilestoneReached?: (milestone: Milestone) => void;
  onEasterEggFound?: (easterEgg: EasterEgg) => void;
  autoCheckInterval?: number; // ms between achievement checks
  showNotifications?: boolean;
  notificationDuration?: number; // ms
  className?: string;
}

/**
 * Achievement state
 */
interface AchievementState {
  unlocked: boolean;
  unlockedAt: Date | null;
  viewed: boolean;
}

/**
 * Milestone state
 */
interface MilestoneState {
  reached: boolean;
  reachedAt: Date | null;
  celebrated: boolean;
}

/**
 * Easter egg state
 */
interface EasterEggState {
  found: boolean;
  foundAt: Date | null;
  lastTriggered: Date | null;
}

/**
 * DelightfulMoments Component
 */
export const DelightfulMoments: React.FC<DelightfulMomentsProps> = ({
  achievements = [],
  milestones = [],
  easterEggs = [],
  onAchievementUnlock,
  onMilestoneReached,
  onEasterEggFound,
  autoCheckInterval = 5000,
  showNotifications = true,
  notificationDuration = 3000,
  className = '',
}) => {
  const [achievementStates, setAchievementStates] = useState<Record<string, AchievementState>>({});
  const [milestoneStates, setMilestoneStates] = useState<Record<string, MilestoneState>>({});
  const [easterEggStates, setEasterEggStates] = useState<Record<string, EasterEggState>>({});
  const [activeNotifications, setActiveNotifications] = useState<Array<{
    id: string;
    type: 'achievement' | 'milestone' | 'easterEgg';
    title: string;
    message: string;
    icon: string;
    color: string;
  }>>([]);
  const [showAchievementsPanel, setShowAchievementsPanel] = useState(false);
  
  const checkInterval = useRef<NodeJS.Timeout | null>(null);
  const notificationTimeouts = useRef<Map<string, NodeJS.Timeout>>(new Map());
  const containerRef = useRef<HTMLDivElement>(null);
  const audioContext = useRef<AudioContext | null>(null);

  /**
   * Initialize states
   */
  useEffect(() => {
    // Initialize achievement states
    const initialAchievementStates: Record<string, AchievementState> = {};
    achievements.forEach(achievement => {
      initialAchievementStates[achievement.id] = {
        unlocked: false,
        unlockedAt: null,
        viewed: false,
      };
    });
    setAchievementStates(initialAchievementStates);

    // Initialize milestone states
    const initialMilestoneStates: Record<string, MilestoneState> = {};
    milestones.forEach(milestone => {
      initialMilestoneStates[milestone.id] = {
        reached: false,
        reachedAt: null,
        celebrated: false,
      };
    });
    setMilestoneStates(initialMilestoneStates);

    // Initialize easter egg states
    const initialEasterEggStates: Record<string, EasterEggState> = {};
    easterEggs.forEach(easterEgg => {
      initialEasterEggStates[easterEgg.id] = {
        found: false,
        foundAt: null,
        lastTriggered: null,
      };
    });
    setEasterEggStates(initialEasterEggStates);

    // Initialize audio context for sound effects
    if (typeof window !== 'undefined' && window.AudioContext) {
      audioContext.current = new AudioContext();
    }

    // Set up auto-check interval
    if (autoCheckInterval > 0) {
      checkInterval.current = setInterval(checkAchievementsAndMilestones, autoCheckInterval);
    }

    // Set up easter egg triggers
    setupEasterEggTriggers();

    return () => {
      if (checkInterval.current) {
        clearInterval(checkInterval.current);
      }
      notificationTimeouts.current.forEach(timeout => clearTimeout(timeout));
      notificationTimeouts.current.clear();
    };
  }, []);

  /**
   * Check achievements and milestones
   */
  const checkAchievementsAndMilestones = useCallback(() => {
    // Check achievements
    achievements.forEach(achievement => {
      const state = achievementStates[achievement.id];
      if (!state.unlocked && achievement.unlockCondition()) {
        unlockAchievement(achievement);
      }
    });

    // Check milestones
    milestones.forEach(milestone => {
      const state = milestoneStates[milestone.id];
      if (!state.reached && milestone.current >= milestone.target) {
        reachMilestone(milestone);
      }
    });
  }, [achievements, milestones, achievementStates, milestoneStates]);

  /**
   * Unlock an achievement
   */
  const unlockAchievement = useCallback((achievement: Achievement) => {
    const now = new Date();
    
    setAchievementStates(prev => ({
      ...prev,
      [achievement.id]: {
        unlocked: true,
        unlockedAt: now,
        viewed: false,
      },
    }));

    // Show notification
    if (showNotifications) {
      showNotification({
        id: `achievement-${achievement.id}-${now.getTime()}`,
        type: 'achievement',
        title: achievement.secret ? 'Secret Achievement Unlocked!' : 'Achievement Unlocked!',
        message: achievement.title,
        icon: achievement.icon,
        color: achievement.color,
      });
    }

    // Play animation
    playAchievementAnimation(achievement);

    // Play sound effect
    if (achievement.soundEffect) {
      playSoundEffect(achievement.soundEffect);
    }

    // Call callback
    onAchievementUnlock?.(achievement);
  }, [showNotifications, onAchievementUnlock]);

  /**
   * Reach a milestone
   */
  const reachMilestone = useCallback((milestone: Milestone) => {
    const now = new Date();
    
    setMilestoneStates(prev => ({
      ...prev,
      [milestone.id]: {
        reached: true,
        reachedAt: now,
        celebrated: false,
      },
    }));

    // Show notification
    if (showNotifications) {
      showNotification({
        id: `milestone-${milestone.id}-${now.getTime()}`,
        type: 'milestone',
        title: 'Milestone Reached!',
        message: `${milestone.title}: ${milestone.current}${milestone.unit || ''}`,
        icon: '🎯',
        color: 'var(--color-success)',
      });
    }

    // Play animation based on celebration level
    playMilestoneAnimation(milestone);

    // Call callback
    onMilestoneReached?.(milestone);
  }, [showNotifications, onMilestoneReached]);

  /**
   * Find an easter egg
   */
  const findEasterEgg = useCallback((easterEgg: EasterEgg) => {
    const now = new Date();
    const state = easterEggStates[easterEgg.id];
    
    // Check cooldown
    if (state.lastTriggered && easterEgg.cooldown) {
      const timeSinceLastTrigger = now.getTime() - state.lastTriggered.getTime();
      if (timeSinceLastTrigger < easterEgg.cooldown) {
        return;
      }
    }

    setEasterEggStates(prev => ({
      ...prev,
      [easterEgg.id]: {
        found: true,
        foundAt: now,
        lastTriggered: now,
      },
    }));

    // Show notification
    if (showNotifications) {
      showNotification({
        id: `easterEgg-${easterEgg.id}-${now.getTime()}`,
        type: 'easterEgg',
        title: easterEgg.secret ? 'Secret Found!' : 'Easter Egg Discovered!',
        message: easterEgg.message || easterEgg.description,
        icon: '🥚',
        color: 'var(--color-warning)',
      });
    }

    // Play animation
    playEasterEggAnimation(easterEgg);

    // Call callback
    onEasterEggFound?.(easterEgg);
  }, [easterEggStates, showNotifications, onEasterEggFound]);

  /**
   * Show notification
   */
  const showNotification = useCallback((notification: {
    id: string;
    type: 'achievement' | 'milestone' | 'easterEgg';
    title: string;
    message: string;
    icon: string;
    color: string;
  }) => {
    setActiveNotifications(prev => [...prev, notification]);

    // Auto-remove after duration
    const timeout = setTimeout(() => {
      setActiveNotifications(prev => prev.filter(n => n.id !== notification.id));
    }, notificationDuration);

    notificationTimeouts.current.set(notification.id, timeout);
  }, [notificationDuration]);

  /**
   * Play achievement animation
   */
  const playAchievementAnimation = useCallback((achievement: Achievement) => {
    const animationType = achievement.animation || 'confetti';
    
    switch (animationType) {
      case 'confetti':
        playConfettiAnimation(achievement.color);
        break;
      case 'fireworks':
        playFireworksAnimation();
        break;
      case 'stars':
        playStarsAnimation(achievement.color);
        break;
      case 'sparkle':
        playSparkleAnimation();
        break;
      case 'glow':
        playGlowAnimation(achievement.color);
        break;
    }
  }, []);

  /**
   * Play milestone animation
   */
  const playMilestoneAnimation = useCallback((milestone: Milestone) => {
    const animationType = milestone.animation || 'unlock';
    
    switch (animationType) {
      case 'progress':
        playProgressAnimation(milestone.current / milestone.target);
        break;
      case 'unlock':
        playUnlockAnimation();
        break;
      case 'reveal':
        playRevealAnimation();
        break;
    }
  }, []);

  /**
   * Play easter egg animation
   */
  const playEasterEggAnimation = useCallback((easterEgg: EasterEgg) => {
    // Custom animation based on easter egg configuration
    const container = containerRef.current;
    if (!container) return;

    applyMotionClasses(container, 'CELEBRATION_CONFETTI');
    
    setTimeout(() => {
      if (container) {
        removeMotionClasses(container, 'CELEBRATION_CONFETTI');
      }
    }, 2000);
  }, []);

  /**
   * Play sound effect
   */
  const playSoundEffect = useCallback(async (url: string) => {
    if (!audioContext.current) return;

    try {
      const response = await fetch(url);
      const arrayBuffer = await response.arrayBuffer();
      const audioBuffer = await audioContext.current.decodeAudioData(arrayBuffer);
      
      const source = audioContext.current.createBufferSource();
      source.buffer = audioBuffer;
      source.connect(audioContext.current.destination);
      source.start();
    } catch (error) {
      console.warn('Failed to play sound effect:', error);
    }
  }, []);

  /**
   * Set up easter egg triggers
   */
  const setupEasterEggTriggers = useCallback(() => {
    easterEggs.forEach(easterEgg => {
      switch (easterEgg.trigger) {
        case 'click':
          if (easterEgg.triggerDetails.selector) {
            const elements = document.querySelectorAll(easterEgg.triggerDetails.selector);
            elements.forEach(element => {
              element.addEventListener('click', () => findEasterEgg(easterEgg));
            });
          }
          break;
          
        case 'hover':
          if (easterEgg.triggerDetails.selector) {
            const elements = document.querySelectorAll(easterEgg.triggerDetails.selector);
            elements.forEach(element => {
              element.addEventListener('mouseenter', () => findEasterEgg(easterEgg));
            });
          }
          break;
          
        case 'scroll':
          window.addEventListener('scroll', () => {
            const scrollPosition = window.scrollY + window.innerHeight;
            const triggerPosition = easterEgg.triggerDetails.position || document.body.scrollHeight * 0.8;
            
            if (scrollPosition >= triggerPosition) {
              findEasterEgg(easterEgg);
              // Remove listener after triggering
              window.removeEventListener('scroll', () => {});
            }
          });
          break;
          
        case 'sequence':
          // Keyboard sequence
          let sequence = '';
          window.addEventListener('keydown', (e) => {
            sequence += e.key.toLowerCase();
            
            if (sequence.length > easterEgg.triggerDetails.sequence.length) {
              sequence = sequence.slice(-easterEgg.triggerDetails.sequence.length);
            }
            
            if (sequence === easterEgg.triggerDetails.sequence.toLowerCase()) {
              findEasterEgg(easterEgg);
              sequence = '';
            }
          });
          break;
          
        case 'time':
          setTimeout(() => {
            findEasterEgg(easterEgg);
          }, easterEgg.triggerDetails.delay || 30000);
          break;
      }
    });
  }, [easterEggs, findEasterEgg]);

  /**
   * Animation functions
   */
  const playConfettiAnimation = useCallback((color: string) => {
    const container = containerRef.current;
    if (!container) return;

    // Create confetti elements
    for (let i = 0; i < 50; i++) {
      const confetti = document.createElement('div');
      confetti.className = 'confetti';
      confetti.style.cssText = `
        position: fixed;
        width: 10px;
        height: 10px;
        background-color: ${color};
        border-radius: 2px;
        z-index: 9999;
        pointer-events: none;
        top: -20px;
        left: ${Math.random() * 100}vw;
        animation: confetti-fall ${1 + Math.random() * 2}s ease-in forwards;
        transform: rotate(${Math.random() * 360}deg);
      `;
      
      container.appendChild(confetti);
      
      // Remove after animation
      setTimeout(() => {
        confetti.remove();
      }, 3000);
    }
  }, []);

  const playFireworksAnimation = useCallback(() => {
    const container = containerRef.current;
    if (!container) return;

    for (let i = 0; i < 5; i++) {
      const firework = document.createElement('div');
      firework.className = 'firework';
      firework.style.cssText = `
        position: fixed;
        width: 4px;
        height: 4px;
        background-color: #ff6b6b;
        border-radius: 50%;
        z-index: 9999;
        pointer-events: none;
        top: 80vh;
        left: ${20 + i * 15}vw;
        animation: firework-explode 1.5s ease-out forwards;
      `;
      
      container.appendChild(firework);
      
      setTimeout(() => {
        firework.remove();
      }, 1500);
    }
  }, []);

  const playStarsAnimation = useCallback((color: string) => {
    const container = containerRef.current;
    if (!container) return;

    for (let i = 0; i < 30; i++) {
      const star = document.createElement('div');
      star.className = 'star';
      star.style.cssText = `
        position: fixed;
        width: ${4 + Math.random() * 8}px;
        height: ${4 + Math.random() * 8}px;
        background-color: ${color};
        clip-path: polygon(50% 0%, 61% 35%, 98% 35%, 68% 57%, 79% 91%, 50% 70%, 21% 91%, 32% 57%, 2% 35%, 39% 35%);
        z-index: 9999;
        pointer-events: none;
        top: ${Math.random() * 100}vh;
        left: ${Math.random() * 100}vw;
        opacity: 0;
        animation: star-twinkle ${1 + Math.random() * 2}s ease-in-out ${Math.random() * 0.5}s infinite;
      `;
      
      container.appendChild(star);
      
      setTimeout(() => {
        star.remove();
      }, 3000);
    }
  }, []);

  const playSparkleAnimation = useCallback(() => {
    const container = containerRef.current;
    if (!container) return;

    for (let i = 0; i < 20; i++) {
      const sparkle = document.createElement('