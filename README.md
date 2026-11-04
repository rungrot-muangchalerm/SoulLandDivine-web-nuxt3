# Soul Land GM Admin

แอปพลิเคชันหลักกำลังทยอยย้ายมาใช้ Nuxt 3 และ Nitro server routes ที่โฟลเดอร์
รากของโปรเจกต์ ส่วนโปรเจกต์ Express, Vue 2 และ Vue 3/Vite รุ่นก่อนหน้าเก็บไว้ใน
`legacy/` เพื่อใช้อ้างอิงเท่านั้น

## วิธีใช้งาน

ต้องใช้ Node.js เวอร์ชัน 20.19 ขึ้นไป และเชื่อมต่อฐานข้อมูล MySQL/MariaDB ได้
`GAMEDB_*` ใช้กำหนดการเชื่อมต่อเดียวกับฐาน `gamedb` ซึ่งใช้ร่วมกันทั้งข้อมูลเกม
และข้อมูลของเว็บแอดมิน ตัวแปรเดิม `DB_HOST`, `DB_PORT`, `DB_USER` และ
`DB_PASSWORD` จะถูกใช้เป็นค่าสำรองเฉพาะเมื่อไม่ได้กำหนดตัวแปร `GAMEDB_*`
ที่ตรงกัน ส่วน `DB_NAME` จะไม่ถูกนำมาใช้ โดยเว็บจะใช้ฐาน `gamedb` หากไม่ได้
กำหนด `GAMEDB_NAME`

```powershell
Copy-Item .env.example .env
# กำหนด GAMEDB_* ใน .env ให้เชื่อมต่อฐานข้อมูลที่ใช้ร่วมกัน
npm install
npm run dev
```

เซิร์ฟเวอร์สำหรับพัฒนาและ preview ใช้ `http://localhost:8081` เป็นค่าเริ่มต้น
และรับการเชื่อมต่อผ่าน IPv4 เพื่อให้ VS Code หรือเบราว์เซอร์เชื่อมต่อผ่าน port
forwarding ได้ ส่วน Nitro server สำหรับ production ให้กำหนด `HOST=0.0.0.0`
และ `PORT=8081` (หรือใช้ `NITRO_HOST=0.0.0.0` และ `NITRO_PORT=8081`)

ไฟล์ `database/gamedb_export.sql` ที่อยู่ใน repository เป็น database dump ซึ่งมี
คำสั่ง `DROP TABLE` และ `CREATE TABLE` อย่านำเข้าไฟล์นี้ในฐานข้อมูลที่ใช้งานจริง
โดยยังไม่ได้ตรวจสอบและสำรองข้อมูลก่อน

ไฟล์ `database/game-config-schema.sql` ใช้สร้างตารางเว็บแอดมินที่ใช้ฐานร่วมกัน
(`admin_user`, `channel_list`, `operationlog` และ `broadcast`), ตาราง
configuration ของเกม และตารางเก็บเวอร์ชัน schema ไฟล์นี้เป็น schema ฉบับร่าง
สำหรับพิจารณาว่าจะย้ายชุดข้อมูลใดจาก XML เข้า database ต่อไปยังต้องเลือกตาราง
ที่ต้องการก่อนนำไปใช้จริง ข้อมูล NPC, ตำแหน่งวาง/จุดเกิด และ configuration
แผนที่/ด่านยังคงอ่านจาก XML ตามเดิม Schema นี้ยังไม่สามารถใช้แทน
`database/gamedb_export.sql` สำหรับตาราง runtime เดิมที่ game server ใช้อยู่ได้

ไฟล์ข้อมูลตั้งต้น `database/game-config-seed.sql` และ
`database/game-config-localization-th.sql` เป็นไฟล์ที่สร้างจากข้อมูลเกม จึงถูก
ตั้งค่า ignore ไว้และจะไม่รวมใน Git ระหว่างเลือกขอบเขตตาราง ข้อความ localization
หากนำมาใช้ภายหลังจะต้องเก็บแยกจากค่าที่ควบคุมการทำงานของเกม และโค้ดที่อ่าน
configuration ต้องรองรับการเลือกข้อความตามภาษาด้วย

