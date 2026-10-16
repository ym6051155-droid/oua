import { createBrowserClient } from "@supabase/ssr";
export function supabaseBrowser() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !key) throw new Error("يرجى ضبط متغيرات Supabase في ملف .env.local");
  return createBrowserClient(url, key);
}