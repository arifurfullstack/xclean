-- ============================================
-- Migration: 20260207091036_5bdabf7e-3ff4-46ac-926c-f01e908482f3.sql
-- ============================================
-- Create app_role enum for user roles
CREATE TYPE public.app_role AS ENUM ('customer', 'cleaner', 'company', 'admin');

-- Create profiles table
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create user_roles table (separate from profiles for security)
CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role app_role NOT NULL DEFAULT 'customer',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE (user_id, role)
);

-- Create addresses table
CREATE TABLE public.addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  label TEXT NOT NULL DEFAULT 'Home',
  street_address TEXT NOT NULL,
  city TEXT NOT NULL,
  province TEXT NOT NULL,
  postal_code TEXT NOT NULL,
  country TEXT NOT NULL DEFAULT 'Canada',
  is_default BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create booking_status enum
CREATE TYPE public.booking_status AS ENUM ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled');

-- Create bookings table
CREATE TABLE public.bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  cleaner_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  address_id UUID REFERENCES public.addresses(id) ON DELETE SET NULL,
  service_type TEXT NOT NULL,
  service_price DECIMAL(10,2) NOT NULL,
  scheduled_date DATE NOT NULL,
  scheduled_time TEXT NOT NULL,
  duration_hours INTEGER NOT NULL DEFAULT 2,
  status booking_status NOT NULL DEFAULT 'pending',
  special_instructions TEXT,
  cleaner_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Security definer function to check user role
CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role app_role)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
      AND role = _role
  )
$$;

-- Function to get current user's role
CREATE OR REPLACE FUNCTION public.get_user_role(_user_id UUID)
RETURNS app_role
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role
  FROM public.user_roles
  WHERE user_id = _user_id
  LIMIT 1
$$;

-- Profiles RLS policies
CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- User roles RLS policies (read-only for users, only system can modify)
CREATE POLICY "Users can view their own roles"
  ON public.user_roles FOR SELECT
  USING (auth.uid() = user_id);

-- Addresses RLS policies
CREATE POLICY "Users can view their own addresses"
  ON public.addresses FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own addresses"
  ON public.addresses FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own addresses"
  ON public.addresses FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own addresses"
  ON public.addresses FOR DELETE
  USING (auth.uid() = user_id);

-- Bookings RLS policies
CREATE POLICY "Customers can view their own bookings"
  ON public.bookings FOR SELECT
  USING (auth.uid() = customer_id);

CREATE POLICY "Customers can create bookings"
  ON public.bookings FOR INSERT
  WITH CHECK (auth.uid() = customer_id);

CREATE POLICY "Customers can update their own bookings"
  ON public.bookings FOR UPDATE
  USING (auth.uid() = customer_id);

-- Function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_addresses_updated_at
  BEFORE UPDATE ON public.addresses
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at
  BEFORE UPDATE ON public.bookings
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Create profile
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');
  
  -- Assign default customer role
  INSERT INTO public.user_roles (user_id, role)
  VALUES (NEW.id, 'customer');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Trigger for new user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- Migration: 20260207093610_05979ee9-b718-4d23-93fd-ec895240c476.sql
-- ============================================
-- Create cleaner_profiles table for business information
CREATE TABLE public.cleaner_profiles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE,
  business_name TEXT NOT NULL,
  bio TEXT,
  hourly_rate NUMERIC NOT NULL DEFAULT 50,
  services TEXT[] NOT NULL DEFAULT ARRAY['Home Cleaning'],
  service_areas TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
  years_experience INTEGER DEFAULT 0,
  profile_image TEXT,
  gallery_images TEXT[] DEFAULT ARRAY[]::TEXT[],
  is_verified BOOLEAN NOT NULL DEFAULT false,
  instant_booking BOOLEAN NOT NULL DEFAULT false,
  is_active BOOLEAN NOT NULL DEFAULT true,
  response_time TEXT DEFAULT 'Responds in ~1 hour',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.cleaner_profiles ENABLE ROW LEVEL SECURITY;

-- Cleaners can view their own profile
CREATE POLICY "Cleaners can view their own profile"
ON public.cleaner_profiles
FOR SELECT
USING (auth.uid() = user_id);

-- Cleaners can update their own profile
CREATE POLICY "Cleaners can update their own profile"
ON public.cleaner_profiles
FOR UPDATE
USING (auth.uid() = user_id);

-- Cleaners can insert their own profile
CREATE POLICY "Cleaners can insert their own profile"
ON public.cleaner_profiles
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Anyone can view active cleaner profiles (for search/discovery)
CREATE POLICY "Anyone can view active cleaner profiles"
ON public.cleaner_profiles
FOR SELECT
USING (is_active = true);

-- Add policy for cleaners to view bookings assigned to them
CREATE POLICY "Cleaners can view their assigned bookings"
ON public.bookings
FOR SELECT
USING (auth.uid() = cleaner_id);

-- Add policy for cleaners to update their assigned bookings
CREATE POLICY "Cleaners can update their assigned bookings"
ON public.bookings
FOR UPDATE
USING (auth.uid() = cleaner_id);

-- Create trigger for updated_at
CREATE TRIGGER update_cleaner_profiles_updated_at
BEFORE UPDATE ON public.cleaner_profiles
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- Migration: 20260207094354_94600d38-61be-466a-bd63-b816822d5c9d.sql
-- ============================================
-- Update the handle_new_user function to use account_type from metadata
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  account_type text;
  user_role app_role;
BEGIN
  -- Get account_type from metadata, default to 'customer'
  account_type := COALESCE(NEW.raw_user_meta_data->>'account_type', 'customer');
  
  -- Map account_type to app_role
  IF account_type = 'cleaner' THEN
    user_role := 'cleaner';
  ELSE
    user_role := 'customer';
  END IF;
  
  -- Create profile
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');
  
  -- Assign role based on account_type
  INSERT INTO public.user_roles (user_id, role)
  VALUES (NEW.id, user_role);
  
  RETURN NEW;
END;
$function$;

-- ============================================
-- Migration: 20260207135027_5067fd1f-1c87-42fa-9fc9-ff2040ac0a6f.sql
-- ============================================
-- Add admin SELECT policies for all tables using the existing has_role function

-- Profiles: Allow admins to view all profiles
CREATE POLICY "Admins can view all profiles"
ON public.profiles
FOR SELECT
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- User Roles: Allow admins to view all user roles
CREATE POLICY "Admins can view all user roles"
ON public.user_roles
FOR SELECT
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- Addresses: Allow admins to view all addresses
CREATE POLICY "Admins can view all addresses"
ON public.addresses
FOR SELECT
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- Bookings: Allow admins to view all bookings
CREATE POLICY "Admins can view all bookings"
ON public.bookings
FOR SELECT
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- Cleaner Profiles: Allow admins to view all cleaner profiles (including inactive)
CREATE POLICY "Admins can view all cleaner profiles"
ON public.cleaner_profiles
FOR SELECT
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- Allow admins to update cleaner profiles (for verification/activation)
CREATE POLICY "Admins can update cleaner profiles"
ON public.cleaner_profiles
FOR UPDATE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- Allow admins to update bookings
CREATE POLICY "Admins can update all bookings"
ON public.bookings
FOR UPDATE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- ============================================
-- Migration: 20260207141539_bc4335b6-16c1-451c-b4bc-f7b85cd3131c.sql
-- ============================================
-- Allow admins to update user roles
CREATE POLICY "Admins can update user roles"
ON public.user_roles
FOR UPDATE
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- ============================================
-- Migration: 20260207163211_32d2e8cf-68f7-45ca-a561-c9627c308e3d.sql
-- ============================================
-- Allow admins to update any profile
CREATE POLICY "Admins can update all profiles" 
ON public.profiles 
FOR UPDATE 
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- ============================================
-- Migration: 20260207163448_68ec82fb-03a0-4e38-85ed-cc9e2bc2bf80.sql
-- ============================================
-- Allow admins to delete profiles
CREATE POLICY "Admins can delete profiles" 
ON public.profiles 
FOR DELETE 
USING (has_role(auth.uid(), 'admin'::app_role));

-- Allow admins to delete user roles
CREATE POLICY "Admins can delete user roles" 
ON public.user_roles 
FOR DELETE 
USING (has_role(auth.uid(), 'admin'::app_role));

-- Allow admins to delete cleaner profiles
CREATE POLICY "Admins can delete cleaner profiles" 
ON public.cleaner_profiles 
FOR DELETE 
USING (has_role(auth.uid(), 'admin'::app_role));

-- Allow admins to delete bookings
CREATE POLICY "Admins can delete bookings" 
ON public.bookings 
FOR DELETE 
USING (has_role(auth.uid(), 'admin'::app_role));

-- Allow admins to delete addresses
CREATE POLICY "Admins can delete addresses" 
ON public.addresses 
FOR DELETE 
USING (has_role(auth.uid(), 'admin'::app_role));

