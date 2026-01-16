#!/bin/bash
    sudo apt-get update
    sudo apt-get install -y nginx
    echo "<h1>Hello, World from The Lighthouse!</h1><p>This page is served by a VM managed by Terraform.</p>" | sudo tee /var/www/html/index.html