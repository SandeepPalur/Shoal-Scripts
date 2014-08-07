git clone https://github.com/SandeepPalur/Shoal-Scripts.git 

cd Shoal-Scripts 
 You should see the following script files.Just run these scripts to install shoal-client,shoal-server and shoal-agent  
1. shoal-client.sh(Installs cvmfs client and shoal client)
2. shoal-agent.sh(Installs squid and shoal agent)
3. shoal-server.sh(Installs and hosts shoal server on port 80)

OR If you want to pass it to Cloud-Init and install it on boot of VM,follow the below steps: 

yum -y install cloud-utils
write-mime-multipart --output=shoal-client-mime.txt shoal-client.sh:text/x-shellscript
write-mime-multipart --output=shoal-agent-mime.txt shoal-agent.sh:text/x-shellscript
ec2-run-instances ami-9fd2a9af --region us-west-2 -z us-west-2a -g sg-17ec5472 -n 1 --kernel aki-fc8f11cc -t t2.micro -k key -f shoal-agent-mime.txt
ec2-run-instances ami-9fd2a9af --region us-west-2 -z us-west-2a -g sg-17ec5472 -n 1 --kernel aki-fc8f11cc -t t2.micro -k key -f shoal-client-mime.txt

