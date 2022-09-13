In this terraform code below steps would be performed:

Two r5.large EC2 instances will be created in Private Subnet named as private-subnet
with the EC2 name prod-web-server-1 and prod-web-server-2 with a
Security Group named as hiver_SG(keeping 443 and 80 opened) under a target group named as tg which will be attached to 
Network Load Balancer named as hiverNLB