-- ============================================
-- Migration: 20260207170011_c5f824e2-8864-4c7a-ba4c-085bb496690a.sql
-- ============================================
-- Allow admins to insert user roles
CREATE POLICY "Admins can insert user roles"
ON public.user_roles
FOR INSERT
TO authenticated
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- ============================================
-- Migration: 20260207171739_88a66628-fb7d-4980-9edd-fb597f422ea0.sql
-- ============================================
-- Create platform_settings table (single row for all settings)
CREATE TABLE public.platform_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  platform_name text NOT NULL DEFAULT 'The Cleaning Network',
  support_email text,
  maintenance_mode boolean NOT NULL DEFAULT false,
  notify_new_users boolean NOT NULL DEFAULT true,
  notify_new_bookings boolean NOT NULL DEFAULT true,
  notify_cleaner_applications boolean NOT NULL DEFAULT true,
  require_email_verification boolean NOT NULL DEFAULT true,
  require_2fa_admins boolean NOT NULL DEFAULT false,
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid REFERENCES auth.users(id)
);

-- Enable RLS
ALTER TABLE public.platform_settings ENABLE ROW LEVEL SECURITY;

-- Admins can view settings
CREATE POLICY "Admins can view platform settings"
ON public.platform_settings
FOR SELECT
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role));

-- Admins can update settings
CREATE POLICY "Admins can update platform settings"
ON public.platform_settings
FOR UPDATE
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Admins can insert settings (for initial setup)
CREATE POLICY "Admins can insert platform settings"
ON public.platform_settings
FOR INSERT
TO authenticated
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Create trigger for updated_at
CREATE TRIGGER update_platform_settings_updated_at
BEFORE UPDATE ON public.platform_settings
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Insert default settings row
INSERT INTO public.platform_settings (id) VALUES (gen_random_uuid());

-- ============================================
-- Migration: 20260207172413_32bb5fab-a8b3-4c2f-a695-968e2a80dbca.sql
-- ============================================
-- Add more essential settings columns to platform_settings
ALTER TABLE public.platform_settings
ADD COLUMN platform_commission_rate numeric NOT NULL DEFAULT 10,
ADD COLUMN min_booking_hours integer NOT NULL DEFAULT 2,
ADD COLUMN max_booking_hours integer NOT NULL DEFAULT 8,
ADD COLUMN cancellation_window_hours integer NOT NULL DEFAULT 24,
ADD COLUMN advance_booking_days integer NOT NULL DEFAULT 30,
ADD COLUMN min_hourly_rate numeric NOT NULL DEFAULT 25,
ADD COLUMN max_hourly_rate numeric NOT NULL DEFAULT 150,
ADD COLUMN default_currency text NOT NULL DEFAULT 'CAD',
ADD COLUMN site_tagline text DEFAULT 'Find trusted cleaning professionals near you',
ADD COLUMN terms_url text,
ADD COLUMN privacy_url text,
ADD COLUMN allow_instant_booking boolean NOT NULL DEFAULT true,
ADD COLUMN require_cleaner_verification boolean NOT NULL DEFAULT true,
ADD COLUMN auto_approve_cleaners boolean NOT NULL DEFAULT false;

-- ============================================
-- Migration: 20260208065641_2d61ed6f-e722-4f74-9efa-e59207668cee.sql
-- ============================================
-- Create payment status enum
CREATE TYPE payment_status AS ENUM ('pending', 'verified', 'rejected');

-- Create payment_records table
CREATE TABLE public.payment_records (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE,
  customer_id UUID NOT NULL,
  customer_name TEXT NOT NULL,
  customer_email TEXT NOT NULL,
  cleaner_id UUID,
  cleaner_name TEXT,
  cleaner_email TEXT,
  amount NUMERIC NOT NULL,
  payment_method TEXT NOT NULL DEFAULT 'bank_transfer',
  status payment_status NOT NULL DEFAULT 'pending',
  rejection_reason TEXT,
  service_type TEXT NOT NULL,
  booking_date DATE NOT NULL,
  booking_time TEXT NOT NULL,
  customer_address TEXT,
  submitted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  verified_at TIMESTAMP WITH TIME ZONE,
  verified_by UUID,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.payment_records ENABLE ROW LEVEL SECURITY;

-- Admin policies
CREATE POLICY "Admins can view all payment records"
ON public.payment_records
FOR SELECT
USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update payment records"
ON public.payment_records
FOR UPDATE
USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can insert payment records"
ON public.payment_records
FOR INSERT
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Customers can create their own payment records
CREATE POLICY "Customers can create their own payment records"
ON public.payment_records
FOR INSERT
WITH CHECK (auth.uid() = customer_id);

-- Customers can view their own payment records
CREATE POLICY "Customers can view their own payment records"
ON public.payment_records
FOR SELECT
USING (auth.uid() = customer_id);

-- Cleaners can view payment records for their bookings
CREATE POLICY "Cleaners can view their payment records"
ON public.payment_records
FOR SELECT
USING (auth.uid() = cleaner_id);

-- Add updated_at trigger
CREATE TRIGGER update_payment_records_updated_at
BEFORE UPDATE ON public.payment_records
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- Migration: 20260208130248_d70f0cfb-6e7f-4ee5-adc0-988f5449d9ea.sql
-- ============================================
-- Create subscription plans table
CREATE TABLE public.subscription_plans (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  target_audience TEXT NOT NULL CHECK (target_audience IN ('cleaner', 'customer')),
  tier TEXT NOT NULL CHECK (tier IN ('basic', 'pro', 'premium')),
  monthly_price NUMERIC NOT NULL DEFAULT 0,
  features JSONB NOT NULL DEFAULT '[]'::jsonb,
  -- Cleaner benefits
  priority_listing_boost INTEGER DEFAULT 0,
  commission_discount NUMERIC DEFAULT 0,
  includes_verification_badge BOOLEAN DEFAULT false,
  includes_analytics_access BOOLEAN DEFAULT false,
  -- Customer benefits
  booking_discount_percent NUMERIC DEFAULT 0,
  priority_booking BOOLEAN DEFAULT false,
  premium_support BOOLEAN DEFAULT false,
  express_booking BOOLEAN DEFAULT false,
  -- Status
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create user subscriptions table
CREATE TABLE public.user_subscriptions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  plan_id UUID NOT NULL REFERENCES public.subscription_plans(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'cancelled', 'expired')),
  payment_method TEXT NOT NULL DEFAULT 'bank_transfer' CHECK (payment_method IN ('bank_transfer', 'stripe')),
  -- Dates
  start_date DATE,
  end_date DATE,
  next_billing_date DATE,
  -- Payment tracking
  last_payment_date TIMESTAMP WITH TIME ZONE,
  last_payment_amount NUMERIC,
  -- Stripe fields for future use
  stripe_subscription_id TEXT,
  stripe_customer_id TEXT,
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create subscription payment records table
CREATE TABLE public.subscription_payments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  subscription_id UUID NOT NULL REFERENCES public.user_subscriptions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL,
  plan_id UUID NOT NULL REFERENCES public.subscription_plans(id),
  amount NUMERIC NOT NULL,
  payment_method TEXT NOT NULL DEFAULT 'bank_transfer',
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'verified', 'rejected')),
  billing_period_start DATE NOT NULL,
  billing_period_end DATE NOT NULL,
  -- Verification
  verified_at TIMESTAMP WITH TIME ZONE,
  verified_by UUID,
  rejection_reason TEXT,
  -- Timestamps
  submitted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS on all tables
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_payments ENABLE ROW LEVEL SECURITY;

-- Subscription Plans Policies (public read for active plans, admin full access)
CREATE POLICY "Anyone can view active subscription plans"
  ON public.subscription_plans FOR SELECT
  USING (is_active = true);

CREATE POLICY "Admins can view all subscription plans"
  ON public.subscription_plans FOR SELECT
  USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can insert subscription plans"
  ON public.subscription_plans FOR INSERT
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update subscription plans"
  ON public.subscription_plans FOR UPDATE
  USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can delete subscription plans"
  ON public.subscription_plans FOR DELETE
  USING (has_role(auth.uid(), 'admin'::app_role));

-- User Subscriptions Policies
CREATE POLICY "Users can view their own subscriptions"
  ON public.user_subscriptions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own subscriptions"
  ON public.user_subscriptions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own subscriptions"
  ON public.user_subscriptions FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all subscriptions"
  ON public.user_subscriptions FOR SELECT
  USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update all subscriptions"
  ON public.user_subscriptions FOR UPDATE
  USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can delete subscriptions"
  ON public.user_subscriptions FOR DELETE
  USING (has_role(auth.uid(), 'admin'::app_role));

-- Subscription Payments Policies
CREATE POLICY "Users can view their own payments"
  ON public.subscription_payments FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own payments"
  ON public.subscription_payments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all payments"
  ON public.subscription_payments FOR SELECT
  USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update payments"
  ON public.subscription_payments FOR UPDATE
  USING (has_role(auth.uid(), 'admin'::app_role));

