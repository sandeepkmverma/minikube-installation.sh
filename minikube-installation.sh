#!/bin/bash

check_user(){

    if [ "$(whoami)" == "root" ]
    then
        echo "Please switch to the non-root user"
        exit
    fi

}


create_dir(){

    mkdir ~/kubernetes_test
    cd ~/kubernetes_test
}

install_kubectl(){

    echo "Downloading the release"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

    echo ""

    echo "Validating the binary"
    curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(<kubectl.sha256) kubectl" | sha256sum --check

    echo ""

    echo "Installing kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    echo ""

    echo "Testing the version"
    kubectl version --client
    
}

install_minikube(){

    sudo usermod -aG docker "$(whoami)"

/usr/bin/newgrp docker <<EONG

    echo "Downloading Minikube"
    echo ""
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    echo ""
    echo "Installing Minikube"
    echo ""    
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    minikube config set driver docker
    minikube start --driver=docker
    kubectl get ns
    echo ""
    echo "Minikube is successfully Installed"
    echo ""    
EONG
    newgrp docker
    
}



install_docker(){

    sudo apt-get update -y
    
    sudo apt-get install -y apt-transport-https \
                            ca-certificates \
                            curl \
                            gnupg \
                            lsb-release
    
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io
    sudo systemctl start docker
    sudo systemctl enable docker
}



check_docker(){

    which docker &> /dev/null
        if [ $? -eq 0 ]
        then
            echo "Docker is already installed"
        else
            echo "Installing Docker"
            install_docker
        fi

}


check_kubectl(){

    which kubectl &> /dev/null
        if [ $? -eq 0 ]
        then
            echo "Kubectl is already installed"
        else
            echo "Installing Kubectl"
            install_kubectl
        fi

}

check_minikube(){

    which minikube &> /dev/null
        if [ $? -eq 0 ]
        then
            echo "Minikube is already installed"
        else
            install_minikube
        fi

}


main(){

    check_user
    create_dir
    check_docker
    check_kubectl
    check_minikube
}

main







