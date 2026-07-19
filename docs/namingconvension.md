# Resource Naming Guidelines

## Environments

- `dev`
- `prod`

## Naming principles

- Use lowercase letters only
- Separate segments with hyphens where possible
- Include the environment as a suffix
- Add region when relevant (for example `centralus`)
- Keep names consistent across resource types

## Resource group

Format: `rg-<app>-<env>`

- `rg-selfhosted-dev`
- `rg-selfhosted-prod`

## Virtual network (VNet)

Format: `vnet-<app>-<env>-<region>-<sequence>`

- `vnet-selfhosted-dev-centralus-001`
- `vnet-selfhosted-prod-centralus-001`

## Subnets

Format: `snet-<purpose>-<env>-<region>`

- `snet-aks-dev-centralus`
- `snet-services-dev-centralus`

- `snet-aks-prod-centralus`
- `snet-services-prod-centralus`

## Network security groups (NSGs)

Format: `nsg-<purpose>-<env>-<region>`

- `nsg-selfhosted-dev-centralus`
- `nsg-services-dev-centralus`

- `nsg-selfhosted-prod-centralus`
- `nsg-services-prod-centralus`

## Key vault

Format: `kv-<app>-<env>-<sequence>`

- `kv-selfhosted-dev-001`
- `kv-selfhosted-prod-001`

## Database

Format: `sqldb-<app>-<env>-<sequence>`

- `sqldb-selfhosted  -dev-001`
- `sqldb-selfhosted-prod-001`

## Container Registry

Format: `acr<app><env><sequence>`

- `acrselfhosteddev001`
- `acrselfhostedprod001`

## StorageAccount

Format: `stg<app><env><sequence>`

- `stgghselfhosteddev001`
- `stgghselfhostedprod001`

## Azure Container Instance

- `acighselfhosteddev001`
- `acighselfhostedprod001`

## Data Disk

Format: `datadisk<app><env><sequence>`

- `datadiskghselfhosteddev001`
- `datadiskghselfhostedprod001`

## Azure Private Endpoint for Key Vault, Storage Account, and Container Registry

Format: `pe<app><env><sequence>`

- `peghselfhostedkvdev001`
- `peghselfhostedprod001`

- `peghselfhostedstgdev001`
- `peghselfhostedstgprod001`

- `peghselfhostedacrdev001`
- `peghselfhostedacrprod001`

## Azure Bastion Host

Format: `bastion-<app>-<env>-<region>`

- `bastion-selfhosted-dev-centralus`
- `bastion-selfhosted-prod-centralus`

## Azure Firewall

Format: `firewall-<app>-<env>-<region>`

- `firewall-selfhosted-dev-centralus`
- `firewall-selfhosted-prod-centralus`

## Kubernetes Cluster

Format: `aks-<app>-<env>-<region>-<sequence>`

- `aks-selfhosted-dev-centralus-001`
- `aks-selfhosted-prod-centralus-001`

## Virtual Machine

Format: `vm-<app>-<env>-<region>-<sequence>`

- `vm-selfhosted-dev-centralus-001`
- `vm-selfhosted-prod-centralus-001`

## Managed Disk

Format: `mdisk-<app>-<env>-<region>-<sequence>`

- `mdisk-selfhosted-dev-centralus-001`
- `mdisk-selfhosted-prod-centralus-001`
