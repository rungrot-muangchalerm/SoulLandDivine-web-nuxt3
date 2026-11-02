# AdminAPI — คู่มือใช้งาน API (สำหรับฝั่ง Web)

> Base URL: `http://<server-ip>:8082`
> ทุก endpoint (ยกเว้น `GET /`) ต้องส่ง **token** ทุกครั้ง

---

## 🔐 การยืนยันตัวตน (Authentication)

ส่ง token ผ่าน **HTTP Header** หรือ **Query String**:

| วิธี | ตัวอย่าง |
|---|---|
| Header | `token: <ADMIN_API_TOKEN>` |
| Query String | `?token=<ADMIN_API_TOKEN>` |

### การตั้งค่า Token

แก้ไขไฟล์ `appsettings.json`:

```json
{
  "AdminSettings": {
    "AdminToken": "<ADMIN_API_TOKEN>",
    "UserToken": "<USER_API_TOKEN>"
  }
}
```

| ค่า | ความหมาย |
|---|---|
| `AdminToken` | Token สำหรับสิทธิ์แอดมิน (จัดการได้ทุกอย่าง) |
| `UserToken` | Token สำหรับสิทธิ์ผู้ใช้ทั่วไป |

### รหัสผลลัพธ์ (Response Code)

| code | ความหมาย |
|---|---|
| `1` | สำเร็จ |
| `2` | ไม่พบไฟล์ |
| `3` | Token ไม่ถูกต้อง (403) |
| `4` | เกิดข้อผิดพลาด |

---

## 🏠 ตรวจสอบสถานะเซิร์ฟเวอร์

### `GET /`

ตรวจว่า AdminAPI ทำงานอยู่หรือไม่ (ไม่ต้องใช้ token)

**Response:**
```
Admin API Server is Running
```

---

## 📤 การอัปโหลดไฟล์ (Upload)

### `POST /up{Resource}`

อัปโหลดไฟล์ไปยังโฟลเดอร์ที่กำหนด

**Path Parameters:**

| Resource | โฟลเดอร์ปลายทาง |
|---|---|
| `photo` | `public/photo/` |
| `announcement` | `public/announcement/` |
| `face` | `public/face/` |
| `gamevideo` | `public/gameVideo/` |
| `sound` | `public/sound/` |
| `recommendvideo` | `public/recommendVideo/` |
| `gatelist` | `public/gateList/` |

**Request (multipart/form-data):**

| Field | ประเภท | คำอธิบาย |
|---|---|---|
| `file` | File | ไฟล์ที่ต้องการอัปโหลด |
| `fileName` | String | ชื่อไฟล์ปลายทาง (รวมนามสกุล) |

**ตัวอย่าง (cURL):**
```bash
curl -X POST "http://localhost:8082/upphoto?token=<ADMIN_API_TOKEN>" \
  -F "file=@C:\path\to\image.png" \
  -F "fileName=hero_001.png"
```

**Response (สำเร็จ):**
```json
{ "code": 1, "message": "ok" }
```

**Response (ผิดพลาด):**
```json
{ "code": 4, "message": "ข้อความ error" }
```

---

## 📥 การดาวน์โหลดไฟล์ (Download)

### `GET /down{Resource}?fileName=...`

ดาวน์โหลดไฟล์จากโฟลเดอร์ที่กำหนด

**Path Parameters:**

| Resource | โฟลเดอร์ต้นทาง |
|---|---|
| `photos` | `public/photo/` |
| `announcement` | `public/announcement/` |
| `face` | `public/face/` |
| `gamevideo` | `public/gameVideo/` |
| `sound` | `public/sound/` |
| `detailphoto` | `public/photo/` |
| `radiocaster` | `public/radioCaster/` |
| `radioinfo` | `public/radio/` |
| `gatelist` | `public/gateList/` |

**Query Parameters:**

| Field | ประเภท | คำอธิบาย |
|---|---|---|
| `fileName` | String | ชื่อไฟล์ที่ต้องการดาวน์โหลด |

