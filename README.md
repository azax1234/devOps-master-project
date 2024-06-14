# devOps-master-project
The Spring boot app runs on port 8075 as defined in src/main/resources/application.properties

## Plug-Ins (apart from the defaults)

1. Docker Pipeline - to use container as node.

2. SonarQube Scanner



## To be installed in Node

1. Docker - ansible playbook
2. jenkins - ansible playbook
3. sonarqube - dont use ansible playbook, use below

sudo apt install unzip
sudo adduser sonarqube #this will prompt for crating password
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.4.0.54424.zip
unzip *
chmod -R 755 sonarqube-9.4.0.54424
chown -R sonarqube:sonarqube sonarqube-9.4.0.54424
cd sonarqube-9.4.0.54424/bin/linux-x86-64/
su sonarcube
./sonar.sh start

### Sonar UI will start on port 9000. default user is admin:admin
### To auhenticate sonar server in Jenkins, create a token under my accounts->security in sonar and add as a secret text with id 'sonar' in jenkins