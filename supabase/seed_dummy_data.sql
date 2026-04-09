-- ============================================
-- SEED: Dummy Data for The Cleaning Network
-- Run this in the Supabase SQL Editor (as admin, bypasses RLS)
-- ============================================

-- =============================================
-- 1. Create dummy auth users (providers/cleaners)
-- =============================================
-- We use deterministic UUIDs so references work cleanly.
-- Password for all dummy accounts: "DummyPass123!"

INSERT INTO auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token
) VALUES
  -- Cleaner 1: SparklePro Cleaning
  ('a1000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   'sparklepro@demo.cleaningnetwork.ca', crypt('DummyPass123!', gen_salt('bf')),
   now(), '{"full_name":"Sarah Johnson","account_type":"cleaner"}'::jsonb, now(), now(), '', ''),

  -- Cleaner 2: CleanSweep Masters
  ('a1000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   'cleansweep@demo.cleaningnetwork.ca', crypt('DummyPass123!', gen_salt('bf')),
   now(), '{"full_name":"Michael Chen","account_type":"cleaner"}'::jsonb, now(), now(), '', ''),

  -- Cleaner 3: Eco Clean Solutions
  ('a1000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   'ecoclean@demo.cleaningnetwork.ca', crypt('DummyPass123!', gen_salt('bf')),
   now(), '{"full_name":"Emma Davis","account_type":"cleaner"}'::jsonb, now(), now(), '', ''),

  -- Cleaner 4: Pristine Home Services
  ('a1000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   'pristinehome@demo.cleaningnetwork.ca', crypt('DummyPass123!', gen_salt('bf')),
   now(), '{"full_name":"James Wilson","account_type":"cleaner"}'::jsonb, now(), now(), '', ''),

  -- Cleaner 5: Maid Masters
  ('a1000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   'maidmasters@demo.cleaningnetwork.ca', crypt('DummyPass123!', gen_salt('bf')),
   now(), '{"full_name":"Sophia Martinez","account_type":"cleaner"}'::jsonb, now(), now(), '', ''),

  -- Cleaner 6: Crystal Clear Co.
  ('a1000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   'crystalclear@demo.cleaningnetwork.ca', crypt('DummyPass123!', gen_salt('bf')),
   now(), '{"full_name":"David Brown","account_type":"cleaner"}'::jsonb, now(), now(), '', ''),

  -- Cleaner 7: Green Gleam Services
  ('a1000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   'greengleam@demo.cleaningnetwork.ca', crypt('DummyPass123!', gen_salt('bf')),
   now(), '{"full_name":"Olivia Taylor","account_type":"cleaner"}'::jsonb, now(), now(), '', ''),

  -- Cleaner 8: A+ Janitorial
  ('a1000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   'aplusjanitorial@demo.cleaningnetwork.ca', crypt('DummyPass123!', gen_salt('bf')),
   now(), '{"full_name":"Robert Anderson","account_type":"cleaner"}'::jsonb, now(), now(), '', ''),

  -- Cleaner 9: FreshStart Cleaning
  ('a1000000-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   'freshstart@demo.cleaningnetwork.ca', crypt('DummyPass123!', gen_salt('bf')),
   now(), '{"full_name":"Emily White","account_type":"cleaner"}'::jsonb, now(), now(), '', ''),

  -- Cleaner 10: Pro Shine Team
  ('a1000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   'proshine@demo.cleaningnetwork.ca', crypt('DummyPass123!', gen_salt('bf')),
   now(), '{"full_name":"Daniel Lee","account_type":"cleaner"}'::jsonb, now(), now(), '', ''),

  -- Cleaner 11: TidyUp Experts
  ('a1000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   'tidyupexperts@demo.cleaningnetwork.ca', crypt('DummyPass123!', gen_salt('bf')),
   now(), '{"full_name":"Rachel Kim","account_type":"cleaner"}'::jsonb, now(), now(), '', ''),

  -- Cleaner 12: Diamond Dust Cleaning
  ('a1000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   'diamonddust@demo.cleaningnetwork.ca', crypt('DummyPass123!', gen_salt('bf')),
   now(), '{"full_name":"Chris Patel","account_type":"cleaner"}'::jsonb, now(), now(), '', ''),

  -- Dummy customers for reviews
  ('c1000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   'customer1@demo.cleaningnetwork.ca', crypt('DummyPass123!', gen_salt('bf')),
   now(), '{"full_name":"Alice Thompson","account_type":"customer"}'::jsonb, now(), now(), '', ''),

  ('c1000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   'customer2@demo.cleaningnetwork.ca', crypt('DummyPass123!', gen_salt('bf')),
   now(), '{"full_name":"Bob Harris","account_type":"customer"}'::jsonb, now(), now(), '', ''),

  ('c1000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   'customer3@demo.cleaningnetwork.ca', crypt('DummyPass123!', gen_salt('bf')),
   now(), '{"full_name":"Carol Nguyen","account_type":"customer"}'::jsonb, now(), now(), '', ''),

  ('c1000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   'customer4@demo.cleaningnetwork.ca', crypt('DummyPass123!', gen_salt('bf')),
   now(), '{"full_name":"David Murphy","account_type":"customer"}'::jsonb, now(), now(), '', ''),

  ('c1000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   'customer5@demo.cleaningnetwork.ca', crypt('DummyPass123!', gen_salt('bf')),
   now(), '{"full_name":"Elena Rodriguez","account_type":"customer"}'::jsonb, now(), now(), '', '')

ON CONFLICT (id) DO NOTHING;

-- Also need identities for the auth users
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
SELECT
  id, id,
  jsonb_build_object('sub', id::text, 'email', email),
  'email', id::text, now(), now(), now()