หากกำลังย้ายระบบเดิม ให้รัน migration
`database/migrations/20261031_admin_users_gamedb.sql` หนึ่งครั้งเพื่อคัดลอกบัญชี
แอดมินจาก `dlbackstage.user` หลังจากนั้นระบบ login, session และการจัดการบัญชี
แอดมินจะใช้ `gamedb.admin_user` จากนั้นรัน
`database/migrations/20261103_channel_list_gamedb.sql` หนึ่งครั้งเพื่อคัดลอก
channel จาก `dlbackstage.channel_list` โดย migration จะเก็บตารางเดิมไว้เพื่อใช้
ย้อนกลับ ส่วนเว็บจะอ่านและแก้ไข channel ใน `gamedb`

ก่อนเปลี่ยนเว็บให้ใช้ฐานใหม่ ให้รัน
`database/migrations/20261104_admin_operations_gamedb.sql` เพื่อสร้างตาราง
`gamedb.operationlog` และ `gamedb.broadcast` พร้อมคัดลอกข้อมูลเดิมจาก
`dlbackstage` ควรพักการเขียนข้อมูลจากหน้าแอดมินระหว่าง migration ทำงาน แล้วจึง
เริ่มเว็บเวอร์ชันใหม่ migration นี้เพิ่มข้อมูลโดยใช้ `INSERT IGNORE` จึงรันซ้ำ
เพื่อคัดลอกแถวที่ยังไม่มี ID ซ้ำใน `gamedb` ได้ แต่จะไม่เขียนทับแถวที่มีอยู่แล้ว
ควรเก็บฐานเดิมไว้จนกว่าจะตรวจสอบข้อมูลที่ย้ายเสร็จ หลังจาก migration แล้ว ทั้ง
game server และการทำงานของเว็บแอดมินจะใช้ `gamedb`

หน้าแสดงข้อมูลผู้เล่นจะแสดงบัญชีที่มีตัวละครอยู่ใน server ที่เลือก ครั้งละ 50
บัญชี เมื่อขยายบัญชีจะแสดงตัวละคร ทรัพยากร และยอดเติมเงิน ยอดรวมของผู้เล่นคำนวณ
จากตัวละครของบัญชีนั้นใน server ที่เลือก ตารางตัวละครที่ export มาไม่มีข้อมูล
สถานะออนไลน์ จึงแสดงสถานะเป็นไม่ทราบ การปิด/เปิด mute และ freeze ยังคงทำกับ
ตัวละครที่เลือกเป็นรายตัว และส่งคำสั่งผ่าน Game Server protocol

หน้าหักไอเทมจะโหลด inventory ของ server ที่เลือกโดยอัตโนมัติ ครั้งละ 50 แถว
รวมถึงไอเทมแบบ stack, อุปกรณ์, วงแหวน/กระดูกวิญญาณ และไอเทมสะสมประเภทที่รองรับ
ยอดเงินและหมวด inventory ที่ไม่มี Game Server deduction type รองรับจะแสดงเพื่อ
ดูเท่านั้น

หน้าอีเมลแยกประเภทผู้รับ (ผู้เล่นรายบุคคลหรือทั้ง server) ออกจากเนื้อหาอีเมล
(เทมเพลต Email หรือกำหนดหัวข้อ ผู้ส่ง เนื้อหา และรางวัลเอง) รางวัลที่กำหนดเอง
เลือกจากรายการหรือกรอก item ID, type และจำนวนได้ โดยส่งได้ไม่เกิน 255 ไอเทมต่อ
คำขอ หากข้อมูลรางวัลรวมยาวเกิน 255 ตัวอักษร ระบบจะแยกส่งเป็นหลายอีเมล ผู้รับ
รายบุคคลระบุด้วยรูปแบบ `serverId:UID` และคั่นผู้เล่นหลายคนด้วย `|` (ไม่เกิน 50
คนต่อคำขอ) อีเมลที่กำหนดเองสำหรับ server ส่งได้ทั้ง server ที่เลือก หรือทุก
RelationServer ที่เชื่อมกับ GlobalServer ของ channel ที่เลือก

