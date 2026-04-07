import { useLocation } from "react-router-dom";
import {
  LayoutDashboard,
  CalendarDays,
  History,
  MapPin,
  User,
  Settings,
  LogOut,
  Crown,
  Briefcase,
  FileQuestion,
  MessageSquare,
  FileText,
  Wallet,
} from "lucide-react";
import { NavLink } from "@/components/NavLink";
import { useAuth } from "@/contexts/AuthContext";
import { useUnreadMessages } from "@/hooks/useUnreadMessages";
import { Badge } from "@/components/ui/badge";
import {
  Sidebar,
  SidebarContent,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarFooter,
  useSidebar,
} from "@/components/ui/sidebar";
import logo from "@/assets/logo-new.png";

const mainMenuItems = [
  { title: "Dashboard", url: "/dashboard", icon: LayoutDashboard },
  { title: "Profile", url: "/dashboard/profile", icon: User },
];

const serviceMenuItems = [
  { title: "My Jobs", url: "/dashboard/my-jobs", icon: Briefcase },
  { title: "My Quotes", url: "/dashboard/quotes", icon: FileQuestion },
  { title: "Upcoming", url: "/dashboard/upcoming", icon: CalendarDays },
  { title: "Booking History", url: "/dashboard/history", icon: History },
  { title: "Messages", url: "/dashboard/messages", icon: MessageSquare },
];

const financeMenuItems = [
  { title: "Invoices", url: "/dashboard/invoices", icon: FileText },
  { title: "Wallet", url: "/dashboard/wallet", icon: Wallet },
  { title: "Membership", url: "/dashboard/subscription", icon: Crown },
];

const settingsMenuItems = [
  { title: "Addresses", url: "/dashboard/addresses", icon: MapPin },
  { title: "Settings", url: "/dashboard/settings", icon: Settings },
];

const DashboardSidebar = () => {
  const { state } = useSidebar();
  const collapsed = state === "collapsed";
  const location = useLocation();
  const { signOut } = useAuth();
  const unreadCount = useUnreadMessages();

  const isActive = (path: string) => {
    if (path === "/dashboard") {
      return location.pathname === "/dashboard";
    }
    return location.pathname.startsWith(path);
  };

  const renderMenuItems = (items: typeof mainMenuItems) => (
    <SidebarMenu>
      {items.map((item) => {
        const active = isActive(item.url);
        return (
          <SidebarMenuItem key={item.title}>
            <SidebarMenuButton
              asChild
              isActive={active}
              tooltip={item.title}
              className={`
                group/item rounded-lg px-3 py-2 transition-all duration-150 text-sm font-normal
                ${active
                  ? "bg-primary text-primary-foreground hover:bg-primary/90 hover:text-primary-foreground"
                  : "text-foreground/70 hover:bg-muted hover:text-foreground"
                }
              `}
            >
              <NavLink
                to={item.url}
                end={item.url === "/dashboard"}
                className="flex items-center gap-3"
                activeClassName=""
              >
                <item.icon className={`h-[18px] w-[18px] shrink-0 ${active ? "text-primary-foreground" : "text-foreground/50"}`} />
                <span className="truncate">{item.title}</span>
                {item.title === "Messages" && unreadCount > 0 && (
                  <Badge variant={active ? "secondary" : "destructive"} className="ml-auto h-5 min-w-5 px-1.5 text-[10px] justify-center rounded-full">
                    {unreadCount > 99 ? "99+" : unreadCount}
                  </Badge>
                )}
              </NavLink>
            </SidebarMenuButton>
          </SidebarMenuItem>
        );
      })}
    </SidebarMenu>
  );

  return (
    <Sidebar
      collapsible="icon"
      className="border-r border-border/40 [&_[data-sidebar=sidebar]]:!bg-card"
      style={{
        "--sidebar-accent": "var(--primary)",
        "--sidebar-accent-foreground": "var(--primary-foreground)",
      } as React.CSSProperties}
    >
      <SidebarContent className="px-3 pt-5 pb-2" style={{ background: "transparent" }}>
        {/* Logo */}
        {!collapsed && (
          <div className="px-3 mb-6 flex items-center gap-2.5">
            <img src={logo} alt="Logo" className="h-8 w-auto rounded" />
            <span className="font-heading font-semibold text-foreground text-sm tracking-tight">
              The Cleaning Network
            </span>
          </div>
        )}

        <SidebarGroup>
          <SidebarGroupLabel className="text-[10px] font-semibold text-foreground/40 uppercase tracking-[0.1em] px-3 mb-1">
            Home
          </SidebarGroupLabel>
          <SidebarGroupContent>{renderMenuItems(mainMenuItems)}</SidebarGroupContent>
        </SidebarGroup>

        <SidebarGroup className="mt-4">
          <SidebarGroupLabel className="text-[10px] font-semibold text-foreground/40 uppercase tracking-[0.1em] px-3 mb-1">
            Services
          </SidebarGroupLabel>
          <SidebarGroupContent>{renderMenuItems(serviceMenuItems)}</SidebarGroupContent>
        </SidebarGroup>

        <SidebarGroup className="mt-4">
          <SidebarGroupLabel className="text-[10px] font-semibold text-foreground/40 uppercase tracking-[0.1em] px-3 mb-1">
            Finance
          </SidebarGroupLabel>
          <SidebarGroupContent>{renderMenuItems(financeMenuItems)}</SidebarGroupContent>
        </SidebarGroup>

        <SidebarGroup className="mt-4">
          <SidebarGroupLabel className="text-[10px] font-semibold text-foreground/40 uppercase tracking-[0.1em] px-3 mb-1">
            Account
          </SidebarGroupLabel>
          <SidebarGroupContent>{renderMenuItems(settingsMenuItems)}</SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>

      <SidebarFooter
        className="p-3 border-t border-border/30"
        style={{ background: "transparent" }}
      >
        <button
          onClick={signOut}
          className="flex items-center gap-3 w-full px-3 py-2 rounded-lg text-foreground/50 hover:text-destructive hover:bg-destructive/8 transition-colors text-sm"
        >
          <LogOut className="h-[18px] w-[18px] shrink-0" />
          {!collapsed && <span>Sign Out</span>}
        </button>
      </SidebarFooter>
    </Sidebar>
  );
};

export default DashboardSidebar;
