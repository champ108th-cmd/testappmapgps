// ใส่ค่าจาก Supabase: Project Settings -> API
//   SUPABASE_URL      = Project URL  (เช่น https://abcdefgh.supabase.co)
//   SUPABASE_ANON_KEY = anon public key (ขึ้นต้นด้วย eyJ... หรือ sb_publishable_...)
// ห้ามใช้ service_role key เด็ดขาด เพราะไฟล์นี้เปิดเผยต่อสาธารณะ
// anon key ออกแบบมาให้เปิดเผยได้ ข้อมูลถูกป้องกันด้วยการล็อกอิน + RLS ที่ตั้งไว้ใน supabase-setup.sql
window.APP_CONFIG = {
  ORS_API_KEY: 'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImMxMzVjMWNjYTZjYjQwZTA5MTE2NGUxZGVmMDVmMmY0IiwiaCI6Im11cm11cjY0In0=',
  SUPABASE_URL: 'https://sttrxulxtltjpctmroua.supabase.co',
  SUPABASE_ANON_KEY: 'sb_publishable_id0i20vtznhw6RE-qWBvOQ_344Vjqxx'
};
