import type { Metadata, Viewport } from "next";
import "./globals.css";
export const metadata: Metadata = {
  title: "أهليّة | المنصة الأكاديمية",
  description: "منصة تعليمية وتواصل أكاديمي لطلاب وأساتذة جامعة أمدرمان الأهلية",
  manifest: "/manifest.json",
  applicationName: "أهليّة",
};
export const viewport: Viewport = { themeColor: "#1a5276", width: "device-width", initialScale: 1 };
export default function RootLayout({ children }: Readonly<{children: React.ReactNode}>) {
  return <html lang="ar" dir="rtl"><body>{children}<script dangerouslySetInnerHTML={{__html:`if ('serviceWorker' in navigator) window.addEventListener('load',()=>navigator.serviceWorker.register('/sw.js').catch(()=>{}));`}} /></body></html>;
}