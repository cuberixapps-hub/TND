# Truth or Dare - Animation Showcase

## 🎨 Refined Animation Design

The app now features a sophisticated animation system that enhances user experience through subtle, purposeful motion design aligned with modern UI trends.

## ✨ Key Animation Features

### 1. **Entrance Animations**

- **Staggered Reveals**: Elements appear in sequence with carefully timed delays
- **Smooth Curves**: Using `easeInOutCubic` and `easeOutQuart` for natural motion
- **Subtle Scaling**: Elements grow from 0.9 to 1.0 for a gentle entrance

### 2. **Interactive Feedback**

- **AnimatedCard Widget**: Custom component with press feedback
  - Scale reduction on tap (0.98 scale)
  - Shadow depth animation
  - Smooth elevation changes
- **Button Interactions**: Responsive touch feedback with scale and color transitions

### 3. **Micro-Animations**

- **PulseAnimation**: Gentle pulsing for important elements
  - Crown emoji on winner screen
  - Challenge type buttons
  - Play button on home screen
- **ShimmerText**: Elegant text shimmer effect
  - App title on home screen
  - Winner name announcement
  - Gradient color transitions

### 4. **Loading & Transitions**

- **LoadingAnimation**: Custom spinning dots loader
- **SpinningWheel**: Smooth rotation for challenge selection
- **Page Transitions**: Custom slide and fade combinations
  - Duration: 400ms with easeInOutCubic curve
  - Simultaneous slide and fade effects

### 5. **Particle Effects**

- **FloatingParticles**: Ambient background animation
  - Organic movement patterns
  - Opacity pulsing
  - Random trajectory changes

### 6. **List Animations**

- **Staggered List Items**: Sequential appearance with delays
  - Player cards: 60ms stagger delay
  - Mode cards: 80ms stagger delay
  - Leaderboard items: 80ms stagger delay with scale variation

### 7. **Special Effects**

- **RippleAnimation**: Expanding ripple effect for emphasis
- **Shake Animation**: Subtle shake for celebration (2Hz, 2px offset)
- **Bounce Curves**: Elastic animations for playful elements

## 🎯 Animation Principles

### Timing

- **Ultra Fast**: 150ms - Micro interactions
- **Fast**: 250ms - Quick feedback
- **Normal**: 350ms - Standard transitions
- **Slow**: 500ms - Emphasis animations
- **Very Slow**: 750ms - Major transitions

### Curves

- **defaultCurve**: `Curves.easeInOutCubic` - General purpose
- **entranceCurve**: `Curves.easeOutQuart` - Smooth entrances
- **exitCurve**: `Curves.easeInQuart` - Smooth exits
- **bounceCurve**: `Curves.elasticOut` - Playful elements
- **smoothCurve**: `Curves.easeInOutSine` - Gentle transitions

## 🎮 Animation Highlights by Screen

### Home Screen

1. Logo pulse animation (2s cycle, 0.95-1.05 scale)
2. Title shimmer effect (3s duration, gradient colors)
3. Play button shimmer after 1s delay
4. Feature chips staggered entrance

### Mode Selection

1. Cards appear with staggered animation (80ms delay)
2. Scale from 0.9 to 1.0 with bounce curve
3. Interactive card press feedback
4. Smooth page transitions

### Player Setup

1. Player counter slide-in from top
2. Input field appearance with fade and slide
3. Player cards slide in from right (60ms stagger)
4. Dismissible cards with smooth removal

### Game Play

1. Challenge selection buttons with pulse effect
2. Spinning wheel animation during selection
3. Challenge card entrance with scale and shake
4. Score updates with spring animation

### Scoreboard

1. Winner crown pulse and shake animation
2. Winner name shimmer effect
3. Leaderboard items with position-based animation
4. Top 3 positions have enhanced entrance effects

## 🚀 Performance Optimizations

- **AnimationController Management**: Proper disposal to prevent memory leaks
- **Conditional Animations**: Only animate visible elements
- **Curve Optimization**: Using hardware-accelerated curves
- **Stagger Calculations**: Efficient delay computation
- **Transform Efficiency**: Using Transform widgets for GPU acceleration

## 📱 Responsive Design

All animations adapt to:

- Device performance capabilities
- Screen size and orientation
- User accessibility settings (respects reduced motion)
- Theme changes (light/dark mode)

## 🎨 Visual Harmony

The animation system creates a cohesive experience through:

- Consistent timing across all screens
- Unified easing curves for similar interactions
- Color-coordinated effects matching game modes
- Subtle motion that enhances rather than distracts

---

The refined animation system transforms the Truth or Dare app into a polished, modern experience that feels responsive, engaging, and delightful to use.
