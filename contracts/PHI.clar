;; title: PHI
;; version: 1.0.0
;; summary: $PHI is a fungible token with a fixed supply for funding R&D and community-driven initiatives.
;; description: The PHI token is designed to support decentralized applications by providing a standardized unit of value for transactions within its ecosystem. It is specifically intended for use in the Sphinx DANA. The token has 8 decimals, a total supply of 7,777,777, and the smallest unit is called an 'OXY'. This contract follows the SIP-010 standard without external imports.

(define-trait sip-010-trait
    (
        ;; Read-only functions
        (get-balance (principal) (response uint uint))
        (get-total-supply () (response uint uint))
        (get-decimals () (response uint uint))
        (get-symbol () (response (string-ascii 12) uint))
        (get-name () (response (string-ascii 32) uint))
        (get-token-uri () (response (optional (string-ascii 256)) uint))
        
        ;; Public functions
        (transfer (uint principal principal (optional (buff 34))) (response bool uint))
        (mint (uint principal) (response bool uint))
    )
)

(define-fungible-token phi)

(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))
(define-constant ERR_INVALID_AMOUNT (err u102))
(define-constant ERR_INVALID_RECIPIENT (err u103))
(define-constant ERR_MAX_SUPPLY_EXCEEDED (err u104))

(define-data-var contract-owner principal tx-sender)
(define-constant TOKEN_URI u"https://cyan-rational-cuckoo-19.mypinata.cloud/ipfs/QmYwAFtPctz8UrPLpfiC6xmVnPwXqkEjXrL3mw4im8Hyxo")
(define-constant TOKEN_NAME "PHI")
(define-constant TOKEN_SYMBOL "PHI")
(define-constant TOKEN_DECIMALS u8)
(define-constant MAX_SUPPLY u7777777)

(define-data-var total-minted uint u0)

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance phi who))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply phi))
)

(define-read-only (get-name)
  (ok TOKEN_NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

(define-read-only (get-token-uri)
  (ok (some TOKEN_URI))
)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_OWNER_ONLY)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (let (
      (current-minted (var-get total-minted))
      (new-total (+ current-minted amount))
    )
      (asserts! (<= new-total MAX_SUPPLY) ERR_MAX_SUPPLY_EXCEEDED)
      (try! (ft-mint? phi amount recipient))
      (var-set total-minted new-total)
      (ok true)
    )
  )
)

(define-public (transfer
  (amount uint)
  (sender principal)
  (recipient principal)
  (memo (optional (buff 34)))
)
  (begin
    (asserts! (> amount u0) ERR_INVALID_AMOUNT) 
    (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER) 
    (asserts! (is-eq recipient 'SP000000000000000000002Q6VF78) ERR_INVALID_RECIPIENT) 

    (try! (ft-transfer? phi amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

(begin
    (try! (ft-mint? phi u7777777 'ST39CTMYWSMSGJR89EKFSVG86ZWXNRTA1NPKKEP2J))
    (var-set total-minted u7777777)
)
