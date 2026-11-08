-- =====================================================================
-- ตั้งค่า Supabase สำหรับแอป "จุดส่งพัสดุ"
-- วิธีใช้: Supabase Dashboard -> SQL Editor -> New query -> วางทั้งไฟล์ -> Run
-- รันซ้ำได้ ไม่ทำให้ข้อมูลหาย
-- =====================================================================

-- 1) ตารางเก็บจุดส่งพัสดุ
create table if not exists public.pins (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  address     text not null default '',
  name        text not null default '',
  phone       text not null default '',
  note        text not null default '',
  lat         double precision not null,
  lng         double precision not null,
  photos      jsonb not null default '[]'::jsonb,   -- รายการ path ของรูปใน Storage
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists pins_user_created_idx on public.pins (user_id, created_at desc);

-- อัปเดตเวลาแก้ไขอัตโนมัติ
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists pins_touch on public.pins;
create trigger pins_touch before update on public.pins
  for each row execute function public.touch_updated_at();

-- 2) Row Level Security: ทุกคนเห็น/แก้ได้เฉพาะแถวของตัวเองเท่านั้น
alter table public.pins enable row level security;

drop policy if exists "pins_select_own" on public.pins;
drop policy if exists "pins_insert_own" on public.pins;
drop policy if exists "pins_update_own" on public.pins;
drop policy if exists "pins_delete_own" on public.pins;

create policy "pins_select_own" on public.pins for select to authenticated
  using (user_id = auth.uid());
create policy "pins_insert_own" on public.pins for insert to authenticated
  with check (user_id = auth.uid());
create policy "pins_update_own" on public.pins for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "pins_delete_own" on public.pins for delete to authenticated
  using (user_id = auth.uid());

-- 3) ที่เก็บรูป (private) โฟลเดอร์แรกของ path ต้องเป็น user id ของเจ้าของ
insert into storage.buckets (id, name, public)
values ('pin-photos', 'pin-photos', false)
on conflict (id) do nothing;

drop policy if exists "photos_select_own" on storage.objects;
drop policy if exists "photos_insert_own" on storage.objects;
drop policy if exists "photos_update_own" on storage.objects;
drop policy if exists "photos_delete_own" on storage.objects;

create policy "photos_select_own" on storage.objects for select to authenticated
  using (bucket_id = 'pin-photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "photos_insert_own" on storage.objects for insert to authenticated
  with check (bucket_id = 'pin-photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "photos_update_own" on storage.objects for update to authenticated
  using (bucket_id = 'pin-photos' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'pin-photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "photos_delete_own" on storage.objects for delete to authenticated
  using (bucket_id = 'pin-photos' and (storage.foldername(name))[1] = auth.uid()::text);
