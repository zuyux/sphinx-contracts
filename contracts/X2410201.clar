;; Constants
(define-constant question-id u2410201)
(define-constant question-contract 'ST28B2GFEWHR2MXA6P0XNW2GVV9K30HYSC3D9Q0SR)
(define-constant metadata u"QmNrpqntsw24nqG6gieAPXnuuGfYBfCD83n8oBAGp21DVS")  ;; IPFS CID for question metadata
(define-constant owner tx-sender)
(define-constant submission-fee u1)  ;; 1 STX submission fee
(define-constant question-timeout u1000) ;; Timeout in blocks (1000 blocks)

;; Map to store the question's initialization block
(define-map question-init
  { question-id: uint }
  { init-block: uint } ;; Block height at the time of initialization
)

;; Map to store the question status and responses
(define-map question-status
  { question-id: uint }  
  { status: (string-utf8 10) }  ;; "open" or "closed"
)

(define-map user-response
  { user: principal }  
  { ipfs-metadata: (string-utf8 256) }  ;; IPFS metadata link for the user's response
)

(define-read-only (get-block-height)
  block-height)

;; Initialize the question, store the block height
(define-public (initialize-question (init-block uint))
  (begin
    ;; Store the block height at the time of initialization
    (map-set question-init { question-id: question-id }
      { init-block: init-block })
    (ok "Question initialized successfully")
  )
)


;; Read-only function to get the question metadata and status
(define-read-only (get-question-details)
  (match (map-get? question-status { question-id: question-id })
    question-data
    (ok 
      { 
        metadata: metadata,  ;; Return IPFS metadata link
        status: (get status question-data)  ;; Return current status
      }
    )
    (err u404)  ;; Return 404 if question not found
  )
)

;; Public function to close the question (only owner)
(define-public (close-question)
  (begin
    (if (is-eq tx-sender owner)
      (match (map-get? question-status { question-id: question-id })
        question-data
        (let ((current-status (get status question-data)))
          (if (is-eq current-status u"open")
            (begin
              (map-set question-status { question-id: question-id } { status: u"closed" })
              (ok "Question closed successfully")
            )
            (err u403)  ;; Already closed
          )
        )
        (err u404)  ;; Question not found
      )
      (err u401)  ;; Unauthorized
    )
  )
)

;; Function to transfer funds (only owner)
(define-public (transfer-funds (amount uint) (recipient principal))
  (begin
    (if (is-eq tx-sender owner)
      (let ((balance (stx-get-balance (as-contract tx-sender))))
        (if (>= balance amount)
          (let ((transfer-result (stx-transfer? amount (as-contract tx-sender) recipient)))
            (match transfer-result
              true (ok "Transfer successful")
              false (err u402)  ;; Transfer failed
            )
          )
          (err u402)  ;; Insufficient funds
        )
      )
      (err u401)  ;; Unauthorized
    )
  )
)

;; Submit user response with IPFS CID (only if question is open)
(define-public (submit-response (ipfs-cid (string-utf8 256)))
  (begin
    ;; Check question status
    (match (map-get? question-status { question-id: question-id })
      question-data
      (let ((current-status (get status question-data)))
        (if (is-eq current-status u"open")
          ;; Check if user already submitted a response
          (match (map-get? user-response { user: tx-sender })
            response-data (err u403)  ;; User already submitted
            ;; Proceed with submission
            (let ((transfer-result (stx-transfer? submission-fee tx-sender question-contract)))
              (match transfer-result
                true
                  (begin
                    (map-set user-response { user: tx-sender } { ipfs-metadata: ipfs-cid })
                    (ok "Response submitted successfully")
                  )
                false (err u402)  ;; Fee transfer failed
              )
            )
          )
          (err u403)  ;; Question is closed
        )
      )
      (err u404)  ;; Question not found
    )
  )
)


;; Function to contribute additional funds to the question contract pool
(define-public (contribute-to-pool (amount uint))
  (begin
    (if (> amount u0)
      (let ((transfer-result (stx-transfer? amount tx-sender (as-contract tx-sender))))
        (match transfer-result
          true (ok "Funds contributed successfully")
          false (err u402)  ;; Fund transfer failed
        )
      )
      (err u401)  ;; Contribution must be greater than zero
    )
  )
)

;; Read-only function to get user response metadata
(define-read-only (get-response (user principal))
  (match (map-get? user-response { user: user })
    response-data
    (ok (get ipfs-metadata response-data))  ;; Return IPFS CID of the response
    (err u404)  ;; No response found
  )
)

(define-read-only (get-balance)
  (ok (stx-get-balance (as-contract tx-sender)))  ;; Get the contract's STX balance
)

(define-read-only (is-question-timed-out)
  (let ((current-block-height block-height))  ;; block-height can be used directly in read-only functions
    (match (map-get? question-init { question-id: question-id })
      init-data
      (let ((init-block (get init-block init-data)))
        ;; Check if the current block height exceeds the timeout
        (if (> current-block-height (+ init-block question-timeout))
          (ok true)  ;; Question has timed out
          (ok false) ;; Question is still within the allowed time
        )
      )
      (err u404)  ;; Question not found
    )
  )
)

(define-read-only (is-question-open)
  (match (map-get? question-status { question-id: question-id })
    question-data
    (let ((current-status (get status question-data)))
      (if (is-eq current-status u"open")
        (ok true)  ;; Question is open
        (ok false)  ;; Question is closed
      )
    )
    (err u404)  ;; Question not found
  )
)

