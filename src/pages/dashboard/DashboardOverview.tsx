import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { format } from "date-fns";
import {
  CalendarDays,
  Clock,
  MapPin,
  Plus,
  History,
  CheckCircle,
  AlertCircle,
  ArrowUpRight,
  TrendingUp,
} from "lucide-react";
import { useAuth } from "@/contexts/AuthContext";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";

interface Booking {
  id: string;
  service_type: string;
  service_price: number;
  scheduled_date: string;
  scheduled_time: string;
  status: string;
  cleaner_name: string | null;
  addresses: {
    street_address: string;
    city: string;
  } | null;
}

interface Profile {
  full_name: string | null;
  email: string | null;
}

const DashboardOverview = () => {
  const { user } = useAuth();
  const [profile, setProfile] = useState<Profile | null>(null);
  const [upcomingBookings, setUpcomingBookings] = useState<Booking[]>([]);
  const [recentBookings, setRecentBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      if (!user) return;

      try {
        const { data: profileData } = await supabase
          .from("profiles")
          .select("full_name, email")
          .eq("id", user.id)
          .single();
        
        setProfile(profileData);

        const today = new Date().toISOString().split("T")[0];
        const { data: upcoming } = await supabase
          .from("bookings")
          .select(`
            id, service_type, service_price, scheduled_date, scheduled_time, status, cleaner_name,
            addresses ( street_address, city )
          `)
          .eq("customer_id", user.id)
          .gte("scheduled_date", today)
          .in("status", ["pending", "confirmed"])
          .order("scheduled_date", { ascending: true })
          .limit(3);

        setUpcomingBookings(upcoming || []);

        const { data: recent } = await supabase
          .from("bookings")
          .select(`
            id, service_type, service_price, scheduled_date, scheduled_time, status, cleaner_name,
            addresses ( street_address, city )
          `)
          .eq("customer_id", user.id)
          .eq("status", "completed")
          .order("scheduled_date", { ascending: false })
          .limit(3);

        setRecentBookings(recent || []);
      } catch (error) {
        console.error("Error fetching dashboard data:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [user]);

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "confirmed":
        return <Badge variant="success" className="gap-1"><CheckCircle className="h-3 w-3" /> Confirmed</Badge>;
      case "pending":
        return <Badge variant="warning" className="gap-1"><Clock className="h-3 w-3" /> Pending</Badge>;
      case "completed":
        return <Badge variant="secondary" className="gap-1"><CheckCircle className="h-3 w-3" /> Completed</Badge>;
      case "cancelled":
        return <Badge variant="destructive" className="gap-1"><AlertCircle className="h-3 w-3" /> Cancelled</Badge>;
      default:
        return <Badge variant="outline">{status}</Badge>;
    }
  };

  if (loading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-12 w-72" />
        <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
          {[1, 2, 3, 4].map((i) => (
            <Skeleton key={i} className="h-[120px] rounded-xl" />
          ))}
        </div>
        <Skeleton className="h-64 rounded-xl" />
      </div>
    );
  }

  const statCards = [
    {
      label: "Upcoming",
      value: upcomingBookings.length,
      subtitle: "Scheduled cleanings",
      icon: CalendarDays,
      iconBg: "bg-primary/10",
      iconColor: "text-primary",
    },
    {
      label: "Completed",
      value: recentBookings.length,
      subtitle: "Total cleanings done",
      icon: CheckCircle,
      iconBg: "bg-secondary/15",
      iconColor: "text-secondary",
    },
    {
      label: "Next Cleaning",
      value: upcomingBookings.length > 0
        ? format(new Date(upcomingBookings[0].scheduled_date), "MMM d")
        : "—",
      subtitle: upcomingBookings.length > 0
        ? upcomingBookings[0].scheduled_time
        : "No upcoming bookings",
      icon: Clock,
      iconBg: "bg-[hsl(var(--warning)/0.12)]",
      iconColor: "text-[hsl(var(--warning))]",
    },
    {
      label: "Addresses",
      value: 0,
      subtitle: "Saved locations",
      icon: MapPin,
      iconBg: "bg-[hsl(var(--info)/0.12)]",
      iconColor: "text-[hsl(var(--info))]",
    },
  ];

  return (
    <div className="space-y-6">
      {/* Welcome Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="font-heading text-2xl md:text-3xl font-bold text-foreground tracking-tight">
            Welcome back, {profile?.full_name?.split(" ")[0] || "there"}!
          </h1>
          <p className="text-sm text-muted-foreground mt-1">
            Here's an overview of your cleaning services
          </p>
        </div>
        <Button asChild variant="cta" className="shadow-md">
          <Link to="/search">
            <Plus className="h-4 w-4 mr-2" />
            Book a Cleaning
          </Link>
        </Button>
      </div>

      {/* Stat Cards - MaterialM style */}
      <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {statCards.map((stat) => (
          <Card key={stat.label} className="shadow-card hover:shadow-card-hover transition-shadow duration-300 border-0">
            <CardContent className="p-5">
              <div className="flex items-start justify-between">
                <div className="space-y-2">
                  <p className="text-sm font-medium text-muted-foreground">{stat.label}</p>
                  <p className="text-3xl font-bold text-foreground tracking-tight">{stat.value}</p>
                  <p className="text-xs text-muted-foreground">{stat.subtitle}</p>
                </div>
                <div className={`rounded-xl p-3 ${stat.iconBg}`}>
                  <stat.icon className={`h-5 w-5 ${stat.iconColor}`} />
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Upcoming Bookings */}
      <Card className="shadow-card border-0">
        <CardHeader className="flex flex-row items-center justify-between pb-4">
          <div>
            <CardTitle className="text-lg font-semibold">Upcoming Cleanings</CardTitle>
            <CardDescription className="text-xs mt-0.5">Your scheduled cleaning appointments</CardDescription>
          </div>
          <Button variant="outline" size="sm" asChild className="gap-1.5 text-xs">
            <Link to="/dashboard/upcoming">
              View All
              <ArrowUpRight className="h-3.5 w-3.5" />
            </Link>
          </Button>
        </CardHeader>
        <CardContent>
          {upcomingBookings.length > 0 ? (
            <div className="space-y-3">
              {upcomingBookings.map((booking) => (
                <div
                  key={booking.id}
                  className="flex flex-col md:flex-row md:items-center justify-between gap-3 p-4 rounded-xl bg-muted/50 hover:bg-muted transition-colors"
                >
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1.5">
                      <h4 className="font-semibold text-sm">{booking.service_type}</h4>
                      {getStatusBadge(booking.status)}
                    </div>
                    <div className="flex flex-wrap gap-4 text-xs text-muted-foreground">
                      <span className="flex items-center gap-1">
                        <CalendarDays className="h-3.5 w-3.5" />
                        {format(new Date(booking.scheduled_date), "MMM d, yyyy")}
                      </span>
                      <span className="flex items-center gap-1">
                        <Clock className="h-3.5 w-3.5" />
                        {booking.scheduled_time}
                      </span>
                      {booking.addresses && (
                        <span className="flex items-center gap-1">
                          <MapPin className="h-3.5 w-3.5" />
                          {booking.addresses.city}
                        </span>
                      )}
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="font-bold text-primary text-sm">${booking.service_price}</div>
                    {booking.cleaner_name && (
                      <div className="text-xs text-muted-foreground">{booking.cleaner_name}</div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-10">
              <div className="rounded-2xl bg-muted/60 w-16 h-16 flex items-center justify-center mx-auto mb-4">
                <CalendarDays className="h-7 w-7 text-muted-foreground" />
              </div>
              <h3 className="font-semibold text-sm mb-1">No upcoming cleanings</h3>
              <p className="text-xs text-muted-foreground mb-5">
                Book your first cleaning to get started
              </p>
              <Button asChild size="sm">
                <Link to="/search">Find a Cleaner</Link>
              </Button>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Recent History */}
      <Card className="shadow-card border-0">
        <CardHeader className="flex flex-row items-center justify-between pb-4">
          <div>
            <CardTitle className="text-lg font-semibold">Recent History</CardTitle>
            <CardDescription className="text-xs mt-0.5">Your past cleaning services</CardDescription>
          </div>
          <Button variant="outline" size="sm" asChild className="gap-1.5 text-xs">
            <Link to="/dashboard/history">
              View All
              <ArrowUpRight className="h-3.5 w-3.5" />
            </Link>
          </Button>
        </CardHeader>
        <CardContent>
          {recentBookings.length > 0 ? (
            <div className="space-y-3">
              {recentBookings.map((booking) => (
                <div
                  key={booking.id}
                  className="flex flex-col md:flex-row md:items-center justify-between gap-3 p-4 rounded-xl bg-muted/50 hover:bg-muted transition-colors"
                >
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1.5">
                      <h4 className="font-semibold text-sm">{booking.service_type}</h4>
                      {getStatusBadge(booking.status)}
                    </div>
                    <div className="flex flex-wrap gap-4 text-xs text-muted-foreground">
                      <span className="flex items-center gap-1">
                        <CalendarDays className="h-3.5 w-3.5" />
                        {format(new Date(booking.scheduled_date), "MMM d, yyyy")}
                      </span>
                      {booking.cleaner_name && (
                        <span>{booking.cleaner_name}</span>
                      )}
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="font-bold text-sm">${booking.service_price}</div>
                    <Button variant="link" size="sm" className="p-0 h-auto text-xs text-primary">
                      Book Again
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-10">
              <div className="rounded-2xl bg-muted/60 w-16 h-16 flex items-center justify-center mx-auto mb-4">
                <History className="h-7 w-7 text-muted-foreground" />
              </div>
              <h3 className="font-semibold text-sm mb-1">No cleaning history yet</h3>
              <p className="text-xs text-muted-foreground">
                Your completed cleanings will appear here
              </p>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
};

export default DashboardOverview;
