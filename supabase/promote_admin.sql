-- Promote riff1431@gmail.com to admin role
UPDATE public.user_roles 
SET role = 'admin' 
WHERE user_id = (
  SELECT id FROM auth.users WHERE email = 'riff1431@gmail.com'
);
