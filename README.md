# Custom Windows Server Image: Auto Installer Guide

Panduan ini membantu kamu membuat dan meng-deploy custom Windows Server image menggunakan VPS + QEMU.

---

## 1. Download & Setup Installer

Download script installer:

```bash id="p8r1j3"
wget https://raw.githubusercontent.com/syx-tar/Custom-Windows-Server-Image/main/windows-server-autoinstaller.sh
```

Berikan permission agar bisa dijalankan:

```bash id="3b9k7s"
chmod +x windows-server-autoinstaller.sh
```

Jalankan installer:

```bash id="zqk6tw"
./windows-server-autoinstaller.sh
```

---

Tinggal ditunggu hingga selesai.

### Navigasi tmux:

* Keluar dari session:

  ```
  Ctrl + B, lalu tekan D
  ```
* Masuk kembali:

  ```bash
  tmux attach -t windows
  ```

### Download via browser:

Kompress Windows Server Img kalian

```bash
dd if=windows2xxx.img | gzip -c>windows2xxx.gz
```

Link untuk download

```id="t6cbv1"
http://IP_VPS:3923/windows2xxx.gz
```

---

## 5. Setup Akses RDP

### Cara 1: Upload ke DigitalOcean

1. Buka:

   ```
   https://cloud.digitalocean.com/images/custom_images
   ```
2. Klik Upload an Image
3. Pilih Import via URL
4. Masukkan:

   ```
   http://IP_VPS:3923/windows2xxx.gz
   ```
5. Atur:

   * Region sesuai kebutuhan
   * Distribution pilih Other
6. Klik Upload

Proses upload dan extract membutuhkan waktu.

---

### Cara 2: Deploy Manual ke Droplet

Gunakan perintah berikut:

```bash id="p9r6c2"
curl -L [http://168.144.81.209:3923/GSWin11_Pro.gz](http://IP_VPS:3923/windows2xxx.gz) | gunzip | dd of=/dev/vda bs=1M status=progress
```

Atau ikuti tutorial video:

```id="x2h8vn"
https://www.youtube.com/watch?v=U8b3y2hVum8&t=510s
```

---

## Catatan Tambahan

* Pastikan VPS memiliki resource yang cukup (RAM dan CPU)
* Gunakan koneksi stabil saat upload/download image
* Periksa kembali nama file sebelum menjalankan perintah

---

Selesai.