**ตัวอย่าง (cURL):**
```bash
curl -X GET "http://localhost:8082/downphotos?fileName=hero_001.png&token=<ADMIN_API_TOKEN>" \
  -o hero_001.png
```

**Response:**
- ✅ พบไฟล์ → ส่งไฟล์กลับ (binary, `application/octet-stream`)
- ❌ ไม่พบไฟล์ → ข้อความ `file not exist`

---

## 🗑️ การลบรูปภาพ

### `POST /rmPhoto?fileName=...`

ลบไฟล์รูปภาพจาก `public/photo/`

**Query Parameters:**

| Field | ประเภท | คำอธิบาย |
|---|---|---|
| `fileName` | String | ชื่อไฟล์ที่ต้องการลบ |

**ตัวอย่าง (cURL):**
```bash
curl -X POST "http://localhost:8082/rmPhoto?fileName=hero_001.png&token=<ADMIN_API_TOKEN>"
```

**Response:**
```json
{ "code": 1, "message": "ok" }
```

| code | ความหมาย |
|---|---|
| `1` | ลบสำเร็จ |
| `2` | ไม่พบไฟล์ |
| `4` | เกิดข้อผิดพลาด |

---

## 🎰 การจัดการ Gacha XML

### อ่าน DrawTime.xml

#### `GET /api/gacha/time`

อ่านไฟล์ `Bin/Data/XML/Draw/DrawTime.xml`

**ตัวอย่าง (cURL):**
```bash
curl -X GET "http://localhost:8082/api/gacha/time?token=<ADMIN_API_TOKEN>"
```

**Response:** XML content (`application/xml`)
```xml
<?xml version="1.0" encoding="utf-8"?>
<DrawTime>
  ...
</DrawTime>
```

---

### เขียน/แก้ไข DrawTime.xml

#### `POST /api/gacha/time`

เขียนไฟล์ `DrawTime.xml` ใหม่ (ตรวจสอบความถูกต้องของ XML ก่อนบันทึก)

**Request (JSON):**

| Field | ประเภท | คำอธิบาย |
|---|---|---|
| `xmlContent` | String | เนื้อหา XML ทั้งไฟล์ |

**ตัวอย่าง (cURL):**
```bash
curl -X POST "http://localhost:8082/api/gacha/time?token=<ADMIN_API_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"xmlContent": "<?xml version=\"1.0\"?><DrawTime>...</DrawTime>"}'
```

**Response (สำเร็จ):**
```json
{ "code": 1, "message": "Gacha Time updated successfully" }
```

**Response (XML ไม่ถูกต้อง):**
```json
{ "code": 4, "message": "Invalid XML format or file lock" }
```

---

### อ่าน DrawHeroRatio.xml

#### `GET /api/gacha/ratio`

อ่านไฟล์ `Bin/Data/XML/Draw/DrawHeroRatio.xml`

**ตัวอย่าง (cURL):**
```bash
curl -X GET "http://localhost:8082/api/gacha/ratio?token=<ADMIN_API_TOKEN>"
```

**Response:** XML content (`application/xml`)

---

### เขียน/แก้ไข DrawHeroRatio.xml

#### `POST /api/gacha/ratio`

เขียนไฟล์ `DrawHeroRatio.xml` ใหม่ (ตรวจสอบความถูกต้องของ XML ก่อนบันทึก)

**Request (JSON):**

| Field | ประเภท | คำอธิบาย |
|---|---|---|
| `xmlContent` | String | เนื้อหา XML ทั้งไฟล์ |

**ตัวอย่าง (cURL):**
```bash
curl -X POST "http://localhost:8082/api/gacha/ratio?token=<ADMIN_API_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"xmlContent": "<?xml version=\"1.0\"?><DrawHeroRatio>...</DrawHeroRatio>"}'
```

**Response (สำเร็จ):**
```json
{ "code": 1, "message": "Hero Ratio updated successfully" }
```

**Response (XML ไม่ถูกต้อง):**
```json
{ "code": 4, "message": "Invalid XML format or file lock" }
```

---

