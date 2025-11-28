# Prerequisites for Azure Virtual Desktop Deployment

This guide covers the prerequisites for deploying Azure Virtual Desktop (AVD) for both **Desktop** and **Remote App** scenarios.

## Common Prerequisites

### Azure Subscription Requirements
- Active Azure subscription with sufficient permissions
- **Role required**: Contributor or Owner on the subscription/resource group
- Sufficient quota for virtual machines in your target region

### Entra ID
- Azure AD tenant synchronized with your subscription
- Users must exist in Azure AD (cloud-only or hybrid identities)
- If using hybrid identities: Azure AD Connect configured and syncing

### Networking
- **Virtual Network (VNet)** in your target Azure region
- **Subnet** with sufficient IP addresses for session hosts
- If hybrid: VPN Gateway or ExpressRoute for on-premises connectivity
- DNS configured to resolve domain names (AD DS or Azure AD DS)

### Identity Provider (Choose One)

| Option | Requirements |
|--------|--------------|
| **Azure AD DS** | Azure AD Domain Services deployed and running |
| **AD DS** | Domain Controller accessible from Azure VNet, Azure AD Connect configured |
| **Azure AD Only** | Intune enrollment required for session hosts |

---

## Desktop Deployment Prerequisites

### Additional Requirements
- [ ] Windows 10/11 Enterprise multi-session image (from Azure Marketplace or custom)
- [ ] FSLogix profile storage (Azure Files or Azure NetApp Files recommended)
- [ ] Storage account with Azure AD authentication enabled (for FSLogix)
- [ ] Application group type: **Desktop**

### Recommended Storage Setup
```
Storage Account → File Share → FSLogix Profiles
├── Premium tier for best performance
└── SMB protocol with Azure AD Kerberos authentication
```

---

## Remote App Deployment Prerequisites

### Additional Requirements
- [ ] Applications to publish identified and documented
- [ ] Windows 10/11 Enterprise multi-session or Windows Server image
- [ ] Applications installed on session host image (or App Attach configured)
- [ ] Application group type: **RemoteApp**
- [ ] MSIX packages prepared (if using MSIX App Attach)

### Application Delivery Options
| Method | Use Case |
|--------|----------|
| **Image-based** | Apps installed directly on golden image |
| **MSIX App Attach** | Dynamic app delivery, easier updates |
| **App-V** | Legacy application virtualization |

---

## Resource Checklist

### Create Before AVD Deployment

| Resource | Purpose | Required For |
|----------|---------|--------------|
| Resource Group | Container for all AVD resources | Both |
| Virtual Network | Network connectivity | Both |
| Subnet | IP allocation for hosts | Both |
| Storage Account | FSLogix profiles | Desktop (recommended for RemoteApp) |
| Azure AD DS / AD DS | Domain join | Both |
| Log Analytics Workspace | Monitoring & diagnostics | Both (recommended) |

---

## Permissions Summary

| Task | Required Role |
|------|---------------|
| Create host pool | Desktop Virtualization Contributor |
| Create VMs | Virtual Machine Contributor |
| Join to domain | Domain join permissions |
| Assign users | Desktop Virtualization User Session Operator |

---

## Next Steps

1. Verify all prerequisites are met
2. Proceed to **Host Pool Creation**
3. Configure **Session Hosts**
4. Set up **Application Groups**
5. Assign **Users/Groups**