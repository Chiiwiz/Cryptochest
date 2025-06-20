# Cryptochest Smart Contract

A decentralized personal data vault built on the Stacks blockchain, enabling secure storage and monetized access to encrypted personal data with zero-knowledge proof verification.

## Overview

Cryptochest allows users to create personal encrypted data vaults where they can:
- Store encrypted personal data with cryptographic hashes
- Set custom pricing for data access
- Control data visibility and accessibility
- Earn STX tokens when others access their data
- Maintain complete audit trails of all data interactions

## Features

###  Personal Data Vaults
- Create individual encrypted storage repositories
- Store unlimited encrypted data entries with metadata
- Full ownership and control over your data

###  Monetized Data Access
- Set custom pricing for data access (in STX)
- Earn revenue when others access your data
- Flexible pricing models per user

###  Security & Privacy
- Encrypted data storage with SHA256 hashing
- Zero-knowledge proof verification
- Toggle data visibility on/off
- Comprehensive access audit trails

###  Transparent Analytics
- Complete interaction history logging
- Access audit trails with timestamps
- Payment tracking and verification

## Smart Contract Functions

### Administrative Functions

#### `update-chain-height`
Updates the global blockchain height (admin only).
```clarity
(update-chain-height new-height)
```

### Core Functionality

#### `create-storage`
Initialize a new personal data vault with custom access pricing.
```clarity
(create-storage entry-fee)
```
- `entry-fee`: Price in STX for accessing your data (min: 1, max: 1,000,000)

#### `store-encrypted-data`
Store encrypted data in your personal vault.
```clarity
(store-encrypted-data data-hash cipher-data type-label verification-hash)
```
- `data-hash`: SHA256 hash of the original data (64 chars)
- `cipher-data`: Encrypted data payload (max 256 chars)
- `type-label`: Category/type of data (max 32 chars)
- `verification-hash`: Zero-knowledge proof hash (64 chars)

#### `request-data-access`
Pay to access someone's encrypted data.
```clarity
(request-data-access data-holder record-index access-purpose)
```
- `data-holder`: Principal address of data owner
- `record-index`: Index of the data record to access
- `access-purpose`: Reason for accessing data (max 64 chars)

#### `update-access-fee`
Modify the access fee for your data vault.
```clarity
(update-access-fee new-fee)
```
- `new-fee`: New price in STX (min: 1, max: 1,000,000)

#### `toggle-data-visibility`
Enable/disable access to a specific data record.
```clarity
(toggle-data-visibility record-index)
```
- `record-index`: Index of the record to toggle

### Query Functions

#### `get-storage-info`
Retrieve information about a user's data vault.
```clarity
(get-storage-info user-address)
```

#### `get-encrypted-record`
Get details of a specific encrypted data record.
```clarity
(get-encrypted-record holder record-index)
```

#### `get-interaction-log`
View access history for a specific data record.
```clarity
(get-interaction-log data-holder accessor record-index)
```

## Data Structures

### Personal Storage Registry
Tracks each user's vault metadata:
- `creation-block`: Block height when vault was created
- `total-entries`: Number of data records stored
- `access-price`: Current fee for accessing data

### Encrypted Data Repository
Stores encrypted data records:
- `content-hash`: SHA256 hash of original data
- `encrypted-blob`: Encrypted data payload
- `category-tag`: Data classification/type
- `is-accessible`: Whether data can be accessed
- `proof-signature`: Zero-knowledge proof hash

### Interaction History
Audit trail of all data access:
- `timestamp`: Block height when access occurred
- `request-reason`: Purpose of data access
- `payment-amount`: STX paid for access

## Security Features

### Input Validation
- Block height validation (max: 1,000,000,000)
- Access fee bounds checking (1-1,000,000 STX)
- String length validation for all inputs
- Hash format verification (exactly 64 characters)
- Record existence verification

### Access Control
- Users can only modify their own data
- Self-access prevention (can't pay to access own data)
- Visibility controls per data record
- Admin-only functions properly protected

### Error Handling
- `ERR_ACCESS_DENIED` (401): Unauthorized access attempt
- `ERR_STORAGE_EXISTS` (409): Vault already exists
- `ERR_STORAGE_MISSING` (404): Vault not found
- `ERR_PRICE_INVALID` (400): Invalid pricing
- `ERR_INVALID_INPUT` (422): Invalid input parameters
- `ERR_RECORD_NOT_FOUND` (403): Data record not found

## Getting Started

### Prerequisites
- Stacks wallet with STX for transactions
- Clarity development environment
- Basic understanding of blockchain principles

### Deployment
1. Deploy the contract to Stacks blockchain
2. Initialize admin functions if needed
3. Users can start creating vaults immediately

### Usage Flow
1. **Create Vault**: Call `create-storage` with desired access fee
2. **Store Data**: Use `store-encrypted-data` to add encrypted records
3. **Set Pricing**: Adjust fees with `update-access-fee`
4. **Control Access**: Toggle visibility with `toggle-data-visibility`
5. **Monetize**: Earn STX when others access your data via `request-data-access`

## Use Cases

### Personal Data Monetization
- Sell access to personal fitness data
- Monetize consumer behavior insights
- License personal creative content

### Research & Analytics
- Provide anonymized data for research
- Enable privacy-preserving analytics
- Support academic studies with controlled data access

### Identity & Verification
- Store encrypted identity documents
- Provide selective disclosure of credentials
- Enable zero-knowledge identity verification

### Healthcare Data
- Secure storage of medical records
- Controlled sharing with healthcare providers
- Research data contribution with compensation

## Technical Specifications

- **Blockchain**: Stacks
- **Language**: Clarity
- **Token**: STX (for payments)
- **Encryption**: Client-side (off-chain)
- **Hash Algorithm**: SHA256
- **Zero-Knowledge Proofs**: Supported via hash verification

## Security Considerations

1. **Encryption**: Data must be encrypted client-side before storage
2. **Key Management**: Users responsible for encryption key security
3. **Hash Verification**: Always verify data integrity using provided hashes
4. **Access Control**: Regularly review and update data visibility settings
5. **Pricing Strategy**: Set appropriate access fees to balance monetization and privacy

## Development

### Testing
Test all functions with various input scenarios:
- Valid and invalid inputs
- Edge cases and boundary conditions
- Access control mechanisms
- Payment flows

### Integration
- Frontend interfaces for user interaction
- Encryption/decryption libraries
- Payment processing systems
- Analytics dashboards

## Contributing

1. Fork the repository
2. Create feature branches
3. Add comprehensive tests
4. Submit pull requests with detailed descriptions