-- Create updated_at trigger function if not exists
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- Add triggers for updated_at
CREATE TRIGGER update_subscription_plans_updated_at
  BEFORE UPDATE ON public.subscription_plans
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_subscriptions_updated_at
  BEFORE UPDATE ON public.user_subscriptions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_subscription_payments_updated_at
  BEFORE UPDATE ON public.subscription_payments
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Insert default subscription plans
INSERT INTO public.subscription_plans (name, description, target_audience, tier, monthly_price, features, priority_listing_boost, commission_discount, includes_verification_badge, includes_analytics_access)
VALUES 
  ('Cleaner Basic', 'Essential features for independent cleaners', 'cleaner', 'basic', 19.99, '["Priority listing boost", "5% reduced commission"]', 10, 5, false, false),
  ('Cleaner Pro', 'Professional features for growing businesses', 'cleaner', 'pro', 39.99, '["Higher priority listing", "7% reduced commission", "Verification badge"]', 25, 7, true, false),
  ('Cleaner Premium', 'Complete suite for established cleaning businesses', 'cleaner', 'premium', 79.99, '["Top priority listing", "10% reduced commission", "Verification badge", "Analytics access"]', 50, 10, true, true);

INSERT INTO public.subscription_plans (name, description, target_audience, tier, monthly_price, features, booking_discount_percent, priority_booking, premium_support, express_booking)
VALUES 
  ('Customer Basic', 'Save on your regular cleaning bookings', 'customer', 'basic', 9.99, '["5% off all bookings", "Priority booking access"]', 5, true, false, false),
  ('Customer Pro', 'Enhanced benefits for frequent users', 'customer', 'pro', 19.99, '["10% off all bookings", "Priority booking", "Premium support"]', 10, true, true, false),
  ('Customer Premium', 'Maximum savings and VIP treatment', 'customer', 'premium', 29.99, '["15% off all bookings", "Priority booking", "Premium support", "Express booking"]', 15, true, true, true);

-- ============================================
-- Migration: 20260220184944_e8cab346-dbad-4290-8b44-bb9ef201a54d.sql
-- ============================================

-- Create sponsored_status enum
CREATE TYPE public.sponsored_status AS ENUM ('inactive', 'requested', 'active', 'expired');

-- Create sponsored_listings table
CREATE TABLE public.sponsored_listings (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  cleaner_profile_id UUID NOT NULL REFERENCES public.cleaner_profiles(id) ON DELETE CASCADE,
  user_id UUID NOT NULL,
  is_sponsored BOOLEAN NOT NULL DEFAULT false,
  sponsored_priority INTEGER NOT NULL DEFAULT 0,
  sponsored_start TIMESTAMP WITH TIME ZONE,
  sponsored_end TIMESTAMP WITH TIME ZONE,
  sponsored_status sponsored_status NOT NULL DEFAULT 'inactive',
  sponsored_note TEXT,
  sponsored_views_count INTEGER NOT NULL DEFAULT 0,
  sponsored_quote_clicks INTEGER NOT NULL DEFAULT 0,
  sponsored_book_clicks INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(cleaner_profile_id)
);

-- Enable RLS
ALTER TABLE public.sponsored_listings ENABLE ROW LEVEL SECURITY;

-- Public can view active sponsored listings
CREATE POLICY "Anyone can view active sponsored listings"
  ON public.sponsored_listings
  FOR SELECT
  USING (sponsored_status = 'active' AND is_sponsored = true);

-- Cleaners can view their own sponsorship record
CREATE POLICY "Cleaners can view their own sponsorship"
  ON public.sponsored_listings
  FOR SELECT
  USING (auth.uid() = user_id);

-- Cleaners can insert their own sponsorship request
CREATE POLICY "Cleaners can insert their own sponsorship"
  ON public.sponsored_listings
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Cleaners can update their own record (only note and request fields)
CREATE POLICY "Cleaners can update their own sponsorship note"
  ON public.sponsored_listings
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Admins can view all sponsored listings
CREATE POLICY "Admins can view all sponsored listings"
  ON public.sponsored_listings
  FOR SELECT
  USING (has_role(auth.uid(), 'admin'::app_role));

-- Admins can update all sponsored listings
CREATE POLICY "Admins can update all sponsored listings"
  ON public.sponsored_listings
  FOR UPDATE
  USING (has_role(auth.uid(), 'admin'::app_role));

-- Admins can insert sponsored listings
CREATE POLICY "Admins can insert sponsored listings"
  ON public.sponsored_listings
  FOR INSERT
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Admins can delete sponsored listings
CREATE POLICY "Admins can delete sponsored listings"
  ON public.sponsored_listings
  FOR DELETE
  USING (has_role(auth.uid(), 'admin'::app_role));

-- Auto-update updated_at
CREATE TRIGGER update_sponsored_listings_updated_at
  BEFORE UPDATE ON public.sponsored_listings
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Function to increment view count (public callable)
CREATE OR REPLACE FUNCTION public.increment_sponsored_views(listing_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.sponsored_listings
  SET sponsored_views_count = sponsored_views_count + 1
  WHERE id = listing_id;
END;
$$;

-- Function to increment click count (public callable)
CREATE OR REPLACE FUNCTION public.increment_sponsored_clicks(listing_id UUID, click_type TEXT)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF click_type = 'quote' THEN
    UPDATE public.sponsored_listings
    SET sponsored_quote_clicks = sponsored_quote_clicks + 1
    WHERE id = listing_id;
  ELSIF click_type = 'book' THEN
    UPDATE public.sponsored_listings
    SET sponsored_book_clicks = sponsored_book_clicks + 1
    WHERE id = listing_id;
  END IF;
END;
$$;


-- ============================================
-- Migration: 20260220191723_b17de475-6626-4fb8-a9a8-49e6e6f21eed.sql
-- ============================================

-- Create cleaner_of_the_week table
CREATE TABLE public.cleaner_of_the_week (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  cleaner_profile_id uuid NOT NULL REFERENCES public.cleaner_profiles(id) ON DELETE CASCADE,
  week_start date NOT NULL,
  week_end date NOT NULL,
  note text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);

-- Only one active entry at a time (partial unique index)
CREATE UNIQUE INDEX cleaner_of_the_week_active_unique ON public.cleaner_of_the_week (is_active) WHERE is_active = true;

-- Enable RLS
ALTER TABLE public.cleaner_of_the_week ENABLE ROW LEVEL SECURITY;

-- Anyone can view the active cleaner of the week
CREATE POLICY "Anyone can view active cleaner of the week"
  ON public.cleaner_of_the_week
  FOR SELECT
  USING (is_active = true);

-- Admins have full access
CREATE POLICY "Admins can view all cleaner of the week"
  ON public.cleaner_of_the_week
  FOR SELECT
  USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can insert cleaner of the week"
  ON public.cleaner_of_the_week
  FOR INSERT
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update cleaner of the week"
  ON public.cleaner_of_the_week
  FOR UPDATE
  USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can delete cleaner of the week"
  ON public.cleaner_of_the_week
  FOR DELETE
  USING (has_role(auth.uid(), 'admin'::app_role));

-- Auto-update updated_at
CREATE TRIGGER update_cleaner_of_the_week_updated_at
  BEFORE UPDATE ON public.cleaner_of_the_week
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();


-- ============================================
-- Migration: 20260221064347_99b06783-5f32-44ed-9e14-54593130b5c0.sql
-- ============================================

-- Create theme_settings table for storing website appearance configuration
CREATE TABLE public.theme_settings (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  setting_key text NOT NULL UNIQUE,
  setting_value text,
  setting_type text NOT NULL DEFAULT 'text',
  category text NOT NULL DEFAULT 'general',
  label text NOT NULL,
  description text,
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid
);

-- Enable RLS
ALTER TABLE public.theme_settings ENABLE ROW LEVEL SECURITY;

-- Only admins can manage theme settings
CREATE POLICY "Admins can view theme settings" ON public.theme_settings FOR SELECT USING (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Admins can insert theme settings" ON public.theme_settings FOR INSERT WITH CHECK (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Admins can update theme settings" ON public.theme_settings FOR UPDATE USING (has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Admins can delete theme settings" ON public.theme_settings FOR DELETE USING (has_role(auth.uid(), 'admin'::app_role));

-- Anyone can read theme settings (needed for frontend rendering)
CREATE POLICY "Anyone can read theme settings" ON public.theme_settings FOR SELECT USING (true);

-- Insert default theme settings
INSERT INTO public.theme_settings (setting_key, setting_value, setting_type, category, label, description) VALUES
  ('logo_url', NULL, 'image', 'branding', 'Site Logo', 'Main website logo displayed in the header'),
  ('favicon_url', NULL, 'image', 'branding', 'Favicon', 'Browser tab icon (recommended 32x32 or 64x64)'),
  ('hero_bg_image', NULL, 'image', 'images', 'Hero Background', 'Homepage hero section background image'),
  ('primary_color', '207 70% 35%', 'color', 'colors', 'Primary Color', 'Main brand color (blue)'),
  ('secondary_color', '142 70% 45%', 'color', 'colors', 'Secondary Color', 'Accent brand color (green)'),
  ('accent_color', '45 93% 47%', 'color', 'colors', 'Accent Color', 'Highlight color for ratings/badges (gold)'),
  ('destructive_color', '0 84% 60%', 'color', 'colors', 'Destructive Color', 'Error/danger color (red)'),
  ('background_color', '200 30% 98%', 'color', 'colors', 'Background Color', 'Page background color'),
  ('foreground_color', '215 25% 15%', 'color', 'colors', 'Text Color', 'Main text color'),
  ('header_style', 'light', 'select', 'branding', 'Header Style', 'Header appearance: light or dark'),
  ('footer_bg_image', NULL, 'image', 'images', 'Footer Background', 'Footer section background image'),
  ('og_image', NULL, 'image', 'images', 'Social Share Image', 'Image shown when sharing on social media');

-- Create storage bucket for theme assets
INSERT INTO storage.buckets (id, name, public) VALUES ('theme-assets', 'theme-assets', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for theme assets
CREATE POLICY "Anyone can view theme assets" ON storage.objects FOR SELECT USING (bucket_id = 'theme-assets');
CREATE POLICY "Admins can upload theme assets" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'theme-assets' AND has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Admins can update theme assets" ON storage.objects FOR UPDATE USING (bucket_id = 'theme-assets' AND has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Admins can delete theme assets" ON storage.objects FOR DELETE USING (bucket_id = 'theme-assets' AND has_role(auth.uid(), 'admin'::app_role));


-- ============================================
-- Migration: 20260221065708_8be25004-59d6-42f0-a172-bc9ed5495440.sql
-- ============================================

-- Create reviews table
CREATE TABLE public.reviews (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  booking_id UUID REFERENCES public.bookings(id),
  reviewer_id UUID NOT NULL,
  cleaner_profile_id UUID NOT NULL REFERENCES public.cleaner_profiles(id),
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(booking_id, reviewer_id)
);

-- Enable RLS
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Anyone can read reviews (public)
CREATE POLICY "Anyone can view reviews"
ON public.reviews FOR SELECT
USING (true);

-- Users can create reviews for their own bookings
CREATE POLICY "Users can create their own reviews"
ON public.reviews FOR INSERT
WITH CHECK (auth.uid() = reviewer_id);

-- Users can update their own reviews
CREATE POLICY "Users can update their own reviews"
ON public.reviews FOR UPDATE
USING (auth.uid() = reviewer_id);

-- Users can delete their own reviews
CREATE POLICY "Users can delete their own reviews"
ON public.reviews FOR DELETE
USING (auth.uid() = reviewer_id);

-- Admins full access
CREATE POLICY "Admins can manage all reviews"
ON public.reviews FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role));

-- Trigger for updated_at
CREATE TRIGGER update_reviews_updated_at
BEFORE UPDATE ON public.reviews
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();


-- ============================================
-- Migration: 20260221065838_a5772328-d868-4d1e-a39a-4c1a0a625d5b.sql
-- ============================================

-- Add foreign key from reviews.reviewer_id to profiles.id
ALTER TABLE public.reviews
ADD CONSTRAINT reviews_reviewer_id_fkey
FOREIGN KEY (reviewer_id) REFERENCES public.profiles(id);


-- ============================================
-- Migration: 20260221070218_5af0c790-cd3b-47a1-afdc-f0078499562b.sql
-- ============================================

-- Create jobs table
CREATE TABLE public.jobs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  service_type TEXT NOT NULL DEFAULT 'Home Cleaning',
  location TEXT NOT NULL,
  budget_min NUMERIC,
  budget_max NUMERIC,
  duration_hours INTEGER DEFAULT 2,
  preferred_date DATE,
  preferred_time TEXT,
  urgency TEXT NOT NULL DEFAULT 'flexible',
  status TEXT NOT NULL DEFAULT 'open',
  applications_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create job_applications table
CREATE TABLE public.job_applications (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  job_id UUID NOT NULL REFERENCES public.jobs(id) ON DELETE CASCADE,
  applicant_id UUID NOT NULL,
  cover_message TEXT,
  proposed_rate NUMERIC,
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(job_id, applicant_id)
);

-- Enable RLS
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.job_applications ENABLE ROW LEVEL SECURITY;

-- Jobs: Anyone can view open jobs
CREATE POLICY "Anyone can view open jobs"
ON public.jobs FOR SELECT
USING (status = 'open' OR auth.uid() = user_id);

-- Jobs: Authenticated users can create jobs
CREATE POLICY "Authenticated users can create jobs"
ON public.jobs FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Jobs: Users can update their own jobs
CREATE POLICY "Users can update their own jobs"
ON public.jobs FOR UPDATE
USING (auth.uid() = user_id);

-- Jobs: Users can delete their own jobs
CREATE POLICY "Users can delete their own jobs"
ON public.jobs FOR DELETE
USING (auth.uid() = user_id);

-- Jobs: Admins full access
CREATE POLICY "Admins can manage all jobs"
ON public.jobs FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role));