อีเมลที่กำหนดเองใช้ Game Server protocol เดิม หลังแก้โค้ดต้อง build และ restart
GlobalServer กับ RelationServer หนึ่งครั้ง ส่วน process เกมอื่นไม่เปลี่ยนแปลง
ระบบส่งอีเมลเข้าคิวตามลำดับใน process และเก็บสถานะความคืบหน้าไว้ใน NodeCache
เป็นเวลาเจ็ดวัน API จะส่ง job ID กลับทันที จากนั้นหน้าอีเมลจะตรวจสอบ job ID เพื่อ
ดูความคืบหน้าและผลลัพธ์ เนื่องจากคิวอยู่ในหน่วยความจำ งานที่ยังไม่เสร็จและสถานะ
จะหายไปเมื่อ Nuxt process restart และระบบนี้ต้องใช้ Nuxt process เดียวสำหรับ
จัดการคิวและตรวจสอบสถานะ

Nuxt ให้บริการหน้าแอดมินเดิมทั้ง 28 หน้าและ Nitro API จาก origin เดียวกัน Nitro
จัดการ login และตรวจสอบ session, การจัดการ channel และผู้ใช้, operation log,
การตั้งเวลาส่ง broadcast, การอัปโหลด/ดาวน์โหลดประกาศ และคำขอผ่าน Game Server
protocol ให้กำหนด `GAMESERVER_HOST`/`GAMESERVER_PORT` สำหรับการเชื่อมต่อ
Game Server ไฟล์ประกาศจะส่งต่อไปยัง Game AdminAPI โดยใช้ `ADMIN_API_URL` และ
`ADMIN_API_TOKEN` โดย token จะถูกเก็บและส่งจากฝั่ง server ผ่าน HTTP header ชื่อ
`token` ห้ามใส่ token ใน Vue component หรือ commit ลง source control ระบบ
Express รุ่นเก่าไม่ได้ทำหน้าที่เป็น proxy

หน้าแอดมิน `/activities` ใช้จัดการเฉพาะ field ตารางเวลาที่ตรวจสอบแล้วจาก
activity XML config ที่อนุญาตไว้ ซึ่งระบุใน `docs/API_DOCUMENTATION.md` หลัง
แก้ไข `Game_Server/AdminAPI` ต้อง build และ restart AdminAPI ก่อน endpoint
กิจกรรมใหม่จึงจะใช้งานได้ และ game server อาจต้อง reload XML configuration ด้วย

การตรวจสอบการทำงานครบวงจรของ route ที่พึ่งพาฐานข้อมูล game server หรือบริการ
ประกาศ จำเป็นต้องตั้งค่าบริการเหล่านั้นให้พร้อม ไฟล์ระบบเก่ายังคงอยู่ใน
`legacy/` เพื่อใช้อ้างอิง ไม่ใช่แอปพลิเคชันที่กำลังทำงาน

## ไฟล์อ้างอิงสำหรับการย้ายระบบ

- `legacy/express/` — Express API, DB models และส่วนเชื่อมต่อ game server รุ่นเดิม
- `legacy/vue2/` — หน้าแอดมิน Vue 2 รุ่นเดิม
- `legacy/vue3/` — ต้นแบบ Vue 3/Vite รุ่นเดิม

การตั้งค่าฐานข้อมูลกำหนดผ่าน environment variables ห้าม commit ไฟล์ `.env`
ที่ใช้ในเครื่องลง source control
