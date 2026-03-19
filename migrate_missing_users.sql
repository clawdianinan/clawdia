-- Migrate missing users from OLD to NEW database
-- Missing: jobs@iih.ng, sinachi@iih.ng, test@iih.ng

-- First, get the missing user records from OLD
-- Then insert into NEW auth.users
-- Need to preserve encrypted passwords and all metadata

-- Set up connections via dblink or use psql \copy

\echo 'Missing users to migrate:'
SELECT email, encrypted_password, email_confirmed_at, confirmed_at, created_at, updated_at 
FROM auth.users 
WHERE email IN ('jobs@iih.ng', 'sinachi@iih.ng', 'test@iih.ng');
