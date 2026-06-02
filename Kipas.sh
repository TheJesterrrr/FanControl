#!/bin/bash

# Check Root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "[ ERROR ] Harap jalankan script ini dengan sudo!"
        echo "Contoh: sudo ./atur_kipas.sh"
        exit 1
    fi
}

# Status
show_status() {
    echo "======================================"
    echo "STATUS KIPAS THINKPAD SAAT INI:"
    echo "======================================"
    cat /proc/acpi/ibm/fan | grep -E "status|speed|level"
    if systemctl is-active --quiet thinkfan; then
        echo "Layanan Otomatis (thinkfan): AKTIF"
    else
        echo "Layanan Otomatis (thinkfan): NONAKTIF (Mode Manual)"
    fi
    echo "======================================"
}


set_manual_fan() {
    local level=$1
    echo "[*] Menghentikan layanan otomatis (thinkfan)..."
    systemctl stop thinkfan
    echo "[*] Mengatur kecepatan kipas ke: level $level"
    echo "level $level" > /proc/acpi/ibm/fan
    echo "[ SUCCESS ] Berhasil diubah."
    echo ""
    read -n 1 -s -r -p "Tekan tombol apa saja untuk kembali ke menu..."
}


set_auto_fan() {
    echo "[*] Mengaktifkan kembali layanan otomatis (thinkfan)..."
    echo "level auto" > /proc/acpi/ibm/fan
    systemctl start thinkfan
    echo "[ SUCCESS ] Kipas sekarang dikendalikan otomatis oleh thinkfan."
    echo ""
    read -n 1 -s -r -p "Tekan tombol apa saja untuk kembali ke menu..."
}

monitor_fan() {
    echo "Memantau status kipas secara real-time... (Tekan Ctrl+C untuk berhenti)"
    sleep 1
    watch -n 1 "cat /proc/acpi/ibm/fan; echo '---'; systemctl is-active thinkfan"
}

# Main Loop
check_root

while true; do
    clear
    show_status
    echo "PILIH MENU PENGATURAN KIPAS:"
    echo "1) Matikan Kipas (Level 0)"
    echo "2) Kecepatan Rendah (Level 2)"
    echo "3) Kecepatan Sedang (Level 4)"
    echo "4) Kecepatan Maksimal (Level 7)"
    echo "5) Kecepatan TURBO (Full-Speed)"
    echo "6) Kembalikan ke OTOMATIS (thinkfan)"
    echo "7) Pantau Real-Time (Monitor)"
    echo "8) Keluar"
    echo "======================================"
    read -p "Masukkan pilihan Anda [1-8]: " pilihan

    case $pilihan in
        1) set_manual_fan "0" ;;
        2) set_manual_fan "2" ;;
        3) set_manual_fan "4" ;;
        4) set_manual_fan "7" ;;
        5) set_manual_fan "full-speed" ;;
        6) set_auto_fan ;;
        7) monitor_fan ;;
        8) echo "Keluar dari script. Sampai jumpa!"; exit 0 ;;
        *) echo "[ ERROR ] Pilihan tidak valid!"; sleep 1 ;;
    esac
done
