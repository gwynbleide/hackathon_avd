# Azure Virtual Desktop Custom Image Template

## 🎯 Overview

Build a custom image template for Azure Virtual Desktop (AVD) using Azure Image Builder to create a standardized, optimized virtual desktop image for your organization.

## 🏆 Objectives

### Image template
- [ ] Create an Azure Compute Gallery
- [ ] Create User assigned identity with required permissions (least privileged model suggest creating a custom role, for this hackathon purpose, assign an Owner role the resource groups you are using for image build)
- [ ] Define an image definition for Windows 11 Enterprise multi-session 25H2 image
- [ ] Create an Image Builder template
- [ ] Set default language to Czech
- [ ] Disable Storage sense
- [ ] Configure FSlogix profiles
- [ ] Uninstall unnecessary AppX packages
- [ ] Using custom script, install custom SW. Use prepared script and SW
- [ ] Use Azure Compute Gallery to store the image
- [ ] Select appropriate VM image build size

### Run build
- [ ] Run the image build
- [ ] Access the image build console to verify the progress of the image build
- [ ] After the successfull build, check the output logs to see the image build progress

### Deployment
- [ ] Redeploy the Session hosts with the newly build image

## 📚 Resources

- [AVD Custom image overview](https://learn.microsoft.com/en-us/azure/virtual-desktop/custom-image-templates)
- [AVD Create custom image](https://learn.microsoft.com/en-us/azure/virtual-desktop/create-custom-image-templates)