-- Applications: Job owner can view applications for their jobs
CREATE POLICY "Job owners can view applications"
ON public.job_applications FOR SELECT
USING (
  auth.uid() = applicant_id
  OR EXISTS (SELECT 1 FROM public.jobs WHERE jobs.id = job_id AND jobs.user_id = auth.uid())
);

-- Applications: Authenticated users can apply
CREATE POLICY "Users can create applications"
ON public.job_applications FOR INSERT
WITH CHECK (auth.uid() = applicant_id);

-- Applications: Users can update their own applications
CREATE POLICY "Users can update their applications"
ON public.job_applications FOR UPDATE
USING (auth.uid() = applicant_id);

-- Applications: Job owners can update application status
CREATE POLICY "Job owners can update application status"
ON public.job_applications FOR UPDATE
USING (EXISTS (SELECT 1 FROM public.jobs WHERE jobs.id = job_id AND jobs.user_id = auth.uid()));

-- Applications: Users can delete their own applications
CREATE POLICY "Users can delete their applications"
ON public.job_applications FOR DELETE
USING (auth.uid() = applicant_id);

-- Admins full access to applications
CREATE POLICY "Admins can manage all applications"
ON public.job_applications FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role));

-- Triggers for updated_at
CREATE TRIGGER update_jobs_updated_at
BEFORE UPDATE ON public.jobs
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_job_applications_updated_at
BEFORE UPDATE ON public.job_applications
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Function to increment applications count
CREATE OR REPLACE FUNCTION public.increment_job_applications()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.jobs SET applications_count = applications_count + 1 WHERE id = NEW.job_id;
  RETURN NEW;
END;
$$;

CREATE TRIGGER increment_applications_on_insert
AFTER INSERT ON public.job_applications
FOR EACH ROW
EXECUTE FUNCTION public.increment_job_applications();


-- ============================================
-- Migration: 20260221074222_191de1ce-ca2b-4ac3-bf88-6d9d28155bbc.sql
-- ============================================
-- Add image_url column to jobs table
ALTER TABLE public.jobs ADD COLUMN image_url text NULL;

-- Create storage bucket for job images
INSERT INTO storage.buckets (id, name, public) VALUES ('job-images', 'job-images', true);

-- Storage policies: anyone can view job images
CREATE POLICY "Anyone can view job images"
ON storage.objects FOR SELECT
USING (bucket_id = 'job-images');

-- Authenticated users can upload job images
CREATE POLICY "Authenticated users can upload job images"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'job-images' AND auth.uid() IS NOT NULL);

