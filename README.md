# SRU Faculty Senate Complaint System

ระบบรับเรื่องร้องเรียนสำหรับ **สภาคณาจารย์ มหาวิทยาลัยราชภัฏสุราษฎร์ธานี** พัฒนาด้วย PHP 8.2+ และ MySQL/MariaDB โดยเน้นความปลอดภัยและการคุ้มครองข้อมูลส่วนบุคคล

## ความสามารถหลัก

- หน้าบ้านสำหรับรับเรื่องร้องเรียน พร้อมคำชี้แจงการใช้งาน
- ตรวจสอบเลขบัตรประชาชนไทย 13 หลักด้วย checksum ทั้งฝั่ง Browser และ Server
- รับชื่อ–สกุล รายละเอียดเรื่องร้องเรียน หมายเลขโทรศัพท์ และอีเมล
- ผู้ใช้ต้องยืนยันว่าเบอร์โทรศัพท์และอีเมลเป็นข้อมูลจริงสำหรับติดต่อกลับ
- ตั้งค่าประเภทเรื่องร้องเรียนจากระบบหลังบ้าน
- กำหนดผู้รับอีเมล/คณะกรรมการแยกตามประเภทเรื่อง
- ระบบล็อกอินเจ้าหน้าที่และ Super Admin เพิ่มผู้ดูแลระบบได้
- Dashboard, รายการเรื่องร้องเรียน, เปลี่ยนสถานะเรื่อง
- Audit log การเข้าดู/เปลี่ยนสถานะ/การจัดการค่าระบบ
- เข้ารหัสเลขบัตรประชาชน ชื่อ เบอร์โทรศัพท์ และอีเมลด้วย AES-256-GCM ก่อนเก็บฐานข้อมูล
- PDO prepared statements (`ATTR_EMULATE_PREPARES=false`) เพื่อป้องกัน SQL Injection
- CSRF token, secure session cookie, SameSite, security headers, output escaping
- Login throttling จากฐานข้อมูลตามบัญชี/IP และเก็บเฉพาะค่า hash ของ username/IP
- Honeypot + จำกัดการส่งแบบฟอร์มสาธารณะ 10 ครั้ง/30 นาทีต่อ IP hash เพื่อลด bot/spam
- GitHub Actions ตรวจ PHP syntax และ `composer audit`

## โครงสร้าง

```text
src/                 core security/database/auth/mail
public/              web root
public/admin/        back office
public/admin/actions state-changing admin handlers
database/schema.sql  MariaDB/MySQL schema
bin/                 CLI setup tools
docs/index.html      static UI preview for GitHub Pages
```

> **สำคัญ:** ตั้ง Document Root ของเว็บไซต์ไปที่โฟลเดอร์ `public/` เท่านั้น อย่าชี้ web root ไปที่ root ของ repository เพื่อป้องกัน `.env`, source และไฟล์ตั้งค่าถูกดาวน์โหลดจากเว็บ

## ติดตั้ง

1. ต้องมี PHP 8.2+, PDO MySQL, OpenSSL, mbstring และ Composer
2. รัน `composer install --no-dev --optimize-autoloader`
3. สร้างฐานข้อมูลด้วย `database/schema.sql`
4. คัดลอก `.env.example` เป็น `.env`
5. สร้างคีย์เข้ารหัส:
   ```bash
   php bin/generate-key.php
   ```
   นำค่าที่ได้ไปใส่ `APP_KEY` ใน `.env`
6. ตั้งค่า DB และ SMTP ใน `.env`
7. สร้าง Super Admin คนแรก:
   ```bash
   php bin/create-admin.php admin "ชื่อผู้ดูแล" admin@example.ac.th "รหัสผ่านที่ยาวและคาดเดายาก"
   ```
8. ตั้ง Document Root ไปที่ `/path/to/project/public`
9. บังคับ HTTPS และตั้งค่า TLS certificate ที่ Web Server/Reverse Proxy

## ข้อจำกัดของการตรวจเลขบัตรประชาชน

การตรวจ **13 หลัก + checksum** สามารถคัดกรองเลขที่พิมพ์ผิดหรือเลขสุ่มทั่วไปได้ แต่ **ไม่สามารถยืนยันว่าเลขนั้นถูกออกโดยรัฐจริง หรือเป็นของผู้กรอกจริง** เพราะผู้ไม่หวังดีสามารถสร้างเลขที่ผ่าน checksum ได้ หากต้องการยืนยันตัวบุคคลจริง ควรเชื่อมระบบ Digital ID/ThaID หรือ Identity Provider ที่หน่วยงานได้รับอนุญาตให้ใช้งาน แทนการพึ่ง checksum เพียงอย่างเดียว

## GitHub Pages UI Preview

GitHub Pages รัน PHP ไม่ได้ จึงมี `docs/index.html` สำหรับ **ตัวอย่างหน้าจอเท่านั้น** เมื่อสร้าง repository ใหม่แล้วสามารถตั้งค่า Pages เป็น `Deploy from a branch` และเลือก `/docs` เพื่อแสดงตัวอย่าง UI ได้ ส่วนระบบจริงต้อง deploy บน PHP server

## แนวทาง Production เพิ่มเติม

- ใช้ HTTPS เท่านั้น และเปิด HSTS หลังยืนยันว่าโดเมน/ซับโดเมนรองรับ HTTPS ครบ
- จำกัดสิทธิ์ DB user เฉพาะฐานข้อมูลนี้ ไม่ใช้ root
- `.env` ต้องอยู่นอก `public/`, permission แนะนำ 600 และไม่ commit เข้า Git
- Backup DB แบบเข้ารหัสและทดสอบ restore เป็นระยะ
- ใช้ SMTP account เฉพาะระบบและหมุนรหัสผ่าน/secret เป็นระยะ
- แนะนำเพิ่ม MFA/2FA สำหรับบัญชีเจ้าหน้าที่ หากระบบใช้งานจริงในวงกว้าง
- แนะนำ Reverse Proxy rate limit หรือ WAF (เช่น ModSecurity/Cloudflare ตามนโยบายมหาวิทยาลัย)
- ทำ retention policy สำหรับข้อมูลร้องเรียนและ audit logs ตามนโยบาย/กฎหมายที่เกี่ยวข้อง

## หมายเหตุด้านอีเมล

อีเมลแจ้งเตือนไม่ส่งเลขบัตรประชาชน เบอร์โทร หรืออีเมลผู้ร้องเรียนโดยตรง ผู้รับจะได้รับเลขที่เรื่องและลิงก์ให้เข้าสู่ระบบเพื่อดูรายละเอียด ช่วยลดการกระจายข้อมูลส่วนบุคคลไปยัง mailbox หลายแห่ง
