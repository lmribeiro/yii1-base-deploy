# Yii1 Base Deploy

Deploy Yii1 Base Application to Server via SSH by RSync

## Config example:

```
name: Build and Deploy
on:
    push:
        branches:
            -   master

jobs:
    build:
        name: Build and Deploy
        runs-on: ubuntu-latest
        steps:
            -   name: Checkout Repository
                uses: actions/checkout@master

            -   name: Setup Enviroment
                uses: shivammathur/setup-php@v2
                with:
                    php-version: '7.1'

            -   name: Speed up the packages installation process
                run: composer global require hirak/prestissimo

            -   name: Install Packages
                run: composer install --no-dev

            -   name: Deploy to Server
                uses: yiier/yii1-base-deploy@master
                with:
                    user: user
                    host: host
                    path: path
                    owner: owner
                env:
                    DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
```
