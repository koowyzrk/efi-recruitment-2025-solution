#!/bin/bash

read -p "Podaj nazwę użytkownika SSH dla połączenia z VM (np. Twoja nazwa użytkownika GCP, 'efi_user', 'weather_app'): " SSH_USER

PROJECT_ROOT=$(pwd)

echo "Wybierz środowisko wdrożenia:"
echo "1) Chmura (Google Cloud VM)"
echo "2) Lokalnie (na Twojej maszynie)"
read -p "Wybierz opcję (1/2): " DEPLOY_ENV

if [ "$DEPLOY_ENV" == "1" ]; then
  echo "-------------------------------------"
  echo "Krok 1: Uruchamianie Terraform w chmurze..."
  echo "-------------------------------------"
  cd "$PROJECT_ROOT/terraform"
  terraform init
  terraform apply -auto-approve
  IP_ADDRESS=$(terraform output -raw ip)
  cd "$PROJECT_ROOT"

  if [ -z "$IP_ADDRESS" ]; then
    echo "BŁĄD: Nie udało się uzyskać adresu IP z Terraform."
    exit 1
  fi

  echo "-------------------------------------"
  echo "Adres IP instancji w chmurze: $IP_ADDRESS"
  echo "-------------------------------------"

  echo "Krok 2: Oczekiwanie na uruchomienie maszyny wirtualnej i SSH..."
  ATTEMPTS=0
  MAX_ATTEMPTS=10
  while ! ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$IP_ADDRESS" exit 2>/dev/null && [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    echo "Czekam na połączenie SSH z $IP_ADDRESS... Próba $((ATTEMPTS + 1))"
    sleep 15
    ATTEMPTS=$((ATTEMPTS + 1))
  done

  if [ $ATTEMPTS -eq $MAX_ATTEMPTS ]; then
    echo "BŁĄD: Nie udało się połączyć SSH z instancją po wielu próbach."
    exit 1
  fi

  echo "-------------------------------------"
  echo "Krok 3: Uruchamianie Ansible playbook dla chmury..."
  echo "-------------------------------------"
  cd "$PROJECT_ROOT/ansible"
  ansible-playbook -i "$IP_ADDRESS," --user="$SSH_USER" deploy_app.yml

  echo "-------------------------------------"
  echo "Wdrożenie do chmury zakończone. Aplikacja powinna być dostępna pod http://$IP_ADDRESS"
  echo "-------------------------------------"

elif [ "$DEPLOY_ENV" == "2" ]; then
  echo "-------------------------------------"
  echo "Krok 1: Uruchamianie Ansible playbook lokalnie..."
  echo "-------------------------------------"
  cd "$PROJECT_ROOT/ansible"
  ansible-playbook -i inventory.ini deploy_local.yml --limit local

  echo "-------------------------------------"
  echo "Wdrożenie lokalne zakończone. Aplikacja powinna być dostępna pod http://localhost:8000"
  echo "-------------------------------------"

else
  echo "Niepoprawny wybór. Anulowanie wdrożenia."
  exit 1
fi
