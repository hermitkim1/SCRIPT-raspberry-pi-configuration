# This is Alvin's script for 
# default configuration of Raspberry Pi.

# To update system
echo ======================
echo == To update system ==
echo ======================
sleep 2
sudo apt update -y
sudo apt upgrade -y

# To install vim
echo ====================
echo == To install vim ==
echo ====================
sleep 2
sudo apt install vim -y

# To install Nanum fonts for Korean
echo ===========================
echo == To install Naum fonts ==
echo ===========================
sleep 2
sudo apt install fonts-nanum fonts-nanum-extra -y

# To install and enable ufw (Ubuntu Firewall) - Recommended
# echo ===============================
# echo == To install and enable ufw ==
# echo ===============================
# sleep 2
# sudo apt install ufw -y
# sudo ufw enable
# sudo ufw status
# sudo ufw allow ssh # allow ssh

# To install fail2ban
echo =========================
echo == To install fail2ban ==
echo =========================
sleep 2
sudo apt install fail2ban -y

# To setup fail2ban
echo == To setup fail2ban
sleep 2
echo "[ssh]" >> /etc/fail2ban/jail.local
echo "" >> /etc/fail2ban/jail.local
echo "enabled = true" >> /etc/fail2ban/jail.local
echo "port = ssh" >> /etc/fail2ban/jail.local
echo "filter = sshd" >> /etc/fail2ban/jail.local
echo "logpath = /var/log/auth.log" >> /etc/fail2ban/jail.local
echo "bantime = 900" >> /etc/fail2ban/jail.local
echo "banaction = iptables-allports" >> /etc/fail2ban/jail.local
echo "findtime = 900" >> /etc/fail2ban/jail.local
echo "maxretry = 3" >> /etc/fail2ban/jail.local

# To restart fail2ban service
echo == To restart fail2ban service
sleep 2
sudo systemctl restart fail2ban

# To install Docker engine
echo ==============================
echo == To install Docker engine ==
echo ==============================
sleep 2
wget -qO- get.docker.com | sh
# To check successful Docker installation
sudo docker info

# To setup bash-completion for git (Optional)
# echo "" >> ~/.bashrc
echo ======================================
echo == To setup bash-completion for git ==
echo ===============Optional===============
sleep 2
# echo "source /usr/share/bash-completion/completions/git" >> ~./bashrc
