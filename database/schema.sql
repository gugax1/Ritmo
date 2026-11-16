
create table public.gyms(id uuid primary key default gen_random_uuid(),owner_id uuid not null references auth.users(id),name text not null check(length(name) between 2 and 120),timezone text not null default 'America/Sao_Paulo' check(timezone in ('America/Sao_Paulo','America/Manaus','America/Recife','America/Rio_Branco')),attendance_through date,created_at timestamptz not null default now());
create index on public.gyms(owner_id);
create table public.students(id uuid primary key default gen_random_uuid(),gym_id uuid not null references public.gyms(id),name text not null check(length(name) between 2 and 120),phone text not null check(phone ~ '^\+[1-9][0-9]{9,14}$'),status text not null default 'active' check(status in ('active','inactive','left')),consent boolean not null default false,opt_out boolean not null default false,joined_on date not null default current_date,unique(gym_id,id),unique(gym_id,phone));
create table public.payments(id uuid primary key default gen_random_uuid(),gym_id uuid not null references public.gyms(id),student_id uuid not null,due_on date not null,amount numeric(10,2) not null check(amount>0),paid_at timestamptz,foreign key(gym_id,student_id) references public.students(gym_id,id),unique(student_id,due_on));
create table public.attendance(id uuid primary key default gen_random_uuid(),gym_id uuid not null references public.gyms(id),student_id uuid not null,attended_on date not null,foreign key(gym_id,student_id) references public.students(gym_id,id),unique(student_id,attended_on));
create table public.automation_rules(id uuid primary key default gen_random_uuid(),gym_id uuid not null references public.gyms(id),kind text not null check(kind in ('due_soon','overdue','absence')),enabled boolean not null default false,unique(gym_id,kind));
create table public.events(id uuid primary key default gen_random_uuid(),gym_id uuid not null references public.gyms(id),student_id uuid not null,kind text not null,status text not null default 'simulated' check(status='simulated'),dedupe_key text not null unique,created_at timestamptz not null default now(),foreign key(gym_id,student_id) references public.students(gym_id,id));
alter table public.gyms enable row level security; revoke all on public.gyms from anon; grant select,insert,update,delete on public.gyms to authenticated; create policy owner_access on public.gyms to authenticated using (owner_id=(select auth.uid())) with check (owner_id=(select auth.uid()));alter table public.students enable row level security; revoke all on public.students from anon; grant select,insert,update,delete on public.students to authenticated; create policy owner_access on public.students to authenticated using (exists(select 1 from public.gyms g where g.id=gym_id and g.owner_id=(select auth.uid()))) with check (exists(select 1 from public.gyms g where g.id=gym_id and g.owner_id=(select auth.uid())));create index on public.students(gym_id);alter table public.payments enable row level security; revoke all on public.payments from anon; grant select,insert,update,delete on public.payments to authenticated; create policy owner_access on public.payments to authenticated using (exists(select 1 from public.gyms g where g.id=gym_id and g.owner_id=(select auth.uid()))) with check (exists(select 1 from public.gyms g where g.id=gym_id and g.owner_id=(select auth.uid())));create index on public.payments(gym_id);alter table public.attendance enable row level security; revoke all on public.attendance from anon; grant select,insert,update,delete on public.attendance to authenticated; create policy owner_access on public.attendance to authenticated using (exists(select 1 from public.gyms g where g.id=gym_id and g.owner_id=(select auth.uid()))) with check (exists(select 1 from public.gyms g where g.id=gym_id and g.owner_id=(select auth.uid())));create index on public.attendance(gym_id);alter table public.automation_rules enable row level security; revoke all on public.automation_rules from anon; grant select,insert,update,delete on public.automation_rules to authenticated; create policy owner_access on public.automation_rules to authenticated using (exists(select 1 from public.gyms g where g.id=gym_id and g.owner_id=(select auth.uid()))) with check (exists(select 1 from public.gyms g where g.id=gym_id and g.owner_id=(select auth.uid())));create index on public.automation_rules(gym_id);alter table public.events enable row level security; revoke all on public.events from anon; grant select,insert,update,delete on public.events to authenticated; create policy owner_access on public.events to authenticated using (exists(select 1 from public.gyms g where g.id=gym_id and g.owner_id=(select auth.uid()))) with check (exists(select 1 from public.gyms g where g.id=gym_id and g.owner_id=(select auth.uid())));create index on public.events(gym_id);
create function public.simulate(p_gym uuid) returns integer language plpgsql security invoker set search_path='' as $$
declare local_day date; watermark date; n integer;
begin
 select (now() at time zone timezone)::date,attendance_through into local_day,watermark from public.gyms where id=p_gym;
 if not found then raise exception 'Academia não autorizada'; end if;
 perform pg_advisory_xact_lock(hashtextextended(p_gym::text,0));
 with candidates as (
 select s.id student_id,r.kind,
 case when r.kind='absence' then coalesce(max(a.attended_on),s.joined_on)::text else p.id::text end subject
 from public.students s join public.automation_rules r on r.gym_id=s.gym_id and r.enabled
 left join public.payments p on p.student_id=s.id and p.gym_id=s.gym_id and p.paid_at is null
 left join public.attendance a on a.student_id=s.id and a.gym_id=s.gym_id
 where s.gym_id=p_gym and s.status='active' and s.consent and not s.opt_out
 group by s.id,r.kind,p.id,p.due_on,s.joined_on
 having (r.kind='due_soon' and p.due_on=local_day+3)
 or (r.kind='overdue' and p.due_on<local_day)
 or (r.kind='absence' and watermark>=local_day-1 and coalesce(max(a.attended_on),s.joined_on)<=local_day-30)
 )
 insert into public.events(gym_id,student_id,kind,dedupe_key)
 select p_gym,c.student_id,c.kind,p_gym||':'||c.student_id||':'||c.kind||':'||c.subject
 from candidates c where not exists(select 1 from public.events e where e.student_id=c.student_id and e.created_at>now()-interval '7 days')
 on conflict(dedupe_key) do nothing;
 get diagnostics n=row_count; return n;
end $$;
revoke execute on function public.simulate(uuid) from public,anon; grant execute on function public.simulate(uuid) to authenticated;
