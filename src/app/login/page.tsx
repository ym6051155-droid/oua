 "use client";
import Link from "next/link";
import { FormEvent, useState } from "react";
import { useRouter } from "next/navigation";
import { supabaseBrowser } from "@/lib/supabase";
export default function LoginPage(){
 const [email,setEmail]=useState(""); const [password,setPassword]=useState(""); const [error,setError]=useState(""); const [busy,setBusy]=useState(false); const router=useRouter();
 async function submit(e:FormEvent){e.preventDefault();setBusy(true);setError("");try{const db=supabaseBrowser();const {error}=await db.auth.signInWithPassword({email,password});if(error)throw error;router.push("/dashboard");router.refresh();}catch(err){setError(err instanceof Error?err.message:"تعذر تسجيل الدخول");}finally{setBusy(false)}}
 return <main className="container py-10 max-w-xl"><Link href="/" className="text-academic no-underline">← الرئيسية</Link><section className="card mt-5"><h1 className="text-2xl font-bold mb-2">تسجيل الدخول</h1><p className="text-slate-500 mb-6">مرحباً بعودتك إلى منصتك الأكاديمية.</p><form onSubmit={submit} className="space-y-4"><div><label className="label">البريد الإلكتروني</label><input className="field" type="email" required autoComplete="email" value={email} onChange={e=>setEmail(e.target.value)}/></div><div><label className="label">كلمة المرور</label><input className="field" type="password" required autoComplete="current-password" value={password} onChange={e=>setPassword(e.target.value)}/></div>{error&&<p role="alert" className="text-red-700 text-sm">{error}</p>}<button className="btn btn-primary w-full" disabled={busy}>{busy?"جارٍ الدخول…":"دخول"}</button></form><p className="mt-5 text-sm text-slate-600">ليس لديك حساب؟ <Link className="text-academic" href="/register">إنشاء حساب</Link></p></section></main>
}