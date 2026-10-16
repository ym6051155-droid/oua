-- أهليّة: Supabase PostgreSQL schema
create extension if not exists pgcrypto;
create type public.app_role as enum ('student','professor','admin');

create table public.users (
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text not null,
 email text not null unique,
 role public.app_role not null default 'student',
 major text,
 semester int check (semester between 1 and 10),
 whatsapp_number text,
 messenger_psid text,
 push_subscription_id text,
 notification_preferences jsonb not null default '{"email":true,"whatsapp":false,"messenger":false,"push":false}'::jsonb,
 department text,
 is_approved boolean not null default false,
 created_at timestamptz not null default now(),
 constraint student_academic_fields check (role <> 'student' or (major is not null and semester is not null))
);
create table public.groups (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 subject_name text not null,
 created_by_prof_id uuid not null references public.users(id),
 target_major text not null,
 target_semester int not null check(target_semester between 1 and 10),
 created_at timestamptz not null default now()
);
create table public.lectures_materials (
 id uuid primary key default gen_random_uuid(), group_id uuid not null references public.groups(id) on delete cascade,
 title text not null, description text, pdf_url text, audio_url text, created_by uuid references public.users(id),
 created_at timestamptz not null default now()
);
create table public.announcements (
 id uuid primary key default gen_random_uuid(), group_id uuid not null references public.groups(id) on delete cascade,
 content text not null, meeting_link text, is_pinned boolean not null default false,
 created_by uuid references public.users(id), created_at timestamptz not null default now()
);
create table public.assignments (
 id uuid primary key default gen_random_uuid(), group_id uuid not null references public.groups(id) on delete cascade,
 title text not null, description text, deadline timestamptz not null, created_by uuid references public.users(id),
 created_at timestamptz not null default now()
);
create table public.submissions (
 id uuid primary key default gen_random_uuid(), assignment_id uuid not null references public.assignments(id) on delete cascade,
 student_id uuid not null references public.users(id), file_url text not null, submitted_at timestamptz not null default now(),
 grade numeric check (grade between 0 and 100), feedback text, unique(assignment_id,student_id)
);
create table public.attendance_sessions (
 id uuid primary key default gen_random_uuid(), group_id uuid not null references public.groups(id) on delete cascade,
 is_active boolean not null default true, expires_at timestamptz not null, created_by uuid references public.users(id),
 created_at timestamptz not null default now()
);
create table public.attendance_records (
 id uuid primary key default gen_random_uuid(), session_id uuid not null references public.attendance_sessions(id) on delete cascade,
 student_id uuid not null references public.users(id), attended_at timestamptz not null default now(),
 unique(session_id,student_id)
);
create table public.questions_forum (
 id uuid primary key default gen_random_uuid(), group_id uuid not null references public.groups(id) on delete cascade,
 user_id uuid not null references public.users(id), question_text text not null, created_at timestamptz not null default now()
);
create table public.answers (
 id uuid primary key default gen_random_uuid(), question_id uuid not null references public.questions_forum(id) on delete cascade,
 user_id uuid not null references public.users(id), answer_text text not null, is_verified_by_prof boolean not null default false,
 created_at timestamptz not null default now()
);
create index groups_target_idx on public.groups(target_major,target_semester);
create index announcements_group_created_idx on public.announcements(group_id,created_at desc);
create index materials_group_created_idx on public.lectures_materials(group_id,created_at desc);
create index questions_group_created_idx on public.questions_forum(group_id,created_at desc);

create or replace function public.current_role() returns public.app_role
language sql stable security definer set search_path=public as $$
 select role from public.users where id=auth.uid()
$$;
create or replace function public.is_approved_professor() returns boolean
language sql stable security definer set search_path=public as $$
 select exists(select 1 from public.users where id=auth.uid() and role='professor' and is_approved=true)
$$;
create or replace function public.can_access_group(gid uuid) returns boolean
language sql stable security definer set search_path=public as $$
 select exists (
  select 1 from public.groups g join public.users u on u.id=auth.uid()
  where g.id=gid and (
   (u.role='student' and u.major=g.target_major and u.semester=g.target_semester and u.is_approved=true)
   or (u.role='professor' and u.is_approved=true and g.created_by_prof_id=u.id)
   or u.role='admin'
  )
 )
$$;

alter table public.users enable row level security;
alter table public.groups enable row level security;
alter table public.lectures_materials enable row level security;
alter table public.announcements enable row level security;
alter table public.assignments enable row level security;
alter table public.submissions enable row level security;
alter table public.attendance_sessions enable row level security;
alter table public.attendance_records enable row level security;
alter table public.questions_forum enable row level security;
alter table public.answers enable row level security;

