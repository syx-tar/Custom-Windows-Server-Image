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

## 2. Menjalankan QEMU

Catatan:

* Ganti `windows2xxx` sesuai versi Windows yang kamu gunakan
* Sesuaikan `-m` (RAM) dan `-smp` (CPU core) dengan spesifikasi VPS
* Gunakan RAM secukupnya, jangan menggunakan seluruh RAM VPS (disarankan sisakan minimal 1–2 GB untuk OS)

### Cek Dukungan KVM

Jalankan perintah berikut:

```bash id="lq1k0a"
kvm-ok
```

Jika hasilnya:

```
INFO: /dev/kvm exists
KVM acceleration can be used
```

Gunakan perintah berikut (lebih cepat karena hardware acceleration):

```bash id="7t7bqz"
qemu-system-x86_64 \
-m 5G \
-smp 4 \
-cpu host \
-enable-kvm \
-boot order=d \
-drive file=windows2xxx.iso,media=cdrom \
-drive file=windows2xxx.img,format=raw,if=virtio \
-drive file=virtio-win.iso,media=cdrom \
-device usb-ehci,id=usb,bus=pci.0,addr=0x4 \
-device usb-tablet \
-vnc :0
```

Jika tidak tersedia KVM, gunakan perintah berikut:

```bash id="9v4u3g"
qemu-system-x86_64 \
-m 5G \
-smp 4 \
-cpu qemu64 \
-boot order=d \
-drive file=windows2xxx.iso,media=cdrom \
-drive file=windows2xxx.img,format=raw,if=virtio \
-drive file=virtio-win.iso,media=cdrom \
-device usb-ehci,id=usb,bus=pci.0,addr=0x4 \
-device usb-tablet \
-vnc :0
```

---

## 3. Akses via VNC

1. Buka RealVNC Viewer
2. Masukkan alamat:

   ```
   IP_VPS:5900
   ```
3. Klik Connect
4. Setelah terhubung, ikuti panduan video berikut:
   https://www.youtube.com/watch?v=h4q_TEXz9_Y&t=524s

---

## 4. Download File Custom Windows Server

### Kompres image Windows:

```bash id="j0i6fi"
dd if=windows2xxx.img | gzip -c > windows2xxx.gz
```

### Install Copyparty & tmux:

```bash id="k3kq2u"
wget https://github.com/9001/copyparty/releases/latest/download/copyparty-sfx.py
apt install tmux -y
```

### Buka port:

```bash id="g5q2m1"
sudo ufw allow 3923
```

### Jalankan tmux session:

```bash id="3j9w6m"
tmux new -s windows
```

### Jalankan Copyparty server:

```bash id="r8j0xn"
python3 copyparty-sfx.py
```

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
wget -O- --no-check-certificate http://IP_VPS:3923/windows2xxx.gz | gunzip | dd of=/dev/vda
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
