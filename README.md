# Laravel Administrable Deploy

[![Packagist](https://img.shields.io/packagist/v/guysolamour/laravel-administrable-deploy.svg)](https://packagist.org/packages/guysolamour/laravel-administrable-deploy)
[![Packagist](https://poser.pugx.org/guysolamour/laravel-administrable-deploy/d/total.svg)](https://packagist.org/packages/guysolamour/laravel-administrable-deploy)
[![Packagist](https://img.shields.io/packagist/l/guysolamour/laravel-administrable-deploy.svg)](https://packagist.org/packages/guysolamour/laravel-administrable-deploy)

This package allows you to deploy a website on a dedicated server or a VPS by installing the various tools necessary for the operation of the site and by automating the deployment process.

---

### Prerequis
1. Works on Unix type system (MacOs and Linux)
2. Ubuntu Server operating system
3. have a bash version >= 4 (you can do ```bash --version ```) otherwise update the bash shell
4. Instal ansible (https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
5. Instal anistrano (https://ansistrano.com)

### Installation

Install via composer
```bash
composer require guysolamour/laravel-deploy
```

### Preparing the server

1- Connect to the server
```bash
ssh root@000.000.000.000
# 000.000.000.000 must be changed with your server ip address
```


2- Create a user to run the tasks
```bash
sudo useradd user -s /bin/bash -d /home/user -m -G sudo
# user must be changed with your own user
```

3- Add created user to sudoers file
```bash
sudo visudo
# Append user ALL=(ALL) NOPASSWD:ALL at the end of line
# user must be changed with your own user
```

4- Install python on the remote server
```bash
sudo apt install -y python-apt
```

5- Disconnect from the remote machine and copy host machine ssh key for the created user
```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub user@000.000.000.000
# If you dont have generate ssh key before use sshkeygen command to generate newly key
# 000.000.000.000 must be changed with your server ip address
```

### Scaffold

Run the scaffold command to generate the necessary base files. This command must be executed once and at the very beginning.

```bash
./vendor/bin/deploy scaffold --host 000.001.002.003 --domain domain.com --application appname
```


THE DIFFERENT STEPS

1- Generate the file that will contain the passwords
```bash
./vendor/bin/deploy password:create
# Enter the password that will be used for decryption
# This password must be saved in clear in the .vaultpass file
# This file must not be versioned.
```

2- Add theses variables with the correct data
```yaml

# The deployement user password. The user created on the server.
vault_user_password: "password"

# The deployment database password
vault_database_password: "password"

# The database root user password
vault_database_root_password: "password"

# The administrator password for admin panel in local
vault_admin_local_password: "password"

# The administrator password for admin panel in production
vault_admin_production_password: "password"

# The ftp password for backup. Can be blank.
vault_ftp_password: "password"

# Copy and paste the output of *php artisan key:generate --show command
vault_app_key: "base64:appkey"
```


3- To modify the file containing the passwords
```bash
./vendor/bin/deploy password:edit
```

4- To view the contents of the file
```bash
./vendor/bin/deploy password:view
```

4- To delete the contents of the file
```bash
./vendor/bin/deploy password:delete
```

### Available commands

1. **help**
2. **scaffold**
3. **configure:server**
4. **password:create**
5. **password:view**
6. **password:edit**
7. **password:delete**
8. **run**
9. **rollback**
10. **db:seed**
11. **db:deploy**
12. **db:dump**
13. **db:run**
14. **db:import**
15. **storage:dump**
16. **storage:import**
17. **storage:deploy**
18. **exec**
19. **dkim**
20. **clean**
21. **ssh**
22. **env:deploy**


### Help
Get more informations
```sh
./vendor/bin/deploy help
```

### Configure server
Run **configure:server** command to install all necessary softwares for a laravel project on the VPS (php, mysql, nginx ...).

```sh
./vendor/bin/deploy configure:server
```


### Deploy

```sh
./vendor/bin/deploy run
```


### Rollback

```sh
./vendor/bin/deploy rollback
```


### Seed database

```sh
./vendor/bin/deploy db:seed
```


### Database deploy
Copy and import local database into remote database

```sh
./vendor/bin/deploy db:deploy
```


### Database import
Copy and import remote database into local database

```sh
./vendor/bin/deploy db:import
```


### Database dump

Dump local database

```sh
./vendor/bin/deploy db:dump
```

### Storage deploy
Copy and import local storage folder into remote storage folder

```sh
./vendor/bin/deploy storage:deploy
```


### Storage import
Copy and import remote storage folder into local storage folder

```sh
./vendor/bin/deploy storage:import
```



### Exec

Run a shell command online

```sh
./vendor/bin/deploy exec "pwd"
```


### Dkim

Display DKIM public key

```sh
./vendor/bin/deploy dkim
```


### Clean
Remove temporary files

```sh
./vendor/bin/deploy clean
```


### SSH

SSH into remote project

```sh
./vendor/bin/deploy ssh
```

If you discover any security related issues, please email rolandassale@gmail.com
instead of using the issue tracker.

## Credits

- [Guy-roland ASSALE](https://github.com/guysolamour/laravel-administrable-deploy)
- [All contributors](https://github.com/guysolamour/laravel-administrable-deploy/graphs/contributors)

This package is bootstrapped with the help of
[melihovv/laravel-package-generator](https://github.com/melihovv/laravel-package-generator).