-- Users can update their own job images
CREATE POLICY "Users can update their own job images"
ON storage.objects FOR UPDATE
USING (bucket_id = 'job-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Users can delete their own job images
CREATE POLICY "Users can delete their own job images"
ON storage.objects FOR DELETE
USING (bucket_id = 'job-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- ============================================
-- Migration: 20260221075043_5b3c112c-4a98-4d41-8baa-bcb4e3b07a31.sql
-- ============================================

-- Create service_listings table (Fiverr-style gig listings)
CREATE TABLE public.service_listings (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  cleaner_profile_id UUID NOT NULL REFERENCES public.cleaner_profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'Home Cleaning',
  price_type TEXT NOT NULL DEFAULT 'fixed' CHECK (price_type IN ('fixed', 'hourly', 'starting_at')),
  price NUMERIC NOT NULL DEFAULT 50,
  duration_hours NUMERIC DEFAULT 2,
  image_url TEXT,
  gallery_images TEXT[] DEFAULT ARRAY[]::TEXT[],
  features TEXT[] DEFAULT ARRAY[]::TEXT[],
  is_active BOOLEAN NOT NULL DEFAULT true,
  location TEXT,
  service_area TEXT[] DEFAULT ARRAY[]::TEXT[],
  max_orders INTEGER DEFAULT 5,
  delivery_time TEXT DEFAULT 'Same day',
  views_count INTEGER NOT NULL DEFAULT 0,
  orders_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.service_listings ENABLE ROW LEVEL SECURITY;

-- Anyone can view active listings
CREATE POLICY "Anyone can view active service listings"
ON public.service_listings
FOR SELECT
USING (is_active = true);

-- Cleaners can view their own listings (including inactive)
CREATE POLICY "Cleaners can view their own listings"
ON public.service_listings
FOR SELECT
USING (auth.uid() = user_id);

-- Cleaners can create their own listings
CREATE POLICY "Cleaners can create their own listings"
ON public.service_listings
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Cleaners can update their own listings
CREATE POLICY "Cleaners can update their own listings"
ON public.service_listings
FOR UPDATE
USING (auth.uid() = user_id);

-- Cleaners can delete their own listings
CREATE POLICY "Cleaners can delete their own listings"
ON public.service_listings
FOR DELETE
USING (auth.uid() = user_id);

-- Admins can manage all listings
CREATE POLICY "Admins can manage all service listings"
ON public.service_listings
FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role));

-- Create trigger for auto-updating updated_at
CREATE TRIGGER update_service_listings_updated_at
BEFORE UPDATE ON public.service_listings
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Create index for faster queries
CREATE INDEX idx_service_listings_category ON public.service_listings(category);
CREATE INDEX idx_service_listings_user_id ON public.service_listings(user_id);
CREATE INDEX idx_service_listings_active ON public.service_listings(is_active);


-- ============================================
-- Migration: 20260221131123_de5e9570-52bc-46f7-b371-54e9f5a2f4c2.sql
-- ============================================

-- Create quote_request_status enum
CREATE TYPE public.quote_request_status AS ENUM ('new', 'assigned', 'responded', 'booked', 'closed', 'rejected');

-- Create quote_response_status enum
CREATE TYPE public.quote_response_status AS ENUM ('sent', 'accepted', 'declined');

-- Create quote_requests table
CREATE TABLE public.quote_requests (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  customer_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  listing_id UUID REFERENCES public.service_listings(id) ON DELETE SET NULL,
  address TEXT NOT NULL,
  city TEXT,
  latitude NUMERIC,
  longitude NUMERIC,
  quote_type TEXT NOT NULL DEFAULT 'Residential',
  services JSONB NOT NULL DEFAULT '[]'::jsonb,
  preferred_datetime TIMESTAMP WITH TIME ZONE,
  notes TEXT,
  status public.quote_request_status NOT NULL DEFAULT 'new',
  assigned_provider_id UUID,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create quote_responses table
CREATE TABLE public.quote_responses (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  quote_request_id UUID NOT NULL REFERENCES public.quote_requests(id) ON DELETE CASCADE,
  provider_id UUID NOT NULL,
  price_amount NUMERIC NOT NULL,
  message TEXT,
  status public.quote_response_status NOT NULL DEFAULT 'sent',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create notifications table
CREATE TABLE public.notifications (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  title TEXT NOT NULL,
  body TEXT,
  link TEXT,
  read_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS on all tables
ALTER TABLE public.quote_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quote_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Updated_at triggers
CREATE TRIGGER update_quote_requests_updated_at
  BEFORE UPDATE ON public.quote_requests
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_quote_responses_updated_at
  BEFORE UPDATE ON public.quote_responses
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ========== QUOTE REQUESTS RLS ==========
-- Anyone (including guests) can create quote requests
CREATE POLICY "Anyone can create quote requests"
  ON public.quote_requests FOR INSERT
  WITH CHECK (true);

-- Customers can view their own quote requests
CREATE POLICY "Customers can view their own quote requests"
  ON public.quote_requests FOR SELECT
  USING (auth.uid() = customer_id);

-- Customers can update their own quote requests (e.g. cancel)
CREATE POLICY "Customers can update their own quote requests"
  ON public.quote_requests FOR UPDATE
  USING (auth.uid() = customer_id);

-- Assigned providers can view quote requests assigned to them
CREATE POLICY "Providers can view assigned quote requests"
  ON public.quote_requests FOR SELECT
  USING (auth.uid() = assigned_provider_id);

-- Providers can update assigned quote requests
CREATE POLICY "Providers can update assigned quote requests"
  ON public.quote_requests FOR UPDATE
  USING (auth.uid() = assigned_provider_id);

-- Cleaners can view new/unassigned quote requests
CREATE POLICY "Cleaners can view new quote requests"
  ON public.quote_requests FOR SELECT
  USING (
    status = 'new'::quote_request_status 
    AND has_role(auth.uid(), 'cleaner'::app_role)
  );

-- Admins can manage all quote requests
CREATE POLICY "Admins can manage all quote requests"
  ON public.quote_requests FOR ALL
  USING (has_role(auth.uid(), 'admin'::app_role));

-- ========== QUOTE RESPONSES RLS ==========
-- Providers can create responses
CREATE POLICY "Providers can create quote responses"
  ON public.quote_responses FOR INSERT
  WITH CHECK (auth.uid() = provider_id);

-- Providers can view their own responses
CREATE POLICY "Providers can view their own responses"
  ON public.quote_responses FOR SELECT
  USING (auth.uid() = provider_id);

-- Providers can update their own responses
CREATE POLICY "Providers can update their own responses"
  ON public.quote_responses FOR UPDATE
  USING (auth.uid() = provider_id);

-- Customers can view responses to their quote requests
CREATE POLICY "Customers can view responses to their quotes"
  ON public.quote_responses FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.quote_requests
      WHERE quote_requests.id = quote_responses.quote_request_id
        AND quote_requests.customer_id = auth.uid()
    )
  );

-- Customers can update response status (accept/decline)
CREATE POLICY "Customers can update response status"
  ON public.quote_responses FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.quote_requests
      WHERE quote_requests.id = quote_responses.quote_request_id
        AND quote_requests.customer_id = auth.uid()
    )
  );

-- Admins can manage all responses
CREATE POLICY "Admins can manage all quote responses"
  ON public.quote_responses FOR ALL
  USING (has_role(auth.uid(), 'admin'::app_role));

-- ========== NOTIFICATIONS RLS ==========
-- Users can view their own notifications
CREATE POLICY "Users can view their own notifications"
  ON public.notifications FOR SELECT
  USING (auth.uid() = user_id);

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update their own notifications"
  ON public.notifications FOR UPDATE
  USING (auth.uid() = user_id);

-- System/admins can create notifications for anyone
CREATE POLICY "Admins can manage all notifications"
  ON public.notifications FOR ALL
  USING (has_role(auth.uid(), 'admin'::app_role));

-- Allow authenticated users to insert notifications (for system use)
CREATE POLICY "Authenticated users can create notifications"
  ON public.notifications FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- Enable realtime for notifications
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;


-- ============================================
-- Migration: 20260221131131_0cfee7e1-4eef-45d9-906e-a9604bc46d08.sql
-- ============================================

-- Replace the overly permissive INSERT policy with a more specific one
-- Drop the old policy
DROP POLICY "Anyone can create quote requests" ON public.quote_requests;

-- Allow authenticated users to create quote requests (customer_id must match)
CREATE POLICY "Authenticated users can create quote requests"
  ON public.quote_requests FOR INSERT
  WITH CHECK (auth.uid() = customer_id);

-- Allow anonymous/guest submissions (customer_id is null)
CREATE POLICY "Guests can create quote requests"
  ON public.quote_requests FOR INSERT
  WITH CHECK (customer_id IS NULL);


-- ============================================
-- Migration: 20260221133237_17c97161-a6a9-476c-b2da-2e71728a23e3.sql
-- ============================================
INSERT INTO public.theme_settings (setting_key, setting_value, setting_type, category, label, description)
VALUES ('global_font', 'Inter', 'font', 'branding', 'Global Font', 'Set the primary font used across the entire website')
ON CONFLICT DO NOTHING;

-- ============================================
-- Migration: 20260221160907_464627bf-5080-4058-937e-056349538d88.sql
-- ============================================

-- Create conversations table
CREATE TABLE public.conversations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  customer_id UUID NOT NULL,
  provider_id UUID NOT NULL,
  last_message_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  last_message_preview TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(customer_id, provider_id)
);

-- Create messages table
CREATE TABLE public.messages (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL,
  text TEXT NOT NULL,
  attachment_url TEXT,
  read_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create index for fast message lookups
CREATE INDEX idx_messages_conversation_id ON public.messages(conversation_id, created_at DESC);
CREATE INDEX idx_conversations_customer_id ON public.conversations(customer_id);
CREATE INDEX idx_conversations_provider_id ON public.conversations(provider_id);
CREATE INDEX idx_messages_sender_id ON public.messages(sender_id);
CREATE INDEX idx_messages_unread ON public.messages(conversation_id, read_at) WHERE read_at IS NULL;

-- Enable RLS
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Conversations RLS: participants can view
CREATE POLICY "Participants can view their conversations"
  ON public.conversations FOR SELECT
  USING (auth.uid() = customer_id OR auth.uid() = provider_id);

CREATE POLICY "Authenticated users can create conversations"
  ON public.conversations FOR INSERT
  WITH CHECK (auth.uid() = customer_id OR auth.uid() = provider_id);

CREATE POLICY "Participants can update their conversations"
  ON public.conversations FOR UPDATE
  USING (auth.uid() = customer_id OR auth.uid() = provider_id);

-- Admin conversation access
CREATE POLICY "Admins can view all conversations"
  ON public.conversations FOR SELECT
  USING (has_role(auth.uid(), 'admin'::app_role));

-- Messages RLS: only conversation participants
CREATE POLICY "Participants can view messages"
  ON public.messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.conversations c
      WHERE c.id = conversation_id
      AND (c.customer_id = auth.uid() OR c.provider_id = auth.uid())
    )
  );

CREATE POLICY "Participants can send messages"
  ON public.messages FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id
    AND EXISTS (
      SELECT 1 FROM public.conversations c
      WHERE c.id = conversation_id
      AND (c.customer_id = auth.uid() OR c.provider_id = auth.uid())
    )
  );