## ✉️ การจัดการ Email XML

> ⚠️ **สำคัญ:** หลังแก้ไข `Email.xml` แล้ว ต้อง **restart RelationServer** เพื่อให้โหลด template ใหม่ (เกมโหลด XML ตอน boot เท่านั้น)

### รายชื่อ mailId ที่ใช้ได้

#### `GET /api/email/templates`

อ่านรายชื่อ template ทั้งหมดจาก `Bin/Data/XML/Email/Email.xml` — ใช้ตรวจสอบก่อนส่ง mail ว่า mailId มีอยู่จริง

**ตัวอย่าง (cURL):**
```bash
curl -X GET "http://localhost:8082/api/email/templates?token=<ADMIN_API_TOKEN>"
```

**Response (สำเร็จ):**
```json
{
  "code": 1,
  "count": 131,
  "templates": [
    { "id": 1, "title": "อีเมลฉบับนี้จะถูกลบหลังจากเปิดอ่านเสร็จ", "reward": "7401:2:1|7402:2:1|7403:2:1", "type": 1, "validityDate": 1 },
    { "id": 7, "title": "รางวัล", "reward": "", "type": 1, "validityDate": 0 }
  ]
}
```

| Field | ประเภท | คำอธิบาย |
|---|---|---|
| `id` | Int | mailId — ใช้ส่งใน protocol 10020 (`mailId`) |
| `title` | String | ชื่อเรื่อง (ภาษาไทย) |
| `reward` | String | ของรางวัลใน template (รูปแบบ `itemId:count:bindType`) |
| `type` | Int | ประเภทอีเมล |
| `validityDate` | Int | อายุอีเมล (วัน) |

---

### อ่าน Email.xml ทั้งไฟล์

#### `GET /api/email/xml`

อ่านไฟล์ `Bin/Data/XML/Email/Email.xml` ทั้งไฟล์ (สำหรับดู/แก้ไข template ทั้งหมด)

**ตัวอย่าง (cURL):**
```bash
curl -X GET "http://localhost:8082/api/email/xml?token=<ADMIN_API_TOKEN>"
```

**Response:** XML content (`application/xml`)

---

### เขียน/แก้ไข Email.xml ทั้งไฟล์

#### `POST /api/email/xml`

เขียนไฟล์ `Email.xml` ใหม่ (ตรวจสอบความถูกต้องของ XML ก่อนบันทึก) — ใช้เพิ่ม template ใหม่ เช่น เพิ่ม `<class id="2" ...>` และ `<class id="3" ...>`

**Request (JSON):**

| Field | ประเภท | คำอธิบาย |
|---|---|---|
| `xmlContent` | String | เนื้อหา XML ทั้งไฟล์ |

**ตัวอย่าง (cURL):**
```bash
curl -X POST "http://localhost:8082/api/email/xml?token=<ADMIN_API_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"xmlContent": "<?xml version=\"1.0\"?><idspace id=\"Email\">...</idspace>"}'
```

**Response (สำเร็จ):**
```json
{ "code": 1, "message": "Email.xml updated successfully" }
```

**Response (XML ไม่ถูกต้อง):**
```json
{ "code": 4, "message": "Invalid XML format or file lock" }
```

---

## 🗓️ การจัดการตารางเวลากิจกรรม

Game AdminAPI เปิดให้อ่าน XML จาก allowlist และแก้เฉพาะฟิลด์เวลาของแถวเดิม
ไม่รับ path หรือเนื้อหา XML ทั้งไฟล์จากเว็บ

### อ่าน config กิจกรรม

#### `GET /api/activities/config/{configId}`

ส่งกลับ XML (`application/xml`) โดย `configId` เลือกได้จาก:

