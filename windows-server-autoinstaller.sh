#!/bin/bash

display_menu() {
    echo "Please select the Windows Server version:"
    echo "1. Windows Server 2016"
    echo "2. Windows Server 2019"
    echo "3. Windows Server 2022"
    echo "4. Windows Server 2025"
    read -p "Enter your choice: " choice
}

# Update & install
apt-get update && apt-get upgrade -y
apt install qemu-utils qemu-system-x86 qemu-kvm cpu-checker tmux -y

# Open ports
ufw allow 3923
ufw allow 5900

echo "Port 3923 dan 5900 sudah dibuka."

# Download copyparty
wget https://github.com/9001/copyparty/releases/latest/download/copyparty-sfx.py

# Start tmux session for copyparty
tmux new-session -d -s windows "python3 copyparty-sfx.py"
echo "tmux session 'windows' sudah jalan."

# Menu pilihan Windows
display_menu

case $choice in
    1)
        img_file="windows2016.img"
        iso_link="https://go.microsoft.com/fwlink/p/?LinkID=2195174&clcid=0x409&culture=en-us&country=US"
        iso_file="windows2016.iso"
        ;;
    2)
        img_file="windows2019.img"
        iso_link="https://go.microsoft.com/fwlink/p/?LinkID=2195167&clcid=0x409&culture=en-us&country=US"
        iso_file="windows2019.iso"
        ;;
    3)
        img_file="windows2022.img"
        iso_link="https://go.microsoft.com/fwlink/p/?LinkID=2195280&clcid=0x409&culture=en-us&country=US"
        iso_file="windows2022.iso"
        ;;
    4)
        img_file="windows2025.img"
        iso_link="https://go.microsoft.com/fwlink/p/?linkid=2293312&clcid=0x409&culture=en-us&country=US"
        iso_file="windows2025.iso"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo "Selected: $img_file"

# Input RAM dengan peringatan
echo ""
echo "⚠️  PERINGATAN:"
echo "Gunakan RAM secukupnya, jangan menggunakan seluruh RAM VPS."
echo "Disarankan sisakan minimal 1–2 GB untuk OS agar tidak crash."
echo ""

read -p "Masukkan jumlah RAM (GB): " RAM
read -p "Masukkan jumlah CPU core: " CPU

# Create disk
qemu-img create -f raw "$img_file" 20G
echo "Disk image dibuat."

# Download virtio
wget -O virtio-win.iso 'https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.285-1/virtio-win-0.1.285.iso'
echo "Virtio driver downloaded."

# Download Windows ISO
wget -O "$iso_file" "$iso_link"
echo "Windows ISO downloaded."

# Check KVM
KVM_STATUS=$(kvm-ok 2>&1)
echo "$KVM_STATUS"

if echo "$KVM_STATUS" | grep -q "KVM acceleration can be used"; then
    echo "KVM aktif, menggunakan akselerasi."

    CMD="qemu-system-x86_64 \
    -m ${RAM}G \
    -smp ${CPU} \
    -cpu host \
    -enable-kvm \
    -boot order=d \
    -drive file=${iso_file},media=cdrom \
    -drive file=${img_file},format=raw,if=virtio \
    -drive file=virtio-win.iso,media=cdrom \
    -device usb-ehci,id=usb,bus=pci.0,addr=0x4 \
    -device usb-tablet \
    -vnc :0"

else
    echo "KVM tidak tersedia, menggunakan mode biasa."

    CMD="qemu-system-x86_64 \
    -m ${RAM}G \
    -smp ${CPU} \
    -cpu qemu64 \
    -boot order=d \
    -drive file=${iso_file},media=cdrom \
    -drive file=${img_file},format=raw,if=virtio \
    -drive file=virtio-win.iso,media=cdrom \
    -device usb-ehci,id=usb,bus=pci.0,addr=0x4 \
    -device usb-tablet \
    -vnc :0"
fi

# Jalankan VM dalam tmux
tmux new-session -d -s qemu_vm "$CMD"

echo ""
echo "✅ VM berhasil dijalankan!"
echo "Session tmux:"
echo "- copyparty  : tmux attach -t windows"
echo "- VM Windows : tmux attach -t qemu_vm"
echo ""
echo "Akses VNC di port 5900"