CREATE POLICY "Participants can update messages (read receipts)"
  ON public.messages FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.conversations c
      WHERE c.id = conversation_id
      AND (c.customer_id = auth.uid() OR c.provider_id = auth.uid())
    )
  );

-- Admin message access (read-only)
CREATE POLICY "Admins can view all messages"
  ON public.messages FOR SELECT
  USING (has_role(auth.uid(), 'admin'::app_role));

-- Trigger to update conversation's last_message_at on new message
CREATE OR REPLACE FUNCTION public.update_conversation_last_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.conversations
  SET last_message_at = NEW.created_at,
      last_message_preview = LEFT(NEW.text, 100),
      updated_at = NEW.created_at
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE TRIGGER on_new_message
  AFTER INSERT ON public.messages
  FOR EACH ROW
  EXECUTE FUNCTION public.update_conversation_last_message();

-- Enable realtime for messages
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.conversations;


-- ============================================
-- Migration: 20260221162620_4924a96b-301b-4e3d-88c6-ac320986c85b.sql
-- ============================================
-- Create storage bucket for chat attachments
INSERT INTO storage.buckets (id, name, public)
VALUES ('chat-attachments', 'chat-attachments', true)
ON CONFLICT (id) DO NOTHING;

-- Allow authenticated users to upload files to their own folder
CREATE POLICY "Users can upload chat attachments"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'chat-attachments' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow anyone to view chat attachments (public bucket)
CREATE POLICY "Chat attachments are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'chat-attachments');

-- Allow users to delete their own attachments
CREATE POLICY "Users can delete own chat attachments"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'chat-attachments' AND auth.uid()::text = (storage.foldername(name))[1]);


-- ============================================
-- Migration: 20260221163951_f78e825c-5e4d-4fd8-8bae-f112a1d9cc55.sql
-- ============================================

-- Add missing columns to notifications table
ALTER TABLE public.notifications
  ADD COLUMN IF NOT EXISTS type text NOT NULL DEFAULT 'general',
  ADD COLUMN IF NOT EXISTS data jsonb DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS is_read boolean NOT NULL DEFAULT false;

-- Backfill is_read from existing read_at
UPDATE public.notifications SET is_read = true WHERE read_at IS NOT NULL;

-- Create index for fast unread queries
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread
  ON public.notifications (user_id, is_read)
  WHERE is_read = false;

-- Create index for ordering
CREATE INDEX IF NOT EXISTS idx_notifications_user_created
  ON public.notifications (user_id, created_at DESC);


-- ============================================
-- Migration: 20260221164621_8177ffe0-3481-4ee8-883d-374f944c0469.sql
-- ============================================

-- 1. Notify cleaner when a new booking is created
CREATE OR REPLACE FUNCTION public.notify_new_booking()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  customer_name text;
BEGIN
  -- Get customer name
  SELECT full_name INTO customer_name FROM public.profiles WHERE id = NEW.customer_id;

  -- Notify the cleaner (if assigned)
  IF NEW.cleaner_id IS NOT NULL THEN
    INSERT INTO public.notifications (user_id, type, title, body, link, data)
    VALUES (
      NEW.cleaner_id,
      'booking',
      'New Booking Request',
      'You have a new ' || NEW.service_type || ' booking from ' || COALESCE(customer_name, 'a customer') || ' on ' || NEW.scheduled_date::text,
      '/cleaner/bookings',
      jsonb_build_object('booking_id', NEW.id, 'service_type', NEW.service_type, 'scheduled_date', NEW.scheduled_date)
    );
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_new_booking
AFTER INSERT ON public.bookings
FOR EACH ROW
EXECUTE FUNCTION public.notify_new_booking();

-- 2. Notify customer when payment is verified or rejected
CREATE OR REPLACE FUNCTION public.notify_payment_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  -- Only fire when status changes to verified or rejected
  IF OLD.status = 'pending' AND NEW.status = 'verified' THEN
    INSERT INTO public.notifications (user_id, type, title, body, link, data)
    VALUES (
      NEW.customer_id,
      'payment',
      'Payment Verified ✅',
      'Your $' || NEW.amount::text || ' payment for ' || NEW.service_type || ' has been verified.',
      '/dashboard/bookings',
      jsonb_build_object('payment_id', NEW.id, 'amount', NEW.amount)
    );
  ELSIF OLD.status = 'pending' AND NEW.status = 'rejected' THEN
    INSERT INTO public.notifications (user_id, type, title, body, link, data)
    VALUES (
      NEW.customer_id,
      'payment',
      'Payment Rejected ❌',
      'Your $' || NEW.amount::text || ' payment for ' || NEW.service_type || ' was rejected.' || CASE WHEN NEW.rejection_reason IS NOT NULL THEN ' Reason: ' || NEW.rejection_reason ELSE '' END,
      '/dashboard/bookings',
      jsonb_build_object('payment_id', NEW.id, 'amount', NEW.amount, 'reason', NEW.rejection_reason)
    );
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_payment_status
AFTER UPDATE ON public.payment_records
FOR EACH ROW
EXECUTE FUNCTION public.notify_payment_status_change();

-- 3. Notify job poster when someone applies to their job
CREATE OR REPLACE FUNCTION public.notify_job_application()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  job_owner_id uuid;
  job_title text;
  applicant_name text;
BEGIN
  SELECT user_id, title INTO job_owner_id, job_title FROM public.jobs WHERE id = NEW.job_id;
  SELECT full_name INTO applicant_name FROM public.profiles WHERE id = NEW.applicant_id;

  IF job_owner_id IS NOT NULL THEN
    INSERT INTO public.notifications (user_id, type, title, body, link, data)
    VALUES (
      job_owner_id,
      'job_application',
      'New Application for "' || job_title || '"',
      COALESCE(applicant_name, 'Someone') || ' applied to your job posting.',
      '/jobs/' || NEW.job_id,
      jsonb_build_object('job_id', NEW.job_id, 'application_id', NEW.id, 'applicant_id', NEW.applicant_id)
    );
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_job_application
AFTER INSERT ON public.job_applications
FOR EACH ROW
EXECUTE FUNCTION public.notify_job_application();

-- 4. Notify customer when cleaner accepts/declines their booking
CREATE OR REPLACE FUNCTION public.notify_booking_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  IF OLD.status = 'pending' AND NEW.status = 'confirmed' THEN
    INSERT INTO public.notifications (user_id, type, title, body, link, data)
    VALUES (
      NEW.customer_id,
      'booking',
      'Booking Confirmed ✅',
      COALESCE(NEW.cleaner_name, 'Your cleaner') || ' has confirmed your ' || NEW.service_type || ' booking for ' || NEW.scheduled_date::text || '.',
      '/dashboard/upcoming',
      jsonb_build_object('booking_id', NEW.id)
    );
  ELSIF OLD.status = 'pending' AND NEW.status = 'cancelled' THEN
    INSERT INTO public.notifications (user_id, type, title, body, link, data)
    VALUES (
      NEW.customer_id,
      'booking',
      'Booking Declined',
      'Your ' || NEW.service_type || ' booking for ' || NEW.scheduled_date::text || ' was declined.',
      '/dashboard/bookings',
      jsonb_build_object('booking_id', NEW.id)
    );
  ELSIF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    INSERT INTO public.notifications (user_id, type, title, body, link, data)
    VALUES (
      NEW.customer_id,
      'booking',
      'Booking Completed 🎉',
      'Your ' || NEW.service_type || ' booking has been marked as completed. Leave a review!',
      '/dashboard/bookings',
      jsonb_build_object('booking_id', NEW.id)
    );
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_booking_status
AFTER UPDATE ON public.bookings
FOR EACH ROW
EXECUTE FUNCTION public.notify_booking_status_change();


-- ============================================
-- Migration: 20260221170353_cfab002a-27d7-4ee5-aa01-f91e7c8ffdf7.sql
-- ============================================

-- Create storage bucket for cleaner profile images
INSERT INTO storage.buckets (id, name, public) VALUES ('cleaner-profiles', 'cleaner-profiles', true);

-- Allow cleaners to upload their own profile image
CREATE POLICY "Cleaners can upload profile images"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'cleaner-profiles' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow cleaners to update their own profile image
CREATE POLICY "Cleaners can update profile images"
ON storage.objects FOR UPDATE
USING (bucket_id = 'cleaner-profiles' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow cleaners to delete their own profile image
CREATE POLICY "Cleaners can delete profile images"
ON storage.objects FOR DELETE
USING (bucket_id = 'cleaner-profiles' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Anyone can view cleaner profile images
CREATE POLICY "Anyone can view cleaner profile images"
ON storage.objects FOR SELECT
USING (bucket_id = 'cleaner-profiles');


-- ============================================
-- Migration: 20260221170853_0a287ed9-87c1-4e37-9639-778dda214865.sql
-- ============================================

-- Create storage bucket for user profile avatars
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);

-- Users can upload their own avatar
CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Users can update their own avatar
CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Users can delete their own avatar
CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE
USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Anyone can view avatars
CREATE POLICY "Anyone can view avatars"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');


-- ============================================
-- Migration: 20260221173827_95611552-5fce-40ec-9f06-be7cc79546c7.sql
-- ============================================
-- Allow authenticated users to view all profiles (names/avatars are not sensitive)
CREATE POLICY "Authenticated users can view all profiles"
ON public.profiles
FOR SELECT
USING (auth.uid() IS NOT NULL);

-- ============================================
-- Migration: 20260221184810_1a377685-94ee-42e8-bdfb-c1b7e7caa429.sql
-- ============================================

-- Create invoices table
CREATE TABLE public.invoices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_number text NOT NULL UNIQUE,
  booking_id uuid REFERENCES public.bookings(id),
  customer_id uuid NOT NULL,
  cleaner_id uuid,
  amount numeric NOT NULL,
  commission_amount numeric NOT NULL DEFAULT 0,
  net_amount numeric NOT NULL DEFAULT 0,
  service_type text NOT NULL,
  service_date date NOT NULL,
  status text NOT NULL DEFAULT 'issued',
  notes text,
  due_date date,
  paid_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  created_by uuid
);