| configId | ไฟล์ |
|---|---|
| `recharge-tabs` | `Recharge/RechargeGiftTab.xml` |
| `recharge-time` | `Recharge/RechargeGiftTime.xml` |
| `direct-purchase-time` | `Recharge/DirectPurchaseTime.xml` |
| `activity-info` | `Activity/ActivityInfo.xml` |
| `special-activity` | `Activity/SpecialActivityInfo.xml` |
| `special-activity-table` | `Activity/SpecialActivityTable.xml` |
| `overseas-activity` | `Activity/OverSeasActivityTable.xml` |
| `camp-timers` | `Camp/CampActivityTimer.xml` |
| `hunting-unlocks` | `Hunting/HuntingActivity.xml` |
| `integral-boss` | `IntegralBoss/IntegralBossConfig.xml` |
| `theme-boss-time` | `ThemeBoss/ThemeBossBuffTime.xml` |
| `wish-pool` | `WishPool/WishPoolItem2.xml` |

### แก้ตารางเวลาของแถว

#### `POST /api/activities/config/{configId}/{rowId}`

ส่ง JSON object ที่มีเฉพาะฟิลด์เวลาซึ่งมีอยู่แล้วบนแถวนั้น เช่น:

```json
{ "ShowStart": "2026-07-01 00:00:00", "ShowEnd": "2026-07-07 23:59:59" }
```

ระบบตรวจ config, ID แถว และชื่อฟิลด์กับ allowlist ก่อนเขียนผ่านไฟล์ชั่วคราว
โดยไม่แก้รางวัลหรือเพิ่ม/ลบแอตทริบิวต์อื่น การเปลี่ยน config อาจต้องให้ Game
Server โหลด XML ใหม่หรือรีสตาร์ต

---

## 📋 สรุป Endpoints ทั้งหมด

| Method | Path | คำอธิบาย | ต้องใช้ Token |
|---|---|---|---|
| GET | `/` | ตรวจสอบสถานะเซิร์ฟเวอร์ | ❌ |
| POST | `/up{Resource}` | อัปโหลดไฟล์ (photo, announcement, face, gamevideo, sound, recommendvideo, gatelist) | ✅ |
| GET | `/down{Resource}` | ดาวน์โหลดไฟล์ (photos, announcement, face, gamevideo, detailphoto, radiocaster, radioinfo, gatelist) | ✅ |
| POST | `/rmPhoto` | ลบรูปภาพ | ✅ |
| GET | `/api/gacha/time` | อ่าน DrawTime.xml | ✅ |
| POST | `/api/gacha/time` | เขียน DrawTime.xml | ✅ |
| GET | `/api/gacha/ratio` | อ่าน DrawHeroRatio.xml | ✅ |
| POST | `/api/gacha/ratio` | เขียน DrawHeroRatio.xml | ✅ |
| GET | `/api/activities/config/{configId}` | อ่าน XML กิจกรรมจาก allowlist | ✅ |
| POST | `/api/activities/config/{configId}/{rowId}` | แก้เฉพาะตารางเวลาของแถวกิจกรรม | ✅ |
| GET | `/api/email/templates` | รายชื่อ mailId ที่ใช้ได้ (จาก Email.xml) | ✅ |
| GET | `/api/email/xml` | อ่าน Email.xml ทั้งไฟล์ | ✅ |
| POST | `/api/email/xml` | เขียน Email.xml ทั้งไฟล์ (เพิ่ม template) | ✅ |

---

## ⚠️ หมายเหตุ

1. **Token หมดอายุ** — ตอนนี้ token เป็นแบบคงที่ (ไม่มีหมดอายุ) ตั้งค่าได้ใน `appsettings.json`
2. **สิทธิ์** — `AdminToken` กับ `UserToken` ใช้สิทธิ์เท่ากันในตอนนี้ (ยังไม่แยกสิทธิ์)
3. **การอัปโหลด** — ใช้ `multipart/form-data` เท่านั้น (ไม่รองรับ raw body)
4. **ชื่อไฟล์** — ต้องระบุ `fileName` ให้ถูกต้อง รวมนามสกุล เพื่อป้องกันการเขียนทับไฟล์อื่น
5. **XML** — ระบบตรวจสอบความถูกต้องของ XML ก่อนบันทึกเสมอ และเขียนผ่านไฟล์ชั่วคราวเพื่อป้องกันไฟล์เสียหาย
