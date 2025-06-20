;; Cryptochest: Decentralized Personal Data Vault on Stacks

;; Administrative Variables
(define-data-var system-owner principal tx-sender)
(define-data-var current-chain-height uint u0)

;; Data Structures
(define-map personal-storage-registry
    principal
    {
        creation-block: uint,
        total-entries: uint,
        access-price: uint
    }
)

(define-map encrypted-data-repository
    { owner-address: principal, record-index: uint }
    {
        content-hash: (string-utf8 64),
        encrypted-blob: (string-utf8 256),
        category-tag: (string-utf8 32),
        is-accessible: bool,
        proof-signature: (string-utf8 64)
    }
)

(define-map interaction-history
    { data-holder: principal, accessor: principal, record-index: uint }
    {
        timestamp: uint,
        request-reason: (string-utf8 64),
        payment-amount: uint
    }
)

;; Error Constants
(define-constant ERR_ACCESS_DENIED (err u401))
(define-constant ERR_STORAGE_EXISTS (err u409))
(define-constant ERR_STORAGE_MISSING (err u404))
(define-constant ERR_PRICE_INVALID (err u400))

;; Update current chain height (admin only)
(define-public (update-chain-height (new-height uint))
    (begin
        (asserts! (is-eq tx-sender (var-get system-owner)) ERR_ACCESS_DENIED)
        (ok (var-set current-chain-height new-height))
    )
)

;; Initialize a new personal data storage
(define-public (create-storage (entry-fee uint))
    (let
        ((caller tx-sender))
        (asserts! (is-none (get-storage-info caller)) ERR_STORAGE_EXISTS)
        (asserts! (> entry-fee u0) ERR_PRICE_INVALID)
        (ok (map-set personal-storage-registry
            caller
            {
                creation-block: (var-get current-chain-height),
                total-entries: u0,
                access-price: entry-fee
            }
        ))
    )
)

;; Store encrypted data into personal storage
(define-public (store-encrypted-data 
    (data-hash (string-utf8 64))
    (cipher-data (string-utf8 256))
    (type-label (string-utf8 32))
    (verification-hash (string-utf8 64)))
    (let
        ((caller tx-sender)
         (storage-details (unwrap! (get-storage-info caller) ERR_STORAGE_MISSING))
         (new-index (+ (get total-entries storage-details) u1)))
        
        (map-set encrypted-data-repository
            { owner-address: caller, record-index: new-index }
            {
                content-hash: data-hash,
                encrypted-blob: cipher-data,
                category-tag: type-label,
                is-accessible: true,
                proof-signature: verification-hash
            }
        )
        
        (map-set personal-storage-registry
            caller
            (merge storage-details { total-entries: new-index })
        )
        
        (ok new-index)
    )
)

;; Request paid access to encrypted data
(define-public (request-data-access 
    (data-holder principal)
    (record-index uint)
    (access-purpose (string-utf8 64)))
    (let
        ((requester tx-sender)
         (storage-info (unwrap! (get-storage-info data-holder) ERR_STORAGE_MISSING))
         (cost (get access-price storage-info)))
        
        ;; Log access attempt
        (map-set interaction-history
            { data-holder: data-holder, accessor: requester, record-index: record-index }
            {
                timestamp: (var-get current-chain-height),
                request-reason: access-purpose,
                payment-amount: cost
            }
        )
        
        ;; Process payment
        (stx-transfer? cost requester data-holder)
    )
)

;; Storage information query
(define-read-only (get-storage-info (user-address principal))
    (map-get? personal-storage-registry user-address)
)

;; Encrypted data query
(define-read-only (get-encrypted-record (holder principal) (record-index uint))
    (map-get? encrypted-data-repository { owner-address: holder, record-index: record-index })
)

;; Access history query
(define-read-only (get-interaction-log 
    (data-holder principal)
    (accessor principal)
    (record-index uint))
    (map-get? interaction-history
        { data-holder: data-holder, accessor: accessor, record-index: record-index }
    )
)

;; Modify storage access fee
(define-public (update-access-fee (new-fee uint))
    (let
        ((caller tx-sender)
         (storage-info (unwrap! (get-storage-info caller) ERR_STORAGE_MISSING)))
        (asserts! (> new-fee u0) ERR_PRICE_INVALID)
        (ok (map-set personal-storage-registry
            caller
            (merge storage-info { access-price: new-fee })
        ))
    )
)

;; Toggle data accessibility status
(define-public (toggle-data-visibility (record-index uint))
    (let
        ((caller tx-sender)
         (data-record (unwrap! (get-encrypted-record caller record-index) ERR_ACCESS_DENIED)))
        (ok (map-set encrypted-data-repository
            { owner-address: caller, record-index: record-index }
            (merge data-record { is-accessible: (not (get is-accessible data-record)) })
        ))
    )
)