FROM auth.users
WHERE id IN (
  'a1000000-0000-0000-0000-000000000001',
  'a1000000-0000-0000-0000-000000000002',
  'a1000000-0000-0000-0000-000000000003',
  'a1000000-0000-0000-0000-000000000004',
  'a1000000-0000-0000-0000-000000000005',
  'a1000000-0000-0000-0000-000000000006',
  'a1000000-0000-0000-0000-000000000007',
  'a1000000-0000-0000-0000-000000000008',
  'a1000000-0000-0000-0000-000000000009',
  'a1000000-0000-0000-0000-000000000010',
  'a1000000-0000-0000-0000-000000000011',
  'a1000000-0000-0000-0000-000000000012',
  'c1000000-0000-0000-0000-000000000001',
  'c1000000-0000-0000-0000-000000000002',
  'c1000000-0000-0000-0000-000000000003',
  'c1000000-0000-0000-0000-000000000004',
  'c1000000-0000-0000-0000-000000000005'
)
ON CONFLICT DO NOTHING;

-- =============================================
-- 2. Create profiles (the handle_new_user trigger may already fire,
--    but we insert with ON CONFLICT to be safe)
-- =============================================
INSERT INTO public.profiles (id, email, full_name, avatar_url) VALUES
  ('a1000000-0000-0000-0000-000000000001', 'sparklepro@demo.cleaningnetwork.ca', 'Sarah Johnson', 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=200&h=200&fit=crop&crop=face'),
  ('a1000000-0000-0000-0000-000000000002', 'cleansweep@demo.cleaningnetwork.ca', 'Michael Chen', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face'),
  ('a1000000-0000-0000-0000-000000000003', 'ecoclean@demo.cleaningnetwork.ca', 'Emma Davis', 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=200&h=200&fit=crop&crop=face'),
  ('a1000000-0000-0000-0000-000000000004', 'pristinehome@demo.cleaningnetwork.ca', 'James Wilson', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop&crop=face'),
  ('a1000000-0000-0000-0000-000000000005', 'maidmasters@demo.cleaningnetwork.ca', 'Sophia Martinez', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&h=200&fit=crop&crop=face'),
  ('a1000000-0000-0000-0000-000000000006', 'crystalclear@demo.cleaningnetwork.ca', 'David Brown', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face'),
  ('a1000000-0000-0000-0000-000000000007', 'greengleam@demo.cleaningnetwork.ca', 'Olivia Taylor', 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop&crop=face'),
  ('a1000000-0000-0000-0000-000000000008', 'aplusjanitorial@demo.cleaningnetwork.ca', 'Robert Anderson', 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=200&h=200&fit=crop&crop=face'),
  ('a1000000-0000-0000-0000-000000000009', 'freshstart@demo.cleaningnetwork.ca', 'Emily White', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&h=200&fit=crop&crop=face'),
  ('a1000000-0000-0000-0000-000000000010', 'proshine@demo.cleaningnetwork.ca', 'Daniel Lee', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&h=200&fit=crop&crop=face'),
  ('a1000000-0000-0000-0000-000000000011', 'tidyupexperts@demo.cleaningnetwork.ca', 'Rachel Kim', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop&crop=face'),
  ('a1000000-0000-0000-0000-000000000012', 'diamonddust@demo.cleaningnetwork.ca', 'Chris Patel', 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=200&h=200&fit=crop&crop=face'),
  -- Customers
  ('c1000000-0000-0000-0000-000000000001', 'customer1@demo.cleaningnetwork.ca', 'Alice Thompson', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop&crop=face'),
  ('c1000000-0000-0000-0000-000000000002', 'customer2@demo.cleaningnetwork.ca', 'Bob Harris', 'https://images.unsplash.com/photo-1599566150163-29194dcabd9c?w=200&h=200&fit=crop&crop=face'),
  ('c1000000-0000-0000-0000-000000000003', 'customer3@demo.cleaningnetwork.ca', 'Carol Nguyen', 'https://images.unsplash.com/photo-1607746882042-944635dfe10e?w=200&h=200&fit=crop&crop=face'),
  ('c1000000-0000-0000-0000-000000000004', 'customer4@demo.cleaningnetwork.ca', 'David Murphy', 'https://images.unsplash.com/photo-1633332755192-727a05c4013d?w=200&h=200&fit=crop&crop=face'),
  ('c1000000-0000-0000-0000-000000000005', 'customer5@demo.cleaningnetwork.ca', 'Elena Rodriguez', 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=200&h=200&fit=crop&crop=face')
ON CONFLICT (id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  avatar_url = EXCLUDED.avatar_url;

-- =============================================
-- 3. Assign user roles
-- =============================================
INSERT INTO public.user_roles (user_id, role) VALUES
  ('a1000000-0000-0000-0000-000000000001', 'cleaner'),
  ('a1000000-0000-0000-0000-000000000002', 'cleaner'),
  ('a1000000-0000-0000-0000-000000000003', 'cleaner'),
  ('a1000000-0000-0000-0000-000000000004', 'cleaner'),
  ('a1000000-0000-0000-0000-000000000005', 'cleaner'),
  ('a1000000-0000-0000-0000-000000000006', 'cleaner'),
  ('a1000000-0000-0000-0000-000000000007', 'cleaner'),
  ('a1000000-0000-0000-0000-000000000008', 'cleaner'),
  ('a1000000-0000-0000-0000-000000000009', 'cleaner'),
  ('a1000000-0000-0000-0000-000000000010', 'cleaner'),
  ('a1000000-0000-0000-0000-000000000011', 'cleaner'),
  ('a1000000-0000-0000-0000-000000000012', 'cleaner'),
  ('c1000000-0000-0000-0000-000000000001', 'customer'),
  ('c1000000-0000-0000-0000-000000000002', 'customer'),
  ('c1000000-0000-0000-0000-000000000003', 'customer'),
  ('c1000000-0000-0000-0000-000000000004', 'customer'),
  ('c1000000-0000-0000-0000-000000000005', 'customer')
ON CONFLICT (user_id, role) DO NOTHING;

-- =============================================
-- 4. Create cleaner profiles with stock images
-- =============================================
INSERT INTO public.cleaner_profiles (
  id, user_id, business_name, bio, hourly_rate, services, service_areas,
  years_experience, profile_image, gallery_images,
  is_verified, instant_booking, is_active, response_time
) VALUES
  -- 1. SparklePro Cleaning — Toronto, Home + Deep + Airbnb
  ('b1000000-0000-0000-0000-000000000001',
   'a1000000-0000-0000-0000-000000000001',
   'SparklePro Cleaning',
   'Award-winning residential cleaning service with 8+ years of experience. We specialize in making your home sparkle using premium eco-friendly products. Our team of trained professionals ensures every corner of your space is meticulously cleaned.',
   85, ARRAY['Home Cleaning','Deep Cleaning','Airbnb Turnover','Move In/Out'],
   ARRAY['Toronto','North York','Scarborough','Etobicoke'],
   8,
   'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600&h=400&fit=crop',
   ARRAY['https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=600&h=400&fit=crop','https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=600&h=400&fit=crop','https://images.unsplash.com/photo-1527515545081-5db817172677?w=600&h=400&fit=crop'],
   true, true, true, 'Responds in ~30 min'),

  -- 2. CleanSweep Masters — Vancouver, Office + Commercial
  ('b1000000-0000-0000-0000-000000000002',
   'a1000000-0000-0000-0000-000000000002',
   'CleanSweep Masters',
   'Vancouver''s premier commercial and office cleaning company. We handle everything from small office suites to large corporate spaces. Licensed, bonded, and insured with a 100% satisfaction guarantee.',
   120, ARRAY['Office Cleaning','Post Construction','Deep Cleaning'],
   ARRAY['Vancouver','Burnaby','Richmond','Surrey'],
   12,
   'https://images.unsplash.com/photo-1521791136064-7986c2920216?w=600&h=400&fit=crop',
   ARRAY['https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&h=400&fit=crop','https://images.unsplash.com/photo-1497215842964-222b430dc094?w=600&h=400&fit=crop'],
   true, false, true, 'Responds in ~1 hour'),

  -- 3. Eco Clean Solutions — Calgary, Eco-Friendly
  ('b1000000-0000-0000-0000-000000000003',
   'a1000000-0000-0000-0000-000000000003',
   'Eco Clean Solutions',
   'Certified green cleaning service using 100% plant-based, non-toxic products. Perfect for families with children and pets. We believe clean shouldn''t mean chemical. Every product we use is biodegradable and cruelty-free.',
   95, ARRAY['Eco-Friendly','Home Cleaning','Move In/Out','Deep Cleaning'],
   ARRAY['Calgary','Airdrie','Cochrane','Okotoks'],
   6,
   'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&h=400&fit=crop',
   ARRAY['https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=600&h=400&fit=crop','https://images.unsplash.com/photo-1563453392212-326f5e854473?w=600&h=400&fit=crop'],
   true, true, true, 'Responds in ~30 min'),

  -- 4. Pristine Home Services — Ottawa, Home + Carpet
  ('b1000000-0000-0000-0000-000000000004',
   'a1000000-0000-0000-0000-000000000004',
   'Pristine Home Services',
   'Family-owned cleaning business serving the Ottawa region since 2018. We take pride in transforming homes with our attention to detail. Specialized in carpet deep cleaning and restoration with industrial-grade equipment.',
   70, ARRAY['Home Cleaning','Carpet Cleaning','Deep Cleaning'],
   ARRAY['Ottawa','Gatineau','Kanata','Orleans'],
   7,
   'https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?w=600&h=400&fit=crop',
   ARRAY['https://images.unsplash.com/photo-1558317374-067fb5f30001?w=600&h=400&fit=crop','https://images.unsplash.com/photo-1556909212-d5b604d0c90d?w=600&h=400&fit=crop'],
   true, true, true, 'Responds in ~1 hour'),

  -- 5. Maid Masters — Montreal, Home + Regular
  ('b1000000-0000-0000-0000-000000000005',
   'a1000000-0000-0000-0000-000000000005',
   'Maid Masters',
   'Montréal''s trusted maid service with bilingual staff (English & French). We offer flexible scheduling and competitive rates for regular cleaning. Our trained maids follow a 50-point cleaning checklist to ensure nothing is missed.',
   75, ARRAY['Home Cleaning','Deep Cleaning','Airbnb Turnover'],
   ARRAY['Montreal','Laval','Longueuil','Brossard'],
   10,
   'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=600&h=400&fit=crop',
   ARRAY['https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600&h=400&fit=crop','https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&h=400&fit=crop'],
   true, false, true, 'Responds in ~2 hours'),

  -- 6. Crystal Clear Co. — Edmonton, Window + Office
  ('b1000000-0000-0000-0000-000000000006',
   'a1000000-0000-0000-0000-000000000006',
   'Crystal Clear Co.',
   'Specialized in window cleaning, glass restoration, and office maintenance. We use advanced pure-water cleaning technology for streak-free results every time. Commercial and residential services available.',
   90, ARRAY['Office Cleaning','Deep Cleaning','Post Construction'],
   ARRAY['Edmonton','St. Albert','Sherwood Park','Spruce Grove'],
   5,
   'https://images.unsplash.com/photo-1527515637462-cee1cef4c8e4?w=600&h=400&fit=crop',
   ARRAY['https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=600&h=400&fit=crop'],
   false, true, true, 'Responds in ~1 hour'),

  -- 7. Green Gleam Services — Winnipeg, Eco + Home
  ('b1000000-0000-0000-0000-000000000007',
   'a1000000-0000-0000-0000-000000000007',
   'Green Gleam Services',
   'Passionate about clean living and sustainability. Green Gleam brings together eco-friendly products and professional-grade cleaning techniques. We''re Winnipeg''s first carbon-neutral cleaning service.',
   80, ARRAY['Eco-Friendly','Home Cleaning','Carpet Cleaning','Move In/Out'],
   ARRAY['Winnipeg','Brandon','Steinbach'],
   4,
   'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&h=400&fit=crop',
   ARRAY['https://images.unsplash.com/photo-1600607687644-aac4c3eac7f4?w=600&h=400&fit=crop','https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?w=600&h=400&fit=crop'],
   true, true, true, 'Responds in ~45 min'),

  -- 8. A+ Janitorial — Mississauga, Commercial + Office
  ('b1000000-0000-0000-0000-000000000008',
   'a1000000-0000-0000-0000-000000000008',
   'A+ Janitorial Services',
   'Professional janitorial and commercial cleaning for offices, warehouses, retail spaces, and medical facilities. Fully insured with background-checked staff. Serving the GTA with pride since 2015.',
   110, ARRAY['Office Cleaning','Post Construction','Deep Cleaning'],
   ARRAY['Mississauga','Brampton','Oakville','Hamilton'],
   10,
   'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=600&h=400&fit=crop',
   ARRAY['https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&h=400&fit=crop','https://images.unsplash.com/photo-1497215842964-222b430dc094?w=600&h=400&fit=crop'],
   true, false, true, 'Responds in ~2 hours'),

  -- 9. FreshStart Cleaning — Halifax, Move In/Out
  ('b1000000-0000-0000-0000-000000000009',
   'a1000000-0000-0000-0000-000000000009',
   'FreshStart Cleaning Co.',
   'Specializing in move-in/move-out cleaning and Airbnb turnovers. We make sure your new space feels fresh and inviting. Based in Halifax, serving all of HRM with reliable and affordable services.',
   65, ARRAY['Move In/Out','Airbnb Turnover','Home Cleaning','Deep Cleaning'],
   ARRAY['Halifax','Dartmouth','Bedford','Sackville'],
   3,
   'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&h=400&fit=crop',
   ARRAY['https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=600&h=400&fit=crop','https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=600&h=400&fit=crop'],
   false, true, true, 'Responds in ~1 hour'),

  -- 10. Pro Shine Team — Victoria, Home + Deep
  ('b1000000-0000-0000-0000-000000000010',
   'a1000000-0000-0000-0000-000000000010',
   'Pro Shine Team',
   'Detail-oriented cleaning professionals delivering premium residential cleaning across Greater Victoria. We treat every home like our own. Our team uses hospital-grade disinfectants and state-of-the-art equipment.',
   100, ARRAY['Home Cleaning','Deep Cleaning','Carpet Cleaning'],
   ARRAY['Victoria','Saanich','Langford','Sidney'],
   9,
   'https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=600&h=400&fit=crop',
   ARRAY['https://images.unsplash.com/photo-1527515637462-cee1cef4c8e4?w=600&h=400&fit=crop'],
   true, true, true, 'Responds in ~30 min'),

  -- 11. TidyUp Experts — Markham, All-Around
  ('b1000000-0000-0000-0000-000000000011',
   'a1000000-0000-0000-0000-000000000011',
   'TidyUp Experts',
   'Versatile cleaning service offering everything from basic tidying to intensive deep cleans. We pride ourselves on punctuality and flexibility. Available 7 days a week with same-day booking options.',
   78, ARRAY['Home Cleaning','Office Cleaning','Deep Cleaning','Eco-Friendly'],
   ARRAY['Markham','Vaughan','Richmond Hill','Aurora'],
   5,
   'https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=600&h=400&fit=crop',
   ARRAY['https://images.unsplash.com/photo-1563453392212-326f5e854473?w=600&h=400&fit=crop','https://images.unsplash.com/photo-1558317374-067fb5f30001?w=600&h=400&fit=crop'],
   true, true, true, 'Responds in ~45 min'),

  -- 12. Diamond Dust Cleaning — London ON, Post-Construction
  ('b1000000-0000-0000-0000-000000000012',
   'a1000000-0000-0000-0000-000000000012',
   'Diamond Dust Cleaning',
   'Heavy-duty cleaning specialists. We handle the toughest post-construction cleanups, warehouse revamps, and industrial space turnovers. No job is too big. Equipped with commercial-grade machinery and a crew that delivers.',
   130, ARRAY['Post Construction','Deep Cleaning','Office Cleaning','Move In/Out'],
   ARRAY['London','Kitchener','Waterloo','Guelph'],
   11,
   'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&h=400&fit=crop',
   ARRAY['https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&h=400&fit=crop'],
   true, false, true, 'Responds in ~1 hour')

ON CONFLICT (user_id) DO UPDATE SET
  business_name = EXCLUDED.business_name,
  bio = EXCLUDED.bio,
  hourly_rate = EXCLUDED.hourly_rate,
  services = EXCLUDED.services,
  service_areas = EXCLUDED.service_areas,
  years_experience = EXCLUDED.years_experience,
  profile_image = EXCLUDED.profile_image,
  gallery_images = EXCLUDED.gallery_images,
  is_verified = EXCLUDED.is_verified,
  instant_booking = EXCLUDED.instant_booking,
  response_time = EXCLUDED.response_time;


-- =============================================
-- 5. Create service listings (Fiverr-style gigs)
-- =============================================
INSERT INTO public.service_listings (
  id, user_id, cleaner_profile_id, title, description, category,
  price_type, price, duration_hours, image_url, gallery_images,
  features, is_active, location, service_area, delivery_time, views_count, orders_count
) VALUES
  -- SparklePro Cleaning listings
  ('d1000000-0000-0000-0000-000000000001',
   'a1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000001',
   'Complete Home Deep Clean — Top to Bottom',
   'A thorough, meticulous deep clean of your entire home. We cover baseboards, behind appliances, inside cabinets, window sills, light fixtures, and every surface. Perfect for seasonal refreshes or pre-event preparation.',
   'Deep Cleaning', 'fixed', 189, 4,
   'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600&h=400&fit=crop',
   ARRAY['https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=600&h=400&fit=crop'],
   ARRAY['All rooms included','Behind appliances','Inside cabinets','Window sills','Baseboards','Light fixtures'],
   true, 'Toronto, ON', ARRAY['Toronto','North York'], 'Same day', 342, 47),

  ('d1000000-0000-0000-0000-000000000002',
   'a1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000001',
   'Airbnb Quick Turnover Service',
   'Fast, efficient Airbnb turnover cleaning designed for hosts. We strip beds, do laundry, restock supplies, and leave your property guest-ready. Available 7 days a week with same-day booking.',
   'Home Cleaning', 'starting_at', 95, 2,
   'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&h=400&fit=crop',
   ARRAY['https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=600&h=400&fit=crop'],
   ARRAY['Linen change','Laundry service','Supply restock','Guest-ready checklist','Same day availability'],
   true, 'Toronto, ON', ARRAY['Toronto','North York','Scarborough'], 'Same day', 218, 82),

  -- CleanSweep Masters listings
  ('d1000000-0000-0000-0000-000000000003',
   'a1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000002',
   'Full Office Cleaning & Sanitization',
   'Comprehensive office cleaning service including desk sanitization, floor care, kitchen/breakroom cleaning, restroom deep clean, and lobby maintenance. We work after hours to minimize disruption.',
   'Office Cleaning', 'hourly', 65, 3,
   'https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&h=400&fit=crop',
   ARRAY['https://images.unsplash.com/photo-1497215842964-222b430dc094?w=600&h=400&fit=crop'],
   ARRAY['After-hours scheduling','Desk sanitization','Floor care','Kitchen & breakroom','Restroom deep clean','Trash & recycling'],
   true, 'Vancouver, BC', ARRAY['Vancouver','Burnaby','Richmond'], '24 hours', 187, 31),

  ('d1000000-0000-0000-0000-000000000004',
   'a1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000002',
   'Post-Construction Cleanup — Commercial Grade',
   'Heavy-duty cleanup after construction or renovation work. We remove dust, debris, paint residue, and adhesive. Industrial vacuum and pressure washing included. Perfect for new builds and renovations.',
   'Post-Construction', 'starting_at', 250, 6,
   'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=600&h=400&fit=crop',
   ARRAY[]::TEXT[],
   ARRAY['Debris removal','Dust extraction','Paint cleanup','Pressure washing','Floor polishing','Window cleaning'],
   true, 'Vancouver, BC', ARRAY['Vancouver','Burnaby','Surrey'], '48 hours', 94, 12),

  -- Eco Clean Solutions listings
  ('d1000000-0000-0000-0000-000000000005',
   'a1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000003',
   '100% Green Home Cleaning Package',
   'Our signature eco-friendly home cleaning uses only plant-based, non-toxic, biodegradable products. Safe for kids, pets, and the planet. Certified green products with aromatherapy-grade essential oils.',
   'Eco-Friendly Cleaning', 'fixed', 115, 3,
   'https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=600&h=400&fit=crop',
   ARRAY['https://images.unsplash.com/photo-1563453392212-326f5e854473?w=600&h=400&fit=crop'],
   ARRAY['100% plant-based products','Pet & child safe','Aromatherapy oils','Biodegradable','No harsh chemicals','Carbon-neutral'],
   true, 'Calgary, AB', ARRAY['Calgary','Airdrie','Cochrane'], 'Same day', 276, 58),

  ('d1000000-0000-0000-0000-000000000006',
   'a1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000003',
   'Eco Move-In/Move-Out Deep Clean',
   'Moving? Let us handle the cleaning. We deep clean the entire property using green products. Ideal for getting your damage deposit back or preparing a new space for move-in.',
   'Move-in/Move-out', 'fixed', 175, 5,
   'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=600&h=400&fit=crop',
   ARRAY[]::TEXT[],
   ARRAY['Full property coverage','Inside all cupboards','Oven & fridge','Bathroom descale','Floor scrub','Green products only'],
   true, 'Calgary, AB', ARRAY['Calgary','Okotoks'], '24 hours', 145, 22),

  -- Pristine Home Services listings
  ('d1000000-0000-0000-0000-000000000007',
   'a1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000004',
   'Professional Carpet Deep Cleaning',
   'Hot water extraction carpet cleaning using professional truck-mounted equipment. Removes deep-seated dirt, allergens, stains, and odors. We pre-treat high-traffic areas and apply protective coating.',
   'Carpet Cleaning', 'starting_at', 149, 3,
   'https://images.unsplash.com/photo-1558317374-067fb5f30001?w=600&h=400&fit=crop',
   ARRAY['https://images.unsplash.com/photo-1556909212-d5b604d0c90d?w=600&h=400&fit=crop'],
   ARRAY['Truck-mounted equipment','Stain pre-treatment','Allergen removal','Deodorizing','Protective coating','Fast drying'],
   true, 'Ottawa, ON', ARRAY['Ottawa','Kanata','Orleans'], 'Same day', 198, 35),

  ('d1000000-0000-0000-0000-000000000008',
   'a1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000004',
   'Weekly Home Maintenance Cleaning',
   'Reliable weekly cleaning service to keep your home consistently fresh. Includes vacuuming, mopping, dusting, bathroom and kitchen cleaning, bed-making, and surface sanitization.',
   'Home Cleaning', 'hourly', 45, 2,
   'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=600&h=400&fit=crop',
   ARRAY[]::TEXT[],
   ARRAY['Weekly schedule','All rooms','Kitchen & bathroom focus','Surface sanitization','Flexible timing'],
   true, 'Ottawa, ON', ARRAY['Ottawa','Gatineau'], 'Same day', 312, 98),

  -- Maid Masters listings
  ('d1000000-0000-0000-0000-000000000009',
   'a1000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000005',
   'Bilingual Home Cleaning Service',
   'Professional French and English speaking cleaning staff serve Montreal households. Our 50-point cleaning checklist covers everything from baseboards to ceiling fans. Satisfaction guaranteed.',
   'Home Cleaning', 'hourly', 50, 3,
   'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=600&h=400&fit=crop',
   ARRAY[]::TEXT[],
   ARRAY['Bilingual staff','50-point checklist','All rooms','Kitchen deep clean','Bathroom scrub','Satisfaction guarantee'],
   true, 'Montreal, QC', ARRAY['Montreal','Laval','Longueuil'], 'Same day', 156, 43),

  -- Crystal Clear Co. listings
  ('d1000000-0000-0000-0000-000000000010',
   'a1000000-0000-0000-0000-000000000006', 'b1000000-0000-0000-0000-000000000006',
   'Premium Window Cleaning — Interior & Exterior',
   'Crystal-clear windows using pure-water technology. We clean interior and exterior glass, frames, sills, and screens. Streak-free guarantee. Available for residential and commercial properties.',
   'Other', 'starting_at', 99, 3,
   'https://images.unsplash.com/photo-1527515637462-cee1cef4c8e4?w=600&h=400&fit=crop',
   ARRAY[]::TEXT[],
   ARRAY['Pure-water technology','Interior & exterior','Frames & sills','Screen cleaning','Streak-free guarantee','Up to 3 storeys'],
   true, 'Edmonton, AB', ARRAY['Edmonton','St. Albert'], '24 hours', 123, 19),

  -- Green Gleam Services listings
  ('d1000000-0000-0000-0000-000000000011',
   'a1000000-0000-0000-0000-000000000007', 'b1000000-0000-0000-0000-000000000007',
   'Carbon-Neutral Home Detailing',
   'Winnipeg''s first carbon-neutral cleaning service. We offset 100% of our operations'' carbon footprint. Premium home detailing includes hand-wiping all surfaces, eco-steam cleaning, and green product application.',
   'Eco-Friendly Cleaning', 'fixed', 135, 4,
   'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&h=400&fit=crop',
   ARRAY['https://images.unsplash.com/photo-1600607687644-aac4c3eac7f4?w=600&h=400&fit=crop'],
   ARRAY['Carbon neutral','Eco-steam cleaning','Hand-detailed surfaces','Plant-based sprays','Reusable cloths'],
   true, 'Winnipeg, MB', ARRAY['Winnipeg','Brandon'], 'Same day', 89, 14),

  ('d1000000-0000-0000-0000-000000000012',
   'a1000000-0000-0000-0000-000000000007', 'b1000000-0000-0000-0000-000000000007',
   'Green Carpet & Upholstery Refresh',
   'Eco-friendly deep carpet and upholstery cleaning. We use enzymatic cleaners and steam extraction to remove stains and allergens without harsh chemicals. Great for allergy sufferers.',
   'Carpet Cleaning', 'starting_at', 119, 3,
   'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?w=600&h=400&fit=crop',
   ARRAY[]::TEXT[],
   ARRAY['Enzymatic cleaners','Steam extraction','Upholstery included','Allergy-friendly','Non-toxic','Pet stain removal'],
   true, 'Winnipeg, MB', ARRAY['Winnipeg'], '24 hours', 67, 8),

  -- A+ Janitorial listings
  ('d1000000-0000-0000-0000-000000000013',
   'a1000000-0000-0000-0000-000000000008', 'b1000000-0000-0000-0000-000000000008',
   'Medical Facility Sanitization',
   'Hospital-grade sanitization for medical offices, dental clinics, and healthcare facilities. We follow strict infection control protocols and use EPA-registered disinfectants.',
   'Office Cleaning', 'hourly', 85, 4,
   'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=600&h=400&fit=crop',
   ARRAY[]::TEXT[],
   ARRAY['Hospital-grade disinfectants','Infection control protocols','EPA registered','Background-checked staff','WHMIS certified','Biohazard capable'],
   true, 'Mississauga, ON', ARRAY['Mississauga','Brampton','Oakville'], '24 hours', 76, 11),

  -- FreshStart Cleaning listings
  ('d1000000-0000-0000-0000-000000000014',
   'a1000000-0000-0000-0000-000000000009', 'b1000000-0000-0000-0000-000000000009',
   'Budget-Friendly Move-Out Clean',
   'Affordable yet thorough move-out cleaning designed to help you get your deposit back. We focus on kitchens, bathrooms, floors, and walls. Add-on options for oven and fridge deep clean.',
   'Move-in/Move-out', 'fixed', 129, 4,
   'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&h=400&fit=crop',
   ARRAY[]::TEXT[],
   ARRAY['Deposit-back guarantee','Kitchen focus','Bathroom descaling','Wall spot cleaning','Floor care','Optional oven/fridge add-on'],
   true, 'Halifax, NS', ARRAY['Halifax','Dartmouth','Bedford'], 'Same day', 201, 55),

  ('d1000000-0000-0000-0000-000000000015',
   'a1000000-0000-0000-0000-000000000009', 'b1000000-0000-0000-0000-000000000009',
   'Airbnb Host Express Package',
   'Quick, reliable turnovers for busy Airbnb hosts in Halifax. We can be there within 2 hours of checkout. Includes fresh linens, guest amenity setup, and photo-ready staging.',
   'Home Cleaning', 'fixed', 85, 2,
   'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=600&h=400&fit=crop',
   ARRAY[]::TEXT[],
   ARRAY['2-hour response','Fresh linens','Guest amenities','Photo-ready staging','Damage check','Restock supplies'],
   true, 'Halifax, NS', ARRAY['Halifax','Dartmouth'], 'Same day', 134, 41),

  -- Pro Shine Team listings
  ('d1000000-0000-0000-0000-000000000016',
   'a1000000-0000-0000-0000-000000000010', 'b1000000-0000-0000-0000-000000000010',
   'Premium Residential Deep Clean',
   'Our signature premium service for discerning homeowners. Every surface is hand-wiped, every corner is inspected, and every detail is perfected. We use hospital-grade disinfectants and premium microfiber cloths.',
   'Deep Cleaning', 'fixed', 249, 5,
   'https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=600&h=400&fit=crop',
   ARRAY[]::TEXT[],
   ARRAY['Hospital-grade disinfectants','Premium microfiber','Hand-wiped surfaces','Detailed inspection','All rooms','Inside appliances'],
   true, 'Victoria, BC', ARRAY['Victoria','Saanich','Langford'], '24 hours', 156, 27),

  -- TidyUp Experts listings
  ('d1000000-0000-0000-0000-000000000017',
   'a1000000-0000-0000-0000-000000000011', 'b1000000-0000-0000-0000-000000000011',
   'Same-Day Express Clean',
   'Need cleaning done today? Our express team is available 7 days a week for same-day bookings. Perfect for unexpected guests or last-minute events. Fast, efficient, and reliable.',
   'Home Cleaning', 'fixed', 99, 2,
   'https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=600&h=400&fit=crop',
   ARRAY[]::TEXT[],
   ARRAY['Same-day availability','7 days a week','Express turnaround','Full home coverage','2-hour slots','Last-minute bookings'],
   true, 'Markham, ON', ARRAY['Markham','Vaughan','Richmond Hill'], 'Same day', 245, 67),

  ('d1000000-0000-0000-0000-000000000018',
   'a1000000-0000-0000-0000-000000000011', 'b1000000-0000-0000-0000-000000000011',
   'Eco-Friendly Office Maintenance',
   'Green cleaning for your workspace. We use non-toxic products to sanitize desks, clean floors, and maintain washrooms. Weekly and bi-weekly plans available. LEED-compliant products.',
   'Office Cleaning', 'hourly', 55, 3,
   'https://images.unsplash.com/photo-1497215842964-222b430dc094?w=600&h=400&fit=crop',
   ARRAY[]::TEXT[],
   ARRAY['LEED-compliant','Non-toxic products','Desk sanitization','Floor care','Washroom maintenance','Flexible schedules'],
   true, 'Markham, ON', ARRAY['Markham','Aurora'], '24 hours', 88, 15),

  -- Diamond Dust Cleaning listings
  ('d1000000-0000-0000-0000-000000000019',
   'a1000000-0000-0000-0000-000000000012', 'b1000000-0000-0000-0000-000000000012',
   'Industrial Post-Construction Blitz',
   'The ultimate in post-construction cleanup. We bring in a full crew with industrial vacuums, pressure washers, and floor polishers. Suitable for new builds, renovations, and commercial fitouts.',
   'Post-Construction', 'starting_at', 350, 8,
   'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=600&h=400&fit=crop',
   ARRAY[]::TEXT[],
   ARRAY['Full crew deployment','Industrial vacuums','Pressure washing','Floor polishing','Debris hauling','Final inspection'],
   true, 'London, ON', ARRAY['London','Kitchener','Waterloo'], '48 hours', 62, 9),

  ('d1000000-0000-0000-0000-000000000020',
   'a1000000-0000-0000-0000-000000000012', 'b1000000-0000-0000-0000-000000000012',
   'Commercial Space Deep Decontamination',
   'Comprehensive decontamination and deep cleaning for warehouses, factories, and large commercial spaces. We handle everything from floor scrubbing to high-ceiling dusting with scissor lifts.',
   'Deep Cleaning', 'starting_at', 499, 10,
   'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=600&h=400&fit=crop',
   ARRAY[]::TEXT[],
   ARRAY['Warehouse scale','High-ceiling access','Floor scrubbing','Decontamination','Equipment cleaning','Scissor lift work'],
   true, 'London, ON', ARRAY['London','Guelph'], '72 hours', 34, 5)

ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  category = EXCLUDED.category,
  price_type = EXCLUDED.price_type,
  price = EXCLUDED.price,
  image_url = EXCLUDED.image_url,
  features = EXCLUDED.features,
  views_count = EXCLUDED.views_count,
  orders_count = EXCLUDED.orders_count;


-- =============================================
-- 6. Create reviews for cleaner profiles
-- =============================================
INSERT INTO public.reviews (id, reviewer_id, cleaner_profile_id, rating, comment) VALUES
  -- Reviews for SparklePro Cleaning
  ('e1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000001', 5, 'Absolutely incredible service! Sarah and her team made our home look brand new. Every corner was spotless. Will definitely book again.'),
  ('e1000000-0000-0000-0000-000000000002', 'c1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000001', 5, 'Best cleaning service in Toronto. They were on time, professional, and thorough. Our Airbnb reviews went up after using their turnover service!'),
  ('e1000000-0000-0000-0000-000000000003', 'c1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000001', 4, 'Great deep clean. A couple of spots were missed under the sofa but overall very happy with the results. Good value for the price.'),
  ('e1000000-0000-0000-0000-000000000004', 'c1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000001', 5, 'We''ve been using SparklePro for 6 months now. Consistent quality every single time. Highly recommend to anyone in the GTA.'),

  -- Reviews for CleanSweep Masters
  ('e1000000-0000-0000-0000-000000000005', 'c1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000002', 5, 'Our office has never looked better! The after-hours scheduling is perfect — no disruption to our workflow at all. Excellent commercial service.'),
  ('e1000000-0000-0000-0000-000000000006', 'c1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000002', 4, 'Handled our post-construction cleanup efficiently. The crew was large and well-organized. Only took one day for what I expected to be two.'),
  ('e1000000-0000-0000-0000-000000000007', 'c1000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000002', 5, 'Michael''s team is simply the best in Vancouver for commercial spaces. They''re thorough, reliable, and their pricing is fair.'),

  -- Reviews for Eco Clean Solutions
  ('e1000000-0000-0000-0000-000000000008', 'c1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000003', 5, 'As a family with two young kids and a dog, finding a truly green cleaner was essential. Eco Clean delivers every time. The products smell amazing too!'),
  ('e1000000-0000-0000-0000-000000000009', 'c1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000003', 5, 'Love that they''re carbon-neutral! The cleaning quality is just as good as traditional services, with none of the chemical smell. Five stars.'),
  ('e1000000-0000-0000-0000-000000000010', 'c1000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000003', 5, 'Emma and team did our move-out clean and we got our full deposit back. Everything was sparkling. Green and effective!'),

  -- Reviews for Pristine Home Services
  ('e1000000-0000-0000-0000-000000000011', 'c1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000004', 4, 'Great carpet cleaning result. Our carpets look years younger. The team was friendly and explained the whole process clearly.'),
  ('e1000000-0000-0000-0000-000000000012', 'c1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000004', 5, 'Using their weekly cleaning service and it''s been a game changer. Always on time and our house stays consistently clean.'),
  ('e1000000-0000-0000-0000-000000000013', 'c1000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000004', 4, 'Solid cleaning service. The carpet deep clean removed stains I thought were permanent. Will use again for sure.'),

  -- Reviews for Maid Masters
  ('e1000000-0000-0000-0000-000000000014', 'c1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000005', 5, 'Finally a bilingual cleaning service in Montreal! Sophia''s team is wonderful — polite, efficient, and meticulous. Our condo sparkles.'),
  ('e1000000-0000-0000-0000-000000000015', 'c1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000005', 4, 'Good quality cleaning at a fair price. The 50-point checklist really ensures nothing is missed. Booked them for weekly now.'),
  ('e1000000-0000-0000-0000-000000000016', 'c1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000005', 5, 'Maid Masters is our go-to for Airbnb turnovers in Montreal. Quick, reliable, and guests always comment on how clean the place is.'),

  -- Reviews for Crystal Clear Co.
  ('e1000000-0000-0000-0000-000000000017', 'c1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000006', 4, 'Our office windows are spotless. David''s team uses some fancy water system that leaves zero streaks. Very impressed.'),
  ('e1000000-0000-0000-0000-000000000018', 'c1000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000006', 5, 'Crystal Clear did our home windows + screens. Everything is gleaming. They were careful with our garden too. Highly recommend in Edmonton.'),

  -- Reviews for Green Gleam Services
  ('e1000000-0000-0000-0000-000000000019', 'c1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000007', 5, 'The carbon-neutral aspect sold me, but the quality kept me coming back. Our house has never smelled so naturally fresh. Love this service!'),
  ('e1000000-0000-0000-0000-000000000020', 'c1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000007', 4, 'Great eco carpet cleaning. Removed pet stains without harsh chemicals. Olivia was super friendly and professional.'),

  -- Reviews for A+ Janitorial
  ('e1000000-0000-0000-0000-000000000021', 'c1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000008', 5, 'A+ truly lives up to their name. Our dental clinic requires strict sanitization standards and they exceed them every time.'),
  ('e1000000-0000-0000-0000-000000000022', 'c1000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000008', 5, 'Professional, thorough, and reliable. They handle our warehouse cleaning on weekends. Always done perfectly.'),

  -- Reviews for FreshStart Cleaning
  ('e1000000-0000-0000-0000-000000000023', 'c1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000009', 5, 'Used FreshStart for my move-out and got my full deposit back! Emily was lovely and the price was very fair for Halifax.'),
  ('e1000000-0000-0000-0000-000000000024', 'c1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000009', 4, 'Quick Airbnb turnover — they were done in under 2 hours and the place looked amazing. My guests loved it.'),

  -- Reviews for Pro Shine Team
  ('e1000000-0000-0000-0000-000000000025', 'c1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000010', 5, 'Premium service for a reason. Daniel''s attention to detail is unmatched. Our home feels like a five-star hotel after they visit.'),
  ('e1000000-0000-0000-0000-000000000026', 'c1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000010', 5, 'Worth every penny. The deep clean was incredibly thorough. Found dirt in places I didn''t even know existed. Highly recommend.'),
  ('e1000000-0000-0000-0000-000000000027', 'c1000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000010', 4, 'Excellent carpet cleaning service in Victoria. Professional equipment and great results. Will use again.'),

  -- Reviews for TidyUp Experts
  ('e1000000-0000-0000-0000-000000000028', 'c1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000011', 5, 'Same-day booking saved me when surprise guests were coming! Rachel''s team showed up within an hour and transformed our home.'),
  ('e1000000-0000-0000-0000-000000000029', 'c1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000011', 4, 'Reliable and flexible. We use TidyUp for both home and our small office. They handle both spaces really well.'),

  -- Reviews for Diamond Dust Cleaning
  ('e1000000-0000-0000-0000-000000000030', 'c1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000012', 5, 'Hired them for a massive post-construction cleanup of our new warehouse. Chris brought a full crew and heavy equipment. Done in one day. Incredible.'),
  ('e1000000-0000-0000-0000-000000000031', 'c1000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000012', 5, 'Diamond Dust handled our condo renovation cleanup. They removed every speck of dust and the floors were polished to perfection.')

ON CONFLICT (id) DO UPDATE SET
  rating = EXCLUDED.rating,
  comment = EXCLUDED.comment;


-- =============================================
-- 7. Create wallets for all new users
-- =============================================
INSERT INTO public.wallets (user_id, balance)
SELECT u.id, 0
FROM auth.users u
WHERE u.id IN (
  'a1000000-0000-0000-0000-000000000001',
  'a1000000-0000-0000-0000-000000000002',
  'a1000000-0000-0000-0000-000000000003',
  'a1000000-0000-0000-0000-000000000004',
  'a1000000-0000-0000-0000-000000000005',
  'a1000000-0000-0000-0000-000000000006',
  'a1000000-0000-0000-0000-000000000007',
  'a1000000-0000-0000-0000-000000000008',
  'a1000000-0000-0000-0000-000000000009',
  'a1000000-0000-0000-0000-000000000010',
  'a1000000-0000-0000-0000-000000000011',
  'a1000000-0000-0000-0000-000000000012',
  'c1000000-0000-0000-0000-000000000001',
  'c1000000-0000-0000-0000-000000000002',
  'c1000000-0000-0000-0000-000000000003',
  'c1000000-0000-0000-0000-000000000004',
  'c1000000-0000-0000-0000-000000000005'
)
ON CONFLICT (user_id) DO NOTHING;


-- =============================================
-- Done! Summary:
-- • 12 Cleaner/Provider accounts created
-- • 5 Customer accounts created (for reviews)
-- • 12 Cleaner profiles with stock images & details
-- • 20 Service listings across all categories
-- • 31 Reviews with realistic comments
-- • Wallets auto-created for all users
-- ============================================= 
