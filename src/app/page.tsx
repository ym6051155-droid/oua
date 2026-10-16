import Link from "next/link";
import { BookOpen, Users, WifiOff, BellRing, GraduationCap, ShieldCheck } from "lucide-react";
const features = [
  {icon:BookOpen,title:"مكتبة المحاضرات",desc:"ملفات PDF وشيتات وملفات صوتية خفيفة للمراجعة."},
  {icon:Users,title:"قروبات الدفعات",desc:"محتوى أكاديمي يظهر حسب التخصص والسمستر."},
  {icon:WifiOff,title:"دعم الاتصال الضعيف",desc:"تطبيق قابل للتثبيت وحفظ الصفحات المفتوحة للعمل دون اتصال."},
  {icon:BellRing,title:"تنبيهات مرنة",desc:"تحكم في قنوات التنبيه المفضلة من إعدادات الحساب."}
];
export default function Home() {
 return <main>
  <header className="bg-white border-b border-slate-100"><div className="container flex items-center justify-between py-4 gap-4">
   <Link href="/" className="flex items-center gap-3 no-underline text-inherit"><span className="bg-academic text-white rounded-2xl p-3"><GraduationCap/></span><span><strong className="block text-lg">أهليّة</strong><small className="text-slate-500">جامعة أمدرمان الأهلية</small></span></Link>
   <nav className="flex gap-2"><Link className="btn btn-light" href="/login">دخول</Link><Link className="btn btn-primary" href="/register">إنشاء حساب</Link></nav>
  </div></header>
  <section className="container py-14 md:py-20"><div className="max-w-3xl">
   <span className="inline-block rounded-full bg-emerald-50 text-emerald-800 px-3 py-2 text-sm mb-5">منصتك الأكاديمية في مكان واحد</span>
   <h1 className="text-4xl md:text-6xl font-extrabold leading-tight mb-5">تعلّم، شارك، وتابع <span className="text-academic">رحلتك الجامعية</span></h1>
   <p className="text-lg md:text-xl text-slate-600 leading-8 mb-7">مساحة تعليمية عربية للطلاب والأساتذة، مصممة لتكون واضحة وسريعة حتى مع اتصال إنترنت محدود.</p>
   <div className="flex flex-wrap gap-3"><Link href="/register" className="btn btn-primary">ابدأ الآن</Link><Link href="/login" className="btn btn-light">لديّ حساب بالفعل</Link></div>
  </div>
  <div className="grid-cards mt-12">{features.map(f=><article className="card" key={f.title}><div className="text-academic mb-4">{<f.icon size={26}/>}</div><h2 className="font-bold text-lg mb-2">{f.title}</h2><p className="text-slate-600 leading-7">{f.desc}</p></article>)}</div>
  <section className="card mt-8 bg-academic text-white"><div className="flex items-start gap-4"><ShieldCheck size={30}/><div><h2 className="text-xl font-bold mb-2">صلاحيات أكاديمية واضحة</h2><p className="leading-7 text-blue-100">إنشاء القروبات للأساتذة المعتمدين فقط، والطلاب يشاهدون القروبات المطابقة لتخصصهم وسمسترهم. تظل حماية البيانات والصلاحيات مطبقة على مستوى قاعدة البيانات.</p></div></div></section>
  </section>
  <footer className="text-center text-slate-500 text-sm py-8">أهليّة — منصة تعليمية مجتمعية تجريبية</footer>
 </main>;
}