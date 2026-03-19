# Contributing to PRDForge

Thank you for your interest in contributing to PRDForge! This document provides guidelines and instructions for contributing to our open-source project.

## Code of Conduct

Please read our [Code of Conduct](CODE_OF_CONDUCT.md) before participating. We are committed to providing a welcoming and inclusive environment for all contributors.

## How Can I Contribute?

### Reporting Bugs
- Check if the bug has already been reported in [GitHub Issues](https://github.com/prdforge/prdforge/issues)
- Use the bug report template
- Include detailed steps to reproduce
- Provide environment information (OS, browser, version)

### Suggesting Enhancements
- Check if the feature has already been suggested
- Use the feature request template
- Explain the problem it solves
- Include mockups or examples if possible

### Contributing Code
- Fork the repository
- Create a feature branch
- Follow our coding standards
- Write tests for your changes
- Submit a pull request

### Improving Documentation
- Fix typos or unclear explanations
- Add examples or tutorials
- Translate documentation
- Improve code comments

### Answering Questions
- Help others in [GitHub Discussions](https://github.com/prdforge/discussions)
- Answer questions on Stack Overflow (tag: `prdforge`)
- Improve our FAQ or troubleshooting guides

## Development Environment Setup

### Prerequisites
- Node.js 18+ and npm 8+
- PostgreSQL 14+ or SQLite 3.35+
- Git
- Docker and Docker Compose (optional)

### Quick Start with Docker (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/prdforge/prdforge.git
   cd prdforge
   ```

2. **Copy environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Start services with Docker**
   ```bash
   docker-compose up -d
   ```

4. **Run migrations**
   ```bash
   docker-compose exec app npm run db:migrate
   ```

5. **Seed database (optional)**
   ```bash
   docker-compose exec app npm run db:seed
   ```

6. **Access the application**
   - Frontend: http://localhost:3000
   - API: http://localhost:3001
   - Adminer (database): http://localhost:8080

### Manual Setup

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Set up database**
   ```bash
   # Create database
   createdb prdforge_development

   # Run migrations
   npm run db:migrate

   # Seed data (optional)
   npm run db:seed
   ```

3. **Start development servers**
   ```bash
   # Terminal 1: Backend API
   npm run dev:api

   # Terminal 2: Frontend
   npm run dev:web

   # Terminal 3: Worker (optional, for background jobs)
   npm run dev:worker
   ```

4. **Run tests**
   ```bash
   # All tests
   npm test

   # Specific test file
   npm test -- tests/unit/auth.test.js

   # Watch mode
   npm run test:watch
   ```

### Environment Variables

Required environment variables (see `.env.example` for full list):

```bash
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/prdforge_development

# Authentication
JWT_SECRET=your-jwt-secret-here
SESSION_SECRET=your-session-secret-here

# AI Services
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# Storage
S3_BUCKET=your-bucket-name
S3_REGION=us-east-1
S3_ACCESS_KEY=your-access-key
S3_SECRET_KEY=your-secret-key
```

## Project Structure

```
prdforge/
├── apps/
│   ├── web/                 # Next.js frontend
│   │   ├── src/
│   │   │   ├── components/  # React components
│   │   │   ├── pages/       # Next.js pages
│   │   │   ├── lib/         # Frontend utilities
│   │   │   └── styles/      # CSS/SCSS files
│   │   └── public/          # Static assets
│   │
│   └── api/                 # Express.js backend
│       ├── src/
│       │   ├── controllers/ # Request handlers
│       │   ├── middleware/  # Express middleware
│       │   ├── models/      # Database models
│       │   ├── routes/      # API routes
│       │   ├── services/    # Business logic
│       │   └── utils/       # Backend utilities
│       └── prisma/          # Database schema
│
├── packages/
│   ├── shared/              # Shared code between apps
│   ├── ui/                  # Design system components
│   └── types/               # TypeScript type definitions
│
├── scripts/                 # Build/deployment scripts
├── tests/                   # Test files
├── docs/                    # Documentation
└── docker/                  # Docker configuration
```

## Code Style and Conventions

### TypeScript
- Use strict TypeScript configuration
- No `any` type unless absolutely necessary
- Use interfaces for object shapes
- Prefer `type` for unions and intersections

### JavaScript/TypeScript Conventions
```typescript
// Use const for variables that don't change
const MAX_RETRIES = 3;

// Use let for variables that change
let attemptCount = 0;

// Use descriptive variable names
const userPreferences = getUserPreferences(); // Good
const up = getUserPreferences(); // Bad

// Use async/await over callbacks
async function fetchUser(id: string): Promise<User> {
  const response = await api.get(`/users/${id}`);
  return response.data;
}

// Use destructuring
const { firstName, lastName, email } = user;

// Use template literals
const greeting = `Hello, ${firstName}!`;

// Use optional chaining and nullish coalescing
const userName = user?.profile?.name ?? 'Anonymous';
```

### React/Next.js Conventions
```tsx
// Use functional components with TypeScript
interface UserCardProps {
  user: User;
  onSelect?: (user: User) => void;
}

const UserCard: React.FC<UserCardProps> = ({ user, onSelect }) => {
  // Use hooks at the top level
  const [isSelected, setIsSelected] = useState(false);
  
  // Handle events
  const handleClick = useCallback(() => {
    setIsSelected(!isSelected);
    onSelect?.(user);
  }, [isSelected, onSelect, user]);
  
  return (
    <div 
      className={`user-card ${isSelected ? 'selected' : ''}`}
      onClick={handleClick}
      role="button"
      tabIndex={0}
    >
      <h3>{user.name}</h3>
      <p>{user.email}</p>
    </div>
  );
};

// Use memo for expensive components
export default memo(UserCard);
```

### CSS/Styling
- Use CSS Modules or styled-components
- Follow BEM naming convention for CSS classes
- Use design system tokens for colors, spacing, etc.
- Mobile-first responsive design

### Database/Prisma
```prisma
// Use singular table names
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  
  // Use camelCase for field names
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  // Define relations clearly
  projects  Project[]
  
  @@map("users") // Map to plural table name
}
```

### Git Commit Messages
Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add user profile page
fix: resolve login authentication issue
docs: update API documentation
style: format code with prettier
refactor: simplify authentication logic
test: add unit tests for user service
chore: update dependencies
```

## Testing Requirements

### Test Structure
```
tests/
├── unit/           # Unit tests
├── integration/    # Integration tests
├── e2e/           # End-to-end tests
└── fixtures/      # Test data
```

### Writing Tests

#### Unit Tests (Jest)
```typescript
import { calculateCredits } from '@/services/creditService';

describe('Credit Service', () => {
  describe('calculateCredits', () => {
    it('should calculate credits for small document', () => {
      const document = { wordCount: 500 };
      const credits = calculateCredits(document);
      expect(credits).toBe(5);
    });
    
    it('should throw error for invalid document', () => {
      expect(() => calculateCredits(null)).toThrow('Invalid document');
    });
  });
});
```

#### Integration Tests (Supertest)
```typescript
import request from 'supertest';
import app from '@/app';

describe('Projects API', () => {
  let authToken: string;
  
  beforeAll(async () => {
    // Setup test data
    const response = await request(app)
      .post('/api/auth/login')
      .send({ email: 'test@example.com', password: 'password' });
    
    authToken = response.body.token;
  });
  
  it('should create a new project', async () => {
    const response = await request(app)
      .post('/api/projects')
      .set('Authorization', `Bearer ${authToken}`)
      .send({ name: 'Test Project', description: 'Test description' });
    
    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty('id');
    expect(response.body.name).toBe('Test Project');
  });
});
```

#### E2E Tests (Playwright)
```typescript
import { test, expect } from '@playwright/test';

test('user can create and export PRD', async ({ page }) => {
  // Login
  await page.goto('/login');
  await page.fill('[data-testid="email"]', 'test@example.com');
  await page.fill('[data-testid="password"]', 'password');
  await page.click('[data-testid="login-button"]');
  
  // Create project
  await page.click('[data-testid="new-project-button"]');
  await page.fill('[data-testid="project-name"]', 'My Test PRD');
  await page.click('[data-testid="create-button"]');
  
  // Verify project created
  await expect(page.locator('[data-testid="project-title"]')).toHaveText('My Test PRD');
  
  // Export project
  await page.click('[data-testid="export-button"]');
  await page.click('[data-testid="export-pdf"]');
  
  // Wait for export and verify download
  const downloadPromise = page.waitForEvent('download');
  await page.click('[data-testid="download-button"]');
  const download = await downloadPromise;
  expect(download.suggestedFilename()).toContain('.pdf');
});
```

### Test Coverage Requirements
- Minimum 80% line coverage
- 90% for critical paths (auth, billing, exports)
- All new features must include tests
- Bug fixes must include regression tests

## Pull Request Process

### 1. Before Submitting a PR
- [ ] Run tests: `npm test`
- [ ] Check linting: `npm run lint`
- [ ] Build successfully: `npm run build`
- [ ] Update documentation if needed
- [ ] Add tests for new functionality
- [ ] Update CHANGELOG.md if applicable

### 2. Creating a Pull Request
1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature-name`
3. Make your changes
4. Commit with descriptive message
5. Push to your fork: `git push origin feat/your-feature-name`
6. Open a pull request against `main`

### 3. PR Description Template
```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update
- [ ] Other (please describe)

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] E2E tests added/updated
- [ ] Manual testing performed