-- Sequence for invoice numbering
CREATE SEQUENCE public.invoice_number_seq START 1;

-- Function to generate invoice number
CREATE OR REPLACE FUNCTION public.generate_invoice_number()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
  IF NEW.invoice_number IS NULL OR NEW.invoice_number = '' THEN
    NEW.invoice_number := 'INV-' || LPAD(nextval('public.invoice_number_seq')::text, 5, '0');
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER set_invoice_number
  BEFORE INSERT ON public.invoices
  FOR EACH ROW
  EXECUTE FUNCTION public.generate_invoice_number();

-- Auto-generate invoice on booking completion
CREATE OR REPLACE FUNCTION public.auto_generate_invoice_on_completion()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  commission_rate numeric;
  commission numeric;
  net numeric;
BEGIN
  IF OLD.status != 'completed' AND NEW.status = 'completed' THEN
    -- Check if invoice already exists for this booking
    IF EXISTS (SELECT 1 FROM public.invoices WHERE booking_id = NEW.id) THEN
      RETURN NEW;
    END IF;

    SELECT platform_commission_rate INTO commission_rate FROM public.platform_settings LIMIT 1;
    commission_rate := COALESCE(commission_rate, 10);
    commission := ROUND(NEW.service_price * commission_rate / 100, 2);
    net := NEW.service_price - commission;

    INSERT INTO public.invoices (
      booking_id, customer_id, cleaner_id, amount, commission_amount, net_amount,
      service_type, service_date, status, due_date
    ) VALUES (
      NEW.id, NEW.customer_id, NEW.cleaner_id, NEW.service_price, commission, net,
      NEW.service_type, NEW.scheduled_date, 'paid', NEW.scheduled_date
    );
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER generate_invoice_on_booking_complete
  AFTER UPDATE ON public.bookings
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_generate_invoice_on_completion();

-- Auto-generate invoice on payment verification
CREATE OR REPLACE FUNCTION public.auto_generate_invoice_on_payment_verified()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  commission_rate numeric;
  commission numeric;
  net numeric;
BEGIN
  IF OLD.status = 'pending' AND NEW.status = 'verified' THEN
    -- Check if invoice already exists for this booking
    IF NEW.booking_id IS NOT NULL AND EXISTS (SELECT 1 FROM public.invoices WHERE booking_id = NEW.booking_id) THEN
      RETURN NEW;
    END IF;

    SELECT platform_commission_rate INTO commission_rate FROM public.platform_settings LIMIT 1;
    commission_rate := COALESCE(commission_rate, 10);
    commission := ROUND(NEW.amount * commission_rate / 100, 2);
    net := NEW.amount - commission;

    INSERT INTO public.invoices (
      booking_id, customer_id, cleaner_id, amount, commission_amount, net_amount,
      service_type, service_date, status, due_date, paid_at
    ) VALUES (
      NEW.booking_id, NEW.customer_id, NEW.cleaner_id, NEW.amount, commission, net,
      NEW.service_type, NEW.booking_date, 'paid', NEW.booking_date, now()
    );
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER generate_invoice_on_payment_verified
  AFTER UPDATE ON public.payment_records
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_generate_invoice_on_payment_verified();

-- Updated at trigger
CREATE TRIGGER update_invoices_updated_at
  BEFORE UPDATE ON public.invoices
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Enable RLS
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;

-- RLS policies
CREATE POLICY "Customers can view their own invoices"
  ON public.invoices FOR SELECT
  USING (auth.uid() = customer_id);

CREATE POLICY "Cleaners can view their invoices"
  ON public.invoices FOR SELECT
  USING (auth.uid() = cleaner_id);

CREATE POLICY "Admins can manage all invoices"
  ON public.invoices FOR ALL
  USING (has_role(auth.uid(), 'admin'::app_role));

-- Index for fast lookups
CREATE INDEX idx_invoices_customer_id ON public.invoices(customer_id);
CREATE INDEX idx_invoices_cleaner_id ON public.invoices(cleaner_id);
CREATE INDEX idx_invoices_booking_id ON public.invoices(booking_id);


-- ============================================
-- Migration: 20260223060858_1dc4fe1f-32f6-4e15-960a-0ff98c766903.sql
-- ============================================

-- Wallet table: one wallet per user
CREATE TABLE public.wallets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  balance numeric NOT NULL DEFAULT 0 CHECK (balance >= 0),
  currency text NOT NULL DEFAULT 'CAD',
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);

-- Wallet transactions log
CREATE TABLE public.wallet_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id uuid NOT NULL REFERENCES public.wallets(id) ON DELETE CASCADE,
  user_id uuid NOT NULL,
  type text NOT NULL CHECK (type IN ('top_up', 'earning', 'payment', 'withdrawal', 'refund', 'admin_credit', 'admin_debit')),
  amount numeric NOT NULL,
  balance_after numeric NOT NULL,
  description text,
  reference_id text,
  status text NOT NULL DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed', 'cancelled')),
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone NOT NULL DEFAULT now()
);

-- Wallet top-up requests (for bank transfer verification)
CREATE TABLE public.wallet_topup_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  wallet_id uuid NOT NULL REFERENCES public.wallets(id) ON DELETE CASCADE,
  amount numeric NOT NULL CHECK (amount > 0),
  payment_method text NOT NULL DEFAULT 'bank_transfer',
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'verified', 'rejected')),
  rejection_reason text,
  verified_by uuid,
  verified_at timestamp with time zone,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_topup_requests ENABLE ROW LEVEL SECURITY;

