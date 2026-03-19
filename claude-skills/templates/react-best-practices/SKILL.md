# React Best Practices Skill

## Purpose
Apply Vercel-optimized React/Next.js performance guidelines and best practices.

## Priority Categories

### 1. Eliminating Waterfalls (CRITICAL)
- async-defer-await: Move await into branches where actually used
- async-parallel: Use Promise.all() for independent operations
- async-dependencies: Use better-all for partial dependencies
- async-api-routes: Start promises early, await late in API routes
- async-suspense-boundaries: Use Suspense to stream content

### 2. Bundle Size Optimization (CRITICAL)
- bundle-barrel-imports: Import directly, avoid barrel files
- bundle-dynamic-imports: Use next/dynamic for heavy components
- bundle-defer-third-party: Load analytics/logging after hydration
- bundle-conditional: Load modules only when feature is activated
- bundle-preload: Preload on hover/focus for perceived speed

### 3. Server-Side Performance (HIGH)
- server-cache-react: Use React.cache() for per-request deduplication
- server-cache-lru: Use LRU cache for cross-request caching
- server-serialization: Minimize data passed to client components
- server-parallel-fetching: Restructure components to parallelize fetches
- server-after-nonblocking: Use after() for non-blocking operations

### 4. Client-Side Data Fetching (MEDIUM-HIGH)
- client-swr-dedup: Use SWR for automatic request deduplication
- client-event-listeners: Deduplicate global event listeners

### 5. Re-render Optimization (MEDIUM)
- rerender-defer-reads: Don't subscribe to state only used in callbacks
- rerender-memo: Extract expensive work into memoized components
- rerender-dependencies: Use primitive dependencies in effects
- rerender-derived-state: Subscribe to derived booleans, not raw values
- rerender-functional-setstate: Use functional setState for stable callbacks
- rerender-lazy-state-init: Pass function to useState for expensive values
- rerender-transitions: Use startTransition for non-urgent updates

## Implementation Examples

### Dynamic Imports
```typescript
// ❌ Avoid
import HeavyComponent from '@/components/HeavyComponent';

// ✅ Use
const HeavyComponent = dynamic(() => import('@/components/HeavyComponent'), {
  ssr: false,
  loading: () => <Skeleton />
});
```

### React.cache() for Data Fetching
```typescript
import { cache } from 'react';

const getData = cache(async (id: string) => {
  const res = await fetch(`/api/data/${id}`);
  return res.json();
});

// Same request in same render = cached
const data1 = await getData('123');
const data2 = await getData('123'); // Returns cached result
```

### SWR for Client Data
```typescript
import useSWR from 'swr';

function UserProfile({ userId }) {
  const { data, error, isLoading } = useSWR(
    `/api/user/${userId}`,
    (url) => fetch(url).then(res => res.json())
  );
  
  // Automatic deduplication, caching, revalidation
}
```