## Screenshots (if applicable)

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added to complex code
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (if applicable)
- [ ] No new warnings introduced
```

### 4. Code Review Process
1. **Automated Checks** (must pass):
   - Tests pass
   - Linting passes
   - Build succeeds
   - Code coverage maintained

2. **Reviewer Feedback**:
   - At least one maintainer must approve
   - Address all review comments
   - Make requested changes
   - Request re-review when ready

3. **Merge Approval**:
   - All checks pass
   - At least one approval
   - No unresolved discussions
   - Squash commits if requested

### 5. After Merge
- Delete your feature branch
- Sync your fork with upstream
- Celebrate your contribution! 🎉

## Documentation

### Writing Documentation
- Use Markdown with consistent formatting
- Include code examples
- Add screenshots for UI changes
- Keep documentation up-to-date with code

### Documentation Structure
```
docs/
├── api/              # API documentation
├── guides/           # Tutorials and how-tos
├── development/      # Developer documentation
├── deployment/       # Deployment guides
└── images/          # Documentation images
```

### Generating API Documentation
```bash
# Generate API docs from JSDoc comments
npm run docs:api

# Serve documentation locally
npm run docs:serve
```

## Deployment

### Development Deployment
- Automatic deployment to staging on merge to `develop`
- Manual deployment to production from `main`
- Use feature flags for new functionality

### Release Process
1. **Version Bump**
   ```bash
   npm version patch  # or minor, major
   ```

2. **Create Release**
   ```bash
   git push --tags
   # Create release on GitHub
   ```

3. **Deploy to Production**
   ```bash
   npm run deploy:production
   ```

### Monitoring
- Application logs in Datadog
- Error tracking in Sentry
- Performance monitoring in New Relic
- Uptime monitoring in Pingdom

## Getting Help

### Development Questions
- Check existing documentation
- Search GitHub issues and discussions
- Ask in [GitHub Discussions](https://github.com/prdforge/discussions)
- Join our [Discord server](https://discord.gg/prdforge-dev)

### Code Review Questions
- Ask specific questions in PR comments
- Request pairing session if needed
- Reference relevant documentation

### Stuck on Something?
1. Take a break and come back fresh
2. Simplify the problem
3. Write a failing test
4. Ask for help with clear context

## Recognition

### Contributor Hall of Fame
We recognize contributors in:
- GitHub contributors list
- Release notes
- Project README
- Annual contributor awards

### First-time Contributors
Look for issues tagged `good-first-issue` or `help-wanted`. These are specifically curated for new contributors.

### Contributor Badges
Earn badges for different contribution types:
- 🐛 Bug Hunter: Fixed critical bugs
- 📚 Documentation: Improved docs
- 🎨 Design: UI/UX improvements
- 🧪 Testing: Added comprehensive tests
- 🔧 Maintenance: Code quality improvements

## License

By contributing to PRDForge, you agree that your contributions will be licensed under the [MIT License](LICENSE).

---

Thank you for contributing to PRDForge! Your efforts help make product development better for everyone.

Happy coding! 🚀