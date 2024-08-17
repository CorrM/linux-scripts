#!/bin/bash

# Menu function
docker_menu() {
    check_root
    if ! check_pacman; then
        return 1
    fi

    local options=(
        "Back to main menu"
        "Install docker"
        "Install portainer CE"
        "Create docker group"
        "Fix docker folder premisions"
        "Start on boot"
        "Stop on boot"
        "Faster image build (overlay diff engine)"
        "Nvidia GPU acceleration"
        "Test Nvidia GPU acceleration"
        "Get all containers IPs"
    )
    while true; do
        show_menu "Docker Utils" "Utilities for Docker" "${options[@]}"
        choice=$?

        # TODO: Add rootless https://docs.docker.com/engine/security/rootless/
        case $choice in
            1) return 0 ;;
            2) docker_install ;;
            3) docker_portainer ;;
            4) docker_create_group ;;
            5) docker_fix_folder_permisions ;;
            6) docker_start_on_boot ;;
            7) docker_stop_on_boot ;;
            8) docker_fast_image_build ;;
            9) docker_nvidia_acceleration ;;
            10) docker_test_nvidia_acceleration ;;
            11) docker_get_ip_of_containers ;;
            *) print_color "$RED" "Invalid option. Please try again." ;;
        esac
        pause
    done
}

docker_install() {
    print_color "$YELLOW" "Install docker and docker compose..."
    sudo pacman -S docker docker-compose --noconfirm --needed
}

docker_portainer() {
    if ! check_docker; then
        print_color "$RED" "Docker should be installed."
        return
    fi
    
    print_color "$YELLOW" "Install Portainer CE..."
    docker volume create portainer_data
    docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
    xdg-open https://localhost:9443
}

docker_create_group() {
    print_color "$YELLOW" "Create the docker group and add your user..."

    sudo groupadd docker
    sudo usermod -aG docker $USER
    sudo newgrp docker
}

docker_fix_folder_permisions() {
    print_color "$YELLOW" "Fixing docker folder premisions..."

    sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
    sudo chmod g+rwx "$HOME/.docker" -R
}

docker_start_on_boot() {
    print_color "$YELLOW" "Start on boot with systemd..."

    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
}

docker_stop_on_boot() {
    print_color "$YELLOW" "Start on boot with systemd..."

    sudo systemctl disable docker.service
    sudo systemctl disable containerd.service
}

docker_fast_image_build() {
    print_color "$YELLOW" "Enable native overlay diff engine..."

    sudo systemctl stop docker.service

    sudo pacman -S fuse-overlayfs --noconfirm --needed
    local conf_file="/etc/modprobe.d/disable-overlay-redirect-dir.conf"
    local option="options overlay metacopy=off redirect_dir=off"

    if [ -f "$conf_file" ]; then
        if grep -q "$option" "$conf_file"; then
            print_color "$GREEN" "The required option is already present in $conf_file."
        else
            echo "$option" >> "$conf_file"
            print_color "$GREEN" "Added the required option to $conf_file."
        fi
    else
        echo "$option" > "$conf_file"
        print_color "$GREEN" "Created $conf_file with the required option."
    fi

    sudo modprobe -r overlay
    sudo modprobe overlay

    sudo systemctl start docker.service
}

docker_nvidia_acceleration() {
    print_color "$YELLOW" "Add nvidia GPU acceleration..."

    sudo pacman -S nvidia-container-toolkit --noconfirm --needed
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker
}

docker_test_nvidia_acceleration() {
    print_color "$YELLOW" "Test nvidia GPU acceleration..."

    docker run --gpus all nvidia/cuda:12.6.0-runtime-ubuntu20.04 nvidia-smi
}

docker_get_ip_of_containers() {
    print_color "$YELLOW" "Getting all containers IPs"

    for ID in $(docker ps -q | awk '{print $1}'); do
        IP=$(docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" "$ID")
        NAME=$(docker ps | grep "$ID" | awk '{print $NF}')
        printf "%s %s\n" "$IP" "$NAME"
    done
}
