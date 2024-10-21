;; Constants
(define-constant question-contract 'ST3STE2Z0HXAT2QV3F7M9VDVDZRJBGYDT559Q9S7.X2410203)  ;; Address of the question contract
(define-constant submission-fee u1)  ;; Hardcoded 1 STX submission fee

;; Map to track user submissions
(define-map user-response
  { user: principal }  ;; Key: User principal (only one response per user)
  { ipfs-metadata: (string-utf8 256) }  ;; Value: IPFS metadata link for the response
)

;; Public function to submit a response
(define-public (submit-response (ipfs-cid (string-utf8 256)))
  (begin
    ;; Check if the user has already submitted a response
    (match (map-get? user-response { user: tx-sender })
      response-data (err u403)  ;; Error: User has already submitted a response
      ;; User has not submitted a response yet, proceed with submission
      (let (
        (transfer-result (stx-transfer? submission-fee tx-sender question-contract))  ;; Transfer fee
      )
        (match transfer-result
          true
            (begin
              ;; Save the response metadata to the map
              (map-set user-response { user: tx-sender }
                { ipfs-metadata: ipfs-cid })
              (ok "Response submitted successfully")
            )
          false (err u402)  ;; Error: Fee transfer failed
        )
      )
    )
  )
)

;; Function to contribute additional funds to the question contract pool
(define-public (contribute-to-pool (amount uint))
  (begin
    ;; Ensure the amount is greater than zero
    (if (> amount u0)
      (let ((transfer-result (stx-transfer? amount tx-sender question-contract)))  ;; Transfer funds
        (match transfer-result
          true (ok "Funds contributed successfully")
          false (err u402)  ;; Error: Fund transfer failed
        )
      )
      (err u401)  ;; Error: Contribution must be greater than zero
    )
  )
)

;; Read-only function to get the user's response metadata
(define-read-only (get-response (user principal))
  (match (map-get? user-response { user: user })
    response-data
    (ok (get ipfs-metadata response-data))  ;; Return the IPFS metadata link
    (err u404)  ;; Error: No response found for the user
  )
)