-- Wallets RLS
CREATE POLICY "Users can view their own wallet" ON public.wallets FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own wallet" ON public.wallets FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Admins can view all wallets" ON public.wallets FOR SELECT USING (has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can update all wallets" ON public.wallets FOR UPDATE USING (has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can insert wallets" ON public.wallets FOR INSERT WITH CHECK (has_role(auth.uid(), 'admin'));

-- Wallet Transactions RLS
CREATE POLICY "Users can view their own transactions" ON public.wallet_transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Admins can view all transactions" ON public.wallet_transactions FOR SELECT USING (has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can insert transactions" ON public.wallet_transactions FOR INSERT WITH CHECK (has_role(auth.uid(), 'admin'));

-- Wallet top-up requests RLS
CREATE POLICY "Users can view their own topup requests" ON public.wallet_topup_requests FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create topup requests" ON public.wallet_topup_requests FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Admins can view all topup requests" ON public.wallet_topup_requests FOR SELECT USING (has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can update topup requests" ON public.wallet_topup_requests FOR UPDATE USING (has_role(auth.uid(), 'admin'));

-- Auto-create wallet for new users via trigger
CREATE OR REPLACE FUNCTION public.create_wallet_for_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.wallets (user_id) VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_profile_created_create_wallet
  AFTER INSERT ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.create_wallet_for_new_user();

-- Function to credit wallet (used by admin and system)
CREATE OR REPLACE FUNCTION public.credit_wallet(
  p_user_id uuid,
  p_amount numeric,
  p_type text,
  p_description text DEFAULT NULL,
  p_reference_id text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_wallet_id uuid;
  v_new_balance numeric;
  v_txn_id uuid;
BEGIN
  -- Get or create wallet
  SELECT id INTO v_wallet_id FROM public.wallets WHERE user_id = p_user_id;
  IF v_wallet_id IS NULL THEN
    INSERT INTO public.wallets (user_id) VALUES (p_user_id) RETURNING id INTO v_wallet_id;
  END IF;

  -- Update balance
  UPDATE public.wallets SET balance = balance + p_amount, updated_at = now()
  WHERE id = v_wallet_id
  RETURNING balance INTO v_new_balance;

  -- Record transaction
  INSERT INTO public.wallet_transactions (wallet_id, user_id, type, amount, balance_after, description, reference_id)
  VALUES (v_wallet_id, p_user_id, p_type, p_amount, v_new_balance, p_description, p_reference_id)
  RETURNING id INTO v_txn_id;

  RETURN v_txn_id;
END;
$$;

-- Function to debit wallet
CREATE OR REPLACE FUNCTION public.debit_wallet(
  p_user_id uuid,
  p_amount numeric,
  p_type text,
  p_description text DEFAULT NULL,
  p_reference_id text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_wallet_id uuid;
  v_current_balance numeric;
  v_new_balance numeric;
  v_txn_id uuid;
BEGIN
  SELECT id, balance INTO v_wallet_id, v_current_balance FROM public.wallets WHERE user_id = p_user_id;
  IF v_wallet_id IS NULL THEN
    RAISE EXCEPTION 'Wallet not found for user %', p_user_id;
  END IF;

  IF v_current_balance < p_amount THEN
    RAISE EXCEPTION 'Insufficient wallet balance';
  END IF;

  UPDATE public.wallets SET balance = balance - p_amount, updated_at = now()
  WHERE id = v_wallet_id
  RETURNING balance INTO v_new_balance;

  INSERT INTO public.wallet_transactions (wallet_id, user_id, type, amount, balance_after, description, reference_id)
  VALUES (v_wallet_id, p_user_id, p_type, -p_amount, v_new_balance, p_description, p_reference_id)
  RETURNING id INTO v_txn_id;

  RETURN v_txn_id;
END;
$$;

-- Indexes
CREATE INDEX idx_wallet_transactions_wallet_id ON public.wallet_transactions(wallet_id);
CREATE INDEX idx_wallet_transactions_user_id ON public.wallet_transactions(user_id);
CREATE INDEX idx_wallet_transactions_created_at ON public.wallet_transactions(created_at DESC);
CREATE INDEX idx_wallet_topup_requests_user_id ON public.wallet_topup_requests(user_id);
CREATE INDEX idx_wallet_topup_requests_status ON public.wallet_topup_requests(status);

-- Updated_at triggers
CREATE TRIGGER update_wallets_updated_at BEFORE UPDATE ON public.wallets FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_topup_requests_updated_at BEFORE UPDATE ON public.wallet_topup_requests FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


-- ============================================
-- Migration: 20260223072701_5b002bb7-901e-436d-a3de-836b576086bb.sql
-- ============================================

-- Add proof_image_url column to wallet_topup_requests
ALTER TABLE public.wallet_topup_requests
ADD COLUMN proof_image_url text;

-- Create storage bucket for payment proofs
INSERT INTO storage.buckets (id, name, public)
VALUES ('payment-proofs', 'payment-proofs', true)
ON CONFLICT (id) DO NOTHING;

-- Allow authenticated users to upload their own payment proofs
CREATE POLICY "Users can upload their own payment proofs"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'payment-proofs' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow authenticated users to view payment proofs
CREATE POLICY "Anyone can view payment proofs"
ON storage.objects FOR SELECT
USING (bucket_id = 'payment-proofs');

-- Allow users to update/delete their own payment proofs
CREATE POLICY "Users can update their own payment proofs"
ON storage.objects FOR UPDATE
USING (bucket_id = 'payment-proofs' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete their own payment proofs"
ON storage.objects FOR DELETE
USING (bucket_id = 'payment-proofs' AND auth.uid()::text = (storage.foldername(name))[1]);


-- ============================================
-- Migration: 20260226162457_8026ccb2-f1cd-49a9-be59-011c71490de7.sql
-- ============================================
CREATE POLICY "Anyone can read platform settings"
ON public.platform_settings
FOR SELECT
USING (true);

-- ============================================
-- Migration: 20260306181201_45de939c-6cb5-46d6-9bf2-e87da8df27f2.sql
-- ============================================

-- Push subscriptions table
CREATE TABLE public.push_subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  endpoint text NOT NULL,
  p256dh text NOT NULL,
  auth text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(user_id, endpoint)
);

ALTER TABLE public.push_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert their own push subscriptions"
  ON public.push_subscriptions FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own push subscriptions"
  ON public.push_subscriptions FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own push subscriptions"
  ON public.push_subscriptions FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- Trigger to send push notification via edge function when notification is inserted
CREATE OR REPLACE FUNCTION public.send_push_on_notification()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  PERFORM net.http_post(
    url := 'https://seybtckozzdcjgdgcsdq.supabase.co/functions/v1/send-push-notification',
    headers := '{"Content-Type": "application/json"}'::jsonb,
    body := jsonb_build_object(
      'user_id', NEW.user_id,
      'title', NEW.title,
      'body', COALESCE(NEW.body, ''),
      'url', COALESCE(NEW.link, '/'),
      'tag', NEW.type
    )
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_notification_send_push
  AFTER INSERT ON public.notifications
  FOR EACH ROW
  EXECUTE FUNCTION public.send_push_on_notification();


-- ============================================
-- Migration: 20260328060845_d00c0715-9221-4b91-b057-0a724f1882cf.sql
-- ============================================
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- ============================================
-- Migration: 20260331150127_87592f3f-e2cf-482f-ac1b-4ef18a35ec93.sql
-- ============================================

-- Create provider_verification_documents table
CREATE TABLE public.provider_verification_documents (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  document_type TEXT NOT NULL,
  file_url TEXT,
  insurance_expiry_date DATE,
  status TEXT NOT NULL DEFAULT 'pending',
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  reviewed_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.provider_verification_documents ENABLE ROW LEVEL SECURITY;

-- Providers can insert their own docs
CREATE POLICY "Providers can insert their own documents"
ON public.provider_verification_documents FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Providers can view their own docs
CREATE POLICY "Providers can view their own documents"
ON public.provider_verification_documents FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Providers can update their own pending docs
CREATE POLICY "Providers can update their own pending documents"
ON public.provider_verification_documents FOR UPDATE
TO authenticated
USING (auth.uid() = user_id AND status = 'pending');

-- Admins can view all docs
CREATE POLICY "Admins can view all verification documents"
ON public.provider_verification_documents FOR SELECT
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- Admins can update all docs
CREATE POLICY "Admins can update all verification documents"
ON public.provider_verification_documents FOR UPDATE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- Admins can delete docs
CREATE POLICY "Admins can delete verification documents"
ON public.provider_verification_documents FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- Create private storage bucket
INSERT INTO storage.buckets (id, name, public) VALUES ('verification-documents', 'verification-documents', false);

-- Storage RLS: owners can upload
CREATE POLICY "Providers can upload verification documents"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'verification-documents' AND (storage.foldername(name))[1] = auth.uid()::text);

-- Owners can view their own files
CREATE POLICY "Providers can view their verification documents"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'verification-documents' AND (storage.foldername(name))[1] = auth.uid()::text);

-- Admins can view all files
CREATE POLICY "Admins can view all verification documents"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'verification-documents' AND public.has_role(auth.uid(), 'admin'));

-- Updated_at trigger
CREATE TRIGGER update_verification_documents_updated_at
  BEFORE UPDATE ON public.provider_verification_documents
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


-- ============================================
-- Migration: 20260331175817_72ab87bf-39b6-4768-90f5-6e8323cc6e67.sql
-- ============================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.provider_verification_documents;

-- ============================================
-- Migration: 20260331181746_031dc56a-c000-4dd7-9d48-12876edea271.sql
-- ============================================

DROP POLICY IF EXISTS "Providers can update their own pending documents" ON public.provider_verification_documents;

CREATE POLICY "Providers can update their own documents"
ON public.provider_verification_documents
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id AND status IN ('pending', 'rejected'))
WITH CHECK (auth.uid() = user_id);


-- ============================================
-- Migration: 20260331184023_89990228-d381-4db1-bb17-6cefe5c6378d.sql
-- ============================================
UPDATE provider_verification_documents SET status = 'pending', reviewed_at = NULL, notes = NULL WHERE id IN ('a1e6a373-2139-4353-8149-e7b268bc31ca', '0a5eff4e-6f1e-4f08-8d87-52ecc9b82a7e');

-- ============================================
-- Migration: 20260409024500_add_payment_gateway_columns.sql
-- ============================================
-- Add payment gateway configuration columns to platform_settings
ALTER TABLE platform_settings
  ADD COLUMN IF NOT EXISTS stripe_enabled BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS stripe_mode TEXT DEFAULT 'test',
  ADD COLUMN IF NOT EXISTS stripe_publishable_key TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS stripe_webhook_secret TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS cash_enabled BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS cash_instructions TEXT DEFAULT 'Please pay the cleaner in cash after the service is completed.',
  ADD COLUMN IF NOT EXISTS cash_confirmation_required BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS bank_enabled BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS bank_name TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS bank_account_name TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS bank_account_number TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS bank_routing_number TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS bank_swift_code TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS bank_instructions TEXT DEFAULT 'Please transfer the payment before your scheduled booking date.',
  ADD COLUMN IF NOT EXISTS auto_payouts_enabled BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS payout_schedule TEXT DEFAULT 'weekly',
  ADD COLUMN IF NOT EXISTS minimum_payout_amount NUMERIC DEFAULT 50,
  ADD COLUMN IF NOT EXISTS payout_delay_days INTEGER DEFAULT 7,
  ADD COLUMN IF NOT EXISTS capture_method TEXT DEFAULT 'automatic',
  ADD COLUMN IF NOT EXISTS allow_refunds BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS refund_window_days INTEGER DEFAULT 14,
  ADD COLUMN IF NOT EXISTS pass_processing_fee_to_customer BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS processing_fee_percentage NUMERIC DEFAULT 2.9;