create policy "users read self or admin" on public.users for select using(id=auth.uid() or public.current_role()='admin');
create policy "users insert self only student or pending professor" on public.users for insert with check(id=auth.uid() and (role='student' or (role='professor' and is_approved=false)));
create policy "users update self preferences or admin" on public.users for update using(id=auth.uid() or public.current_role()='admin') with check(id=auth.uid() or public.current_role()='admin');
create policy "groups visible to matching cohort" on public.groups for select using(public.can_access_group(id));
create policy "approved professors create groups" on public.groups for insert with check(public.is_approved_professor() and created_by_prof_id=auth.uid());
create policy "owner professor or admin update groups" on public.groups for update using((public.is_approved_professor() and created_by_prof_id=auth.uid()) or public.current_role()='admin');
create policy "group materials readable" on public.lectures_materials for select using(public.can_access_group(group_id));
create policy "professor adds materials" on public.lectures_materials for insert with check(public.is_approved_professor() and exists(select 1 from public.groups where id=group_id and created_by_prof_id=auth.uid()));
create policy "group announcements readable" on public.announcements for select using(public.can_access_group(group_id));
create policy "professor posts announcements" on public.announcements for insert with check(public.is_approved_professor() and exists(select 1 from public.groups where id=group_id and created_by_prof_id=auth.uid()));
create policy "assignments readable by group" on public.assignments for select using(public.can_access_group(group_id));
create policy "professor creates assignments" on public.assignments for insert with check(public.is_approved_professor() and exists(select 1 from public.groups where id=group_id and created_by_prof_id=auth.uid()));
create policy "student reads own submissions and professor group submissions" on public.submissions for select using(student_id=auth.uid() or public.current_role()='admin' or exists(select 1 from public.assignments a join public.groups g on g.id=a.group_id where a.id=assignment_id and g.created_by_prof_id=auth.uid()));
create policy "student submits to matching assignment" on public.submissions for insert with check(student_id=auth.uid() and public.current_role()='student' and exists(select 1 from public.assignments a join public.groups g on g.id=a.group_id join public.users u on u.id=auth.uid() where a.id=assignment_id and g.target_major=u.major and g.target_semester=u.semester and a.deadline>now()));
create policy "professor grades submissions" on public.submissions for update using(public.current_role()='admin' or exists(select 1 from public.assignments a join public.groups g on g.id=a.group_id where a.id=assignment_id and g.created_by_prof_id=auth.uid()));
create policy "attendance sessions readable by group" on public.attendance_sessions for select using(public.can_access_group(group_id));
create policy "professor opens attendance" on public.attendance_sessions for insert with check(public.is_approved_professor() and exists(select 1 from public.groups where id=group_id and created_by_prof_id=auth.uid()));
create policy "student or professor reads attendance records" on public.attendance_records for select using(student_id=auth.uid() or public.current_role()='admin' or exists(select 1 from public.attendance_sessions s join public.groups g on g.id=s.group_id where s.id=session_id and g.created_by_prof_id=auth.uid()));
create policy "student checks into active session" on public.attendance_records for insert with check(student_id=auth.uid() and exists(select 1 from public.attendance_sessions s join public.groups g on g.id=s.group_id join public.users u on u.id=auth.uid() where s.id=session_id and s.is_active=true and s.expires_at>now() and g.target_major=u.major and g.target_semester=u.semester));
create policy "questions readable in group" on public.questions_forum for select using(public.can_access_group(group_id));
create policy "members ask questions" on public.questions_forum for insert with check(user_id=auth.uid() and public.can_access_group(group_id));
create policy "answers readable" on public.answers for select using(exists(select 1 from public.questions_forum q where q.id=question_id and public.can_access_group(q.group_id)));
create policy "members answer" on public.answers for insert with check(user_id=auth.uid() and exists(select 1 from public.questions_forum q where q.id=question_id and public.can_access_group(q.group_id)));
create policy "professor verifies answers" on public.answers for update using(public.is_approved_professor() and exists(select 1 from public.questions_forum q join public.groups g on g.id=q.group_id where q.id=question_id and g.created_by_prof_id=auth.uid()));

-- Create a private Storage bucket named course-materials in Supabase Storage.
-- For production, use private signed URLs and add storage.objects RLS policies.
-- Do not allow public profile role changes: admin approval should use a trusted server-side
-- function/service role and verify that the requester is an admin.
